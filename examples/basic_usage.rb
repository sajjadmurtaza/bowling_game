#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/bowling_game'

puts 'Bowling Game - Basic Usage Examples'
puts '=' * 35

# Simple scoring
puts '1. Simple scoring:'
score = BowlingGame::Convenience.score([[5, 3], [10], [4, 6]])
puts "   BowlingGame::Convenience.score([[5,3], [10], [4,6]]) => #{score}"

# Step-by-step game building
puts "\n2. Step-by-step game building:"
game = BowlingGame::Game.new
game.add_frame([5, 3]).add_frame([10]).add_frame([4, 6])
puts '   game.add_frame([5,3]).add_frame([10]).add_frame([4,6])'
puts "   game.score => #{game.score}"

# Processing multiple games
puts "\n3. Processing multiple games:"
games = [[[5, 3], [10], [4, 6]], [[10], [10], [5, 3]]]
games.each_with_index do |frames, i|
  score = BowlingGame::Convenience.score(frames)
  puts "   Game #{i + 1}: #{score} points"
end

# Game state inspection
puts "\n4. Game state inspection:"
puts "   game.current_frame => #{game.current_frame}"
puts "   game.complete? => #{game.complete?}"
puts "   game.frames.length => #{game.frames.length}"

puts "\n#{'=' * 35}"
puts 'Basic usage examples complete'
