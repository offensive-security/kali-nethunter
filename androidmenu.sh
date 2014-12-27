#!/bin/bash
# Modified to include menu system
# Kernel Development requires Kali 64bit host

# Configure the build environment
DEBUG=0    # Valid values are 0 or 1, with 1 being enabled
LOCALGIT=0
FROZENKERNEL=0

######### Dependencies #######
# cd ~
# git clone https://github.com/offensive-security/kali-nethunter
# cd kali-nethunter
# sh build-deps.sh
##########  Compiler ###########
# cd ~
# git clone https://github.com/offensive-security/gcc-arm-linux-gnueabihf-4.7.git
# export PATH=${PATH}:/root/gcc-arm-linux-gnueabihf-4.7/bin
######### Local git repos  #######
# When testing multiple images, it is often faster to first checkout git repos and use them locally.
# To do this, you can :
# cd ~/kali-nethunter
#
# - Nexus 10
# git clone https://github.com/binkybear/kernel_samsung_manta.git -b thunderkat
# git clone https://github.com/binkybear/nexus10-5.git -b android-exynos-manta-3.4-lollipop-release
# - Nexus 9
# git clone https://github.com/binkybear/flounder.git -b android-tegra-flounder-3.10-lollipop-release  nexus9-5
# - Nexus 7 (2012)
# git clone https://github.com/binkybear/kangaroo.git -b kangaroo
# git clone https://github.com/binkybear/####################.git -b ########## nexus7_2012-5
# - Nexus 7 (2013)
# git clone https://github.com/binkybear/kernel_msm.git -b android-msm-flo-3.4-kitkat-mr2 flodeb
# git clone https://github.com/binkybear/flo.git -b ElementalX-3.00 nexus7_2013-5
# - Nexus 6
# git clone https://github.com/binkybear/kernel_msm.git -b android-msm-shamu-3.10-lollipop-release nexus6-5
# - Nexus 5
# git clone https://github.com/binkybear/furnace_kernel_lge_hammerhead.git -b android-4.4
# git clone https://github.com/binkybear/kernel_msm.git -b android-msm-hammerhead-3.4-lollipop-release nexus5-5
# - Nexus 4
# git clone https://github.com/binkybear/kernel_msm.git -b android-msm-mako-3.4-kitkat-mr2 mako
# git clone https://github.com/binkybear/####################.git -b ########## nexus4-5
# - OnePlus One
# git clone https://github.com/binkybear/AK-OnePone.git -b cm-11.0-ak oneplus11
# git clone https://github.com/binkybear/AK-OnePone.git -b cm-12.0-ak oneplus12
# - Galaxy S5
# git clone https://github.com/binkybear/KTSGS5.git -b aosp4.4 galaxy_s5
# git clone https://github.com/binkybear/KTSGS5.git -b tw4.4 galaxy_s5_tw
# - Galaxy S4
# git clone https://github.com/binkybear/android_kernel_samsung_jf.git -b cm-11.0 galaxy_s4
# git clone https://github.com/binkybear/android_kernel_samsung_exynos5410.git -b cm-11.0 galaxy_s4_i9500
# - Toolchain
# git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.7
# git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 -b lollipop-release
######## Local Repo ##########
# to update :  for directory in $(ls -l |grep "^d" | awk -F" " '{print $9}');do cd $directory && git pull && cd ..;done
# 0 = use remote git clone | 1 = local copies
######## Frozen Kernels ##########
# Save time from having to build kernels every time set FROZENKERNEL=1.
# This will use premade kernels in devices/frozen_kernels/{VERSION}/{BUILDNAME}

#########  Devices  ##########
# Build scripts for each kernel is located under devices/devicename
source devices/nexus10-manta
source devices/nexus9-volantis #aka flounder
source devices/nexus6-shamu
source devices/nexus7-grouper-tilapia
source devices/nexus7-flo-deb
source devices/nexus5-hammerhead
source devices/nexus4-mako
source devices/one-bacon

######### Set paths and permissions  #######

basepwd=`pwd`
rootfs=`pwd`/rootfs
basedir=`pwd`/android-$VERSION
build_dir=`pwd`/PLACE_ROM_HERE
wwork=`pwd`/PLACE_ROM_HERE/working_rom_folder
wram=`pwd`/PLACE_ROM_HERE/working_ramdisk_folder
bt=`pwd`/utils/boottools
architecture="armhf"

