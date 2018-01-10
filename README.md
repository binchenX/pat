# Poplar Android Flash tools

It will generate the install scripts and the images that can be put into a FAT32 formatted USB disk, and flashed to the board Emmc through u-boot command.

## Dependency

1. Install Python and simg2img

apt-get install -y python python-pip android-tools-fsutils

2. A FAT32 formatted usb with capacity bigger than 8G. To format, check [this](https://askubuntu.com/questions/22381/how-to-format-a-usb-flash-drive).

## Instructions

1. Download and build the Poplar Android, or use prebuild snapshot.

2. Check the pat tool to anywhere you want. 

`git clone git@github.com:pierrchen/pat.git /path/to/pat_tool`;

3. Generate partitions data and flash script

```
IMG_IN=${your_android_src_root}/out/target/product/poplar
uflash.py -i $IMG_IN
```

By default, all the output goes to ./out_usb, you can specif it using `-o path/to/usb_out`.

4. Install generated partitions and flash script to usb.

Run `install_usb.sh out_usb usb_mount_point` to copy all the required images and scripts to your usb disk. In Ubuntu 14.04 the mount point follows the format of `/media/<user>/<usb_id>`.

5. Flash All Android partitions.
 
To flash all the Android partitions, power on the board, access u-boot console, copy paste following *long* commands:

```
usb reset;fatload usb 0:1 ${scriptaddr} flash_boot.scr; source ${scriptaddr};fatload usb 0:1 ${scriptaddr} flash_system.scr; source ${scriptaddr};fatload usb 0:1 ${scriptaddr} flash_userdata.scr; source ${scriptaddr};fatload usb 0:1 ${scriptaddr} flash_cache.scr; source ${scriptaddr};
```

To flash single parititions, for example, system partition, use following:

```
usb reset
fatload usb 0:1 ${scriptaddr} flash_system.scr;source ${scriptaddr};
```

## What's in out_usb?

Below here is a little bit what is copied and where they are from:

```
    a) *.scr
    b) mbr.tgz and ebr*.tgz
    c) bootloader.img (*)
    d) boot.img, system.img.raw_*, usrdata.img.raw_* , cache.img.raw_*
```

Notes:
- a) are install scripts for u-boot
- b) are partition table; prebuilt, come with this repo
- c) bootloader.img; a prebuild is provided for the convenience. But you are suggested to build your own using the latest l-loader/atf/u-boot to stay in sync. The `bootloader.img` is generated from of the `l-loader.bin` by removing its first 512 bytes, as shown below. To build `l-loader.bin`, follow the instructions[here](https://github.com/Linaro/poplar-tools/blob/latest/build_instructions.md).

```
    dd if=l-loader.bin of=bootloader.img bs=512 skip=1 count=8191
```
- d) are converted from android core images, splitted, and raw or xt4 (NOT sparse image)
