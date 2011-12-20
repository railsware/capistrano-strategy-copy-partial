# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "capistrano-strategy-copy-partial"

Gem::Specification.new do |s|
  s.name        = "capistrano-strategy-copy-partial"
  s.version     = CapistranoStrategyCopyPartial::VERSION
  s.authors     = ["Maxim Bondaruk"]
  s.email       = ["maxim.bondaruk@railsware.com"]
  s.homepage    = "http://github.com/railsware/capistrano-strategy-copy-partial"
  s.summary     = %q{Capistrano deploy strategy to transfer subdirectory of repository}
  
  s.rubyforge_project = "capistrano-strategy-copy-partial"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency "capistrano", ">=2.5.5"
end
