#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/bowling_game'

puts 'Bowling Game - Error Handling Examples'
puts '=' * 40

error_cases = [
  { input: [[11]], desc: 'Pin count > 10' },
  { input: [[-1]], desc: 'Negative pin count' },
  { input: [[6, 5]], desc: 'Too many pins in frame' },
  { input: [[]], desc: 'Empty frame' },
  { input: [[3, 4, 2]], desc: 'Too many rolls in regular frame' },
  { input: ['invalid'], desc: 'Non-array frame' }
]

puts 'Input validation tests:'
error_cases.each do |test_case|
  BowlingGame::Convenience.score(test_case[:input])
  puts "FAIL: #{test_case[:desc]} - should have raised error"
rescue ArgumentError => e
  puts "PASS: #{test_case[:desc]} - #{e.message}"
rescue StandardError => e
  puts "PARTIAL: #{test_case[:desc]} - #{e.class}: #{e.message}"
end

# Game state errors
puts "\nGame state validation:"
begin
  game = BowlingGame::Game.new
  10.times { game.add_frame([3, 4]) } # Complete game
  game.add_frame([5, 3]) # Try to add 11th frame
  puts 'FAIL: Should prevent adding frame to completed game'
rescue StandardError => e
  puts "PASS: Game completion validation - #{e.message}"
end

# Graceful error recovery
puts "\nGraceful error recovery:"
game = BowlingGame::Game.new
valid_frames = [[7, 3], [5, 4]]
invalid_frames = [[15], [6, 5]]

(valid_frames + invalid_frames).each do |frame|
  game.add_frame(frame)
  puts "Added #{frame.inspect} successfully"
rescue ArgumentError => e
  puts "Rejected #{frame.inspect}: #{e.message}"
end

puts "Final game state: #{game.frames.length} frames, score: #{game.score}"

puts "\n#{'=' * 40}"
puts 'Error handling examples complete'
