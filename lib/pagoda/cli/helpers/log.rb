require 'socketIO'

module Pagoda::Command
  class Log < Base

    COLORS = [
      'light_black',
      'light_red',
      'light_green',
      'light_yellow',
      'light_blue',
      'light_magenta',
      'light_cyan',
      'light_white',
      'white',
      'red',
      'yellow',
      'blue',
      'magenta',
      'cyan',
      'green'
      ]

    'light_black',    => 10,
    'light_red',      => 11,
    'light_green',    => 12,
    'light_yellow',   => 13,
    'light_blue',     => 14,
    'light_magenta',  => 15,
    'light_cyan',     => 16,
    'light_white',    => 17
    def run
      user_input = options[:component] || args.first

      if user_input =~ /^(web\d*)|(db\d*)|(cache\d*)|(worker\d*)$/
        comps = user_input
      else
        comps = nil
      end


      auth_hash = {user: user, pass: password, app: app}
      auth_hash['comps'] = comps unless comps == nil
      message_block = ->(hash) { colorize hash[0]['message'] }


      client = SocketIO.connect("http://log.pagodabox.com:8080") do

        before_start do
          on_event('auth_challenge') do
            emit('authenticate', auth_hash)
          end

          on_event('authenticated') do
            puts "Successfully Authenticated"
          end

          on_event('error') do |hash|
            error hash[0]['message']
          end

          on_event('subscribed') do |hash|
            if hash[0]['success']
              puts "successfully subscribed to #{hash[0]['comp']}"
            else
              puts "failed to subscribe to #{hash[0]['comp']}"
            end
          end

          on_event('unsubscribed') do |hash|
            puts "#{hash[0]['success'] ? 'successfully unsubscribed from' : 'failed to unsubscribe from' } #{hash[0]['comp']}"
          end

          on_event('log', &message_block)

          on_disconnect { puts "Disconnected" }

        end

      end
      # else
      #   error "Something went wrong"
      # end
    end

    def colorize message
      @hash ||= {}
      if color = @hash[message.split(' ')[0]]
        puts message.send(color)
      else
        puts message.send(@hash[message.split(' ')[0]] = next_color)
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