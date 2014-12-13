#####################################################
# Create Nexus 7 (2013) FLO/DEB Stock Kernel (4.4+)
#####################################################
f_deb_stock_kernel(){
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
  	cp -rf ${basepwd}/devices/frozen_kernels/4.4.4/n7-flodeb/* ${basedir}/flashkernel/
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
		if [[ -d ${basepwd}/devices/kernels/flodeb-4 ]]; then
  		echo "Copying kernel to rootfs"
  		cp -rf ${basepwd}/devices/kernels/flodeb-4 ${basedir}/kernel
		else
  		git clone https://github.com/binkybear/kernel_msm.git -b android-msm-flo-3.4-kitkat-mr2 ${basepwd}/devices/kernels/flodeb-4
			cp -rf ${basepwd}/devices/kernels/flodeb-4 ${basedir}/kernel
		fi
		cd ${basedir}/kernel
		make clean
		sleep 10
		make kali_defconfig
		# Attach kernel builder to updater-script
		cp $basepwd/devices/updater-scripts/kitkat/flo-deb ${basedir}/flashkernel/META-INF/com/google/android/updater-script
		# Start kernel build
		f_kernel_build
	fi
}

#####################################################
# Create Nexus 7 (2013) FLO/DEB CyanogenMod Kernel (4.4+)
#####################################################
f_deb_cyanogen_kernel(){
	if [[ $FROZENKERNEL == 1 ]]; then
		echo "Using frozen kernel"
		cp -rf ${basepwd}/flash/ ${basedir}/flashkernel
		rm -rf ${basedir}/flashkernel/data ${basedir}/flashkernel/sdcard ${basedir}/flashkernel/system/app ${basedir}/flashkernel/META-INF/com/google/android/updater-script
		cp -rf ${basepwd}/devices/frozen_kernels/4.4.4/n7-flodeb-CM/* ${basedir}/flashkernel/
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
		if [[ $LOCALGIT == 1 ]]; then
			echo "Copying kernel to rootfs"
			cp -rf ${basepwd}/cyanflodeb ${basedir}/kernel
		else
			git clone https://github.com/binkybear/flo.git -b Cyanogenmod ${basedir}/kernel
		fi
		cd ${basedir}/kernel
		make clean
		sleep 10
		make kali_defconfig
		# Attach kernel builder to updater-script
		cp $basepwd/devices/updater-scripts/lollipop/flo-deb ${basedir}/flashkernel/META-INF/com/google/android/updater-script
		# Start kernel build
		f_kernel_build
	fi
}

#####################################################
# Create Nexus 7 (2013) FLO/DEB Kernel (5)
#####################################################

f_deb_stock_kernel5(){
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
  	cp -rf ${basepwd}/devices/frozen_kernels/4.4.4/n7-flodeb/* ${basedir}/flashkernel/
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
		if [[ -d ${basepwd}/devices/kernels/flodeb-5 ]]; then
  		echo "Copying kernel to rootfs"
  		cp -rf ${basepwd}/devices/kernels/flodeb-5 ${basedir}/kernel
		else
			git clone https://github.com/binkybear/kernel_msm.git -b android-msm-flo-3.4-lollipop-release ${basepwd}/devices/kernels/flodeb-5
			cp -rf ${basepwd}/devices/kernels/flodeb-5 ${basedir}/kernel
		fi
		cd ${basedir}/kernel
		chmod +x scripts/*
		make clean
		sleep 10
		make kali_defconfig
		# Attach kernel builder to updater-script
		cp $basepwd/devices/updater-scripts/lollipop/flo-deb ${basedir}/flashkernel/META-INF/com/google/android/updater-script
		# Start kernel build
		f_kernel_build
	fi
}
