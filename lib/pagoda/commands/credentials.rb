module Pagoda::Command
  class Credentials < Base
    
    def reset
      if confirm
        FileUtils.rm_f("#{home_directory}/.pagoda/credentials")
        display "Your credentials have been reset"
      end
    end
   
   def change_user
    get_credentials
   end
    
  end
end