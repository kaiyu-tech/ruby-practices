#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require './list'

opt = OptionParser.new

options = {}

opt.on('-a') { |v| options[:all] = v }
opt.on('-l') { |v| options[:detail] = v }
opt.on('-r') { |v| options[:reverse] = v }

opt.parse!(ARGV)

target_path = ARGV[0]

list = LS::List.new(options, target_path)

puts list.layout
