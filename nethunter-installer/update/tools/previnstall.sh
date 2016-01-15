#!/sbin/sh
# Check for previous installation of NetHunter

TMP=/tmp/nethunter

source $TMP/env.sh

console="$(cat /tmp/console)"

print() {
	echo "ui_print - $1" > $console
}

NH=/data/local/kali-$ARCH
NHAPP=/data/data/com.offsec.nethunter/files/chroot/kali-$ARCH
NHSYS=/data/local/nhsystem/kali-$ARCH

# Make sure we are mounted
/tmp/busybox mount /data

# Fix for TWRP chasing symbolic links (mentioned by triryland)
rm -rf $NHSYS/dev/*
rm -rf $NHAPP/dev/*
rm -rf $NH/dev/*

# Check for previous NetHunter chroot
if [ -d $NH ]; then
	print "Detected previous version of NetHunter, moving chroot"
	mv $NH $NHSYS
fi

if [ -d $NHAPP ]; then
	mv $NHAPP $NHSYS
fi

# Just to be safe lets remove old version of NetHunter app
rm -rf /data/data/com.offsec.nethunter
rm -rf /data/app/com.offsec.nethunter
rm -f /data/app/NetHunter.apk
rm -f /data/app/nethunter.apk

sleep 3
