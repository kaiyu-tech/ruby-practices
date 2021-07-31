#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

opt = OptionParser.new

begin
  opt.parse!(ARGV)
rescue OptionParser::InvalidOption => e
  p "cal: #{e.message}"
  exit
end

# スコアの加点を取得する
def score_bonus(params, throw_count, index)
  if throw_count == 1
    params[index + 1] + params[index + 2] # strike
  else
    params[index + 1] # spare
  end
end

# スコアの合計を作成する
def score_total(params)
  frame_number = 1
  throw_count = 0
  score_subtotal = 0
  result = 0

  params.each_with_index do |score, index|
    throw_count += 1
    score_subtotal += score
    result += score

    next unless frame_number < 10 && (score == 10 || throw_count == 2)

    result += score_bonus(params, throw_count, index) if score_subtotal == 10

    frame_number += 1
    throw_count = 0
    score_subtotal = 0
  end

  result
end

params = ARGV[0].gsub('X', '10').split(',').map(&:to_i)

p score_total(params)
