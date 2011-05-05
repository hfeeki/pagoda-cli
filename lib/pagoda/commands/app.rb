module Pagoda::Command
  class App < Base
    
    def list
      display
      apps = client.app_list
      if !apps.empty?
        display "=== apps ==="
        display
        apps.each do |app|
          display app[:name]
        end
      else
        display "looks like you don't have any apps yet"
        display "type 'pagoda launch' to start"
      end
      display
    end
    
    def create
      display
      clone_url = extract_git_clone_url
      unless name = app
        unless name = args.dup.shift
          error "Please Specify an app name ie. pagoda create awesomeapp"
        end
      end
      display "  +> Registering #{name}"
      app = client.app_create(name, clone_url)
      display "  +> Deploying...", false
      loop_transaction(name)
      add_app(name, clone_url)
      display "  +> #{name} created and deployed"
      display
    end
    alias :launch :create
    
    def destroy
      display
      if confirm "Are you sure you want to remove #{app}? This cannot be undone! (y/n)"
        client.app_destroy(app)
        display "#{app} has been successfully destroyed."
        remove_app(app)
      end
      display
    end
    alias :delete :destroy
    
    def info
      display
      info = client.app_info(app)
      display "  #{info[:name]} - info"
      display "  //////////////////////////////////"
      display "  name       :  #{info[:name]}"
      display "  clone_url  :  #{info[:git_url]}"
      display
      display "  owner"
      display "    username :  #{info[:owner][:username]}"
      display "    email    :  #{info[:owner][:email]}"
      display
      display "  collaborators"
      info[:collaborators].each_with_index do |collaborator, index|
        display "    username :  #{collaborator[:username]}"
        display "    email    :  #{collaborator[:email]}"
      end
      display
    end
    
    def sync
      display
      display "attempting to sync your folder with your application"
      display
      apps = client.app_list
      my_repo = extract_git_clone_url
      matching_apps = []
      apps.each do |app|
        if app[:git_url] == my_repo
          matching_apps.push app
        end
      end
      if matching_apps.count > 1
        unless name = app
          unless name = args.dup.shift
            display "You have more then one application that uses this repo"
            error "Please Specify an app name ie. pagoda sync #{matching_apps[0][:name]}"
          end
        end
        assign_app = nil
        matching_apps.each do |app|
          assign_app = app if app[:name] == name
        end
        add_sync_data_or_do_nothing assign_app
      elsif matching_apps.count == 1
        app = matching_apps.first
        add_sync_data_or_do_nothing app
      else
        error "you have no applications using this repo"
      end
    end
    
    def deploy
      display
      branch = parse_branch
      commit = parse_commit
      if branch && commit
        client.deploy(app, branch, commit)
        display "  +> deploying...", false
        loop_transaction
        display "  +> deployed"
        display
      else
        option_value(nil, "--latest")
      end
    end
    
    def rewind
      display
      transaction = client.rewind(app)
      display "  +> undo...", false
      loop_transaction
      display "  +> done"
      display
    end
    alias :rollback :rewind
    alias :undo :rewind
    
    def fast_forward
      display
      transaction = client.fast_forward(app)
      display "  +> redo...", false
      loop_transaction
      display "  +> done"
      display
    end
    alias :fastforward :fast_forward
    alias :forward :fast_forward
    alias :redo :fast_forward

    protected
    
    def add_sync_data_or_do_nothing(app)
      my_app_list = read_apps
      current_root = locate_app_root
      in_list = false
      my_app_list.each do |app_str|
        app_arr = app_str.split(" ")
        if app[:git_url] == app_arr[1] && app[:name] == app_arr[0] || app_arr[2] == current_root
          display "This clone is already in use by #{app_arr[0]}."
          display "try modifying ~/.pagoda/apps"
          in_list = true
        end
      end
      unless in_list
        puts "Application added"
        add_app app[:name]
      end
    end
    
    
  end
end
