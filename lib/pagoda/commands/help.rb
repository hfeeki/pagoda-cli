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
  user:info                    # show current user details
  user:reset                   # reset the password on the account to 'password'
  user:forgot                  # send an email with instructions to reset the password
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
  rollback                     # rollback app

  == Collaborators functions ==
  collaborators                # list collaborators
  collaborators:add <email>    # add a collaborator
  collaborators:remove <email> # remove a collaborator

  
      }
    end
  end
end