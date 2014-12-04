#!/bin/bash

### Tests the os and only allows 64 bit Kali
f_ostest(){
  unamestr=`uname`
  unamearch=`uname -m`

  case $unamestr in
    Darwin)
    d_clear
    echo "OS X is not supported!"
    echo ""
    read -p "Press [Enter] to exit the script." null
    d_clear
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
        d_clear
        exit;;
      esac;;
      *)
      echo "32 Bit OSs not supported!"
      echo ""
      read -p "Press [Enter] to exit the script." null
      d_clear
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

#################
### Main Menu ###
#################
f_mainmenu(){
  clear
  echo "NetHunter Build Menu"
  echo ""
  echo "##################################################"
  echo "[1] Build for Nexus devices"
  echo ""
  echo "[2] Build for OnePlus devices"
  echo ""
  echo "[3] Build for Samsung devices"
  echo ""
  echo "[4] RootFS only for all devices"
  echo ""
  #echo "[O] Options"
  echo "[Q] Quit"
  echo ""
  read -p "Selection: " brandselection

  case $brandselection in
    1) f_nexusmenu;;
    2) f_oneplusmenu;;
    3) f_samsungmenu;;
    4) f_rootfsonly;;
    Q|q) clear; exit;;
  esac
}

###################
### Device Type ###
###################
f_nexusmenu(){
  clear
  echo "NetHunter>Nexus Build Menu"
  echo ""
  echo "##################################################"
  echo "[1] Nexus 4 ---------- MAKO"
  echo "[2] Nexus 5 ---------- HAMMERHEAD"
  echo "[3] Nexus 6 ---------- SHAMU"
  echo "[4] Nexus 7 (2012) --- GROUPER/TILAPIA"
  echo "[5] Nexus 7 (2013) --- FLO/DEB"
  echo "[6] Nexus 9 ---------- FLOUNDER"
  echo "[7] Nexus 10 --------- MANTA"
  echo ""
  echo ""
  echo "[R] Return to previous menu"
  echo "[Q] Quit"
  echo ""
  read -p "Selection: " deviceselection

  case $deviceselection in
    1) f_mako;;
    2) f_hammerhead;;
    3) f_shamu;;
    4) f_groupertilapia;;
    5) f_flodeb;;
    6) f_flounder;;
    7) f_manta;;
    R|r) f_mainmenu;;
    Q|q) clear; exit;;
  esac
}

f_oneplusmenu(){
  clear
  echo "NetHunter>OnePlus Build Menu"
  echo ""
  echo "##################################################"
  echo "[1] OnePlus One"
  echo ""
  echo ""
  echo "[R] Return to previous menu"
  echo "[Q] Quit"
  echo ""
  read -p "Selection: " deviceselection

  case $deviceselection in
    1) f_oneplusone;;
    R|r) f_mainmenu;;
    Q|q) clear; exit;;
  esac
}

f_samsungmenu(){
  clear
  echo "NetHunter>Samsung Build Menu"
  echo ""
  echo "##################################################"
  echo "[1] Galaxy S5 --- G900"
  echo "[2] Galaxy S4 --- I9500"
  echo ""
  echo ""
  echo "[R] Return to previous menu"
  echo "[Q] Quit"
  echo ""
  read -p "Selection: " deviceselection

  case $deviceselection in
    1) f_gs5;;
    2) f_gs4;;
    R|r) f_mainmenu;;
    Q|q) clear; exit;;
  esac
}

#####################
### Nexus Devices ###
#####################
f_mako(){
  clear
  device=mako
  echo "NetHunter>Nexus>Mako Build Menu"
  echo "##################################################"
  echo "	[1] Rootfs and Kernel --- (Android 4.4.2 - 4.4.4)"
  echo "	[2] Kernel Only --------- (Android 4.4.2 - 4.4.4)"
  echo "  [3] RootFS and Kernel --- (Android 5)"
  echo "  [4] Kernel Only --------- (Android 5)"
  echo ""
  echo ""
  echo "[R] Return to previous menu"
  echo "[Q] Quit"
  echo ""
  read -p "Selection: " buildselection

  case $buildselection in
    1) f_kitkatall;;
    2) f_kitkatkernel;;
    3) f_lollipopall;;
    4) f_lollipopkernel;;
    R|r) f_nexusmenu;;
    Q|q) clear; exit;;
  esac
}

