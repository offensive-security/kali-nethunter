#!/bin/bash
#####################################################
# Create Nexus 10 Kernel (4.4+)
#####################################################
f_nexus10_kernel(){
	echo "Downloading Android Toolchian"
	if [[ $LOCALGIT == 1 ]]; then
		echo "Copying toolchain to rootfs"
    cp -rf ${basepwd}/arm-eabi-4.7 ${basedir}/toolchain
	else
		git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.7 ${basedir}/toolchain
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
  	cp -rf ${basepwd}/devices/frozen_kernels/4.4.4/n10-manta/* ${basedir}/flashkernel/
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
		echo "Downloading Kernel"
		if [[ $LOCALGIT == 1 ]]; then
  		echo "Copying kernel to rootfs"
  		cp -rf ${basepwd}/kernel_samsung_manta ${basedir}/kernel
		else
  		git clone https://github.com/binkybear/kernel_samsung_manta.git -b thunderkat ${basedir}/kernel
		fi
		cd ${basedir}/kernel
		make clean
		sleep 10
		make kali_defconfig
		# Attach kernel builder to updater-script
		cp $basepwd/devices/updater-scripts/kitkat/manta ${basedir}/flashkernel/META-INF/com/google/android/updater-script
		f_kernel_build
	fi
}

#####################################################
# Create Nexus 10 Kernel (5)
#####################################################
f_nexus10_kernel5(){
	echo "Downloading Android Toolchian"
	if [[ $LOCALGIT == 1 ]]; then
		echo "Copying toolchain to rootfs"
    cp -rf ${basepwd}/arm-eabi-4.7 ${basedir}/toolchain
	else
		git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.7 ${basedir}/toolchain
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
  	cp -rf ${basepwd}/devices/frozen_kernels/5/n10-manta/* ${basedir}/flashkernel/
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
	echo "Downloading Kernel"
	if [[ $LOCALGIT == 1 ]]; then
  	echo "Copying kernel to rootfs"
  	cp -rf ${basepwd}/nexus10-5 ${basedir}/kernel
	else
  	git clone https://github.com/binkybear/nexus10-5.git -b android-exynos-manta-3.4-lollipop-release ${basedir}/kernel
	fi
	cd ${basedir}/kernel
	make clean
	sleep 10
	make kali_defconfig
	# Attach kernel builder to updater-script
	cp $basepwd/devices/updater-scripts/lollipop/manta ${basedir}/flashkernel/META-INF/com/google/android/updater-script
	f_kernel_build
	fi
}
