#!/usr/bin/env ruby

module SecureKeys
  module Validation
    module Entropy
      module_function

      # Calculate the Shannon entropy of a string
      # @param string [String] The string to analyze
      # @return [Float] The Shannon entropy value (higher means more random)
      def calculate(string:)
        return 0.0 if string.empty?

        frequencies = Hash.new(0)
        string.each_char { |char| frequencies[char] += 1 }

        frequencies.each_value.sum do |count|
          frequency = count.to_f / string.length
          -frequency * Math.log2(frequency)
        end
      end
    end
  end
end
