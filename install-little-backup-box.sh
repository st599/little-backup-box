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

sudo apt update
sudo apt full-upgrade -y
sudo apt update

sudo apt install -y acl git-core screen rsync exfat-fuse exfat-utils ntfs-3g gphoto2 libimage-exiftool-perl dialog php minidlna samba samba-common-bin

sudo apt autoremove

curl https://rclone.org/install.sh | sudo bash

USER="$1"

if [ -z "$USER" ]; then
    USER="pi"
    fi
sudo mkdir /media/card
sudo mkdir /media/storage
sudo chown -R $USER:users /media/storage
sudo chmod -R 775 /media/storage
sudo setfacl -Rdm g:$USER:rw /media/storage

sudo cp /etc/minidlna.conf /etc/minidlna.conf.orig
sudo sed -i 's|'media_dir=/var/lib/minidlna'|'media_dir=/media/storage'|' /etc/minidlna.conf
sudo sh -c "echo 'media_dir=/home/$USER/BACKUP' >> /etc/minidlna.conf"
sudo service minidlna start

cd
git clone https://github.com/dmpop/little-backup-box.git

ln -s /media/storage /home/$USER/little-backup-box/scripts

echo -e '\nBAK_DIR="/home/'$USER'/BACKUP" # Home directory path' >> little-backup-box/scripts/config.cfg
mkdir -p /home/$USER/BACKUP
chown $USER:users -R /home/$USER/BACKUP



BACKTITLE="Little Backup Box"

OPTIONS=(1 "Remote control"
         2 "Card backup"
         3 "Camera backup"
	 4 "Internal backup")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "Backup Mode" \
                --menu "Select the default backup mode:" \
                15 40 4 \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
	    crontab -l | { cat; echo "@reboot cd /home/"$USER"/little-backup-box/scripts && sudo php -S 0.0.0.0:8000"; } | crontab
            ;;
        2)
            crontab -l | { cat; echo "@reboot sudo /home/"$USER"/little-backup-box/scripts/card-backup.sh >> /home/"$USER"/little-backup-box.log 2>&1"; } | crontab
            ;;
        3)
	    crontab -l | { cat; echo "@reboot sudo /home/"$USER"/little-backup-box/scripts/camera-backup.sh >> /home/"$USER"/little-backup-box.log 2>&1"; } | crontab
            ;;
	4)
	    crontab -l | { cat; echo "@reboot sudo /home/"$USER"/little-backup-box/scripts/internal-backup.sh >> /home/"$USER"/little-backup-box.log 2>&1"; } | crontab
            ;;
esac

crontab -l | { cat; echo "@reboot sudo /home/"$USER"/little-backup-box/scripts/restart-servers.sh"; } | crontab

crontab -l | { cat; echo "*/5 * * * * sudo /home/"$USER"/little-backup-box/scripts/ip.sh"; } | crontab

sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.orig
pw="raspberry"
(echo $pw; echo $pw ) | sudo smbpasswd -s -a pi
sudo sh -c "echo '### Global Settings ###' > /etc/samba/smb.conf"
sudo sh -c "echo '[global]' >> /etc/samba/smb.conf"
sudo sh -c "echo 'workgroup = WORKGROUP' >> /etc/samba/smb.conf"
sudo sh -c "echo 'wide links = yes' >> /etc/samba/smb.conf"
sudo sh -c "echo 'unix extensions = no' >> /etc/samba/smb.conf"
sudo sh -c "echo 'dns proxy = no' >> /etc/samba/smb.conf"
sudo sh -c "echo '### Debugging/Accounting ###' >> /etc/samba/smb.conf"
sudo sh -c "echo 'log file = /var/log/samba/log.%m' >> /etc/samba/smb.conf"
sudo sh -c "echo 'max log size = 1000' >> /etc/samba/smb.conf"
sudo sh -c "echo 'syslog = 0' >> /etc/samba/smb.conf"
sudo sh -c "echo 'panic action = /usr/share/samba/panic-action %d' >> /etc/samba/smb.conf"
sudo sh -c "echo '### Authentication ###' >> /etc/samba/smb.conf"
sudo sh -c "echo 'security = user' >> /etc/samba/smb.conf"
sudo sh -c "echo 'map to guest = Bad User' >> /etc/samba/smb.conf"
sudo sh -c "echo 'guest account = pi' >> /etc/samba/smb.conf"
sudo sh -c "echo '### Share Definitions ###' >> /etc/samba/smb.conf"
sudo sh -c "echo '[little-backup-box]' >> /etc/samba/smb.conf"
sudo sh -c "echo 'comment = Little Backup Box /media/storage' >> /etc/samba/smb.conf"
sudo sh -c "echo 'path = /media/storage' >> /etc/samba/smb.conf"
sudo sh -c "echo 'browseable = yes' >> /etc/samba/smb.conf"
sudo sh -c "echo 'force user = $USER' >> /etc/samba/smb.conf"
sudo sh -c "echo 'force group = $USER' >> /etc/samba/smb.conf"
sudo sh -c "echo 'admin users = $USER' >> /etc/samba/smb.conf"
sudo sh -c "echo 'writeable = yes' >> /etc/samba/smb.conf"
sudo sh -c "echo 'read only = no' >> /etc/samba/smb.conf"
sudo sh -c "echo 'guest ok = yes' >> /etc/samba/smb.conf"
sudo sh -c "echo 'create mask = 0777' >> /etc/samba/smb.conf"
sudo sh -c "echo 'directory mask = 0777' >> /etc/samba/smb.conf"

