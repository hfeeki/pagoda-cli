module Pagoda::Command
  class Help < Base
    def index
      display %{
        === Usage ===
        
        help      shows help
      }
    end
  end
end