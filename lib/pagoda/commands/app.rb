module Pagoda::Command
  class App < Base
    
    # internal use only
    def list
      info = parse pagoda.user_info
      display "=== #{info['user']['username']} Applications ==="
      
      if apps = parse(pagoda.app_list)
        apps['apps'].each do |app|
          display "name: #{app['name']}"
          # display " - ID: #{app['id']}"
          # display " - IP: #{app['ip_address']}"
        end
      else
        display "#{info['user']['username']} has not created any applications yet."
        display "Use 'pagoda app:create' to create one."
      end
    end
    
    def create      
        display "=== Create App ==="
        app = {}
        app[:name] = ask "Application Name: "
        app[:git_url] = ask "Application git clone URL: "
        
        pagoda.app_create(app)
        
        display "Application #{app[:name]} successfully create at http://#{app[:name]}.pagodabox.com!"
        display "Use 'pagoda app.list' to view a list of all your applications"
        display "or use 'pagoda app.info --[name]' to view an applications information."
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
    
    
    protected

    def is_git?
      File.exists?(".git") && File.directory?(".git")
    end
    
  end
end