# frozen_string_literal: true

require './frame'

class Game
  def initialize(marks)
    @frames = []
    parse(marks)
  end

  def parse(marks)
    marks.each_with_index do |mark, index|
      if @frames.last&.continue? || final?
        @frames.last << mark
      else
        @frames.last&.calc_bonus(marks[index..index.next])
        @frames << Frame.new(mark)
      end
    end
  end

  def score
    @frames.map(&:score).sum
  end

  private

  def final?
    @frames.count == 10
  end
end
