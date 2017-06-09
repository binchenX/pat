# Poplar Android Flash tools

It will generate the install scripts and the images that can be put into a FAT32 formatted usb disk, and flashed to the board emmc through u-boot command.

## Instructions

1. Download and build the poplar Android

2. Put script `poplar_android_flash` in the $OUT

3. Run `ruby ./poplar_android_flash.rb`

   Copy following stuff to your FAT32 formatted USB disk, for a whole re-flash. Or, just copy the files/images you want to re-flash, say boot.img and flash_boot.scr.

```
   a. *.scr  
   b. mbr.tgz and ebr*.tgz
   c. boot.img, bootloader.img, system.img.raw*, usrdata.img.raw_ , cache.img.raw_
```

4. Follow [this](https://github.com/Linaro/poplar-tools/blob/latest/build_instructions.md), check the section `Run the recovery on the Poplar board`, to run the flash scripts in bootloader mode. Just replace the install.scr with flash_xxx.scr you want to use.

```
    usb reset
    fatload usb 0:1 ${scriptaddr} flash_xxxx.scr
    source ${scriptaddr}
```

