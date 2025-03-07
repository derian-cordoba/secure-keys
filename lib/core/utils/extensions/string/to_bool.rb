# Adds some useful methods to the String class
module BooleanCasting
  # Casts a string to a boolean
  # @return [Boolean] the boolean value of the string
  def to_bool
    return true if self == true || self =~ /^(true|t|yes|y|1)$/i
    return false if self == false || empty? || self =~ /^(false|f|no|n|0)$/i

    # If the string is not a boolean, return false by default
    false
  end
  alias to_b to_bool
  alias to_boolean to_bool
end
