module Pagoda::Command
  class Collaborators < BaseWithApp
    def list
      list = pagoda.list_collaborators(app)
      display list.map { |c| c[:email] }.join("\n")
    end
    alias :index :list

    def add
      email = args.shift.downcase rescue ''
      raise(CommandFailed, "Specify an email address to share the app with.") if email == ''
      display pagoda.add_collaborator(app, email)
    end

    def remove
      email = args.shift.downcase rescue ''
      raise(CommandFailed, "Specify an email address to remove from the app.") if email == ''
      pagoda.remove_collaborator(app, email)
      display "Collaborator removed."
    end
  end
end