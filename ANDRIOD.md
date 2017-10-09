# Poplar Android Build

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

```
mkdir device/hisilicon
git clone ssh://git@dev-private-git.linaro.org/aspen/staging/device/linaro/poplar.git   device/hisilicon/poplar
git clone ssh://git@dev-private-git.linaro.org/aspen/staging/device/linaro/poplar-kernel.git device/hisilicon/poplar-kernel
```

### Build
```
source build/envsetup.sh
lunch poplar-eng
make -j8
```

## Update Kernel and DTB

- pack new kernel and dtb into new boot.img, and boot from emmc

`device/hisilicon/poplar-kernel` come with the prebuilt kernel and dtb. To update the kernel and dtb, just copy what you newly built one in to `${your_android}/device/hisilicon/poplar-kernel`.

To rebuild the `$OUT/boot.img`,
```
  source build/envsetup.sh
  lunch poplar-eng
  make bootimage -j8
```

Then, flash the new boot.img to the board, and boot from emmc.

- put the new kernel/dtb into usb, and boot from usb

Alternatively, you can just to put new kernel and dtb in to a fat32 formatted usb disk.

```
     9197   hi3798cv200-poplar.dtb
 15733248   Image
  1273215   ramdisk.android.uboot
```

Note that, the usb must also have a `ramdisk.android.uboot` file, it is u-boot legacy format ramdisk, as produced by mkimage.

```
mkimage -n 'Android Ramdisk Image' -A arm64 -O linux -T ramdisk -C none
-d $OUT/ramdisk.img $OUT/ramdisk.android.uboot
```

## Boot Android

- boot from emmc

Enter into the u-boot console (by hitting any key to stop autoboot), and type following command:

```
poplar# run bootai
```

- boot from usb

Enter into the u-boot console (by hitting any key to stop autoboot), and type following command:

```
poplar# run setupa
poplar# run boota
```

## Debug, adb, Misc

- adb

Currently the board doesn't support usb OTG, you will have to use adb over tcp ip, and here are the steps to set it up.

1. Plug an Ethernet cable to your board and make sure eth0 is getting its address  

```
poplar:/ # ifconfig 
eth0      Link encap:Ethernet  HWaddr 66:2c:57:b3:f9:a3
          inet addr:192.168.0.18  Bcast:192.168.0.255  Mask:255.255.255.0 
          inet6 addr: fe80::642c:57ff:feb3:f9a3/64 Scope: Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:2072 errors:0 dropped:0 overruns:0 frame:0 
          TX packets:258 errors:0 dropped:0 overruns:0 carrier:0 
          collisions:0 txqueuelen:1000 
          RX bytes:429037 TX bytes:28204 
          Interrupt:35 
```

2. write down the ip address, 192.168.0.18 in this case

3. On you developer machine:

```
$adb connect  ${poplar_ip_addr}       #192.168.0.18
```

And, check with `adb devices`

```
$ adb devices
List of devices attached
192.168.0.18:5555   device
```

4. Now, adb is ready for you to use, use `adb help` for more information.

```
$adb remount
$adb push path/to/your/tools  /system/bin
```
