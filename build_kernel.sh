#!/bin/bash

set -e

# variables
export ARCH=arm64
export KBUILD_BUILD_USER=Chatur
export KBUILD_BUILD_HOST=Eureka.org
export BUILD_CROSS_COMPILE=$(pwd)/toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export KERNEL_LLVM_BIN=$(pwd)/toolchain/llvm-arm-toolchain-ship/10.0/bin/clang
export CLANG_TRIPLE=aarch64-linux-gnu-

gcc(){
  if [ ! -d toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 ]; then
    echo "... Cloning aarch64-linux-android-4.9 cross compiler ..."
    git clone https://github.com/Chatur27/Toolchains-for-Eureka.git -b GCC-4.9 --single-branch toolchain/gcc/linux-x86/aarch64/aarch64-linux-android-4.9
  fi
}

clang(){
  if [ ! -d toolchain/llvm-arm-toolchain-ship/10.0 ]; then
    echo "... Cloning Android Clang/LLVM v10.0.9 ..."
    git clone https://github.com/xiangfeidexiaohuo/Snapdragon-LLVM.git -b 10.0.9 --single-branch toolchain/llvm-arm-toolchain-ship/10.0
  fi
}

function trap_ctrlc (){
    # exit shell script with error code 2
    # if omitted, shell script will continue execution
    exit 2
}

clean(){
  echo "... Cleaning up source ..."
  rm -rf out
  rm -f arch/arm64/boot/Image
}

build(){
  echo "... Starting build using $(nproc) cores ..."
  mkdir out

  make -j$(nproc) -C $(pwd) O=$(pwd)/out ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE vendor/gta4lwifi_eur_open_defconfig
  make -j$(nproc) -C $(pwd) O=$(pwd)/out ARCH=arm64 CROSS_COMPILE=$BUILD_CROSS_COMPILE REAL_CC=$KERNEL_LLVM_BIN CLANG_TRIPLE=$CLANG_TRIPLE

  cp out/arch/arm64/boot/Image $(pwd)/arch/arm64/boot/Image
}


# initialise trap to call trap_ctrlc function
# when signal 2 (SIGINT) is received
trap "trap_ctrlc" 2

gcc
clang
clean
build
