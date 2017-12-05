# frozen_string_literal: true

require 'sinatra'
require 'sinatra/json'
require 'json'
require_relative './lib/dice'

get '/' do
  erb :index, layout: :layout
end

get '/roller' do
  erb :roller, layout: :layout
end

get '/roll' do
  dice = Array.new(params['num'].to_i) { Dice.public_send("d#{params['sides']}") }
  output = dice.map(&:roll).reduce(:+) + params['mod'].to_i
  json data: { output: output.to_s }
end

get '/stat-generator' do
  erb :stat_list, layout: :layout
end

get '/generate-stats' do
  roll_list = Array.new(7) do
    Array.new(4) { Dice.d6.roll }.sort.reverse.take(3).reduce(&:+)
  end.sort.reverse.take(6)
  json data: { output: roll_list }
end
