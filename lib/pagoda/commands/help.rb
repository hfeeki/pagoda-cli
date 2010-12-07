module Pagoda::Command
  class Help < Base
    def index
      display %{
  === Usage ===

  help                         # show this usage
  version                      # show the gem version

  app:list                     # list your apps
  app:create <name>            # create (register) a new app
  app:init   <name>            # link current directory to be deployed as a created app
  app:info [<name>]            # display info about an app
  app:destroy [<name>]         # remove app

  deploy                       # deploy current directory app to production
  deploy:production            # same as deploy
  deploy:staging               # deploy current directory app to staging url

  collaborators                # list collaborators
  collaborators:add <email>    # add a collaborator
  collaborators:remove <email> # remove a collaborator

  keys                         # show registered public keys
  keys:add [<path to keyfile>] # add a public key
  keys:remove <keyname>        # remove a key by name (user@host)
  keys:clear                   # remove all keys
  
      }
    end
  end
end