sudo sh -c "echo '[internal-backup]' >> /etc/samba/smb.conf"
sudo sh -c "echo 'comment = Little Backup Box internal backup' >> /etc/samba/smb.conf"
sudo sh -c "echo 'path = /home/$USER/BACKUP' >> /etc/samba/smb.conf"
sudo sh -c "echo 'browseable = yes' >> /etc/samba/smb.conf"
sudo sh -c "echo 'force user = $USER' >> /etc/samba/smb.conf"
sudo sh -c "echo 'force group = $USER' >> /etc/samba/smb.conf"
sudo sh -c "echo 'admin users = $USER' >> /etc/samba/smb.conf"
sudo sh -c "echo 'writeable = yes' >> /etc/samba/smb.conf"
sudo sh -c "echo 'read only = no' >> /etc/samba/smb.conf"
sudo sh -c "echo 'guest ok = yes' >> /etc/samba/smb.conf"
sudo sh -c "echo 'create mask = 0777' >> /etc/samba/smb.conf"
sudo sh -c "echo 'directory mask = 0777' >> /etc/samba/smb.conf"
sudo samba restart

chmod +x little-backup-box/scripts/*.sh
cd

#########################################################################################
# ST: Install Contact Sheet Creation
dialog --clear \
       --title "Enable Contact Sheet support" \
       --backtitle "$BACKTITLE" \
       --yesno "Enable support Image Contact Sheets" 7 60

response=$?
case $response in
    0) clear
	   echo -e '\nIMG_CS=true # Enable image contact sheet' >> little-backup-box/scripts/config.cfg
       sudo apt-get install -y imagemagick
       clear
       ;;
    1) clear
	   echo -e '\nIMG_CS=false # Enable image contact sheet' >> little-backup-box/scripts/config.cfg
	   clear
	;;
esac

dialog --clear \
       --title "Enable Contact Sheet support" \
       --backtitle "$BACKTITLE" \
       --yesno "Enable support Video Contact Sheets" 7 60

response=$?
case $response in
    0) clear
	   echo -e '\nVID_CS=true # Enable video contact sheet' >> little-backup-box/scripts/config.cfg
       wget https://p.outlyer.net/vcs/files/vcs-1.13.4.gz
	   gunzip -c vcs-1.13.4.gz > little-backup-box/scripts/vcs-1.13.4.sh
	   chmod a+x little-backup-box/scripts/vcs-1.13.4.sh
	   sudo apt install -y ffmpeg  gawk
       clear
       ;;
    1) clear
	   echo -e '\nVID_CS=false # Enable video contact sheet' >> little-backup-box/scripts/config.cfg
	   clear
	;;
esac
#########################################################################################

dialog --clear \
       --title "Enable OLED support" \
       --backtitle "$BACKTITLE" \
       --yesno "Enable support for a 128x64 OLED display?" 7 60

response=$?
case $response in
    0) clear
       sudo apt-get install -y wiringpi i2c-tools
       git clone https://github.com/dmpop/ssd1306_rpi.git
       cd ssd1306_rpi
       cc -o oled oled.c fontx.c -lwiringPi -lpthread -DI2C
       sudo cp oled /usr/local/bin/
       sudo chown root:root /usr/local/bin/oled
       sudo chmod 755 /usr/local/bin/oled
       cd
       crontab -l | { cat; echo "@reboot sudo /home/"$USER"/little-backup-box/scripts/start.sh"; } | crontab
       echo -e '\nDISP=true # Enable OLED display' >> little-backup-box/scripts/config.cfg
       dialog --clear \
	      --title "Enable I2C" \
	      --backtitle "$BACKTITLE" \
	      --msgbox "Almost done! Run the following command:\n\nsudo raspi-config\n\nSwitch to the Interfacing Options section and enable I2C. Then reboot the system." 15 30
       clear
       ;;
    1)  echo -e '\nDISP=false # Enable OLED display' >> little-backup-box/scripts/config.cfg
	dialog --clear \
	       --title "Setup finished" \
	       --backtitle "$BACKTITLE" \
	       --infobox "\nAll done! The system will reboot now." 5 45 ; sleep 3
	clear
	sudo reboot
	;;
    255)  echo -e '\nDISP=false" # Enable OLED display' >> little-backup-box/scripts/config.cfg
	  dialog --clear \
		 --title "Setup finished" \
		 --backtitle "$BACKTITLE" \
		 --infobox "\nAll done! The system will reboot now." 5 45 ; sleep 3
	  clear
	  sudo reboot
	  ;;
esac

