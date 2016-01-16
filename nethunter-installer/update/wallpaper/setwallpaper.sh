#!/sbin/sh
# Set the wallpaper based on device screen resolution

wp=/data/system/users/0/wallpaper

# Make sure we are mounted
mount /data

console="$(cat /tmp/console)"
[ -z "$console" ] && console=/dev/null

ui_print() {
	echo "ui_print - $1" > $console
}

res=`grep -o "<resolution.*/>" /twres/ui.xml`
[ -n "$res" ] && {
	res=`echo $res | awk -F'"' '{print $2"x"$4}'`
	ui_print "Found screen resolution: $res"
	[ -e "/tmp/nethunter/wallpaper/$res.png" ] && {
		chmod 777 $wp
		rm $wp
		cp "/tmp/nethunter/wallpaper/$res.png" $wp
		chmod 777 $wp
		chown system:system $wp
		ui_print "NetHunter wallpaper applied successfully"
	} || {
		ui_print "No wallpaper found for your screen resolution! Skipping..."
	}
}
