# brew install imagemagick
# gem install rmagick

require 'RMagick'
require 'optparse'

argstr = ARGV*" " 
options = {:args=>argstr,:start_index=>0,:folder=>"source",:outfolder=>"result", :size => 2, :limit=>25,:skip=>0,:fx_name=>"lighten"}

  ARGV.options do |opts|
    script_name = File.basename($0)
    opts.banner = "Usage: ruby #{script_name} [options]"

    opts.separator ""
    
    opts.on("-i","--index FILE","start at INDEX index") do |idx|
      options[:start_index] = idx.to_i
    end
    
    opts.on("-s","--start FILE","start at FILE file name") do |file|
      options[:start_file] = file
    end
    
    opts.on("-f","--folder FOLDER","source files are in FOLDER name") do |folder|
      options[:folder] = folder
    end
    
    opts.on("-o","--out FOLDER","composite file in FOLDER name") do |folder|
      options[:outfolder] = folder
    end
    
    opts.on("-n","--limit NUM","limit to the first NUM files") do |num|
      options[:limit] = num.to_i
    end
  
    opts.on("-m","--skip NUM","Only process every NUM files (skip the rest)") do |num|
      options[:skip] = num.to_i
    end
    
    opts.on("-x","--fx EFFECT","composite EFFECT lighten, darken, multiply") do |fx|
      options[:fx_name] = fx
    end
    
    
    opts.separator ""

    opts.on("-h", "--help", "Show this help message.") { puts opts; exit }

    opts.parse!
  end


limit = options[:limit]
skip=options[:skip]
start_file = options[:start_file]
folder = options[:folder]
outfolder=options[:outfolder]

n = 0
#filenames = ["DSC00909.JPG","DSC01171.JPG","DSC01295.JPG"]

filenames = Dir.new(folder).to_a
# filter out non JPGs
filenames = filenames.find_all{|item| item =~ /.jpg/i}
puts "look for files in '#{folder}' and write to '#{outfolder}'"

puts "#{filenames.size} total files"
if(start_file)
  idx = filenames.index(start_file)
  
else
  idx = options[:start_index]

end

filenames=filenames.slice!(idx+1,filenames.size) # chop off the beginning
start_file = filenames[0]
puts "START at  #{idx} #{start_file} - #{filenames.size} files left"

if(limit<0)
  limit = filenames.size
end

puts "LIMIT to #{limit}"
if(skip>0)
  puts "Process only every #{skip} file" 
end

fx = Magick::LightenCompositeOp
case options[:fx_name]
  when "lighten" 
    fx = Magick::LightenCompositeOp
  when "darken"
    fx = Magick::DarkenCompositeOp 
  when "multiply"
    fx =Magick::MultiplyCompositeOp
end
puts "FX = #{fx}"



ncount = 0

begin
  start = Time.now
  #dst = Magick::Image.new(3344,2224){self.background_color = 'black'}
  dst = Magick::Image.read("#{folder}/#{filenames.first}").first
 filenames.each_with_index do |f,n|
     fname = "#{folder}/#{f}"

    if(n > limit)
      puts "Limit #{n-1} reached - quitting at #{fname}" 
      break
    elsif(skip>0 && (n % skip) != 0)
     # puts "SKIP #{n} #{fname}"
      next
    end
    
    
    next if(!fname.downcase.end_with?(".jpg"))
    puts "#{n} #{fname}"
  
    src = Magick::Image.read(fname).first
    dst.composite!(src, Magick::CenterGravity, fx)
    
    src.destroy! # don't leak memory
    
    ncount+=1
  
    if(ncount % 20 == 0)
      puts "Write progress.jpg"
          dst.write("#{outfolder}/progress.jpg")   
    end
  end
rescue Exception => e
  puts "ERROR"
  puts e
end

dur = (Time.now-start)
puts "Composited #{ncount} images in #{dur.to_i} seconds  ~#{(ncount/dur).to_i} images/second"

sf = filenames.first.split(".").first
ef = filenames.last.split(".").first
skipstr = skip && skip>0 ? "mod_#{skip}" : ""
fxstr = options[:fx_name]!="lighten"? "__#{options[:fx_name]}" : ""

outname = "#{outfolder}/#{sf}__#{ef}__#{filenames.size}_#{skipstr}_#{ncount}#{fxstr}.jpg"
puts "Writing #{outname}"

options[:outname]=outname
# log the parameters so we can reproduce
File.open("#{outfolder}/log.txt", 'a') {|f| f.write("\n");f.write(options.to_s) }

dst.write(outname)




