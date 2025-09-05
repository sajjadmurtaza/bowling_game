# frozen_string_literal: true

module BowlingGame
  module Frame
    # Base class for all frame types
    # Follows Open/Closed Principle - open for extension, closed for modification
    class Base
      MAX_PINS = 10

      attr_reader :rolls

      def initialize(rolls)
        @rolls = rolls.freeze
      end

      # Calculate base score for this frame (sum of pins knocked down)
      # @return [Integer] Base score
      def base_score
        rolls.sum
      end

      # Check if this frame is a strike
      # @return [Boolean] True if strike
      def strike?
        false
      end

      # Check if this frame is a spare
      # @return [Boolean] True if spare
      def spare?
        false
      end

      # Get bonus multiplier for scoring
      # @return [Integer] Multiplier for bonus calculations
      def bonus_multiplier
        0
      end

      # Get pins available for bonus calculation
      # @param count [Integer] Number of pins needed for bonus
      # @return [Array<Integer>] Pins for bonus calculation
      def bonus_pins(count = 2)
        rolls.take(count)
      end
    end

    # Regular frame (no strike or spare)
    class Regular < Base
      def initialize(rolls)
        super
        validate_rolls!
      end

      private

      def validate_rolls!
        raise ArgumentError, 'Regular frame cannot have more than 2 rolls' if rolls.length > 2

        return unless rolls.sum > MAX_PINS

        raise ArgumentError, 'Cannot knock down more than 10 pins in regular frame'
      end
    end

    # Strike frame (10 pins in first roll)
    class Strike < Base
      def initialize(rolls)
        super
        validate_rolls!
      end

      def strike?
        true
      end

      def bonus_multiplier
        2
      end

      private

      def validate_rolls!
        return if rolls.length == 1 && rolls.first == MAX_PINS

        raise ArgumentError, 'Strike frame must have exactly one roll of 10'
      end
    end

    # Spare frame (10 pins in two rolls)
    class Spare < Base
      def initialize(rolls)
        super
        validate_rolls!
      end

      def spare?
        true
      end

      def bonus_multiplier
        1
      end

      private

      def validate_rolls!
        return if rolls.length == 2 && rolls.sum == MAX_PINS

        raise ArgumentError, 'Spare frame must have exactly 2 rolls summing to 10'
      end
    end

    # Tenth frame (special rules for strikes and spares)
    class Tenth < Base
      def initialize(rolls)
        super
        validate_rolls!
      end

      def strike?
        rolls.first == MAX_PINS
      end

      def spare?
        !strike? && rolls.length >= 2 && rolls[0] + rolls[1] == MAX_PINS
      end

      # Tenth frame doesn't provide bonus to other frames
      def bonus_multiplier
        0
      end

      # Tenth frame uses all its rolls for scoring
      def base_score
        rolls.sum
      end

      private

      def validate_rolls!
        validate_roll_count!

        case rolls.length
        when 1 then validate_single_roll!
        when 2 then validate_two_rolls!
        when 3 then validate_three_rolls!
        end
      end

      def validate_roll_count!
        raise ArgumentError, 'Tenth frame must have 1-3 rolls' unless rolls.length.between?(1, 3)
      end

      def validate_single_roll!
        return unless rolls.first >= MAX_PINS

        raise ArgumentError, 'Tenth frame with one roll must be less than 10 (incomplete)'
      end

      def validate_two_rolls!
        if strike_in_first_roll?
          validate_second_roll_after_strike!
        elsif rolls.sum > MAX_PINS
          raise ArgumentError, 'First two rolls cannot exceed 10 pins in tenth frame'
        end
      end

      def validate_three_rolls!
        if strike_in_first_roll?
          validate_tenth_frame_after_strike!
        elsif spare_in_first_two_rolls?
          validate_third_roll_after_spare!
        else
          raise ArgumentError, 'Tenth frame can only have 3 rolls after strike or spare'
        end
      end

      def validate_second_roll_after_strike!
        return if rolls[1].between?(0, MAX_PINS)

        raise ArgumentError, 'Invalid second roll after strike in tenth frame'
      end

      def validate_third_roll_after_spare!
        return if rolls[2].between?(0, MAX_PINS)

        raise ArgumentError, 'Invalid third roll after spare in tenth frame'
      end

      def validate_tenth_frame_after_strike!
        second_roll = rolls[1]
        third_roll = rolls[2]

        # If second roll is a strike, third can be anything
        return if second_roll == MAX_PINS

        # If second roll is not a strike, second + third cannot exceed 10
        # unless third roll is after a spare (second + third == 10)
        return unless second_roll + third_roll > MAX_PINS

        raise ArgumentError, 'Invalid roll combination in tenth frame after strike'
      end

      def strike_in_first_roll?
        rolls.first == MAX_PINS
      end

      def spare_in_first_two_rolls?
        rolls[0] + rolls[1] == MAX_PINS
      end
    end
  end
end
