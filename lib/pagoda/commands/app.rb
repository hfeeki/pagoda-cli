module Pagoda::Command
  class App < Base
    def list
      list = pagoda.list
      if list.size > 0
        display "=== Your Apps ==="
        display list.join("\n")
      else
        display "You have no apps."
      end
    end
    
    # 
    # create will register a new application with pagoda
    # It won't actually sync your app with the newly registered
    # Pagoda instance, you will then need to init your app
    #
    def create
      if args.length > 0
        attrs = pagoda.create(args.first)
        display "=== #{attrs[:name]} ==="
        display "IP:    #{attrs[:ip]}"
        display "\n"
        display "From #{attrs[:name]}'s root directory, run: pagoda init #{attrs[:name]}"
      else
        error "Please specify an app name: pagoda create appname" unless args.length > 0
      end
    end
    
    # 
    # Initting your app will setup your local app to
    # be deployable on the PagodaGrid
    # 
    # Before initting your app, your app must be registered.
    # You can register on the website, or via pagoda create 'yourapp'
    # assuming you are already have an account and in good standing
    # 
    def init
      
    end
    
    def info
      name = (args.first && !args.first =~ /^\-\-/) ? args.first : extract_app
      attrs = pagoda.info(name)
      display "=== #{attrs[:name]} ==="
      display "IP:           #{attrs[:ip]}"
      display "Instances:    #{attrs[:instances]}"
      display "Created At:   #{attrs[:created_at]}"
      display "\n"
      display "== Owner =="
      display "Username:     #{attrs[:owner][:username]}"
      display "Email:        #{attrs[:owner][:email]}"
      display "\n"
      display "== Collaborators =="
      attrs[:collaborators].each do |c|
        display "#{c[:username]} -> #{c[:email]}"
      end
    end
  end
end