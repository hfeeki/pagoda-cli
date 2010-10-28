require 'webmock/rspec'

require 'pagoda/command'
require 'pagoda/commands/base'

Dir["#{File.dirname(__FILE__)}/../lib/pagoda/commands/*"].each { |c| require c }

include WebMock::API

def stub_api_request(method, path)
  stub_request(method, "https://api.pagodagrid.com#{path}")
end

def prepare_command(klass)
  command = klass.new(['--app', 'myapp'])
  command.stub!(:args).and_return([])
  command.stub!(:display)
  # command.stub!(:heroku).and_return(mock('heroku client', :host => 'heroku.com'))
  command.stub!(:extract_app).and_return('myapp')
  command
end