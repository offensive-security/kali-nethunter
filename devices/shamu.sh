f_nexus6_kernel5(){
	echo "Downloading Android Toolchain"
	if [[ -d ${basepwd}/toolchains/toolchain32 ]]; then
		echo "Copying toolchain to rootfs"
		cp -rf ${basepwd}/toolchains/toolchain32 ${basedir}/toolchain
	else
		git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.7 ${basepwd}/toolchains/toolchain32
		cp -rf ${basepwd}/toolchains/toolchain32 ${basedir}/toolchain
	fi
	echo "Setting export paths"
	# Set path for Kernel building
	export ARCH=arm
	export SUBARCH=arm
	export CROSS_COMPILE=${basedir}/toolchain/bin/arm-eabi-
	if [[ $FROZENKERNEL == 1 ]]; then
		echo "Using frozen kernel"
 		cp -rf ${basepwd}/flash/ ${basedir}/flashkernel
		rm -rf ${basedir}/flashkernel/data ${basedir}/flashkernel/sdcard ${basedir}/flashkernel/system/app ${basedir}/flashkernel/META-INF/com/google/android/updater-script
  	cp -rf ${basepwd}/devices/frozen_kernels/5/n6-shamu/* ${basedir}/flashkernel/
  	if [ -f "${basedir}/flash/META-INF/com/google/android/updater-script" ]; then
	  	if grep -Fxq "#KERNEL_SCRIPT_START" "${basedir}/flash/META-INF/com/google/android/updater-script"; then
	    	echo "Kernel already added to main updater-script"
	  	else
	    	echo "Adding Kernel install to updater-script in main update.zip"
	    	cat ${basedir}/flashkernel/META-INF/com/google/android/updater-script >> ${basedir}/flash/META-INF/com/google/android/updater-script
	    	cp -f ${basedir}/flashkernel/kernel/kernel ${basedir}/flash/kernel/kernel
	  	fi
		fi
	else
		f_kernel_build_init
		cd ${basedir}
		echo "Downloading Kernel"
		if [[ -d ${basepwd}/devices/kernels/shamu-5 ]]; then
  		echo "Copying kernel to rootfs"
  		cp -rf ${basepwd}/devices/kernels/shamu-5 ${basedir}/kernel
		else
  		git clone https://github.com/binkybear/kernel_msm.git -b android-msm-shamu-3.10-lollipop-release ${basepwd}/devices/kernels/shamu-5
			cp -rf ${basepwd}/devices/kernels/shamu-5 ${basedir}/kernel
		fi
		cd ${basedir}/kernel
		chmod +x scripts/*
		make clean
		sleep 10
		make kali_defconfig
		# Attach kernel builder to updater-script
		cp $basepwd/devices/updater-scripts/lollipop/shamu ${basedir}/flashkernel/META-INF/com/google/android/updater-script
		f_kernel_build
		cd ${basedir}/flashkernel/kernel
		abootimg --create ${basedir}/flashkernel/boot.img -f ${basedir}/kernel/ramdisk/5/bootimg.cfg -k ${basedir}/kernel/arch/arm/boot/zImage-dtb -r ${basedir}/kernel/ramdisk/5/initrd.img
		cd ${basedir}
		if [ -d "${basedir}/flash/" ]; then
			cp ${basedir}/flashkernel/boot.img ${basedir}/flash/boot.img
		fi
		f_zip_kernel_save
	fi
}
