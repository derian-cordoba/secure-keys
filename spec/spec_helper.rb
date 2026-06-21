$LOAD_PATH << './lib'
require 'bundler/setup'
require 'core/utils/extensions/kernel'
require 'core/console/logger'
require_relative 'helpers/simplecov_env'
require_relative 'helpers/arguments/handler'

SimpleCovEnv.start!

RSpec.configure do |rspec|
  rspec.expect_with :rspec do |config|
    # Remove the max formatted output length
    config.max_formatted_output_length = nil
  end

  rspec.before(:suite) do
    null_logger = Logger.new(File::NULL)
    SecureKeys::Core::Console::Logger.instance_variable_set(:@log, null_logger)
  end
end
