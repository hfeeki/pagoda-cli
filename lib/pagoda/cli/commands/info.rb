desc 'Get information for a specific app'
arg_name 'Application Name'
command :info do |c|

  c.desc 'App on pagodabox'
  c.arg_name 'APP_NAME'
  c.flag [:a, :app]

  c.action do |global_options,options,args|
    require 'pagoda/cli/helpers/app'
    ::Pagoda::Command::App.new(global_options,options,args).info
  end
end