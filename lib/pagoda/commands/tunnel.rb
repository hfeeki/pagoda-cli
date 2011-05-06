module Pagoda::Command
  class Tunnel < Auth

    def index
      app
      type = option_value("-t", "--type") || 'mysql'
      Pagoda::Command.run_internal("tunnel:#{type}", args)
    end

    def mysql
      instance_name = option_value("-n", "--name")
      unless instance_name
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
      display
      display "+> Authenticating Database Ownership"
      
      if client.database_exists?(app, instance_name)
        Pagoda::TunnelProxy.new(:mysql, user, password, app, instance_name).start
      else
        errors = []
        errors << "Security exception -"
        errors << "Either the MySQL instance doesn't exist or you are unauthorized"
        error errors
      end
    end
  end
end