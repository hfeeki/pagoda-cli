module Pagoda::Command
  class App < Base
    
    def list
      display pagoda.app_list
      # list = pagoda.app_list
      # if list.size > 0
      #   display "=== Your Apps ==="
      #   display list.join("\n")
      # else
      #   display "You have no apps."
      # end
    end
    
    # 
    # create will register a new application with pagoda
    # It won't actually sync your app with the newly registered
    # Pagoda instance, you will then need to init your app
    #
    def create
      if args.length > 0
        display pagoda.app_create(args.first)
      #   attrs = pagoda.app_create(args.first)
      #   display "=== #{attrs[:name]} ==="
      #   display "IP:    #{attrs[:ip]}"
      #   display "\n"
      #   display "From #{attrs[:name]}'s root directory, run: pagoda init #{attrs[:name]}"
      else
        error "Please specify an app name: pagoda create appname" unless args.length > 0
      end
    end
    
    # 
    # Initing your app will setup your local app to
    # be deployable on the PagodaGrid
    # 
    # Before initing your app, your app must be registered.
    # You can register on the website, or via pagoda create 'yourapp'
    # assuming you are already have an account and in good standing
    # 
    def init
      if args.length > 0
        name = NAME # args.first
        if pagoda.app_list.include? name
          if confirm("Is this #{name}'s root directory? (y/n)")
            FileUtils.cd(Dir.pwd)
            init_app if !is_git?
            add_remote(name)
            display "#{name} is ready for deployment! # pagoda deploy"
          else
            error "Please change into #{name}'s root directory and try again."
          end
        else
          error "#{name} doesn't match any of the existing apps.\n
                You must first create #{name} if it doesn't already exist. # pagoda create #{name}\n
                List all available apps # pagoda list"
        end
      else
        error "Please specify an app name: pagoda init appname"
      end
    end
    
    def info
      name = NAME #(args.first && !args.first =~ /^\-\-/) ? args.first : extract_app
      display pagoda.app_info(name)
      # attrs = pagoda.app_info(name)
      # display "=== #{attrs[:name]} ==="
      # display "IP:           #{attrs[:ip]}"
      # display "Instances:    #{attrs[:instances]}"
      # display "Created At:   #{attrs[:created_at]}"
      # display "\n"
      # display "== Owner =="
      # display "Username:     #{attrs[:owner][:username]}"
      # display "Email:        #{attrs[:owner][:email]}"
      # display "\n"
      # display "== Collaborators =="
      # attrs[:collaborators].each do |c|
      #   display "#{c[:username]} -> #{c[:email]}"
      # end
    end
    
    def card_info
      app = NAME #extract_app
      display pagoda.app_credit_card_info(app)
      # attrs = pagoda.app_credit_card_info(app)
      # display "=== card associated with #{app}"
      # display "last four: #{attrs[:number]}"
    end
    
    def add_card
      app = NAME #extract_app
      display "Enter credit card number:"
      number = ask
      valid = false
      until valid
        display "Expiration date YYYY-MM:"
        expiration = ask
        if expiration  =~ /\d{4}\-\d{2}/
          valid = true
        end
        if valid == false
          display "invalid expiration format"
        end
      end
      display "CVV number:"
      cvv = ask
      card = {:number => number, :expiration => expiration, :code => cvv}
      pagoda.app_add_card(app, card)
      display "card added to #{app}"
      display "card number: #{number}"
      display "expiration : #{expiration}"
    end
    
    def destroy
      app = NAME #extract_app
      if confirm "Are you sure you want to destroy #{app}? This cannot be undone! (y/n)"
        pagoda.app_destroy(app)
        display "#{app} permanently destroyed."
      end
    end
    
    protected
    
    def is_git?
      File.exists?(".git") && File.directory?(".git")
    end
    
    def init_app
      shell "git init"
    end
    
    def add_remote(name)
      shell "git remote add pagoda git@git.pagodagrid.com:#{name}.git"
    end
    
  end
end