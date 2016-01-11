#!/sbin/sh
# Check for install of busybox

# Make sure we are mounted
/sbin/busybox mount /system

if [ ! -f /system/xbin/busybox ] || [ ! -f /system/bin/busybox ]; then
	echo "@Missing busybox...installing"
	cp /tmp/busybox /system/xbin/busybox
	chmod 755 /system/xbin/busybox
	/system/xbin/busybox --install -s /system/xbin
fi
