#!/sbin/sh
#
# Check for install of BB
#
/sbin/busybox mount /data
/sbin/busybox mount /system

if [ ! -f /system/xbin/busybox ] || [ ! -f /system/bin/busybox ]; then
	echo "@Missing busybox...installing"
	mkdir -p /data/local/nhsystem/bin/
	cp /tmp/busybox /data/local/nhsystem/bin/busybox
	chmod 755 /data/local/nhsystem/bin/busybox
	ln -s /data/local/nhsystem/bin/busybox /system/bin/busybox
	ln -s /data/local/nhsystem/bin/busybox /system/xbin/busybox	
	/data/local/nhsystem/bin/busybox --install -s /system/xbin
fi