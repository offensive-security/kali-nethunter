#####################################################
# Create Nexus 5 Stock Kernel (4.4+)
#####################################################
f_hammerhead_stock_kernel(){
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
  	cp -rf ${basepwd}/devices/frozen_kernels/4.4.4/n5-hammerhead/* ${basedir}/flashkernel/
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
		if [[ -d ${basepwd}/devices/kernels/hammerhead-4 ]]; then
  		echo "Copying kernel to rootfs"
  		cp -rf ${basepwd}/devices/kernels/hammerhead-4 ${basedir}/kernel
		else
  		git clone https://github.com/binkybear/furnace_kernel_lge_hammerhead.git -b android-4.4 ${basepwd}/devices/kernels/hammerhead-4
			cp -rf ${basepwd}/devices/kernels/hammerhead-4 ${basedir}/kernel
		fi
		cd ${basedir}/kernel
		make clean
		sleep 10
		make kali_defconfig
		# Attach kernel builder to updater-script
		cp $basepwd/devices/updater-scripts/kitkat/hammerhead ${basedir}/flashkernel/META-INF/com/google/android/updater-script
		# Start kernel build
		f_kernel_build
	fi
}

#####################################################
# Create Nexus 5 Stock Kernel (5)
#####################################################
f_hammerhead_stock_kernel5(){
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
  	cp -rf ${basepwd}/devices/frozen_kernels/5/n5-hammerhead/* ${basedir}/flashkernel/
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
		if [[ -d ${basepwd}/devices/kernels/hammerhead-5 ]]; then
  		echo "Copying kernel to rootfs"
  		cp -rf ${basepwd}/devices/kernels/hammerhead-5 ${basedir}/kernel
		else
  		git clone https://github.com/binkybear/kernel_msm.git -b android-msm-hammerhead-3.4-lollipop-release ${basepwd}/devices/kernels/hammerhead-5
			cp -rf ${basepwd}/devices/kernels/hammerhead-5 ${basedir}/kernel
		fi
		cd ${basedir}/kernel
		chmod +x scripts/*
		make clean
		sleep 10
		make kali_defconfig
		# Attach kernel builder to updater-script
		cp $basepwd/devices/updater-scripts/lollipop/hammerhead ${basedir}/flashkernel/META-INF/com/google/android/updater-script
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
