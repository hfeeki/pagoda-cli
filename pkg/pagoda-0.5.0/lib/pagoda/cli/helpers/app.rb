module Pagoda
  module Command

    class App < Base

      def list
        apps = client.app_list
        unless apps.empty?
          display
          display "APPS"
          display "//////////////////////////////////"
          display
          apps.each do |app|
            display "- #{app[:name]}"
          end
        else
          error ["looks like you haven't launched any apps", "type 'pagoda create' to create this project on pagodabox"]
        end
        display
      end

      def info
        display
        info = client.app_info(app)
        error("What application are you looking for?") unless info.is_a?(Hash)
        display "INFO - #{info[:name]}"
        display "//////////////////////////////////"
        display "name        :  #{info[:name]}"
        display "clone url   :  git@pagodabox.com:#{info[:id]}.git"
        display
        display "owner"
        display "   username :  #{info[:owner][:username]}"
        display "   email    :  #{info[:owner][:email]}"
        display
        display "collaborators"
        info[:collaborators].each do |collab|
        display "   username :  #{collab[:username]}"
        display "   email    :  #{collab[:email]}"
        end
        display
        display "ssh_portal  :  #{info[:ssh] ? 'enabled' : 'disabled'}"
        display
      end

      def rename
        old_name = options[:old] || app
        new_name = options[:new] || args.first
        error "I need the new name" unless new_name
        error "New name and existiong name cannot be the same" if new_name == old_name
        client.app_update(old_name, {:name => new_name})
        display "Successfully changed name to #{new_name}"
      rescue
        error "Given name was either invalid or already in use"
      end

      def init
        id = client.app_info(args.first || app)[:id] rescue error("We could not find the application you were looking for")
        create_git_remote(id, remote)
      end

      def clone
        my_app = args.first || app
        id = client.app_info(my_app)[:id]
        display
        git "clone git@git.pagodabox.com:#{id}.git #{my_app}"
        Dir.chdir(my_app)
        git "config --add pagoda.id #{id}"
        Dir.chdir("..")
        display
        display "+> Repo has been added. Navigate to folder #{my_app}."
      rescue
        error "We were not able to access that app"
      end

      def create
        name = args.first || app
        if client.app_available?(name)
          id = client.app_create(name)[:id]
          display("Creating #{name}...", false)
          loop_transaction(name)
          d_remote = create_git_remote(id, remote)
          display "#{name} created"
          display "----------------------------------------------------"
          display
          display "LIVE URL    : http://#{name}.pagodabox.com"
          display "ADMIN PANEL : http://dashboard.pagodabox.com/apps/#{name}"
          display
          display "----------------------------------------------------"
          display
          display "+> Use 'git push #{d_remote} --all' to push your code live"
        else
          error "App name (#{name}) is already taken"
        end
      end

      def deploy
        display
        my_app = app
        if client.app_info(my_app)[:active_transaction_id] == nil
          begin
            client.app_deploy(my_app, branch, commit)
          rescue RestClient::Found => e
            # do nothing because we found it HURRAY!
          end
          display "+> deploying current branch and commit...", true
          loop_transaction
        else
          error "Your app is currently in transaction, Please try again later."          
        end
      end

      def rollback
        display
        client.app_rollback(app)
        display "+> undo..."
        loop_transaction
        display
      end

      def destroy
        display
        my_app = app
        dname = display_name(my_app) # Make the app name look better
        if options[:force]
          display "+> Destroying #{dname}"
          client.app_destroy(my_app)
          display "+> #{dname} has been successfully destroyed. RIP #{dname}."
          remove_app(my_app)
        else
          if confirm ["Are you totally completely sure you want to delete #{dname} forever and ever?", "THIS CANNOT BE UNDONE! (y/n)"]
            display
            display "+> Destroying #{dname}"
            client.app_destroy(my_app)
            display "+> #{dname} has been successfully destroyed. RIP #{dname}."
            remove_app(my_app)
          end
        end
        display
      end
      
    end
  end  
end