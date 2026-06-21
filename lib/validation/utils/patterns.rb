#!/usr/bin/env ruby

# rubocop:disable Lint/Syntax, Metrics/ModuleLength

module SecureKeys
  module Validation
    # Known secret patterns with descriptions
    PATTERNS = {
      # GitHub
      github_token: {
        pattern: /ghp_[a-zA-Z0-9]{36}/,
        description: 'GitHub Personal Access Token',
        severity: :high,
        example: 'ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
      },
      github_oauth: {
        pattern: /gho_[a-zA-Z0-9]{36}/,
        description: 'GitHub OAuth Access Token',
        severity: :high,
        example: 'gho_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
      },
      github_app: {
        pattern: /(ghu|ghs)_[a-zA-Z0-9]{36}/,
        description: 'GitHub App Token',
        severity: :high,
        example: 'ghu_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
      },
      github_refresh: {
        pattern: /ghr_[a-zA-Z0-9]{36}/,
        description: 'GitHub Refresh Token',
        severity: :high,
        example: 'ghr_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
      },

      # AWS
      aws_access_key: {
        pattern: /AKIA[0-9A-Z]{16}/,
        description: 'AWS Access Key ID',
        severity: :critical,
        example: 'AKIAIOSFODNN7EXAMPLE'
      },
      aws_secret_key: {
        pattern: %r{(?i)aws(.{0,20})?['\"][0-9a-zA-Z/+]{40}['\"]},
        description: 'AWS Secret Access Key',
        severity: :critical,
        example: 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY'
      },
      aws_session_token: {
        pattern: %r{(?i)aws(.{0,20})?session(.{0,20})?['\"][0-9a-zA-Z/+]{100,}['\"]},
        description: 'AWS Session Token',
        severity: :high,
        example: 'FwoGZXIvYXdzEBaa...(very long token)'
      },

      # Google Cloud
      gcp_api_key: {
        pattern: /AIza[0-9A-Za-z\-_]{35}/,
        description: 'Google Cloud API Key',
        severity: :high,
        example: 'AIzaSyDaGmWKa4JsXZ-HjGw7ISLn_3namBGewQe'
      },
      gcp_oauth: {
        pattern: /ya29\.[0-9A-Za-z\-_]+/,
        description: 'Google OAuth Access Token',
        severity: :high,
        example: 'ya29.a0AfH6SMBx...'
      },

      # Stripe
      stripe_secret_key: {
        pattern: /sk_(live|test)_[0-9a-zA-Z]{24,}/,
        description: 'Stripe Secret Key',
        severity: :critical,
        example: 'sk_live_51H...'
      },
      stripe_publishable_key: {
        pattern: /pk_(live|test)_[0-9a-zA-Z]{24,}/,
        description: 'Stripe Publishable Key',
        severity: :medium,
        example: 'pk_live_51H...'
      },
      stripe_restricted_key: {
        pattern: /rk_(live|test)_[0-9a-zA-Z]{24,}/,
        description: 'Stripe Restricted Key',
        severity: :high,
        example: 'rk_live_51H...'
      },

      # Slack
      slack_token: {
        pattern: /xox[baprs]-[0-9a-zA-Z]{10,48}/,
        description: 'Slack Token',
        severity: :high,
        example: 'xoxb-1234567890123-1234567890123-xxxxxxxxxxxxx'
      },
      slack_webhook: {
        pattern: %r{https://hooks\.slack\.com/services/T[a-zA-Z0-9_]{8,}/B[a-zA-Z0-9_]{8,}/[a-zA-Z0-9_]{24}},
        description: 'Slack Webhook URL',
        severity: :medium,
        example: 'https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX'
      },

      # OAuth & JWT
      jwt_token: {
        pattern: %r{eyJ[A-Za-z0-9\-_=]+\.eyJ[A-Za-z0-9\-_=]+\.?[A-Za-z0-9\-_.+/=]*},
        description: 'JWT Token',
        severity: :medium,
        example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dozjgNryP4J3jVmNHl0w5N_XgL0n3I9PlFUP0THsR8U'
      },

      # Generic patterns
      private_key: {
        pattern: /-----BEGIN (RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----/,
        description: 'Private Key',
        severity: :critical,
        example: '-----BEGIN PRIVATE KEY-----'
      },
      generic_api_key: {
        pattern: /(?i)(api[_-]?key|apikey)[\s]*[:=][\s]*['\"]([a-zA-Z0-9_\-]{20,})['\"]/,
        description: 'Generic API Key',
        severity: :medium,
        example: 'api_key: "abcdef1234567890abcdef1234567890"'
      },
      generic_secret: {
        pattern: /(?i)(secret|password|passwd|pwd)[\s]*[:=][\s]*['\"]([^\s'\"]{8,})['\"]/,
        description: 'Generic Secret/Password',
        severity: :medium,
        example: 'secret: "mysecretpassword123"'
      },

      # Firebase
      firebase_key: {
        pattern: /AIza[0-9A-Za-z\-_]{35}/,
        description: 'Firebase API Key',
        severity: :medium,
        example: 'AIzaSyDaGmWKa4JsXZ-HjGw7ISLn_3namBGewQe'
      },

      # Twilio
      twilio_api_key: {
        pattern: /SK[a-z0-9]{32}/,
        description: 'Twilio API Key',
        severity: :high,
        example: 'SKxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
      },
      twilio_account_sid: {
        pattern: /AC[a-z0-9]{32}/,
        description: 'Twilio Account SID',
        severity: :low,
        example: 'ACxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
      },

      # SendGrid
      sendgrid_api_key: {
        pattern: /SG\.[a-zA-Z0-9_\-]{22}\.[a-zA-Z0-9_\-]{43}/,
        description: 'SendGrid API Key',
        severity: :high,
        example: 'SG.xxxxxxxxxxxxxxxxxxxxxx.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
      },

      # Mailchimp
      mailchimp_api_key: {
        pattern: /[a-f0-9]{32}-us[0-9]{1,2}/,
        description: 'Mailchimp API Key',
        severity: :medium,
        example: 'abcdef1234567890abcdef1234567890-us19'
      },

      # Square
      square_access_token: {
        pattern: /sq0atp-[0-9A-Za-z\-_]{22}/,
        description: 'Square Access Token',
        severity: :high,
        example: 'sq0atp-xxxxxxxxxxxxxxxxxxxxxx'
      },

      # PayPal
      paypal_braintree: {
        pattern: /access_token\$production\$[a-z0-9]{16}\$[a-f0-9]{32}/,
        description: 'PayPal Braintree Access Token',
        severity: :critical,
        example: 'access_token$production$xxxxxxxxxxxxxxxx$xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
      },

      # Heroku
      heroku_api_key: {
        pattern: /[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}/,
        description: 'Heroku API Key (UUID format)',
        severity: :high,
        example: '12345678-1234-1234-1234-123456789012'
      },

      # Generic Base64 secrets (often used for keys)
      base64_secret: {
        pattern: %r{(?i)(secret|key|token|password)[\s]*[:=][\s]*['\"]([A-Za-z0-9+/]{40,}={0,2})['\"]},
        description: 'Base64 Encoded Secret',
        severity: :low,
        example: 'secret: "YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXoxMjM0NTY3ODkw"'
      }
    }.freeze
  end
end

# rubocop:enable Lint/Syntax, Metrics/ModuleLength
