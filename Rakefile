require 'rake'
require 'jeweler'
require 'rspec'
require 'rspec/core/rake_task'

desc "Run all specs"
RSpec::Core::RakeTask.new('spec') do |t|
  t.rspec_opts = ['--colour --format progress']
end

task :default => :spec

Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name        = "pagoda"
  gem.summary     = %Q{client for interacting with the pagodagrid}
  gem.description = %Q{client for interacting with the pagodagrid}
  gem.email       = "tyler@pagodagrid.com"
  gem.homepage    = "http://pagodagrid.com/"
  gem.authors     = ["Tyler Flint"]
  gem.files       = Dir["{lib}/**/*", "{bin}/**/*", "{spec}/**/*","[A-Z]*"]
  gem.executables = ['pagoda']
  
  # dependencies
  # gem.add_dependency "gem"
end


