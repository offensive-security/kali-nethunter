#####################################################
# Create Nexus 7 Grouper Kernel (4.4+)
#####################################################
f_nexus7_grouper_kernel(){
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
  	cp -rf ${basepwd}/devices/frozen_kernels/4.4.4/n7-groupertilapia/* ${basedir}/flashkernel/
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
		# Kangaroo Kernel has y-cable support and kexec patch built in
		if [[ -d ${basepwd}/devices/kernels/groupertilapia-4 ]]; then
  		echo "Copying kernel to rootfs"
  		cp -rf ${basepwd}/devices/kernels/groupertilapia-4 ${basedir}/kernel
		else
  		git clone https://github.com/binkybear/kangaroo.git -b kangaroo ${basepwd}/devices/kernels/groupertilapia-4
			cp -rf ${basepwd}/devices/kernels/groupertilapia-4 ${basedir}/kernel
		fi
		cd ${basedir}/kernel
		make clean
		sleep 3
		make kali_defconfig
		# Attach kernel builder to updater-script
		cp $basepwd/devices/updater-scripts/kitkat/grouper-tilapia ${basedir}/flashkernel/META-INF/com/google/android/updater-script
		f_kernel_build
	fi
}
