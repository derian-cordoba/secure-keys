require_relative './string/to_bool'

module Kernel
  include BooleanCasting

  String.include(BooleanCasting)
  String.singleton_class.include(BooleanCasting)
end
