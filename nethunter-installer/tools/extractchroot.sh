#!/sbin/sh
# Install Kali chroot

# Make sure we are mounted
/sbin/busybox mount /data

# If file kalifs-full.tar.xz is present, then extract
if [ -f "/data/local/kalifs-full.tar.xz" ]; then
	echo "Found chroot to be installed"
	# Remove previous chroot
	if [ -d "/data/local/nhsystem/kali-armhf" ]; then
		echo "Removing previous chroot"
		rm -rf /data/local/nhsystem/kali-armhf
	fi

	# Extract new chroot
	echo "Extracting chroot..."
	/sbin/busybox xz -df /data/local/kalifs-full.tar.xz
	mkdir -p /data/local/nhsystem
	/tmp/busybox tar xf /data/local/kalifs-full.tar -C /data/local/nhsystem
	rm -f /data/local/kalifs-full.tar
fi
