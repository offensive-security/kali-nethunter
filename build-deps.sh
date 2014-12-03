#!/bin/bash
utils/safe-apt-get install -y git-core gnupg flex bison gperf libesd0-dev build-essential \
zip curl libncurses5-dev zlib1g-dev libncurses5-dev gcc-multilib g++-multilib \
parted kpartx debootstrap pixz qemu-user-static abootimg cgpt vboot-kernel-utils \
vboot-utils uboot-mkimage bc lzma lzop automake autoconf m4 dosfstools rsync \
schedtool git e2fsprogs device-tree-compiler ccache dos2unix

if [ $? -eq 001 ]; then
 exit
fi

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
