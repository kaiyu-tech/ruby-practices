#!/usr/bin/env ruby

require 'optparse'
require 'date'

opt = OptionParser.new

today = Date.today

# パラメータの初期値は今月
params = {y: today.year, m: today.month}

opt.on('-y VAL') {|v| params[:y] = v.to_i }
opt.on('-m VAL') {|v| params[:m] = v.to_i }

begin
  opt.parse!(ARGV)
rescue OptionParser::InvalidOption => e
  puts 'cal: ' + e.message
  exit
end

begin
  first = Date.new(params[:y], params[:m], 1) # 月初
  last = Date.new(params[:y], params[:m], -1) # 月末
rescue Date::Error => e
  puts 'cal: ' + e.message
  exit
end

result = ""

result << sprintf('%d月 %4d', first.month, first.year).center(20) << "\n"

result << "\e[31m日\e[0m 月 火 水 木 金 \e[36m土\e[0m\n"

result << '   ' * first.wday
(first..last).each do |date|
  value = sprintf('%2d', date.day)
  # 今日の日付は色を反転する
  value = "\e[7m" << value << "\e[0m" if date == today
  result << value << ' '
  result << "\n" if date.wday == 6
end
# 末尾に改行がある場合は削除する
result.chomp!

# 選択月が6週未満だった場合は足りない分の行を追加する
weeks = last.strftime("%U").to_i - first.strftime("%U").to_i + 1
result << "\n" * (6 - weeks)
print result << "\n"
