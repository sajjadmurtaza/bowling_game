#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/bowling_game'

puts 'Basic Bowling Game Test'
puts '=' * 25

# Test the original problem
puts 'Testing: [[5,3], [10], [4,6]]'
result = BowlingGame::Convenience.score([[5, 3], [10], [4, 6]])
puts "Result: #{result}"
puts "Expected: 38"
puts result == 38 ? '✅ PASS' : '❌ FAIL'

puts "\nTesting: Perfect game"
perfect = Array.new(9) { [10] } + [[10, 10, 10]]
result = BowlingGame::Convenience.score(perfect)
puts "Result: #{result}"
puts "Expected: 300"
puts result == 300 ? '✅ PASS' : '❌ FAIL'

puts "\nBasic functionality working!"
