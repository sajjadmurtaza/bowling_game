# Bowling Game Scorer

A Ruby library that calculates bowling scores from frame data.

## Problem

Calculate bowling scores from input like `[[5,3], [10], [4,6]]` and return the total score (`38`).

## Installation

```bash
bundle install
```

## Usage

```ruby
require_relative 'lib/bowling_game'

# Calculate score from frame data
score = BowlingGame::Convenience.score([[5,3], [10], [4,6]])
puts score  # => 38

# Perfect game
perfect = Array.new(9) { [10] } + [[10, 10, 10]]
score = BowlingGame::Convenience.score(perfect)  # => 300
```

## Testing

```bash
ruby examples/test_all.rb       # Comprehensive test suite
bundle exec rspec               # Full RSpec test suite
bundle exec rubocop             # Code quality check
```

## Examples

See `examples/` directory:
- `test_all.rb` - Comprehensive test with all scenarios
- `basic_usage.rb` - Common usage patterns  
- `error_handling.rb` - Input validation examples

## Architecture

```
lib/bowling_game.rb              # Main entry point
├── game.rb                      # Game state management
├── bowling_scorer.rb            # Score calculation
├── frame.rb                     # Frame types (Strike, Spare, etc.)
└── convenience.rb               # Simple interface
```

## Bowling Rules

- **Strike** `[10]`: 10 + next 2 rolls
- **Spare** `[7,3]`: 10 + next 1 roll  
- **Regular** `[5,3]`: Sum of pins
- **10th Frame**: Special rules allow up to 3 rolls

---

Professional Ruby implementation following SOLID principles with comprehensive test coverage.