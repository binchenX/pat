#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "usage: install_usb.sh out_usb usb_mount_point"
    exit
fi

usb_out=${1}
usb_mount_point=${2}
echo "copy ${usb_out}/* to ${usb_mount_point}"
cp ${usb_out}/*  ${usb_mount_point} -v
sync
