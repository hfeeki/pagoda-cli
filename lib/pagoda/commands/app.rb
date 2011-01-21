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
      name = ask "please specify a name for this application, or hit enter to use '#{extract_possible_name}' :"
      name.chomp!
      name = extract_possible_name if name.empty?
      display "--> registering #{name}"
      app = client.app_create(name, clone_url)
      display "--> deploying...", false
      loop_transaction(app[:transactions][0][:id])
      add_app(name, clone_url)
      display "--> app created and deployed"
    end
    
    def info
      info = client.app_info(app)
      puts info
    end
    
    def deploy
      transaction = client.deploy(app)
      display "--> deploying...", false
      loop_transaction(transaction)
      display "--> deployed"
    end
    
    def rewind
      transaction = client.rewind(app)
      display "--> rewinding...", false
      loop_transaction(transaction)
      display "--> app rewound"
    end
    
    def fast_forward
      transaction = client.fast_forward(app)
      display "--> fast forwarding...", false
      loop_transaction(transaction)
      display "--> app fast forwarded"
    end
    
    def destroy
      if confirm "Are you sure you want to remove #{app}? This cannot be undone! (y/n)"
        client.app_destroy(app)
        display "#{app} has been successfully destroyed."
        remove_app(app)
      end
    end
    
  end
end