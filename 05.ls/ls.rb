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
  result = +''

  result << (value[0] == '1' ? 'r' : '-')
  result << (value[1] == '1' ? 'w' : '-')
  result << if value[2] == '1'
              is_special ? special_char : 'x'
            else
              is_special ? special_char.upcase : '-'
            end

  result
end

# 通常表示
def path_normal(path_list)
  cols = 3
  rows = path_list.length.quo(cols).ceil
  length = rows * cols

  path_list += Array.new(length - path_list.length, '')

  max_length = path_list.max_by(&:length).length

  result = +''
  path_list.each_slice(rows).to_a.transpose.flatten.each_with_index do |path, i|
    next if path.empty?

    result << path.ljust(max_length + 2)
    result << "\n" if i % cols == cols - 1
  end

  result
end

# 詳細表示のためのデータを生成
def generate_parts(path, total_blocks, cols)
  status = File.lstat(path)

  file_type = status.mode.to_s(8).chars[0..-5].join
  special_type = status.mode.to_s(8).chars[-4]
  access_type = status.mode.to_s(2).chars[-9..-1].join

  cols[0] << (file_type_char(file_type.to_i(8)) +
  file_access_char(access_type[0..2], special_type == '4', 's') +
  file_access_char(access_type[3..5], special_type == '2', 's') +
  file_access_char(access_type[6..8], special_type == '1', 't'))

  cols[1] << status.nlink.to_s

  cols[2] << "#{Etc.getpwuid(status.uid).name}  #{Etc.getgrgid(status.gid).name}"

  cols[3] << status.size.to_s

  mtime = status.mtime
  cols[4] << ((Time.now - mtime).quo(86_400) >= 182 ? mtime.strftime('%_m %_d  %Y') : mtime.strftime('%_m %_d %R'))

  cols[5] << (File.ftype(path) == 'link' ? "#{path} -> #{File.readlink(path)}" : path)

  total_blocks += status.blocks

  [total_blocks, cols]
end

# 詳細表示のレイアウト
def parts_layout(cols)
  result = +''

  (0...cols[0].length).to_a.product(cols).each do |i, col|
    result << if cols.first == col
                col[i]
              elsif cols.last == col
                " #{col[i]}"
              else
                margin = /\A[0-9]+\z/.match?(col[i]) ? 2 : 1
                col[i].rjust(col.max_by(&:length).length + margin)
              end
    result << "\n" if col == cols.last
  end

  result
end

# 詳細表示
def path_detail(path_list)
  cols = Array.new(6) { [] }

  total_blocks = 0

  path_list.each do |path|
    total_blocks, cols = generate_parts(path, total_blocks, cols)
  end

  "total #{total_blocks}\n#{parts_layout(cols)}"
end

opt = OptionParser.new

params = {}

opt.on('-a') { |v| params[:all] = v }
opt.on('-l') { |v| params[:detail] = v }
opt.on('-r') { |v| params[:reverse] = v }

begin
  opt.parse!(ARGV)
rescue OptionParser::InvalidOption => e
  p "cal: #{e.message}"
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
