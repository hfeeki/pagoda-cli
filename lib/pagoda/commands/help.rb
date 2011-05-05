module Pagoda::Command
  class Help < Base
    def index
      display %{
Pagoda

NAME
     pagoda -- work flow utility for pagodabox.com

SYNOPSIS
     pagoda [command] [-a -b -c -f -i -u -p]

DESCRIPTION
     
     If no operands are given, we will attempt to pull data from the current
     directory.  If more than one operand is given, non-directory operands are
     displayed first.

     The following options are available:
     
PARAMETERS
     
     -a <name>             --app=<name>  application name
     
     -b <branch>      --branch=<branch>  specify the branch name
     
     -c <commit>      --commit=<commit>  specify the commit id
     
     -i <instance> --instance=<instance> specify the instance you want to 
                                         operate on used for database instance
                                         
     -f                                  force instead of confirmation
     
     --latest                            used to deploy latest code
                                         
     -u <username> --username=<username> specify username
     
     -p <password> --password=<password> specify password

COMMANDS

    app:list                     # list your apps
    app:deploy                   # Deploy your current state to pagoda
    app:launch <name>            # create (register) a new app
    app:info                     # display info about an app
    app:destroy                  # remove app
    app:rollback                 # rollback app
    tunnel:mysql                 # create a tunnel to your database on pagoda


EXAMPLES
     launch an application on pagoda from inside the clone folder:
        (must be done inside your repo folder)

            pagoda app:launch <app name>

     list your applications:

            pagoda app:list

     create tunnel to your database:
        (must be inside your repo folder or specify app)

            pagoda tunnel:mysql -a <app name> -i <database name>
            
     destroy an application:
        (must be inside your repo folder or specify app)
      
            pagoda app:destroy 

        
      }
    end
  end
end