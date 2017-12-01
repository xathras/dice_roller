require 'spec_helper'

module Dice
  RSpec.describe Die do
    it 'should be able to roll the maximum value, but no higher' do
      list = Array.new(50) { Dice.d6 }.map(&:roll)

      expect(list).to include(6)
      expect(list).not_to include(7)
    end
  end
end
