busybox=/data/local/bin/busybox

sleep 20

#########  EXPORT ######### 
#mount -o remount,rw -t yaffs2 /dev/block/mtdblock3 /system
export bin=/system/bin
export mnt=/data/local/kali-armhf
PRESERVED_PATH=$PATH
export PATH=/usr/bin:/usr/sbin:/bin:/usr/local/bin:/usr/local/sbin:$PATH
export TERM=linux
export TERMINFO=/etc/terminfo
export HOME=/root
export LOGNAME=root

#########  MOUNT ######### 

$busybox mount -o bind /system $mnt/system
$busybox mount -o bind /sdcard $mnt/sdcard
$busybox mount -o bind /dev $mnt/dev
$busybox mount -t devpts devpts $mnt/dev/pts
$busybox mount -t proc proc $mnt/proc
$busybox mount -t sysfs sysfs $mnt/sys
		
$busybox chmod 666 /dev/null

# SET 250MB TO ALLOW POSTGRESQL #
$busybox sysctl -w kernel.shmmax=268435456

# NETWORK SETTINGS #
$busybox sysctl -w net.ipv4.ip_forward=1
echo "nameserver 208.67.222.222" > $mnt/etc/resolv.conf
echo "nameserver 208.67.220.220" >> $mnt/etc/resolv.conf
echo "127.0.0.1 localhost" > $mnt/etc/hosts
echo "kali" > $mnt/proc/sys/kernel/hostname

# execute startup script

clear
$busybox chroot $mnt /bin/bash -l

chmod 755 /system/bin/bootkali
chmod 755 /system/bin/killkali