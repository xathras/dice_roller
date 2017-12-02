# frozen_string_literal: true

require 'sinatra'
require 'sinatra/json'
require 'json'
require_relative './lib/dice'

get '/' do
  erb :roller, layout: :layout
end

get '/roll' do
  dice = Array.new(params['num'].to_i) { Dice.public_send("d#{params['sides']}") }
  output = dice.map(&:roll).reduce(:+) + params['mod'].to_i
  json data: { output: output.to_s }
end
