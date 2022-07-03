#!/bin/bash

# Resources
THREAD="-j$(nproc --all)"

export CLANG_PATH=/home/nakixii/toolchain/proton-clang/bin/
export PATH=${CLANG_PATH}:${PATH}
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=/home/nakixii/toolchain/proton-clang/bin/aarch64-linux-gnu- CC=clang CXX=clang++
export CROSS_COMPILE_COMPAT=/home/nakixii/toolchain/arm-none-eabi-gcc/bin/arm-none-eabi-

DEFCONFIG="mgk_64_k510_defconfig"

# Paths
KERNEL_DIR=`pwd`
ZIMAGE_DIR="$KERNEL_DIR/out/arch/arm64/boot"

# Vars
export LOCALVERSION=-debug
export ARCH=arm64
export SUBARCH=$ARCH
export KBUILD_BUILD_USER=nakixii

DATE_START=$(date +"%s")

echo
echo "-------------------"
echo "Making Kernel:"
echo "-------------------"
echo

make CC="ccache clang" CXX="ccache clang++" LD=ld.lld O=out $DEFCONFIG
make CC="ccache clang" CXX="ccache clang++" LD=ld.lld O=out $THREAD 2>&1 | tee kernel.log

echo
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
echo

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
ls -a $ZIMAGE_DIR

cd $KERNEL_DIR

chown -R nakixii *
chgrp -R nakixii *

if grep -q "Error " kernel.log
then
	echo; echo
	grep -n "error:" kernel.log
	grep -n "error," kernel.log
	grep -n "not found" kernel.log
	echo; echo
	exit 0
else
TIME="$(date "+%Y%m%d-%H%M%S")"
mkdir -p tmp
cp -fp $ZIMAGE_DIR/Image.gz tmp
cp -rp ./anykernel/* tmp
cd tmp
7za a -mx9 tmp.zip *
cd ..
rm *.zip
cp -fp tmp/tmp.zip DynamIQ-Kernel-D8100-$TIME.zip
rm -rf tmp
echo $TIME
fi
