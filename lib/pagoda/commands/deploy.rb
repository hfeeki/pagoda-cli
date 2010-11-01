module Pagoda::Command
  class Deploy < Base
    
    # 
    # Shortcut for git push pagoda master
    # 
    def production
      shell "git push pagoda master"
    end
    alias :index :production
    
    # 
    # Shortcut for git push pagoda staging
    # 
    def staging
      shell "git push pagoda staging"
    end
    
  end
end