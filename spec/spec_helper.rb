$LOAD_PATH << './lib'
require 'bundler/setup'
require 'core/utils/extensions/kernel'
require_relative 'helpers/simplecov_env'
require_relative 'helpers/arguments/handler'

SimpleCovEnv.start!

RSpec.configure do |rspec|
  rspec.expect_with :rspec do |config|
    # Remove the max formatted output length
    config.max_formatted_output_length = nil
  end
end
