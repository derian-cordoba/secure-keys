#!/usr/bin/env ruby

require_relative '../core/console/logger'

module SecureKeys
  module Validation
    # Encapsulates the result of validating a single secret value
    class ValidationResult
      private

      attr_writer :key, :value, :issues, :detected_type

      public

      attr_reader :key, :value, :issues, :detected_type

      # Initialize a new validation result
      # @param key [Symbol] The key identifier that was validated
      # @param value [String] The value that was validated
      # @param issues [Array<ValidationIssue>] The list of issues found during validation
      # @param detected_type [Hash, nil] The detected secret type config, if any pattern matched
      def initialize(key:, value:, issues:, detected_type: nil)
        @key = key
        @value = value
        @issues = issues
        @detected_type = detected_type
      end

      # Check if validation passed with no errors or critical issues
      # @return [Boolean] true if no critical or error issues were found
      def valid?
        !errors? && !critical?
      end

      # Check if any critical-severity issues were found
      # @return [Boolean] true if critical issues exist
      def critical?
        issues.any? { |issue| issue.severity == :critical }
      end

      # Check if any error-severity issues were found
      # @return [Boolean] true if error issues exist
      def errors?
        issues.any? { |issue| issue.severity == :error }
      end

      # Check if any warning-severity issues were found
      # @return [Boolean] true if warning issues exist
      def warnings?
        issues.any? { |issue| issue.severity == :warning }
      end

      # Returns the highest severity level across all issues
      # @return [Symbol] :critical, :error, :warning, or :ok
      def severity_level
        return :critical if critical?
        return :error if errors?
        return :warning if warnings?

        :ok
      end

      # Returns a one-line summary of the validation outcome
      # @return [String] The summary string
      def summary
        return "✅ '#{key}' passed validation" if valid?

        "#{severity_icon} '#{key}' has #{issues.length} issue(s)"
      end

      # Prints the full validation result to the console via Logger
      def print
        Core::Console::Logger.message(message: "\nValidation Result for '#{key}':")
        Core::Console::Logger.message(message: '-' * 70)

        if detected_type
          Core::Console::Logger.message(message: "Detected Type: #{detected_type[:description]}")
          Core::Console::Logger.message(message: "Severity:      #{detected_type[:severity]}")
        end

        if issues.empty?
          Core::Console::Logger.success(message: '✅ No issues found')
        else
          Core::Console::Logger.message(message: '')
          issues.each { |issue| Core::Console::Logger.message(message: "  #{issue}") }
        end

        Core::Console::Logger.message(message: '-' * 70)
      end

      # Returns a hash representation of the validation result
      # @return [Hash] The hash representation
      def to_h
        {
          key:,
          valid: valid?,
          severity: severity_level,
          detected_type:,
          issues: issues.map(&:to_h),
        }
      end

      private

      # Returns the appropriate icon for the current severity level
      # @return [String] The severity icon
      def severity_icon
        case severity_level
        when :critical then '🔴'
        when :error then '❌'
        when :warning then '⚠️'
        else '✅'
        end
      end
    end
  end
end
