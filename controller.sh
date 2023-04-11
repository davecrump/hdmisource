#!/bin/bash

# The master controller that starts the camera or test card
# and monitors the button and switch

############ Set Environment Variables ###############

CONFIGFILE=/boot/hdmisource_config.txt

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

############ Function to check available cameras ###############

do_check_cameras()
{
  # Check each in turn.  Reset first
  OLDC920_CONNECTED="no"
  EAGLEEYE_CONNECTED="no"
  EAGLEEYE2_CONNECTED="no"
  USBTV007_CONNECTED="no"
  MS210X_CONNECTED="no"

  lsusb | grep -q "046d:082d"
  if [ $? == 0 ] ; then
    OLDC920_CONNECTED="yes"
  fi

  lsusb | grep -q "095d:3001"
  if [ $? == 0 ]; then
    EAGLEEYE_CONNECTED="yes"
    EAGLEEYES="$(lsusb | grep -c "095d:3001")"
    if [ $EAGLEEYES == 2 ]; then
      EAGLEEYE2_CONNECTED="yes"
    fi
  fi

  lsusb | grep -q "1b71:3002"
  if [ $? == 0 ]; then
    USBTV007_CONNECTED="yes"
  fi

  lsusb | grep -q "534d:0021"
  if [ $? == 0 ]; then
    MS210X_CONNECTED="yes"
  fi

  # Now determine the next in sequence

  if [ "$CURRENT_CAMERA" == "none" ] || [ "$CURRENT_CAMERA" == "picam" ]; then
    if [ "$OLDC920_CONNECTED" == "yes" ]; then
      NEXT_CAMERA="c920"
    else
      if [ "$EAGLEEYE_CONNECTED" == "yes" ]; then
        NEXT_CAMERA="eagleeye"
      else
        if [ "$USBTV007_CONNECTED" == "yes" ]; then
          NEXT_CAMERA="easycap"
        else
          if [ "$MS210X_CONNECTED" == "yes" ]; then
            NEXT_CAMERA="easycap"
          else
            NEXT_CAMERA="picam"
          fi
        fi
      fi
    fi
  elif [ "$CURRENT_CAMERA" == "c920" ]; then
    if [ "$EAGLEEYE_CONNECTED" == "yes" ]; then
      NEXT_CAMERA="eagleeye"
    else
      if [ "$USBTV007_CONNECTED" == "yes" ]; then
        NEXT_CAMERA="easycap"
      else
        if [ "$MS210X_CONNECTED" == "yes" ]; then
          NEXT_CAMERA="easycap"
        else
          if [ "$PICAM_CONNECTED" == "yes" ]; then
            NEXT_CAMERA="picam"
          else
            NEXT_CAMERA="c920"
          fi
        fi
      fi
    fi
  elif [ "$CURRENT_CAMERA" == "eagleeye" ]; then
    if [ "$EAGLEEYE2_CONNECTED" == "yes" ]; then
      NEXT_CAMERA="eagleeye2"
    else
      if [ "$USBTV007_CONNECTED" == "yes" ]; then
        NEXT_CAMERA="easycap"
      else
        if [ "$MS210X_CONNECTED" == "yes" ]; then
          NEXT_CAMERA="easycap"
        else
          if [ "$PICAM_CONNECTED" == "yes" ]; then
            NEXT_CAMERA="picam"
          else
            if [ "$OLDC920_CONNECTED" == "yes" ]; then
              NEXT_CAMERA="c920"
            else
              NEXT_CAMERA="eagleeye"
            fi
          fi
        fi
      fi
    fi
  elif [ "$CURRENT_CAMERA" == "eagleeye2" ]; then
    if [ "$USBTV007_CONNECTED" == "yes" ]; then
      NEXT_CAMERA="easycap"
    else
      if [ "$MS210X_CONNECTED" == "yes" ]; then
        NEXT_CAMERA="easycap"
      else
        if [ "$PICAM_CONNECTED" == "yes" ]; then
          NEXT_CAMERA="picam"
        else
          if [ "$OLDC920_CONNECTED" == "yes" ]; then
            NEXT_CAMERA="c920"
          else
            NEXT_CAMERA="eagleeye"
          fi
        fi
      fi
    fi
  elif [ "$CURRENT_CAMERA" == "easycap" ]; then
    if [ "$PICAM_CONNECTED" == "yes" ]; then
      NEXT_CAMERA="picam"
    else
      if [ "$OLDC920_CONNECTED" == "yes" ]; then
        NEXT_CAMERA="c920"
      else
        if [ "$EAGLEEYE_CONNECTED" == "yes" ]; then
          NEXT_CAMERA="eagleeye"
        else
          NEXT_CAMERA="easycap"
        fi
      fi
    fi
  fi
}




################################################################


############ Read Config File ###############

CAM_SWITCH=$(get-config_var cam_switch $CONFIGFILE)
BUTTON=$(get-config_var button $CONFIGFILE)
ACTIVE=$(get-config_var active $CONFIGFILE)
CAMERA=$(get-config_var camera $CONFIGFILE)

CURRENT_CAMERA="none"
NEXT_CAMERA="none"
FIRST_CAMERA="yes"

clear                                                 # Clear the screen

sudo systemctl start pigpiod >/dev/null 2>/dev/null   # Start the GPIO Deamon

sleep 1                                               # Wait for the deamon to start

