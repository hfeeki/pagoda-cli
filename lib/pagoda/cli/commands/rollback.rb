desc 'Rollback your repo to the deploy it was on last'
command :rollback do |c|

  c.desc 'Application to be rolled back'
  c.arg_name 'APP_NAME'
  c.flag [:a, :app]

  c.action do |global_options,options,args|
    require 'pagoda/cli/helpers/app'
    Pagoda::Command::App.new(global_options, options, args).rollback
  end
end