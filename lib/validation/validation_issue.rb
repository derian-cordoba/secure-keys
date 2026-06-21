#!/usr/bin/env ruby

module SecureKeys
  module Validation
    # Represents a single issue detected during secret validation
    class ValidationIssue
      attr_reader :severity, :type, :message, :recommendation

      # Initialize a new validation issue
      # @param severity [Symbol] The severity level (:critical, :error, :warning, :info)
      # @param type [Symbol] The category of the issue (e.g. :empty_value, :weak_secret)
      # @param message [String] A human-readable description of the issue
      # @param recommendation [String, nil] An optional actionable recommendation for the developer
      def initialize(severity:, type:, message:, recommendation:)
        @severity = severity
        @type = type
        @message = message
        @recommendation = recommendation
      end

      # Returns a string representation of the issue, including the recommendation if present
      # @return [String] The formatted issue string
      def to_s
        text = "#{severity_icon} #{severity.upcase}: #{message}"
        text += "\n\t\t💡 #{recommendation}" if recommendation
        text
      end

      # Returns a hash representation of the issue
      # @return [Hash] The hash representation
      def to_h
        {
          severity:,
          type:,
          message:,
          recommendation:,
        }
      end

      private

      # Returns the appropriate icon for the severity level
      # @return [String] The severity icon
      def severity_icon
        case severity
        when :critical then '🔴'
        when :error then '❌'
        when :warning then '⚠️'
        when :info then 'ℹ️'
        else '•'
        end
      end
    end
  end
end
