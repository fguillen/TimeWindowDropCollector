# -*- encoding: utf-8 -*-
$:.push File.expand_path( "../lib", __FILE__ )
require "time_window_drop_collector/version"

Gem::Specification.new do |s|
  s.name        = "time_window_drop_collector"
  s.version     = TimeWindowDropCollector::VERSION
  s.authors     = ["Fernando Guillen", "Carlos Moutinho"]
  s.email       = ["fguillen.mail@gmail.com", "carlosmoutinho@gmail.com"]
  s.homepage    = "https://github.com/fguillen/TimeWindowDropCollector"
  s.summary     = "Counter storage system for a concrete time window"
  s.description = "Counter storage system for a concrete time window"

  s.rubyforge_project = "time_window_drop_collector"

  s.files         = `git ls-files`.split( "\n" )
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split( "\n" )
  s.executables   = `git ls-files -- bin/*`.split( "\n" ).map{ |f| File.basename( f ) }
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake",            "0.9.2.2"
  s.add_development_dependency "mocha",           "0.10.0"
  s.add_development_dependency "delorean",        "1.2.0"
  s.add_development_dependency "memcache_mock",   "0.0.14"

  s.add_dependency "dalli"
end
