#!/sbin/sh
# Install Kali chroot

NHSYS=/data/local/nhsystem
KALIFS=/data/local/kalifs-full.tar

# Make sure we are mounted
/sbin/busybox mount /data

# If file kalifs-full.tar.xz is present, then extract
if [ -f "$KALIFS.xz" ]; then
	echo "Found chroot to be installed"
	# Remove previous chroot
	if [ -d "$NHSYS/kali-armhf" ]; then
		echo "Removing previous chroot"
		rm -rf $NHSYS/kali-armhf
	fi

	# Extract new chroot
	echo "Extracting chroot..."
	mkdir -p $NHSYS
	/sbin/busybox xz -df $KALIFS.xz
	/tmp/busybox tar xf  -C $NHSYS
	rm -f $KALIFS
fi
