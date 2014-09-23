#!/sbin/sh

mkdir /tmp/ramdisk
cp /tmp/boot.img-ramdisk.gz /tmp/ramdisk/
cd /tmp/ramdisk/
gunzip -c /tmp/ramdisk/boot.img-ramdisk.gz | cpio -i
rm /tmp/ramdisk/boot.img-ramdisk.gz
rm /tmp/boot.img-ramdisk.gz

if [ $(grep -c "mount tmpfs tmpfs /storage mode=0050,uid=0,gid=1028" /tmp/ramdisk/init.rc) == 0 ]; then
   sed -i "/mkdir \/mnt\/asec/i\ \ \ \ mount tmpfs tmpfs /storage mode=0050,uid=0,gid=1028" /tmp/ramdisk/init.rc
fi

if  ! grep -qr init.d /tmp/ramdisk/*; then
   echo "" >> /tmp/ramdisk/init.rc
   echo "service userinit /data/local/bin/busybox run-parts /system/etc/init.d" >> /tmp/ramdisk/init.rc
   echo "    oneshot" >> /tmp/ramdisk/init.rc
   echo "    class late_start" >> /tmp/ramdisk/init.rc
   echo "    user root" >> /tmp/ramdisk/init.rc
   echo "    group root" >> /tmp/ramdisk/init.rc
fi

if  ! grep -qr TERMINFO /tmp/ramdisk/*; then
	echo "    export TERMINFO /system/etc/terminfo"  >> /tmp/ramdisk/init.environ.rc
	echo "    export TERM linux"  >> /tmp/ramdisk/init.environ.rc
fi

find . | cpio -o -H newc | gzip > /tmp/boot.img-ramdisk.gz
rm -r /tmp/ramdisk

echo "console=ttyHSL0,115200,n8 androidboot.hardware=hammerhead user_debug=31 maxcpus=2 msm_watchdog_v2.enable=1" > /tmp/cmdline.cfg

echo \#!/sbin/sh > /tmp/createnewboot.sh
echo /tmp/mkbootimg --kernel /tmp/kernel --ramdisk /tmp/boot.img-ramdisk.gz --cmdline \"$(cat /tmp/cmdline.cfg)\" --base 0x$(cat /tmp/boot.img-base) --pagesize 2048 --ramdisk_offset 0x02900000 --tags_offset 0x02700000 --output /tmp/newboot.img >> /tmp/createnewboot.sh
chmod 777 /tmp/createnewboot.sh
/tmp/createnewboot.sh