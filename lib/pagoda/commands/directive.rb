module Pagoda::Command
  class Directive < Base
   
    def add
      app = NAME #extract_app
      display "=== Add Directive ==="
      hash = {}
      print "Directory: "
      hash[:directory] = ask
      print "Who (IP): "
      hash[:who] = ask
      print "action (allow/deny): "
      hash[:action] =  ask
      print "Priority: "
      hash[:position] =  ask
      pagoda.app_add_directive(app, hash)
      display "Directive added to application"
    end
    
    def update
      app = NAME #extract_app
      display "=== Update Directive ==="
      hash = {}
      print "ID to be modified: "
      id = ask
      print "Directory: "
      hash[:directory] = ask
      print "Who (IP): "
      hash[:who] = ask
      print "action (allow/deny): "
      hash[:action] =  ask
      print "Priority: "
      hash[:position] =  ask
      pagoda.app_update_directive(app, id, hash)
      display "Update applied."
    end
    
    def list
      app = NAME #extract_app
      rtn = parse pagoda.app_get_directives(app)
      if rtn['access_directives']
        arr = rtn['access_directives']
        display "=== Access Directives for #{app} ==="
        arr.each do |directive|
          display "== Directive =="
          display "  ID:        #{directive['id']}"
          display "  Directory: #{directive['directory']}"
          display "  Who:       #{directive['who']}"
          display "  Action:    #{directive['action']}"
          display "  Position:  #{directive['position']}"
        end 
      else
        display "=== No URL Rewrites for #{app} ==="
      end
    end
    
    def info
      app = NAME #extract_app
      if args.length > 0
        rtn = parse pagoda.app_get_directive(app, (args.first))
        directive = rtn['directive']
        display "=== Access Directive ==="
        display "  ID:        #{directive['id']}"
        display "  Directory: #{directive['directory']}"
        display "  Who:       #{directive['who']}"
        display "  Action:    #{directive['action']}"
        display "  Position:  #{directive['position']}"
      else
        display "Please specify a directive ID: pagoda directive:info id"
      end
    end
    
    def remove
      app = NAME #extract_app
      if args.length > 0
        pagoda.app_remove_directive(app, (args.first))
      else
        display "Please specify a directive ID: pagoda directive:remove id"
      end
    end
    
  end
end
