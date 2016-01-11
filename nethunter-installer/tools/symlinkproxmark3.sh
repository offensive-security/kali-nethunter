#!/sbin/sh

TMP=/tmp/nethunter

# Make sure we are mounted
/sbin/busybox mount /system

cp -rf $TMP/system/bin/lualibs /system/bin/lualibs
cp -rf $TMP/system/bin/scripts /system/bin/scripts
cp -f $TMP/system/bin/proxmark3 /system/bin/proxmark3
cp -f $TMP/system/lib/libusb.so /system/lib/libusb.so 
cp -f $TMP/system/lib/libtermcap.so /system/lib/libtermcap.so
cp -f $TMP/system/lib/libreadline.so /system/lib/libreadline.so

chmod 755 /system/bin/proxmark3
chmod -R 755 /system/bin/scripts/*
chmod -R 755 /system/bin/lualibs/*
chmod 755 /system/lib/libusb.so /system/lib/libtermcap.so /system/lib/libreadline.so
