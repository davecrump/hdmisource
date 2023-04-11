#!/bin/bash

# This script compares the demanded hdmi mode with /boot/config.txt
# and amends the file and reboots if the mode needs to changed

# Modes auto 1080p 1080i 720p 720i fps 15 24 25 30 50 60 100 120
#hdmimode=1080p
#fps=25



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
HDMIMODE=$(get_config_var hdmimode $CONFIGFILE)
FPS=$(get_config_var fps $CONFIGFILE)

################# CHECK CURRENT MODE #################################

CHANGE_REQUIRED=YES

if [ "$HDMIMODE" == "auto" ]; then
  if ! grep -q "^hdmi_group=" /boot/config.txt ; then
    if ! grep -q "^hdmi_mode=" /boot/config.txt ; then
      if ! grep -q "^hdmi_drive=" /boot/config.txt ; then
        if ! grep -q "^hdmi_cvt=" /boot/config.txt ; then
          CHANGE_REQUIRED=NO
        fi
      fi
    fi
  fi
  if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo > /home/pi/tmp/hdmi_def.txt
  fi
fi

if [ "$HDMIMODE" == "1080p" ]; then

  case "$FPS" in
    "24" )
      if grep -q "^hdmi_group=1" /boot/config.txt ; then      
        if grep -q "^hdmi_mode=32" /boot/config.txt ; then
          if grep -q "^hdmi_drive=2" /boot/config.txt ; then
            CHANGE_REQUIRED=NO
          fi
        fi
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_group=1" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=32" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "25" )
      if grep -q "^hdmi_group=1" /boot/config.txt ; then      
        if grep -q "^hdmi_mode=33" /boot/config.txt ; then
          if grep -q "^hdmi_drive=2" /boot/config.txt ; then
            CHANGE_REQUIRED=NO
          fi
        fi
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_group=1" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=33" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "30" )
      if grep -q "^hdmi_group=1" /boot/config.txt ; then      
        if grep -q "^hdmi_mode=34" /boot/config.txt ; then
          if grep -q "^hdmi_drive=2" /boot/config.txt ; then
            CHANGE_REQUIRED=NO
          fi
        fi
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_group=1" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=34" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "50" )
      if grep -q "^hdmi_group=1" /boot/config.txt ; then      
        if grep -q "^hdmi_mode=31" /boot/config.txt ; then
          if grep -q "^hdmi_drive=2" /boot/config.txt ; then
            CHANGE_REQUIRED=NO
          fi
        fi
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_group=1" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=31" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "60" )
      if grep -q "^hdmi_group=1" /boot/config.txt ; then      
        if grep -q "^hdmi_mode=16" /boot/config.txt ; then
          if grep -q "^hdmi_drive=2" /boot/config.txt ; then
            CHANGE_REQUIRED=NO
          fi
        fi
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_group=1" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=16" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "100" )
      if grep -q "^hdmi_group=1" /boot/config.txt ; then      
        if grep -q "^hdmi_mode=64" /boot/config.txt ; then
          if grep -q "^hdmi_drive=2" /boot/config.txt ; then
            CHANGE_REQUIRED=NO
          fi
        fi
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_group=1" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=64" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "120" )
      if grep -q "^hdmi_group=1" /boot/config.txt ; then      
        if grep -q "^hdmi_mode=63" /boot/config.txt ; then
          if grep -q "^hdmi_drive=2" /boot/config.txt ; then
            CHANGE_REQUIRED=NO
          fi
        fi
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_group=1" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=63" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
  esac
fi

