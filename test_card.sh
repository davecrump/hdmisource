#!/bin/bash

#################### ENTER TEST CARD FILE NAMES HERE ########################

NO_OF_720_CARDS=4
NO_OF_1080_CARDS=4

FILE_720_CARD_1=/home/pi/tmp/720_Test_Card_F_Call.jpg
FILE_720_CARD_2=/home/pi/hdmisource/images/720_PM5544.jpg
FILE_720_CARD_3=/home/pi/hdmisource/images/720_75_Colour.jpg
FILE_720_CARD_4=/home/pi/hdmisource/images/720_11_Grey.jpg

FILE_1080_CARD_1=/home/pi/tmp/1080_Test_Card_F_Call.jpg
FILE_1080_CARD_2=/home/pi/hdmisource/images/720_PM5544.jpg
FILE_1080_CARD_3=/home/pi/hdmisource/images/720_75_Colour.jpg
FILE_1080_CARD_4=/home/pi/hdmisource/images/720_11_Grey.jpg


############ FUNCTION TO READ CONFIG FILE #############################

get_config_var() {
lua - "$1" "$2" <<EOF
local key=assert(arg[1])
local fn=assert(arg[2])
local file=assert(io.open(fn))
for line in file:lines() do
local val = line:match("^#?%s*"..key.."=(.*)$")
if (val ~= nil) then
print(val)
break
end
end
EOF
}

################## READ FROM CONFIG FILE #############################
 
CONFIGFILE=/boot/hdmisource_config.txt
BUTTON=$(get_config_var button $CONFIGFILE)
CAM_SWITCH=$(get_config_var cam_switch $CONFIGFILE)
HDMIMODE=$(get_config_var hdmimode $CONFIGFILE)

if [ "$HDMIMODE" == "720p" ] || [ "$HDMIMODE" == "720i" ]; then
  NO_OF_CARDS=$NO_OF_720_CARDS
  BASE_FILE_LABEL="\$FILE_720_CARD_"
else
  NO_OF_CARDS=$NO_OF_1080_CARDS
  BASE_FILE_LABEL="\$FILE_1080_CARD_"
fi

INDEX=1
SHUTDOWN_COUNT=0

# Display first image
DISPLAY_FILE="$BASE_FILE_LABEL$INDEX"
eval "sudo fbi -T 1 -noverbose -a $DISPLAY_FILE >/dev/null 2>/dev/null"

CAM_SWITCH_POS=$(pigs r $CAM_SWITCH)
while [[ $CAM_SWITCH_POS -eq 1 ]]; do              # Test Card selected

  BUTTON_POS=$(pigs r $BUTTON)                     # Check Button

  if [[ $BUTTON_POS -eq 0 ]]; then

    ((SHUTDOWN_COUNT++))                          # Increment counter (only change when it is 1)

    #echo $SHUTDOWN_COUNT incremented

    if [[ $INDEX -eq 0 ]] && [[ $SHUTDOWN_COUNT -eq 1 ]]; then   # Kill some fbi processes
      sudo killall fbi
    fi
  
    if [[ $SHUTDOWN_COUNT -eq 1 ]]; then          # only change testcard once

    #echo $SHUTDOWN_COUNT in loop

      ((INDEX++))
      DISPLAY_FILE="$BASE_FILE_LABEL$INDEX"
      #echo $DISPLAY_FILE
      eval "sudo fbi -T 1 -noverbose -a $DISPLAY_FILE >/dev/null 2>/dev/null"
      if [[ $INDEX -eq $NO_OF_CARDS ]]; then
        INDEX=0
      fi
    fi
  else                                            # Button released
    SHUTDOWN_COUNT=0
  fi
  sleep 0.1s

done