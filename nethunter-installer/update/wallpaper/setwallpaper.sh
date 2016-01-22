#!/sbin/sh
# Set the wallpaper based on device screen resolution

bin=/tmp/nethunter/tools
wp=/data/system/users/0/wallpaper

# Make sure we are mounted
mount /system
mount /data

console="$(cat /tmp/console)"
[ "$console" ] || console=/proc/$$/fd/1

print() {
	echo "ui_print - $1" > $console
	echo
}

res=$($bin/screenres)
[ "$res" ] && {
	print "Found screen resolution: $res"
	[ -f "/tmp/nethunter/wallpaper/$res.png" ] && {
		chmod 777 $wp
		rm $wp
		cp "/tmp/nethunter/wallpaper/$res.png" $wp
		chmod 777 $wp
		chown system:system $wp
		print "NetHunter wallpaper applied successfully"
	} || {
		print "No wallpaper found for your screen resolution. Skipping..."
	}
} || {
	print "Can't get screen resolution from kernel! Skipping..."
}
