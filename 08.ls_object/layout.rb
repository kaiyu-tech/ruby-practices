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
        total_blocks, cols = generate(paths)

        files = ''
        rows = cols[0].length
        (0...rows).each do |index|
          cols.each do |col|
            files += if cols.first == col
                       col[index]
                     elsif cols.last == col
                       " #{col[index]}\n"
                     else
                       margin = /\A[0-9]+\z/.match?(col[index]) ? 2 : 1
                       col[index].rjust(col.max_by(&:length).length + margin)
                     end
          end
        end

        "total #{total_blocks}\n#{files}"
      end

      private

      def generate(paths)
        rows = []

        total_blocks = 0

        paths.each do |path|
          total_blocks += path.blocks
          rows << path.generate
        end

        [total_blocks, rows.transpose]
      end
    end
  end
end
