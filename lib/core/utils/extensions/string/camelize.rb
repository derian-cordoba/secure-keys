# Adds some useful methods to the String class
module Camelize
  # Convert a string to camel case format
  # @return [String] the camel case formatted string
  def camelize
    words = gsub(/[-_\s]+/, ' ') # Replace underscores, dashes, and spaces with a single space
            .split(/(?=[A-Z])|\s+/) # Split the string into words while preserving uppercase transitions
            .map(&:downcase) # Convert everything to lowercase to handle uppercase env variables

    # Lowercase the first word and capitalize the rest
    words.map.with_index do |word, index|
      index.zero? ? word : word.capitalize
    end.join
  end
end
