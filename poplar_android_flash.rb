# generate the files and scripts that can be copied
# to a fat32 formatted usb disk, and then allows you
# re-flash the emmc with.

# partition table we are now using. (u-boot based)
# Part    Start Sector    Num Sectors     UUID            Type
#   1     1               8191            6d9fd96d-01     83
#   2     8192            81920           6d9fd96d-02     83
#   3     90112           2097151         6d9fd96d-03     83
#   4     2187263         13082625        6d9fd96d-04     0f Extd
#   5     2187264         2097151         6d9fd96d-05     83
#   6     4284416         10985472        6d9fd96d-06     83
#

@pt = {
      "bootloader" => [1,      8191    ],
      "boot"       => [8192,   81920   ],
      "system"     => [90112,  2097151 ],
      "cache"      => [2187264,2097151 ],
      "userdata"   => [4284416,10985472]}

# UEFI based. (Not used yet)
# #    Start     Size     Type FS Type Description
# -    -----     ----     ---- ------- -----------
# *        0        1      MBR
# 1        1     8191     0xf0    none loader
# 2     8192   262144     0xef    vfat /boot       <-- EFI partition
# 3   270336    81919     0xda    none android_boot
# 4   352255 14917633     0x0f    none extended
# *   352255        1      EBR
# 5   352256  2097151     0x83    ext4 android_system
# *  2449407        1      EBR
# 6  2449408  2097151     0x83    ext4 android_cache
# *  4546559        1      EBR
# 7  4546560 10723328     0x83    ext4 android_user_data

@pt_uefi = {
      "bootloader" => [1,      8191    ],
      "efi"        => [8192,   262144  ],
      "boot"       => [270336, 81919   ],
      "system"     => [352256, 2097151 ],
      "cache"      => [2449408,2097151 ],
      "userdata"   => [4546560,10723328]}

@SECTOR_SIZE = 512
@CHUNK_SIZE = 300*1024*1024;

def install_script_for partition
    uboot_load_to = 0x08000000
    start = @pt[partition][0]
    size =  @pt[partition][1]
    s = []
    parts(partition).each_with_index { |image, i|
      emmc_dest = start + (@CHUNK_SIZE/@SECTOR_SIZE) * i;
      emmc_writecount = File.size(image)/@SECTOR_SIZE
      s << "\# install #{partition}, part #{i}: #{image}"
      s << "fatload usb 0:1 0x#{uboot_load_to.to_s(16)} #{image}"
      s << "mmc write 0x#{uboot_load_to.to_s(16)} 0x#{emmc_dest.to_s(16)} 0x#{emmc_writecount.to_s(16)}"
    }
    s.join("\n")
end

def need_convert_to_raw img
  ["system.img", "userdata.img", "cache.img"].include? img
end

# use simg2img to convert raw ext file if needed
# split to parts each less than @CHUNK_SIZE if needed
def process img
  # must at least have one of original or .raw file
  raw_img = "#{img}.raw"
  if [img, raw_img].none? {|f| File.exists?(f)}
    puts "ERROR:no #{img} and #{raw_img} found"
    return false
  end

  if need_convert_to_raw(img)
    if not File.exists?(raw_img)
      puts "INFO:no #{raw_img} found, converting it to ext4.."
      %x[simg2img #{img} #{img}.raw]
    else
      if not %x[file #{raw_img}].include?("ext4")
        puts "ERROR:#{raw_img} is not ext4, something wrong"
        return false;
      end
    end
    # we will check the raw_img for those images
    img = raw_img
  end

  if File.size(img) < @CHUNK_SIZE
    return true
  end

  if Dir.glob("#{img}_*").any?
    puts "INFO:parts for #{img} exists, will use that"
    return true
  end

  puts "INFO:spiting #{img}.."
  cmd = "split -b #{@CHUNK_SIZE} #{img} #{img}_"
  %x[#{cmd}]
  return true
end

# return the parts name for this partition
def parts partition
  img = "#{partition}.img"
  if need_convert_to_raw img
    img = "#{partition}.img.raw"
  end

  p = Dir.entries(".").select {|e| e.start_with?("#{img}_")}
  p.empty?() ? [img] : p.sort
end

def make_uboot_script raw_command
  cmd = "mkimage -T script -A arm64 -C none -n 'Poplar Flash' -d #{raw_command} #{raw_command}.scr"
  %x[#{cmd}]
end

def go
  @partitions = @pt.keys
  @partitions.each { |p|
    if process "#{p}.img"
      s = install_script_for p
      raw_cmd = "flash_#{p}"
      File.open(raw_cmd,"w") {|f| f.write(s)}
      make_uboot_script(raw_cmd)
      #puts "script for flashing #{p} generate"
    end
  }
end

if %x[which simg2img].empty?()
  puts "ERROR:please install simg2img"
  exit
end
go