#!/sbin/sh
#
# Set the wallpaper based on device screen resolution
#

wp=/data/system/users/0/wallpaper

console=`ps | awk '$5~/update/{print "/proc/"$1"/fd/"$(NF-1)}'`

ui_print() {
	echo "ui_print - $1" > $console
}

res=`grep -o "<resolution.*/>" /twres/ui.xml`
[ -n "$res" ] && {
	res=`echo $res | awk -F'"' '{print $2"x"$4}'`
	ui_print "Found screen resolution: $res"
	[ -e "/tmp/wallpaper/$res.png" ] && {
		chmod 777 $wp
		rm $wp
		cp "/tmp/wallpaper/$res.png" $wp
		chmod 777 $wp
		chown system:system $wp
		ui_print "Nethunter wallpaper applied successfully"
	} || {
		ui_print "No wallpaper found for your screen resolution! Skipping..."
	}
}

# ALL OTHER DEVICES
#dumpsys window displays | /tmp/busybox/grep/grep init  
#dumpsys window | /tmp/busybox grep -i "Unrestricted"
