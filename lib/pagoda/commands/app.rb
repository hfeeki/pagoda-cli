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
    # Initing your app will setup your local app to
    # be deployable on the PagodaGrid
    # 
    # Before initing your app, your app must be registered.
    # You can register on the website, or via pagoda create 'yourapp'
    # assuming you are already have an account and in good standing
    # 
    def init
      if args.length > 0
        name = args.first
        if pagoda.list.include? name
          if confirm("Is this #{name}'s root directory? (y/n)")
            FileUtils.cd(Dir.pwd)
            init_app if !is_git?
            add_remote(name)
            display "#{name} is ready for deployment! # pagoda deploy"
          else
            error "Please change into #{name}'s root directory and try again."
          end
        else
          error "#{name} doesn't match any of the existing apps.\nYou must first create #{name} if it doesn't already exist. # pagoda create #{name}\nList all available apps # pagoda list"
        end
      else
        error "Please specify an app name: pagoda init appname"
      end
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
    
    def destroy
      app = extract_app
      if confirm "Are you sure you want to destroy #{app}? This cannot be undone! (y/n)"
        pagoda.destroy(app)
        display("#{app} permanently destroyed.")
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