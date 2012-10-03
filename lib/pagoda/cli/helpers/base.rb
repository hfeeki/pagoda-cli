require 'pagoda-client'
require 'pagoda-api'

module Pagoda
  module Command

    class Base
      include Pagoda::Helpers

      class << self
        include Pagoda::Helpers
        def ask_for_credentials
          username = ask "Username: "
          display "Password: ", false
          password = running_on_windows? ? ask_for_password_on_windows : ask_for_password
          # api_key =  Pagoda::Client.new(user, password).api_key
          [username, password] # return
        end

        def ask_for_password
          echo_off
          password = ask
          puts
          echo_on
          return password
        end

        def ask_for_password_on_windows
          require "Win32API"
          char = nil
          password = ''
          
          while char = Win32API.new("crtdll", "_getch", [ ], "L").Call do
            break if char == 10 || char == 13 # received carriage return or newline
            if char == 127 || char == 8 # backspace and delete
              password.slice!(-1, 1)
            else
              # windows might throw a -1 at us so make sure to handle RangeError
              (password << char.chr) rescue RangeError
            end
          end
          return password
        end

        def echo_off
          silently(system("stty -echo"))
        rescue
        end

        def echo_on
          silently(system("stty echo"))
        rescue
        end
                  
      end
      
      attr_reader :client
      attr_reader :globals
      attr_reader :options
      attr_reader :args

      def initialize(globals, options, args)
        @globals = globals
        @options = options
        @args = args
      end

      def user
        globals[:username]
      end

      def password
        globals[:password]
      end

      def client
        @client ||= Pagoda::Client.new(user, password)
      end

      def api
        @api ||= Pagoda::Api.new(user, password)
      end

      def is_family?(app_name)
        # Family = True, Component = False
        ((client.app_info(use_app)[:service_type] == :family) rescue true) # TODO: Remove the rescue for production
      end

      # protected
      
      def shell(cmd)
        FileUtils.cd(Dir.pwd) {|d| return `#{cmd}`}
      end
      
      def remote
        options[:remote] || "pagoda"
      end

      def app(soft_fail=true)
        if app = globals[:app] || options[:app]
          app
        elsif app = extract_app_from_git_config
          app
        elsif app = extract_app_from_remote
          app
        else
          if soft_fail
            display "I was unable to find your application name."
            ask "what is the name of your application? "
          else
            error "Unable to find the app. please specify using -a or --app="
          end
        end
      end
      
      def extract_app_from_git_config
        remote = git("config pagoda.id")
        if remote =~ /error: More than one value for the key pagoda.id/
          git("config --unset-all pagoda.id") 
          return nil
        end
        remote == "" ? nil : remote
      end

      def extract_app_from_remote
        remotes = git_remotes
        if remotes.length == 1
          remotes.values.first
        end
      end

      def git_remotes(base_dir=Dir.pwd)
        remotes = {}
        original_dir = Dir.pwd
        Dir.chdir(base_dir)
        git("remote -v").split("\n").each do |remote|
          name, url, method = remote.split(/\s/)
          if url =~ /^git@git.pagodabox.com:([\w\d-]+)\.git$/
            remotes[name] = $1
          end
        end
        Dir.chdir(original_dir)
        remotes
      end

      def branch
        options[:branch] || find_branch
      end
      
      def commit
        options[:commit] || find_commit
      end
      
      def find_branch
        if git("name-rev --refs=$(git symbolic-ref HEAD) --name-only HEAD") =~ /Could not get/
          error "Cannot find your branch"
        else
          git("name-rev --refs=$(git symbolic-ref HEAD) --name-only HEAD")
        end
      end

      def home_dir
        File.expand_path("~")
      end
      
      def find_commit
        if git("rev-parse --verify HEAD") =~ /Could not get/
          error "Cannot find your commit"
        else
          git("rev-parse --verify HEAD")
        end
      end
      
      def extract_git_clone_url(remote="pagoda")
        git("config remote.#{remote}.url")
      end
      
      def locate_app_root(dir=Dir.pwd)
        return dir if File.exists? "#{dir}/.git/config"
        parent = dir.split('/')[0..-2].join('/')
        return false if parent.empty?
        locate_app_root(parent)
      end

      def loop_transaction(app_name = nil)
        use_app = app_name || app
        family = is_family?(use_app)
        if family
          transaction_id = api.app_show(use_app)[:active_transaction_id]
        else
          transaction_id = client.app_info(use_app)[:active_transaction_id]
        end
        if transaction_id
          log_stream_length = 0
          display("",true,0)
          while true
            start = Time.now
            if family
              active = api.transaction_show(transaction_id)
            else
              active = client.transaction_info(use_app, transaction_id)
            end
            unless active[:log_stream].length == log_stream_length
              display( active[:log_stream][log_stream_length..-1].join("\n"),true,0)
              log_stream_length = active[:log_stream].length
            end
            break unless active[:state] == "incomplete"
            sleep(Time.now - start) if (Time.now - start) > 0
          end
        end
        display('',true,0)
        display( "Complete!",true,0)
        display('',true,0)
      end
    end

  end
end