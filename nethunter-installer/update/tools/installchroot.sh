#!/sbin/sh
# Install Kali chroot

tmp=$(readlink -f "$0")
tmp=${tmp%/*/*}
. "$tmp/env.sh"

console=$(cat /tmp/console)
[ "$console" ] || console=/proc/$$/fd/1

print() {
	echo "ui_print - $1" > $console
	echo
}

NHSYS=/data/local/nhsystem

verify_fs() {
	# valid architecture?
	case $FS_ARCH in
		armhf|arm64|i386|amd64) ;;
		*) return 1 ;;
	esac
	# valid build size?
	case $FS_SIZE in
		full|minimal) ;;
		*) return 1 ;;
	esac
	# actually exists as non-zero-size file?
	[ -s "$KALIFS" ] || return 1

	return 0
}

do_install() {
	print "Found Kali chroot to be installed: $KALIFS"

	mkdir -p "$NHSYS"

	CHROOT="$NHSYS/kali-$FS_ARCH"

	# Remove previous chroot
	[ -d "$CHROOT" ] && {
		print "Removing previous chroot..."
		rm -rf "$CHROOT"
	}

	# Extract new chroot
	print "Extracting Kali rootfs, this may take up to 25 minutes..."
	if busybox_nh tar -xJf "$KALIFS" -C "$NHSYS" --exclude "kali-$FS_ARCH/dev"; then
		mkdir -p "$CHROOT/dev"
		chmod 0755 "$CHROOT/dev"
		print "Kali $FS_ARCH $FS_SIZE chroot installed successfully!"

		# We should remove the rootfs archive to free up device memory or storage space
		rm -f "$KALIFS"

		exit 0
	fi

	print "Error: Kali $FS_ARCH $FS_SIZE chroot failed to install!"
	print "Maybe you ran out of space on your data partition?"

	# Only remove the rootfs if it's using up tmpfs space (included in the installer zip)
	case $KALIFS in
		/tmp/*) rm -f "$KALIFS" ;;
	esac

	exit 1
}

# Check these locations in priority order
for fsdir in "$tmp" "/data/local" "/sdcard" "/external_sd"; do

	# Check location for kalifs-[arch]-[size].tar.xz name format
	for KALIFS in "$fsdir"/kalifs-*-*.tar.xz; do
		[ -f "$KALIFS" ] || continue
		FS_ARCH=$(basename "$KALIFS" | awk -F[-.] '{print $2}')
		FS_SIZE=$(basename "$KALIFS" | awk -F[-.] '{print $3}')
		verify_fs && do_install
	done

	# Check location for kalifs-[size].tar.xz name format
	for KALIFS in "$fsdir"/kalifs-*.tar.xz; do
		[ -f "$KALIFS" ] || continue
		FS_ARCH=armhf
		FS_SIZE=$(basename "$KALIFS" | awk -F[-.] '{print $2}')
		verify_fs && do_install
	done

done

print "No Kali rootfs archive found. Skipping..."
exit 0
