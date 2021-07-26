#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'csv'

opt = OptionParser.new

begin
  opt.parse!(ARGV)
rescue OptionParser::InvalidOption => e
  p "cal: #{e.message}"
  # エラーの場合はプログラムを終了する
  exit
end

params = ARGV[0].gsub('X', '10').parse_csv.map(&:to_i)

# strikeかspareかを検出してindexと共に取得する
def bonus_states(params)
  frame_number = 1
  throw_count = 0
  score_subtotal = 0
  bonus_state = :none

  result = []

  params.each_with_index do |score, index|
    throw_count += 1
    score_subtotal += score

    if score_subtotal == 10
      bonus_state = throw_count == 1 ? :strike : :spare
    end

    next unless score == 10 || throw_count == 2

    result << { bonus_state: bonus_state, param_index: index }

    frame_number += 1

    break if frame_number == 10

    throw_count = 0
    score_subtotal = 0
    bonus_state = :none
  end

  result
end

bonus_states = bonus_states(params)

# strikeとspareを加味しないスコアの小計
score_subtotal = params.sum

# strikeかspareで加算されるスコアの合計を取得
def score_bonus_total(bonus_states, params)
  result = 0

  bonus_states.each do |v|
    state = v[:bonus_state]
    index = v[:param_index]

    case state
    when :strike
      result += params[index + 1] + params[index + 2]
    when :spare
      result += params[index + 1]
    end
  end

  result
end

score_bonus_total = score_bonus_total(bonus_states, params)

p score_subtotal + score_bonus_total
