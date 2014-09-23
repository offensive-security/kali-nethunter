# Kali on Android Installer
============

## Installation Instructions:

```
mkdir ~/arm-stuff
cd ~/arm-stuff
git clone https://github.com/offensive-security/gcc-arm-linux-gnueabihf-4.7
export PATH=${PATH}:/root/arm-stuff/gcc-arm-linux-gnueabihf-4.7/bin
git clone https://github.com/binkybear/kali-scripts
cd ~/arm-stuff/kali-scripts
./build-deps.sh
./androidmenu.sh
```
## Local Repo Instructions:

You can save time by downloading the repos you plan on working with first so that they don't have to be downloaded each time your run a build.  Here are all the current local repos:

```
cd ~/arm-stuff/kali-scripts
git clone https://github.com/sensepost/mana.git
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
