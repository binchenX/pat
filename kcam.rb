#!/usr/bin/env ruby
# to Analysis kernel two config files, and/or merge file b into file a.
# kcam - Kernel Config Analysis and Merge
# For analysis use:
# "kcam -i a b t"
# For merge or substract use
# "kcam -a a b out" : merge configs in b into a
# "kcam -s a b out" : remove configs in b from a
@argv_size = ARGV.size
if @argv_size < 3
    puts "kcam -i a b [c] or kcam -a|-s a b out"
    exit
end

@ops = ARGV.shift
if @ops.eql?("-i")
    @fa = ARGV.shift
    @fb = ARGV.shift
    if @argv_size == 4
        @details = ARGV.shift.to_i
        if not (0..3).include?(@details)
            puts "kcam -i a b [c], c should be in [0..3]"
            exit
        end
    end
elsif @ops.eql?("-a") or @ops.eql?("-s")
    if @argv_size < 4
        puts "usage: kcam -a|-s a b out"
        exit
    end
    @fa = ARGV.shift
    @fb = ARGV.shift
    @fc = ARGV.shift
end

@des = ["#config in #{@fa} only",
        "#config in #{@fb} only",
        "#config in both but with different value",
        "#config in both and with same value"]

def kconfig_to_hash f
    h={}
    File.read(f).split("\n").sort.each { |c|
        if not c.start_with?("#")
            k = c.split("=")[0]; v = c.split("=")[1]; h[k] = v
        end
    }
    h
end

def hash_to_kconfig h
    c = ""
    h.keys.sort.each { |k| c << "#{k}=#{h[k]}\n" }
    c
end

def all_keys ha, hb
    all_keys = []
    all_keys << ha.keys
    all_keys << hb.keys
    all_keys.flatten!.uniq!
    all_keys
end

def analysis ha, hb
    infos = [{}, {}, {}, {}]
    all_keys(ha,hb).each { |k|
        if ha.has_key?(k) and !hb.has_key?(k)
            infos[0][k] = ha[k]
        elsif !ha.has_key?(k) and hb.has_key?(k)
            infos[1][k] = hb[k]
        elsif ha.has_key?(k) and hb.has_key?(k)
            if ha[k] != hb[k]
                infos[2][k] = "#{ha[k]},#{hb[k]}"
            else
                infos[3][k] = hb[k]
            end
        end
    }
    infos
end

def do_merge ha, hb
    hc = {}
    all_keys(ha,hb).each { |k|
        if ha.has_key?(k) and !hb.has_key?(k)
            hc[k] = ha[k]
        else
            hc[k] = hb[k]
        end
    }
    hc
end

def do_substract ha, hb
    hc = {}
    ha.keys.each { |k| hc[k] = ha[k] unless hb.has_key?(k) }
    hc
end

def analysis_only
    @ops.eql?("-i")
end

@ha = kconfig_to_hash (@fa)
@hb = kconfig_to_hash (@fb)
@infos = analysis(@ha, @hb)
if @ops == "-a"
    @hc = do_merge(@ha,@hb)
elsif @ops == "-s"
    @hc = do_substract(@ha, @hb)
end

if !analysis_only
    File.open(@fc,"wb") { |f| f.write(hash_to_kconfig(@hc))}
end

if analysis_only && @argv_size == 4
    # print details only so that you can tee to a file
    puts hash_to_kconfig(@infos[@details])
    puts @des[@details]
else
    puts "configs# in #{@fa}, #{@ha.keys.size}"
    puts "configs# in #{@fb}, #{@hb.keys.size}"
    puts "stats: #{@infos.map {|h| h.keys.size}}"
    if !analysis_only
        puts "configs# in #{@fc}, #{@hc.keys.size}"
    end
end