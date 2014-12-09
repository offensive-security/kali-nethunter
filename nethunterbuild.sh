#!/bin/bash
set -e

### Verifies input from user
f_check(){
  # First checks to see if host machine is running 64 bit Kali
  hostarch=`uname -m`
  if [ $hostarch == "Darwin" ]; then
    echo "OS X isn't supported"
    exit
  else
    testkali=$(cat /etc/*-release | grep "ID=kali")
  fi
  if [[ $testkali == "ID=kali"* && ( $hostarch == "x86_64" || $hostarch == "amd64" ) ]]; then
    echo "64 bit Kali Linux detected"
  else
    echo "This utility is only compatible with 64 bit Kali Linux."
    exit
  fi

  # Checks to see if input matches script's abilities
  # If nothing is selectd, display error and exit immediately
  if [[ $buildtype == "" ]]&&[[ $targetver == "" ]]&&[[ $selecteddevice == "" ]]; then
    echo "You must specify arguments in order for the script to work."
    echo "Use the flag -help or -h to see what arguments are needed."
    exit
  fi
  # If build type is blank, display error and set $error var to 1
  if [[ $buildtype == "" ]]; then
    echo "The build cannot continue because a build type was not specified."
    error=1
  fi
  # If Kernel build is selected, but no device specified, display error and set $error var to 1
  if [[ $selecteddevice == "" ]]&&[[ $buildtype == "kernel" ]]; then
    echo "The build cannot continue because a device was not specified."
    error=1
  fi
  # If Kernel build is selected but no android version selected, display error and set $error var to 1
  if [[ $targetver == "" ]]&&[[ $buildtype == "kernel" ]]; then
    echo "The build cannot continue because an Android version was not specified."
    error=1
  fi
  # If Lollipop kernel is selected for an unsupported device, display error and set $error var to 1
  if [[ $buildtype == "kernel" ]]&&[[ $targetver == "lollipop" ]]; then
    if [[ $selecteddevice == "manta" ]]||[[ $selecteddevice == "groupertilapia" ]]||[[ $selecteddevice == "mako" ]]||[[ $selecteddevice == "gs5" ]]||[[ $selecteddevice == "gs4" ]]||[[ $selecteddevice == "bacon" ]]; then
      echo "Lollipop isn't currently supported by your device."
      error=1
    fi
  fi
  # If KitKat kernel is selected for an unsupported device, display error and set $error var to 1
  if [[ $buildtype == "kernel" ]]&&[[ $targetver == "kitkat" ]]; then
    if [[ $selecteddevice == "shamu" ]]||[[ $selecteddevice == "flounder" ]]; then
      echo "KitKat isn't supported by your device."
      error=1
    fi
  fi
  # If the device isn't currently supported, display error and set $error var to 1
  if [[ $selecteddevice == "gs4" ]]; then
    echo "$selecteddevice isn't currently supported."
    error=1
  fi

  # Displays the errors above and exits
  if [[ $error == 1 ]]; then
    exit
  fi
}

### Creates directories and sets things up
f_setup(){
  ### Set window size
  printf '\033[8;40;90t'

  ######### Set paths and permissions  #######
  export basepwd=~/NetHunter
  export rootfs=$basepwd/rootfs
  export bt=$basepwd/utils/boottools
  export architecture="armhf"

  ### Tests if kali-nethunter build directory exists
  if [ -d $basepwd ]; then
    cd $basepwd
  else
    ### Make Directories and Prepare to build
    mkdir -p $basepwd
    cd $basepwd
    git clone -b development https://github.com/offensive-security/kali-nethunter $basepwd
    cd $basepwd
    ### Build Dependencies for script
    apt-get install -y git-core gnupg flex bison gperf libesd0-dev build-essential \
    zip curl libncurses5-dev zlib1g-dev libncurses5-dev gcc-multilib g++-multilib \
    parted kpartx debootstrap pixz qemu-user-static abootimg cgpt vboot-kernel-utils \
    vboot-utils uboot-mkimage bc lzma lzop automake autoconf m4 dosfstools pixz rsync \
    schedtool git dosfstools e2fsprogs device-tree-compiler ccache dos2unix
    MACHINE_TYPE=`uname -m`
    if [ ${MACHINE_TYPE} == 'x86_64' ]; then
      dpkg --add-architecture i386
      apt-get update
      apt-get install -y ia32-libs
      # Required for kernel cross compiles
      apt-get install -y libncurses5:i386
    else
      apt-get install -y libncurses5
    fi
    if [ ! -e "/usr/bin/lz4c" ]; then
      echo "Missing lz4c which is needed to build certain kernels.  Downloading and making for system:"
      cd $basepwd
      wget http://lz4.googlecode.com/files/lz4-r112.tar.gz
      tar -xf lz4-r112.tar.gz
      cd lz4-r112
      make
      make install
      echo "lz4c now installed.  Removing leftover files."
      cd ..
      rm -rf lz4-r112.tar.gz lz4-r112
    fi
  fi

  # Allow user input of version number/folder creation to make set up easier
  cd $basepwd
  for directory in $(ls -l |grep ^d|awk -F" " '{print $9}');do cd $directory && git pull && cd ..;done
  cd $basepwd
  builddate=$(date +%m%d%Y)
  case $buildtype in
    rootfs) export basedir=$basepwd/rootfs-$builddate;;
    kernel) export basedir=$basepwd/kernel-$selecteddevice-$builddate;;
  esac
  if [ -d "${basedir}" ]; then
    rm -rf ${basedir}
  fi
  mkdir -p ${basedir}

  chmod +x $bt/*

  case $keepfiles in
    1) echo "Keep Existing files";;
    *)
      if [[ $buildtype == "rootfs" ]]||[[ $buildtype == "all" ]]; then
        rm -rf $basepwd/rootfs/*
        rm -rf $basepwd/toolchains/gcc-arm-linux-gnueabihf-4.7
      fi
      if [[ $selecteddevice == "flodeb" ]]; then
        rm -rf ${basepwd}/devices/kernels/flodeb-4
        rm -rf ${basepwd}/devices/kernels/flodeb-5
        rm -rf ${basepwd}/toolchains/toolchain32
      fi
      if [[ $selecteddevice == "flounder" ]]; then
        rm -rf ${basepwd}/devices/kernels/flounder-5
        rm -rf ${basepwd}/toolchains/toolchain64s
      fi
      if [[ $selecteddevice == "groupertilapia" ]]; then
        rm -rf ${basepwd}/devices/kernels/groupertilapia-4
        rm -rf ${basepwd}/toolchains/toolchain32
      fi
      if [[ $selecteddevice == "hammerhead" ]]; then
        rm -rf ${basepwd}/devices/kernels/hammerhead-4
        rm -rf ${basepwd}/devices/kernels/hammerhead-5
        rm -rf ${basepwd}/toolchains/toolchain32
      fi
      if [[ $selecteddevice == "mako" ]]; then
        rm -rf ${basepwd}/devices/kernels/mako-4
        rm -rf ${basepwd}/toolchains/toolchain32
      fi
      if [[ $selecteddevice == "manta" ]]; then
        rm -rf ${basepwd}/devices/kernels/manta-4
        rm -rf ${basepwd}/devices/kernels/manta-5
        rm -rf ${basepwd}/toolchains/toolchain32
      fi
      if [[ $selecteddevice == "shamu" ]]; then
        rm -rf ${basepwd}/devices/kernels/shamu-5
        rm -rf ${basepwd}/toolchains/toolchain32
      fi
      if [[ $selecteddevice == "bacon" ]]; then
        rm -rf ${basepwd}/devices/kernels/oneplus11
        rm -rf ${basepwd}/devices/kernels/oneplus12
        rm -rf ${basepwd}/toolchains/toolchain32
      fi;;
  esac

  #########  Devices  ##########
  # Build scripts for each kernel is located under devices/devicename
  source $basepwd/devices/manta.sh
  source $basepwd/devices/flounder.sh
  source $basepwd/devices/shamu.sh
  source $basepwd/devices/grouper-tilapia.sh
  source $basepwd/devices/flo-deb.sh
  source $basepwd/devices/hammerhead.sh
  source $basepwd/devices/mako.sh
  source $basepwd/devices/bacon.sh
  cd ${basedir}
}

### processes input and runs the proper functions
f_build(){
  case $buildtype in
    rootfs) f_rootfs; f_movefiles;;
    *) sleep 0;;
  esac

  case $selecteddevice in
    manta)
    case $buildtype in
      kernel)
      case $targetver in
        lollipop) f_nexus10_kernel5; f_zip_kernel_save;;
        kitkat) f_nexus10_kernel; f_zip_kernel_save;;
      esac;;
      all)
      case $targetver in
        lollipop) f_rootfs; f_nexus10_kernel5; f_zip_kernel_save;;
        kitkat) f_rootfs; f_nexus10_kernel; f_zip_kernel_save;;
      esac;;
    esac;;
    groupertilapia)
    case $buildtype in
      kernel)
      case $targetver in
        lollipop) f_nexus7_grouper_kernel5; f_zip_kernel_save;;
        kitkat) f_nexus7_grouper_kernel; f_zip_kernel_save;;
      esac;;
      all)
      case $targetver in
        lollipop) f_rootfs; f_nexus7_grouper_kernel5; f_zip_kernel_save;;
        kitkat) f_rootfs; f_nexus7_grouper_kernel; f_zip_kernel_save;;
      esac;;
    esac;;
    flodeb)
    case $buildtype in
      kernel)
      case $targetver in
        lollipop) f_deb_stock_kernel5; f_zip_kernel_save;;
        kitkat) f_deb_stock_kernel; f_zip_kernel_save;;
      esac;;
      all)
      case $targetver in
        lollipop) f_rootfs; f_deb_stock_kernel5; f_zip_kernel_save;;
        kitkat) f_rootfs; f_deb_stock_kernel; f_zip_kernel_save;;
      esac;;
    esac;;
    mako)
    case $buildtype in
      kernel)
      case $targetver in
        lollipop) f_mako_stock_kernel5; f_zip_kernel_save;;
        kitkat) f_mako_stock_kernel; f_zip_kernel_save;;
      esac;;
      all)
      case $targetver in
        lollipop) f_rootfs; f_mako_stock_kernel5; f_zip_kernel_save;;
        kitkat) f_rootfs; f_mako_stock_kernel; f_zip_kernel_save;;
      esac;;
    esac;;
    hammerhead)
    case $buildtype in
      kernel)
      case $targetver in
        lollipop) f_hammerhead_stock_kernel5; f_zip_kernel_save;;
        kitkat) f_hammerhead_stock_kernel; f_zip_kernel_save;;
      esac;;
      all)
      case $targetver in
        lollipop) f_rootfs; f_hammerhead_stock_kernel5; f_zip_kernel_save;;
        kitkat) f_rootfs; f_hammerhead_stock_kernel; f_zip_kernel_save;;
      esac;;
    esac;;
    shamu)
      case $buildtype in
        kernel) f_nexus6_kernel5; f_zip_kernel_save;;
        all) f_rootfs; f_nexus6_kernel5; f_zip_kernel_save;;
      esac;;
    flounder)
    case $buildtype in
      kernel) f_nexus9_kernel5; f_zip_kernel_save;;
      all) f_rootfs; f_nexus9_kernel5; f_zip_kernel_save;;
    esac;;
    bacon)
    case $buildtype in
      kernel)
      case $targetver in
        lollipop) f_oneplus_kernel5; f_zip_kernel_save;;
        kitkat) f_oneplus_kernel; f_zip_kernel_save;;
      esac;;
      all)
      case $targetver in
        lollipop) f_rootfs; f_oneplus_kernel5; f_zip_kernel_save;;
        kitkat) f_rootfs; f_deb_stock_kernel; f_zip_kernel_save;;
      esac;;
    esac;;
  esac

}

### Actually builds the rootfs
f_rootfs(){
  f_rootfs_setup(){
    ###################
    ### BUILD SETUP ###
    ###################
    if [[ -d $basepwd/toolchains/gcc-arm-linux-gnueabihf-4.7 ]]; then
      echo "Using existing toolchain"
    else
      echo "Cloning toolchain"
      git clone https://github.com/offensive-security/gcc-arm-linux-gnueabihf-4.7 $basepwd/toolchains/gcc-arm-linux-gnueabihf-4.7
    fi
    export PATH=${PATH}:$basepwd/toolchains/gcc-arm-linux-gnueabihf-4.7/bin
    unset CROSS_COMPILE
    # Set working folder to rootfs
    cd ${rootfs}
  }

  f_rootfs_stage_one(){
    echo -e "\e[31m##########################################################################################\e[0m"
    echo -e "\e[31m###\e[0m  FIRST STAGE CHROOT  \e[31m#################################################################\e[0m"
    echo -e "\e[31m##########################################################################################\e[0m"
    ##############################################################
    ### Create the base system to install everything on top of ###
    ##############################################################

    debootstrap --foreign --arch $architecture kali kali-$architecture http://http.kali.org/kali
    cp /usr/bin/qemu-arm-static kali-$architecture/usr/bin/
  }

  f_rootfs_stage_two(){
    echo -e "\e[31m##########################################################################################\e[0m"
    echo -e "\e[31m###\e[0m  SECOND STAGE CHROOT  \e[31m################################################################\e[0m"
    echo -e "\e[31m##########################################################################################\e[0m"
    ########################
    ### Configure RootFS ###
    ########################

    LANG=C chroot kali-$architecture /debootstrap/debootstrap --second-stage

    #Copies sources.list file to chroot
    cp -rf $basepwd/utils/config/sources.list ${rootfs}/kali-$architecture/etc/apt/sources.list

    #define hostname
    cp -rf $basepwd/utils/config/hostname ${rootfs}/kali-$architecture/etc/hostname

    # fix for TUN symbolic link to enable programs like openvpn
    # set terminal length to 80 because root destroy terminal length
    # add fd to enable stdin/stdout/stderr
    cp -rf $basepwd/utils/config/bashprofile ${rootfs}/kali-$architecture/root/.bash_profile

    # Copy hosts file to chroot
    cp -rf $basepwd/utils/config/hosts ${rootfs}/kali-$architecture/etc/hosts

    if [[ $LOCALGIT == 1 ]]; then
      cp /etc/hosts kali-$architecture/etc/
    fi

    # Install Local files
    cp -rf ${basepwd}/utils/{s,start-*} kali-$architecture/usr/bin/
    cp -rf ${basepwd}/utils/hid/* kali-$architecture/usr/bin/
    cp -rf ${basepwd}/utils/msf/*.sh kali-$architecture/usr/bin/
    cp -rf $basepwd/utils/config/interfaces ${rootfs}/kali-$architecture/etc/network/interfaces
    cp -rf $basepwd/utils/config/resolv.conf ${rootfs}/kali-$architecture/etc/resolv.conf
  }

  f_rootfs_stage_three(){
    echo -e "\e[31m##########################################################################################\e[0m"
    echo -e "\e[31m###\e[0m  THIRD STAGE CHROOT  \e[31m#################################################################\e[0m"
    echo -e "\e[31m##########################################################################################\e[0m"
    ######################################
    ### Install extra Kali Linux tools ###
    ######################################

    export MALLOC_CHECK_=0 # workaround for LP: #520465
    export LC_ALL=C
    export DEBIAN_FRONTEND=noninteractive

    mount -t proc proc ${rootfs}/kali-$architecture/proc
    mount -o bind /dev/ ${rootfs}/kali-$architecture/dev/
    mount -o bind /dev/pts ${rootfs}/kali-$architecture/dev/pts

    cp -rf ${basepwd}/utils/config/debconf.set ${rootfs}/kali-$architecture/debconf.set
    cp -rf ${basepwd}/utils/config/third-stage ${rootfs}/kali-$architecture/third-stage
    cp -rf ${basepwd}/utils/safe-apt-get kali-$architecture/usr/bin/safe-apt-get
    chmod +x ${rootfs}/kali-$architecture/third-stage
    LANG=C chroot kali-$architecture /third-stage
  }

  f_rootfs_stage_four(){
    echo -e "\e[31m##########################################################################################\e[0m"
    echo -e "\e[31m###\e[0m  FOURTH STAGE CHROOT  \e[31m################################################################\e[0m"
    echo -e "\e[31m##########################################################################################\e[0m"
    ########################################################
    ### Set up and configures tools needed for NetHunter ###
    ########################################################

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
    cp -rf $basepwd/utils/config/dnsmasq.conf ${rootfs}/kali-$architecture/etc/dnsmasq.conf

    # Add missing folders to chroot needed
    cap=kali-$architecture/captures
    mkdir -p kali-$architecture/root/.ssh/
    mkdir -p kali-$architecture/sdcard kali-$architecture/system
    mkdir -p $cap/evilap $cap/ettercap $cap/kismet/db $cap/nmap $cap/sslstrip $cap/tshark $cap/wifite $cap/tcpdump $cap/urlsnarf $cap/dsniff $cap/honeyproxy $cap/mana/sslsplit

    # In order for metasploit to work daemon,nginx,postgres must all be added to inet
    # beef-xss creates user beef-xss. Openvpn server requires nobdy:nobody in order to work
    echo "inet:x:3004:postgres,root,beef-xss,daemon,nginx" >> kali-$architecture/etc/group
    echo "nobody:x:3004:nobody" >> kali-$architecture/etc/group
  }

  f_rootfs_cleanup(){
    echo -e "\e[31m##########################################################################################\e[0m"
    echo -e "\e[31m###\e[0m  CLEAN UP CHROOT  \e[31m####################################################################\e[0m"
    echo -e "\e[31m##########################################################################################\e[0m"

    cp -rf $basepwd/utils/config/cleanup ${rootfs}/kali-$architecture/cleanup
    chmod +x kali-$architecture/cleanup
    LANG=C chroot kali-$architecture /cleanup
    sleep 5

    #It isn't mounted anyway.
    #umount ${rootfs}/kali-$architecture/proc/sys/fs/binfmt_misc
    umount ${rootfs}/kali-$architecture/dev/pts
    umount ${rootfs}/kali-$architecture/dev/
    umount ${rootfs}/kali-$architecture/proc
  }

  f_rootfs_create_zip(){
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
    cd ${basepwd}

    # Create base flashable zip

    cp -rf ${basepwd}/flash ${basedir}/
    mkdir -p ${basedir}/flash/data/local/
    mkdir -p ${basedir}/flash/system/lib/modules

    # Copy configuration files needed by nethunter app (we could also move this folder to flash/sdcard/files)

    mkdir -p ${basedir}/flash/sdcard
    cp -rf ${basepwd}/utils/files ${basedir}/flash/sdcard

    # Download/add Android applications that are useful to our chroot enviornment

    rm ${basedir}/flash/data/app/*

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

    cd ${basedir}/flash/
    zip -r6 NetHunter-$builddate.zip *
    mv NetHunter-$builddate.zip ${basedir}
    cd ${basedir}
    # Generate sha1sum
    echo "Generating sha1sum for update-kali-$builddate.zip"
    sha1sum NetHunter-$builddate.zip > ${basedir}/NetHunter-$builddate.sha1sum
    sleep 5
  }

  if [[ -d ${rootfs}/kali-$architecture ]]; then
    echo "Reusing existing RootFS"
    f_rootfs_create_zip
  else
    f_rootfs_setup
    f_rootfs_stage_one
    f_rootfs_stage_two
    f_rootfs_stage_three
    f_rootfs_stage_four
    f_rootfs_cleanup
    f_rootfs_create_zip
  fi
}

### Zip up the kernel
f_zip_kernel_save(){
  apt-get install -y zip
  d_clear
  cd ${basedir}/flashkernel/
  zip -r6 kernel-kali-$builddate.zip *
  mv kernel-kali-$builddate.zip ${basedir}
  cd ${basedir}
  # Generate sha1sum
  echo "Generating sha1sum for kernel-kali-$builddate.zip"
  sha1sum kernel-kali-$builddate.zip > ${basedir}/kernel-kali-$builddate.sha1sum
  sleep 5
}

### Set up kernel folder
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

### Builds the kernel
f_kernel_build(){
  echo "Building Kernel"
  make -j $(grep -c processor /proc/cpuinfo)
  echo "Building modules"

  # Detect if module support is enabled in kernel and if so then build/copy.
  if grep -q CONFIG_MODULES=y .config; then
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

### Moves files to output directory
f_movefiles(){
  case $buildtype in
    rootfs)
    cd ${basedir}
    mkdir -p $outputdir/RootFS
    mv update-kali-$builddate.zip $outputdir/RootFS/NetHunter-$builddate.zip
    mv update-kali-$builddate.sha1sum $outputdir/RootFS/NetHunter-$builddate.sha1sum
    echo "File is now located at $outputdir/RootFS/NetHunter-$builddate.zip"
    echo "SHA1 sum located at $outputdir/RootFS/NetHunter-$builddate.sha1sum"
    rm -rf ${basedir}
    exit;;
  esac

  if [ -a ${basedir}/kernel-kali-$builddate.zip ]; then
    cd ${basedir}
    mkdir -p $outputdir/Kernels/$selecteddevice
    mv kernel-kali-$builddate.zip $outputdir/Kernels/$selecteddevice/Kernel-$selecteddevice-$targetver-$builddate.zip
    mv kernel-kali-$builddate.sha1sum $outputdir/Kernels/$selecteddevice/Kernel-$selecteddevice-$targetver-$builddate.sha1sum
    echo "File is now located at $outputdir/Kernels/$selecteddevice/Kernel-$selecteddevice-$targetver-$builddate.zip"
    echo "SHA1 sum located at $outputdir/Kernels/$selecteddevice/Kernel-$selecteddevice-$targetver-$builddate.sha1sum"
    rm -rf ${basedir}
  else
    echo "No kernel file found. Skipping transfer to output directory."
  fi
}

### doesn't clear screen if debug mode on
d_clear(){
  # Disable the 'clear' statements, if DEBUG mode is enabled
  if [[ ${DEBUG} == 1 ]]; then
    echo **DEBUG** : Not clearing the screen.
  else
    clear
  fi
}




######################### The commands below this line execute first #########################
### Use these variables to set the defaults if no argument was set
outputdir=~/NetHunter-Builds
deletefiles=0

### Arguments ###
while getopts "b:a:t:o:dkh" flag; do
  case "$flag" in
    b)
      case $OPTARG in
        kernel)
        buildtype="kernel";;
        rootfs)
        buildtype="rootfs";;
        all)
        buildtype="all";;
        *)
        echo "Invalid build type: $OPTARG"
        exit;;
      esac;;
    a)
      case $OPTARG in
        lollipop|Lollipop)
        targetver=lollipop;;
        kitkat|KitKat)
        targetver=kitkat;;
        touchwiz|Touchwiz)
        targetver=touchwiz;;
        *)
        echo "Invalid Device Selected: $OPTARG"
        exit;;
      esac;;
    t)
      case $OPTARG in
        manta) selecteddevice="manta";;
        grouper|tilapia|groupertilapia|tilapiagrouper) selecteddevice="groupertilapia";;
        flo|deb|flodeb|debflo) selecteddevice="flodeb";;
        mako) selecteddevice="mako";;
        hammerhead) selecteddevice="hammerhead";;
        shamu) selecteddevice="shamu";;
        flounder) selecteddevice="flounder";;
        gs5) selecteddevice="gs5";;
        gs4) selecteddevice="gs4";;
        bacon) selecteddevice="bacon";;
        *) echo "Invalid device: $OPTARG"
      esac;;
    o)
      outputdir=$OPTARG
      if [ -d "$outputdir" ]; then
        sleep 0
      else
        mkdir -p $outputdir
        if [ -d "$outputdir" ]; then
          sleep 0
        else
          echo "There was an error creating the directory. Make sure it is correct before continuing."
          exit
        fi
      fi;;
    d)
      echo "Debugging Mode On"
      DEBUG=1;;
    k)
      keepfiles=1;;
    h)
      clear
      echo -e "\e[31m##################################\e[37m NetHunter Help Menu \e[31m###################################\e[0m"
      echo -e "\e[31m###e.g. ./nethunterbuilder.sh -b kernel -t grouper -a lollipop -o ~/newbuild                       ###\e[0m"
      echo -e "\e[31m###\e[37m Options \e[31m##############################################################################\e[0m"
      echo -e  "-h               \e[31m||\e[0m This help menu"
      echo -e  "-b [type]        \e[31m||\e[0m Build type"
      echo -e  "-t [device]      \e[31m||\e[0m Android device to build for (Kernel buids only)"
      echo -e  "-a [Version]     \e[31m||\e[0m Android version to build for (Kernel buids only)"
      echo -e  "-o [directory]   \e[31m||\e[0m Where the files are output (Defaults to ~/NetHunter-Builds)"
      echo -e  "-k               \e[31m||\e[0m Keep previously downloaded files (If they exist)"
      echo -e  "-d               \e[31m||\e[0m Turn debug mode on"
      echo -e "\e[31m###\e[37m Devices \e[31m##############################################################################\e[0m"
      echo -e  "manta            \e[31m||\e[0m Nexus 10"
      echo -e  "grouper          \e[31m||\e[0m Nexus 7 (2012) Wifi"
      echo -e  "tilapia          \e[31m||\e[0m Nexus 7 (2012) 3G"
      echo -e  "flo              \e[31m||\e[0m Nexus 7 (2013) Wifi"
      echo -e  "deb              \e[31m||\e[0m Nexus 7 (2013) LTE"
      echo -e  "mako             \e[31m||\e[0m Nexus 4"
      echo -e  "hammerhead       \e[31m||\e[0m Nexus 5"
      echo -e  "shamu            \e[31m||\e[0m Nexus 6"
      echo -e  "flounder         \e[31m||\e[0m Nexus 9 Wifi"
      echo -e  "bacon            \e[31m||\e[0m OnePlus One"
      echo -e "\e[31m###\e[37m Build Types \e[31m##########################################################################\e[0m"
      echo -e  "all              \e[31m||\e[0m Builds kernel and RootFS (Requires -t and -a arguments)"
      echo -e  "kernel           \e[31m||\e[0m Builds just a kernel (Requires -t and -a arguments)"
      echo -e  "rootfs           \e[31m||\e[0m Builds Nethunter RootFS"
      echo -e "\e[31m###\e[37m Versions \e[31m#############################################################################\e[0m"
      echo -e  "lollipop         \e[31m||\e[0m Android 5.0 Lollipop"
      echo -e  "kitkat           \e[31m||\e[0m Android 4.4.2 - 4.4.4 KitKat"
      echo -e "\e[31m##########################################################################################\e[0m"
      exit;;
  esac
done

# Checks if script can run with given arguments and host machine capabilities
f_check
# Sets up build environment and variables and updates files
f_setup
# Builds kernel and/or rootfs according to input
f_build
# Moves files to specified output directory
