#!/bin/bash

boot=
if [ -z "$1" ]
then
  boot=boot.img
else
  boot=$1
fi

temp=`od -A n -H -j 20 -N 4 $boot | sed 's/ //g'`
ramdisk_load_addr=0x$temp

cmd_line=`od -A n --strings -j 64 -N 512 $boot`

# Get offset 0xE and 0xF, then read in reverse order
base_temp=`od -A n -h -j 14 -N 2 $boot | sed 's/ //g'`

# The actual 4-byte Kernel Load Address has an offset at the lower bytes,
# but we want to get the base, ie. no offset.
zeros=0000
base=0x$base_temp$zeros

page_size=`od -A n -D -j 36 -N 4 $boot | sed 's/ //g'`

echo "PAGE SIZE: $page_size"
echo "BASE ADDRESS: $base"
echo "RAMDISK ADDRESS: $ramdisk_load_addr"
echo "CMDLINE: '$cmd_line'"
