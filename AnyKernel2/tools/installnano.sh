#!/sbin/sh

# Mount system
/sbin/busybox mount /system
/sbin/busybox mount /data

NANODIR="/system/etc/nano"
NANOBIN="/system/xbin/nano"
DATA="/data/local/nhsystem/etc"
SYSTEM="/system/etc"

# Check for previous installation of nano
if [ ! -d "$NANODIR" ] || [ ! -f "$NANOBIN"] ; then
	echo "@Installing nano"
	# Symlink from /data/local/nhsystem/etc/nano to /system/etc/nano
	mkdir -p $DATA/nano
	ln -s $DATA/nano $SYSTEM/nano

	# Symlink from /data/local/nhsystem/nano/terminfo to /system/etc/terminfo
	mkdir -p $DATA/nano/terminfo
	cp -rf /tmp/system/etc/terminfo $DATA/nano/terminfo
	ln -s $DATA/nano/terminfo $SYSTEM/terminfo

	# Symlink from /data/local/nhsystem/nano/xbin/nano to /system/xbin/nano
	mkdir -p $DATA/nano/xbin
	cp -f /tmp/system/xbin/nano $DATA/nano/xbin/nano
	chmod 755 $DATA/nano/xbin/nano
	ln -s $DATA/nano/xbin/nano $NANOBIN

	# Symlink from /data/local/nhsystem/nano/lib/libncurses.so to /system/lib/libncurses.so
	mkdir -p $DATA/nano/lib
	cp -f /tmp/system/lib/libncurses.so $DATA/nano/lib/libncurses.so
	ln -s $DATA/nano/lib/libncurses.so /system/lib/libncurses.so
else
	echo "Previous version of nano detected. Skipping install"
fi