if [ "$HDMIMODE" == "1080i" ]; then
  case "$FPS" in
    "24" )
      if grep -q "^hdmi_cvt=1920 1080 24 3 0 1 0" /boot/config.txt ; then      
        CHANGE_REQUIRED=NO
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_cvt=1920 1080 24 3 0 1 0" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_group=2" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=87" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "25" )
      if grep -q "^hdmi_cvt=1920 1080 25 3 0 1 0" /boot/config.txt ; then      
        CHANGE_REQUIRED=NO
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_cvt=1920 1080 24 3 0 1 0" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_group=2" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=87" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "30" )
      if grep -q "^hdmi_cvt=1920 1080 30 3 0 1 0" /boot/config.txt ; then      
        CHANGE_REQUIRED=NO
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_cvt=1920 1080 30 3 0 1 0" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_group=2" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=87" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "50" )
      if grep -q "^hdmi_group=1" /boot/config.txt ; then      
        if grep -q "^hdmi_mode=20" /boot/config.txt ; then
          if grep -q "^hdmi_drive=2" /boot/config.txt ; then
            CHANGE_REQUIRED=NO
          fi
        fi
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_group=1" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=20" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "60" )
      if grep -q "^hdmi_group=1" /boot/config.txt ; then      
        if grep -q "^hdmi_mode=5" /boot/config.txt ; then
          if grep -q "^hdmi_drive=2" /boot/config.txt ; then
            CHANGE_REQUIRED=NO
          fi
        fi
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_group=1" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=5" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "100" )
      if grep -q "^hdmi_cvt=1920 1080 100 3 0 1 0" /boot/config.txt ; then      
        CHANGE_REQUIRED=NO
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_cvt=1920 1080 100 3 0 1 0" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_group=2" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=87" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "120" )
      if grep -q "^hdmi_group=1" /boot/config.txt ; then      
        if grep -q "^hdmi_mode=46" /boot/config.txt ; then
          if grep -q "^hdmi_drive=2" /boot/config.txt ; then
            CHANGE_REQUIRED=NO
          fi
        fi
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_group=1" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=46" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
  esac
fi

if [ "$HDMIMODE" == "720p" ]; then

  case "$FPS" in
    "24" )
      if grep -q "^hdmi_group=1" /boot/config.txt ; then      
        if grep -q "^hdmi_mode=60" /boot/config.txt ; then
          if grep -q "^hdmi_drive=2" /boot/config.txt ; then
            CHANGE_REQUIRED=NO
          fi
        fi
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_group=1" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=60" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "25" )
      if grep -q "^hdmi_group=1" /boot/config.txt ; then      
        if grep -q "^hdmi_mode=61" /boot/config.txt ; then
          if grep -q "^hdmi_drive=2" /boot/config.txt ; then
            CHANGE_REQUIRED=NO
          fi
        fi
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_group=1" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=61" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "30" )
      if grep -q "^hdmi_group=1" /boot/config.txt ; then      
        if grep -q "^hdmi_mode=62" /boot/config.txt ; then
          if grep -q "^hdmi_drive=2" /boot/config.txt ; then
            CHANGE_REQUIRED=NO
          fi
        fi
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_group=1" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=62" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "50" )
      if grep -q "^hdmi_group=1" /boot/config.txt ; then      
        if grep -q "^hdmi_mode=19" /boot/config.txt ; then
          if grep -q "^hdmi_drive=2" /boot/config.txt ; then
            CHANGE_REQUIRED=NO
          fi
        fi
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_group=1" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=19" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "60" )
      if grep -q "^hdmi_group=1" /boot/config.txt ; then      
        if grep -q "^hdmi_mode=4" /boot/config.txt ; then
          if grep -q "^hdmi_drive=2" /boot/config.txt ; then
            CHANGE_REQUIRED=NO
          fi
        fi
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_group=1" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=4" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "100" )
      if grep -q "^hdmi_group=1" /boot/config.txt ; then      
        if grep -q "^hdmi_mode=41" /boot/config.txt ; then
          if grep -q "^hdmi_drive=2" /boot/config.txt ; then
            CHANGE_REQUIRED=NO
          fi
        fi
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_group=1" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=41" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "120" )
      if grep -q "^hdmi_group=1" /boot/config.txt ; then      
        if grep -q "^hdmi_mode=47" /boot/config.txt ; then
          if grep -q "^hdmi_drive=2" /boot/config.txt ; then
            CHANGE_REQUIRED=NO
          fi
        fi
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_group=1" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=47" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
  esac
fi

