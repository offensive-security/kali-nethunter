#!/sbin/sh
# Install nano text editor

ETC=/system/etc
TMP=/tmp/nethunter

# Make sure we are mounted
/sbin/busybox mount /system

# Check for previous installation of nano
if [ ! -d "$NANODIR" ] || [ ! -f "$NANOBIN"]; then
	echo "@Installing nano"
	mkdir -p $ETC/terminfo
	mkdir -p $ETC/nano

	cp -f $TMP/system/lib/libncurses.so /system/lib/libncurses.so
	cp -rf $TMP$ETC/terminfo $ETC/terminfo
	cp -rf $TMP$ETC/nano $ETC/nano
	cp -rf $TMP/system/xbin/nano /system/xbin/nano

	chmod 755 /system/xbin/nano
else
	echo "Previous version of nano detected. Skipping install"
fi
