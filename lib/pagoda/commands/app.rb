module Pagoda::Command
  class App < Base
    
    def list
      apps = parse pagoda.app_list
      puts apps
      list = apps['apps']
        display "=== Your Apps ==="
        list.each do |app|
          display "name: #{app['name']}"
          display " - ID: #{app['id']}"
          display " - IP: #{app['ip_address']}"
        end
    end
    
    # 
    # create will register a new application with pagoda
    # It won't actually sync your app with the newly registered
    # Pagoda instance, you will then need to init your app
    #{:app => {:name => app}}
    def create
        display "=== Create App ==="
        print "app name: "
        hash = {}
        hash[:app] = {}
        hash[:app][:name] = ask
        print "git url: "
        hash[:app][:git_url] = ask
        puts hash
        puts pagoda.app_create(hash)
        display "== App Created =="
        display "address: #{hash[:app][:name]}.pagodagrid.com"
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
    
    def info
      name = (args.first && !args.first =~ /^\-\-/) ? args.first : extract_app
      app = parse pagoda.app_info(name)
      puts app
      attrs = app['app']
      display "=== #{attrs['name']} ==="
      display "ID:             #{attrs['id']}"
      display "IP:             #{attrs['ip']}"
      display "git url:        #{attrs['git_url']}"
      display "php version:    #{attrs['php_version']}"
      display "enable gzip:    #{attrs['enable_gzip']}"
      display "far future:     #{attrs['far_future_expires_enabled']}"
      display "etag enabled:   #{attrs['etag_enabled']}"
      display "\n"
      if attrs['owner']
        display "== Owner =="
        display "Username:     #{attrs['owner']['username']}"
        display "Email:        #{attrs['owner']['email']}"
        display "\n"
      end
      if attrs['credit_card']
        display "== Card =="
        display "ID:           #{attrs['credit_card']['id']}"
        display "Last four:    #{attrs['credit_card']['last_four']}"
        display "\n"
      end
      if attrs['collaborators']
        display "== Collaborators =="
        attrs['collaborators']['collaborator'].each do |c|
          display "#{c}"
        end
        display "\n"
      end
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
    
    def destroy
      app = NAME #extract_app
      if confirm "Are you sure you want to destroy #{app}? This cannot be undone! (y/n)"
        pagoda.app_destroy(app)
        display "#{app} permanently destroyed."
      end
    end
    
    def update
      app = NAME #extract_app
      updated = {}
      done = false
      until done
        update_display
        option = ask
        case option
        when '1'
          print "desired name: "
          updated[:name] = ask
        when '2'
          print "git_url: "
          updated[:git_url] = ask
        when '3'
          print "php_version: "
          updated[:php_version] = ask
        when '4'
          display "expects 'true' or 'false'"
          print "enable_gzip: "
          gzip = ask
          if gzip == 'true'
            updated[:enable_gzip] = true
          elsif gzip == 'false'
            updated[:enable_gzip] = false
          else
            display "unrecognized input"
            display "update not applied"
          end
        when '5'
          display "expects 'true' or 'false'"
          print "far_future_expires_enabled: "
          ffe = ask
          if ffe == 'true'
            updated[:far_future_expires_enabled] = true
          elsif ffe == 'false'
            updated[:far_future_expires_enabled] = false
          else
            display "unrecognized input"
            display "update not applied"
          end
        when '6'
          display "expects 'true' or 'false'"
          print "etag_enabled: "
          etag = ask
          if etag == 'true'
            updated[:etag_enabled] = true
          elsif etag == 'false'
            updated[:etag_enabled] = false
          else
            display "unrecognized input"
            display "update not applied"
          end
        when '7'
          print "ssl_crt: "
          updated[:ssl_crt] = ask
        end
        if confirm("Are you done making changes? (y/n)")
          done = true
        end
      end
      display "changes being made:"
      puts updated
      if confirm "Are you sure you would like to make all of these changes? (y/n)"
        pagoda.app_update(app, updated)
        display "updates applied to application: #{app}"
      end
    end
    
    protected

    def update_display
          print %{
   what attribute(s) would you like to upgrade?
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