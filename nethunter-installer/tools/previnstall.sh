#!/sbin/sh
#
# Check for previous installation of Nethunter
#
chmod 755 /tmp/busybox
/tmp/busybox mount /data
/tmp/busybox mount /system

# Fix for TWRP chasing symbolic links (mentioned by triryland)
rm -rf /data/local/nhsystem/kali-armhf/dev/*
rm -rf /data/data/com.offsec.nethunter/files/chroot/kali-armhf/dev/*
rm -rf /data/local/kali-armhf/dev/*

NH=/data/local/kali-armhf
NHAPP=/data/data/com.offsec.nethunter/files/chroot/kali-armhf

# Check for previous Nethunter chroot
if [ -d $NH ]; then
	echo "Detected previous version of Nethunter, moving chroot"
	mv $NH /data/local/nhsystem/kali-armhf
fi

if [ -d $NHAPP ]; then
	mv $NHAPP /data/local/nhsystem/kali-armhf
fi

# Just to be safe lets remove old version of Nethunter app
rm -rf /data/data/com.offsec.nethunter
rm -rf /data/app/com.offsec.nethunter
rm -f /data/app/Nethunter.apk
rm -f /data/app/nethunter.apk

sleep 3