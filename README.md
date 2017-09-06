# Poplar Android Flash tools

It will generate the install scripts and the images that can be put into a FAT32 formatted usb disk, and flashed to the board emmc through u-boot command.

## Dependency

1. Ruby

This is a ruby script so need to install ruby if have don't have one.
On Ubuntu ` sudo apt-get install ruby-ful`

2. simg2img

Used by the script to convert Android sparse image to raw ext4 image. This will be available after a full android build, located at `${your_android}/out/host/linux-x86/bin/simg2img`

3. A FAT32 formatted usb with capacity bigger than 8G. To format, check [this](https://askubuntu.com/questions/22381/how-to-format-a-usb-flash-drive).

## Instructions

1. Download and build the poplar Android (follow internal wiki)

2. Check the pat tool to anywhere you want. `git clone git@github.com:pierrchen/pat.git /path/to/pat_tool`; and move `cp $OUT/*.img path/to/pat_tool`. 

(The `$OUT` is an environment variable setting by android build system after you did `source build/envsetup.sh; lunch`. For poplar, it is `${your_android_src_root}/out/target/product/poplar`.) 

3. Run `ruby ./poplar_android_flash.rb` in pat_tool.

4. Run `./install_usb.sh usb_mount_point` to copy all the required images and scripts to your usb disk. In Ubuntu 14.04 the mount point follows the format of `/media/<user>/<usb_id>`. 

See below a description regarding what is copied to the usb disk.

5. To flash all the partitions, power on the board, access u-boot console, copy paste following *long* commands:

```
usb reset;fatload usb 0:1 ${scriptaddr} flash_pt.scr; source ${scriptaddr};fatload usb 0:1 ${scriptaddr} flash_bootloader.scr; source ${scriptaddr};fatload usb 0:1 ${scriptaddr} flash_system.scr; source ${scriptaddr};fatload usb 0:1 ${scriptaddr} flash_userdata.scr; source ${scriptaddr};fatload usb 0:1 ${scriptaddr} flash_cache.scr; source ${scriptaddr};
```

OK. I know that script is too long. I probably can use u-boot script to make it shorter but for now please bear with me. I'll show you how to flash a single system partition, and you will get the idea how to flash others.

```
usb reset
fatload usb 0:1 ${scriptaddr} flash_system.scr;source ${scriptaddr};
```

## What was copied and flashed?

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
- c) bootloader.img; a prebuild is provided for the convenience. But you are suggested to build your own using the latest l-loader/atf/u-boot to stay in sync. The `bootloader.img` is generated from of the `l-loader.bin` by removing its first 512 bytes, as shown below. To build `l-loader.bin`, follow the instructions instructed [here](https://github.com/Linaro/poplar-tools/blob/latest/build_instructions.md)
A prebuilt is provided as well.

```
    dd if=l-loader.bin of=bootloader.img bs=512 skip=1 count=8191
```

- d) are converted from android core images, splitted, and raw or ext4 (NOT sparse image)

