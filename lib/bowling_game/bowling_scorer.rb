# frozen_string_literal: true

module BowlingGame
  # Service responsible for calculating bowling scores
  # Follows Single Responsibility Principle - only handles score calculation
  # Uses Dependency Injection for testability
  class BowlingScorer
    MAX_FRAMES = 10

    attr_reader :frames

    def initialize(frames)
      @frames = frames.freeze
    end

    # Calculate total score for all frames
    # @return [Integer] Total game score
    def calculate
      total_score = 0

      frames.each_with_index do |frame, index|
        total_score += calculate_frame_score(frame, index)
      end

      total_score
    end

    private

    # Calculate score for a specific frame including bonuses
    # @param frame [Frame::Base] Frame to calculate score for
    # @param frame_index [Integer] Index of the frame (0-based)
    # @return [Integer] Score for this frame including bonuses
    def calculate_frame_score(frame, frame_index)
      base_score = frame.base_score
      bonus_score = calculate_bonus_score(frame, frame_index)

      base_score + bonus_score
    end

    # Calculate bonus score for strikes and spares
    # @param frame [Frame::Base] Frame to calculate bonus for
    # @param frame_index [Integer] Index of the frame (0-based)
    # @return [Integer] Bonus score
    def calculate_bonus_score(frame, frame_index)
      return 0 unless frame.strike? || frame.spare?
      return 0 if tenth_frame?(frame_index) # Tenth frame doesn't get bonus from future frames

      bonus_pins = get_bonus_pins(frame, frame_index)
      bonus_pins.sum
    end

    # Get pins for bonus calculation from subsequent frames
    # @param frame [Frame::Base] Frame needing bonus pins
    # @param frame_index [Integer] Index of the current frame
    # @return [Array<Integer>] Pins for bonus calculation
    def get_bonus_pins(frame, frame_index)
      pins_needed = frame.strike? ? 2 : 1
      pins = []

      current_frame_index = frame_index + 1

      while pins.length < pins_needed && current_frame_index < frames.length
        next_frame = frames[current_frame_index]
        available_pins = next_frame.bonus_pins(pins_needed - pins.length)
        pins.concat(available_pins)
        current_frame_index += 1
      end

      pins.take(pins_needed)
    end

    # Check if frame index represents the tenth frame
    # @param frame_index [Integer] Frame index (0-based)
    # @return [Boolean] True if tenth frame
    def tenth_frame?(frame_index)
      frame_index == MAX_FRAMES - 1
    end
  end
end
