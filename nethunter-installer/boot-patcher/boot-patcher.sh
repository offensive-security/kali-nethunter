#!/sbin/sh
# Kali NetHunter boot image patcher script by jcadduono
# Based on AnyKernel2 by osm0sis

## start build generated variables
boot_block=
## end build generated variables

# set up extracted files and directories
tmp=/tmp/nethunter/boot-patcher
ramdisk=$tmp/ramdisk
split_img=$tmp/split-img
bin=$tmp/tools
boot_backup=/data/local/boot-backup.img

chmod -R 755 $bin
rm -rf $ramdisk $split_img
mkdir $ramdisk $split_img

console=$(cat /tmp/console)
[ "$console" ] || console=/proc/$$/fd/1

print() {
	[ "$1" ] && {
		echo "ui_print - $1" > $console
	} || {
		echo "ui_print  " > $console
	}
	echo
}

abort() {
	[ "$1" ] && {
		print "Error: $1!"
		print "Aborting..."
	}
	exit 1
}

## start install methods

# find the location of the boot block
find_boot() {
	verify_block() {
		boot_block=$(readlink -f "$boot_block")
		# if the boot block is a file, we must use dd
		if [ -f "$boot_block" ]; then
			use_dd=true
		# if the boot block is a block device, we use flash_image when possible
		elif [ -b "$boot_block" ]; then
			case "$boot_block" in
				/dev/block/bml*|/dev/block/mtd*|/dev/block/mmc*)
					use_dd=false ;;
				*)
					use_dd=true ;;
			esac
		# otherwise we have to keep trying other locations
		else
			return 1
		fi
		print "Found boot partition at: $boot_block"
	}
	# if we already have boot block set then verify and use it
	[ "$boot_block" ] && verify_block && return
	# otherwise, time to go hunting!
	[ -f /etc/recovery.fstab ] && {
		# recovery fstab v1
		boot_block=$(awk '$1 == "/boot" {print $3}' /etc/recovery.fstab)
		[ "$boot_block" ] && verify_block && return
		# recovery fstab v2
		boot_block=$(awk '$2 == "/boot" {print $1}' /etc/recovery.fstab)
		[ "$boot_block" ] && verify_block && return
		return 1
	} && return
	[ -f /fstab.qcom ] && {
		# qcom fstab
		boot_block=$(awk '$2 == "/boot" {print $1}' /fstab.qcom)
		[ "$boot_block" ] && verify_block && return
		return 1
	} && return
	[ -f /proc/emmc ] && {
		# emmc layout
		boot_block=$(awk '$4 == "\"boot\"" {print $1}' /proc/emmc)
		[ "$boot_block" ] && boot_block=/dev/block/$(echo "$boot_block" | cut -f1 -d:) && verify_block && return
		return 1
	} && return
	[ -f /proc/mtd ] && {
		# mtd layout
		boot_block=$(awk '$4 == "\"boot\"" {print $1}' /proc/mtd)
		[ "$boot_block" ] && boot_block=/dev/block/$(echo "$boot_block" | cut -f1 -d:) && verify_block && return
		return 1
	} && return
	[ -f /proc/dumchar_info ] && {
		# mtk layout
		boot_block=$(awk '$1 == "/boot" {print $5}' /proc/dumchar_info)
		[ "$boot_block" ] && verify_block && return
		return 1
	} && return
	abort "Unable to find boot block location"
}

# dump boot and unpack the android boot image
dump_boot() {
	print "Dumping & unpacking original boot image..."
	if $use_dd; then
		dd if="$boot_block" of="$tmp/boot.img"
	else
		dump_image "$boot_block" "$tmp/boot.img"
	fi
	[ $? = 0 ] || abort "Unable to read boot partition"
	$bin/unpackbootimg -i "$tmp/boot.img" -o "$split_img" || {
		abort "Unpacking boot image failed"
	}
}

