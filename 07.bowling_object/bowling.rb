#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require './game'

opt = OptionParser.new
opt.parse!(ARGV)

marks = ARGV[0].split(',')
game = Game.new(marks)
puts game.score
