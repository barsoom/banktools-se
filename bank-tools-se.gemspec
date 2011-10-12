# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bank-tools-se/version"

Gem::Specification.new do |s|
  s.name        = "bank-tools-se"
  s.version     = Bank::Tools::SE::VERSION
  s.authors     = ["Henrik Nyh"]
  s.email       = ["henrik@barsoom.se"]
  s.homepage    = ""
  s.summary     = %q{Validate and prettify Swedish bank account numbers, plusgiro and bankgiro.}
  s.description = %q{Validate and prettify Swedish bank account numbers, plusgiro and bankgiro.}

  s.rubyforge_project = "bank-tools-se"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