# determine the format the ramdisk was compressed in
determine_ramdisk_format() {
	magicbytes=$(hexdump -vn2 -e '2/1 "%x"' $split_img/boot.img-ramdisk)
	case "$magicbytes" in
		425a) rdformat=bzip2; decompress=bzip2 ;; #compress="bzip2 -9c" ;;
		1f8b|1f9e) rdformat=gzip; decompress=gzip ;; #compress="gzip -9c" ;;
		0221) rdformat=lz4; decompress=$bin/lz4 ;; #compress="$bin/lz4 -9" ;;
		5d00) rdformat=lzma; decompress=lzma ;; #compress="lzma -c" ;;
		894c) rdformat=lzo; decompress=lzop ;; #compress="lzop -9c" ;;
		fd37) rdformat=xz; decompress=xz ;; #compress="xz --check=crc32 --lzma2=dict=2MiB" ;;
		*) abort "Unknown ramdisk compression format ($magicbytes)." ;;
	esac
	print "Detected ramdisk compression format: $rdformat"
	command -v "$decompress" || abort "Unable to find archiver for $rdformat"
}

# extract the old ramdisk contents
dump_ramdisk() {
	cd $ramdisk
	$decompress -d < $split_img/boot.img-ramdisk | cpio -i
	[ $? != 0 ] && abort "Unpacking ramdisk failed"
}

# execute all scripts in patch.d
patch_ramdisk() {
	print "Running ramdisk patching scripts..."
	find "$tmp/patch.d/" -type f | sort > "$tmp/patchfiles"
	while read -r patchfile; do
		print "Executing: $(basename "$patchfile")"
		env="$tmp/patch.d-env" sh "$patchfile" || {
			abort "Script failed: $(basename "$patchfile")"
		}
	done < "$tmp/patchfiles"
}

# build the new ramdisk
build_ramdisk() {
	print "Building new ramdisk..."
	cd $ramdisk
	find | cpio -o -H newc | gzip -9c > $tmp/ramdisk-new
}

# build the new boot image
build_boot() {
	cd $split_img
	kernel=
	for image in zImage zImage-dtb Image Image-dtb Image.gz Image.gz-dtb; do
		if [ -s $tmp/$image ]; then
			kernel="$tmp/$image"
			print "Found replacement kernel $image!"
			break
		fi
	done
	[ "$kernel" ] || kernel="$(ls ./*-zImage)"
	if [ -s $tmp/ramdisk-new ]; then
		rd="$tmp/ramdisk-new"
		print "Found replacement ramdisk image!"
	else
		rd="$(ls ./*-ramdisk)"
	fi
	if [ -s $tmp/dtb.img ]; then
		dtb="$tmp/dtb.img"
		print "Found replacement device tree image!"
	else
		dtb="$(ls ./*-dt)"
	fi
	$bin/mkbootimg \
		--kernel "$kernel" \
		--ramdisk "$rd" \
		--dt "$dtb" \
		--second "$(ls ./*-second)" \
		--cmdline "$(cat ./*-cmdline)" \
		--board "$(cat ./*-board)" \
		--base "$(cat ./*-base)" \
		--pagesize "$(cat ./*-pagesize)" \
		--kernel_offset "$(cat ./*-kernel_offset)" \
		--ramdisk_offset "$(cat ./*-ramdisk_offset)" \
		--second_offset "$(cat ./*-second_offset)" \
		--tags_offset "$(cat ./*-tags_offset)" \
		-o $tmp/boot-new.img || {
			abort "Repacking boot image failed"
		}
}

# backup old boot image
backup_boot() {
	print "Backing up original boot image to $boot_backup..."
	mkdir -p "$(dirname $boot_backup)"
	cp -f $tmp/boot.img $boot_backup
}

# write the new boot image to boot block
write_boot() {
	print "Writing new boot image to memory..."
	if $use_dd; then
		dd if="$tmp/boot-new.img" of="$boot_block"
	else
		flash_image "$boot_block" "$tmp/boot-new.img"
	fi
	[ $? = 0 ] || abort "Failed to write boot image! You may need to restore your boot partition"
}

## end install methods

. $tmp/env.sh

## start boot image patching

find_boot

dump_boot

determine_ramdisk_format

dump_ramdisk

patch_ramdisk

build_ramdisk

build_boot

backup_boot

write_boot

## end boot image patching
