#!/bin/bash

# This script uses vlc to display the video from the C920.

# set -x

############ Function to Read value with - from Config File ###############

get-config_var() {
lua - "$1" "$2" <<EOF
local key=assert(arg[1])
local fn=assert(arg[2])
local file=assert(io.open(fn))
for line in file:lines() do
local val = line:match("^#?%s*"..key.."=[+-]?(.*)$")
if (val ~= nil) then
print(val)
break
end
end
EOF
}


CONFIGFILE=/boot/hdmisource_config.txt
CAMERA=$(get-config_var camera $CONFIGFILE)
DEBUG=no  # set to yes for diagnostics

if [ "$DEBUG" != "yes" ]; then
  clear
fi

############ IDENTIFY USB VIDEO DEVICES #############################

  WEBCAM_TYPE="None"
  ECCONTRAST=" "


############ Auto Camera selection #########################

  lsusb | grep -q "046d:082d"
  if [ $? == 0 ] && [ "$CAMERA" == "auto" ]; then
    WEBCAM_TYPE="OldC920"
  fi

  if [ "$WEBCAM_TYPE" == "None" ]; then
    lsusb | grep -q "046d:0892"
    if [ $? == 0 ]; then
      WEBCAM_TYPE="OrbicamC920"
    fi
  fi

  if [ "$WEBCAM_TYPE" == "None" ]; then
    lsusb | grep -q "046d:08e5"
    if [ $? == 0 ]; then
      WEBCAM_TYPE="NewerC920"
    fi
  fi

  if [ "$WEBCAM_TYPE" == "None" ]; then
    lsusb | grep -q "046d:0843"
    if [ $? == 0 ]; then
      WEBCAM_TYPE="C930e"
    fi
  fi

  if [ "$WEBCAM_TYPE" == "None" ]; then
    lsusb | grep -q "046d:082b"
    if [ $? == 0 ]; then
      WEBCAM_TYPE="C170"
    fi
  fi

  if [ "$WEBCAM_TYPE" == "None" ]; then
    lsusb | grep -q "046d:0825"
    if [ $? == 0 ]; then
      WEBCAM_TYPE="C270"
    fi
  fi

  if [ "$WEBCAM_TYPE" == "None" ]; then
    lsusb | grep -q "046d:0821"
    if [ $? == 0 ]; then
      WEBCAM_TYPE="C910"
    fi
  fi

  if [ "$WEBCAM_TYPE" == "None" ]; then
    lsusb | grep -q "046d:0823"
    if [ $? == 0 ]; then
      WEBCAM_TYPE="B910"
    fi
  fi

  if [ "$WEBCAM_TYPE" == "None" ]; then
    lsusb | grep -q "046d:0826"
    if [ $? == 0 ]; then
      WEBCAM_TYPE="C525"
    fi
  fi

  if [ "$WEBCAM_TYPE" == "None" ]; then
    lsusb | grep -q "046d:0823"
    if [ $? == 0 ]; then
      WEBCAM_TYPE="C310"
    fi
  fi

  if [ "$WEBCAM_TYPE" == "None" ] && [ "$CAMERA" == "auto" ]; then
    lsusb | grep -q "095d:3001"
    if [ $? == 0 ]; then
      WEBCAM_TYPE="EagleEye"
    fi
  fi

  if [ "$WEBCAM_TYPE" == "None" ] && [ "$CAMERA" == "auto" ]; then
    lsusb | grep -q "1b71:3002"
    if [ $? == 0 ]; then
      WEBCAM_TYPE="USBTV007"
      ECCONTRAST="contrast=380"
    fi
  fi

  if [ "$WEBCAM_TYPE" == "None" ] && [ "$CAMERA" == "auto" ]; then
    lsusb | grep -q "534d:0021"
    if [ $? == 0 ]; then
      WEBCAM_TYPE="MS210x"
      ECCONTRAST="contrast=105"
    fi
  fi

  if [ "$WEBCAM_TYPE" == "None" ] && [ "$CAMERA" == "auto" ]; then
    lsusb | grep -q "Webcam"
    if [ $? == 0 ]; then
      WEBCAM_TYPE="Webcam"
    fi
  fi

  if [ "$WEBCAM_TYPE" == "None" ] && [ "$CAMERA" == "auto" ]; then
    libcamera-hello --list-cameras | grep -q "No cameras available"
    if [ $? != 0 ] && [ "$CAMERA" == "auto" ]; then
      WEBCAM_TYPE="PiCam"
    fi
  fi


################### Manual Camera Selection #######################

  EAGLEEYES=0

  lsusb | grep -q "046d:082d"
  if [ $? == 0 ] && [ "$CAMERA" == "c920" ]; then
    WEBCAM_TYPE="OldC920"
  fi

  if [ "$WEBCAM_TYPE" == "None" ] && [ "$CAMERA" == "eagleeye" ]; then
    lsusb | grep -q "095d:3001"
    if [ $? == 0 ]; then
      WEBCAM_TYPE="EagleEye"
    fi
  fi

  if [ "$WEBCAM_TYPE" == "None" ] && [ "$CAMERA" == "eagleeye2" ]; then
    lsusb | grep -q "095d:3001"
    if [ $? == 0 ]; then
      EAGLEEYES="$(lsusb | grep -c "095d:3001")"
      if [ $EAGLEEYES == 2 ]; then
        WEBCAM_TYPE="EagleEye2"
      fi
    fi
  fi

  if [ "$WEBCAM_TYPE" == "None" ] && [ "$CAMERA" == "easycap" ]; then
    lsusb | grep -q "1b71:3002"
    if [ $? == 0 ]; then
      WEBCAM_TYPE="USBTV007"
      ECCONTRAST="contrast=380"
    fi
  fi

  if [ "$WEBCAM_TYPE" == "None" ] && [ "$CAMERA" == "easycap" ]; then
    lsusb | grep -q "534d:0021"
    if [ $? == 0 ]; then
      WEBCAM_TYPE="MS210x"
      ECCONTRAST="contrast=105"
    fi
  fi

  if [ "$WEBCAM_TYPE" == "None" ]; then
    libcamera-hello --list-cameras | grep -q "No cameras available"
    if [ $? != 0 ] && [ "$CAMERA" == "picam" ]; then
      WEBCAM_TYPE="PiCam"
    fi
  fi

