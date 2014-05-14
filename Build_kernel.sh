#!/bin/bash
# kernel build script by thehacker911

BUILD_USER="$USER"
KERNEL_DIR=/home/$USER/android/kernel/source_build
KERNEL_SOURCE_DIR=$KERNEL_DIR/omega
TOOLCHAIN_DIR=$KERNEL_DIR/Toolchains
ANDROID_IMAGE_KITCHEN_DIR=$KERNEL_DIR/android_image_kitchen
BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`
KERNEL_DEFCONFIG=msm8974_sec_defconfig
USER_DEFCONFIG=omega_defconfig
VARIANT_DEFCONFIG=msm8974pro_sec_klte_eur_defconfig
SELINUX_DEFCONFIG=selinux_defconfig
TOOLCHAIN_1=arm-eabi-4.7/bin/arm-eabi-
TOOLCHAIN_2=arm-eabi-4.8.3/bin/arm-gnueabi-
TOOLCHAIN_3=arm-eabi-4.9.1/bin/arm-gnueabi-
TOOLCHAIN_4=arm-eabi-4.9.1-sm/bin/arm-eabi-
BUILD_CROSS_COMPILE=$TOOLCHAIN_DIR/$TOOLCHAIN_4

BUILD_KERNEL()
{	
	echo ""
	echo "=============================================="
	echo "START: MAKE CLEAN"
	echo "=============================================="
	echo ""
	

	make clean


	echo ""
	echo "=============================================="
	echo "END: MAKE CLEAN"
	echo "=============================================="
	echo ""

	echo "CPU"
	echo "$BUILD_JOB_NUMBER"
	echo "BUILD USER"
	echo "$BUILD_USER"
	echo "TOOLCHAIN"
	echo "$BUILD_CROSS_COMPILE"
	
	
	echo ""
	echo "=============================================="
	echo "START: BUILD_KERNEL"
	echo "=============================================="
	echo ""
	
	export ARCH=arm
	export CROSS_COMPILE=$BUILD_CROSS_COMPILE
	make $KERNEL_DEFCONFIG $USER_DEFCONFIG VARIANT_DEFCONFIG=$VARIANT_DEFCONFIG SELINUX_DEFCONFIG=$SELINUX_DEFCONFIG
#	make CONFIG_NO_ERROR_ON_MISMATCH=y -j$BUILD_JOB_NUMBER
	make -j$BUILD_JOB_NUMBER
	
	rm -rf $ANDROID_IMAGE_KITCHEN_DIR/split_img/boot.img-zImage
	cd $KERNEL_SOURCE_DIR/arch/arm/boot/
	mv zImage boot.img-zImage 
	cp boot.img-zImage $ANDROID_IMAGE_KITCHEN_DIR/split_img

	echo ""
	echo "================================="
	echo "END: BUILD_KERNEL"
	echo "================================="
	echo ""
}

BUILD_IMAGE()
{

	echo ""
	echo "=============================================="
	echo "START: BUILD_IMAGE"
	echo "=============================================="
	echo ""

	cd
	cd $ANDROID_IMAGE_KITCHEN_DIR
	./repackimg.sh

	echo ""
	echo "================================="
	echo "END: BUILD_IMAGE"
	echo "================================="
	echo ""


}

# MAIN FUNCTION
rm -rf ./build.log
(
	START_TIME=`date +%s`
	BUILD_DATE=`date +%m-%d-%Y`
	BUILD_KERNEL
	BUILD_IMAGE


	END_TIME=`date +%s`

	let "ELAPSED_TIME=$END_TIME-$START_TIME"
	echo "Total compile time is $ELAPSED_TIME seconds"
) 2>&1	 | tee -a ./build.log

# Credits:
# Samsung
# google
# osm0sis
# cyanogenmod
# kylon 
