# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{pagoda}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tyler Flint"]
  s.date = %q{2010-10-29}
  s.default_executable = %q{pagoda}
  s.description = %q{client for interacting with the pagodagrid}
  s.email = %q{tyler@pagodagrid.com}
  s.executables = ["pagoda"]
  s.extra_rdoc_files = [
    "README"
  ]
  s.files = [
    "Gemfile",
     "Gemfile.lock",
     "README",
     "Rakefile",
     "VERSION",
     "bin/pagoda",
     "lib/pagoda.rb",
     "lib/pagoda/client.rb",
     "lib/pagoda/command.rb",
     "lib/pagoda/commands/app.rb",
     "lib/pagoda/commands/auth.rb",
     "lib/pagoda/commands/base.rb",
     "lib/pagoda/helpers.rb",
     "lib/pagoda/version.rb",
     "spec/base.rb",
     "spec/client_spec.rb",
     "spec/command_spec.rb",
     "spec/commands/app_spec.rb",
     "spec/commands/auth_spec.rb",
     "spec/commands/base_spec.rb"
  ]
  s.homepage = %q{http://pagodagrid.com/}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{client for interacting with the pagodagrid}
  s.test_files = [
    "spec/base.rb",
     "spec/client_spec.rb",
     "spec/command_spec.rb",
     "spec/commands/app_spec.rb",
     "spec/commands/auth_spec.rb",
     "spec/commands/base_spec.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

