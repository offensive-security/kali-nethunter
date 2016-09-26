#!/sbin/sh
# Install NetHunter's busybox

tmp=$(readlink -f "$0")
tmp=${tmp%/*/*}
. "$tmp/env.sh"

console=$(cat /tmp/console)
[ "$console" ] || console=/proc/$$/fd/1

print() {
	echo "ui_print - $1" > $console
	echo
}

xbin=/system/xbin

print "Installing busybox..."
rm -f $xbin/busybox_nh
cp "$tmp/tools/busybox" $xbin/busybox_nh
chmod 0755 $xbin/busybox_nh
$xbin/busybox_nh --install -s $xbin

[ -e $xbin/busybox ] || {
	print "$xbin/busybox not found! Symlinking..."
	ln -s $xbin/busybox_nh $xbin/busybox
}
