#!/bin/bash

boot=
if [ -z "$1" ]
then
  boot=boot.img
else
  boot=$1
fi
echo "Boot = $boot"
umkbootimg $boot

dir=${boot%.*}
mkdir -p "$dir"

mv initramfs.cpio.gz "$dir/ramdisk.cpio.gz"
mv zImage "$dir/zImage"
cd $dir
unpack_ramdisk ramdisk.cpio.gz
exit 0
