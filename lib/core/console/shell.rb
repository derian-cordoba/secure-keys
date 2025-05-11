#!/usr/bin/env ruby

require 'open3'
require_relative 'logger'
require_relative '../globals/globals'

module SecureKeys
  module Core
    module Console
      module Shell
        module_function

        # Source: https://github.com/fastlane/fastlane/blob/5b2106db41be2ca272dfe5b99360f29879c707bb/fastlane/lib/fastlane/helper/sh_helper.rb#L28
        # Executes a shell command
        # All commands will be executed in the given block
        # @param command [String] The command that should be executed
        # @param error_handler [Block] A block that will be called with the output of the command if the command exists with a non-zero exit status
        # @return [Array] An array containing the output of the command, the exit status and the command
        def sh(command:, error_handler: nil)
          previous_encoding = [Encoding.default_external, Encoding.default_internal]
          Encoding.default_external = Encoding::UTF_8
          Encoding.default_internal = Encoding::UTF_8
          Logger.command(command:)

          output = ''
          exit_status = nil
          Open3.popen2e(command) do |_stdin, io, thread|
            io.sync = true
            io.each do |line|
              Logger.command_output(command: line.strip)
              output << line
            end
            exit_status = thread.value
          end

          if exit_status.exitstatus.zero?
            output << command
          else
            message = "Exit status of command '#{command}' was #{exit_status.exitstatus} instead of 0.\n#{output}"

            if error_handler || block_given?
              Logger.error(message:)
              error_handler&.call(output)
            else
              Logger.crash!(message:)
            end
          end

          return yield(exit_status || $CHILD_STATUS, output, command) if block_given?

          [output, exit_status || $CHILD_STATUS, command]
        ensure
          Encoding.default_external = previous_encoding.first
          Encoding.default_internal = previous_encoding.last
        end
      end
    end
  end
end
