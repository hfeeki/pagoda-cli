require 'pagoda-tunnel'

module Pagoda::Command
  class Tunnel < Base

    def run
      if (api.app_show(app)[:service_type] == :family)
        # api tunnel commands
      else
        user_input = options[:component] || args.first
        puts user_input
        component = {}
        begin
          if user_input =~ /^(web\d*)|(db\d*)|(cache\d*)|(worker\d*)$/
            puts "getting list"
            components = client.component_list(app)
            puts components
            components.delete_if {|x| x[:cuid] != user_input }
            puts 'filtering components'
            component = components[0]
            puts component
          else
            component = client.component_info(app, user_input)
            puts component
          end
        rescue Exception => e
          puts e.message
          puts e.backtrace
          output_error
        end
        output_error unless component
        if component[:tunnelable]
          type = component[:_type]
          component_id = component[:_id]
          app_id = component[:app_id]
          Pagoda::Tunnel.new(type, user, password, app_id, component_id).start
        else
          error "Either the component is not tunnelable or you do not have access"
        end
        
      end

    end

    def output_error
      errors = []
      errors << "Input unrecoginized"
      errors << "try 'pagoda -a <appname> tunnel <component>'"
      errors << "ie. 'pagoda -a app tunnel db1'"
      error errors
    end

  end
end