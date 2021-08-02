# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "banktools-se/version"

Gem::Specification.new do |s|
  s.name        = "banktools-se"
  s.version     = BankTools::SE::VERSION
  s.authors     = ["Henrik Nyh"]
  s.email       = ["henrik@barsoom.se"]
  s.homepage    = ""
  s.summary     = %q{Validate and normalize Swedish bank account numbers, plusgiro and bankgiro.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
end
