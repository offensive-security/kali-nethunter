#!/sbin/sh
# Install Kali chroot

TMP=/tmp/nethunter

. $TMP/env.sh

console=$(cat /tmp/console)
[ "$console" ] || console=/proc/$$/fd/1

print() {
	echo "ui_print - $1" > $console
	echo
}

NHSYS=/data/local/nhsystem
CHROOT=$NHSYS/kali-$ARCH

# Check installer for kalifs archive
KALIFS=$(ls $TMP/kalifs-*.tar.xz)
# If not found, check /data/local instead
[ -f "$KALIFS" ] || KALIFS=$(ls /data/local/kalifs-*.tar.xz)

# If kalifs-*.tar.xz is present, then extract
[ -f "$KALIFS" ] && {
	print "Found Kali chroot to be installed: $KALIFS"
	mkdir -p "$NHSYS"

	# Remove previous chroot
	[ -d "$CHROOT" ] && {
		print "Removing previous chroot..."
		rm -rf "$CHROOT"
	}

	# Extract new chroot
	print "Extracting Kali rootfs, this may take up to 25 minutes..."
	busybox_nh tar -xJf "$KALIFS" -C "$NHSYS" --exclude "kali-$ARCH/dev" && {
		mkdir -pm 0755 "$CHROOT/dev"
		print "Kali chroot installed successfully!"
	} || {
		print "Error: Kali chroot failed to install!"
		print "Maybe you ran out of space on your data partition?"
	}

	# We should remove the rootfs archive to free up device memory or storage space
	rm -f "$KALIFS"
} || {
	print "No Kali rootfs archive found. Skipping..."
}
