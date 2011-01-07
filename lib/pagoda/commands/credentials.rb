module Pagoda::Command
  class Credentials < Base
    
    def reset
      if confirm
        Pagoda::Command.run_internal 'auth:delete_credentials', nil
        display "Your credentials have been reset"
      end
    end
    
  end
end