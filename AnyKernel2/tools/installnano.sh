#!/sbin/sh

# Mount system
/sbin/busybox mount /system
/sbin/busybox mount /data

SYSTEM="/system/etc"

# Check for previous installation of nano
if [ ! -d "$NANODIR" ] || [ ! -f "$NANOBIN"] ; then
	echo "@Installing nano"
	mkdir -p $SYSTEM/terminfo
	mkdir -p $SYSTEM/nano

	cp -f /tmp/system/lib/libncurses.so /system/lib/libncurses.so
	cp -rf /tmp/system/etc/terminfo $SYSTEM/terminfo
	cp -rf /tmp/system/etc/nano $SYSTEM/nano
	cp -rf /tmp/system/xbin/nano /system/xbin/nano

	chmod 755 /system/xbin/nano
else
	echo "Previous version of nano detected. Skipping install"
fi