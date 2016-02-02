#!/sbin/sh
# Install NetHunter's busybox

TMP=/tmp/nethunter

. $TMP/env.sh

console=$(cat /tmp/console)
[ "$console" ] || console=/proc/$$/fd/1

print() {
	echo "ui_print - $1" > $console
	echo
}

XBIN=/system/xbin

print "Installing busybox..."
rm -f $XBIN/busybox_nh
cp $TMP/tools/busybox $XBIN/busybox_nh
chmod 755 $XBIN/busybox_nh
$XBIN/busybox_nh --install -s $XBIN
