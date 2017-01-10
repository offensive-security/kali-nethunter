#!/sbin/sh
# Check for previous install of Kali Chroot

tmp=$(readlink -f "$0")
tmp=${tmp%/*/*}
. "$tmp/env.sh"

# HACK: Old installations only exist as armhf anyways
ARCH=armhf

console=$(cat /tmp/console)
[ "$console" ] || console=/proc/$$/fd/1

print() {
	echo "ui_print - $1" > $console
	echo
}

NH=/data/local/kali-$ARCH
NHAPP=/data/data/com.offsec.nethunter/files/chroot/kali-$ARCH
NHSYS=/data/local/nhsystem/kali-$ARCH

# Fix for TWRP chasing symbolic links (mentioned by triryland)
rm -rf "$NHSYS/dev/"* "$NHAPP/dev/"* "$NH/dev/"*

# We probably don't want two old chroots in the same folder, so pick newer location in /data/local first
if [ -d "$NH" ]; then
	print "Detected previous install of Kali $ARCH, moving chroot..."
	mv "$NH" "$NHSYS"
elif [ -d "$NHAPP" ]; then
	print "Detected previous install of Kali $ARCH, moving chroot..."
	mv "$NHAPP" "$NHSYS"
fi

# Just to be safe lets remove old version of NetHunter app
rm -rf /data/data/com.offsec.nethunter
rm -rf /data/app/com.offsec.nethunter
rm -f /data/app/NetHunter.apk
rm -f /data/app/nethunter.apk

sleep 3
