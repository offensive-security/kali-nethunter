#!/sbin/sh
# Install Kali chroot

tmp=$(readlink -f "$0")
tmp=${tmp%/*/*}
. "$tmp/env.sh"

zip=$1

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
	return 0
}

# do_install [optional zip containing kalifs]
do_install() {
	print "Found Kali chroot to be installed: $KALIFS"

	mkdir -p "$NHSYS"

	# HACK 1/2: Rename to kali-armhf until NetHunter App supports searching for best available arch
	CHROOT="$NHSYS/kali-armhf"
	#CHROOT="$NHSYS/kali-$FS_ARCH"

	# Remove previous chroot
	[ -d "$CHROOT" ] && {
		print "Removing previous chroot..."
		rm -rf "$CHROOT"
	}

	# Extract new chroot
	print "Extracting Kali rootfs, this may take up to 25 minutes..."
	if [ "$1" ]; then
		unzip -p "$1" "$KALIFS" | busybox_nh tar -xJf - -C "$NHSYS" --exclude "kali-$FS_ARCH/dev"
	else
		busybox_nh tar -xJf "$KALIFS" -C "$NHSYS" --exclude "kali-$FS_ARCH/dev"
	fi

	[ $? = 0 ] || {
		print "Error: Kali $FS_ARCH $FS_SIZE chroot failed to install!"
		print "Maybe you ran out of space on your data partition?"
		exit 1
	}

	# HACK 2/2: Rename to kali-armhf until NetHunter App supports searching for best available arch
	mv "$NHSYS/kali-$FS_ARCH" "$CHROOT"

	mkdir -m 0755 "$CHROOT/dev"
	print "Kali $FS_ARCH $FS_SIZE chroot installed successfully!"

	# We should remove the rootfs archive to free up device memory or storage space (if not zip install)
	[ "$1" ] || rm -f "$KALIFS"

	exit 0
}

# Check zip for kalifs-* first
[ -f "$zip" ] && {
	KALIFS=$(unzip -lqq "$zip" | awk '$4 ~ /^kalifs-/ { print $4; exit }')
	# Check other locations if zip didn't contain a kalifs-*
	[ "$KALIFS" ] || return

	FS_ARCH=$(echo "$KALIFS" | awk -F[-.] '{print $2}')
	FS_SIZE=$(echo "$KALIFS" | awk -F[-.] '{print $3}')
	verify_fs && do_install "$zip"
}

# Check these locations in priority order
for fsdir in "$tmp" "/data/local" "/sdcard" "/external_sd"; do

	# Check location for kalifs-[arch]-[size].tar.xz name format
	for KALIFS in "$fsdir"/kalifs-*-*.tar.xz; do
		[ -s "$KALIFS" ] || continue
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
