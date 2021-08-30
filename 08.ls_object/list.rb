# frozen_string_literal: true

require './status'
require './layout'

module LS
  class List
    include LS::Layout::Normal
    include LS::Layout::Detail

    def initialize(options, target_path)
      @paths = []
      @options = options

      change(target_path)

      parse
    end

    def layout
      if @options[:detail]
        layout_detail(@paths)
      else
        layout_normal(@paths)
      end
    end

    private

    def change(target_path)
      Dir.chdir(target_path) unless target_path.nil?
    end

    def paths
      mach_flag = @options[:all] ? File::FNM_DOTMATCH : 0
      paths = Dir.glob('*', mach_flag)
      paths.reverse! if @options[:reverse]
      paths
    end

    def parse
      paths.each do |path|
        @paths << LS::Status.new(path)
      end
    end
  end
end
