# frozen_string_literal: true

require './shot'

class Frame
  def initialize(mark)
    @shots = [Shot.new(mark)]
    @bonuses = []
  end

  def <<(mark)
    @shots << Shot.new(mark)
    self
  end

  def calc_bonus(marks)
    if strike?
      @bonuses << Shot.new(marks[0]) << Shot.new(marks[1])
    elsif spare?
      @bonuses << Shot.new(marks[0])
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
end