chmod +x utils/boottools/*

######### Build script start  #######

printf '\033[8;33;100t'

d_clear(){
  # Disable the 'clear' statements, if DEBUG mode is enabled
  if [ ${DEBUG} == 1 ]; then
    echo **DEBUG** : Not clearing the screen.
  else
    clear
  fi
}

f_check_version(){
  # Allow user input of version number/folder creation to make set up easier
  echo "Checking for git updates in local folder..."
  for directory in $(ls -l | grep "^d" | awk -F" " '{print $9}');do cd $directory && git pull && cd ..;done
  d_clear
  # need to exit back to basedir to establish root folder
  cd ${basepwd}
  echo ""
        read -p "Create working folder. Enter version number: " VERSION
        export basedir=`pwd`/android-$VERSION
        if [ -d "${basedir}" ]; then
          echo ""
                echo "Working folder / version already exsists, use a different version number?"
                echo ""
                read -p "Do you wish to continue with same version number? (y/n)" CONT
                if [ "$CONT" == "y" ]; then
                  f_interface
                else
                  exit 1
                fi
        else
                mkdir -p ${basedir}
                cd ${basedir}
                f_interface
  fi
}


###Nightly build script version of check version.
f_check_version_noui(){
  # Allow user input of version number/folder creation to make set up easier
  for directory in $(ls -l | grep "^d" | awk -F" " '{print $9}');do cd $directory && git pull && cd ..;done
  cd ${basepwd}
  VERSION=$(date +%m%d%Y)
case $nightlytype in
    rootfs) export basedir=`pwd`/rootfs-$VERSION;;
    kernel) export basedir=`pwd`/kernel-$device-$VERSION;;
esac
  mkdir -p ${basedir}
  cd ${basedir}
}

f_interface(){
d_clear
echo -e "		         \e[1mKALI NETHUNTER BUILDER FOR ANDROID DEVICES\e[0m"
echo ""
echo "	   WORK PATH: ${basedir}"
echo ""
echo -e "\e[31m	[1] Build for Nexus Devices \e[0m"
echo ""
echo -e "\e[31m	[2] Build for Samsung Devices \e[0m"
echo ""
echo -e "\e[31m	[3] Build for OnePlus One Devices \e[0m"
echo ""
if [ -f "${basedir}/flashkernel/kernel/kernel" ] && [ -d "${basedir}/flash" ]; then
echo "	[77] Inject finished rootfs/kernel into ROM"
fi
echo "	[88] Build a rootfs only - Basic kali chroot for any Android Device"
echo "	[99] Unmount and Clean Work Folders (file dir removal currently disabled)"
echo ""
echo "	[q] Exit"
echo ""
echo ""
# wait for character input

read -p "Choice: " menuchoice

case $menuchoice in

1) d_clear; f_interface_nexus ;;
2) d_clear; f_interface_samsung ;;
3) d_clear; f_interface_oneplus ;;
77) d_clear; f_rom_build; f_interface ;;
88) d_clear; f_rootfs ; f_flashzip; f_zip_save; f_interface ;;
99) f_cleanup; f_interface ;;
q) d_clear; exit 1 ;;
*) echo "Incorrect choice..." ;
esac
}

f_interface_nexus(){
d_clear
echo ""
echo -e "\e[31m ---- NEXUS 10 (2012) - MANTA --------------------------------------------------------\e[0m"
echo "  [1] Build for Nexus 10 Kernel with wireless USB support (Android 4.4+)"
echo ""
echo -e "\e[31m ---- NEXUS 7  (2012) - GROUPER/NAKASI -----------------------------------------------\e[0m"
echo "  [2] Build for Nexus 7 (2012) with wireless USB support (Android 4.4+)"
echo ""
echo -e "\e[31m ---- NEXUS 7  (2013) - DEB/FLO ------------------------------------------------------\e[0m"
echo "  [3] Build for Nexus 7 (2013) with wireless USB support (Android 4.4+)"
echo ""
echo -e "\e[31m ---- NEXUS 4  (2012) - MAKO ---------------------------------------------------------\e[0m"
echo "  [4] Build for Nexus 4 with wireless USB support (Android 4.4+)"
echo ""
echo -e "\e[31m ---- NEXUS 5  (2013) - HAMMERHEAD ---------------------------------------------------\e[0m"
echo "  [5] Build for Nexus 5 with wireless USB support (Android 4.4+)"
echo ""
echo -e "\e[31m ---- NEXUS 6  (2014) - SHAMU --------------------------------------------------------\e[0m"
echo "  [6] Build for Nexus 6 with wireless USB support (Android 4.4+)"
echo ""
echo -e "\e[31m ---- NEXUS 9 (2014) - VOLANTIS ------------------------------------------------------\e[0m"
echo "  [7] Build for Nexus 9 with wireless USB support (Android 4.4+)"
echo ""
echo "  [0] Exit to Main Menu"
echo ""
echo ""

read -p "Choice: " nexusmenuchoice

case $nexusmenuchoice in

1) d_clear; f_manta ;;
2) d_clear; f_grouper ;;
3) d_clear; f_deb ;;
4) d_clear; f_mako ;;
5) d_clear; f_hammerhead ;;
6) d_clear; f_shamu ;;
7) d_clear; f_flounder ;;
0) d_clear; f_interface ;;
*) echo "Incorrect choice..." ;
esac
}

f_interface_samsung(){
echo ""
echo -e "\e[31m ---- SAMSUNG GALAXY S5 - G900(F/I/M/T/DEV/W8) ---------------------------------------\e[0m"
echo "  [1] Build for Samsung Glaxy S5 G900 with wireless USB support (Android 4.4+)"
echo ""
echo -e "\e[31m ---- SAMSUNG GALAXY S4 - I9500 ------------------------------------------------------\e[0m"
echo "  [2] Build for Samsung Glaxy S4 with wireless USB support (Android 4.4+)"
echo ""
echo "  [0] Exit to Main Menu"
echo ""
echo ""

read -p "Choice: " samsungmenuchoice

case $samsungmenuchoice in

1) d_clear; f_galaxyS5 ;;
2) d_clear; f_galaxyS4_I9500 ;;
0) d_clear; f_interface ;;
*) echo "Incorrect choice..." ;
esac
}

f_interface_oneplus(){
echo -e "\e[31m ------------------------- OnePlus One --------------------\e[0m"
echo ""
echo "  [1] Build All - Kali rootfs and Kernel (Android 4.4+)"
echo "  [2] Build Kernel Only (Android 4.4+)"
echo "  [3] Build All - Kali rootfs and Kernel (Android 5)"
echo "  [4] Build Kernel Only (Android 5)"
echo "  [0] Exit to Main Menu"
echo ""
echo ""
# wait for character input

read -p "Choice: " grouper_menuchoice

case $grouper_menuchoice in

1) d_clear; f_rootfs ; f_flashzip ; f_oneplus_kernel ; f_zip_save ; f_zip_kernel_save ; f_rom_build ;;
2) d_clear; f_oneplus_kernel ; f_zip_kernel_save ;;
3) d_clear; f_rootfs ; f_flashzip ; f_oneplus_kernel5 ; f_zip_save ; f_zip_kernel_save ; f_rom_build ;;
4) d_clear; f_oneplus_kernel5 ; f_zip_kernel_save ;;
0) d_clear; f_interface ;;
*) echo "Incorrect choice... " ;
esac
}

f_manta(){
echo -e "\e[31m	------------------------- NEXUS 10 -----------------------\e[0m"
echo ""
echo "	[1] Build All - Kali rootfs and Kernel (Android 4.4+)"
echo "	[2] Build Kernel Only (Android 4.4+)"
echo "  [3] Build All - Kali rootfs and Kernel (Android 5)"
echo "  [4] Build Kernel Only (Android 5)"
echo "	[0] Exit to Main Menu"
echo ""
echo ""
# wait for character input

read -p "Choice: " manta_menuchoice

case $manta_menuchoice in

1) d_clear; f_rootfs ; f_flashzip ; f_nexus10_kernel ; f_zip_save ; f_zip_kernel_save ; f_rom_build ;;
2) d_clear; f_nexus10_kernel ; f_zip_kernel_save ;;
3) d_clear; f_rootfs ; f_flashzip ; f_nexus10_kernel5 ; f_zip_save ; f_zip_kernel_save ; f_rom_build ;;
4) d_clear; f_nexus10_kernel5 ; f_zip_kernel_save ;;
0) d_clear; f_interface ;;
*) echo "Incorrect choice..." ;
esac

}

f_flounder(){
echo -e "\e[31m ------------------------- NEXUS 9 -----------------------\e[0m"
echo ""
echo "  [1] Build All - Kali rootfs and Kernel (Android 9)"
echo "  [2] Build Kernel Only (Android 9)"
echo "  [0] Exit to Main Menu"
echo ""
echo ""
# wait for character input

read -p "Choice: " manta_menuchoice

case $manta_menuchoice in

1) d_clear; f_rootfs ; f_flashzip ; f_nexus9_kernel5 ; f_zip_save ; f_zip_kernel_save ; f_rom_build ;;
2) d_clear; f_nexus9_kernel5 ; f_zip_kernel_save ;;
0) d_clear; f_interface ;;
*) echo "Incorrect choice..." ;
esac

}

f_shamu(){
echo -e "\e[31m ------------------------- NEXUS 6 -----------------------\e[0m"
echo ""
echo "  [1] Build All - Kali rootfs and Kernel (Android 5)"
echo "  [2] Build Kernel Only (Android 5)"
echo "  [0] Exit to Main Menu"
echo ""
echo ""
# wait for character input

read -p "Choice: " shamu_menuchoice

case $shamu_menuchoice in

1) d_clear; f_rootfs ; f_flashzip ; f_nexus6_kernel5 ; f_zip_save ; f_zip_kernel_save ; f_rom_build ;;
2) d_clear; f_nexus6_kernel5 ; f_zip_kernel_save ;;
0) d_clear; f_interface ;;
*) echo "Incorrect choice..." ;
esac

}

f_grouper(){
echo -e "\e[31m	------------------------- NEXUS 7 (2012) -----------------------\e[0m"
echo ""
echo "	[1] Build All - Kali rootfs and Kernel (Android 4.4+)"
echo "	[2] Build Kernel Only (Android 4.4+)"
echo "  [3] Build All - Kali rootfs and Kernel (Android 5)"
echo "  [4] Build Kernel Only (Android 5)"
echo "	[0] Exit to Main Menu"
echo ""
echo ""
# wait for character input

read -p "Choice: " grouper_menuchoice

case $grouper_menuchoice in

1) d_clear; f_rootfs ; f_flashzip ; f_nexus7_grouper_kernel ; f_zip_save ; f_zip_kernel_save ; f_rom_build ;;
2) d_clear; f_nexus7_grouper_kernel ; f_zip_kernel_save ;;
3) d_clear; f_rootfs ; f_flashzip ; f_nexus7_grouper_kernel5 ; f_zip_save ; f_zip_kernel_save ; f_rom_build ;;
4) d_clear; f_nexus7_grouper_kernel5 ; f_zip_kernel_save ;;
0) d_clear; f_interface ;;
*) echo "Incorrect choice... " ;
esac

}

f_deb(){
echo -e "\e[31m	------------------------- NEXUS 7 (2013) -----------------------\e[0m"
echo ""
echo "  [1] Build All - Kali rootfs and Kernel (AOSP/STOCK) (Android 4.4+)"
echo "  [2] Build Kernel (AOSP/STOCK) Only"
echo "  [3] Build All - Kali rootfs and Kernel (CyanogenMod) (Android 4.4+)"
echo "  [4] Build Kernel (CyanogenMod) Only"
echo "  [5] Build All - Kali rootfs and Kernel (AOSP/STOCK) (Android 5)"
echo "  [6] Build Kernel (AOSP/STOCK) (Android 5) Only"
echo "  [0] Exit to Main Menu"
echo ""
echo ""
# wait for character input

read -p "Choice: " deb_menuchoice

case $deb_menuchoice in

1) d_clear; f_rootfs ; f_flashzip ; f_deb_stock_kernel ; f_zip_save ; f_zip_kernel_save ; f_rom_build ;;
2) d_clear; f_deb_stock_kernel ; f_zip_kernel_save ;;
3) d_clear; f_rootfs ; f_flashzip ; f_deb_cyanogen_kernel ; f_zip_save ; f_zip_kernel_save ; f_rom_build ;;
4) d_clear; f_deb_cyanogen_kernel ; f_zip_kernel_save ;;
5) d_clear; f_rootfs ; f_flashzip ; f_deb_stock_kernel5 ; f_zip_save ; f_zip_kernel_save ; f_rom_build ;;
6) d_clear; f_deb_stock_kernel5 ; f_zip_kernel_save ;;
0) d_clear; f_interface ;;
*) echo "Incorrect choice... " ;
esac
}

f_hammerhead(){
echo -e "\e[31m -------------------------      NEXUS 5    -----------------------\e[0m"
echo ""
echo "  [1] Build All - Kali rootfs and Kernel (AOSP/STOCK) (Android 4.4+)"
echo "  [2] Build Kernel (AOSP/STOCK) Only"
echo "  [3] Build All - Kali rootfs and Kernel (AOSP/STOCK) (Android 5)"
echo "  [4] Build Kernel (AOSP/STOCK) (Android 5) Only"
echo "  [0] Exit to Main Menu"
echo ""
echo ""
# wait for character input

read -p "Choice: " deb_menuchoice

case $deb_menuchoice in

1) d_clear; f_rootfs ; f_flashzip ; f_hammerhead_stock_kernel ; f_zip_save ; f_zip_kernel_save ; f_rom_build ;;
2) d_clear; f_hammerhead_stock_kernel ; f_zip_kernel_save ;;
3) d_clear; f_rootfs ; f_flashzip ; f_hammerhead_stock_kernel5 ; f_zip_save ; f_zip_kernel_save ; f_rom_build ;;
4) d_clear; f_hammerhead_stock_kernel5 ; f_zip_kernel_save ;;
0) d_clear; f_interface ;;
*) echo "Incorrect choice... " ;
esac
}

f_mako(){
echo -e "\e[31m -------------------------      NEXUS 4    -----------------------\e[0m"
echo ""
echo "  [1] Build All - Kali rootfs and Kernel (AOSP/STOCK) (Android 4.4+)"
echo "  [2] Build Kernel (AOSP/STOCK) Only"
echo "  [3] Build All - Kali rootfs and Kernel (AOSP/STOCK) (Android 5)"
echo "  [4] Build Kernel (AOSP/STOCK) (Android 5) Only"
echo "  [0] Exit to Main Menu"
echo ""
echo ""
# wait for character input

read -p "Choice: " mako_menuchoice

case $mako_menuchoice in

1) d_clear; f_rootfs ; f_flashzip ; f_mako_stock_kernel ; f_zip_save ; f_zip_kernel_save ; f_rom_build ;;
2) d_clear; f_mako_stock_kernel ; f_zip_kernel_save ;;
3) d_clear; f_rootfs ; f_flashzip ; f_mako_stock_kernel5 ; f_zip_save ; f_zip_kernel_save ; f_rom_build ;;
4) d_clear; f_mako_stock_kernel5 ; f_zip_kernel_save ;;
0) d_clear; f_interface ;;
*) echo "Incorrect choice... " ;
esac
}

f_galaxyS5(){
echo -e "\e[31m --------------     SAMSUNG GALAXY S5 ----G900(F/I/M/T/DEV/W8)      ---------\e[0m"
echo ""
echo "  [1] Build All - Kali rootfs and Kernel (AOSP/STOCK) (Android 4.4+)"
echo "  [2] Build All - Kali rootfs and Kernel (TOUCHWIZ) (Android 4.4+)"
echo "  [3] Build Kernel (AOSP/STOCK) Only"
echo "  [4] Build Kernel (TOUCHWIZ) Only"
echo "  [0] Exit to Main Menu"
echo ""
echo ""
# wait for character input

read -p "Choice: " s5_menuchoice

case $s5_menuchoice in

1) d_clear; f_rootfs ; f_flashzip ; f_s5_stock_kernel ; f_zip_save ; f_zip_kernel_save ; f_rom_build ;;
2) d_clear; f_rootfs ; f_flashzip ; f_s5_tw_kernel ; f_zip_save ; f_zip_kernel_save ; f_rom_build ;;
3) d_clear; f_s5_kernel ; f_zip_kernel_save ;;
4) d_clear; f_s5_tw_kernel ; f_zip_kernel_save ;;
0) d_clear; f_interface ;;
*) echo "Incorrect choice... " ;
esac
}

f_galaxyS4_I9500(){
echo -e "\e[31m --------------     SAMSUNG GALAXY S4 ----------GT-I9500    ---------\e[0m"
echo ""
echo "  [1] Build All - Kali rootfs and Kernel (CM + All Qualacom Devices) (Android 4.4+)"
echo "  [2] Build All - Kali rootfs and Kernel (CM + I9500) (Android 4.4+)"
echo "  [3] Build Kernel (CM + Qualacom) Only"
echo "  [4] Build Kernel (CM + I9500) Only"
echo "  [0] Exit to Main Menu"
echo ""
echo ""
# wait for character input

read -p "Choice: " s4_menuchoice

case $s4_menuchoice in

1) d_clear; f_rootfs ; f_flashzip ; f_s4_kernel ; f_zip_save ; f_zip_kernel_save ; f_rom_build ;;
2) d_clear; f_rootfs ; f_flashzip ; f_s4_i9500_kernel ; f_zip_save ; f_zip_kernel_save ; f_rom_build ;;
3) d_clear; f_s4_kernel ; f_zip_kernel_save ;;
4) d_clear; f_s4_i9500_kernel ; f_zip_kernel_save ;;
0) d_clear; f_interface ;;
*) echo "Incorrect choice... " ;
esac
}

f_check_crosscompile(){
# Make sure that the cross compiler can be found in the path before we do
# anything else, that way the builds don't fail half way through.

case $ccc in
  1) export PATH=${PATH}:/root/gcc-arm-linux-gnueabihf-4.7/bin; unset CROSS_COMPILE;;
  *)
    export CROSS_COMPILE=arm-linux-gnueabihf-
    if [ $(compgen -c $CROSS_COMPILE | wc -l) -eq 0 ] ; then
      echo "Missing cross compiler for Android root filesystem."
      echo "Set up PATH according to the README"
      echo ""
      read -p "Enter export path (probable path): " -e -i "export PATH=${PATH}:/root/gcc-arm-linux-gnueabihf-4.7/bin" EXPORT_PATH
      $EXPORT_PATH
      unset CROSS_COMPILE
    else
      echo "Found cross compiler - will continue"
      unset CROSS_COMPILE
    fi;;
esac
}

f_rootfs(){

# Conduct check to see if previous rootfs was built

if [ -d "${rootfs}/kali-$architecture" ]; then
  d_clear
  echo "Detected prebuilt rootfs."
  echo ""
  read -p "Would you like to create a new rootfs? (y/n): " -e -i "n" createrootfs
    if [ "$createrootfs" == "y" ]; then
      echo "Removing previous rootfs"
      rm -rf ${rootfs}/kali-$architecture
      f_rootfs_build
    else
      echo "Continue with current build"
    fi
else
  echo "Previous rootfs build not found. Starting build."
  sleep 5
  f_rootfs_build
fi
}

f_rootfs_noui(){
rm -rf ${rootfs}/kali-armhf
f_rootfs_build
}

f_rootfs_build(){

f_check_crosscompile

# Set working folder to rootfs

cd ${rootfs}

# Package installations for various sections.

arm="abootimg cgpt fake-hwclock ntpdate vboot-utils vboot-kernel-utils uboot-mkimage"
base="kali-menu kali-defaults initramfs-tools usbutils openjdk-7-jre mlocate"
desktop="kali-defaults kali-root-login desktop-base xfce4 xfce4-places-plugin xfce4-goodies"
tools="nmap metasploit tcpdump tshark wireshark burpsuite armitage sqlmap recon-ng wipe socat ettercap-text-only beef-xss set device-pharmer nishang"
wireless="wifite iw aircrack-ng gpsd kismet kismet-plugins giskismet dnsmasq dsniff sslstrip mdk3 mitmproxy"
services="autossh openssh-server tightvncserver apache2 postgresql openvpn php5"
extras="wpasupplicant zip macchanger dbd florence libffi-dev python-setuptools python-pip hostapd ptunnel tcptrace dnsutils p0f mitmf"
mana="python-twisted python-dnspython libnl1 libnl-dev libssl-dev sslsplit python-pcapy tinyproxy isc-dhcp-server rfkill mana-toolkit"
bdf="backdoor-factory bdfproxy"
spiderfoot="python-lxml python-m2crypto python-netaddr python-mako"
sdr="sox librtlsdr"

export packages="${arm} ${base} ${desktop} ${tools} ${wireless} ${services} ${extras} ${mana} ${spiderfoot} ${sdr} ${bdf}"
export architecture="armhf"

# create the rootfs - not much to modify here, except maybe the hostname.
debootstrap --foreign --arch $architecture kali kali-$architecture http://http.kali.org/kali

cp /usr/bin/qemu-arm-static kali-$architecture/usr/bin/

# SECOND STAGE CHROOT

LANG=C chroot kali-$architecture /debootstrap/debootstrap --second-stage

cat << EOF > kali-$architecture/etc/apt/sources.list
deb http://http.kali.org/kali kali main contrib non-free
deb http://security.kali.org/kali-security kali/updates main contrib non-free
EOF

#define hostname

echo "localhost" > kali-$architecture/etc/hostname

# fix for TUN symbolic link to enable programs like openvpn
# set terminal length to 80 because root destroy terminal length
# add fd to enable stdin/stdout/stderr
cat << EOF > kali-$architecture/root/.bash_profile
export TERM=xterm-256color
stty columns 80
# /usr/bin/firstrun # we can remove this with sed at the end of the firstrun script
cd /root/
if [ ! -d "/dev/net/" ]; then
  mkdir -p /dev/net
  ln -sf /dev/tun /dev/net/tun
fi

if [ ! -d "/dev/fd/" ]; then
  ln -sf /proc/self/fd /dev/fd
  ln -sf /dev/fd/0 /dev/stdin
  ln -sf /dev/fd/1 /dev/stdout
  ln -sf /dev/fd/2 /dev/stderr
fi
EOF

cat << EOF > kali-$architecture/etc/hosts
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
EOF

if [ $LOCALGIT == 1 ]; then
	cp /etc/hosts kali-$architecture/etc/
fi

# Copy over helper files to chroot /usr/bin

# Install Local files
cp -rf ${basepwd}/utils/{s,start-*} kali-$architecture/usr/bin/
cp -rf ${basepwd}/utils/hid/* kali-$architecture/usr/bin/
cp -rf ${basepwd}/utils/msf/*.sh kali-$architecture/usr/bin/

cat << EOF > kali-$architecture/etc/network/interfaces
auto lo
iface lo inet loopback
EOF

cat << EOF > kali-$architecture/etc/resolv.conf
#opendns
nameserver 208.67.222.222
nameserver 208.67.220.220
#google dns
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF

# THIRD STAGE CHROOT

export MALLOC_CHECK_=0 # workaround for LP: #520465
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

mount -t proc proc kali-$architecture/proc
mount -o bind /dev/ kali-$architecture/dev/
mount -o bind /dev/pts kali-$architecture/dev/pts

cat << EOF > kali-$architecture/debconf.set
console-common console-data/keymap/policy select Select keymap from full list
console-common console-data/keymap/full select en-latin1-nodeadkeys
EOF

cp ${basepwd}/utils/safe-apt-get kali-$architecture/usr/bin/safe-apt-get

cat << EOF > kali-$architecture/third-stage
#!/bin/bash
dpkg-divert --add --local --divert /usr/sbin/invoke-rc.d.chroot --rename /usr/sbin/invoke-rc.d
cp /bin/true /usr/sbin/invoke-rc.d
echo -e "#!/bin/sh\nexit 101" > /usr/sbin/policy-rc.d
chmod +x /usr/sbin/policy-rc.d

safe-apt-get update
safe-apt-get install locales-all

debconf-set-selections /debconf.set
rm -f /debconf.set
safe-apt-get update
safe-apt-get -y install git-core binutils ca-certificates initramfs-tools uboot-mkimage
safe-apt-get -y install locales console-common less nano git
echo "root:toor" | chpasswd
sed -i -e 's/KERNEL\!=\"eth\*|/KERNEL\!=\"/' /lib/udev/rules.d/75-persistent-net-generator.rules
rm -f /etc/udev/rules.d/70-persistent-net.rules
safe-apt-get --yes --force-yes install $packages

rm -f /usr/sbin/policy-rc.d
rm -f /usr/sbin/invoke-rc.d
dpkg-divert --remove --rename /usr/sbin/invoke-rc.d

rm -f /third-stage
EOF

chmod +x kali-$architecture/third-stage
LANG=C chroot kali-$architecture /third-stage

# Modify kismet configuration to work with gpsd and socat
sed -i 's/\# logprefix=\/some\/path\/to\/logs/logprefix=\/captures\/kismet/g' ${rootfs}/kali-$architecture/etc/kismet/kismet.conf
sed -i 's/# ncsource=wlan0/ncsource=wlan1/g' ${rootfs}/kali-$architecture/etc/kismet/kismet.conf
sed -i 's/gpshost=localhost:2947/gpshost=127.0.0.1:2947/g' ${rootfs}/kali-$architecture/etc/kismet/kismet.conf


# Copy over our kali specific mana config files
cp -rf ${basepwd}/utils/manna/start-mana* ${rootfs}/kali-$architecture/usr/bin/
cp -rf ${basepwd}/utils/manna/stop-mana ${rootfs}/kali-$architecture/usr/bin/
cp -rf ${basepwd}/utils/manna/*.sh ${rootfs}/kali-$architecture/usr/share/mana-toolkit/run-mana/
dos2unix ${rootfs}/kali-$architecture/usr/share/mana-toolkit/run-mana/*
dos2unix ${rootfs}/kali-$architecture/etc/mana-toolkit/*
chmod 755 ${rootfs}/kali-$architecture/usr/share/mana-toolkit/run-mana/*
chmod 755 ${rootfs}/kali-$architecture/usr/bin/*.sh

# Install Rawr (https://bitbucket.org/al14s/rawr/wiki/Usage)
git clone https://bitbucket.org/al14s/rawr.git ${rootfs}/kali-$architecture/opt/rawr
chmod 755 ${rootfs}/kali-$architecture/opt/rawr/install.sh

# Install Dictionary for wifite
mkdir -p ${rootfs}/kali-$architecture/opt/dic
tar xvf ${basepwd}/utils/dic/89.tar.gz -C ${rootfs}/kali-$architecture/opt/dic

# Install Pingen which generates DLINK WPS pins for some routers
wget https://raw.githubusercontent.com/devttys0/wps/master/pingens/dlink/pingen.py -O ${rootfs}/kali-$architecture/usr/bin/pingen
chmod 755 ${rootfs}/kali-$architecture/usr/bin/pingen

# Install Spiderfoot
# Cherrypy is newer in pip then in repo so we need to use that instead.  All other depend are fine.
LANG=C chroot kali-$architecture pip install cherrypy
cd ${rootfs}/kali-$architecture/opt/
wget https://github.com/smicallef/spiderfoot/archive/v2.2.0-final.tar.gz -O spiderfoot.tar.gz
tar xvf spiderfoot.tar.gz && rm spiderfoot.tar.gz && mv spiderfoot-2.2.0-final spiderfoot
cd ${rootfs}

# Modify Kismet log saving folder
sed -i 's/hs/\/captures/g' ${rootfs}/kali-$architecture/etc/kismet/kismet.conf

# Kali Menu (bash script) to quickly launch common Android Programs
cp -rf ${basepwd}/menu/kalimenu ${rootfs}/kali-$architecture/usr/bin/kalimenu
sleep 5

#Installs ADB and fastboot compiled for ARM
git clone git://git.kali.org/packages/google-nexus-tools
cp ./google-nexus-tools/bin/linux-arm-adb ${rootfs}/kali-$architecture/usr/bin/adb
cp ./google-nexus-tools/bin/linux-arm-fastboot ${rootfs}/kali-$architecture/usr/bin/fastboot
rm -rf ./google-nexus-tools
LANG=C chroot kali-$architecture chmod 755 /usr/bin/fastboot
LANG=C chroot kali-$architecture chmod 755 /usr/bin/adb

#Installs deADBolt
curl -o deadbolt https://raw.githubusercontent.com/photonicgeek/deADBolt/master/main.sh
cp ./deadbolt ${rootfs}/kali-$architecture/usr/bin/deadbolt
rm -rf deadbolt
LANG=C chroot kali-$architecture chmod 755 /usr/bin/deadbolt

#Installs APFucker.py
curl -o apfucker.py https://raw.githubusercontent.com/mattoufoutu/scripts/master/AP-Fucker.py
cp ./apfucker.py ${rootfs}/kali-$architecture/usr/bin/apfucker.py
rm -rf deadbolt
LANG=C chroot kali-$architecture chmod 755 /usr/bin/apfucker.py

#Install HID attack script and dictionaries
cp ${basepwd}/flash/system/xbin/hid-keyboard ${rootfs}/kali-$architecture/usr/bin/hid-keyboard
cp ${basepwd}/utils/dic/pinlist.txt ${rootfs}/kali-$architecture/opt/dic/pinlist.txt
cp ${basepwd}/utils/dic/wordlist.txt ${rootfs}/kali-$architecture/opt/dic/wordlist.txt
cp ${basepwd}/utils/hid/hid-dic.sh ${rootfs}/kali-$architecture/usr/bin/hid-dic
LANG=C chroot kali-$architecture chmod 755 /usr/bin/hid-keyboard
LANG=C chroot kali-$architecture chmod 755 /usr/bin/hid-dic

# Set permissions to executable on newly added scripts
LANG=C chroot kali-$architecture chmod 755 /usr/bin/kalimenu

# Sets the default for hostapd.conf but not really needed as evilap will create it's own now
#sed -i 's#^DAEMON_CONF=.*#DAEMON_CONF=/etc/hostapd/hostapd.conf#' kali-$architecture/etc/init.d/hostapd

# DNSMASQ Configuration options for optional access point
cat <<EOF > kali-$architecture/etc/dnsmasq.conf
log-facility=/var/log/dnsmasq.log
#address=/#/10.0.0.1
#address=/google.com/10.0.0.1
interface=wlan1
dhcp-range=10.0.0.10,10.0.0.250,12h
dhcp-option=3,10.0.0.1
dhcp-option=6,10.0.0.1
#no-resolv
log-queries
EOF

# Add missing folders to chroot needed
cap=kali-$architecture/captures
mkdir -p kali-$architecture/root/.ssh/
mkdir -p kali-$architecture/sdcard kali-$architecture/system
mkdir -p $cap/evilap $cap/ettercap $cap/kismet/db $cap/nmap $cap/sslstrip $cap/tshark $cap/wifite $cap/tcpdump $cap/urlsnarf $cap/dsniff $cap/honeyproxy $cap/mana/sslsplit

# In order for metasploit to work daemon,nginx,postgres must all be added to inet
# beef-xss creates user beef-xss. Openvpn server requires nobdy:nobody in order to work
echo "inet:x:3004:postgres,root,beef-xss,daemon,nginx" >> kali-$architecture/etc/group
echo "nobody:x:3004:nobody" >> kali-$architecture/etc/group

if [ ${DEBUG} == 0 ]; then
  # CLEANUP STAGE

  cat << EOF > kali-$architecture/cleanup
  #!/bin/bash
  rm -rf /root/.bash_history
  apt-get update
  apt-get clean
  rm -f /0
  rm -f /hs_err*
  rm -f cleanup
  rm -f /usr/bin/qemu*
EOF

  chmod +x kali-$architecture/cleanup
  LANG=C chroot kali-$architecture /cleanup

  umount ${rootfs}/kali-$architecture/proc/sys/fs/binfmt_misc
  umount ${rootfs}/kali-$architecture/dev/pts
  umount ${rootfs}/kali-$architecture/dev/
  umount ${rootfs}/kali-$architecture/proc

  sleep 5
fi
}

f_flashzip(){
#####################################################
#  Create flashable Android FS.  Git repository holds necessary
#  folders/scripts/files.
#  Flashable zip will need follow structure:
#
#  /busybox/busybox - for mounting data folders for kernel install
#  /data/app/kalilauncher.apk - Launches into root or menu
#  /data/local/kalifs.tar.bz2 - The filesystem
#  /data/local/tmp_kali - shell scripts to unzip filesystem/boot chroot + config files
#  /kernel/kernel - kernel (zImage or zImage-dtb)
#  /META-INF/com/google/android/updater-binary - Binary file for edify script
#  /META-INF/com/google/android/updater-script - Edify script to install Kali
#  /system/bin/bootkali - Launches the Kali chroot
#  /system/bin/killkali - Shutsdown Kali chroot (unmounts and stops services)
#  /system/etc/ - Contains firmware for wireless devices and nano for text editing
#  /system/xbin/nano - Nano binary
#  /system/xbin/busybox - Busybox binary
#####################################################

# Create base flashable zip

cp -rf ${basepwd}/flash ${basedir}/
mkdir -p ${basedir}/flash/data/local/
mkdir -p ${basedir}/flash/system/lib/modules

# Copy configuration files needed by nethunter app (we could also move this folder to flash/sdcard/files)

mkdir -p ${basedir}/flash/sdcard
cp -rf ${basepwd}/utils/files ${basedir}/flash/sdcard

# Download/add Android applications that are useful to our chroot enviornment

# Required: Terminal application is required
wget -P ${basedir}/flash/data/app/ http://jackpal.github.com/Android-Terminal-Emulator/downloads/Term.apk

# Suggested: BlueNMEA to enable GPS logging in Kismet
wget -P ${basedir}/flash/data/app/ http://max.kellermann.name/download/blue-nmea/BlueNMEA-2.1.3.apk
# Suggested: Hackers Keyboard for easier typing in the terminal
wget -P ${basedir}/flash/data/app/ https://hackerskeyboard.googlecode.com/files/hackerskeyboard-v1037.apk
# Suggested: Android VNC Viewer
wget -P ${basedir}/flash/data/app/ https://android-vnc-viewer.googlecode.com/files/androidVNC_build20110327.apk
# Suggested: DriveDroid for CDROM emulation
wget -P ${basedir}/flash/data/app/ http://softwarebakery.com/apps/drivedroid/files/drivedroid-free-0.9.17.apk
# Keyboard HID app
wget -P ${basedir}/flash/data/app/ https://github.com/pelya/android-keyboard-gadget/raw/master/USB-Keyboard.apk
# Suggested: RFAnalyzer
wget -P ${basedir}/flash/data/app/ https://github.com/demantz/RFAnalyzer/raw/master/RFAnalyzer.apk
}

#####################################################
# Zip and save
#####################################################
f_zip_save(){
apt-get install -y zip
d_clear
# Compress filesystem and add to our flashable zip
cd ${rootfs}

# Achtung, ugly hack to clean up chrooted /dev before packaging.
#######################################
rm -rf  kali-$architecture/dev/*
#######################################
echo "Compressing kali rootfs, please wait"
tar jcf kalifs.tar.bz2 kali-$architecture
mv kalifs.tar.bz2 ${basedir}/flash/data/local/

#tar jcvf ${basedir}/flash/data/local/kalifs.tar.bz2 ${basedir}/kali-$architecture
echo "Structure for flashable zip file is complete."
echo "Build a kernel next or select build flashable zip form the main menu."

cd ${basedir}/flash/
zip -r6 update-kali-$VERSION.zip *
mv update-kali-$VERSION.zip ${basedir}
cd ${basedir}
# Generate sha1sum
echo "Generating sha1sum for update-kali$1.zip"
sha1sum update-kali-$VERSION.zip > ${basedir}/update-kali-$VERSION.sha1sum
echo "Flashable Kali zip now located at ${basedir}/update-kali-$VERSION.zip"
echo "Transfer file to device and flash in recovery"
sleep 5
}

f_zip_kernel_save(){
apt-get install -y zip
d_clear
cd ${basedir}/flashkernel/
zip -r6 kernel-kali-$VERSION.zip *
mv kernel-kali-$VERSION.zip ${basedir}
cd ${basedir}
# Generate sha1sum
echo "Generating sha1sum for kernelkali$1.zip"
sha1sum kernel-kali-$VERSION.zip > ${basedir}/kernel-kali-$VERSION.sha1sum
echo "Kernel can be flashed seperatley if needed using kernel-kali-$VERSION.zip"
echo "Transfer file to device and flash in recovery"
sleep 5
}

f_cleanup(){
  if [ ${DEBUG} == 0 ]; then
    # Clean up all the temporary build stuff and remove the directories.
    # This only runs if debug mode is disabled.

    echo "Unmounting any previous mounted folders"
    sleep 3
    d_clear
    umount ${rootfs}/kali-$architecture/proc/sys/fs/binfmt_misc
    umount ${rootfs}/kali-$architecture/dev/pts
    umount ${rootfs}/kali-$architecture/dev/
    umount ${rootfs}/kali-$architecture/proc
    echo "Removing temporary build files"
    rm -rf ${basedir}/patches ${basedir}/kernel ${basedir}/flash ${basedir}/kali-$architecture ${basedir}/flashkernel
  fi
}

##############################################################
# Attempt to build rom from an existing zip file in ROM folder
##############################################################
f_rom_build(){
d_clear

cd ${basepwd}

echo "If you plan to add to ROM please place zip file in:"
echo "${basepwd}/PLACE_ROM_HERE"
echo ""
read -p "Would you like to attach Kali build to ROM? (y/n): " buildrom
if [ "$buildrom" == "n" ]; then
  echo "All done!"
  sleep 3
  f_interface
fi

f_rom_build_menu(){
prompt="Please select a file: "
options=( $(find ${build_dir} -maxdepth 1 -iname '*.zip' | xargs -0) )

PS3="$prompt "
select zipfile in "${options[@]}" "Quit" ; do
    if (( REPLY == 1 + ${#options[@]} )) ; then
        f_interface
    elif (( REPLY > 0 && REPLY <= ${#options[@]} )) ; then
        echo  "$zipfile chosen"
        break
    else
        echo "Invalid option. Try another one."
        f_rom_build_menu
    fi
done
}

f_rom_build_menu

# Remove previous work folders, create necessary folders and unzip rom

cd $build_dir
rm -rf ${wwork} ${wram}
mkdir -p ${wwork} ${wram}
unzip -q $zipfile -d ${wwork}
cp ${wwork}/boot.img ${wram}
cd ${wram}

# Extract Kernel and config file

$bt/umkbootimg boot.img
abootimg -x boot.img bootimg.cfg

# Replace bootsize in bootimg.cfg - our kernel will be larger
sed -i '/bootsize/d' ${wram}/bootimg.cfg

if [ -f "${wram}/initramfs.cpio.gz" ]; then
    echo "Found ramdisk: initramfs.cpio.gz"
    $bt/unpack_ramdisk initramfs.cpio.gz ramdisk
    rm ${wram}/initramfs.cpio.gz
else
  echo "Ramdisk not found!"
  sleep 5
  f_interface
fi

if  ! grep -qr init.d ${wram}/ramdisk/*; then
   echo "" >> ${wram}/ramdisk/init.rc
   echo "service userinit /data/local/bin/busybox run-parts /system/etc/init.d" >> ${wram}/ramdisk/init.rc
   echo "    oneshot" >> ${wram}/ramdisk/init.rc
   echo "    class late_start" >> ${wram}/ramdisk/init.rc
   echo "    user root" >> ${wram}/ramdisk/init.rc
   echo "    group root" >> ${wram}/ramdisk/init.rc
fi

if  ! grep -qr TERMINFO ${wram}/ramdisk/*; then
  echo "    export TERMINFO /system/etc/terminfo"  >> ${wram}/ramdisk/init.environ.rc
  echo "    export TERM linux"  >> ${wram}/ramdisk/init.environ.rc
fi

# Repack ramdisk

cd ${wram}
$bt/repack_ramdisk ramdisk initramfs.cpio.gz
rm -r ${wram}/ramdisk

# Copy kernel from working folder and replace one that came with ROM

rm ${wram}/boot.img ${wram}/zImage
cp ${basedir}/flashkernel/kernel/kernel ${wram}/zImage

# Rebuild kernel with new ramdisk and zImage

echo "Creating boot.img"
#$bt/mkbootimg --kernel zImage --ramdisk initramfs.cpio.gz --cmdline "$(cat bootimg.cfg | grep "cmdline" | cut -c 10-)" -o boot.img
abootimg --create boot.img -f bootimg.cfg -k zImage -r initramfs.cpio.gz
echo "New boot.img created:"
abootimg -i boot.img
sleep 5

# Copy new kernel boot.img back to ROM

echo "Overwriting new boot.img with ROM's boot.img"
cp -rf ${wram}/boot.img ${wwork}/boot.img

# Back to ROM folder to finish up. Copy files normally that go into flashable zip to ROM.

echo "Copying Kali flash files to ROM folder"

cp -rf ${basedir}/flash/system ${wwork}/
cp -rf ${basedir}/flash/sdcard ${wwork}/
cp -rf ${basedir}/flash/data ${wwork}/
cp -rf ${basedir}/flash/kernel ${wwork}/

# Add default updater-script to end of ROM edify script.

echo "Modifying updater-script from ROM"
cat ${basepwd}/flash/META-INF/com/google/android/updater-script >> ${wwork}/META-INF/com/google/android/updater-script

# Zip then transfer back to basedir

cd ${wwork}
echo "Zipping up rom and transfering to ${basedir}/KaliROM-$VERSION.zip "
zip -r6 -q KaliROM-$VERSION.zip *
mv KaliROM-$VERSION.zip ${basedir}

echo "Cleaning up work folders"
rm -rf ${wwork} ${wram}
echo "All done!"
sleep 5

f_interface
}

##############################################################
# Setup of the Kernel folder can be resued on multiple kernels
##############################################################
f_kernel_build_init(){
d_clear

cp -rf ${basepwd}/flash/ ${basedir}/flashkernel
mkdir -p ${basedir}/flashkernel/system/lib/modules
rm -rf ${basedir}/flashkernel/data
rm -rf ${basedir}/flashkernel/sdcard
rm -rf ${basedir}/flashkernel/system/app
#rm -rf ${basedir}/flashkernel/system/bin ${basedir}/flashkernel/system/xbin
rm -rf ${basedir}/flashkernel/META-INF/com/google/android/updater-script
}

##############################################################
# Kernel build so we don't repeat for every different kernel
##############################################################
f_kernel_build(){
echo "Building Kernel"
make -j $(grep -c processor /proc/cpuinfo)

# Detect if module support is enabled in kernel and if so then build/copy.
if grep -q CONFIG_MODULES=y .config
  then
    echo "Building modules"
    mkdir -p modules
    make modules_install INSTALL_MOD_PATH=${basedir}/kernel/modules
    echo "Copying Kernel and modules to flashable kernel folder"
    find modules -name "*.ko" -exec cp -t ../flashkernel/system/lib/modules {} +
  else
    echo "Module support is disabled."
fi

# If this is not just a kernel build by itself it will copy modules and kernel to main flash (rootfs+kernel)
if [ -d "${basedir}/flash/" ]; then
  echo "Detected exsisting /flash folder, copying kernel and modules"
  if [ -f "${basedir}/kernel/arch/arm/boot/zImage-dtb" ]; then
      cp ${basedir}/kernel/arch/arm/boot/zImage-dtb ${basedir}/flash/kernel/kernel
      echo "zImage-dtb found at ${basedir}/kernel/arch/arm/boot/zImage-dtb"
  else
    if [ -f "${basedir}/kernel/arch/arm/boot/zImage" ]; then
        cp ${basedir}/kernel/arch/arm/boot/zImage ${basedir}/flash/kernel/kernel
        echo "zImage found at ${basedir}/kernel/arch/arm/boot/zImage"
    fi
  fi
  cp ${basedir}/flashkernel/system/lib/modules/* ${basedir}/flash/system/lib/modules
  # Kali rootfs (chroot) looks for modules in a different folder then Android (/system/lib) when using modprobe
  rsync -HPavm --include='*.ko' -f 'hide,! */' ${basedir}/kernel/modules/lib/modules ${rootfs}/kali-armhf/lib/
