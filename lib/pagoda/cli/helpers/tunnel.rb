require 'pagoda-tunnel'

module Pagoda::Command
  class Tunnel < Base

    def run
      if (api.app_show(app)[:service_type] == :family)
        # api tunnel commands
      else
        user_input = options[:component] || args.first
        component = {}
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