#!/usr/bin/env ruby

require_relative './core/utils/extensions/kernel'
require_relative './core/generator'
require_relative './core/globals/globals'
require_relative './core/console/logger'
require_relative './core/console/arguments/parser'

module SecureKeys
  def self.run
    # Configure the argument parser
    Core::Console::Argument::Parser.new
    return Core::Console::Logger.important(message: 'Skipping the generation of the SecureKeys XCFramework') unless Globals.generate_xcframework?

    Core::Generator.new.generate
  end
end
