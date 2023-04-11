![hdmisource build](/images/HDMI_Source_1.jpg)
# BATC HDMI Signal Source for Raspberry Pi 3B 

This software build for a Raspberry Pi 3B enables it to become a very capable HDMI test card generator or camera.  Only 2 external controls are required.  A pushbutton between pins 18 and 20 to select the desired testcard and, if a camera is fitted, a switch between pins 16 and 14 to select the camera.

The current installation method only needs a Windows PC connected to the same (internet-connected) network as a Raspberry Pi 3.  Do not connect a keyboard directly to your Raspberry Pi.  You could connect an HDMI display, but it is not required at this stage.

- First download the 2023-02-21 release of Raspios Bullseye Lite on to your Windows PC from here https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2023-02-22/2023-02-21-raspios-bullseye-armhf-lite.img.xz

- Unzip the image (using 7zip as it is a .xz compressed file) and then transfer it to a Micro-SD Card using Win32diskimager https://sourceforge.net/projects/win32diskimager/

- Before you remove the card from your Windows PC, look at the card with windows explorer; the volume should be labeled "boot".  Create a new empty file called ssh in the top-level (root) directory by right-clicking, selecting New, Text Document, and then change the name to ssh (not ssh.txt).  You should get a window warning about changing the filename extension.  Click OK.  If you do not get this warning, you have created a file called ssh.txt and you need to rename it ssh.  IMPORTANT NOTE: by default, Windows (all versions) hides the .txt extension on the ssh file.  To change this, in Windows Explorer, select File, Options, click the View tab, and then untick "Hide extensions for known file types". Then click OK.

- Create a second file in the boot directory, userconf.txt, with the following text in it:
```sh
pi:$6$B6mdmoSQrTvKkAbL$Ocwu9m3VjPGpZEGe.uJvYNI4w/UcMUYTJjtt327ysNbmPRlnROBCvigF0nRsVFH.QhfsLozLj4OJS8lRT442N0
```
This will create the default user and password.

- Power up the RPi with the new card inserted, and a network connection.  Do not connect a keyboard to the Raspberry Pi. 

- Find the IP address of your Raspberry Pi using an IP Scanner (such as Advanced IP Scanner http://filehippo.com/download_advanced_ip_scanner/ for Windows, or Fing on an iPhone) to get the RPi's IP address.

- From your windows PC use Putty (http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html) to log in to the IP address that you noted earlier.  You will get a Security warning the first time you try; this is normal.

- Log in (user: pi, password: raspberry) then cut and paste the following code in, one line at a time:

```sh
wget https://raw.githubusercontent.com/BritishAmateurTelevisionClub/hdmisource/main/install.sh
chmod +x install.sh
./install.sh
```

The build will request that you enter your callsign and locator, and then finish off in about 15 minutes with no more user input required, so go and make a cup of coffee wait for it to reboot.  When the build is finished the Pi will reboot and show the first testcard on the HDMI output.  

- If your ISP is Virgin Media and you receive an error after entering the wget line: 'GnuTLS: A TLS fatal alert has been received.', it may be that your ISP is blocking access to GitHub.  If (only if) you get this error with Virgin Media, paste the following command in, and press return.
```sh
sudo sed -i 's/^#name_servers.*/name_servers=8.8.8.8/' /etc/resolvconf.conf
```
Then reboot, and try again.  The command asks your RPi to use Google's DNS, not your ISP's DNS.

- If your ISP is BT, you will need to make sure that "BT Web Protect" is disabled so that you are able to download the software.

# Advanced notes

To load the development version, cut and paste in the following lines:

```sh
wget https://raw.githubusercontent.com/davecrump/hdmisource/main/install.sh
chmod +x install.sh
./install.sh -d
```

To load a version from your own GitHub repo (github.com/your_account/vidsource), cut, paste and amend the following lines:
```sh
wget https://raw.githubusercontent.com/your_account/hdmisource/main/install.sh
chmod +x install.sh
./install.sh -u your_account
```
