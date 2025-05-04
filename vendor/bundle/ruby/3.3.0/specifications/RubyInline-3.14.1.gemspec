# -*- encoding: utf-8 -*-
# stub: RubyInline 3.14.1 ruby lib

Gem::Specification.new do |s|
  s.name = "RubyInline".freeze
  s.version = "3.14.1".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.metadata = { "homepage_uri" => "http://www.zenspider.com/ZSS/Products/RubyInline/", "source_code_uri" => "https://github.com/seattlerb/rubyinline" } if s.respond_to? :metadata=
  s.require_paths = ["lib".freeze]
  s.authors = ["Ryan Davis".freeze]
  s.cert_chain = ["-----BEGIN CERTIFICATE-----\nMIIDPjCCAiagAwIBAgIBCDANBgkqhkiG9w0BAQsFADBFMRMwEQYDVQQDDApyeWFu\nZC1ydWJ5MRkwFwYKCZImiZPyLGQBGRYJemVuc3BpZGVyMRMwEQYKCZImiZPyLGQB\nGRYDY29tMB4XDTI0MDEwMjIxMjEyM1oXDTI1MDEwMTIxMjEyM1owRTETMBEGA1UE\nAwwKcnlhbmQtcnVieTEZMBcGCgmSJomT8ixkARkWCXplbnNwaWRlcjETMBEGCgmS\nJomT8ixkARkWA2NvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALda\nb9DCgK+627gPJkB6XfjZ1itoOQvpqH1EXScSaba9/S2VF22VYQbXU1xQXL/WzCkx\ntaCPaLmfYIaFcHHCSY4hYDJijRQkLxPeB3xbOfzfLoBDbjvx5JxgJxUjmGa7xhcT\noOvjtt5P8+GSK9zLzxQP0gVLS/D0FmoE44XuDr3iQkVS2ujU5zZL84mMNqNB1znh\nGiadM9GHRaDiaxuX0cIUBj19T01mVE2iymf9I6bEsiayK/n6QujtyCbTWsAS9Rqt\nqhtV7HJxNKuPj/JFH0D2cswvzznE/a5FOYO68g+YCuFi5L8wZuuM8zzdwjrWHqSV\ngBEfoTEGr7Zii72cx+sCAwEAAaM5MDcwCQYDVR0TBAIwADALBgNVHQ8EBAMCBLAw\nHQYDVR0OBBYEFEfFe9md/r/tj/Wmwpy+MI8d9k/hMA0GCSqGSIb3DQEBCwUAA4IB\nAQCygvpmncmkiSs9r/Kceo4bBPDszhTv6iBi4LwMReqnFrpNLMOWJw7xi8x+3eL2\nXS09ZPNOt2zm70KmFouBMgOysnDY4k2dE8uF6B8JbZOO8QfalW+CoNBliefOTcn2\nbg5IOP7UoGM5lC174/cbDJrJnRG9bzig5FAP0mvsgA8zgTRXQzIUAZEo92D5K7p4\nB4/O998ho6BSOgYBI9Yk1ttdCtti6Y+8N9+fZESsjtWMykA+WXWeGUScHqiU+gH8\nS7043fq9EbQdBr2AXdj92+CDwuTfHI6/Hj5FVBDULufrJaan4xUgL70Hvc6pTTeW\ndeKfBjgVAq7EYHu1AczzlUly\n-----END CERTIFICATE-----\n".freeze]
  s.date = "2024-06-23"
  s.description = "Inline allows you to write foreign code within your ruby code. It\nautomatically determines if the code in question has changed and\nbuilds it only when necessary. The extensions are then automatically\nloaded into the class/module that defines it.\n\nYou can even write extra builders that will allow you to write inlined\ncode in any language. Use Inline::C as a template and look at\nModule#inline for the required API.".freeze
  s.email = ["ryand-ruby@zenspider.com".freeze]
  s.extra_rdoc_files = ["History.txt".freeze, "Manifest.txt".freeze, "README.txt".freeze]
  s.files = ["History.txt".freeze, "Manifest.txt".freeze, "README.txt".freeze]
  s.homepage = "http://www.zenspider.com/ZSS/Products/RubyInline/".freeze
  s.licenses = ["MIT".freeze]
  s.rdoc_options = ["--main".freeze, "README.txt".freeze]
  s.requirements = ["A POSIX environment and a compiler for your language.".freeze]
  s.rubygems_version = "3.5.14".freeze
  s.summary = "Inline allows you to write foreign code within your ruby code".freeze

  s.installed_by_version = "3.5.22".freeze

  s.specification_version = 4

  s.add_runtime_dependency(%q<ZenTest>.freeze, ["~> 4.3".freeze])
  s.add_development_dependency(%q<rdoc>.freeze, [">= 4.0".freeze, "< 7".freeze])
  s.add_development_dependency(%q<hoe>.freeze, ["~> 4.2".freeze])
end