f_hammerhead(){
  clear
  device=hammerhead
  echo "NetHunter>Nexus>Hammerhead Build Menu"
  echo "##################################################"
  echo "	[1] Rootfs and Kernel --- (Android 4.4.2 - 4.4.4)"
  echo "	[2] Kernel Only --------- (Android 4.4.2 - 4.4.4)"
  echo "  [3] RootFS and Kernel --- (Android 5)"
  echo "  [4] Kernel Only --------- (Android 5)"
  echo ""
  echo ""
  echo "[R] Return to previous menu"
  echo "[Q] Quit"
  echo ""
  read -p "Selection: " buildselection

  case $buildselection in
    1) f_kitkatall;;
    2) f_kitkatkernel;;
    3) f_lollipopall;;
    4) f_lollipopkernel;;
    R|r) f_nexusmenu;;
    Q|q) clear; exit;;
  esac
}

f_shamu(){
  clear
  device=shamu
  echo "NetHunter>Nexus>Shamu Build Menu"
  echo "##################################################"
  echo "  [1] RootFS and Kernel --- (Android 5)"
  echo "  [2] Kernel Only --------- (Android 5)"
  echo ""
  echo ""
  echo "[R] Return to previous menu"
  echo "[Q] Quit"
  echo ""
  read -p "Selection: " buildselection

  case $buildselection in
    1) f_lollipopall;;
    2) f_lollipopkernel;;
    R|r) f_nexusmenu;;
    Q|q) clear; exit;;
  esac
}

f_groupertilapia(){
  clear
  device=groupertilapia
  echo "NetHunter>Nexus>Grouper/Tilapia Build Menu"
  echo "##################################################"
  echo "	[1] Rootfs and Kernel --- (Android 4.4.2 - 4.4.4)"
  echo "	[2] Kernel Only --------- (Android 4.4.2 - 4.4.4)"
  echo "  [3] RootFS and Kernel --- (Android 5)"
  echo "  [4] Kernel Only --------- (Android 5)"
  echo ""
  echo ""
  echo "[R] Return to previous menu"
  echo "[Q] Quit"
  echo ""
  read -p "Selection: " buildselection

  case $buildselection in
    1) f_kitkatall;;
    2) f_kitkatkernel;;
    3) f_lollipopall;;
    4) f_lollipopkernel;;
    R|r) f_nexusmenu;;
    Q|q) clear; exit;;
  esac
}

f_flodeb(){
  clear
  device=flodeb
  echo "NetHunter>Nexus>Flo/Deb Build Menu"
  echo "##################################################"
  echo "	[1] Rootfs and Kernel --- (Android 4.4.2 - 4.4.4)"
  echo "	[2] Kernel Only --------- (Android 4.4.2 - 4.4.4)"
  echo "  [3] RootFS and Kernel --- (Android 5)"
  echo "  [4] Kernel Only --------- (Android 5)"
  echo ""
  echo ""
  echo "[R] Return to previous menu"
  echo "[Q] Quit"
  echo ""
  read -p "Selection: " buildselection

  case $buildselection in
    1) f_kitkatall;;
    2) f_kitkatkernel;;
    3) f_lollipopall;;
    4) f_lollipopkernel;;
    R|r) f_nexusmenu;;
    Q|q) clear; exit;;
  esac
}

f_flounder(){
  clear
  device=flounder
  echo "NetHunter>Nexus>Flounder Build Menu"
  echo "##################################################"
  echo "  [1] RootFS and Kernel --- (Android 5)"
  echo "  [2] Kernel Only --------- (Android 5)"
  echo ""
  echo ""
  echo "[R] Return to previous menu"
  echo "[Q] Quit"
  echo ""
  read -p "Selection: " buildselection

  case $buildselection in
    1) f_lollipopall;;
    2) f_lollipopkernel;;
    R|r) f_nexusmenu;;
    Q|q) clear; exit;;
  esac
}

