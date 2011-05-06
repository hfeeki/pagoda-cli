# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "pagoda/version"

Gem::Specification.new do |s|
  s.name        = "pagoda"
  s.version     = Pagoda::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["lyon hill"]
  s.email       = ["hal@pagodabox.com"]
  s.homepage    = "http://www.pagodabox.com/"
  s.summary     = %q{Terminal client for interacting with the pagodabox}
  s.description = %q{Terminal client for interacting with the pagodabox. This client does not contain full api functionality, just functionality that will enhance the workflow experience.}

  s.rubyforge_project = "pagoda"
  
  s.add_development_dependency "rspec"
  s.add_development_dependency "webmock"

  s.add_dependency "crack"
  s.add_dependency "iniparse"
  s.add_dependency "json_pure"
  s.add_dependency "rest-client"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
