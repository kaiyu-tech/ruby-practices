# frozen_string_literal: true

require './shot'

class Frame
  def initialize(mark)
    @shots = [Shot.new(mark)]
    @bonuses = []
  end

  def push(mark)
    @shots << Shot.new(mark)
    self
  end

  def calc_bonus(marks, current)
    if strike?
      push_bonuses([marks[current], marks[current.next]])
    elsif spare?
      push_bonuses([marks[current]])
    end
  end

  def score
    @shots.map(&:score).sum + @bonuses.map(&:score).sum
  end

  def continue?
    score != 10 && @shots.count != 2
  end

  private

  def strike?
    score == 10 && @shots.count == 1
  end

  def spare?
    score == 10 && @shots.count == 2
  end

  def push_bonuses(marks)
    marks.each do |mark|
      @bonuses << Shot.new(mark)
    end
  end
end
