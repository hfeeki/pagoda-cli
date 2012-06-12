require 'socketIO'

module Pagoda::Command
  class Log < Base

    COLORS = [
      'white',
      'red',
      'yellow',
      'blue',
      'magenta',
      'cyan',
      'green'
      ]

    def run
      puts 'in run'
      user_input = options[:component] || args.first
      puts "user input #{user_input}"

      if user_input =~ /^(web\d*)|(db\d*)|(cache\d*)|(worker\d*)$/
        comps = user_input
      else
        comps = nil
      end

      puts "comp: #{comps}"

      auth_hash = {user: user, pass: password, app: app}
      auth_hash['comps'] = comps unless comps == nil

      puts auth_hash

      puts 'connecting'
      client = SocketIO.connect("http://log.pagodabox.com:8080") do
        before_start do
          on_event('auth_challenge') do
            puts 'got auth_challenge event'
            puts emit('authenticate', auth_hash)
          end

          on_event('authenticated') do
            puts "Successfully Authenticated"
          end

          on_event('error') do |hash|
            error hash['message']
          end

          on_event('subscribed') do |hash|
            puts hash.class
            if hash['success']
              puts "successfully subscribed to #{hash['comp']}"
            else
              puts "failed to subscribe to #{hash['comp']}"
            end
          end

          on_event('unsubscribed') do |hash|
            puts "#{hash['success'] ? 'successfully unsubscribed from' : 'failed to unsubscribe from' } #{hash['comp']}"
          end

          on_event('log') do |hash|
            puts hash['message']
          end

          on_disconnect { puts "Disconnected" }

        end

      end
      # else
      #   error "Something went wrong"
      # end
    end

    def colorize message
      @hash |= {}
      if color =  @hash[message.split(' ')[1]]
        puts message.send(color)
      else
        puts message.send(@hash[message.split(' ')[1]] = next_color)
        # retry  
      end
    end

    def next_color
      COLORS[@hash.length % COLORS.length]
    end

    def output_error
      errors = []
      errors << "Input unrecoginized"
      errors << "try 'pagoda -a <appname> log <component>'"
      errors << "ie. 'pagoda -a app log db1'"
      error errors
    end

  end
end