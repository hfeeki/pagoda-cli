module Pagoda::Command
  class Collaborators < Base
    
    def list
      app = NAME #extract_app
      
      display "=== #{app} Collaborators ==="]
      collaborators = parse pagoda.list_collaborators(app)
      collaborators['users'].each do |collaborator|
        # display "Username: #{collaborator['username']}"
        display "Email: #{collaborator['email']}"
      end
    end
    
    alias :index :list

    def add
      app = NAME #extract_app
      
      email = args.shift.downcase rescue ''
      raise(CommandFailed, "Specify an email address to share the app with.") if email == ''
      pagoda.add_collaborator(app, email)
      display "Collaborator added."
    end

    def remove
      app = NAME #extract_app
      
      email = args.shift.downcase rescue ''
      raise(CommandFailed, "Specify an email address to remove from the app.") if email == ''
      pagoda.remove_collaborator(app, email)
      display "Collaborator removed."
    end
  end
end