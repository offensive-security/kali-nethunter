#!/sbin/sh
# Set the wallpaper based on device screen resolution

tmp=$(readlink -f "$0")
tmp=${tmp%/*/*}
cd "$tmp"
. env.sh

wp=/data/system/users/0/wallpaper
wpinfo=${wp}_info.xml

console=$(cat /tmp/console)
[ "$console" ] || console=/proc/$$/fd/1

print() {
	echo "ui_print - $1" > "$console"
	echo
}

res=$(tools/screenres)

if [ ! "$res" ]; then
	print "Can't get screen resolution from kernel! Skipping..."
	exit 1
fi

print "Found screen resolution: $res"

if [ ! -f "wallpaper/$res.png" ]; then
	print "No wallpaper found for your screen resolution. Skipping..."
	exit 1
fi

res_w=$(echo "$res" | cut -f1 -dx)
res_h=$(echo "$res" | cut -f2 -dx)

[ -f "$wp" ] && [ -f "$wpinfo" ] || setup_wp=1

cat "wallpaper/$res.png" > "$wp"

echo "<?xml version='1.0' encoding='utf-8' standalone='yes' ?>" > "$wpinfo"
echo "<wp width=\"$res_w\" height=\"$res_h\" name=\"nethunter.png\" />" >> "$wpinfo"

if [ "$setup_wp" ]; then
	chown system:system "$wp" "$wpinfo"
	chmod 600 "$wp" "$wpinfo"
	chcon "u:object_r:wallpaper_file:s0" "$wp"
	chcon "u:object_r:system_data_file:s0" "$wpinfo"
fi

print "NetHunter wallpaper applied successfully"

exit 0
