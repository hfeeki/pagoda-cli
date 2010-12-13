module Pagoda::Command
  class Rewrite < Base
    
    def add
      app = NAME #extract_app
      display "=== Add Url Rewrite ==="
      hash = {}
      print "To: "
      hash[:to] =  ask
      print "From: "
      hash[:from] =  ask
      parse pagoda.app_add_rewrite(app, hash)
      display "Rewrite added to appliation"
    end
    
    def update
      app = NAME #extract_app
      display "=== Update Url Rewrite ==="
      hash = {}
      print "ID to be modified: "
      id = ask
      print "To: "
      hash[:to] =  ask
      print "From: "
      hash[:from] =  ask
      parse pagoda.app_update_rewrite(app, id, hash)
      display "Update applied."
    end
    
    def list
      app = NAME #extract_app
      rtn = parse pagoda.app_get_rewrites(app)
      if rtn['url_rewrites']
        arr = rtn['url_rewrites']
        display "=== URL Rewrites for #{app} ==="
        arr.each do |rewrite|
          display "== Rewrite =="
          display "  ID:   #{rewrite['id']}"
          display "  To:   #{rewrite['to']}"
          display "  From: #{rewrite['from']}"
        end 
      else
        display "=== No URL Rewrites for #{app} ==="
      end
    end
    
    def info
      app = NAME #extract_app
      if args.length > 0
        rtn = parse pagoda.app_get_rewrite(app, (args.first))
        rewrite = rtn['rewrite']
        display "=== URL Rewrite ==="
        display "ID:   #{rewrite['id']}"
        display "To:   #{rewrite['to']}"
        display "From: #{rewrite['from']}"
      else
        display "Please specify a rewrite ID: pagoda rewrite:info id"
      end
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