fi

# Copy kernel to flashable package, prefer zImage-dtb. Image.gz-dtb appears to be for 64bit kernels for now
if [ -f "${basedir}/kernel/arch/arm/boot/zImage-dtb" ]; then
  cp ${basedir}/kernel/arch/arm/boot/zImage-dtb ${basedir}/flashkernel/kernel/kernel
  echo "zImage-dtb found at ${basedir}/kernel/arch/arm/boot/zImage-dtb"
else
  if [ -f "${basedir}/kernel/arch/arm/boot/zImage" ]; then
    cp ${basedir}/kernel/arch/arm/boot/zImage ${basedir}/flashkernel/kernel/kernel
    echo "zImage found at ${basedir}/kernel/arch/arm/boot/zImage"
  fi
fi

cd ${basedir}

#Adding Kernel build
# 1. Will check if kernel was added to main flashable zip (one with rootfs).  If yes it will skip.
# 2. If it detects KERNEL_SCRIPT_START it will not add it to flashable zip (rootfs)
# 3. If the updater-script is not found it will assume this is a kernel only build so it will not try to add it

if [ -f "${basedir}/flash/META-INF/com/google/android/updater-script" ]; then
  if grep -Fxq "#KERNEL_SCRIPT_START" "${basedir}/flash/META-INF/com/google/android/updater-script"
  then
    echo "Kernel already added to main updater-script"
  else
    echo "Adding Kernel install to updater-script in main update.zip"
    cat ${basedir}/flashkernel/META-INF/com/google/android/updater-script >> ${basedir}/flash/META-INF/com/google/android/updater-script
  fi
