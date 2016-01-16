#!/sbin/sh
# Check for previous install of Kali Chroot

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

# We probably don't want two old chroots in the same folder, so pick newer location in /data/local first
[ -d $NH ] && {
	print "Detected previous install of Kali, moving chroot..."
	mv $NH $NHSYS
} || {
	[ -d $NHAPP ] && {
		print "Detected previous install of Kali, moving chroot..."
		mv $NHAPP $NHSYS
	}
}

# Just to be safe lets remove old version of NetHunter app
rm -rf /data/data/com.offsec.nethunter
rm -rf /data/app/com.offsec.nethunter
rm -f /data/app/NetHunter.apk
rm -f /data/app/nethunter.apk

sleep 3
