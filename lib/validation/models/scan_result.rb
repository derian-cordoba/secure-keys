#!/usr/bin/env ruby

module SecureKeys
  module Validation
    # Aggregates all findings from a single scan run
    class ScanResult
      attr_reader :findings, :files_count

      # Initialize a new scan result
      # @param findings [Array<Finding>] The list of detected secrets
      # @param files_count [Integer] The total number of files (or diff lines) scanned
      def initialize(findings:, files_count:)
        @findings = findings
        @files_count = files_count
      end

      # Check if the scan produced no findings
      # @return [Boolean] true if no secrets were detected
      def clean?
        findings.empty?
      end

      # Returns findings filtered by a specific severity level
      # @param severity [Symbol] The severity to filter by (:low, :medium, :high, :critical)
      # @return [Array<Finding>] Findings matching the given severity
      def by_severity(severity:)
        findings.select { |finding| finding.severity == severity }
      end

      # Returns a hash representation of the scan result
      # @return [Hash] The hash representation, suitable for JSON export
      def to_h
        {
          files_scanned: files_count,
          total_findings: findings.length,
          by_severity: {
            critical: by_severity(severity: :critical).length,
            high: by_severity(severity: :high).length,
            medium: by_severity(severity: :medium).length,
            low: by_severity(severity: :low).length,
          },
          findings: findings.map(&:to_h),
        }
      end
    end
  end
end
