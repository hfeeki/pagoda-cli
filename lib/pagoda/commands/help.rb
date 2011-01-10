module Pagoda::Command
  class Help < Base
    def index
      display %{
        === Usage ===

        help                         # show this usage
        version                      # show the gem version

        NOTE: pagoda saves your credentials so you dont have to type your username
              and password in every time. to reset the credentials
              run: pagoda credentials:reset
  
        app:list                     # list your apps
        app:create <name>            # create (register) a new app
        app:init   <name>            # link current directory to be deployed as a created app
        app:info [<name>]            # display info about an app
        app:destroy [<name>]         # remove app
  
        deploy                       # deploy current directory app to production
        rollback                     # rollback app

      }
    end
  end
end