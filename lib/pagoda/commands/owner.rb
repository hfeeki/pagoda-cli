module Pagoda::Command
  class Owner < Base
    # pagoda owner lyon@delorum.com changes the owner of the current app to me.
    #
    def index
      app = "test" #extract_app
      email = args.shift.downcase rescue ''
      raise(CommandFailed, "Specify an email address to share the app with.") if email == ''
      display pagoda.transfer_owner(app, email)
    end
  end
end