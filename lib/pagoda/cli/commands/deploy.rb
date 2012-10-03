desc 'Deploy your current code branch and commit to your Pagoda Box app'
command :deploy do |c|

  c.desc 'Your application name on pagodabox'
  c.arg_name 'APP_NAME'
  c.flag [:a, :app]

  c.action do |global_options,options,args|
    require 'pagoda/cli/helpers/app'
    Pagoda::Command::App.new(global_options,options,args).deploy
  end
end