#!/sbin/sh
# Check for install of busybox

TMP=/tmp/nethunter

. $TMP/env.sh

console=$(cat /tmp/console)
[ "$console" ] || console=/proc/$$/fd/1

print() {
	echo "ui_print - $1" > $console
	echo
}

XBIN=/system/xbin

[ -f $XBIN/busybox -o -f /system/bin/busybox ] && {
	print "Busybox binary detected. Skipping..."
} || {
	print "Installing busybox..."
	cp $TMP/tools/busybox $XBIN/busybox
	chmod 755 $XBIN/busybox
	$XBIN/busybox --install -s $XBIN
}

