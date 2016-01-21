#!/sbin/sh
# Install Kali chroot

TMP=/tmp/nethunter

source $TMP/env.sh

console="$(cat /tmp/console)"
[ "$console" ] || console=/proc/$$/fd/1

print() {
	echo "ui_print - $1" > $console
	echo
}

# Make sure we are mounted
mount /data

NHSYS=/data/local/nhsystem
KALIFS="$(ls -1 $TMP/kalifs-*.tar.xz | head -1)"

# If kalifs-*.tar.xz is present, then extract
[ -f "$KALIFS" ] && {
	print "Found Kali chroot to be installed: $(basename $KALIFS)"
	mkdir -p "$NHSYS"

	# Remove previous chroot
	[ -d "$NHSYS/kali-$ARCH" ] && {
		print "Removing previous chroot..."
		rm -rf "$NHSYS/kali-$ARCH"
	}

	# Extract new chroot
	print "Extracting Kali rootfs, this may take a while..."
	tar -xJ -f "$KALIFS" -C "$NHSYS"
	print "Kali chroot installed"

	# We should remove the rootfs archive from /tmp to free up device memory
	rm -f $KALIFS
} || {
	print "No Kali rootfs archive found. Skipping..."
}
