#!/sbin/sh
# Set the wallpaper based on device screen resolution

tmp=/tmp/nethunter
wp=/data/system/users/0/wallpaper

console=$(cat /tmp/console)
[ "$console" ] || console=/proc/$$/fd/1

print() {
	echo "ui_print - $1" > $console
	echo
}

res=$($tmp/tools/screenres)
[ "$res" ] && {
	print "Found screen resolution: $res"
	[ -f "$tmp/wallpaper/$res.png" ] && {
		res_w=$(echo "$res" | cut -f1 -dx)
		res_h=$(echo "$res" | cut -f2 -dx)
		rm -f $wp ${wp}_info.xml
		cp "$tmp/wallpaper/$res.png" $wp
		echo "<?xml version='1.0' encoding='utf-8' standalone='yes' ?>" > ${wp}_info.xml
		echo "<wp width=\"$res_w\" height=\"$res_h\" name=\"nethunter.png\" />" >> ${wp}_info.xml
		chmod 700 $wp
		chmod 600 ${wp}_info.xml
		chown system:system "$wp" "${wp}_info.xml"
		print "NetHunter wallpaper applied successfully"
	} || {
		print "No wallpaper found for your screen resolution. Skipping..."
	}
} || {
	print "Can't get screen resolution from kernel! Skipping..."
}
