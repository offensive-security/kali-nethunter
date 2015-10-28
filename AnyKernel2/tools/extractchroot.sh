#!/sbin/sh
# Install Kali chroot

# Make sure we are mounted
/sbin/busybox mount /data

if [ -d "/data/local/kali-armhf" ]; then
	rm -rf /data/local/kali-armhf
fi

/sbin/busybox xz -df data/local/kalifs-full.tar.xz
/sbin/busybox tar xf data/local/kalifs-full.tar -C /data/local