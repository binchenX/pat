# Poplar Android Flash tools

It will generate the install scripts and the images that you can put into a FAT32 formatted usb disk.

## Instructions

1. Download and build the poplar ANdroid

2. Put this script in the $OUT

3. ruby ./poplar_android_flash.rb

   copy following stuff to your FAT32 formatted USB disk:

   a. *.scr  
   b. mbr.tgz and ebr*.tgz
   c. boot.img, bootloader.img, system.img.raw*, usrdata.img.raw_ , cache.img.raw_

4. Follow (this)[https://github.com/Linaro/poplar-tools/blob/latest/build_instructions.md] to run the flash scripts.
   Just replace the install.scr with flash_xxx.scr.

```
    usb reset
    fatload usb 0:1 ${scriptaddr} flash_xxxx.scr
    source ${scriptaddr}
```


