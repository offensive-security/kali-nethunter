#!/sbin/sh
# Kali Nethunter boot image patcher script by jcadduono
# Based on AnyKernel2 by osm0sis

## start build generated variables
boot_block=
## end build generated variables

# set up extracted files and directories
tmpdir=/tmp/nethunter/boot-patcher
ramdisk=$tmpdir/ramdisk
ramdisk_patch=$ramdisk-patch
split_img=$tmpdir/split-img
bin=$tmpdir/tools
boot_backup=/data/local/boot.img-backup

chmod -R 755 $bin
rm -rf $ramdisk $split_img
mkdir $ramdisk $split_img

console="$(cat /tmp/console)"
[ -z "$console" ] && console=/dev/null

print() {
	echo "ui_print - $1" > $console
}

abort() {
	[ -n "$1" ] && {
		print "Error: $1"
		print "Aborting..."
	}
	echo 1 > $tmpdir/exitcode
	exit
}

## start patch methods

# replace_line <file> <line match pattern> <replacement line>
replace_line() {
	sed -i "s/\s*$2\s*$/$3/" $1
}

# insert_after_last <file> <line match pattern> <inserted line>
insert_after_last() {
	[ -z "$(grep "^$3$" $1)" ] && {
		line=$(($(grep -n "^\s*$2\s*$" $1 | tail -1 | cut -d: -f1) + 1))
		sed -i "${line}i$3" $1
	}
}

## end patch methods

## start install methods

# dump boot and extract ramdisk
dump_boot() {
	print "Dumping & unpacking original boot image..."
	dd if=$boot_block of=$tmpdir/boot.img
	$bin/unpackbootimg -i $tmpdir/boot.img -o $split_img
	[ $? != 0 ] && abort "Dumping/unpacking boot image failed"
}

# determine the format the ramdisk was compressed in
determine_ramdisk_format() {
	magicbytes="$(hexdump -vn2 -e '2/1 "%x"' $split_img/boot.img-ramdisk.gz)"
	case "$magicbytes" in
		425a) rdformat="bzip2"; compress="bzip2 -9c"; decompress="bzip2 -dc" ;;
		1f8b|1f9e) rdformat="gzip"; compress="gzip -9c"; decompress="gzip -dc" ;;
		0221) rdformat="lz4"; compress="lz4 -9"; decompress="lz4 -d" ;;
		5d00) rdformat="lzma"; compress="lzma -c"; decompress="lzma -dc" ;;
		894c) rdformat="lzo"; compress="lzop -9c"; decompress="lzop -dc" ;;
		fd37)
			#compress="xz --check=crc32 --lzma2=dict=2MiB"
			rdformat="xz"; compress="gzip -9c"; decompress="xz -d"
			print "Warning: xz-crc compression isn't supported by busybox, using gzip instead!"
			;;
		*) abort "Unknown ramdisk compression format ($magicbytes)." ;;
	esac
	print "Detected ramdisk compression format: $rdformat"
	command -v $decompress >/dev/null 2>&1 || abort "Unable to find archiver for $rdformat"
}

# extract the old ramdisk contents
dump_ramdisk() {
	determine_ramdisk_format
	cd $ramdisk
	$decompress < $split_img/boot.img-ramdisk.gz | cpio -i
	[ $? != 0 ] && abort "Dumping/unpacking ramdisk failed"
}

# patch the ramdisk
patch_ramdisk() {
	print "Patching the ramdisk..."
	cd $ramdisk
	# fix permissions of patch files
	chmod -R 0755 $ramdisk_patch
	chmod 0644 $ramdisk_patch/sbin/media_profiles.xml
	# move the patch files into the ramdisk
	cp -rTd $ramdisk_patch .
	# make sure adb is not secure
	replace_line default.prop "ro.adb.secure=1" "ro.adb.secure=0"
	replace_line default.prop "ro.secure=1" "ro.secure=0"
	# import nethunter and superuser init to init.rc
	insert_after_last init.rc "import /init\\..*\\.rc" "import /init.nethunter.rc"
	insert_after_last init.rc "import /init\\..*\\.rc" "import /init.superuser.rc"
	# patch sepolicy for SuperSU
	print "Patching the sepolicy for SuperSU..."
	LD_LIBRARY_PATH=$LIBDIR /system/bin/supolicy --file $ramdisk/sepolicy $ramdisk/sepolicy_new
	[ -f $ramdisk/sepolicy_new ] && {
		rm $ramdisk/sepolicy
		mv $ramdisk/sepolicy_new $ramdisk/sepolicy
		chmod 0644 $ramdisk/sepolicy
	} || {
		print "Unable to patch the sepolicy, continuing..."
	}
}

# build the new ramdisk
build_ramdisk() {
	print "Building new ramdisk..."
	cd $ramdisk
	find | cpio -o -H newc | $compress > $tmpdir/ramdisk-new.cpio.gz
}

# backup old boot image
backup_boot() {
	print "Backing up old boot image to $boot_backup..."
	mkdir -p $(dirname $boot_backup)
	cp -f $tmpdir/boot.img $boot_backup
}

# build and write the new boot image
write_boot() {
	cd $split_img
	cmdline=`cat *-cmdline`
	board=`cat *-board`
	base=`cat *-base`
	pagesize=`cat *-pagesize`
	kerneloff=`cat *-kerneloff`
	ramdiskoff=`cat *-ramdiskoff`
	tagsoff=`cat *-tagsoff`
	[ -f *-second ] && {
		second=`ls *-second`
		second="--second $split_img/$second"
		secondoff=`cat *-secondoff`
		secondoff="--second_offset $secondoff"
	}
	if [ -f $tmpdir/zImage ]; then
		kernel=$tmpdir/zImage
	else
		kernel=`ls *-zImage`
		kernel=$split_img/$kernel
	fi
	if [ -f $tmpdir/dtb ]; then
		dtb="--dt $tmpdir/dtb"
	elif [ -f *-dtb ]; then
		dtb=`ls *-dtb`
		dtb="--dt $split_img/$dtb"
	fi
	$bin/mkbootimg --kernel $kernel --ramdisk $tmpdir/ramdisk-new.cpio.gz $second \
		--cmdline "$cmdline" --board "$board" \
		--base $base --pagesize $pagesize \
		--kernel_offset $kerneloff --ramdisk_offset $ramdiskoff $secondoff \
		--tags_offset $tagsoff $dtb --output $tmpdir/boot-new.img
	[ $? != 0 -o `wc -c < $tmpdir/boot-new.img` -gt `wc -c < $tmpdir/boot.img` ] && {
		abort "Repacking image failed"
	}
	backup_boot
	print "Writing new boot image to memory..."
	dd if=$tmpdir/boot-new.img of=$boot_block
}

## end install methods

source $tmpdir/env.sh

## start boot image patching

dump_boot

dump_ramdisk

patch_ramdisk

build_ramdisk

write_boot

## end boot image patching
