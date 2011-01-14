module Pagoda::Command
  class App < Base
    
    def list
      display
      display "=== apps ==="
      display
      apps = client.app_list
      if !apps.empty?
        apps.each do |app|
          display app.name
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
      display "--> detected git clone url"
      # display "--> determining app name"
      name = ask "please specify a name for this application, or hit enter to use '#{extract_possible_name}' :"
      if name.length > 1
        
      else
        
      end
      name = extract_possible_name unless name.length > 1
      display "--> registering #{name}"
      
    end
    
    def info
      name = (args.first && !args.first =~ /^\-\-/) ? args.first : extract_app
      
      app = parse pagoda.app_info(name)
      display "=== Application Information: #{app['app']['name']} ==="
      display "ID:             #{app['app']['id']}"
      display "IP:             #{app['app']['ip']}"
      display "git url:        #{app['app']['git_url']}"
      display "php version:    #{app['app']['php_version']}"
      display "enable gzip:    #{app['app']['enable_gzip']}"
      display "far future:     #{app['app']['far_future_expires_enabled']}"
      display "etag enabled:   #{app['app']['etag_enabled']}"
      display "\n"
      if app['app']['owner']
        display "== Owner =="
        display "Username:     #{app['app']['owner']['username']}"
        display "Email:        #{app['app']['owner']['email']}"
        display "\n"
      end
      if app['app']['credit_card']
        display "== Card =="
        display "ID:           #{app['app']['credit_card']['id']}"
        display "Last four:    #{app['app']['credit_card']['last_four']}"
        display "\n"
      end
      if app['app']['collaborators']
        display "== Collaborators =="
        app['app']['collaborators']['collaborator'].each do |collaborator|
          display "#{collaborator['username']}"
          display "#{collaborator['email']}"
        end
        display "\n"
      end
    end
    
    def destroy
      app = NAME # extract_app
      if confirm "Are you sure you want to remove #{app}? This cannot be undone! (y/n)"
        pagoda.app_destroy(app)
        display "#{app} has been successfully removed."
      end
    end
    
  end
end