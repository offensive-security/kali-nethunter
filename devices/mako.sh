#####################################################
# Create Nexus 4 Stock Kernel (4.4+)
#####################################################
f_mako_stock_kernel(){
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
  	cp -rf ${basepwd}/devices/frozen_kernels/4.4.4/n4-mako/* ${basedir}/flashkernel/
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
		if [[ -d ${basepwd}/devices/kernels/mako-4 ]]; then
  		echo "Copying kernel to rootfs"
  		cp -rf ${basepwd}/devices/kernels/mako-4 ${basedir}/kernel
		else
  		git clone https://github.com/binkybear/kernel_msm.git -b android-msm-mako-3.4-kitkat-mr2 ${basepwd}/devices/kernels/mako-4
			cp -rf ${basepwd}/devices/kernels/mako-4 ${basedir}/kernel
		fi
		cd ${basedir}/kernel
		unzip ramdisk/4.4.4/ramdisk_kitkat.zip -d ${basedir}/flashkernel/kernel/
		make clean
		sleep 10
		make kali_defconfig
		#make mako_defconfig #test default defconfig file
		# Attach kernel builder to updater-script
		cp $basepwd/devices/updater-scripts/kitkat/mako ${basedir}/flashkernel/META-INF/com/google/android/updater-script
		# Start kernel build
		f_kernel_build
		cd ${basedir}/flashkernel/kernel
		abootimg --create ${basedir}/flashkernel/boot.img -f bootimg.cfg -k ${basedir}/kernel/arch/arm/boot/zImage -r initrd.img
		cd ${basedir}
		f_zip_kernel_save
	fi
}

#####################################################
# Create Nexus 4 Kernel (5)
#####################################################
f_mako_cm_kernel(){
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
	f_kernel_build_init
	echo "Downloading Kernel"
	cd ${basedir}
	if [[ $LOCALGIT == 1 ]]; then
  	echo "Copying kernel to rootfs"
  	cp -rf ${basepwd}/Unleashed-Kernel-Series-CM ${basedir}/kernel
	else
  	git clone ##### ${basedir}/kernel
	fi
	cd ${basedir}/kernel
	make clean
	sleep 10
	make kali_defconfig
	# Custom installer for Nexus 4 modified from Unleased kernel
	cp -rf ${basedir}/kernel/AnyKernel/tmp/* ${basedir}/flashkernel/kernel/
	cp -rf ${basedir}/kernel/AnyKernel/system/* ${basedir}/flashkernel/system/
	# Attach kernel builder to updater-script
	cp $basepwd/devices/updater-scripts/lollipop/mako ${basedir}/flashkernel/META-INF/com/google/android/updater-script
	f_kernel_build
}