#CAM_SWITCH=24                         # Physical pin 16  3v3 pull-up.  Ground for camera
#BUTTON=23                             # Physical pin 18  3v3 pull-up.  Ground for next or shutdown

pigs m $CAM_SWITCH r                  # set the Camera switch GPIO to read mode
pigs m $BUTTON r                      # set the Button GPIO to read mode
pigs m $ACTIVE w                      # set the Active LED GPIO to write mode

pigs pud $CAM_SWITCH u                # Enable the pull-up on the camera switch GPIO
pigs pud $BUTTON u                    # Enable the pull-up on the button GPIO
pigs w $ACTIVE 1                      # set the Active LED GPIO high

# Check if picam is connected at boot
libcamera-hello --list-cameras | grep -q "No cameras available"
if [ $? != 0 ] ; then
  PICAM_CONNECTED="yes"
fi

while true; do                        # Main loop

  CAM_SWITCH_POS=$(pigs r $CAM_SWITCH)
  if [[ $CAM_SWITCH_POS -eq 0 ]]; then              # Camera selected
    
    if [ "$FIRST_CAMERA" == "yes" ]; then
      /home/pi/hdmisource/camera.sh &                 # Run as normal
    else
      eval "/home/pi/hdmisource/camera.sh $CURRENT_CAMERA &"  # Start last used camera
    fi
    sleep 0.1s
    SHUTDOWN_COUNT=0                                # Now monitor for shutdown or other change request
    while [[ $CAM_SWITCH_POS -eq 0 ]]  && (! test -f /home/pi/tmp/camera_change); do           # Exit if camera is deselected

      CAM_SWITCH_POS=$(pigs r $CAM_SWITCH)          # Check camera switch
      BUTTON_POS=$(pigs r $BUTTON)                  # Check Button

      if [[ $BUTTON_POS -eq 0 ]]; then
        let SHUTDOWN_COUNT=$SHUTDOWN_COUNT+1       # Count the number of 100ms loops the button has been pressed for
      else
        SHUTDOWN_COUNT=0
      fi

      if [[ $SHUTDOWN_COUNT -eq 1 ]] && [ "$CAMERA" == "auto" ]; then          # only change camera once
        echo shutdown | nc 127.0.0.1 1111 >/dev/null 2>/dev/null
        sudo killall libcamera-hello >/dev/null 2>/dev/null
        do_check_cameras
        eval "/home/pi/hdmisource/camera.sh $NEXT_CAMERA &"  # Start camera
        CURRENT_CAMERA=$NEXT_CAMERA
        FIRST_CAMERA="no"
      fi

      if [ $SHUTDOWN_COUNT -gt 19 ]; then           # 2 second press, so

        echo shutdown | nc 127.0.0.1 1111 >/dev/null 2>/dev/null
        sudo killall libcamera-hello >/dev/null 2>/dev/null

        # echo ShutDown                             # display splash
        sudo fbi -T 1 -noverbose -a /home/pi/hdmisource/images/shutdown_caption.jpg >/dev/null 2>/dev/null
        pigs w $ACTIVE 0                            # set the Active LED GPIO low
        sudo systemctl stop pigpiod &               # Prevent occasional shutdown hang
        sleep 2
        sudo shutdown now                           # and shutdown
        exit
      fi
      sleep 0.1s

    done                                            # End of camera switch "ON" monitoring loop

    rm /home/pi/tmp/camera_change >/dev/null 2>/dev/null
    echo shutdown | nc 127.0.0.1 1111 >/dev/null 2>/dev/null
    sudo killall libcamera-hello >/dev/null 2>/dev/null

  fi                                                # End of if camera selected

  if [[ $CAM_SWITCH_POS -eq 1 ]]; then              # Test Card selected

    /home/pi/hdmisource/test_card.sh &              # Display Test Card
    sleep 0.1s

    SHUTDOWN_COUNT=0                                # Now monitor for shutdown or other change request
    while [[ $CAM_SWITCH_POS -eq 1 ]]; do           # Exit if Test Card is deselected

      CAM_SWITCH_POS=$(pigs r $CAM_SWITCH)          # Check camera switch
      BUTTON_POS=$(pigs r $BUTTON)                  # Check Button

      if [ $BUTTON_POS = 0 ]; then
        let SHUTDOWN_COUNT=$SHUTDOWN_COUNT+1       # Count the number of 100ms loops the button has been pressed for
      else
        SHUTDOWN_COUNT=0
      fi

      if [ $SHUTDOWN_COUNT -gt 19 ]; then           # 2 second press, so
        # echo ShutDown                             # display splash
        sudo fbi -T 1 -noverbose -a /home/pi/hdmisource/images/shutdown_caption.jpg >/dev/null 2>/dev/null
        pigs w $ACTIVE 0                            # set the Active LED GPIO low
        sudo systemctl stop pigpiod &               # Prevent occasional shutdown hang
        sleep 2
        sudo shutdown now                           # and shutdown
        exit
      fi
      sleep 0.1s

    done                                            # End of camera switch "OFF" monitoring loop
    (sleep 2; sudo killall fbi >/dev/null 2>/dev/null) &                   # kill fbi after delay for camera to start

  fi                                                # End of if Test Card selected

  sudo killall test_card.sh >/dev/null 2>/dev/null  # make sure that we don't get multiple test cards running

done                                                # End of Main Loop
