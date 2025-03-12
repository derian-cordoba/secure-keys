#!/usr/bin/env ruby

require_relative './core/utils/extensions/kernel'
require_relative './core/generator'
require_relative './core/globals/globals'
require_relative './core/console/logger'
require_relative './core/console/arguments/parser'
require_relative './core/utils/swift/xcframework'

module SecureKeys
  def self.run
    # Configure the argument parser
    Core::Console::Argument::Parser.new

    # Generate the keys
    Core::Generator.new.generate
  end
end
