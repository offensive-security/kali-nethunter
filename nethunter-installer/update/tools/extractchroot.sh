#!/sbin/sh
# Install Kali chroot

TMP=/tmp/nethunter

source $TMP/env.sh

console="$(cat /tmp/console)"

print() {
	echo "ui_print - $1" > $console
}

NHSYS=/data/local/nhsystem
KALIFS=/data/local/kalifs-full.tar.xz

# Make sure we are mounted
mount /data

# If file kalifs-full.tar.xz is present, then extract
[ -f "$KALIFS" ] && {
	print "Found chroot to be installed"
	# Remove previous chroot
	[ -d "$NHSYS/kali-$ARCH" ] && {
		print "Removing previous chroot..."
		rm -rf $NHSYS/kali-armhf
	}

	# Extract new chroot
	print "Extracting chroot..."
	mkdir -p $NHSYS
	tar -C $NHSYS xJf $KALIFS
	rm -f $KALIFS
}
