# Handler extension to update the arguments values
# This helper is used only for testing purposes
module SecureKeys
  module Core
    module Console
      module Argument
        class Handler
          # Reset the arguments to initial values
          def self.reset
            @arguments = {
              delimiter: nil,
              identifier: nil,
              verbose: false,
            }
          end
        end
      end
    end
  end
end
