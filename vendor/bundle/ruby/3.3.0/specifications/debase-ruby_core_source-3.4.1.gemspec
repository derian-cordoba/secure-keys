# -*- encoding: utf-8 -*-
# stub: debase-ruby_core_source 3.4.1 ruby lib

Gem::Specification.new do |s|
  s.name = "debase-ruby_core_source".freeze
  s.version = "3.4.1".freeze

  s.required_rubygems_version = Gem::Requirement.new(">= 1.3.6".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Mark Moseley".freeze, "Gabriel Horner".freeze, "JetBrains RubyMine Team".freeze]
  s.date = "2025-01-13"
  s.description = "Provide Ruby core source files for C extensions that need them.".freeze
  s.email = "os97673@gmail.com".freeze
  s.extra_rdoc_files = ["README.md".freeze]
  s.files = ["README.md".freeze]
  s.homepage = "https://github.com/ruby-debug/debase-ruby_core_source".freeze
  s.licenses = ["MIT".freeze]
  s.required_ruby_version = Gem::Requirement.new(">= 2.0.0".freeze)
  s.rubygems_version = "3.6.2".freeze
  s.summary = "Provide Ruby core source files".freeze

  s.installed_by_version = "3.5.22".freeze

  s.specification_version = 4

  s.add_development_dependency(%q<archive-tar-minitar>.freeze, [">= 0.5.2".freeze])
  s.add_development_dependency(%q<rake>.freeze, [">= 0.9.2".freeze])
  s.add_development_dependency(%q<minitar-cli>.freeze, [">= 0".freeze])
  s.add_development_dependency(%q<test-unit>.freeze, ["~> 3.6.7".freeze])
end
