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
      # display "--> detected git clone url"
      # display "--> determining app name"
      name = ask "please specify a name for this application, or hit enter to use '#{extract_possible_name}' :"
      name.chomp!
      name = extract_possible_name if name.empty?
      display "--> registering #{name}"
      app = client.app_create(name, clone_url)
      display "--> deploying...", false
      deployed = false
      transaction = app[:transactions][0][:id]
      until deployed
        display ".", false
        sleep 1
        updated = client.transaction_status(name, transaction)
        case updated[:state]
        when /.*paused$/
          # handle paused logic
        when 'complete'
          display
          deployed = true
        end
      end
      add_app(name, clone_url)
      display "--> app created and deployed"
    end
    
    def info
      info = client.app_info(app)
      puts info
    end
    
    def destroy
      if confirm "Are you sure you want to remove #{app}? This cannot be undone! (y/n)"
        client.app_destroy(app)
        remove_app(app)
        display "#{app} has been successfully destroyed."
      end
    end
    
  end
end