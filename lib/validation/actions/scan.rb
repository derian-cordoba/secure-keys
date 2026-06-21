#!/usr/bin/env ruby

require 'json'
require_relative '../console/arguments/scan/handler'
require_relative '../../core/console/logger'
require_relative '../scanner'

module SecureKeys
  module Validation
    module Actions
      # Executes the `validate scan` action: runs the scanner, prints a formatted
      # report to the console, optionally saves a JSON report, and exits with an
      # appropriate code (0 = clean, 1 = findings present).
      class Scan
        # Run the scan, print the report, and exit
        # @return [void]
        def run
          result = execute_scan
          print_result(result:)
          save_report(result:) if Console::Argument::Scan::Handler.fetch(key: :output)
          exit(result.clean? ? 0 : 1)
        end

        private

        # Build optional scanner overrides from CLI arguments via Handler.fetch
        # @return [Hash] A sparse options hash (only keys explicitly provided by the user)
        def scanner_options
          options = {}

          if (extensions = Console::Argument::Scan::Handler.fetch(key: :extensions))
            options[:extensions] = extensions.split(',').map(&:strip)
          end

          if (excludes = Console::Argument::Scan::Handler.fetch(key: :excludes))
            options[:excludes] = excludes.split(',').map(&:strip)
          end

          options
        end

        # Run the appropriate scan based on the --staged flag
        # @return [ScanResult] The result of the scan
        def execute_scan
          scanner = Scanner.new(options: scanner_options)

          if Console::Argument::Scan::Handler.fetch(key: :staged, default: false)
            Core::Console::Logger.important(message: 'Scanning staged git changes...')
            scanner.scan_git_diff(staged_only: true)
          else
            path = Console::Argument::Scan::Handler.fetch(key: :path, default: '.')
            Core::Console::Logger.important(message: "Scanning directory: #{path}")
            scanner.scan_directory(path:)
          end
        end

        # Print a formatted scan report to the console
        # @param result [ScanResult] The scan result to display
        # @return [void]
        def print_result(result:)
          separator = '-' * 70

          Core::Console::Logger.message(message: separator)
          Core::Console::Logger.message(message: "\tFiles scanned:  #{result.files_count}")
          Core::Console::Logger.message(message: "\tFindings:       #{result.findings.length}")
          Core::Console::Logger.message(message: separator)

          if result.clean?
            Core::Console::Logger.success(message: "\t✅ No secrets found")
          else
            print_severity_summary(result:)
            Core::Console::Logger.message(message: separator)
            print_findings(result:)
          end

          Core::Console::Logger.message(message: separator)
        end

        # Print a per-severity count breakdown
        # @param result [ScanResult] The scan result
        # @return [void]
        def print_severity_summary(result:)
          counts = {
            critical: result.by_severity(severity: :critical).length,
            high: result.by_severity(severity: :high).length,
            medium: result.by_severity(severity: :medium).length,
            low: result.by_severity(severity: :low).length,
          }

          Core::Console::Logger.error(message: "\t🔴 Critical:  #{counts[:critical]}") if counts[:critical].positive?
          Core::Console::Logger.warning(message: "\t🟠 High:      #{counts[:high]}")     if counts[:high].positive?
          Core::Console::Logger.warning(message: "\t🟡 Medium:    #{counts[:medium]}")   if counts[:medium].positive?
          Core::Console::Logger.message(message: "\t🔵 Low:       #{counts[:low]}")      if counts[:low].positive?
        end

        # Print each finding grouped by severity level
        # @param result [ScanResult] The scan result
        # @return [void]
        def print_findings(result:)
          %i[critical high medium low].each do |severity|
            findings = result.by_severity(severity:)
            next if findings.empty?

            Core::Console::Logger.message(message: "\t#{severity.to_s.upcase} (#{findings.length}):")

            findings.each do |finding|
              Core::Console::Logger.message(message: "\t\t#{finding}")
              Core::Console::Logger.message(message: "\t\t└ #{finding.full_line}")
            end

            Core::Console::Logger.message(message: '')
          end
        end

        # Save the scan result as a pretty-printed JSON report
        # @param result [ScanResult] The scan result to serialise
        # @return [void]
        def save_report(result:)
          output = Console::Argument::Scan::Handler.fetch(key: :output)
          File.write(output, JSON.pretty_generate(result.to_h))
          Core::Console::Logger.success(message: "Report saved to: #{output}")
        end
      end
    end
  end
end
