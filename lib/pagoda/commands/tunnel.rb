module Pagoda::Command
  class Tunnel < Auth
    

    def mysql
      unless app && mysql_instance && user && password
        error "Please specify the app name and database instance (ie. pagoda tunnel:mysql --app=googliebear --instance=santana)"
        return
      end
      Pagoda::Service::Tunnel.new("mysql", user, password, app, mysql_instance).start
    end
    
  protected
  
    def mysql_instance
      option_value("-i", "--instance")
    end
    
  end
end