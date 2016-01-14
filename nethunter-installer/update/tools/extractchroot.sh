#!/sbin/sh
# Install Kali chroot

TMP=/tmp/nethunter

source $TMP/env.sh

console="$(cat /tmp/console)"

print() {
	echo "ui_print - $1" > $console
}

NHSYS=/data/local/nhsystem
KALIFS=/data/local/kalifs-full.tar

# Make sure we are mounted
/sbin/busybox mount /data

# If file kalifs-full.tar.xz is present, then extract
if [ -f "$KALIFS.xz" ]; then
	print "Found chroot to be installed"
	# Remove previous chroot
	if [ -d "$NHSYS/kali-$ARCH" ]; then
		print "Removing previous chroot..."
		rm -rf $NHSYS/kali-armhf
	fi

	# Extract new chroot
	print "Extracting chroot..."
	mkdir -p $NHSYS
	/sbin/busybox xz -df $KALIFS.xz
	/tmp/busybox tar xf  -C $NHSYS
	rm -f $KALIFS
fi