########### Report Camera ##############################################

  if [ "$DEBUG" == "yes" ]; then
    if [ "$WEBCAM_TYPE" == "None" ]; then
      printf "No Webcam identified\n"
    else 
      printf "Found Webcam of type $WEBCAM_TYPE\n"
    fi
  fi

############## Look up USB Parameters ################################ 

# List the video devices, select the 2 lines for the USB device, then
# select the line with the device details and delete the leading tab

if [ "$WEBCAM_TYPE" == "OldC920" ]; then
  VID_USB="$(v4l2-ctl --list-devices 2> /dev/null | \
    sed -n '/C920/,/dev/p' | grep 'dev' | tr -d '\t')"
fi

if [ "$VID_USB" == '' ]; then
  VID_USB="$(v4l2-ctl --list-devices 2> /dev/null | \
    sed -n '/C930e/,/dev/p' | grep 'dev' | tr -d '\t')"
fi
if [ "$WEBCAM_TYPE" == "USBTV007" ]; then
  if [ "$VID_USB" == '' ]; then
    VID_USB="$(v4l2-ctl --list-devices 2> /dev/null | \
      sed -n '/usbtv/,/dev/p' | grep 'dev' | tr -d '\t')"
  fi
fi

if [ "$WEBCAM_TYPE" == "MS210x" ]; then
  if [ "$VID_USB" == '' ]; then
    VID_USB="$(v4l2-ctl --list-devices 2> /dev/null | \
      sed -n '/AV TO USB2.0/,/dev/p' | grep 'dev' | tr -d '\t')"
  fi
fi

if [ "$WEBCAM_TYPE" == "EagleEye" ]; then
  if [ "$VID_USB" == '' ]; then
    VID_USB="$(v4l2-ctl --list-devices 2> /dev/null | \
      sed -n '/EagleEye/,/dev/p' | grep 'dev' | tr -d '\t' \
      | head -n 1)"
  fi
fi

if [ "$WEBCAM_TYPE" == "EagleEye2" ]; then
  if [ "$VID_USB" == '' ]; then
    VID_USB="$(v4l2-ctl --list-devices 2> /dev/null | \
      sed -n '/EagleEye/,/dev/p' | grep 'dev' | tr -d '\t' \
      | tail -n 1)"
  fi
fi

  if [ "$VID_USB" == '' ]; then
    VID_USB="/dev/video0"
    if [ "$DEBUG" == "yes" ]; then
      printf "VID_USB was not found, setting to /dev/video0\n"
    fi
  fi

if [ "$DEBUG" == "yes" ]; then
  printf "The USB device string is $VID_USB\n"
fi

###########################################################################

sudo killall vlc >/dev/null 2>/dev/null
sudo killall libcamera-hello >/dev/null 2>/dev/null

if [ "$WEBCAM_TYPE" == "OldC920" ]; then

  cvlc -I rc --rc-host 127.0.0.1:1111  -f --mmal-display hdmi-1 --no-video-title-show \
    v4l2:///"$VID_USB":width=1920:height=1280:chroma=H264  >/dev/null 2>/dev/null
fi

if [ "$WEBCAM_TYPE" == "EagleEye" ] || [ "$WEBCAM_TYPE" == "EagleEye2" ]; then

  cvlc -I rc --rc-host 127.0.0.1:1111  -f --mmal-display hdmi-1 --no-video-title-show \
     v4l2:///"$VID_USB":width=1920:height=1080:chroma=MJPG:fps=25  >/dev/null 2>/dev/null
fi

if [ "$WEBCAM_TYPE" == "USBTV007" ]; then

  # Set the EasyCap to PAL
  v4l2-ctl -d $VID_USB --set-standard=6

  # Reduce the contrast to prevent crushed whites
  (sleep 0.7; v4l2-ctl -d $VID_USB --set-ctrl $ECCONTRAST >/dev/null 2>/dev/null) &

  cvlc -I rc --rc-host 127.0.0.1:1111  -f --mmal-display hdmi-1 \
    --no-video-title-show --aspect-ratio=16:9 \
    v4l2:///"$VID_USB":width=720:height=576:chroma=I420:fps=25  >/dev/null 2>/dev/null
fi

if [ "$WEBCAM_TYPE" == "MS210x" ]; then

  # Reduce the contrast to prevent crushed whites
  (sleep 0.7; v4l2-ctl -d $VID_USB --set-ctrl $ECCONTRAST >/dev/null 2>/dev/null) &

  cvlc -I rc --rc-host 127.0.0.1:1111  -f --mmal-display hdmi-1 \
    --no-video-title-show --aspect-ratio=16:9 \
    v4l2:///"$VID_USB":width=720:height=576:chroma=I420:fps=25  >/dev/null 2>/dev/null
fi

if [ "$WEBCAM_TYPE" == "PiCam" ]; then

  libcamera-hello --viewfinder-mode 16:1920:1080:P \
    --viewfinder-width 1920 --viewfinder-height 1080 -t 0  >/dev/null 2>/dev/null

fi


