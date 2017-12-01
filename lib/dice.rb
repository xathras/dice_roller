require_relative './dice/die.rb'

module Dice
  def self.d4
    Die.new(4)
  end

  def self.d6
    Die.new
  end

  def self.d8
    Die.new(8)
  end

  def self.d10
    Die.new(10)
  end

  def self.d12
    Die.new(12)
  end

  def self.d20
    Die.new(20)
  end
end
