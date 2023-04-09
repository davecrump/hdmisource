#!/bin/bash

# called by .bashrc on startup to generate labelled cards and make the testcard run
# Dave G8GKQ March 2023

# Check the start-up mode.  Config file can be modified to prevent boot loop
if ! grep -q "^startup=hdmisource" /boot/hdmisource_config.txt ; then
  exit
fi

# First check the HDMI mode

source /home/pi/hdmisource/hdmi_mode_check.sh

# Read in the user details

CALL="BATC"
NUMBERS="0000"
LOCATOR="IO90LU"

read CALL < /boot/testcard/callsign.txt
read NUMBERS < /boot/testcard/numbers.txt
read LOCATOR < /boot/testcard/locator.txt

# Add a callsign to both Test Card Fs

convert -font "FreeSans" -size 1280x160 xc:transparent -fill white -gravity Center \
  -pointsize 70 -annotate 0 "$CALL" /home/pi/tmp/caption.png
convert ~/hdmisource/images/720_Test_Card_F.jpg /home/pi/tmp/caption.png \
  -geometry +0+564 -composite /home/pi/tmp/720_Test_Card_F_Call.jpg

rm /home/pi/tmp/caption.png

convert -font "FreeSans" -size 1920x240 xc:transparent -fill white -gravity Center \
  -pointsize 105 -annotate 0 "$CALL" /home/pi/tmp/caption.png
convert ~/hdmisource/images/1080_Test_Card_F.jpg /home/pi/tmp/caption.png \
  -geometry +0+846 -composite /home/pi/tmp/1080_Test_Card_F_Call.jpg

# Generate the captions for the contest card

#convert -size 720x200 xc:transparent -fill black -gravity Center -pointsize 100 -annotate 0 "$CALL" /home/pi/tmp/caption1.png
#convert -size 720x320 xc:transparent -fill black -gravity Center -pointsize 250 -annotate 0 "$NUMBERS" /home/pi/tmp/caption2.png
#convert -size 720x200 xc:transparent -fill black -gravity Center -pointsize 75 -annotate 0 "$LOCATOR" /home/pi/tmp/caption3.png

# Apply the captions to the contest card
# Basic card needs to have some non-white content

#sudo convert /home/pi/vidsource/wht720.jpg /home/pi/tmp/caption1.png -geometry +0+20 -composite /home/pi/tmp/contest.jpg
#sudo convert /home/pi/tmp/contest.jpg /home/pi/tmp/caption2.png -geometry +0+150 -composite /home/pi/tmp/contest.jpg
#sudo convert /home/pi/tmp/contest.jpg /home/pi/tmp/caption3.png -geometry +0+400 -composite /home/pi/tmp/contest.jpg
#sudo cp /home/pi/tmp/contest.jpg /boot/testcard/contest.jpg

# Insert Call and Locator into banner screens if not already there

#sudo sed -i "s/TestText/${CALL} in ${LOCATOR}/g" /boot/testcard/tcdata1.txt
#sudo sed -i "s/TestText/${CALL} in ${LOCATOR}/g" /boot/testcard/tcdata2.txt

# if banner text includes BATC or IO90LU, replace it with latest callsign and locator

#sudo sed -i "/BATC/c\\$CALL in $LOCATOR" /boot/testcard/tcdata1.txt
#sudo sed -i "/BATC/c\\$CALL in $LOCATOR" /boot/testcard/tcdata2.txt
#sudo sed -i "/IO90LU/c\\$CALL in $LOCATOR" /boot/testcard/tcdata1.txt
#sudo sed -i "/IO90LU/c\\$CALL in $LOCATOR" /boot/testcard/tcdata2.txt

# Run the Controller

/home/pi/hdmisource/controller.sh




