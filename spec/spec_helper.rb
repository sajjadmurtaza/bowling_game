# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
  add_group 'Library', 'lib'
  minimum_coverage 90
end

require_relative '../lib/bowling_game'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on Module and main
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Use color output
  config.color = true

  # Use documentation format for better readability
  config.default_formatter = 'doc' if config.files_to_run.one?

  # Show the slowest examples
  config.profile_examples = 5

  # Run specs in random order to surface order dependencies
  config.order = :random
  Kernel.srand config.seed
end
