require 'colorize'
require 'logger'
require 'tty-screen'
require_relative '../globals/globals'

module SecureKeys
  module Core
    module Console
      module Logger
        module_function

        # Log a success message
        # @param message [String] the message to log
        def success(message:)
          logger.info(message.to_s.green)
        end

        # Log an error message
        # @param message [String] the message to log
        def error(message:)
          logger.warn(message.to_s.red)
        end

        # Log an important message
        # @param message [String] the message to log
        def important(message:)
          logger.info(message.to_s.blue)
        end

        # Log a warning message
        # @param message [String] the message to log
        def warning(message:)
          logger.info(message.to_s.yellow)
        end

        # Log a message without any formatting
        # @param message [String] the message to log
        def message(message:)
          logger.info(message.to_s)
        end

        # Log a deprecated message
        # @param message [String] the message to log
        def deprecated(message:)
          logger.error(message.to_s.deprecated)
        end

        # Log a command message
        # @param command [String] the command to log
        def command(command:)
          logger.info("$ #{command}".cyan)
        end

        # Log a verbose message
        # @param message [String] the message to log
        def verbose(message:)
          logger.debug(message.to_s) if Globals.verbose?
        end

        # Crash the terminal with a message
        # @param message [String] the message to log
        def crash!(message:)
          raise(StandardError.new, message)
        end

        # Kill the terminal with a message
        # @param message [String] the message to log
        def kill!(message:)
          error(message:)
          exit(1)
        end

        # Log a command output
        # @param command [String] the command to log
        def command_output(command:)
          actual = encode_as_utf_8_if_possible(message: command).split("\r")
                                                                .last || ''
          actual.split("\n").each do |cmd|
            prefix = cmd.include?('▸') ? '' : '▸ '
            logger.info("#{prefix} #{cmd.magenta}")
          end
        end

        # Create a logger instance if needed
        # @return [Logger] the logger instance
        def logger
          return @log unless @log.nil?

          $stdout.sync = true
          @log ||= ::Logger.new($stdout)
          @log.formatter = proc do |severity, datetime, _, message|
            "#{format_string(datetime:, severity:)} #{message}\n"
          end

          @log
        end

        # Format the log string
        # @param datetime [Time] the datetime to format
        # @param severity [String] the severity of the log
        # @return [String] the formatted string
        def format_string(datetime: Time.now, severity: '')
          return "#{severity} [#{datetime.strftime('%Y-%m-%d %H:%M:%S.%2N')}]: " if Globals.verbose?

          "[#{datetime.strftime('%H:%M:%S')}]: "
        end

        # Encode a message as UTF-8 if possible
        # @param message [String] the message to encode
        # @return [String] the encoded message
        def encode_as_utf_8_if_possible(message:)
          return message if message.valid_encoding?

          return message.encode(Encoding::UTF_8, Encoding::UTF_16) if message.dup
                                                                             .force_encoding(Encoding::UTF_16)
                                                                             .valid_encoding?

          message.encode(Encoding::UTF_8, invalid: :replace)
        end
      end
    end
  end
end
