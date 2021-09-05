# frozen_string_literal: true

require 'etc'
require 'time'

module LS
  class Status
    def initialize(file)
      @file = file
    end

    def length
      @file.length
    end

    def empty?
      @file.empty?
    end

    def ljust(width, padding = ' ')
      @file.ljust(width, padding)
    end

    def padding(value, width)
      if width.nil?
        value
      else
        margin = /\A[0-9]+\z/.match?(value) ? 1 : 0
        value.rjust(width + margin)
      end
    end

    def generate(widths = [])
      [permissions,
       padding(number_of_hard_links, widths[1]),
       padding(user_and_group_name_of_owner, widths[2]),
       padding(bytes, widths[3]),
       padding(modification_time, widths[4]),
       file_name]
    end

    def blocks
      status.blocks
    end

    private

    def file_type_char(value)
      { 0o01 => 'P', 0o02 => 'c', 0o04 => 'd', 0o06 => 'b', 0o10 => '-', 0o12 => 'l', 0o14 => 's' }[value]
    end

    def file_access_char(value, is_special, special_char)
      file_access = ''

      file_access += (value[0] == '1' ? 'r' : '-')
      file_access += (value[1] == '1' ? 'w' : '-')
      file_access += if value[2] == '1'
                       is_special ? special_char : 'x'
                     else
                       is_special ? special_char.upcase : '-'
                     end

      file_access
    end

    def status
      @status ||= ::File.lstat(@file)
    end

    def file_type
      status.mode.to_s(8).chars[0..-5].join
    end

    def special_type
      status.mode.to_s(8).chars[-4]
    end

    def access_type
      status.mode.to_s(2).chars[-9..-1].join
    end

    def permissions
      file_type_char(file_type.to_i(8)) +
        file_access_char(access_type[0..2], special_type == '4', 's') +
        file_access_char(access_type[3..5], special_type == '2', 's') +
        file_access_char(access_type[6..8], special_type == '1', 't')
    end

    def number_of_hard_links
      status.nlink.to_s
    end

    def user_and_group_name_of_owner
      "#{Etc.getpwuid(status.uid).name}  #{Etc.getgrgid(status.gid).name}"
    end

    def bytes
      status.size.to_s
    end

    def modification_time
      mtime = status.mtime
      (Time.now - mtime).quo(86_400) >= 182 ? mtime.strftime('%_m %_d  %Y') : mtime.strftime('%_m %_d %R')
    end

    def file_name
      ::File.ftype(@file) == 'link' ? "#{@file} -> #{File.readlink(@file)}" : @file
    end
  end
end