f_manta(){
  clear
  device=manta
  echo "NetHunter>Nexus>Manta Build Menu"
  echo "##################################################"
  echo "	[1] Rootfs and Kernel --- (Android 4.4.2 - 4.4.4)"
  echo "	[2] Kernel Only --------- (Android 4.4.2 - 4.4.4)"
  echo "  [3] RootFS and Kernel --- (Android 5)"
  echo "  [4] Kernel Only --------- (Android 5)"
  echo ""
  echo ""
  echo "[R] Return to previous menu"
  echo "[Q] Quit"
  echo ""
  read -p "Selection: " buildselection

  case $buildselection in
    1) f_kitkatall;;
    2) f_kitkatkernel;;
    3) f_lollipopall;;
    4) f_lollipopkernel;;
    R|r) f_nexusmenu;;
    Q|q) clear; exit;;
  esac
}

#######################
### OnePlus Devices ###
#######################
f_oneplusone(){
  clear
  device=bacon
  echo "NetHunter>OnePlus>One Build Menu"
  echo "##################################################"
  echo "	[1] Rootfs and Kernel --- (Android 4.4.2 - 4.4.4)"
  echo "	[2] Kernel Only --------- (Android 4.4.2 - 4.4.4)"
  echo "  [3] RootFS and Kernel --- (Android 5)"
  echo "  [4] Kernel Only --------- (Android 5)"
  echo ""
  echo ""
  echo "[R] Return to previous menu"
  echo "[Q] Quit"
  echo ""
  read -p "Selection: " buildselection

  case $buildselection in
    1) f_kitkatall;;
    2) f_kitkatkernel;;
    3) f_lollipopall;;
    4) f_lollipopkernel;;
    R|r) f_oneplusmenu;;
    Q|q) clear; exit;;
  esac
}

#######################
### Samsung Devices ###
#######################
f_gs5(){
  clear
  device=gs5
  echo "NetHunter>Samsung>Galaxy S5 Build Menu"
  echo "##################################################"
  echo "	[1] Rootfs and Kernel --- (Android  4.4.2 - 4.4.4)"
  echo "	[2] Kernel Only --------- (Android  4.4.2 - 4.4.4)"
  echo "  [3] RootFS and Kernel --- (TouchWiz 4.4.2 - 4.4.4)"
  echo "  [4] Kernel Only --------- (TouchWiz 4.4.2 - 4.4.4)"
  echo ""
  echo ""
  echo "[R] Return to previous menu"
  echo "[Q] Quit"
  echo ""
  read -p "Selection: " buildselection

  case $buildselection in
    1) f_kitkatall;;
    2) f_kitkatkernel;;
    3) f_touchwizall;;
    4) f_touchwizkernel;;
    R|r) f_oneplusmenu;;
    Q|q) clear; exit;;
  esac
}

f_gs4(){
  clear
  device=gs4
  echo "NetHunter>Samsung>Galaxy S4 Build Menu"
  echo "##################################################"
  echo "	[1] Rootfs and Kernel --- (Android  4.4.2 - 4.4.4)"
  echo "	[2] Kernel Only --------- (Android  4.4.2 - 4.4.4)"
  echo "  [3] RootFS and Kernel --- (TouchWiz 4.4.2 - 4.4.4)"
  echo "  [4] Kernel Only --------- (TouchWiz 4.4.2 - 4.4.4)"
  echo ""
  echo ""
  echo "[R] Return to previous menu"
  echo "[Q] Quit"
  echo ""
  read -p "Selection: " buildselection

  case $buildselection in
    1) f_kitkatall;;
    2) f_kitkatkernel;;
    3) f_touchwizall;;
    4) f_touchwizkernel;;
    R|r) f_oneplusmenu;;
    Q|q) clear; exit;;
  esac
}

#############################
### Build Kernel / RootFS ###
#############################
f_kitkatall(){
  ./nethunterbuild -b all -a kitkat -t $device
  exit
}

f_kitkatkernel(){
  ./nethunterbuild -b kernel -a kitkat -t $device
  exit
}

f_lollipopall(){
  ./nethunterbuild -b all -a lollipop -t $device
  exit
}

f_lollipopkernel(){
  ./nethunterbuild -b kernel -a lollipop -t $device
  exit
}

f_touchwizall(){
  ./nethunterbuild -b all -a touchwiz -t $device
  exit
}

f_touchwizkernel(){
  ./nethunterbuild -b kernel -a touchwiz -t $device
  exit
}

f_rootfsonly(){
  ./nethunterbuild.sh -b rootfs
}