fi
}



########################################################################################################
###Nightly build (NOTE: WILL DELETE EXISTING ROOTFS AND OTHER FILES. It will ALWAYS pull from source)###
########################################################################################################
case $1 in
  rootfs)
    if [ $2 == "" ]; then
      exportdir="~/NetHunter"
    else
      exportdir=$2
    fi
    exportdir=${exportdir%/}
    nightlytype=rootfs
    f_check_version_noui
    d_clear
    ccc=1
    f_rootfs_noui
    f_flashzip
    f_zip_save
    cd ${basedir}
    mkdir -p $exportdir/RootFS
    mv update-kali-$VERSION.zip $exportdir/RootFS/NetHunter-$VERSION.zip
    mv update-kali-$VERSION.sha1sum $exportdir/RootFS/NetHunter-$VERSION.sha1sum
    rm -rf ${basedir}
    exit;;

  ###Photonicgeek: For whatever reason I can't get these kernel scripts to build on my server. It works on ACTUAL Kali though.###
  kernel)
    case $2 in
      flodeb)
        if [ $3 == "" ]; then
          exportdir="~/NetHunter"
        else
          exportdir="$3"
        fi
        exportdir=${exportdir%/}
        nightlytype=kernel
        device=flodeb
        f_check_version_noui
        f_deb_stock_kernel
        f_zip_kernel_save
        cd ${basedir}
        mkdir -p $exportdir/Kernels/Flo
        mkdir -p $exportdir/Kernels/Deb
        cp kernel-kali-$VERSION.zip $exportdir/Kernels/Flo/Kernel-$device-$VERSION.zip
        cp kernel-kali-$VERSION.sha1sum $exportdir/Kernels/Flo/Kernel-$device-$VERSION.sha1sum
        mv kernel-kali-$VERSION.zip $exportdir/Kernels/Deb/Kernel-$device-$VERSION.zip
        mv kernel-kali-$VERSION.sha1sum $exportdir/Kernels/Deb/Kernel-$device-$VERSION.sha1sum
        rm -rf ${basedir}
        exit;;

      groupertilapia)
        if [ $3 == "" ]; then
          exportdir="~/NetHunter"
        else
          exportdir="$3"
        fi
        exportdir=${exportdir%/}
        device=groupertilapia
        f_check_version_noui
        f_nexus7_grouper_kernel
        f_zip_kernel_save
        cd ${basedir}
        mkdir -p $exportdir/Kernels/Grouper
        mkdir -p $exportdir/Kernels/Tilapia
        cp kernel-kali-$VERSION.zip $exportdir/Kernels/Grouper/Kernel-$device-$VERSION.zip
        cp kernel-kali-$VERSION.sha1sum $exportdir/Kernels/Grouper/Kernel-$device-$VERSION.sha1sum
        mv kernel-kali-$VERSION.zip $exportdir/Kernels/Tilapia/Kernel-$device-$VERSION.zip
        mv kernel-kali-$VERSION.sha1sum $exportdir/Kernels/Tilapia/Kernel-$device-$VERSION.sha1sum
        rm -rf ${basedir}
        exit;;

      hammerhead)
        if [ $3 == "" ]; then
          exportdir="~/NetHunter"
        else
          exportdir="$3"
        fi
        exportdir=${exportdir%/}
        nightlytype=kernel
        device=hammerhead
        f_check_version_noui
        f_hammerhead_stock_kernel
        f_zip_kernel_save
        cd ${basedir}
        mkdir -p $exportdir/Kernels/Hammerhead
        mv kernel-kali-$VERSION.zip $exportdir/Kernels/Hammerhead/Kernel-$device-$VERSION.zip
        mv kernel-kali-$VERSION.sha1sum $exportdir/Kernels/Hammerhead/Kernel-$device-$VERSION.sha1sum
        rm -rf ${basedir}
        exit;;

      mako)
        if [ $3 == "" ]; then
          exportdir="~/NetHunter"
        else
          exportdir="$3"
        fi
        exportdir=${exportdir%/}
        nightlytype=kernel
        device=mako
        f_check_version_noui
        f_mako_stock_kernel
        f_zip_kernel_save
        cd ${basedir}
        mkdir -p $exportdir/Kernels/Mako
        mv kernel-kali-$VERSION.zip $exportdir/Kernels/Mako/Kernel-$device-$VERSION.zip
        mv kernel-kali-$VERSION.sha1sum $exportdir/Kernels/Mako/Kernel-$device-$VERSION.zip.sha1sum
        rm -rf ${basedir}
        exit;;

      manta)
        if [ $3 == "" ]; then
          exportdir="~/NetHunter"
        else
          exportdir="$3"
        fi
        exportdir=${exportdir%/}
        nightlytype=kernel
        device=manta
        f_check_version_noui
        f_nexus10_kernel
        f_zip_kernel_save
        cd ${basedir}
        mkdir -p $exportdir/Kernels/Manta
        mv kernel-kali-$VERSION.zip $exportdir/Kernels/Manta/Kernel-$device-$VERSION.zip
        mv kernel-kali-$VERSION.sha1sum $exportdir/Kernels/Manta/Kernel-$device-$VERSION.sha1sum
        rm -rf ${basedir}
        exit;;

      sgs5)
        if [ $3 == "" ]; then
          exportdir="~/NetHunter"
        else
          exportdir="$3"
        fi
        exportdir=${exportdir%/}
        nightlytype=kernel
        device=SGS5-G900
        f_check_version_noui
        f_s5_kernel
        f_zip_kernel_save
        cd ${basedir}
        mkdir -p $exportdir/Kernels/SGS5-I9500
        mv kernel-kali-$VERSION.zip $exportdir/Kernels/SGS5-I9500/Kernel-$device-$VERSION.zip
        mv kernel-kali-$VERSION.sha1sum $exportdir/Kernels/SGS5-I9500/Kernel-$device-$VERSION.sha1sum
        rm -rf ${basedir}
        exit;;

      sgs4)
        if [ $3 == "" ]; then
          exportdir="~/NetHunter"
        else
          exportdir="$3"
        fi
        exportdir=${exportdir%/}
        nightlytype=kernel
        device=SGS4-I9500
        f_check_version_noui
        f_s4_kernel
        f_zip_kernel_save
        cd ${basedir}
        mkdir -p $exportdir/Kernels/SGS4-G900
        mv kernel-kali-$VERSION.zip $exportdir/Kernels/SGS4-G900/Kernel-$device-$VERSION.zip
        mv kernel-kali-$VERSION.sha1sum $exportdir/Kernels/SGS4-G900/Kernel-$device-$VERSION.sha1sum
        rm -rf ${basedir}
        exit;;
      *)
        d_clear
        echo "Please specify a device. use 'androidmenu.sh help' for avaliable options."
    esac;;
  help)
    d_clear
    echo "Usage:"
    echo "androidmenu.sh [Build Type] [Device] [Directory]"
    echo ""
    echo "Build Types:"
    echo "   [rootfs] -----------Builds the root filesystem only"
    echo "   [kernel] -----------Builds Kernel (Device MUST be specified)"
    echo ""
    echo "Devices: (Only applies to kernel build type)"
    echo "   [flodeb] -----------Flo and Deb (Nexus 7 2013)"
    echo "   [groupertilapia] ---Grouper and Tilapia (Nexus 7 2012)"
    echo "   [mako] -------------Mako (Nexus 4)"
    echo "   [manta] ------------Manta (Nexus 10)"
    echo "   [sgs5] -------------Samsung Galaxy S5 (G900)"
    echo "   [sgs4] -------------Samsung Galaxy S4 (I9500)"
    echo ""
    echo "Directory:"
    echo "Where the generated files will be put. Default is ~/NetHunter"

    exit;;
  *) d_clear;;
esac

f_check_version
f_interface
