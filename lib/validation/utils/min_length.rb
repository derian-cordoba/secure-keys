#!/usr/bin/env ruby

require_relative '../globals/globals'

module SecureKeys
  module Validation
    # Minimum length requirements by key type
    MIN_LENGTHS = {
      api_key: Globals.api_key_length,
      token: Globals.token_length,
      secret: Globals.secret_length,
      password: Globals.password_length,
      key: Globals.key_length,
    }.freeze
  end
end
