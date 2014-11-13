#!bin/bash

###################################################################################################
### To add an entry:
### 1: Remove all instances of "${rootfs}/kali-$architecture" or "LANG=C chroot kali-$architecture"
### 2: Put the whole script into its own function
### 3: Put the link to it in the f_update function at the top of this script
### 4: Make sure the script can be run on the device itself,
###     so no references to chroot or anything
###################################################################################################


f_update(){
  f_setup

  ### Place your script's link betweeen these lines ###
  f_mana_config
  f_mitmf
  f_wifite
  f_wpsscan
  f_spiderfoot
  f_kismet
  f_kalimenu
  f_adbtools
  f_deadbolt
  f_apfucker
  f_hidattack
  ######################################################

  f_cleanup
}

f_setup(){
  mkdir -p /root/tmp
  cd /root/tmp
  git clone https://github.com/offensive-security/kali-nethunter.git
  basepwd=/root/tmp/kali-nethunter
}

f_cleanup(){
  cd /
  rm -rf /root/tmp
}

f_mana_config(){
  # Copy over our kali specific mana config files
  cp -rf ${basepwd}/utils/manna/start-mana* /usr/bin/
  cp -rf ${basepwd}/utils/manna/stop-mana /usr/bin/
  cp -rf ${basepwd}/utils/manna/*.sh /usr/share/mana-toolkit/run-mana/
  dos2unix /usr/share/mana-toolkit/run-mana/*
  dos2unix /etc/mana-toolkit/*
  chmod 755 /usr/share/mana-toolkit/run-mana/*
  chmod 755 /usr/bin/*.sh
}

f_mitmf(){
  # Install MITMf
  pip install capstone
  git clone https://github.com/byt3bl33d3r/MITMf.git && mv MITMf /opt/MITMf
  chmod 755 /opt/MITMf/setup.sh /opt/MITMf/update.sh
  /opt/MITMf/setup.sh
}

f_wifite(){
  # Install Dictionary for wifite
  mkdir -p /opt/dic
  tar xvf ${basepwd}/utils/dic/89.tar.gz -C /opt/dic
}

f_wpsscan(){
  # Install WPS Scan which scans routers for enabled WPS & pingen which generates DLINK WPS pins
  wget https://raw.githubusercontent.com/devttys0/wps/master/wpstools/wpscan.py -O /usr/bin/wps_scan
  wget https://raw.githubusercontent.com/devttys0/wps/master/wpstools/wpspy.py -O /usr/bin/wps_spy
  wget https://raw.githubusercontent.com/devttys0/wps/master/pingens/dlink/pingen.py -O /usr/bin/pingen
  chmod 755 /usr/bin/wps_scan /usr/bin/pingen /usr/bin/wps_spy
}

f_spiderfoot(){
  # Install Spiderfoot
  # Cherrypy is newer in pip then in repo so we need to use that instead.  All other depend are fine.
  pip install cherrypy
  cd /opt/
  wget https://github.com/smicallef/spiderfoot/archive/v2.2.0-final.tar.gz -O spiderfoot.tar.gz
  tar xvf spiderfoot.tar.gz && rm spiderfoot.tar.gz && mv spiderfoot-2.2.0-final spiderfoot
  cd /root/tmp
}

f_kismet(){
  # Modify Kismet log saving folder
  sed -i 's/hs/\/captures/g' /etc/kismet/kismet.conf
}

f_kalimenu(){
  # Kali Menu (bash script) to quickly launch common Android Programs
  cp -rf ${basepwd}/menu/kalimenu /usr/bin/kalimenu
  chmod 755 /usr/bin/kalimenu
}

f_adbtools(){
  #Installs ADB and fastboot compiled for ARM
  git clone git://git.kali.org/packages/google-nexus-tools
  cp ./google-nexus-tools/bin/linux-arm-adb /usr/bin/adb
  cp ./google-nexus-tools/bin/linux-arm-fastboot /usr/bin/fastboot
  rm -rf ./google-nexus-tools
  chmod 755 /usr/bin/fastboot
  chmod 755 /usr/bin/adb
}

f_deadbolt(){
  #Installs deADBolt
  curl -o deadbolt https://raw.githubusercontent.com/photonicgeek/deADBolt/master/main.sh
  cp ./deadbolt /usr/bin/deadbolt
  rm -rf deadbolt
  chmod 755 /usr/bin/deadbolt
}

f_apfucker(){
  #Installs APFucker.py
  curl -o apfucker.py https://raw.githubusercontent.com/mattoufoutu/scripts/master/AP-Fucker.py
  cp ./apfucker.py /usr/bin/apfucker.py
  rm -rf deadbolt
  chmod 755 /usr/bin/apfucker.py
}

f_hidattack(){
  #Install HID attack script and dictionaries
  cp ${basepwd}/flash/system/xbin/hid-keyboard /usr/bin/hid-keyboard
  cp ${basepwd}/utils/dic/pinlist.txt /opt/dic/pinlist.txt
  cp ${basepwd}/utils/dic/wordlist.txt /opt/dic/wordlist.txt
  cp ${basepwd}/utils/hid/hid-dic.sh ${rootfs}/kali-$architecture/usr/bin/hid-dic
  chmod 755 /usr/bin/hid-keyboard
  chmod 755 /usr/bin/hid-dic
}

f_kernel(){
  #Will finish when there is a good way to flash the kernel.

  device=$(cat /system/build.prop | grep -E 'product.device=' | cut -d"=" -f2)
  case $device in
    flo) ;;

    deb) ;;

    grouper) ;;

    tilapia) ;;

    hammerhead) ;;

    mako) ;;

    manta) ;;

  esac
}

### Insert Functions above this line ###
f_update
