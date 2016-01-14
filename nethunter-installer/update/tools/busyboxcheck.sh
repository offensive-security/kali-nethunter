#!/sbin/sh
# Check for install of busybox

TMP=/tmp/nethunter

source $TMP/env.sh

console="$(cat /tmp/console)"

print() {
	echo "ui_print - $1" > $console
}

XBIN=/system/xbin

# Make sure we are mounted
/sbin/busybox mount /system

if [ ! -f $XBIN/busybox ] || [ ! -f /system/bin/busybox ]; then
	print "Installing busybox..."
	cp $TMP/tools/busybox $XBIN/busybox
	chmod 755 $XBIN/busybox
	$XBIN/busybox --install -s $XBIN
else
	print "Busybox binary detected. Skipping..."
fi

