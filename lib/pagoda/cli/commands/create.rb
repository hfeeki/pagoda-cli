desc 'Create a new application on pagodabox'
arg_name 'new-application-name'
command :create do |c|

  c.desc 'New app name'
  c.arg_name 'APP_NAME'
  c.flag [:a, :app]

  c.action do |global_options,options,args|
    require 'pagoda/cli/helpers/app'
    Pagoda::Command::App.new(global_options,options,args).create
  end
end