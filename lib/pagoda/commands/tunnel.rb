module Pagoda::Command
  class Tunnel < Auth

    def index
      # ensure we have an app,
      # let app exit if not found
      app
      type = (option_value("-t", "--type") || 'mysql').to_sym
      instance_name = option_value("-n", "--name")
      unless instance_name
        case type
        when :mysql
          # try to find mysql instances here
          dbs = client.app_databases(app)
          if dbs.length == 0
            errors = []
            errors << "It looks like you don't have any MySQL instances for #{app}"
            errors << "Feel free to add one in the admin panel (10 MB Free)"
            error errors
          elsif dbs.length == 1  
            instance_name = dbs.first[:name]
          else
            errors = []
            errors << "Multiple MySQL instances found"
            errors << ""
            dbs.each do |instance|
              errors << "-> #{instance[:name]}"
            end
            errors << ""
            errors << "Please specify which instance you would like to use."
            errors << ""
            errors << "ex: pagoda tunnel -n #{dbs[0][:name]}"
            error errors
          end
        end
      end
      display
      display "+> Authenticating Database Ownership"
      if client.database_exists?(app, instance_name)
        Pagoda::TunnelProxy.new(type, user, password, app, instance_name).start
      else
        errors = []
        errors << "Security exception -"
        errors << "Either the MySQL instance doesn't exist or you are unauthorized"
        error errors
      end
    end

    def mysql
      unless app && mysql_instance && user && password
        error "Please specify the app name and database instance (ie. pagoda tunnel:mysql --app=googliebear --instance=santana)"
        return
      end
      display "Authenticating valid database"
      if client.database_exists?(app, mysql_instance)
        display "starting tunnel"
        display "Username and password can be found in your dashboard panel."
        display "ctrl-c to close tunnel."
        Pagoda::TunnelProxy.new("mysql", user, password, app, mysql_instance).start
      else
          error "invalid information:\neither the database or the app does not exist." 
      end
    end
    
  protected
  
    def mysql_instance
      option_value("-i", "--instance")
    end
    
  end
end