# frozen_string_literal: true

module BowlingGame
  # Convenience class for easy scoring with array input format
  # Provides a simple interface for the problem's expected input format
  class Convenience
    # Calculate bowling score from array of frames
    # @param frames_data [Array<Array<Integer>>] Array of frame data
    # @return [Integer] Total game score
    # @example
    #   BowlingGame::Convenience.score([[5,3], [10], [4,6]]) #=> 38
    def self.score(frames_data)
      validate_input!(frames_data)

      game = Game.new
      frames_data.each { |frame_rolls| game.add_frame(frame_rolls) }
      game.score
    end

    # Create a game from array input for more complex operations
    # @param frames_data [Array<Array<Integer>>] Array of frame data
    # @return [Game] Configured bowling game
    def self.create_game(frames_data)
      validate_input!(frames_data)

      game = Game.new
      frames_data.each { |frame_rolls| game.add_frame(frame_rolls) }
      game
    end

    private_class_method def self.validate_input!(frames_data)
      raise ArgumentError, 'Input must be an array' unless frames_data.is_a?(Array)
      raise ArgumentError, 'Input cannot be empty' if frames_data.empty?
      raise ArgumentError, 'Cannot have more than 10 frames' if frames_data.length > Game::MAX_FRAMES

      frames_data.each_with_index do |frame_rolls, index|
        raise ArgumentError, "Frame #{index + 1} must be an array" unless frame_rolls.is_a?(Array)
      end
    end
  end
end
