#!/sbin/sh
#
# clean the system
#
SA=/system/app
rm -f $SA/PrintSpooler.*
rm -f $SA/QuickOffice.apk
rm -f $SA/CloudPrint2.apk
rm -f $SA/Hangouts.apk
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

# * Fix for Cyanogenmod/terminal launching *
# We can pass a no-op ":"  in case resize is in a function. (CM12+ adds it inside function)

sed -i 's/resize/:/g' /system/etc/mkshrc
