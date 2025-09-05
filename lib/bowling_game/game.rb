# frozen_string_literal: true

module BowlingGame
  # Main class responsible for managing a bowling game and calculating the total score
  # Follows Single Responsibility Principle - only manages game state and delegates scoring
  class Game
    MAX_FRAMES = 10
    MAX_PINS = 10

    attr_reader :frames, :current_frame_index

    def initialize
      @frames = []
      @current_frame_index = 0
    end

    # Add a frame to the game
    # @param rolls [Array<Integer>] Array of pin counts for this frame
    # @return [self] Returns self for method chaining
    def add_frame(rolls)
      validate_frame_input!(rolls)
      validate_game_not_complete!

      frame = create_frame(rolls)
      @frames << frame
      @current_frame_index += 1

      self
    end

    # Calculate and return the total score for the game
    # @return [Integer] Total score
    def score
      BowlingScorer.new(frames.dup).calculate
    end

    # Check if the game is complete
    # @return [Boolean] True if all frames have been played
    def complete?
      frames.length == MAX_FRAMES
    end

    # Get the current frame number (1-indexed for display)
    # @return [Integer] Current frame number
    def current_frame
      current_frame_index + 1
    end

    private

    # Create appropriate frame type based on frame number and rolls
    # @param rolls [Array<Integer>] Pin counts for this frame
    # @return [Frame::Base] Appropriate frame instance
    def create_frame(rolls)
      if tenth_frame?
        Frame::Tenth.new(rolls)
      elsif strike?(rolls)
        Frame::Strike.new(rolls)
      elsif spare?(rolls)
        Frame::Spare.new(rolls)
      else
        Frame::Regular.new(rolls)
      end
    end

    # Check if current frame is the tenth frame
    # @return [Boolean] True if this is the tenth frame
    def tenth_frame?
      current_frame_index == MAX_FRAMES - 1
    end

    # Check if rolls represent a strike
    # @param rolls [Array<Integer>] Pin counts
    # @return [Boolean] True if first roll is 10
    def strike?(rolls)
      rolls.first == MAX_PINS
    end

    # Check if rolls represent a spare
    # @param rolls [Array<Integer>] Pin counts
    # @return [Boolean] True if two rolls sum to 10
    def spare?(rolls)
      rolls.length == 2 && rolls.sum == MAX_PINS
    end

    # Validate frame input
    # @param rolls [Array<Integer>] Pin counts to validate
    # @raise [ArgumentError] If input is invalid
    def validate_frame_input!(rolls)
      raise ArgumentError, 'Rolls must be an array' unless rolls.is_a?(Array)
      raise ArgumentError, 'Rolls cannot be empty' if rolls.empty?
      raise ArgumentError, 'Invalid pin count' unless valid_pin_counts?(rolls)

      return if tenth_frame?

      validate_regular_frame_rolls!(rolls)
    end

    # Validate that pin counts are valid integers
    # @param rolls [Array<Integer>] Pin counts to validate
    # @return [Boolean] True if all pin counts are valid
    def valid_pin_counts?(rolls)
      rolls.all? { |roll| roll.is_a?(Integer) && roll >= 0 && roll <= MAX_PINS }
    end

    # Validate regular frame (non-tenth) rolls
    # @param rolls [Array<Integer>] Pin counts to validate
    # @raise [ArgumentError] If rolls are invalid for regular frames
    def validate_regular_frame_rolls!(rolls)
      raise ArgumentError, 'Regular frames can have at most 2 rolls' if rolls.length > 2

      return unless rolls.length == 2 && rolls.sum > MAX_PINS

      raise ArgumentError, 'Cannot knock down more than 10 pins in a frame'
    end

    # Validate that game is not already complete
    # @raise [StandardError] If game is already complete
    def validate_game_not_complete!
      raise StandardError, 'Game is already complete' if complete?
    end
  end
end
