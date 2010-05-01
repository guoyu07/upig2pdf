
# kindle :DX��824*1200�ķֱ���
# �ҵ�������824*1200��780*1080��������úܶࡣ
# ������784*1050 ���ֻ����DX������784  ��С10%����
# ͭ�彨�����ҽ������824*1200
# ����־��1100*1600����ֱ��ʣ���������Ч������ܲ��������о��


require 'rubygems'
require 'optparse'
require 'mini_magick'
require 'prawn'
require 'fileutils'
require 'yaml'
require 'natural_sort_kernel'

exit if Object.const_defined?(:Ocra)

#puts ARGV.inspect
options = {}

optparse = OptionParser.new do|opts|
  # Set a banner, displayed at the top
  # of the help screen.
  opts.banner =<<'EOF'
����ת��jpg�ļ���Ϊpdf�ĵ�(Kindle dxʹ�ã�
ʹ�÷���:
  jpg2pdf [options] jpg_dir_name"
EOF
  options[:output] = ''
  opts.on( '-o', '--output output_name', 'ָ�����·��') do |f|
    options[:output] = f 
  end

  options[:yml] = ''
  opts.on( '-y', '--yml ymlfile', 'ָ�������ļ���') do |f|
    options[:yml] = f 
  end

  opts.on( '-h', '--help', '����' ) do
    puts opts
    `pause`
    exit
  end
end


optparse.parse!

input_path = ARGV[0]

if options[:yml]!=''
  yml = YAML.load_file(options[:yml])
else
  yml = YAML.load('jpg_size: 784x1050
page_size: [396.85, 575.43]
margin: [0, 0, 0, 0]
gamma: 1
')
end

#puts yml.inspect

if !File.directory?(input_path)
  $stderr.puts 'ֻ�����ļ���'
  `pause`
  exit
end
#puts input_path
base_name = File.basename(input_path)
output_path =input_path[0...-base_name.length] 

if options[:output]!=''
  output_path = options[:output]
end

temp_path = 'C:/____upig_pdf_out_temp'
Dir.mkdir(temp_path) unless File.exist?(temp_path)

$pdf_option = {:page_size=>yml["page_size"], :margin=>yml["margin"], :compress=>true}

output_file_name = File.join(output_path, "#{base_name}.pdf")

#puts '='*79


begin
  Prawn::Document.generate("#{output_file_name}", $pdf_option) do
    first_page = true
    Dir.glob('**/*.{jpg,gif,png,tiff}').natural_sort.each do |f|
      puts f
      image = MiniMagick::Image.from_file(f)
      image.rotate "90" if image[:width]>image[:height] 
      image.resize yml["jpg_size"]
      image.gamma yml["gamma"] if yml["gamma"]!=1
      file_name = File.join(temp_path, 'sample.jpg')
      image.write(file_name)
      start_new_page if !first_page
      first_page = false
      image file_name , :fit =>yml["page_size"]
    end
  end
  puts "Done"
rescue => detail
  print detail.backtrace.join("\n")
  puts "��������˳�"
  `pause`
end

#rescue
  #puts "An error occurred: ",$!
#end


