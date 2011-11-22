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
      component_name = options[:component]
      component = {}
      if component_name
        begin
          if user_input =~ /^(web\d*)|(db\d*)|(cache\d*)|(worker\d*)$/
            components = client.component_list(app)
            components.delete_if {|x| x[:cuid] != user_input }
            component = components[0]
          else
            component = client.component_info(app, user_input)
          end
        rescue
          output_error
        end
      else
        component = client.app_info(app)
      end
      output_error unless component
      puts component
      if component[:_id]
        client = SocketIO.connect("log.pagodabox.com") do
          before_start do
            on_event("log.#{component[:id]}.live") {|msg| colorize msg}
            on_disconnect {puts "Disconnected"}
          end

          after_start do
            emit("subscribe", [user, password, "log.#{component[:id]}.live"])
          end
        end
      else
        error "Something went wrong"
      end
    end

    def colorize message
      @hash |= {}
      if color =  @hash[message.split(' ')[1]]
        puts message.send(color)
      else
        @hash[message.split(' ')[1]] = next_color
        retry  
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