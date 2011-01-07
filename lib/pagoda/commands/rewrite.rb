module Pagoda::Command
  class Rewrite < Base
    
    def list
      app = NAME # extract_app
      
      rewrites = parse pagoda.app_get_rewrites(app)
      if rewrites['url_rewrites']
        display "=== URL Rewrites for #{app} ==="
        rewrites['url_rewrites'].each do |rewrite|
          display "== URL Rewrite =="
          display "ID:   #{rewrite['id']}"
          display "To:   #{rewrite['to']}"
          display "From: #{rewrite['from']}"
        end 
      else
        display "=== No URL Rewrites for #{app} ==="
      end
    end
    
    def add
      app = NAME # extract_app
      
      display "=== Add Url Rewrite ==="
      rewrite           = {}
      rewrite[:to]      =  ask "To: "
      rewrite[:from]    =  ask "From: "
      
      parse pagoda.app_add_rewrite(app, hash)
      display "Rewrite successfully added to #{app}"
    end
    
    def info
      app = NAME # extract_app
      
      if args.any?
        rewrites = parse pagoda.app_get_rewrite(app, (args.first))
        display "=== URL Rewrite ==="
        display "ID:    #{rewrites['rewrite']['id']}"
        display "To:    #{rewrites['rewrite']['to']}"
        display "From:  #{rewrites['rewrite']['from']}"
      else
        display "Please specify a rewrite ID: pagoda rewrite:info id"
      end
    end
    
    def update
      app = NAME #extract_app
      
      display "=== Update Url Rewrite ==="
      id = ask "ID to be modified: "
      rewrite           = {}
      rewirte[:to]      =  ask "To: "
      rewirte[:from]    =  ask "From: "
      
      parse pagoda.app_update_rewrite(app, id, hash)
      display "Rewrite successfully updated"
    end
    
    def remove
      app = NAME #extract_app
      if args.length > 0
        pagoda.app_remove_rewrite(app, (args.first))
      else
        display "Please specify a rewrite ID: pagoda rewrite:remove id"
      end
    end
    
  end
end
