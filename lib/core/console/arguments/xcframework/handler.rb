module SecureKeys
  module Core
    module Console
      module Argument
        module XCFramework
          class Handler
            class << self
              attr_reader :arguments
            end

            # Configure the default arguments
            @arguments = {
              replace: false,
              target: nil,
              xcodeproj: nil,
            }
          end
        end
      end
    end
  end
end
