#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "usage: install_usb.sh usb_mount_point"
    exit
fi

usb_mount_point=${1}
echo "copy images and scripts to ${usb_mount_point}"
cp flash_*.scr       ${usb_mount_point}
cp mbr.gz            ${usb_mount_point}
cp ebr*.bin.gz       ${usb_mount_point}
cp bootloader.img    ${usb_mount_point}
cp boot.img          ${usb_mount_point}
cp system.img.raw_*  ${usb_mount_point}
cp cache.img.raw_*   ${usb_mount_point}
cp userdata.img.raw_*    ${usb_mount_point}
