require_relative 'string/to_bool'
require_relative 'string/camelize'

module Kernel
  include BooleanCasting
  include Camelize

  String.include(BooleanCasting)
  String.singleton_class.include(BooleanCasting)

  String.include(Camelize)
  String.singleton_class.include(Camelize)
end
