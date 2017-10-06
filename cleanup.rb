#!/usr/bin/ruby

#keep partition table and bootloader
#rm mbr.gz           
#rm ebr*.bin.gz      
#rm bootloader.img

@res_to_cleanup = [
    "boot",
    "system", 
    "cache",
    "userdata"
    ]

def cleanup_all
    @res_to_cleanup.each { |f|
        flash_script = "flash_#{f}"
        %x[rm #{flash_script}*] unless !File.exists?(flash_script) 
        partition_file = "#{f}.img"
        %x[rm #{partition_file}*] unless !File.exists?(partition_file) 
    }
end

cleanup_all