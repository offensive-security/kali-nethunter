#!/sbin/sh
# Move safe apps from system to data partition to free up space for installation

tmp=$(readlink -f "$0")
tmp=${tmp%/*/*}
. "$tmp/env.sh"

console=$(cat /tmp/console)
[ "$console" ] || console=/proc/$$/fd/1

print() {
	echo "ui_print - $1" > $console
	echo
}

# Free space we require on /system (in Megabytes)
SpaceRequired=50

MoveableApps="
QuickOffice
CloudPrint2
YouTube
PlusOne
PlayGames
Drive
Music2
Maps
Magazines
Newsstand
Currents
Photos
Books
Street
Hangouts
KoreanIME
GoogleHindiIME
GooglePinyinIME
iWnnIME
Keep
FaceLock
Wallet
HoloSpiralWallpaper
BasicDreams
PhaseBeam
LiveWallpapersPicker
"

IFS="
"

MNT=/system
SA=$MNT/app
DA=/data/app

UpdateFreeSpace() {
	FreeSpace=$(df -m "$MNT" | awk -vmnt="$MNT" '
		$6 == mnt { print $4; exit }
		$5 == mnt { print $3; exit }
	')
	# magical number checking hax
	[ "${FreeSpace##*[!0-9]*}" ] && return

	print "Warning: Could not get free space, continuing anyway!"
	exit 0
}

UpdateFreeSpace

if [ "$FreeSpace" -gt "$SpaceRequired" ]; then
	exit 0
fi

print "Free space (before): $FreeSpace MB"

for app in $MoveableApps; do
	UpdateFreeSpace
	if [ "$FreeSpace" -gt "$SpaceRequired" ]; then
		break
	fi
	if [ -d "$SA/$app/" ]; then
		if [ -d "$DA/$app/" ] || [ -f "$DA/$app.apk" ]; then
			print "Removing $SA/$app/ (extra)"
			rm -rf "$SA/$app/"
		else
			print "Moving $app/ to $DA"
			mv "$SA/$app/" "$DA/"
		fi
	fi
	if [ -f "$SA/$app.apk" ]; then
		if [ -d "$DA/$app/" ] || [ -f "$DA/$app.apk" ]; then
			print "Removing $SA/$app.apk (extra)"
			rm -f "$SA/$app.apk"
		else
			print "Moving $app.apk to $DA"
			mv "$SA/$app.apk" "$DA/"
		fi
	fi
done

print "Free space (after): $FreeSpace MB"

if [ ! "$FreeSpace" -gt "$SpaceRequired" ]; then
	print "Unable to free up $SpaceRequired MB of space on '$MNT'!"
	exit 1
fi

exit 0
