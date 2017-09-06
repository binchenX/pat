# Poplar Android Flash tools

It will generate the install scripts and the images that can be put into a FAT32 formatted usb disk, and flashed to the board emmc through u-boot command.

## Dependency

1. Ruby

This is a ruby script so need to install ruby if have don't have one.
On Ubuntu ` sudo apt-get install ruby-ful`

2. simg2img

Used by the script to convert Android sparse image to raw ext4 image. This will be available after a full android build, located at `${your_android}/out/host/linux-x86/bin/simg2img`

## Instructions

1. Download and build the poplar Android (follow internal wiki)

2. Put script `poplar_android_flash.rb` in the $OUT

3. Run `ruby ./poplar_android_flash.rb`

4. Copy following stuff to your FAT32 formatted USB disk for a whole re-flash. Or, just copy the files/images you want to re-flash, say boot.img and flash_boot.scr.

```
    a) *.scr
    b) mbr.tgz and ebr*.tgz
    c) bootloader.img (*)
    d) boot.img, system.img.raw_*, usrdata.img.raw_* , cache.img.raw_*
```

Notes:

- a) are install scripts for u-boot
- b) are partition table; prebuilt, come with this repo
- c) is generated from of the `l-loader.bin` by removing its first 512 bytes, as shown below. To build `l-loader.bin`, follow the instructions instructed [here](https://github.com/Linaro/poplar-tools/blob/latest/build_instructions.md)

```
    dd if=l-loader.bin of=bootloader.img bs=512 skip=1 count=8191
```

- d) are converted from android core images, splitted, and raw or ext4 (NOT sparse image)

4. To flash all the partitions, first copy required images and scripts to your usb disk

```sh
usb_mount_point=
cp mbr.gz            ${usb_mount_point}
cp ebr*.bin.gz       ${usb_mount_point}
cp bootloader.img    ${usb_mount_point}
cp boot.img          ${usb_mount_point}
cp system.img.raw_*  ${usb_mount_point}
cp cache.img.raw_*   ${usb_mount_point}
cp userdata.img_*    ${usb_mount_point}
cp flash_*.scr       ${usb_mount_point}
```

Power on the board, enter into u-boot console, copy paste following commands:

```
usb reset;fatload usb 0:1 ${scriptaddr} flash_pt.scr; source ${scriptaddr};fatload usb 0:1 ${scriptaddr} flash_bootloader.scr; source ${scriptaddr};fatload usb 0:1 ${scriptaddr} flash_system.scr; source ${scriptaddr};fatload usb 0:1 ${scriptaddr} flash_userdata.scr; source ${scriptaddr};fatload usb 0:1 ${scriptaddr} flash_cache.scr; source ${scriptaddr};
```
