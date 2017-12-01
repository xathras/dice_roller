require 'securerandom'

module Dice
  class Die
    def initialize(sides = 6.0)
      @sides = sides.to_f
    end

    def roll
      ((SecureRandom.random_number * @sides) + 1).floor
    end
  end
end
