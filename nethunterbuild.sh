#!/bin/bash

### Tests the os and only allows 64 bit Kali
f_ostest(){
  unamestr=`uname`
  unamearch=`uname -m`

  case $unamestr in
    Darwin)
    clear
    echo "OS X is not supported!"
    echo ""
    read -p "Press [Enter] to exit the script." null
    clear
    exit;;
    *)
    echo "Linux based OS Detected."
    testkali=$(dpkg --get-selections | grep -o "kali-linux")
    case $unamearch in
      x86_64|amd64)
      echo "64 bit linux detected"
      case $testkali in
        kali-linux*)
        echo "Kali Linux OS detected.";;
        *)
        echo "Non-Kali distributions aren't supported!"
        echo ""
        read -p "Press [Enter] to exit the script." null
        clear
        exit;;
      esac;;
      *)
      echo "32 Bit OSs not supported!"
      echo ""
      read -p "Press [Enter] to exit the script." null
      clear
      exit
    esac;;
  esac
}

### Builds dependencies required for the script
f_builddeps(){
  if [ ! -f ~/arm-stuff/kali-nethunter/.completebuild ]; then
    ### Make Directories and Prepare to build
    mkdir ~/arm-stuff
    cd ~/arm-stuff
    git clone https://github.com/offensive-security/gcc-arm-linux-gnueabihf-4.7
    export PATH=${PATH}:/root/arm-stuff/gcc-arm-linux-gnueabihf-4.7/bin
    git clone -b development https://github.com/offensive-security/kali-nethunter
    cd ~/arm-stuff/kali-nethunter

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
      cd ${basedir}
      wget http://lz4.googlecode.com/files/lz4-r112.tar.gz
      tar -xf lz4-r112.tar.gz
      cd lz4-r112
      make
      make install
      echo "lz4c now installed.  Removing leftover files"
      cd ..
      rm -rf lz4-r112.tar.gz lz4-r112
    fi
    echo "This is a file to show that the building of dependencies is complete." > ~/arm-stuff/kali-nethunter/.completebuild
  else
    cd ~/arm-stuff/kali-nethunter
  fi
}

