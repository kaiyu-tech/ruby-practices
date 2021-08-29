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
        @frames.last.push(mark)
      else
        bonus(marks, index)
        @frames << Frame.new(mark)
      end
    end
  end

  def bonus(marks, current)
    if @frames.last&.strike?
      @frames.last.bonus([marks[current], marks[current.next]])
    elsif @frames.last&.spare?
      @frames.last.bonus([marks[current]])
    end
  end

  def final?
    @frames.count == 10
  end

  def score
    @frames.map(&:score).sum
  end
end
