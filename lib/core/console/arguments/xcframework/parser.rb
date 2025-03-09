#!/usr/bin/env ruby

require 'optparse'
require_relative '../../../globals/globals'
require_relative './handler'

module SecureKeys
  module Core
    module Console
      module Argument
        module XCFramework
          class Parser < OptionParser
            # Initialize the argument parser with the default options
            def initialize
              super('Usage: secure-keys --xcframework [--options]')
              separator('')

              # Configure the arguement parser
              configure!
              order!(into: Handler.arguments)
            end

            private

            # Configure the argument parser
            def configure!
              on('-h', '--help', 'Use the provided commands to select the params') do
                puts self
                exit(0)
              end

              on('-t', '--target TARGET', String, 'The target to add the xcframework')
              on('-r', '--replace', FalseClass, 'Replace the existing xcframework')
              on('-x', '--xcodeproj XCODEPROJ', String, 'The Xcode project path (default: the first found Xcode project)')
            end
          end
        end
      end
    end
  end
end
