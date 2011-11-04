#!/usr/bin/env rake
require "bundler/gem_tasks"
require "rspec/core/rake_task"
require 'rake/packagetask'


desc "Run all specs"
RSpec::Core::RakeTask.new('spec') do |t|
  t.rspec_opts = ['--colour --format documentation']
end

desc "Package task"
Rake::PackageTask.new("pagoda", Pagoda::CLI::VERSION ) do |p|
  p.need_tar_gz = true
  p.package_files.include("./**/**/**/**")
end

task :push do
  sh "scp pkg/pagoda-#{Pagoda::CLI::VERSION}.tar.gz getdeb@pagodabox.com:shared/pagoda/"
end