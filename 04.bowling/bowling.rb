#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

opt = OptionParser.new

begin
  opt.parse!(ARGV)
rescue OptionParser::InvalidOption => e
  p "bowling: #{e.message}"
  exit
end

def strike?(frame_throw_count, frame_score_total)
  frame_throw_count == 1 && frame_score_total == 10
end

def spare?(frame_throw_count, frame_score_total)
  frame_throw_count == 2 && frame_score_total == 10
end

# フレームの終了条件を満たしたか？
def end_of_frame?(frame_number, frame_throw_count, frame_score_total)
  frame_number < 10 && (strike?(frame_throw_count, frame_score_total) || frame_throw_count == 2)
end

# スコアの加点を取得する
def score_bonus(frame_throw_count, frame_score_total, next_throw_score, next_next_throw_score)
  if strike?(frame_throw_count, frame_score_total)
    next_throw_score + next_next_throw_score
  elsif spare?(frame_throw_count, frame_score_total)
    next_throw_score
  else
    0
  end
end

# スコアの合計を作成する
def game_score_total(scores)
  frame_number = 1
  frame_throw_count = 0
  frame_score_total = 0
  game_score_total = 0

  scores.each_with_index do |current_throw_score, index|
    frame_throw_count += 1
    frame_score_total += current_throw_score
    game_score_total += current_throw_score

    next unless end_of_frame?(frame_number, frame_throw_count, frame_score_total)

    game_score_total += score_bonus(frame_throw_count, frame_score_total, scores[index + 1], scores[index + 2])

    frame_number += 1
    frame_throw_count = 0
    frame_score_total = 0
  end

  game_score_total
end

scores = ARGV[0].gsub('X', '10').split(',').map(&:to_i)

p game_score_total(scores)
