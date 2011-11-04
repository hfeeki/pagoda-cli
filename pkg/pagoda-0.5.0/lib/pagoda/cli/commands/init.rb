desc 'Connect your local repo with your pagodabox repo.'
arg_name 'APP_NAME'
command :init do |c|

  c.desc 'App name initializing to'
  c.arg_name 'APP_NAME'
  c.flag [:a, :app]

  c.action do |global_options,options,args|
    require 'pagoda/cli/helpers/app'
    Pagoda::Command::App.new(global_options,options,args).init
  end
end