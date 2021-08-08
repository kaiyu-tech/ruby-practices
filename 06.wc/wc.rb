#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def layout(params, total, label, new_line: false)
  result = +''

  width = 7
  result << " #{total[:lines].to_s.rjust(width)}" if params[:lines]
  result << " #{total[:words].to_s.rjust(width)}" if params[:words]
  result << " #{total[:chars].to_s.rjust(width)}" if params[:chars]
  result << " #{label}" unless label == '-'
  result << "\n" if new_line

  result
end

def generate(params)
  result = +''

  file_count = ARGV.count

  total = Hash.new(0)
  subtotal = Hash.new(0)

  ARGF.each_line do |line|
    subtotal[:lines] += 1
    subtotal[:words] += line.split(/\p{blank}|\n/).count { |v| !v.empty? }
    subtotal[:chars] += line.length

    next unless ARGF.eof?

    result << layout(params, subtotal, ARGF.filename, new_line: true)

    total[:lines] += subtotal[:lines]
    total[:words] += subtotal[:words]
    total[:chars] += subtotal[:chars]

    break if ARGV.count.zero?

    subtotal.clear
  end

  result << layout(params, total, 'total') if file_count > 1

  result
end

opt = OptionParser.new

params = {}

opt.on('-l') { |v| params[:lines] = v }
opt.on('-w') { |v| params[:words] = v }
opt.on('-m') { |v| params[:chars] = v }

begin
  opt.parse!(ARGV)
rescue OptionParser::InvalidOption => e
  p "wc: #{e.message}"
  exit
end

# Without options, it works as with all options (-lwm)
# However, it may need to be fixed if the "no option" behavior is changed.
params = Hash.new(true) if params.empty?

puts generate(params)
