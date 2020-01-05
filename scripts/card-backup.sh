#!/usr/bin/env bash

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# IMPORTANT:
# Run the install-little-backup-box.sh script first
# to install the required packages and configure the system.

CONFIG_DIR=$(dirname "$0")
CONFIG="${CONFIG_DIR}/config.cfg"
source "$CONFIG"

if [ $VERBOSE = true ]; then
	echo "LBB CARD BACKUP"
fi

# Set the ACT LED to heartbeat
sudo sh -c "echo heartbeat > /sys/class/leds/led0/trigger"

# Shutdown after a specified period of time (in minutes) if no device is connected.
sudo shutdown -h $SHUTD "Shutdown is activated. To cancel: sudo shutdown -c"
if [ $DISP = true ]; then
    oled r
    oled +a "Shutdown active"
    oled +b "Insert storage"
    sudo oled s 
fi

if [ $VERBOSE = true ]; then
	echo "Shutdown active"
    echo "Insert storage"
fi

# Wait for a USB storage device (e.g., a USB flash drive)
STORAGE=$(ls /dev/* | grep "$STORAGE_DEV" | cut -d"/" -f3)
while [ -z "${STORAGE}" ]
do
    sleep 1
    STORAGE=$(ls /dev/* | grep "$STORAGE_DEV" | cut -d"/" -f3)
done
# When the USB storage device is detected, mount it
mount /dev/"$STORAGE_DEV" "$STORAGE_MOUNT_POINT"

# Set the ACT LED to blink at 1000ms to indicate that the storage device has been mounted
sudo sh -c "echo timer > /sys/class/leds/led0/trigger"
sudo sh -c "echo 1000 > /sys/class/leds/led0/delay_on"

# If display support is enabled, notify that the storage device has been mounted
if [ $DISP = true ]; then
    oled r
    oled +a "Storage OK"
    oled +b "Card reader..."
    sudo oled s 
fi

if [ $VERBOSE = true ]; then
	echo "Storage OK"
    echo "Card reader..."
fi

# Wait for a card reader or a camera
# takes first device found
CARD_READER=($(ls /dev/* | grep "$CARD_DEV" | cut -d"/" -f3))
until [ ! -z "${CARD_READER[0]}" ]
  do
  sleep 1
  CARD_READER=($(ls /dev/* | grep "$CARD_DEV" | cut -d"/" -f3))
done

# If the card reader is detected, mount it and obtain its UUID
if [ ! -z "${CARD_READER[0]}" ]; then
  mount /dev"/${CARD_READER[0]}" "$CARD_MOUNT_POINT"

  # Set the ACT LED to blink at 500ms to indicate that the card has been mounted
  sudo sh -c "echo 500 > /sys/class/leds/led0/delay_on"

  # Cancel shutdown
  sudo shutdown -c
  
  # If display support is enabled, notify that the card has been mounted
  if [ $DISP = true ]; then
      oled r
      oled +a "Card reader OK"
      oled +b "Working..."
      sudo oled s 
  fi

if [ $VERBOSE = true ]; then
	echo "Card reader OK"
    echo "Working..."
fi

  # Create  a .id random identifier file if doesn't exist
  cd "$CARD_MOUNT_POINT"
  if [ ! -f *.id ]; then
    random=$(echo $RANDOM)
    touch $(date -d "today" +"%Y%m%d%H%M")-$random.id
  fi
  ID_FILE=$(ls *.id)
  ID="${ID_FILE%.*}"
  cd

  # Set the backup path
  BACKUP_PATH="$STORAGE_MOUNT_POINT"/"$ID"
  # Perform backup using rsync
  rsync -avh --info=progress2 --exclude "*.id" "$CARD_MOUNT_POINT"/ "$BACKUP_PATH"
fi

# If display support is enabled, notify that the backup is complete
if [ $DISP = true ]; then
    oled r
    oled +a "Backup complete"
    sudo oled s 
fi

if [ $VERBOSE = true ]; then
	echo "Backup complete"
fi


# If image contact sheet is enabled, run
if [ $IMG_CS = true ]; then
	images-contact-sheet.sh $BACKUP_PATH
	if [ $DISP = true ]; then
    	oled r
    	oled +a "Image CS complete"
    	sudo oled s 
	fi
	if [ $VERBOSE = true ]; then
		echo "Image CS complete"
    fi
fi


# If video contact sheet is enabled, run
if [ $VID_CS = true ]; then
	video-contact-sheet.sh $BACKUP_PATH
	if [ $DISP = true ]; then
    	oled r
    	oled +a "Video CS complete"
    	sudo oled s 
	fi
	if [ $VERBOSE = true ]; then
		echo "Video CS complete"
    fi
fi

# Shutdown
sync
if [ $DISP = true ]; then
	oled r
	oled +a "process complete"
	sleep 2
    oled r
fi
if [ $VERBOSE = true ]; then
	echo "process complete"
fi
shutdown -h now
