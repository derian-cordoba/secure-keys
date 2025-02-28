$LOAD_PATH << './lib'
require 'bundler/setup'
require 'core/utils/extensions/kernel'
require_relative './helpers/simplecov_env'
require_relative './helpers/arguments/handler'

SimpleCovEnv.start!
