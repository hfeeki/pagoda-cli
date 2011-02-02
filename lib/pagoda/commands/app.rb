module Pagoda::Command
  class App < Base
    
    def list
      display
      display "=== apps ==="
      display
      apps = client.app_list
      if !apps.empty?
        apps.each do |app|
          display app[:name]
        end
      else
        display "looks like you don't have any apps yet"
        display "type 'pagoda create' to start"
      end
      display
    end
    
    def create      
      display
      clone_url = extract_git_clone_url
      name = ask "Please specify a name for this application, or hit enter to use '#{extract_possible_name}' : "
      name.chomp!
      name = extract_possible_name if name.empty?
      display "  +> Registering #{name}"
      app = client.app_create(name, clone_url)
      display "  +> Deploying...", false
      loop_transaction(app[:transactions][0], name)
      add_app(name, clone_url)
      display "  +> #{name} created and deployed"
      display
    end
    
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
      info[:collaborators].each do |collaborator|
        display "    username :  #{collaborator[:username]}"
        display "    email    :  #{collaborator[:email]}"
      end
      display
    end
    
    def deploy
      display
      transaction = client.deploy(app)
      display "  +> deploying...", false
      loop_transaction(transaction)
      display "  +> deployed"
      display
    end
    
    def rewind
      display
      transaction = client.rewind(app)
      display "  +> undo...", false
      loop_transaction(transaction)
      display "  +> done"
      display
    end
    alias :rollback :rewind
    alias :undo :rewind
    
    def fast_forward
      display
      transaction = client.fast_forward(app)
      display "  +> redo...", false
      loop_transaction(transaction)
      display "  +> done"
      display
    end
    alias :fastforward :fast_forward
    alias :forward :fast_forward
    alias :redo :fast_forward

    def scale_up
      display
      transaction = client.scale_up(app)
      display "  +> scaling up...", false
      loop_transaction(transaction)
      display "  +> done"
      display
    end
    
    def scale_down
      transaction = client.scale_down(app)
      display "  +> scaling down...", false
      loop_transaction(transaction)
      display "  +> done"
      display
    end
    
    def destroy
      display
      if confirm "Are you sure you want to remove #{app}? This cannot be undone! (y/n)"
        client.app_destroy(app)
        display "#{app} has been successfully destroyed."
        remove_app(app)
      end
      display
    end
    
  end
end
