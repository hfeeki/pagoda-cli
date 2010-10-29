module Pagoda::Command
  class Deploy < Base
    
    # 
    # Shortcut for git push pagoda master
    # 
    def production
      
    end
    alias :index :production
    
    # 
    # Shortcut for git push pagoda staging
    # 
    def staging
      
    end
    
  end
end