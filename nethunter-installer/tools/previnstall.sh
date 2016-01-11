#!/sbin/sh
# Check for previous installation of Nethunter

NH=/data/local/kali-armhf
NHAPP=/data/data/com.offsec.nethunter/files/chroot/kali-armhf
NHSYS=/data/local/nhsystem/kali-armhf

# Make sure we are mounted
/tmp/busybox mount /data

# Fix for TWRP chasing symbolic links (mentioned by triryland)
rm -rf $NHSYS/dev/*
rm -rf $NHAPP/dev/*
rm -rf $NH/dev/*

# Check for previous Nethunter chroot
if [ -d $NH ]; then
	echo "Detected previous version of Nethunter, moving chroot"
	mv $NH $NHSYS
fi

if [ -d $NHAPP ]; then
	mv $NHAPP $NHSYS
fi

# Just to be safe lets remove old version of Nethunter app
rm -rf /data/data/com.offsec.nethunter
rm -rf /data/app/com.offsec.nethunter
rm -f /data/app/Nethunter.apk
rm -f /data/app/nethunter.apk

sleep 3
