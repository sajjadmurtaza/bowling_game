#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/bowling_game'

puts 'Comprehensive Bowling Game Test Suite'
puts '=' * 40

tests = [
  {
    name: 'Original problem',
    frames: [[5, 3], [10], [4, 6]],
    expected: 38
  },
  {
    name: 'Perfect game',
    frames: Array.new(9) { [10] } + [[10, 10, 10]],
    expected: 300
  },
  {
    name: 'All spares',
    frames: Array.new(9) { [5, 5] } + [[5, 5, 5]],
    expected: 150
  },
  {
    name: 'All gutters',
    frames: Array.new(10) { [0, 0] },
    expected: 0
  },
  {
    name: 'Mixed game',
    frames: [[1, 4], [4, 5], [6, 4], [5, 5], [10], [0, 1], [7, 3], [6, 4], [10], [2, 8, 6]],
    expected: 133
  }
]

passed = 0
tests.each do |test|
  result = BowlingGame::Convenience.score(test[:frames])
  status = result == test[:expected] ? 'PASS' : 'FAIL'
  puts "#{status}: #{test[:name]} - #{result} (expected #{test[:expected]})"
  passed += 1 if status == 'PASS'
end

# Test error handling
puts "\nError Handling Tests:"
errors = 0

test_cases = [
  { input: [[11]], error: 'Invalid pin count' },
  { input: [[6, 5]], error: 'Cannot knock down more than 10 pins' },
  { input: [[]], error: 'Rolls cannot be empty' }
]

test_cases.each do |test_case|
  BowlingGame::Convenience.score(test_case[:input])
  puts "FAIL: Should have raised error for #{test_case[:input]}"
rescue ArgumentError => e
  if e.message.include?(test_case[:error])
    puts "PASS: Error handling - #{test_case[:error]}"
    errors += 1
  else
    puts "FAIL: Wrong error message - #{e.message}"
  end
end

puts "\n#{'=' * 40}"
puts "Results: #{passed}/#{tests.length} scoring tests passed"
puts "         #{errors}/#{test_cases.length} error tests passed"
puts "Overall: #{passed + errors == tests.length + test_cases.length ? 'ALL PASS' : 'SOME FAILED'}"
