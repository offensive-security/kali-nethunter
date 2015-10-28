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
	# Symlink from /data/local/nhsystem/nano/nano to /system/etc/nano
	mkdir -p $DATA/nano
	cp -rf system/nano $DATA/nano/nano
	ln -s $DATA/nano/nano $SYSTEM/nano

	# Symlink from /data/local/nhsystem/nano/terminfo to /system/etc/terminfo
	mkdir -p $DATA/nano/terminfo
	cp -rf system/etc/terminfo $DATA/nano/terminfo
	ln -s $DATA/nano/terminfo $SYSTEM/terminfo

	# Symlink from /data/local/nhsystem/nano/xbin/nano to /system/xbin/nano
	mkdir -p $DATA/nano/xbin
	cp -f system/etc/xbin/nano $DATA/nano/xbin/nano
	chmod 755 $DATA/nano/xbin/nano
	ln -s $DATA/nano/xbin/nano /system/xbin/nano

	# Symlink from /data/local/nhsystem/nano/lib/libncurses.so to /system/lib/libncurses.so
	mkdir -p $DATA/nano/lib
	cp -f system/lib/libncurses.so $DATA/nano/lib/libncurses.so
	ln -s $DATA/nano/lib/libncurses.so /system/lib/libncurses.so
else
	echo "Previous version of nano detected. Skipping install"
fi