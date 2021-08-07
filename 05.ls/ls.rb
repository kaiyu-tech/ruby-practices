#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'
require 'time'

# ファイルの種類
def file_type_char(value)
  { 0o01 => 'P',
    0o02 => 'c',
    0o04 => 'd',
    0o06 => 'b',
    0o10 => '-',
    0o12 => 'l',
    0o14 => 's' }[value]
end

# ファイルのアクセス権
def file_access_char(value, is_special, special_char)
  file_access = +''

  file_access << (value[0] == '1' ? 'r' : '-')
  file_access << (value[1] == '1' ? 'w' : '-')
  file_access << if value[2] == '1'
                   is_special ? special_char : 'x'
                 else
                   is_special ? special_char.upcase : '-'
                 end

  file_access
end

# 通常表示
def path_normal(path_list)
  cols = 3
  rows = path_list.length.quo(cols).ceil
  length = rows * cols

  path_list += Array.new(length - path_list.length, '')

  max_length = path_list.max_by(&:length).length

  files = +''
  path_list.each_slice(rows).to_a.transpose.flatten.each_with_index do |path, i|
    next if path.empty?

    files << path.ljust(max_length + 2)
    files << "\n" if i % cols == cols - 1
  end

  files
end

# 詳細表示のためのデータを生成
FILE_LIST_COLS = 6
FILE_MODE = 0
FILE_NUMBER_OF_HARD_LINKS = 1
FILE_USER_NAME_OF_OWNER = 2
FILE_GROUP_NAME_OF_OWNER = 3
FILE_FILE_BYTE_SIZE = 4
FILE_LAST_MODIFIED_TIME = 5
def generate_parts(path)
  cols = Array.new(FILE_LIST_COLS) { +'' }

  status = File.lstat(path)

  file_type = status.mode.to_s(8).chars[0..-5].join
  special_type = status.mode.to_s(8).chars[-4]
  access_type = status.mode.to_s(2).chars[-9..-1].join

  cols[FILE_MODE] << (file_type_char(file_type.to_i(8)) +
  file_access_char(access_type[0..2], special_type == '4', 's') +
  file_access_char(access_type[3..5], special_type == '2', 's') +
  file_access_char(access_type[6..8], special_type == '1', 't'))

  cols[FILE_NUMBER_OF_HARD_LINKS] << status.nlink.to_s

  cols[FILE_USER_NAME_OF_OWNER] << "#{Etc.getpwuid(status.uid).name}  #{Etc.getgrgid(status.gid).name}"

  cols[FILE_GROUP_NAME_OF_OWNER] << status.size.to_s

  mtime = status.mtime
  cols[FILE_FILE_BYTE_SIZE] << ((Time.now - mtime).quo(86_400) >= 182 ? mtime.strftime('%_m %_d  %Y') : mtime.strftime('%_m %_d %R'))

  cols[FILE_LAST_MODIFIED_TIME] << (File.ftype(path) == 'link' ? "#{path} -> #{File.readlink(path)}" : path)

  { blocks: status.blocks, cols: cols }
end

# 詳細表示のレイアウト
def parts_layout(cols)
  files = +''

  row_size = cols[0].length
  (0...row_size).each do |i|
    cols.each do |col|
      files << if cols.first == col
                 col[i]
               elsif cols.last == col
                 " #{col[i]}\n"
               else
                 margin = /\A[0-9]+\z/.match?(col[i]) ? 2 : 1
                 col[i].rjust(col.max_by(&:length).length + margin)
               end
    end
  end

  files
end

# 詳細表示
def path_detail(path_list)
  cols = []

  total_blocks = 0

  path_list.each do |path|
    generate_parts = generate_parts(path)
    total_blocks += generate_parts[:blocks]
    cols << generate_parts[:cols]
  end

  "total #{total_blocks}\n#{parts_layout(cols.transpose)}"
end

opt = OptionParser.new

params = {}

opt.on('-a') { |v| params[:all] = v }
opt.on('-l') { |v| params[:detail] = v }
opt.on('-r') { |v| params[:reverse] = v }

begin
  opt.parse!(ARGV)
rescue OptionParser::InvalidOption => e
  p "ls: #{e.message}"
  exit
end

Dir.chdir(ARGV[0]) unless ARGV.length.zero?

mach_flag = params[:all] ? File::FNM_DOTMATCH : 0
path_list = Dir.glob('*', mach_flag)

return if path_list.length.zero?

path_list.reverse! if params[:reverse]

if params[:detail]
  puts path_detail(path_list)
else
  puts path_normal(path_list)
end
