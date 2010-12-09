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

  == User functions ==
  user:create                  # create a new user
  user:list                    # list all users
  user:info                    # show current user details
  user:reset                   # reset the password on the account to 'password'
  user:forgot                  # send an email with a randomly generated password
  user:add_card                # add a credit card to your account
  user:list_card               # list all cards linked to your account
  user:delete_card <card.id>   # delete a credit card with an id number of card.id
  
  == App functions ==
  app:list                     # list your apps
  app:create <name>            # create (register) a new app
  app:init   <name>            # link current directory to be deployed as a created app
  app:info [<name>]            # display info about an app
  app:destroy [<name>]         # remove app
  app:add_card                 # add a credit card for the app to use
  app:card_info                # show the card information from the account
  owner <email>                # transfer ownership of the app to another user at <email>
  
  == Deploy functions ==
  deploy                       # deploy current directory app to production
  deploy:production            # same as deploy
  deploy:staging               # deploy current directory app to staging url

  == Collaborators functions ==
  collaborators                # list collaborators
  collaborators:add <email>    # add a collaborator
  collaborators:remove <email> # remove a collaborator

  == Keys functions ==
  keys                         # show registered public keys
  keys:add [<path to keyfile>] # add a public key
  keys:remove <keyname>        # remove a key by name (user@host)
  keys:clear                   # remove all keys
  
      }
    end
  end
end