### Creates directories and sets things up
f_setup(){
  #########  Devices  ##########
  # Build scripts for each kernel is located under devices/devicename
  source devices/nexus10-manta
  source devices/nexus9-flounder
  source devices/nexus6-shamu
  source devices/nexus7-grouper-tilapia
  source devices/nexus7-flo-deb
  source devices/nexus5-hammerhead
  source devices/nexus4-mako
  source devices/galaxys5-G900
  source devices/galaxys4

  ######### Set paths and permissions  #######

  basepwd=~/arm-stuff/kali-nethunter
  rootfs=$basepwd/rootfs
  basedir=$basepwd/android-$VERSION
  build_dir=$basepwd/PLACE_ROM_HERE
  wwork=$basepwd/PLACE_ROM_HERE/working_rom_folder
  wram=$basepwd/PLACE_ROM_HERE/working_ramdisk_folder
  bt=$basepwd/utils/boottools
  architecture="armhf"

  chmod +x utils/boottools/*

  ######### Build script start  #######

  # Allow user input of version number/folder creation to make set up easier
  for directory in $(ls -l |grep ^d|awk -F" " '{print $9}');do cd $directory && git pull && cd ..;done
  cd ${basepwd}
  VERSION=$(date +%m%d%Y)
  case $buildtype in
    rootfs) export basedir=$basepwd/rootfs-$VERSION;;
    kernel) export basedir=$basepwd/kernel-$selecteddevice-$VERSION;;
    all) export;;
  esac
  if [ -d "${basedir}" ]; then
    rm -rf ${basedir}
  fi
  mkdir -p ${basedir}
  cd ${basedir}
}

### processes input and runs the proper functions
f_build(){
  case $buildtype in
    rootfs) f_rootfs ; f_flashzip; f_zip_save;;
    *) echo "" >/dev/null 2>&1;;
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
        lollipop) f_rootfs; f_flashzip; f_nexus10_kernel5; f_zip_save; f_zip_kernel_save; f_rom_build;;
        kitkat) f_rootfs; f_flashzip; f_nexus10_kernel; f_zip_save; f_zip_kernel_save; f_rom_build;;
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
        lollipop) f_rootfs; f_flashzip; f_nexus7_grouper_kernel5; f_zip_save; f_zip_kernel_save; f_rom_build;;
        kitkat) f_rootfs; f_flashzip; f_nexus7_grouper_kernel; f_zip_save; f_zip_kernel_save; f_rom_build;;
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
        lollipop) f_rootfs; f_flashzip; f_deb_stock_kernel5; f_zip_save; f_zip_kernel_save; f_rom_build;;
        kitkat) f_rootfs; f_flashzip; f_deb_stock_kernel; f_zip_save; f_zip_kernel_save; f_rom_build;;
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
        lollipop) f_rootfs; f_flashzip; f_mako_stock_kernel5; f_zip_save; f_zip_kernel_save; f_rom_build;;
        kitkat) f_rootfs; f_flashzip; f_mako_stock_kernel; f_zip_save; f_zip_kernel_save; f_rom_build;;
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
        lollipop) f_rootfs; f_flashzip; f_hammerhead_stock_kernel5; f_zip_save; f_zip_kernel_save; f_rom_build;;
        kitkat) f_rootfs; f_flashzip; f_hammerhead_stock_kernel; f_zip_save; f_zip_kernel_save; f_rom_build;;
      esac;;
    esac;;
    #shamu)
    #  case $buildtype in
    #    kernel)
    #    all)
    #  esac;;
    flounder)
    case $buildtype in
      kernel) f_nexus9_kernel5; f_zip_kernel_save;;
      all) f_rootfs; f_flashzip; f_nexus9_kernel5; f_zip_save; f_zip_kernel_save; f_rom_build;;
    esac;;
    gs5)
    case $buildtype in
      kernel)
      case $targetver in
        touchwiz) f_s5_tw_kernel; f_zip_kernel_save;;
        kitkat) f_s5_kernel; f_zip_kernel_save;;
      esac;;
      all)
      case $targetver in
        touchwiz) f_rootfs; f_flashzip; f_s5_tw_kernel; f_zip_save; f_zip_kernel_save; f_rom_build;;
        kitkat) f_rootfs; f_flashzip; f_s5_stock_kernel; f_zip_save; f_zip_kernel_save; f_rom_build;;
      esac;;
    esac;;
    #gs4)
    #  case $buildtype in
    #    kernel)
    #      case $targetver in
    #        touchwiz)
    #        kitkat)
    #      esac;;
    #    all)
    #      case $targetver in
    #        touchwiz)
    #        kitkat)
    #      esac;;
    #  esac;;
  esac

}

### Deletes rootfs. Will change to allow keep rootfs
f_rootfs(){
  rm -rf ${rootfs}/kali-armhf
  f_rootfs_build
}

### Actually builds the rootfs
f_rootfs_build(){

  export PATH=${PATH}:/root/gcc-arm-linux-gnueabihf-4.7/bin
  unset CROSS_COMPILE

  # Set working folder to rootfs

  cd ${rootfs}

  # Package installations for various sections.

  arm="abootimg cgpt fake-hwclock ntpdate vboot-utils vboot-kernel-utils uboot-mkimage"
  base="kali-menu kali-defaults initramfs-tools usbutils openjdk-7-jre mlocate"
  desktop="kali-defaults kali-root-login desktop-base xfce4 xfce4-places-plugin xfce4-goodies"
  tools="nmap metasploit tcpdump tshark wireshark burpsuite armitage sqlmap recon-ng wipe socat ettercap-text-only beef-xss set device-pharmer"
  wireless="wifite iw aircrack-ng gpsd kismet kismet-plugins giskismet dnsmasq dsniff sslstrip mdk3 mitmproxy"
  services="autossh openssh-server tightvncserver apache2 postgresql openvpn php5"
  extras="wpasupplicant zip macchanger dbd florence libffi-dev python-setuptools python-pip hostapd ptunnel tcptrace dnsutils p0f"
  mana="python-twisted python-dnspython libnl1 libnl-dev libssl-dev sslsplit python-pcapy tinyproxy isc-dhcp-server rfkill mana-toolkit"
  spiderfoot="python-lxml python-m2crypto python-netaddr python-mako"
  phishingfrenzy="libcurl4-openssl-dev apache2-threaded-dev libapr1-dev libaprutil1-dev redis-server"
  sdr="sox librtlsdr"

  export packages="${arm} ${base} ${desktop} ${tools} ${wireless} ${services} ${extras} ${mana} ${spiderfoot} ${sdr} ${phishingfrenzy}"
  export architecture="armhf"

  # create the rootfs - not much to modify here, except maybe the hostname.
  debootstrap --foreign --arch $architecture kali kali-$architecture http://http.kali.org/kali

  cp /usr/bin/qemu-arm-static kali-$architecture/usr/bin/

  # SECOND STAGE CHROOT

  LANG=C chroot kali-$architecture /debootstrap/debootstrap --second-stage

  echo "deb http://http.kali.org/kali kali main contrib non-free" > kali-$architecture/etc/apt/sources.list
  echo "deb http://security.kali.org/kali-security kali/updates main contrib non-free" >> kali-$architecture/etc/apt/sources.list

  #define hostname

  echo "localhost" > kali-$architecture/etc/hostname

  # fix for TUN symbolic link to enable programs like openvpn
  # set terminal length to 80 because root destroy terminal length
  # add fd to enable stdin/stdout/stderr
  cp ${basepwd}/utils/config/bashprofile kali-$architecture/root/.bash_profile

  cp ${basepwd}/utils/config/hosts kali-$architecture/etc/hosts

  if [[ $LOCALGIT == 1 ]]; then
    cp /etc/hosts kali-$architecture/etc/
  fi

  # Copy over helper files to chroot /usr/bin

  # Install Local files
  cp -rf ${basepwd}/utils/{s,start-*} kali-$architecture/usr/bin/
  cp -rf ${basepwd}/utils/hid/* kali-$architecture/usr/bin/
  cp -rf ${basepwd}/utils/msf/*.sh kali-$architecture/usr/bin/

  cp ${basepwd}/utils/config/interfaces kali-$architecture/etc/network/interfaces

  cp ${basepwd}/utils/config/resolv.conf kali-$architecture/etc/resolv.conf

  # THIRD STAGE CHROOT

  export MALLOC_CHECK_=0 # workaround for LP: #520465
  export LC_ALL=C
  export DEBIAN_FRONTEND=noninteractive

  mount -t proc proc kali-$architecture/proc
  mount -o bind /dev/ kali-$architecture/dev/
  mount -o bind /dev/pts kali-$architecture/dev/pts

  cp ${basepwd}/utils/config/debconf.set kali-$architecture/debconf.set

  cp ${basepwd}/utils/config/third-stage

  chmod +x kali-$architecture/third-stage kali-$architecture/third-stage
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

  # Install Phishing Frenzy

  ## apt-get install libcurl4-openssl-dev apache2-threaded-dev libapr1-dev libaprutil1-dev redis-server
  #git clone https://github.com/pentestgeek/phishing-frenzy.git ${rootfs}/kali-$architecture/var/www/phishing-frenzy
  #LANG=C chroot ${rootfs}/kali-$architecture gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
  #touch ${rootfs}/kali-$architecture/etc/apache2/pf.conf
  #echo "source /usr/local/rvm/scripts/rvm" >> ${rootfs}/kali-$architecture/root/.bashrc
  #LANG=C chroot ${rootfs}/kali-$architecture source /root/.bashrc
  #LANG=C chroot ${rootfs}/kali-$architecture rvm all do gem install --no-rdoc --no-ri rails passenger
  #LANG=C chroot ${rootfs}/kali-$architecture passenger-install-apache2-module --auto
  #echo "LoadModule passenger_module /usr/local/rvm/gems/ruby-2.1.4/gems/passenger-4.0.53/buildout/apache2/mod_passenger.so" >> ${rootfs}/kali-$architecture/etc/apache2/apache2.conf
  #echo "<IfModule mod_passenger.c>" >> ${rootfs}/kali-$architecture/etc/apache2/apache2.conf
  #echo " PassengerRoot /usr/local/rvm/gems/ruby-2.1.4/gems/passenger-4.0.53" >> ${rootfs}/kali-$architecture/etc/apache2/apache2.conf
  #echo " PassengerDefaultRuby /usr/local/rvm/gems/ruby-2.1.4/wrappers/ruby" >> ${rootfs}/kali-$architecture/etc/apache2/apache2.conf
  #echo "</IfModule>" >> ${rootfs}/kali-$architecture/etc/apache2/apache2.conf
  #LANG=C chroot ${rootfs}/kali-$architecture /etc/init.d/mysql start
  #LANG=C chroot ${rootfs}/kali-$architecture mysql -u root -e "create database pf_dev; grant all privileges on pf_dev.* to 'pf_dev'@'localhost' identified by 'password';"
  #cat << EOF > ${rootfs}/kali-$architecture/etc/apache2/pf.conf
  #<IfModule mod_passenger.c>
  #  PassengerRoot %ROOT
  #  PassengerRuby %RUBY
  #</IfModule>
  #
  #<VirtualHost 127.0.0.1:80>
  #    ServerName phishingfrenzy.local
  #    DocumentRoot /var/www/phishing-frenzy/public
  #    RailsEnv development
  #  <Directory /var/www/phishing-frenzy/public>
  #    AllowOverride all
  #    # MultiViews must be turned off.
  #    Options -MultiViews
  #  </Directory>
  #</VirtualHost>
  #EOF
  #LANG=C chroot ${rootfs}/kali-$architecture "cd /var/www/phishing-frenzy/ && bundle install"
  #chown -R www-data:www-data ${rootfs}/kali-$architecture/var/www/phishing-frenzy/
  #chown -R www-data:www-data ${rootfs}/kali-$architecture/etc/apache2/sites-available/
  #chown -R 755 ${rootfs}/kali-$architecture/var/www/phishing-frenzy/public/uploads/
  #LANG=C chroot ${rootfs}/kali-$architecture "cd /var/www/phishing-frenzy/ && rake db:migrate && rake db:seed && rake templates:load"
  #LANG=C chroot ${rootfs}/kali-$architecture /etc/init.d/mysql stop

  # Install MITMf
  LANG=C chroot ${rootfs}/kali-$architecture pip install capstone
  git clone https://github.com/byt3bl33d3r/MITMf.git && mv MITMf ${rootfs}/kali-$architecture/opt/MITMf
  chmod 755 ${rootfs}/kali-$architecture/opt/MITMf/setup.sh ${rootfs}/kali-$architecture/opt/MITMf/update.sh
  LANG=C chroot ${rootfs}/kali-$architecture /opt/MITMf/setup.sh

  # Install Dictionary for wifite
  mkdir -p ${rootfs}/kali-$architecture/opt/dic
  tar xvf ${basepwd}/utils/dic/89.tar.gz -C ${rootfs}/kali-$architecture/opt/dic

  # Install WPS Scan which scans routers for enabled WPS & pingen which generates DLINK WPS pins
  wget https://raw.githubusercontent.com/devttys0/wps/master/wpstools/wpscan.py -O ${rootfs}/kali-$architecture/usr/bin/wps_scan
  wget https://raw.githubusercontent.com/devttys0/wps/master/wpstools/wpspy.py -O ${rootfs}/kali-$architecture/usr/bin/wps_spy
  wget https://raw.githubusercontent.com/devttys0/wps/master/pingens/dlink/pingen.py -O ${rootfs}/kali-$architecture/usr/bin/pingen
  chmod 755 ${rootfs}/kali-$architecture/usr/bin/wps_scan ${rootfs}/kali-$architecture/usr/bin/pingen ${rootfs}/kali-$architecture/usr/bin/wps_spy

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
  cp ${basepwd}/utils/config/dnsmasq.conf kali-$architecture/etc/dnsmasq.conf

  # Add missing folders to chroot needed
  cap=kali-$architecture/captures
  mkdir -p kali-$architecture/root/.ssh/
  mkdir -p kali-$architecture/sdcard kali-$architecture/system
  mkdir -p $cap/evilap $cap/ettercap $cap/kismet/db $cap/nmap $cap/sslstrip $cap/tshark $cap/wifite $cap/tcpdump $cap/urlsnarf $cap/dsniff $cap/honeyproxy $cap/mana/sslsplit

  # In order for metasploit to work daemon,nginx,postgres must all be added to inet
  # beef-xss creates user beef-xss. Openvpn server requires nobdy:nobody in order to work
  echo "inet:x:3004:postgres,root,beef-xss,daemon,nginx" >> kali-$architecture/etc/group
  echo "nobody:x:3004:nobody" >> kali-$architecture/etc/group

  # CLEANUP STAGE

  cp ${basepwd}/utils/config/cleanup kali-$architecture/cleanup

  chmod +x kali-$architecture/cleanup
  LANG=C chroot kali-$architecture /cleanup

  umount ${rootfs}/kali-$architecture/proc/sys/fs/binfmt_misc
  umount ${rootfs}/kali-$architecture/dev/pts
  umount ${rootfs}/kali-$architecture/dev/
  umount ${rootfs}/kali-$architecture/proc

  sleep 5
}

### Create flashable zip
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

  cp -rf ${basepwd}/flash ${basedir}/flash
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

### Zip everything up
f_zip_save(){
  apt-get install -y zip
  clear
  # Compress filesystem and add to our flashable zip
  cd ${rootfs}

  # Achtung, ugly hack to clean up chrooted /dev before packaging.
  #######################################
  rm -rf  kali-$architecture/dev/*
  #######################################

  tar jcvf kalifs.tar.bz2 kali-$architecture
  mv kalifs.tar.bz2 ${basedir}/flash/data/local/

  #tar jcvf ${basedir}/flash/data/local/kalifs.tar.bz2 ${basedir}/kali-$architecture
  echo "Structure for flashable zip file is complete."
  echo "Build a kernel next or select build flashable zip form the main menu."

  cd ${basedir}/flash/
  zip -r6 update-kali-$VERSION.zip *
  mv update-kali-$VERSION.zip ${basedir}
  cd ${basedir}
  # Generate sha1sum
  echo "Generating sha1sum for NetHunter RootFS"
  sha1sum update-kali-$VERSION.zip > ${basedir}/update-kali-$VERSION.sha1sum
  sleep 5
}

### Zip up the kernel
f_zip_kernel_save(){
  apt-get install -y zip
  clear
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

### Cleans up mounts and stuff
f_cleanup(){
  # Clean up all the temporary build stuff and remove the directories.
  # Comment this out to keep things around if you want to see what may have gone
  # wrong.
  echo "Unmounting any previous mounted folders"
  sleep 3
  clear
  #umount ${rootfs}/kali-$architecture/proc/sys/fs/binfmt_misc
  #umount ${rootfs}/kali-$architecture/dev/pts
  #umount ${rootfs}/kali-$architecture/dev/
  #umount ${rootfs}/kali-$architecture/proc
  #echo "Removing temporary build files"
  #rm -rf ${basedir}/patches ${basedir}/kernel ${basedir}/flash ${basedir}/kali-$architecture ${basedir}/flashkernel
}

### Builds rootfs and kernel into ROM zip
f_rom_build(){
  clear

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

### Set up kernel folder
f_kernel_build_init(){
  clear
  # FOLDER CHECKING
  #
  #if [ -d "${basedir}/kernel" ]; then
  #  read -p "Kernel folder already exsists, would you like to remove folder and startover? (y/n)" kernelanswer
  #  if [ "$kernelanswer" == "y" ]; then
  #     rm -rf ${basedir}/kernel
  #  fi
  #fi

  #if [ -d "${basedir}/flashkernel" ]; then
  #  read -p "Kernel folder already exsists, would you like to remove previous folder? (y/n)" flashanswer
  #  if [ "$flashanswer" == "y" ]; then
  #     rm -rf ${basedir}/flashkernel
  #  fi
  #fi

  #if [ -d "${basedir}/toolchain" ]; then
  #  read -p "Toolchain folder already exsists, would you like to redownload? (y/n)" toolchain answer
  #fi

  cp -rf ${basepwd}/flash/ ${basedir}/flashkernel
  mkdir -p ${basedir}/flashkernel/system/lib/modules
  rm -rf ${basedir}/flashkernel/data
  rm -rf ${basedir}/flashkernel/sdcard
  rm -rf ${basedir}/flashkernel/system/app
  #rm -rf ${basedir}/flashkernel/system/bin ${basedir}/flashkernel/system/xbin
  rm -rf ${basedir}/flashkernel/META-INF/com/google/android/updater-script

  echo "Downloading Android Toolchian"
  if [[ $LOCALGIT == 1 ]]; then
    echo "Copying toolchain to rootfs"
    cp -rf ${basepwd}/arm-eabi-4.7 ${basedir}/toolchain
  else
    git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.7 ${basedir}/toolchain
    #git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8 ${basedir}/toolchain
  fi

  echo "Setting export paths"
  # Set path for Kernel building
  export ARCH=arm
  export SUBARCH=arm
  export CROSS_COMPILE=${basedir}/toolchain/bin/arm-eabi-
}

### Builds the kernel
f_kernel_build(){
  echo "Building Kernel"
  make -j $(grep -c processor /proc/cpuinfo)
  echo "Building modules"
  mkdir -p modules
  make modules_install INSTALL_MOD_PATH=${basedir}/kernel/modules
  echo "Copying Kernel and modules to flashable kernel folder"
  find modules -name "*.ko" -exec cp -t ../flashkernel/system/lib/modules {} +

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

  # Copy kernel to flashable package, prefer zImage-dtb
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
    mv update-kali-$VERSION.zip $outputdir/RootFS/NetHunter-$VERSION.zip
    mv update-kali-$VERSION.sha1sum $outputdir/RootFS/NetHunter-$VERSION.sha1sum
    rm -rf ${basedir}
    exit;;
  esac
  case $selecteddevice in
    manta)
    cd ${basedir}
    mkdir -p $outputdir/Kernels/Manta
    mv kernel-kali-$VERSION.zip $outputdir/Kernels/Manta/Kernel-$selecteddevice-$VERSION.zip
    mv kernel-kali-$VERSION.sha1sum $outputdir/Kernels/Manta/Kernel-$selecteddevice-$VERSION.sha1sum
    rm -rf ${basedir};;
    groupertilapia)
    cd ${basedir}
    mkdir -p $outputdir/Kernels/Grouper
    mkdir -p $outputdir/Kernels/Tilapia
    cp kernel-kali-$VERSION.zip $outputdir/Kernels/Grouper/Kernel-$selecteddevice-$VERSION.zip
    cp kernel-kali-$VERSION.sha1sum $outputdir/Kernels/Grouper/Kernel-$selecteddevice-$VERSION.sha1sum
    mv kernel-kali-$VERSION.zip $outputdir/Kernels/Tilapia/Kernel-$selecteddevice-$VERSION.zip
    mv kernel-kali-$VERSION.sha1sum $outputdir/Kernels/Tilapia/Kernel-$selecteddevice-$VERSION.sha1sum
    rm -rf ${basedir};;
    flodeb)
    cd ${basedir}
    mkdir -p $outputdir/Kernels/Flo
    mkdir -p $outputdir/Kernels/Deb
    cp kernel-kali-$VERSION.zip $outputdir/Kernels/Flo/Kernel-$selecteddevice-$VERSION.zip
    cp kernel-kali-$VERSION.sha1sum $outputdir/Kernels/Flo/Kernel-$selecteddevice-$VERSION.sha1sum
    mv kernel-kali-$VERSION.zip $outputdir/Kernels/Deb/Kernel-$selecteddevice-$VERSION.zip
    mv kernel-kali-$VERSION.sha1sum $outputdir/Kernels/Deb/Kernel-$selecteddevice-$VERSION.sha1sum
    rm -rf ${basedir};;
    mako)
    cd ${basedir}
    mkdir -p $outputdir/Kernels/Mako
    mv kernel-kali-$VERSION.zip $outputdir/Kernels/Mako/Kernel-$selecteddevice-$VERSION.zip
    mv kernel-kali-$VERSION.sha1sum $outputdir/Kernels/Mako/Kernel-$selecteddevice-$VERSION.zip.sha1sum
    rm -rf ${basedir};;
    hammerhead)
    cd ${basedir}
    mkdir -p $outputdir/Kernels/Hammerhead
    mv kernel-kali-$VERSION.zip $outputdir/Kernels/Hammerhead/Kernel-$selecteddevice-$VERSION.zip
    mv kernel-kali-$VERSION.sha1sum $outputdir/Kernels/Hammerhead/Kernel-$selecteddevice-$VERSION.sha1sum
    rm -rf ${basedir};;
    shamu)
    cd ${basedir}
    mkdir -p $outputdir/Kernels/Shamu
    mv kernel-kali-$VERSION.zip $outputdir/Kernels/Shamu/Kernel-$selecteddevice-$VERSION.zip
    mv kernel-kali-$VERSION.sha1sum $outputdir/Kernels/Shamu/Kernel-$selecteddevice-$VERSION.sha1sum
    rm -rf ${basedir};;
    flounder)
    cd ${basedir}
    mkdir -p $outputdir/Kernels/Flounder
    mv kernel-kali-$VERSION.zip $outputdir/Kernels/Flounder/Kernel-$selecteddevice-$VERSION.zip
    mv kernel-kali-$VERSION.sha1sum $outputdir/Kernels/Flounder/Kernel-$selecteddevice-$VERSION.sha1sum
    rm -rf ${basedir};;
    gs5)
    cd ${basedir}
    mkdir -p $outputdir/Kernels/SGS5-I9500
    mv kernel-kali-$VERSION.zip $outputdir/Kernels/SGS5-I9500/Kernel-$selecteddevice-$VERSION.zip
    mv kernel-kali-$VERSION.sha1sum $outputdir/Kernels/SGS5-I9500/Kernel-$selecteddevice-$VERSION.sha1sum
    rm -rf ${basedir};;
    gs4)
    cd ${basedir}
    mkdir -p $outputdir/Kernels/SGS4-G900
    mv kernel-kali-$VERSION.zip $outputdir/Kernels/SGS4-G900/Kernel-$selecteddevice-$VERSION.zip
    mv kernel-kali-$VERSION.sha1sum $outputdir/Kernels/SGS4-G900/Kernel-$selecteddevice-$VERSION.sha1sum
    rm -rf ${basedir};;
  esac
}



### Arguments ###
### '$OPTARG' is the var with the string after the -?
while getopts "h:b:a:t:o:" flag; do
  case "$flag" in
    h)
    clear
    echo "Help Menu"
    exit;;
    b)
    clear
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
    esac
    echo "";;
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
    clear
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
      *) echo "Invalid device: $OPTARG"
    esac;;
    o)
    clear
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
  esac
done

f_ostest
f_builddeps
f_setup
f_build
f_movefiles
