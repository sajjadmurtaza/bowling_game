# frozen_string_literal: true

RSpec.describe BowlingGame::Frame do
  describe BowlingGame::Frame::Base do
    subject(:frame) { described_class.new([3, 4]) }

    describe '#initialize' do
      it 'freezes the rolls array' do
        expect(frame.rolls).to be_frozen
      end
    end

    describe '#base_score' do
      it 'returns sum of rolls' do
        expect(frame.base_score).to eq(7)
      end
    end

    describe '#strike?' do
      it 'returns false for base class' do
        expect(frame).not_to be_strike
      end
    end

    describe '#spare?' do
      it 'returns false for base class' do
        expect(frame).not_to be_spare
      end
    end

    describe '#bonus_multiplier' do
      it 'returns 0 for base class' do
        expect(frame.bonus_multiplier).to eq(0)
      end
    end

    describe '#bonus_pins' do
      it 'returns requested number of pins' do
        expect(frame.bonus_pins(1)).to eq([3])
        expect(frame.bonus_pins(2)).to eq([3, 4])
      end

      it 'defaults to 2 pins' do
        expect(frame.bonus_pins).to eq([3, 4])
      end
    end
  end

  describe BowlingGame::Frame::Regular do
    describe '#initialize' do
      it 'accepts valid regular frame' do
        expect { described_class.new([3, 4]) }.not_to raise_error
      end

      it 'accepts single roll' do
        expect { described_class.new([7]) }.not_to raise_error
      end

      it 'rejects more than 2 rolls' do
        expect do
          described_class.new([3, 4, 2])
        end.to raise_error(ArgumentError, 'Regular frame cannot have more than 2 rolls')
      end

      it 'rejects more than 10 pins total' do
        expect do
          described_class.new([6, 5])
        end.to raise_error(ArgumentError, 'Cannot knock down more than 10 pins in regular frame')
      end
    end
  end

  describe BowlingGame::Frame::Strike do
    subject(:strike_frame) { described_class.new([10]) }

    describe '#initialize' do
      it 'accepts valid strike' do
        expect { described_class.new([10]) }.not_to raise_error
      end

      it 'rejects non-strike rolls' do
        expect do
          described_class.new([9])
        end.to raise_error(ArgumentError, 'Strike frame must have exactly one roll of 10')
      end

      it 'rejects multiple rolls' do
        expect do
          described_class.new([10, 0])
        end.to raise_error(ArgumentError, 'Strike frame must have exactly one roll of 10')
      end
    end

    describe '#strike?' do
      it 'returns true' do
        expect(strike_frame).to be_strike
      end
    end

    describe '#bonus_multiplier' do
      it 'returns 2' do
        expect(strike_frame.bonus_multiplier).to eq(2)
      end
    end
  end

  describe BowlingGame::Frame::Spare do
    subject(:spare_frame) { described_class.new([7, 3]) }

    describe '#initialize' do
      it 'accepts valid spare' do
        expect { described_class.new([7, 3]) }.not_to raise_error
      end

      it 'rejects non-spare rolls' do
        expect do
          described_class.new([7, 2])
        end.to raise_error(ArgumentError, 'Spare frame must have exactly 2 rolls summing to 10')
      end

      it 'rejects single roll' do
        expect do
          described_class.new([10])
        end.to raise_error(ArgumentError, 'Spare frame must have exactly 2 rolls summing to 10')
      end

      it 'rejects more than 2 rolls' do
        expect do
          described_class.new([5, 5, 0])
        end.to raise_error(ArgumentError, 'Spare frame must have exactly 2 rolls summing to 10')
      end
    end

    describe '#spare?' do
      it 'returns true' do
        expect(spare_frame).to be_spare
      end
    end

    describe '#bonus_multiplier' do
      it 'returns 1' do
        expect(spare_frame.bonus_multiplier).to eq(1)
      end
    end
  end

  describe BowlingGame::Frame::Tenth do
    describe '#initialize' do
      context 'with one roll' do
        it 'accepts non-strike roll' do
          expect { described_class.new([7]) }.not_to raise_error
        end

        it 'rejects strike (incomplete)' do
          expect do
            described_class.new([10])
          end.to raise_error(ArgumentError,
                             'Tenth frame with one roll must be less than 10 (incomplete)')
        end
      end

      context 'with two rolls' do
        it 'accepts regular frame' do
          expect { described_class.new([3, 4]) }.not_to raise_error
        end

        it 'accepts spare' do
          expect { described_class.new([7, 3]) }.not_to raise_error
        end

        it 'accepts strike followed by any roll' do
          expect { described_class.new([10, 5]) }.not_to raise_error
          expect { described_class.new([10, 10]) }.not_to raise_error
        end

        it 'rejects more than 10 pins for non-strike' do
          expect do
            described_class.new([6, 5])
          end.to raise_error(ArgumentError, 'First two rolls cannot exceed 10 pins in tenth frame')
        end
      end

      context 'with three rolls' do
        it 'accepts strike followed by any valid combination' do
          expect { described_class.new([10, 3, 4]) }.not_to raise_error
          expect { described_class.new([10, 10, 10]) }.not_to raise_error
          expect { described_class.new([10, 7, 3]) }.not_to raise_error
        end

        it 'accepts spare followed by any roll' do
          expect { described_class.new([7, 3, 5]) }.not_to raise_error
          expect { described_class.new([7, 3, 10]) }.not_to raise_error
        end

        it 'rejects three rolls without strike or spare' do
          expect do
            described_class.new([3, 4,
                                 2])
          end.to raise_error(ArgumentError, 'Tenth frame can only have 3 rolls after strike or spare')
        end

        it 'rejects invalid combinations after strike' do
          expect do
            described_class.new([10, 6, 5])
          end.to raise_error(ArgumentError, 'Invalid roll combination in tenth frame after strike')
        end
      end

      context 'with more than three rolls' do
        it 'rejects four rolls' do
          expect do
            described_class.new([10, 10, 10, 10])
          end.to raise_error(ArgumentError, 'Tenth frame must have 1-3 rolls')
        end
      end
    end

    describe '#strike?' do
      it 'returns true when first roll is 10' do
        frame = described_class.new([10, 5, 3])
        expect(frame).to be_strike
      end

      it 'returns false when first roll is not 10' do
        frame = described_class.new([7, 3, 5])
        expect(frame).not_to be_strike
      end
    end

    describe '#spare?' do
      it 'returns true when first two rolls sum to 10 and first is not 10' do
        frame = described_class.new([7, 3, 5])
        expect(frame).to be_spare
      end

      it 'returns false for strike' do
        frame = described_class.new([10, 5, 3])
        expect(frame).not_to be_spare
      end

      it 'returns false when first two rolls do not sum to 10' do
        frame = described_class.new([7, 2])
        expect(frame).not_to be_spare
      end
    end

    describe '#bonus_multiplier' do
      it 'returns 0 (tenth frame does not provide bonus)' do
        frame = described_class.new([10, 10, 10])
        expect(frame.bonus_multiplier).to eq(0)
      end
    end

    describe '#base_score' do
      it 'returns sum of all rolls' do
        frame = described_class.new([10, 5, 3])
        expect(frame.base_score).to eq(18)
      end
    end
  end
end
