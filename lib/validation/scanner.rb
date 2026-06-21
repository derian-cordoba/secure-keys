#!/usr/bin/env ruby

require_relative '../core/console/logger'
require_relative '../core/console/shell'
require_relative 'globals/globals'
require_relative 'utils/patterns'
require_relative 'models/finding'
require_relative 'models/scan_result'

module SecureKeys
  module Validation
    # Scans files and git diffs for exposed secrets using the known PATTERNS set
    class Scanner
      private

      attr_accessor :findings, :options

      public

      # Initialize a new scanner
      # @param options [Hash] Override specific default scanning options
      # @option options [Array<String>] :extensions File extensions to include in the scan
      # @option options [Array<String>] :excludes Directory and file names to exclude
      # @option options [Integer] :max_depth Maximum directory traversal depth
      # @option options [Boolean] :follow_symlinks Whether to follow symbolic links
      def initialize(options: {})
        self.options = default_options.merge(options)
        self.findings = []
      end

      # Scan a directory recursively for exposed secrets
      # @param path [String] The root directory path to scan (default: current directory)
      # @param options [Hash] Additional options to merge for this scan only
      # @return [ScanResult] The aggregated scan result
      def scan_directory(path: '.', options: {})
        self.findings = []
        self.options = self.options.merge(options)

        Core::Console::Logger.verbose(message: "Scanning directory: #{path}")
        Core::Console::Logger.verbose(message: "Extensions: #{file_extensions.join(', ')}")
        Core::Console::Logger.verbose(message: "Excludes: #{exclude_patterns.join(', ')}")

        files = find_files(path:)

        Core::Console::Logger.verbose(message: "Found #{files.length} files to scan")

        files.each { |file| scan_file(file_path: file) }

        ScanResult.new(findings:, files_count: files.length)
      end

      # Scan staged or unstaged git changes for exposed secrets
      # @param staged_only [Boolean] When true, scans only staged changes (default: true)
      # @return [ScanResult] The aggregated scan result
      def scan_git_diff(staged_only: true)
        self.findings = []

        command = staged_only ? 'git diff --cached' : 'git diff'
        diff_output, = Core::Console::Shell.sh(command:)

        return ScanResult.new(findings: [], files_count: 0) if diff_output.strip.empty?

        current_file = nil
        line_number = 0

        diff_output.each_line do |line|
          if line.start_with?('+++')
            current_file = line.sub(%r{^\+\+\+ b/}, '').strip
            line_number = 0
          elsif line.start_with?('+') && current_file && !line.start_with?('+++')
            line_number += 1
            check_line(
              file_path: current_file,
              line_number:,
              line: line[1..],
              is_addition: true
            )
          end
        end

        ScanResult.new(findings:, files_count: diff_output.lines.count)
      end

      private

      # Scan a single file line by line for exposed secrets
      # @param file_path [String] The path to the file to scan
      def scan_file(file_path:)
        return unless File.file?(file_path)

        Core::Console::Logger.verbose(message: "Scanning #{file_path}...")

        content = File.read(file_path)
        line_number = 0

        content.each_line do |line|
          line_number += 1
          check_line(file_path:, line_number:, line:)
        end
      rescue StandardError => e
        Core::Console::Logger.verbose(message: "Failed to scan #{file_path}: #{e.message}")
      end

      # Check a single line against all known secret patterns and suspicious assignments
      # @param file_path [String] The path of the file being scanned
      # @param line_number [Integer] The current line number within the file
      # @param line [String] The content of the line to check
      # @param is_addition [Boolean] Whether the line is a git diff addition (default: false)
      def check_line(file_path:, line_number:, line:, is_addition: false)
        return if line.strip.start_with?('#', '//', '/*', '*')
        return if line.length < 10

        PATTERNS.each do |type, config|
          next unless line.match?(config[:pattern])

          match = line.match(config[:pattern])

          findings << Finding.new(
            file: file_path,
            line: line_number,
            column: match.begin(0),
            type:,
            description: config[:description],
            severity: config[:severity],
            matched_text: mask_secret(secret: match[0]),
            full_line: line.strip,
            is_addition:
          )
        end

        check_suspicious_assignments(file_path:, line_number:, line:, is_addition:)
      end

      # Check a line for generic suspicious variable assignment patterns not caught by PATTERNS
      # @param file_path [String] The path of the file being scanned
      # @param line_number [Integer] The current line number within the file
      # @param line [String] The content of the line
      # @param is_addition [Boolean] Whether the line is a git diff addition
      def check_suspicious_assignments(file_path:, line_number:, line:, is_addition:)
        suspicious_pattern = /(?i)(api_?key|secret|token|password|passwd|pwd|auth|credential)\s*[=:]\s*['"]([^'"]{8,})['"]/

        return unless line.match?(suspicious_pattern)
        return if already_matched_by_pattern?(line:)

        match = line.match(suspicious_pattern)

        findings << Finding.new(
          file: file_path,
          line: line_number,
          column: match.begin(0),
          type: :suspicious_assignment,
          description: 'Suspicious secret assignment',
          severity: :low,
          matched_text: mask_secret(secret: match[0]),
          full_line: line.strip,
          is_addition:
        )
      end

      # Check whether a line was already captured by one of the specific PATTERNS
      # @param line [String] The line content to check
      # @return [Boolean] true if the line matches any known pattern
      def already_matched_by_pattern?(line:)
        PATTERNS.values.any? { |config| line.match?(config[:pattern]) }
      end

      # Recursively find all scannable files under a root path
      # @param path [String] The root directory path
      # @return [Array<String>] The list of matching absolute file paths
      def find_files(path:)
        result = []
        traverse_directory(
          path:,
          result:,
          current_depth: 0,
          max_depth: options.fetch(:max_depth, Globals.max_scan_depth)
        )
        result
      end

      # Recursively traverse a directory, collecting files that match the scan criteria
      # @param path [String] The current directory path
      # @param result [Array<String>] The accumulator for matching file paths
      # @param current_depth [Integer] The current traversal depth
      # @param max_depth [Integer] The maximum allowed traversal depth
      def traverse_directory(path:, result:, current_depth:, max_depth:)
        return if current_depth > max_depth

        Dir.each_child(path) do |entry|
          next if excluded?(name: entry)

          full_path = File.join(path, entry)

          if File.directory?(full_path)
            traverse_directory(
              path: full_path,
              result:,
              current_depth: current_depth + 1,
              max_depth:
            )
          elsif File.file?(full_path) && included_extension?(path: full_path)
            result << full_path
          end
        end
      rescue Errno::EACCES, Errno::ENOENT => e
        Core::Console::Logger.verbose(message: "Skipping #{path}: #{e.message}")
      end

      # Check whether a file or directory name matches an exclude pattern
      # @param name [String] The file or directory name to check
      # @return [Boolean] true if the entry should be excluded
      def excluded?(name:)
        exclude_patterns.any? { |pattern| name == pattern }
      end

      # Check whether a file path has an extension that should be scanned
      # @param path [String] The file path to check
      # @return [Boolean] true if the file extension is in the inclusion list
      def included_extension?(path:)
        file_extensions.include?(File.extname(path))
      end

      # Returns the configured list of file extensions to scan
      # @return [Array<String>] The file extensions
      def file_extensions
        options.fetch(:extensions, Globals.default_scan_extensions)
      end

      # Returns the configured list of directory and file names to exclude
      # @return [Array<String>] The exclude patterns
      def exclude_patterns
        options.fetch(:excludes, Globals.default_scan_excludes)
      end

      # Mask a secret value so only the first four characters are visible
      # @param secret [String] The secret string to mask
      # @return [String] The masked string, safe for display in logs
      def mask_secret(secret:)
        return '***' if secret.length <= 6

        "#{secret[0..3]}#{'*' * (secret.length - 4)}"
      end

      # Builds the default scanning options from globals
      # @return [Hash] The default options hash
      def default_options
        {
          extensions: Globals.default_scan_extensions,
          excludes: Globals.default_scan_excludes,
          max_depth: Globals.max_scan_depth,
          follow_symlinks: false,
        }
      end
    end
  end
end
