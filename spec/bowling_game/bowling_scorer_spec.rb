# frozen_string_literal: true

RSpec.describe BowlingGame::BowlingScorer do
  describe '#calculate' do
    context 'with regular frames only' do
      it 'calculates sum of all pins' do
        frames = [
          BowlingGame::Frame::Regular.new([3, 4]),
          BowlingGame::Frame::Regular.new([2, 5]),
          BowlingGame::Frame::Regular.new([1, 1])
        ]
        scorer = described_class.new(frames)

        expect(scorer.calculate).to eq(16)
      end
    end

    context 'with strikes' do
      it 'calculates strike bonus correctly' do
        frames = [
          BowlingGame::Frame::Strike.new([10]),
          BowlingGame::Frame::Regular.new([3, 4])
        ]
        scorer = described_class.new(frames)

        # Strike: 10 + (3 + 4) = 17
        # Regular: 3 + 4 = 7
        # Total: 24
        expect(scorer.calculate).to eq(24)
      end

      it 'calculates consecutive strikes correctly' do
        frames = [
          BowlingGame::Frame::Strike.new([10]),
          BowlingGame::Frame::Strike.new([10]),
          BowlingGame::Frame::Regular.new([3, 4])
        ]
        scorer = described_class.new(frames)

        # First strike: 10 + (10 + 3) = 23
        # Second strike: 10 + (3 + 4) = 17
        # Regular: 3 + 4 = 7
        # Total: 47
        expect(scorer.calculate).to eq(47)
      end
    end

    context 'with spares' do
      it 'calculates spare bonus correctly' do
        frames = [
          BowlingGame::Frame::Spare.new([7, 3]),
          BowlingGame::Frame::Regular.new([4, 2])
        ]
        scorer = described_class.new(frames)

        # Spare: 10 + 4 * 1 = 14
        # Regular: 4 + 2 = 6
        # Total: 20
        expect(scorer.calculate).to eq(20)
      end

      it 'calculates spare followed by strike correctly' do
        frames = [
          BowlingGame::Frame::Spare.new([7, 3]),
          BowlingGame::Frame::Strike.new([10])
        ]
        scorer = described_class.new(frames)

        # Spare: 10 + 10 * 1 = 20
        # Strike: 10 (no bonus, no next frame)
        # Total: 30
        expect(scorer.calculate).to eq(30)
      end
    end

    context 'with tenth frame' do
      it 'does not give bonus to tenth frame' do
        frames = [
          BowlingGame::Frame::Strike.new([10]),
          BowlingGame::Frame::Tenth.new([5, 3])
        ]
        scorer = described_class.new(frames)

        # Strike: 10 + (5 + 3) = 18
        # Tenth: 5 + 3 = 8 (no bonus from future frames)
        # Total: 26
        expect(scorer.calculate).to eq(26)
      end

      it 'calculates tenth frame with strike correctly' do
        frames = [
          BowlingGame::Frame::Regular.new([3, 4]),
          BowlingGame::Frame::Tenth.new([10, 5, 3])
        ]
        scorer = described_class.new(frames)

        # Regular: 3 + 4 = 7
        # Tenth: 10 + 5 + 3 = 18
        # Total: 25
        expect(scorer.calculate).to eq(25)
      end

      it 'calculates tenth frame with spare correctly' do
        frames = [
          BowlingGame::Frame::Regular.new([3, 4]),
          BowlingGame::Frame::Tenth.new([7, 3, 5])
        ]
        scorer = described_class.new(frames)

        # Regular: 3 + 4 = 7
        # Tenth: 7 + 3 + 5 = 15
        # Total: 22
        expect(scorer.calculate).to eq(22)
      end
    end

    context 'with perfect game (all strikes)' do
      it 'calculates 300 points' do
        frames = []
        9.times { frames << BowlingGame::Frame::Strike.new([10]) }
        frames << BowlingGame::Frame::Tenth.new([10, 10, 10])

        scorer = described_class.new(frames)
        expect(scorer.calculate).to eq(300)
      end
    end

    context 'with all spares' do
      it 'calculates correctly when all rolls are 5' do
        frames = []
        9.times { frames << BowlingGame::Frame::Spare.new([5, 5]) }
        frames << BowlingGame::Frame::Tenth.new([5, 5, 5])

        scorer = described_class.new(frames)
        # Each of first 9 frames: 10 + 5 = 15
        # Tenth frame: 5 + 5 + 5 = 15
        # Total: 9 * 15 + 15 = 150
        expect(scorer.calculate).to eq(150)
      end
    end

    context 'with complex scenarios' do
      it 'handles strike in ninth frame correctly' do
        frames = []
        8.times { frames << BowlingGame::Frame::Regular.new([3, 4]) }
        frames << BowlingGame::Frame::Strike.new([10])
        frames << BowlingGame::Frame::Tenth.new([7, 3, 5])

        scorer = described_class.new(frames)

        # 8 regular frames: 8 * 7 = 56
        # Strike in 9th: 10 + (7 + 3) = 20
        # Tenth: 7 + 3 + 5 = 15
        # Total: 91
        expect(scorer.calculate).to eq(91)
      end

      it 'handles spare in ninth frame correctly' do
        frames = []
        8.times { frames << BowlingGame::Frame::Regular.new([3, 4]) }
        frames << BowlingGame::Frame::Spare.new([6, 4])
        frames << BowlingGame::Frame::Tenth.new([7, 2])

        scorer = described_class.new(frames)

        # 8 regular frames: 8 * 7 = 56
        # Spare in 9th: 10 + 7 * 1 = 17
        # Tenth: 7 + 2 = 9
        # Total: 82
        expect(scorer.calculate).to eq(82)
      end
    end

    context 'with edge cases' do
      it 'handles empty frames array' do
        scorer = described_class.new([])
        expect(scorer.calculate).to eq(0)
      end

      it 'handles single frame' do
        frames = [BowlingGame::Frame::Regular.new([3, 4])]
        scorer = described_class.new(frames)
        expect(scorer.calculate).to eq(7)
      end

      it 'handles strike with insufficient following frames' do
        frames = [BowlingGame::Frame::Strike.new([10])]
        scorer = described_class.new(frames)
        # Strike with no following frames gets no bonus
        expect(scorer.calculate).to eq(10)
      end
    end
  end

  describe '#initialize' do
    it 'freezes the frames array' do
      frames = [BowlingGame::Frame::Regular.new([3, 4])]
      scorer = described_class.new(frames)
      expect(scorer.frames).to be_frozen
    end
  end
end
