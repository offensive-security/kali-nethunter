#!/bin/bash

# Check for root
if [[ $EUID -ne 0 ]]; then
	echo "Please run this as root"
	exit 1
fi

display_help() {
	echo "Usage: ./build.sh [arguments]..."
	echo
	echo "  -f, --full      build a rootfs with all the recommended packages"
	echo "  -m, --minimal   build a rootfs with only the most basic packages"
	echo "  -a, --arch      select a different architecture (default: armhf)"
	echo "                  possible options: armhf, arm64, i386, amd64"
	echo "  -h, --help      display this help message"
	echo
}

exit_help() {
	display_help
	echo "Error: $1"
	exit 1
}

# no arguments provided? show help
if [ $# -eq 0 ]; then
	display_help
	exit 0
fi

# process arguments
while [[ $# -gt 0 ]]; do
	arg=$1
	case $arg in
		-h|--help)
			display_help
			exit 0 ;;
		-f|--full)
			build_size=full
			;;
		-m|--minimal)
			build_size=minimal
			;;
		-a|--arch)
			case $2 in
				armhf|arm64|i386|amd64)
					build_arch=$2
					;;
				*)
					exit_help "Unknown architecture: $2"
					;;
			esac
			shift
			;;
		*)
			exit_help "Unknown argument: $arg"
			;;
	esac
	shift
done

[ "$build_size" ] || exit_help "Build size not specified!"

# set default architecture for most Android devices if not specified
[ "$build_arch" ] || build_arch=armhf

rootfs="kali-$build_arch"
build_output="output/kalifs-$build_arch-$build_size"

mkdir -p output

# Capture all output from here on in kalifs-*.log
exec &> >(tee -a "${build_output}.log")

echo "[+] Selected build size: $build_size"
echo "[+] Selected architecture: $build_arch"
sleep 1

# Dependency checks
dep_check() {
	build_deps="git-core gnupg flex bison gperf libesd0-dev build-essential binfmt-support
		zip curl libncurses5-dev zlib1g-dev libncurses5-dev gcc-multilib g++-multilib
		parted kpartx pixz qemu-user qemu-user-static abootimg cgpt vboot-kernel-utils
		vboot-utils bc lzma lzop xz-utils automake autoconf m4 dosfstools rsync u-boot-tools
		schedtool e2fsprogs device-tree-compiler ccache dos2unix debootstrap"

	for dep in $build_deps; do
		echo "[+] Checking for installed dependency: $dep"
		if ! dpkg-query -W --showformat='${Status}\n' "$dep" | grep -q "install ok installed"; then
			echo "[-] Missing dependency: $dep"
			echo "[+] Attempting to install...."
			apt-get -y install "$dep"
		fi
	done

	echo "[+] All done! Creating hidden file .dep_check so we don't have preform check again."
	touch .dep_check
}

# Run dependency check once (see above for dep check)
if [ ! -f ".dep_check" ]; then
	dep_check
else
	echo "[+] Dependency check previously conducted. To rerun remove file .dep_check"
fi

if [ -d "$rootfs" ]; then
	echo "Detected prebuilt chroot."
	echo
	read -rp "Would you like to create a new chroot? (Y/n): " createrootfs
	case $createrootfs in
	n*|N*)
		echo "Exiting"
		exit
		;;
	*)
		echo "Removing previous chroot"
		rm -rf "$rootfs"
		;;
	esac
else
	echo "Previous rootfs build not found. Ready to build."
	sleep 1
fi

if [ -f "${build_output}.tar.xz" ]; then
	echo "Detected previously created chroot output file: ${build_output}.tar.xz"
	echo
	read -rp "Would you like to create a new file? (Y/n): " createnewxz
	case $createnewxz in
	n*|N*)
		echo "Exiting"
		exit
		;;
	*)
		echo "Removing previous chroot"
		rm -f "${build_output}.tar.xz" "${build_output}.sha512sum"
		;;
	esac
fi

# Add packages you want installed here:

# MINIMAL PACKAGES
# usbutils and pciutils is needed for wifite (unsure why) and apt-transport-https for updates
pkg_minimal="openssh-server kali-defaults kali-archive-keyring
	apt-transport-https ntpdate usbutils pciutils"

