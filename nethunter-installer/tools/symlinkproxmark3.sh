#!/sbin/sh

# Make sure we are mounted
/sbin/busybox mount /data
/sbin/busybox mount /system

cp -rf /tmp/system/bin/lualibs /system/bin/lualibs
cp -rf /tmp/system/bin/scripts /system/bin/scripts
cp -f /tmp/system/bin/proxmark3 /system/bin/proxmark3
cp -f /tmp/system/lib/libusb.so /system/lib/libusb.so 
cp -f /tmp/system/lib/libtermcap.so /system/lib/libtermcap.so
cp -f /tmp/system/lib/libreadline.so /system/lib/libreadline.so

chmod 755 /system/bin/proxmark3
chmod 755 /system/bin/scripts/*
chmod 755 /system/bin/lualibs/*
chmod 755 /system/lib/libusb.so /system/lib/libtermcap.so /system/lib/libreadline.so