if [ "$HDMIMODE" == "720i" ]; then
  case "$FPS" in
    "24" )
      if grep -q "^hdmi_cvt=1280 720 24 3 0 1 0" /boot/config.txt ; then      
        CHANGE_REQUIRED=NO
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_cvt=1280 720 24 3 0 1 0" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_group=2" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=87" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "25" )
      if grep -q "^hdmi_cvt=1280 720 25 3 0 1 0" /boot/config.txt ; then      
        CHANGE_REQUIRED=NO
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_cvt=1280 720 25 3 0 1 0" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_group=2" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=87" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "30" )
      if grep -q "^hdmi_cvt=1280 720 30 3 0 1 0" /boot/config.txt ; then      
        CHANGE_REQUIRED=NO
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_cvt=1280 720 30 3 0 1 0" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_group=2" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=87" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "50" )
      if grep -q "^hdmi_cvt=1280 720 50 3 0 1 0" /boot/config.txt ; then      
        CHANGE_REQUIRED=NO
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_cvt=1280 720 50 3 0 1 0" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_group=2" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=87" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "60" )
      if grep -q "^hdmi_cvt=1280 720 60 3 0 1 0" /boot/config.txt ; then      
        CHANGE_REQUIRED=NO
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_cvt=1280 720 60 3 0 1 0" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_group=2" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=87" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "100" )
      if grep -q "^hdmi_cvt=1280 720 100 3 0 1 0" /boot/config.txt ; then      
        CHANGE_REQUIRED=NO
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_cvt=1280 720 100 3 0 1 0" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_group=2" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=87" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
    ;;
    "120" )
      if grep -q "^hdmi_cvt=1280 720 120 3 0 1 0" /boot/config.txt ; then      
        CHANGE_REQUIRED=NO
      fi
      if [ "$CHANGE_REQUIRED" == "YES" ]; then 
        echo "hdmi_cvt=1280 720 120 3 0 1 0" > /home/pi/tmp/hdmi_def.txt
        echo "hdmi_group=2" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_mode=87" >> /home/pi/tmp/hdmi_def.txt
        echo "hdmi_drive=2" >> /home/pi/tmp/hdmi_def.txt
      fi
  esac
fi


if [ "$CHANGE_REQUIRED" == "YES" ]; then

  ## This section modifies and replaces the end of /boot/config.txt
  ## to allow (only) the correct hdmi config to be loaded at next boot

  ## Set constants for the amendment of /boot/config.txt
  PATHCONFIGS="/home/pi/hdmisource/configs"                ## Path to config files
  lead='^## Begin HDMI Definition'                         ## Marker for start of inserted text
  tail='^## End HDMI Definition'                           ## Marker for end of inserted text
  CHANGEFILE="/boot/config.txt"                            ## File requiring added text
  APPENDFILE=$PATHCONFIGS"/hdmi_mkr.txt"                   ## File containing both markers
  TRANSFILE=/home/pi/tmp/transfer.txt                      ## File used for transfer
  INSERTFILE=/home/pi/tmp/hdmi_def.txt                     ## File which includes new deinition
  rm "$TRANSFILE"  >/dev/null 2>/dev/null                  ## Make sure that the transfer file does not exist

  grep -q "$lead" "$CHANGEFILE"                            ## Is the first marker already present?
  if [ $? -ne 0 ]; then
    sudo bash -c 'cat '$APPENDFILE' >> '$CHANGEFILE' '     ## If not append the markers
  fi

  ## Replace whatever is between the markers with the driver text
    sed -e "/$lead/,/$tail/{ /$lead/{p; r $INSERTFILE
	        }; /$tail/p; d }" $CHANGEFILE >> $TRANSFILE

  sudo cp "$TRANSFILE" "$CHANGEFILE"                       ## Copy from the transfer file
  rm $TRANSFILE                                            ## Delete the transfer file
  rm $INSERTFILE                                           ## Delete the insert file

  # Reboot if not called from menu
  pgrep "menu" >/dev/null 2>/dev/null
  if [ $? != 0 ]; then
    sudo reboot now
  fi
fi