# DEFAULT PACKAGES FULL INSTALL
pkg_full="kali-linux-nethunter mana-toolkit exploitdb lua-sql-sqlite3 msfpc
	exe2hexbat bettercap libapache2-mod-php7.0 libreadline6-dev
	libncurses5-dev libnewlib-arm-none-eabi binutils-arm-none-eabi
	gcc-arm-none-eabi autoconf libtool make gcc-6 g++-6
	libxml2-dev zlib1g-dev libncurses5-dev"

# ARCH SPECIFIC PACKAGES
pkg_minimal_armhf="abootimg cgpt fake-hwclock vboot-utils vboot-kernel-utils nethunter-utils"
pkg_minimal_arm64="$pkg_minimal_armhf"
pkg_minimal_i386="$pkg_minimal_armhf"
pkg_minimal_amd64="$pkg_minimal_armhf"

pkg_full_armhf=""
pkg_full_arm64=""
pkg_full_i386=""
pkg_full_amd64=""

# Set packages to install by arch and size
case $build_arch in
	armhf)
		qemu_arch=arm
		packages="$pkg_minimal $pkg_minimal_armhf"
		[ "$build_size" = full ] &&
			packages="$packages $pkg_full $pkg_full_armhf"
		;;
	arm64)
		qemu_arch=aarch64
		packages="$pkg_minimal $pkg_minimal_arm64"
		[ "$build_size" = full ] &&
			packages="$packages $pkg_full $pkg_full_arm64"
		;;
	i386)
		qemu_arch=i386
		packages="$pkg_minimal $pkg_minimal_i386"
		[ "$build_size" = full ] &&
			packages="$packages $pkg_full $pkg_full_i386"
		;;
	amd64)
		qemu_arch=x86_64
		packages="$pkg_minimal $pkg_minimal_amd64"
		[ "$build_size" = full ] &&
			packages="$packages $pkg_full $pkg_full_amd64"
		;;
esac

# Fix packages to be a single space delimited line using unquoted magic
packages=$(echo $packages)

cleanup_host() {
	umount -l "$rootfs/dev/pts" &>/dev/null
	umount -l "$rootfs/dev" &>/dev/null
	umount -l "$rootfs/proc" &>/dev/null
	umount -l "$rootfs/sys" &>/dev/null

	# Remove read only from nano
	chattr -i /bin/nano
}

chroot_do() {
	DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
	LC_ALL=C LANGUAGE=C LANG=C \
	chroot "$rootfs" "$@"
}

# It's dangerous to leave these mounted if user cleans git after using Ctrl+C
trap cleanup_host EXIT

# Need to find where this error occurs, but we make nano read
# only during build and reset after installation is completed
chattr +i /bin/nano

export build_arch build_size qemu_arch rootfs packages
export -f chroot_do

# Stage 1 - Debootstrap creates basic chroot
echo "[+] Starting stage 1 (debootstrap)"
. stages/stage1

# Stage 2 - Adds repo, bash_profile, hosts file
echo "[+] Starting stage 2 (repo/config)"
. stages/stage2

# Stage 3 - Downloads all packages, modify configuration files
echo "[+] Starting stage 3 (packages/installation)"
. stages/stage3

# Cleanup stage
echo "[+] Starting stage 4 (cleanup)"
. stages/stage4-cleanup

# Unmount and fix nano
cleanup_host

# Compress final file
echo "[+] Tarring and compressing kalifs.  This can take a while...."
XZ_OPTS=-9 tar cJvf "${build_output}.tar.xz" "$rootfs/"
echo "[+] Generating sha512sum of kalifs."
sha512sum "${build_output}.tar.xz" | sed "s|output/||" > "${build_output}.sha512sum"

echo "[+] Finished!  Check output folder for chroot."

# Extract on device
# xz -dc /sdcard/kalifs.tar.xz | tar xvf - -C /data/local/nhsystem
# or
# tar xJvf /sdcard/kalifs.tar.xz -C /data/local/nhsystem
