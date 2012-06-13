require 'socketIO'

module Pagoda::Command
  class Log < Base

    COLORS = [
      'light_red',
      'light_green',
      'light_yellow',
      'light_blue',
      'light_magenta',
      'light_cyan',
      'white',
      'red',
      'yellow',
      'blue',
      'magenta',
      'cyan',
      'green'
      ]

    def run
      user_input = options[:component] || args.first

      if user_input =~ /^(web\d*)|(db\d*)|(cache\d*)|(worker\d*)$/
        comps = user_input
      else
        comps = nil
      end


      auth_hash = {user: user, pass: password, app: app}
      auth_hash['comps'] = [comps] unless comps == nil
      message_block = ->(hash) { colorize hash[0]['message'], hash[0]['name'] }

      @client = SocketIO.connect("http://logvac.pagodabox.com", sync: true) do

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

          on_disconnect do
            puts "Disconnected"
            exit 0
          end

        end

      end

      [:INT, :TERM].each do |sig|
        Signal.trap(sig) do
          @client.disconnect
          puts "Log Closed."
          puts "-----------------------------------------------"
          puts
          exit
        end
      end

      loop { sleep 1000 }

    end

    def colorize message, name
      @hash ||= {}
      if color = @hash[name]
        puts message.send(color)
      else
        puts message.send(@hash[name] = next_color)
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