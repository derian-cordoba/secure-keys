#!/usr/bin/env ruby

require_relative 'swift'
require_relative '../../console/shell'

module SecureKeys
  module Swift
    class Package
      # Generate the Swift Package using the configured path
      def generate
        command = <<~BASH
          rm -rf #{SWIFT_PACKAGE_DIRECTORY} &&
          mkdir -p #{SWIFT_PACKAGE_DIRECTORY} &&
          cd #{SWIFT_PACKAGE_DIRECTORY} &&
          swift package init --name #{SWIFT_PACKAGE_NAME} --type library
        BASH

        Core::Console::Shell.sh(command:)
      end
    end
  end
end
