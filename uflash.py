#!/usr/bin/env python3
from os import system, listdir, path, mkdir
import os
from subprocess import call, PIPE as subprocess_PIPE
from shlex import split as shlex_split
import argparse

pt = {
    'bootloader': [1, 8191],
    'boot': [8192, 81920],
    'system': [90112, 2097151],
    'cache': [2187264, 2097151],
    'userdata': [4284416, 10985472]
}

SECTOR_SIZE = 512
CHUNK_SIZE = 300 * 1024 * 1024;


def need_to_convert_to_raw(img):
    if img in ["system.img", "userdata.img", "cache.img"]:
        return True
    else:
        return False

def process(out, img, in_dir=os.path.curdir):
    print("process ", img)

    in_image = os.path.join(in_dir, img)
    if need_to_convert_to_raw(img):
        out_raw = os.path.join(out, img) + ".raw"
        conv2raw_cmd = "simg2img {} {}".format(in_image, out_raw)
        print(conv2raw_cmd)
        system(conv2raw_cmd)

        split_src = out_raw
    else:
        if out != os.path.curdir:
            cp_dst = os.path.join(out, img)
            cp_cmd = 'cp {} {}'.format(in_image, cp_dst)
            system(cp_cmd)
            split_src = cp_dst
        else:
            split_src = in_image

    # from here on, all the image we'll deal with are in the {out}
    if path.getsize(split_src) < CHUNK_SIZE:
        return True

    split_dst = os.path.join(out, os.path.basename(split_src)) + '_'
    split_cmd = "split -b {} {} {}".format(CHUNK_SIZE, split_src, split_dst)
    print(split_cmd)
    system(split_cmd)
    return True


def get_parts(out, partition):
    img = "{}.img".format(partition)
    if need_to_convert_to_raw(img):
        img = "{}.img.raw".format(partition)

    p = [x for x in listdir(out) if x.startswith('{}_'.format(img))]
    return [img] if not p else sorted(p)


def install_script_for(out, paritition):
    uboot_load_to = 0x08000000
    start = pt[paritition][0]
    size = pt[paritition][1]

    s = []
    for i, image in enumerate(get_parts(out, paritition)):
        emmc_dest = start + int((CHUNK_SIZE / SECTOR_SIZE) * i)
        emmc_writecount = int(path.getsize(os.path.join(out, image)) /
                                           SECTOR_SIZE)
        s.append("# install {}, part {}: {}".format(paritition, i, image))
        s.append("fatload usb 0:1 {} {}".format(hex(uboot_load_to), image))
        s.append("mmc write {} {} {}".format(hex(uboot_load_to),
                                             hex(emmc_dest),
                                             hex(emmc_writecount)))

    return '\n'.join(s)


def make_uboot_script(output_directory, raw_command):
    fmt = "mkimage -T script -A arm64 -C none " \
          "-n 'PoplarFlash' -d {} {}.scr"
    cmd = fmt.format(raw_command, path.join(output_directory,
                                            raw_command))
    # discard the output for this command
    call(shlex_split(cmd), stdout=subprocess_PIPE)



def copy_pt(args):
    print("process pt, just copy")
    files = ['flash_pt.scr', 'mbr.gz', 'ebr5.bin.gz', 'ebr6.bin.gz']
    for f in files:
        scr = os.path.join(args.input_directory, f)
        dst = os.path.join(args.output_directory, f)
        cp_cmd = 'cp {} {}'.format(scr, dst)
        system(cp_cmd)


def go(args):

    if not os.path.exists(args.input_directory):
        print(args.input_directory, "not exsits")
        sys.exit()

    if not os.path.exists(args.output_directory):
        mkdir(args.output_directory)

    for k in args.partitions:
        if k == 'pt':
           copy_pt(args)
        else:
            if process(args.output_directory, "{}.img".format(k), args.input_directory):
                s = install_script_for(args.output_directory, k)
                raw_cmd = "flash_{}".format(k)
                with open(raw_cmd, "w") as f:
                    f.write(s)
                make_uboot_script(args.output_directory, raw_cmd)


def main():
    parser = argparse.ArgumentParser('')
    valid_pts = list(pt.keys())
    valid_pts.append('pt')

    default_pt = list(pt.keys())
    default_pt.remove('bootloader')
    parser.add_argument('-p', '--partitions',
                        help='valid values are [{}]'.format(
                            ','.join(valid_pts)),
                        nargs='*', default=default_pt)
    parser.add_argument('-i', '--input_directory', default=os.path.curdir)
    parser.add_argument('-o', '--output_directory', default="./out_usb")
    args = parser.parse_args()
    print(args.partitions)
    go(args)


if __name__ == '__main__':
    main()

# print(parts("system"))
# print install_script_for('system')
# make_uboot_script('flash_system')
