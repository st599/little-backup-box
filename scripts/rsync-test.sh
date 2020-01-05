#!/bin/bash

rsync -avh --info=progress2 --exclude "*.id"  $1 $2 | ./oled-rsync-progress.sh exclude.txt
