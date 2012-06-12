desc 'Real time log to your pagodabox application'
arg_name ''
command :log do |c|

  c.desc 'Component name you want to connect to'
  c.arg_name 'COMPONENT_NAME'
  c.flag [:c, :component]

  c.desc 'App name'
  c.arg_name 'APP_NAME'
  c.flag [:a, :app]

  c.action do |global_options,options,args|
    require 'pagoda/cli/helpers/log'
    Pagoda::Command::Log.new(global_options,options,args).run
  end
end