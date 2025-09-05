# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

# Default task runs tests and linting
task default: %i[spec rubocop]

# RSpec task
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--format documentation --color'
end

# RuboCop task
RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end

# Task to run all quality checks
desc 'Run all quality checks (tests, linting, code smells)'
task quality: %i[spec rubocop]

# Task to generate documentation
desc 'Generate YARD documentation'
task :docs do
  system 'yard doc'
end

# Task to run the example
desc 'Run the bowling game example'
task :example do
  load 'examples/demo.rb'
end
