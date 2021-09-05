# frozen_string_literal: true

module LS
  module Layout
    module Normal
      def layout_normal(paths, cols = 3)
        rows = paths.length.quo(cols).ceil
        size = rows * cols
        max_length = paths.max_by(&:length).length

        paths += Array.new(size - paths.size, LS::Status.new(''))

        files = ''
        paths.each_slice(rows).to_a.transpose.flatten.each_with_index do |path, index|
          files += path.ljust(max_length + 2)
          files += "\n" if index % cols == cols - 1
        end

        files
      end
    end

    module Detail
      def layout_detail(paths)
        max_widths = paths.map(&:generate).transpose.map { |col| col.max_by(&:length).length }

        total_blocks = 0
        files = []

        paths.each do |path|
          total_blocks += path.blocks
          files << path.generate(max_widths).join(' ')
        end

        "total #{total_blocks}\n#{files.join("\n")}"
      end
    end
  end
end
