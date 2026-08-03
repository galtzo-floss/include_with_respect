# frozen_string_literal: true

# Config for development dependencies of this library
# i.e., not configured by this library
#
# SimpleCov & related config (must run BEFORE any other requires)
# NOTE: Gemfiles for non-coverage appraisals may not have kettle-soup-cover.
#       The rescue LoadError handles that scenario.
begin
  require "kettle-soup-cover"
  if Kettle::Soup::Cover::DO_COV
    # Requiring simplecov loads the project-local `.simplecov`.
    require "simplecov"
    require "kettle/soup/cover/config"
    SimpleCov.start
  end
rescue LoadError => error
  # check the error message and re-raise when unexpected
  raise error unless error.message.include?("kettle")
end

# External RSpec & related config
require "kettle/test/rspec"
# `kettle/test/rspec` installs harness helpers documented in spec/README.md.
require "bundler/setup"

# Third party libraries
require "rspec/block_is_expected"
require "silent_stream"
require "debug"

$respect_semaphore = [] # For tracking as modules get included

require "include_with_respect"
require "support/shared_contexts/my_context"

$original_respect_semaphore = $respect_semaphore.dup

RSpec.configure do |config|
  # only run a specific test with :focus tag
  config.filter_run_when_matching :focus

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include SilentStream

  config.before do
    $respect_semaphore = $original_respect_semaphore.dup
  end
  config.after do
    $respect_semaphore = []
  end
end
