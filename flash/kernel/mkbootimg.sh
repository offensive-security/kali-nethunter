#!/sbin/sh
echo \#!/sbin/sh > /tmp/createnewboot.sh
echo /tmp/mkbootimg --kernel /tmp/kernel --ramdisk /tmp/boot.img-ramdisk.gz --base 0x$(cat /tmp/boot.img-base) --output /tmp/newboot.img >> /tmp/createnewboot.sh
chmod 777 /tmp/createnewboot.sh
/tmp/createnewboot.sh
return $?
