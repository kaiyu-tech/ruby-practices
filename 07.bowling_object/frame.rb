# frozen_string_literal: true

require './shot'

class Frame
  def initialize(mark)
    @shots = [Shot.new(mark)]
    @bonus = []
  end

  def push(mark)
    @shots << Shot.new(mark)
    self
  end

  def bonus(marks)
    marks.each do |mark|
      @bonus << Shot.new(mark)
    end
  end

  def score
    @shots.map(&:score).sum + @bonus.map(&:score).sum
  end

  def continue?
    score != 10 && @shots.count != 2
  end

  def strike?
    score == 10 && @shots.count == 1
  end

  def spare?
    score == 10 && @shots.count == 2
  end
end
