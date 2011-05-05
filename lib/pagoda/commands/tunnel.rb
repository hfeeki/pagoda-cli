module Pagoda::Command
  class Tunnel < Auth

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