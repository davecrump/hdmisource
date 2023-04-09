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

############ Read Config File ###############

CAM_SWITCH=$(get-config_var cam_switch $CONFIGFILE)
BUTTON=$(get-config_var button $CONFIGFILE)
ACTIVE=$(get-config_var active $CONFIGFILE)


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


while true; do                        # Main loop

  CAM_SWITCH_POS=$(pigs r $CAM_SWITCH)
  if [[ $CAM_SWITCH_POS -eq 0 ]]; then              # Camera selected
    /home/pi/hdmisource/camera.sh &                 # Start camera
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
    (sleep 2; sudo killall fbi) &                   # kill fbi after delay for camera to start

  fi                                                # End of if Test Card selected

done                                                # End of Main Loop
