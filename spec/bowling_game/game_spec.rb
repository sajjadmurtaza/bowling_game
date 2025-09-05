# frozen_string_literal: true

RSpec.describe BowlingGame::Game do
  subject(:game) { described_class.new }

  describe '#initialize' do
    it 'starts with no frames' do
      expect(game.frames).to be_empty
    end

    it 'starts at frame 1' do
      expect(game.current_frame).to eq(1)
    end

    it 'is not complete initially' do
      expect(game).not_to be_complete
    end
  end

  describe '#add_frame' do
    context 'with valid input' do
      it 'adds a regular frame' do
        game.add_frame([3, 4])
        expect(game.frames.length).to eq(1)
        expect(game.frames.first).to be_a(BowlingGame::Frame::Regular)
      end

      it 'adds a strike frame' do
        game.add_frame([10])
        expect(game.frames.first).to be_a(BowlingGame::Frame::Strike)
      end

      it 'adds a spare frame' do
        game.add_frame([7, 3])
        expect(game.frames.first).to be_a(BowlingGame::Frame::Spare)
      end

      it 'returns self for method chaining' do
        result = game.add_frame([3, 4])
        expect(result).to eq(game)
      end

      it 'increments current frame' do
        expect { game.add_frame([3, 4]) }.to change(game, :current_frame).by(1)
      end
    end

    context 'with invalid input' do
      it 'raises error for non-array input' do
        expect { game.add_frame('invalid') }.to raise_error(ArgumentError, 'Rolls must be an array')
      end

      it 'raises error for empty array' do
        expect { game.add_frame([]) }.to raise_error(ArgumentError, 'Rolls cannot be empty')
      end

      it 'raises error for negative pins' do
        expect { game.add_frame([-1, 5]) }.to raise_error(ArgumentError, 'Invalid pin count')
      end

      it 'raises error for pins > 10' do
        expect { game.add_frame([11]) }.to raise_error(ArgumentError, 'Invalid pin count')
      end

      it 'raises error for non-integer pins' do
        expect { game.add_frame([3.5, 4]) }.to raise_error(ArgumentError, 'Invalid pin count')
      end

      it 'raises error for too many pins in regular frame' do
        expect do
          game.add_frame([6, 5])
        end.to raise_error(ArgumentError, 'Cannot knock down more than 10 pins in a frame')
      end

      it 'raises error for too many rolls in regular frame' do
        expect { game.add_frame([3, 4, 2]) }.to raise_error(ArgumentError, 'Regular frames can have at most 2 rolls')
      end
    end

    context 'when game is complete' do
      before do
        10.times { game.add_frame([3, 4]) }
      end

      it 'raises error when trying to add another frame' do
        expect { game.add_frame([3, 4]) }.to raise_error(StandardError, 'Game is already complete')
      end
    end

    context 'with tenth frame' do
      before do
        9.times { game.add_frame([3, 4]) }
      end

      it 'creates a tenth frame' do
        game.add_frame([10, 5, 3])
        expect(game.frames.last).to be_a(BowlingGame::Frame::Tenth)
      end
    end
  end

  describe '#complete?' do
    it 'returns false when less than 10 frames' do
      9.times { game.add_frame([3, 4]) }
      expect(game).not_to be_complete
    end

    it 'returns true when 10 frames are complete' do
      10.times { game.add_frame([3, 4]) }
      expect(game).to be_complete
    end
  end

  describe '#score' do
    context 'with example from problem description' do
      it 'calculates score correctly for [[5,3], [10], [4,6]]' do
        game.add_frame([5, 3])  # 8 points
        game.add_frame([10])    # 10 + 10 (4+6 bonus) = 20 points
        game.add_frame([4, 6])  # 10 points (spare, but no next frame for bonus)

        expect(game.score).to eq(38)
      end
    end

    context 'with all strikes (perfect game)' do
      it 'calculates 300 points' do
        9.times { game.add_frame([10]) }
        game.add_frame([10, 10, 10]) # Tenth frame with three strikes

        expect(game.score).to eq(300)
      end
    end

    context 'with all spares' do
      it 'calculates correctly' do
        9.times { game.add_frame([5, 5]) }
        game.add_frame([5, 5, 5]) # Tenth frame spare with 5 bonus

        # Each spare frame gets 10 + next roll bonus
        # First 9 frames: 9 × (10 + 5) = 135
        # Tenth frame: 5 + 5 + 5 = 15
        # Total: 150
        expect(game.score).to eq(150)
      end
    end

    context 'with all gutter balls' do
      it 'calculates 0 points' do
        10.times { game.add_frame([0, 0]) }
        expect(game.score).to eq(0)
      end
    end

    context 'with mixed frames' do
      it 'calculates correctly' do
        game.add_frame([1, 4])   # 5 points
        game.add_frame([4, 5])   # 9 points
        game.add_frame([6, 4])   # 10 + 5 = 15 points (spare + next roll)
        game.add_frame([5, 5])   # 10 + 10 = 20 points (spare + strike)
        game.add_frame([10])     # 10 + 10 = 20 points (strike + spare)
        game.add_frame([0, 1])   # 1 point
        game.add_frame([7, 3])   # 10 + 6 = 16 points (spare + next roll)
        game.add_frame([6, 4])   # 10 + 10 = 20 points (spare + strike)
        game.add_frame([10])     # 10 + 2 + 8 = 20 points (strike + next two rolls)
        game.add_frame([2, 8, 6]) # 16 points (spare in tenth frame)

        # Total: 5 + 9 + 15 + 20 + 11 + 1 + 16 + 20 + 20 + 16 = 133
        expect(game.score).to eq(133)
      end
    end
  end
end
