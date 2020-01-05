#!/bin/bash
################################################################################################
#
# file			 :		images-contact-sheet.sh
# date			 : 		24/12/2019
# author		 :		Simon Thompson (st599)
# copyright		 :		(c) Simon Thompson 2019
# licence		 : 		GNU General Public License version 3
# description	 	 :		Shell script to create a video contact sheet
# requires		 :		imagemagick
#
################################################################################################


## VARIABLES
img_dir=$1
VERSION="1.0"
file_type_list="*.jpg *.JPG *.jpeg *.png *.PNG *.gif *.GIF *.bmp *.BMP *.tif *.tiff *.TIF *.TIFF"
BACKUP_PATH=/home/pi/

## INITIALISE
echo "Creating Image Contact Sheet"
echo "st599 version:"  $VERSION
echo ""

## Change directory
echo "...Changing to Image Directory"
cd $img_dir

## List directory contents
echo "...Creating List of Images in Image Directory"
image_list=$(ls $file_type_list 2>/dev/null)
#echo $image_list

## Create Contact Sheet
echo "...Creating Contact Sheet using Imagemagick"
montage -verbose -label '%f' -font Helvetica -pointsize 10 -background '#000000' -fill 'gray' -define jpeg:size=200x200 -geometry 200x200+2+2 -auto-orient $image_list contact-dark.jpg 

## Add Label
echo "...Adding Label"
curr_dir=$(pwd)
label_img=$(echo $curr_dir | tr / _)
#echo $label_img
convert contact-dark.jpg -background Plum -splice 0x18 -annotate +12+12 $label_img contact-dark-label.jpg
rm contact-dark.jpg

## Move to Correct Output Directory
mkdir -p $BACKUP_PATH/CONTACT_SHEETS/
mv contact-dark-label.jpg $BACKUP_PATH/CONTACT_SHEETS/$label_img.jpg

