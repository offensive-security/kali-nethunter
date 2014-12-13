#
# created by @l0rdg3x
# modified by binkybear
#####################################################
# Create OnePlus One Stock Kernel (4.4+)
#####################################################
f_oneplus_kernel(){
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
  	cp -rf ${basepwd}/devices/frozen_kernels/4.4.4/one-bacon/* ${basedir}/flashkernel/
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
		if [[ -d ${basepwd}/devices/kernels/oneplus11 ]]; then
  		echo "Copying kernel to rootfs"
  		cp -rf ${basepwd}/devices/kernels/oneplus11 ${basedir}/kernel
		else
  		git clone https://github.com/binkybear/AK-OnePone.git -b cm-11.0-ak ${basedir}/devices/kernels/oneplus11
			cp -rf ${basepwd}/devices/kernels/oneplus11 ${basedir}/kernel
		fi
		cd ${basedir}/kernel
		chmod +x scripts/* ramdisk/4/mkbootimg ramdisk/4/dtbToolCM
		make clean
		sleep 10
		make kali_defconfig
		# Attach kernel builder to updater-script
		cp $basepwd/devices/updater-scripts/kitkat/bacon ${basedir}/flashkernel/META-INF/com/google/android/updater-script
		# Start kernel build
		f_kernel_build
		# Start boot.img creation
		cd ${basedir}/kernel
		echo "Creating dt.img"
		${basedir}/kernel/ramdisk/4/dtbToolCM -2 -o ${basedir}/flashkernel/kernel/dt.img -s 2048 -p ${basedir}/kernel/scripts/dtc/ ${basedir}/kernel/arch/arm/boot/
		sleep 3
		echo "Creating boot.img"
		${basedir}/kernel/ramdisk/4/mkbootimg --kernel arch/arm/boot/zImage --ramdisk ramdisk/4/initrd.img --cmdline "console=ttyHSL0,115200,n8 androidboot.hardware=bacon user_debug=31 msm_rtb.filter=0x3F ehci-hcd.park=3" --dt ../flashkernel/kernel/dt.img --output ../flashkernel/boot.img
		# Copy boot.img to flash folder if it exists
		if [ -d "${basedir}/flash/" ]; then
			cp ${basedir}/flashkernel/boot.img ${basedir}/flash/boot.img
		fi
	fi
}

#####################################################
# Create OnePlus One Kernel (5+)
#####################################################
f_oneplus_kernel5(){
	echo "Downloading Android Toolchian"
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
  	cp -rf ${basepwd}/devices/frozen_kernels/4.4.4/one-bacon/* ${basedir}/flashkernel/
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
		if [[ -d ${basepwd}/devices/kernels/oneplus12 ]]; then
  			echo "Copying kernel to rootfs"
  			cp -rf ${basepwd}/devices/kernels/oneplus12 ${basedir}/kernel
		else
  			git clone https://github.com/binkybear/furnace-bacon.git -b cm-12.0 ${basepwd}/devices/kernels/oneplus12
			cp -rf ${basepwd}/devices/kernels/oneplus12 ${basedir}/kernel
		fi
		cd ${basedir}/kernel
		chmod +x scripts/* ramdisk/5/mkbootimg ramdisk/5/dtbToolCM
		make clean
		sleep 10
		make kali_defconfig
		# Attach kernel builder to updater-script
		cp $basepwd/devices/updater-scripts/lollipop/bacon ${basedir}/flashkernel/META-INF/com/google/android/updater-script
		# Start kernel build
		f_kernel_build
		# Start boot.img creation
		cd ${basedir}/kernel
		echo "Creating dt.img"
		${basedir}/kernel/ramdisk/5/dtbToolCM -2 -o ${basedir}/flashkernel/kernel/dt.img -s 2048 -p ${basedir}/kernel/scripts/dtc/ ${basedir}/kernel/arch/arm/boot/
		sleep 3
		echo "Creating boot.img"
		${basedir}/kernel/ramdisk/5/mkbootimg --kernel arch/arm/boot/zImage --ramdisk ramdisk/5/initrd.img --cmdline "console=ttyHSL0,115200,n8 androidboot.hardware=bacon user_debug=31 msm_rtb.filter=0x3F ehci-hcd.park=3 androidboot.selinux=permissive" --dt ../flashkernel/kernel/dt.img --output ../flashkernel/boot.img
		# Copy boot.img to flash folder if it exists
		if [ -d "${basedir}/flash/" ]; then
			cp ${basedir}/flashkernel/boot.img ${basedir}/flash/boot.img
		fi
	fi
}
