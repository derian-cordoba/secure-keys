#!/usr/bin/env ruby

module SecureKeys
  module Validation
    # Common weak or test values that should never be used
    WEAK_SECRETS = %w[
      password password123 123456 secret test demo
      admin root changeme temp default example
      sample placeholder your-key-here your_api_key
      xxxxxxxxxxxx 0000000000 1234567890
    ].freeze
  end
end
