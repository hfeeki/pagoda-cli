desc 'Tunnel to a component in your application'
arg_name 'Component name'
command :tunnel do |c|

  c.desc 'Component name you want to connect to'
  c.arg_name 'COMPONENT_NAME'
  c.flag [:c, :component]

  c.desc 'New app name'
  c.arg_name 'APP_NAME'
  c.flag [:a, :app]


  c.action do |global_options,options,args|
    require 'pagoda/cli/helpers/tunnel'
    Pagoda::Command::Tunnel.new(global_options,options,args).run
  end
end