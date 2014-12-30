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

# * Fix for Cyanogenmod *
# Busybox or selinux does not like the resize command when launching
# the terminal with Kali Launcher.  Comment out of mkshrc

sed -i 's/resize/#resize/g' /system/etc/mkshrc
#rm -f /system/xbin/resize