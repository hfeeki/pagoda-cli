module Pagoda::Command
  class Collaborators < BaseWithApp
    
    def list
      app = NAME #extract_app
      display pagoda.list_collaborators(app)
      # list = pagoda.list_collaborators(app)
      # display list.map { |c| c[:email] }.join("\n")
    end
    alias :index :list

    def add
      app = name #extract_app
      email = args.shift.downcase rescue ''
      raise(CommandFailed, "Specify an email address to share the app with.") if email == ''
      display pagoda.add_collaborator(app, email)
    end

    def remove
      app = name #extract_app
      email = args.shift.downcase rescue ''
      raise(CommandFailed, "Specify an email address to remove from the app.") if email == ''
      pagoda.remove_collaborator(app, email)
      display "Collaborator removed."
    end
  end
end