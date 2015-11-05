#!/sbin/sh
#
# Check for previous installation of Nethunter
#
/tmp/busybox mount /data
/tmp/busybox mount /system

NH=/data/local/kali-armhf

# Check for previous Nethunter chroot
if [ -d "$NH" ]; then
	echo "Detected previous version of Nethunter, moving chroot"
	mv /data/local/kali-armhf /data/data/com.offsec.nethunter/files/chroot/kali-armhf
fi