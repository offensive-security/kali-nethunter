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
	# Just to be safe lets remove old version of Nethunter app
	rm -rf /data/app/com.offsec.Nethunter
	rm -f /data/app/Nethunter.apk
	rm -f /data/app/nethunter.apk
fi