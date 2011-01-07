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
        app = {}
        
        display "=== Create App ==="
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
      display "=== #{app['app']['name']} ==="
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
          display "#{collaborator}"
        end
        display "\n"
      end
    end
    
    def update
      app = NAME #extract_app
      
      updates = {}
      case update_display
        when '1'
          updates[:name] = ask "Desired Name: "
        when '2'
          updates[:git_url] = ask "Git Clone URL: "
        when '3'
          updates[:php_version] = ask "PHP Version: "
        when '4'
          gzip = ask "GZip Compression Enabled (y/n): "
          updates[:enable_gzip] = true if gzip == 'y'
          updates[:enable_gzip] = false if gzip == 'n'
          display "Incorrect format. Update failed." if gzip != 'y' || gzip != 'n'
        when '5'
          ffe = ask "Far Future Expires Enabled (y/n): "
          updates[:far_future_expires_enabled] = true if ffe == 'y'
          updates[:far_future_expires_enabled] = false if ffe == 'n'
          display "Incorrect format. Update failed." if ffe != 'y' || ffe != 'n'
        when '6'
          etag = ask "ETags Enabled (y/n): "
          updates[:etag_enabled] = true if etag == 'y'
          updates[:etag_enabled] = false if etag == 'n'
          display "Incorrect format. Update failed." if etag != 'y' || etag != 'n'
        when '7'
          updates[:ssl_crt] = ask "ssl_crt: "
      end
      
      if confirm("Are you done making changes? (y/n)")
        if confirm "Are you sure you would like to apply these updates? (y/n)"
          display "Updating..."
          pagoda.app_update(app, updated)
          display "#{app} has been updated!"
        end
      else
        update_display
      end
    end
    
    def destroy
      app = NAME #extract_app
      if confirm "Are you sure you want to remove #{app}? This cannot be undone! (y/n)"
        pagoda.app_destroy(app)
        display "#{app} has been successfully removed."
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
        name = get_app_name
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
    
    def generate_csr
      app = NAME #extract_app
      hash = {}
      display "=== Create SSL CSR ==="
      display "Please insert necessary fields"
      display ""
      print "country: "
      hash[:country] = ask
      print "state: "
      hash[:state] = ask
      print "city: "
      hash[:city] = ask
      print "organization: "
      hash[:organization] = ask
      print "department: "
      hash[:department] = ask
      print "common name: "
      hash[:common_name] = ask
      print "email: "
      hash[:email] = ask
      rtn = parse pagoda.app_generate_csr(app, hash)
      display "#{rtn['app']['ssl_csr']}"
    end
    
    def get_csr
      app = NAME #extract_app
      rtn = parse pagoda.app_get_csr(app)
      display "#{rtn['csr']}"
    end
    
    def set_crt
      app = NAME #extract_app
      if args.length > 0
        filename = args.first
        file = File.open("#{filename}", "rb")
        content = file.read
        pagoda.app_add_crt(app, content)
      else
        display "Missing filename. pagoda app:set_crt filename.txt"
      end
    end
    
    def get_crt
      app = NAME #extract_app
      rtn = parse pagoda.app_get_crt(app)
      display "#{rtn['crt']}"
    end
    
    def card_info
      app = NAME #extract_app
      card = parse pagoda.app_credit_card_info(app)
      attrs = card['credit_card']
      display "=== card associated with #{app} ==="
      display "ID:         #{attrs['id']}"
      display "last four:  #{attrs['last_four']}"
    end
    
    def add_card
      app = NAME #extract_app
      print "Enter credit card number: "
      number = ask
      valid = false
      until valid
        print "Expiration date YYYY-MM: "
        expiration = ask
        if expiration  =~ /\d{4}\-\d{2}/
          valid = true
        end
        if valid == false
          display "invalid expiration format"
        end
      end
      print "CVV number: "
      cvv = ask
      card = {:number => number, :expiration => expiration, :code => cvv}
      pagoda.app_add_card(app, card)
      display "card added to #{app}"
      display "card number: #{number}"
      display "expiration : #{expiration}"
    end
    
    protected

    def update_display
      ask %{
        What would you like to update?
        1:name
        2:git_url
        3:php_version
        4:enable_gzip
        5:far_future_expires_enabled
        6:etag_enabled
        7:ssl_cert
       :}
    end
    
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