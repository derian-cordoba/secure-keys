#!/usr/bin/env ruby

require_relative 'globals/globals'
require_relative 'utils/weak_secrets'
require_relative 'utils/patterns'
require_relative 'utils/min_length'
require_relative 'utils/entropy'
require_relative 'validation_issue'
require_relative 'validation_result'

module SecureKeys
  module Validation
    # Validates individual secret values against known patterns and security rules
    class Validator
      private

      attr_accessor :issues

      public

      # Initialize a new validator
      def initialize
        self.issues = []
      end

      # Validate a single secret value against all configured rules
      # @param key [Symbol] The key identifier for the secret
      # @param value [String] The value to validate
      # @param options [Hash] Additional validation options
      # @option options [Boolean] :check_entropy Enable Shannon entropy checking (default: false)
      # @option options [Boolean] :allow_production Skip production key warnings (default: false)
      # @option options [Boolean] :warn_on_pattern Emit informational notices for matched patterns (default: false)
      # @return [ValidationResult] The result of the validation
      def validate(key:, value:, options: {})
        self.issues = []

        check_empty(key:, value:)
        check_weak_secret(key:, value:)
        check_minimum_length(key:, value:)
        check_pattern_match(key:, value:, options:)
        check_entropy(key:, value:) if options[:check_entropy]

        ValidationResult.new(key:, value:, issues:, detected_type: detect_type(value:))
      end

      # Detect the secret type of a value by matching against known patterns
      # @param value [String] The value to analyze
      # @return [Hash, nil] The matching pattern config merged with :type key, or nil if no match
      def detect_type(value:)
        PATTERNS.each do |type, config|
          return config.merge(type:) if value.to_s.match?(config[:pattern])
        end

        nil
      end

      # Returns security recommendations for a given key name
      # @param key [Symbol] The key identifier
      # @return [Array<String>] List of actionable recommendations
      def recommendations(key:)
        result = []
        formatted_key = key.to_s.downcase

        if formatted_key.include?('github')
          result << 'Use GitHub Personal Access Tokens with minimal required scopes'
          result << 'Consider fine-grained tokens with repository-specific access'
        end

        if formatted_key.include?('aws')
          result << 'Use AWS IAM roles instead of long-lived access keys when possible'
          result << 'Enable MFA for all IAM users with access keys'
          result << 'Rotate AWS access keys every 90 days'
        end

        if formatted_key.include?('stripe')
          result << 'Never commit live Stripe keys to version control'
          result << 'Use Stripe test keys for development and staging'
          result << 'Consider Stripe restricted keys with minimal permissions'
        end

        if formatted_key.include?('api') || formatted_key.include?('key')
          result << 'Rotate this key regularly (every 90 days recommended)'
          result << 'Use environment-specific keys for dev, staging, and production'
        end

        result
      end

      private

      # Check if the value is empty
      # @param key [Symbol] The key identifier
      # @param value [String] The value to check
      def check_empty(key:, value:)
        return unless value.to_s.empty?

        issues << ValidationIssue.new(
          severity: :error,
          type: :empty_value,
          message: "Key '#{key}' has an empty value",
          recommendation: 'Provide a non-empty secret value'
        )
      end

      # Check if the value is a known weak or placeholder secret
      # @param key [Symbol] The key identifier
      # @param value [String] The value to check
      def check_weak_secret(key:, value:)
        return unless value

        formatted_value = value.downcase

        WEAK_SECRETS.each do |weak|
          next unless formatted_value == weak || formatted_value.include?(weak)

          issues << ValidationIssue.new(
            severity: :critical,
            type: :weak_secret,
            message: "Key '#{key}' uses a weak or placeholder value matching '#{weak}'",
            recommendation: 'Replace with a strong, randomly generated secret'
          )
        end
      end

      # Check if the value meets the minimum length requirement for its inferred key type
      # @param key [Symbol] The key identifier
      # @param value [String] The value to check
      def check_minimum_length(key:, value:)
        return unless value

        key_type = determine_key_type(key:)
        min_length = MIN_LENGTHS[key_type] || MIN_LENGTHS[:key]

        return unless value.length < min_length

        issues << ValidationIssue.new(
          severity: :warning,
          type: :too_short,
          message: "Key '#{key}' is too short (#{value.length} chars, minimum is #{min_length})",
          recommendation: "Use a longer secret (recommended: #{min_length * 2}+ characters)"
        )
      end

      # Check if the value matches a known production secret pattern
      # @param key [Symbol] The key identifier
      # @param value [String] The value to check
      # @param options [Hash] Validation options controlling severity behaviour
      def check_pattern_match(key:, value:, options:)
        return unless value

        detected = detect_type(value:)
        return unless detected

        if detected[:severity] == :critical && !options[:allow_production]
          issues << ValidationIssue.new(
            severity: :critical,
            type: :production_key_detected,
            message: "Key '#{key}' appears to be a live #{detected[:description]}",
            recommendation: 'Use test or development keys locally. Store production keys in your CI/CD secrets manager.'
          )
        elsif options[:warn_on_pattern]
          issues << ValidationIssue.new(
            severity: :info,
            type: :pattern_detected,
            message: "Key '#{key}' matches the pattern for: #{detected[:description]}",
            recommendation: nil
          )
        end
      end

      # Check if the value has sufficient Shannon entropy to be a strong secret
      # @param key [Symbol] The key identifier
      # @param value [String] The value to check
      def check_entropy(key:, value:)
        return unless value

        entropy = Entropy.calculate(string: value)
        return unless entropy < Globals.min_entropy_threshold

        issues << ValidationIssue.new(
          severity: :warning,
          type: :low_entropy,
          message: "Key '#{key}' has low entropy (#{entropy.round(2)})",
          recommendation: 'Use a more random secret with a wider variety of characters'
        )
      end

      # Infer the semantic key type from the key name for minimum-length lookup
      # @param key [Symbol] The key identifier
      # @return [Symbol] One of :api_key, :token, :secret, :password, or :key
      def determine_key_type(key:)
        formatted_key = key.to_s.downcase

        return :api_key if formatted_key.include?('api') && formatted_key.include?('key')
        return :token if formatted_key.include?('token')
        return :secret if formatted_key.include?('secret')
        return :password if formatted_key.include?('password') || formatted_key.include?('pwd')

        :key
      end
    end
  end
end
