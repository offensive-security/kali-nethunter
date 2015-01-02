# Kali Linux NetHunter for Nexus & OnePlus Devices
==================================================
Kali Linux NetHunter is a Android penetration testing platform for Nexus and OnePlus devices built on top of Kali Linux, which includes some special and unique features. Of course, you have all the usual Kali tools in NetHunter as well as the ability to get a full VNC session from your phone to a graphical Kali chroot, however the strength of NetHunter does not end there. 
We've incorporated some amazing features into the NetHunter OS which are both powerful and unique. From pre-programmed HID Keyboard (Teensy) attacks, to BadUSB Man In The Middle attacks, to one-click MANA Evil Access Point setups. And yes, NetHunter natively supports wireless 802.11 frame injection with a variety of supported USB NICs. NetHunter is still in its infancy and we are looking forward to seeing this project and community grow.

## Installation Instructions
Installation instructions and image downloads can be found at [nethunter.com](http://nethunter.com).

## Building from sources
You can also rebuild the NetHunter images from scratch, which allows for easier image modification. For best results use a 64 bit Kali Linux development environment with over 10Gb free disk space and enter the following commands:

```
mkdir ~/arm-stuff
cd ~/arm-stuff
git clone https://github.com/offensive-security/gcc-arm-linux-gnueabihf-4.7
export PATH=${PATH}:/root/arm-stuff/gcc-arm-linux-gnueabihf-4.7/bin
git clone https://github.com/offensive-security/kali-nethunter
cd ~/arm-stuff/kali-nethunter
./build-deps.sh
./androidmenu.sh
```
## Local Repo Instructions:

You can save time by downloading the repos you plan on working with first so that they don't have to be downloaded each time your run a build.  Here are all the current local repos:

```
cd ~/arm-stuff/kali-nethunter
git clone https://github.com/binkybear/kernel_samsung_manta.git -b thunderkat
git clone https://github.com/binkybear/kangaroo.git -b kangaroo
git clone https://github.com/binkybear/kernel_msm.git -b android-msm-flo-3.4-kitkat-mr2 flodeb
git clone https://github.com/binkybear/flo.git -b Cyanogenmod cyanflodeb
git clone https://github.com/binkybear/furnace_kernel_lge_hammerhead.git -b android-4.4
git clone https://github.com/binkybear/furnace_kernel_caf_hammerhead.git -b cm-11.0
git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.7
```

If you plan on only building for one device then you only need the kernel you plan on building for.  After that you need to edit androidmenu.sh and change LOCALGIT to 1:

```
LOCALGIT=1
```

If you do not need to recompile the kernel and want to save some build time, change the FROZENKERNEL variable to 1.

```
FROZENKERNEL=1
```
