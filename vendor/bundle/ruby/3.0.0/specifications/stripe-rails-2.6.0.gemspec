# -*- encoding: utf-8 -*-
# stub: stripe-rails 2.6.0 ruby lib

Gem::Specification.new do |s|
  s.name = "stripe-rails".freeze
  s.version = "2.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Charles Lowell".freeze, "Nola Stowe".freeze, "SengMing Tan".freeze]
  s.date = "2024-08-12"
  s.description = "A gem to integrate stripe into your rails app".freeze
  s.email = ["sengming@sanemen.com".freeze]
  s.homepage = "https://github.com/tansengming/stripe-rails".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.3.5".freeze
  s.summary = "A gem to integrate stripe into your rails app".freeze

  s.installed_by_version = "3.3.5" if s.respond_to? :installed_by_version

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<rails>.freeze, [">= 5.1"])
    s.add_runtime_dependency(%q<stripe>.freeze, [">= 3.15.0"])
    s.add_runtime_dependency(%q<responders>.freeze, [">= 0"])
  else
    s.add_dependency(%q<rails>.freeze, [">= 5.1"])
    s.add_dependency(%q<stripe>.freeze, [">= 3.15.0"])
    s.add_dependency(%q<responders>.freeze, [">= 0"])
  end
end
