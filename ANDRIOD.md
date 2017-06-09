# Android build

This file documents how to build Poplar Android.

## Get and Build Android

For general set up, refer to [official Android doc](https://source.android.com/source/initializing). 

### Get AOSP android-7.1.1_r3
```
mkdir poplar
cd poplar
repo init -u https://android.googlesource.com/platform/manifest.git -b android-7.1.1_r3
repo sync -j8
```

### Add poplar device

Use the `newUboot` branch to work with new u-boot and new kernel.

```
mkdir device/hisilicon
git clone ssh://git@dev-private-git.linaro.org/aspen/staging/device/linaro/poplar.git  -b newUboot    device/hisilicon/poplar
git clone ssh://git@dev-private-git.linaro.org/aspen/staging/device/linaro/poplar-kernel.git -b newUboot  device/hisilicon/poplar-kernel
```

### Build
```
source build/envsetup.sh
lunch poplar-eng
make -j8
```

## Update Bootloader
(*notes*: this section will go after change been merged to poplar-u-boot)

Changes are need to make u-boot be able to boot an arm64 Android bootimage. Follow the instructions [here](https://github.com/Linaro/poplar-tools/blob/latest/build_instructions.md) to download and build the `ATF`, `l-loader` and `U-boot`. But for `u-boot` use a different repo/branch, which contains un-merged changes to support boot an android arm64 image.

```
git clone git@github.com:pierrchen/poplar-u-boot.git -b bootai 
```

Build all as described [here](https://github.com/Linaro/poplar-tools/blob/latest/build_instructions.md), you will get a `l-loader.bin`, which is our bootloader.

To flash the bootloader, follow [here](https://github.com/pierrchen/pat/blob/master/README.md)

## Update Kernel and DTB

`device/hisilicon/poplar-kernel` come with the prebuilt kernel and dtb. This section explains how to update it and rebuilt the `boot.img`. This is useful for kernel developers.

Choose the android branch for the kernel, currently none is fully ready, but you can use `android-4.9-poplar` to start with.

```
git clone https://github.com/linaro/poplar-linux.git -b android-4.9-poplar
```

Follow [here](https://github.com/Linaro/poplar-tools/blob/latest/build_instructions.md#step-4-build-linux) to build.

Copy the `arch/arm64/boot/Image` and `arch/arm64/boot/dts/hisilicon/hi3798cv200-poplar.dtb` to ${your_android}/device/hisilicon/poplar-kernel.

To rebuilt the bootimage;

```
source build/envsetup.sh
lunch poplar-eng
make bootimage -j8 
```