#!/sbin/sh
mkdir /tmp/ramdisk
cp /tmp/boot.img-ramdisk.gz /tmp/ramdisk/
cd /tmp/ramdisk/
gunzip -c /tmp/ramdisk/boot.img-ramdisk.gz | cpio -i
rm /tmp/ramdisk/boot.img-ramdisk.gz
rm /tmp/boot.img-ramdisk.gz

# Enable root on lollipop
if [ $(grep -c "seclabel u:r:install_recovery:s0" /tmp/ramdisk/init.rc) == 0 ]; then
   sed -i "s/seclabel u:r:install_recovery:s0/#seclabel u:r:install_recovery:s0/" /tmp/ramdisk/init.rc
fi

# Set selinux to permissive
if [ $(grep -c "setenforce 0" /tmp/ramdisk/init.rc) == 0 ]; then
   /tmp/busybox sed -i '/start ueventd/i \ \ \ \ setenforce 0' /tmp/ramdisk/init.rc
fi

# Enabled /etc/init.d
if  ! grep -qr init.d /tmp/ramdisk/*; then
   echo "" >> /tmp/ramdisk/init.rc
   echo "service userinit /data/local/bin/busybox run-parts /system/etc/init.d" >> /tmp/ramdisk/init.rc
   echo "    oneshot" >> /tmp/ramdisk/init.rc
   echo "    class late_start" >> /tmp/ramdisk/init.rc
   echo "    user root" >> /tmp/ramdisk/init.rc
   echo "    group root" >> /tmp/ramdisk/init.rc
fi

# Set location of TERMINFO for nano
if  ! grep -qr TERMINFO /tmp/ramdisk/*; then
	echo "    export TERMINFO /system/etc/terminfo"  >> /tmp/ramdisk/init.environ.rc
	echo "    export TERM linux"  >> /tmp/ramdisk/init.environ.rc
fi

find . | cpio -o -H newc | gzip > /tmp/boot.img-ramdisk.gz
rm -r /tmp/ramdisk