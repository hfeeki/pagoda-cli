require 'rake'
require 'jeweler'
require 'rspec'
require 'rspec/core/rake_task'

desc "Run all specs"
RSpec::Core::RakeTask.new('spec') do |t|
  t.rspec_opts = ['--colour --format progress']
end

desc "Print specdocs"
RSpec::Core::RakeTask.new(:doc) do |t|
  t.rspec_opts = ["--format", "specdoc", "--dry-run"]
  # t.spec_files = FileList['spec/*_spec.rb']
end

desc "Generate RCov code coverage report"
RSpec::Core::RakeTask.new('rcov') do |t|
  # t.spec_files = FileList['spec/*_spec.rb']
  t.rcov         = true
  t.rcov_opts    = ['--exclude', 'examples']
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


