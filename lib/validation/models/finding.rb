#!/usr/bin/env ruby

module SecureKeys
  module Validation
    # Represents a single secret detected during a file or git diff scan
    class Finding
      attr_reader :file, :line, :column, :type, :description, :severity,
                  :matched_text, :full_line, :is_addition

      # Initialize a new finding
      # @param file [String] The file path where the secret was found
      # @param line [Integer] The line number where the secret was found
      # @param column [Integer] The column offset of the match within the line
      # @param type [Symbol] The pattern type that matched (e.g. :github_token, :aws_access_key)
      # @param description [String] A human-readable description of the secret type
      # @param severity [Symbol] The severity level (:low, :medium, :high, :critical)
      # @param matched_text [String] The masked matched text, safe for display
      # @param full_line [String] The full trimmed line of code containing the secret
      # @param is_addition [Boolean] Whether this line is an addition in a git diff (default: false)
      def initialize(file:, line:, column:, type:, description:, severity:,
                     matched_text:, full_line:, is_addition: false)
        @file = file
        @line = line
        @column = column
        @type = type
        @description = description
        @severity = severity
        @matched_text = matched_text
        @full_line = full_line
        @is_addition = is_addition
      end

      # Check if this finding came from a git diff addition
      # @return [Boolean] true if the line is a git diff addition
      def addition?
        is_addition
      end

      # Returns a one-line string representation of the finding
      # @return [String] The formatted finding string
      def to_s
        "#{severity_icon} #{file}:#{line}:#{column} [#{type}] #{description} — #{matched_text}"
      end

      # Returns a hash representation of the finding
      # @return [Hash] The hash representation
      def to_h
        {
          file:,
          line:,
          column:,
          type:,
          description:,
          severity:,
          matched_text:,
          full_line:,
          is_addition:,
        }
      end

      private

      # Returns the appropriate icon for the severity level
      # @return [String] The severity icon
      def severity_icon
        case severity
        when :critical then '🔴'
        when :high then '🟠'
        when :medium then '🟡'
        when :low then '🔵'
        else '⚪'
        end
      end
    end
  end
end
