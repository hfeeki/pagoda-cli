module Pagoda
  module Service
    class Tunnel
      
      def initialize(type, user, pass, app, instance)
        @type     = type
        @user     = user
        @pass     = pass
        @app      = app
        @instance = instance 
      end
      
      def start
        puts "HAY YO IT WORKED"
      end
    
    end
  end
end
