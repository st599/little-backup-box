#!/bin/bash
################################################################################################
#
# file			 :		video-contact-sheet.sh
# date			 : 		24/12/2019
# author		 :		Simon Thompson (st599)
# copyright		 :		(c) Simon Thompson 2019
# licence		 : 		GNU General Public License version 3
# description	 	 :		Shell script to create a video contact sheet
# requires		 :		FFmpeg, grep, vcs script (https://p.outlyer.net/vcs/files/vcs-1.13.4.gz)
#
################################################################################################

## VARIABLES
vid_dir=$1
VERSION="1.0"
file_type_list="*.mp4 *.MP4 *.mpg *.MPG *.avi *.AVI *.wmv *.WMV *.mpeg *.MPEG *.mxf *.MXF *.mov *.MOV"
BACKUP_PATH=/home/pi/
numframes=20
vidCS=/home/pi/scripts/vcs-1.13.4.sh

## INITIALISE
echo "Creating Video Contact Sheet"
echo "st599 version:"  $VERSION
echo ""

## Change directory
echo "...Changing to Video Directory"
cd $vid_dir

## List directory contents
echo "...Creating List of Videos in Video Directory"
image_list=$(ls $file_type_list 2>/dev/null)
#echo $image_list

for f in $image_list
do
	echo "......Processing $f"
	$vidCS -n 20 -c 5 -u "little-backup-box" -H 250 -j -o video_sheet_${f%.*}.jpg  $f
done

mkdir -p $BACKUP_PATH/CONTACT_SHEETS/
mv video_sheet*jpg $BACKUP_PATH/CONTACT_SHEETS/
