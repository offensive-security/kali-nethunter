f_nexus9_kernel5(){
	echo "Downloading Android Toolchain"
	if [[ -d ${basepwd}/toolchains/toolchain64 ]]; then
		echo "Copying toolchain to rootfs"
		cp -rf ${basepwd}/toolchains/toolchain64 ${basedir}/toolchain64
	else
		git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 -b lollipop-release ${basepwd}/toolchains/toolchain64
		cp -rf ${basepwd}/toolchains/toolchain64 ${basedir}/toolchain64
	fi
	echo "Setting export paths"
	# Set path for Kernel building
	export ARCH=arm64
	export SUBARCH=arm
	export CROSS_COMPILE=${basedir}/toolchain64/bin/aarch64-linux-android-
	if [[ $FROZENKERNEL == 1 ]]; then
  	echo "Using frozen kernel"
  	cp -rf ${basepwd}/flash/ ${basedir}/flashkernel
  	rm -rf ${basedir}/flashkernel/data ${basedir}/flashkernel/sdcard ${basedir}/flashkernel/system/app ${basedir}/flashkernel/META-INF/com/google/android/updater-script
  	cp -rf ${basepwd}/devices/frozen_kernels/5/n9-flounder/* ${basedir}/flashkernel/
  	if [ -f "${basedir}/flash/META-INF/com/google/android/updater-script" ]; then
    	if grep -Fxq "#KERNEL_SCRIPT_START" "${basedir}/flash/META-INF/com/google/android/updater-script"; then
      	echo "Kernel already added to main updater-script"
    	else
      	echo "Adding Kernel install to updater-script in main update.zip"
      	cat ${basedir}/flashkernel/META-INF/com/google/android/updater-script >> ${basedir}/flash/META-INF/com/google/android/updater-script
      	cp -f ${basedir}/flashkernel/kernel/kernel ${basedir}/flash/kernel/kernel
    	fi
  	fi
		if [ -d "${basedir}/flash" ]; then
    	echo "Found flash folder, copying kernel"
    	cp -f ${basedir}/flashkernel/kernel/kernel ${basedir}/flash/kernel/kernel
  	fi
  else
  	f_kernel_build_init
  	echo "Downloading Kernel"
  	cd ${basedir}
  	if [[ -d ${basepwd}/devices/kernels/flounder-5 ]]; then
    	echo "Copying kernel to rootfs"
    	cp -rf ${basepwd}/devices/kernels/flounder-5 ${basedir}/kernel
  	else
    	git clone https://github.com/binkybear/flounder.git -b android-tegra-flounder-3.10-lollipop-release ${basepwd}/devices/kernels/flounder-5
			cp -rf ${basepwd}/devices/kernels/flounder-5 ${basedir}/kernel
  	fi
		cd ${basedir}/kernel
		chmod +x scripts/*
		chmod +x arch/arm64/kernel/vdso/*.sh
		make clean
		sleep 10
		make kali_defconfig
		# Attach kernel builder to updater-script
		cp $basepwd/devices/updater-scripts/lollipop/flounder ${basedir}/flashkernel/META-INF/com/google/android/updater-script
		f_kernel_build
		cd ${basedir}/flashkernel/kernel
		abootimg --create ${basedir}/flashkernel/boot.img -f ${basedir}/kernel/ramdisk/5/bootimg.cfg -k ${basedir}/kernel/arch/arm64/boot/Image.gz-dtb -r ${basedir}/kernel/ramdisk/5/initrd.img
		cd ${basedir}
		if [ -d "${basedir}/flash/" ]; then
  		cp ${basedir}/flashkernel/boot.img ${basedir}/flash/boot.img
		fi
		f_zip_kernel_save
	fi
}
