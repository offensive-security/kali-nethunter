#!/sbin/sh
# Move safe apps from system to data partition to free up space for installation

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

SA=/system/app
DA=/data/app

UpdateFreeSpace() {
	FreeSpace=$(busybox df -m /system | awk '!/Used/ {print $4}')
}

UpdateFreeSpace

if [ "$FreeSpace" -gt "$SpaceRequired" ]; then
	exit 0
fi

for app in $MoveableApps; do
	UpdateFreeSpace
	if [ "$FreeSpace" -gt "$SpaceRequired" ]; then
		break
	fi
	if [ -d "$SA/$app/" ]; then
		if [ -d "$DA/$app/" ]; then
			print "Removing $SA/$app/ (extra)"
			rm -rf "$SA/$app/"
		else
			print "Moving $app/ to $DA"
			mv "$SA/$app/" "$DA/"
		fi
	fi
	if [ -f "$SA/$app.apk" ]; then
		if [ -d "$DA/$app.apk" ]; then
			print "Removing $SA/$app.apk (extra)"
			rm -f "$SA/$app.apk"
		else
			print "Moving $app.apk to $DA"
			mv "$SA/$app.apk" "$DA/"
		fi
	fi
done

if [ ! "$FreeSpace" -gt "$SpaceRequired" ]; then
	exit 1
fi

exit 0
