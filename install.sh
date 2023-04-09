#!/bin/bash

# HDMI Source for Raspberry Pi 3
# Orignal design by Brian, G4EWJ
# Updated for HDMi and packaged for release by Dave, G8GKQ

whoami | grep -q pi
if [ $? != 0 ]; then
  echo "Install must be performed as user pi"
  exit
fi

# Check which source needs to be loaded
GIT_SRC="BritishAmateurTelevisionClub"
GIT_SRC_FILE=".hdmisource_gitsrc"

if [ "$1" == "-d" ]; then
  GIT_SRC="davecrump";
  echo
  echo "--------------------------------------------------------"
  echo "----- Installing development version of HDMISource -----"
  echo "--------------------------------------------------------"
elif [ "$1" == "-u" -a ! -z "$2" ]; then
  GIT_SRC="$2"
  echo
  echo "WARNING: Installing ${GIT_SRC} development version, press enter to continue or 'q' to quit."
  read -n1 -r -s key;
  if [[ $key == q ]]; then
    exit 1;
  fi
  echo "ok!";
else
  echo
  echo "--------------------------------------------------------------"
  echo "----- Installing BATC Production Portsdown of HDMISource -----"
  echo "--------------------------------------------------------------"
fi

sudo mkdir /boot/testcard
echo
echo "---------------------------"
echo "----- Personalisation -----"
echo "---------------------------"

echo
echo "Please enter your callsign and press enter (it can be changed later)"
read CALL
echo and please enter the locator for $CALL and press enter
read LOCATOR

sudo sh -c "echo $CALL > /boot/testcard/callsign.txt"
sudo sh -c "echo $LOCATOR > /boot/testcard/locator.txt"
sudo sh -c "echo 0000 > /boot/testcard/numbers.txt"

echo
echo Call set to $CALL and locator set to $LOCATOR
echo "these can be changed by editing the files in /boot/testcard/"
echo
echo "The install will now continue without needing any user input"
echo "and reboot when it is finished."

# Update the package manager
echo
echo "------------------------------------"
echo "----- Updating Package Manager -----"
echo "------------------------------------"
sudo dpkg --configure -a
sudo apt-get update --allow-releaseinfo-change

# Uninstall the apt-listchanges package to allow silent install of ca certificates (201704030)
# http://unix.stackexchange.com/questions/124468/how-do-i-resolve-an-apparent-hanging-update-process
sudo apt-get -y remove apt-listchanges

# Upgrade the distribution
echo
echo "-----------------------------------"
echo "----- Performing dist-upgrade -----"
echo "-----------------------------------"
sudo apt-get -y dist-upgrade


# Install the packages that we need
echo
echo "-------------------------------"
echo "----- Installing Packages -----"
echo "-------------------------------"
#
#sudo apt-get -y install cmake libusb-1.0-0-dev libx11-dev buffer libjpeg-dev indent
#sudo apt-get -y install ttf-dejavu-core bc libfftw3-dev libvncserver-dev
#sudo apt-get -y install netcat

sudo apt-get -y install git                   # For build
sudo apt-get -y install vlc                   # For displaying cameras
sudo apt-get -y install fbi                   # for displaying images
sudo apt-get -y install imagemagick           # for adding captions to images
sudo apt-get -y install usbmount              # for easy USB stick usage
sudo apt-get -y install pigpio                # to read the buttons and switches
sudo apt-get -y install libdrm-tests          # To check HDMI current mode - not working
sudo apt-get -y install edid-decode           # To display connected display EDID


echo
echo "--------------------------------"
echo "----- Setting up Autostart -----"
echo "--------------------------------"

# Set auto login to command line
sudo raspi-config nonint do_boot_behaviour B2

# Modify .bashrc to run startup script on ssh logon
echo if test -z \"\$SSH_CLIENT\" >> ~/.bashrc 
echo then >> ~/.bashrc
echo "  source /home/pi/hdmisource/on_start.sh" >> ~/.bashrc
echo fi >> ~/.bashrc

# Amend /etc/fstab to create a tmpfs drive at ~/tmp for temporary use
sudo sed -i '4itmpfs           /home/pi/tmp    tmpfs   defaults,noatime,nosuid,size=10m  0  0' /etc/fstab

# Download the previously selected version of hdmisource
echo
echo "-------------------------------------------"
echo "----- Downloading HDMISource Software -----"
echo "-------------------------------------------"
wget https://github.com/${GIT_SRC}/hdmisource/archive/main.zip

# Unzip the HDMISource software and copy to the Pi
unzip -o main.zip
mv hdmisource-main hdmisource
rm main.zip
cd /home/pi


# Enable camera
echo
echo "--------------------------------------------------"
echo "---- Enabling the Pi Cam in /boot/config.txt -----"
echo "--------------------------------------------------"
sudo bash -c 'echo -e "\n##Enable Pi Camera" >> /boot/config.txt'
sudo bash -c 'echo -e "\ngpu_mem=128\nstart_x=1\n" >> /boot/config.txt'

# DON'T set the framebuffer to 32 bit depth by disabling dtoverlay=vc4-fkms-v3d
#echo
#echo "----------------------------------------------"
#echo "---- Setting Framebuffer to 32 bit depth -----"
#echo "----------------------------------------------"

#sudo sed -i "/^dtoverlay=vc4-fkms-v3d/c\#dtoverlay=vc4-fkms-v3d" /boot/config.txt

# Reduce the dhcp client timeout to speed off-network startup (201704160)
sudo bash -c 'echo -e "\n# Shorten dhcpcd timeout from 30 to 5 secs" >> /etc/dhcpcd.conf'
sudo bash -c 'echo -e "\ntimeout 5\n" >> /etc/dhcpcd.conf'

# Copy the default config file to the /boot folder
sudo cp /home/pi/hdmisource/hdmisource_config.txt.factory /boot/hdmisource_config.txt

# Add the hdmi definition markers to the /boot/config file
sudo bash -c 'cat /home/pi/hdmisource/configs/hdmi_mkr.txt >> /boot/config.txt'

# Add the audio definition markers to the /boot/config file
sudo bash -c 'cat /home/pi/hdmisource/configs/audio_mkr.txt >> /boot/config.txt'

# Save git source used
echo "${GIT_SRC}" > /home/pi/${GIT_SRC_FILE}

# Add aliases to kill the test card generator after boot or to start it
echo "alias stop='/home/pi/hdmisource/stop.sh'" >> /home/pi/.bash_aliases
echo "alias start='/home/pi/hdmisource/on_start.sh'" >> /home/pi/.bash_aliases
echo "alias menu='/home/pi/hdmisource/menu.sh'" >> /home/pi/.bash_aliases

echo
echo "SD Card Serial:"
cat /sys/block/mmcblk0/device/cid

# Reboot
echo
echo "--------------------------------"
echo "----- Complete.  Rebooting -----"
echo "--------------------------------"
sleep 1
echo
echo "------------------------------------------------------"
echo "----- The HDMI output should be active on reboot -----"
echo "------------------------------------------------------"

sudo reboot now
exit



