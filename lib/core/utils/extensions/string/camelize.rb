# Adds some useful methods to the String class
module Camelize
  # Convert a string to camel case format
  # @return [String] the camel case formatted string
  def camelize
    words = split(/(?<=[a-z])(?=[A-Z])|[-_\s]+/) # Split at lowercase-to-uppercase transitions or explicit separators
            .map(&:downcase) # Convert everything to lowercase for consistency

    words.map.with_index { |word, index| index.zero? ? word : word.capitalize }.join
  end
end
