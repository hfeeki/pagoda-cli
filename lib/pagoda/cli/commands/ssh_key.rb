desc 'Generate an ssh key and post it to pagodabox'
arg_name 'Describe arguments to destroy here'
command 'key:gen' do |c|

  c.desc 'File that will contain your ssh key'
  c.arg_name 'FILE_NAME'
  c.flag [:f, :file]

  c.action do |global_options,options,args|
    require 'pagoda/cli/helpers/key'
    Pagoda::Command::Key.new(global_options,options,args).generate_key_and_push
  end
end

desc 'Post an existiong ssh key to pagodabox'
command 'key:push' do |c|

  c.desc 'File that contains your ssh key'
  c.arg_name 'FILE_NAME'
  c.flag [:f, :file]


  c.action do |global_options,options,args|
    require 'pagoda/cli/helpers/key'
    Pagoda::Command::Key.new(global_options,options,args).push_existing_key
  end
end