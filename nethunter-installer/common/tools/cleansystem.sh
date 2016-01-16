#!/sbin/sh
# Clean the system from extra/uneeded apps

SA=/system/app

# Make sure we are mounted
mount /system

# Apks were located in /system/app folder previously
rm -f $SA/PrintSpooler.*
rm -f $SA/QuickOffice.apk
rm -f $SA/CloudPrint2.apk
rm -f $SA/HPPrintPlugin.apk
rm -f $SA/KoreanIME.apk
rm -f $SA/PlusOne.apk
rm -f $SA/PlayGames.apk
rm -f $SA/Drive.apk
rm -f $SA/Maps.apk
rm -f $SA/Magazines.apk
rm -f $SA/GooglePinyinIME.apk
rm -f $SA/Books.apk
rm -f $SA/Magazines.apk
rm -f $SA/Currents.apk
rm -f $SA/GoogleEars.apk
rm -f $SA/Keep.apk
rm -f $SA/FaceLock.apk

# Apks are located in folders now...can we move to /data?
rm -rf $SA/HoloSpiralWallpaper
rm -rf $SA/BasicDreams
rm -rf $SA/Drive
rm -rf $SA/Maps
rm -rf $SA/FaceLock
rm -rf $SA/Books
rm -rf $SA/Newsstand
rm -rf $SA/Street
rm -rf $SA/CloudPrint2
rm -rf $SA/PlayGames
rm -rf $SA/YouTube
rm -rf $SA/PlusOne
rm -rf $SA/PrintSpooler
rm -rf $SA/GoogleHindiIME
rm -rf $SA/GooglePinyinIME
rm -rf $SA/KoreanIME
#rm -rf $SA/LatinImeGoogle
rm -rf $SA/Music2
rm -rf $SA/iWnnIME
rm -rf $SA/Photos
rm -rf $SA/LiveWallpapersPicker
rm -rf $SA/PhaseBeam
rm -rf /system/priv-app/Hangouts
rm -rf /system/priv-app/Wallet
