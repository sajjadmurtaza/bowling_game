# frozen_string_literal: true

# Main module for the Bowling Game scoring system
# Provides a clean, object-oriented approach to bowling score calculation
module BowlingGame
  # Version information
  VERSION = '1.0.0'
end

# Require all the necessary files
require_relative 'bowling_game/frame'
require_relative 'bowling_game/bowling_scorer'
require_relative 'bowling_game/game'
require_relative 'bowling_game/convenience'
