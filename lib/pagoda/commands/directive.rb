module Pagoda::Command
  class Directive < Base
    
    def list
      app = NAME # extract_app
      
      directives = parse pagoda.app_get_directives(app)
      if directives['access_directives']
        display "=== Access Directives for #{app} ==="
        directives['access_directives'].each do |directive|
          display "== Directive =="
          display "ID:          #{directive['id']}"
          display "Directory:   #{directive['directory']}"
          display "Who:         #{directive['who']}"
          display "Action:      #{directive['action']}"
          display "Position:    #{directive['position']}"
        end 
      else
        display "=== No Access Directives found for #{app} ==="
      end
    end
   
    def add
      app = NAME # extract_app
      
      display "=== Add Directive ==="
      directive = {}
      directive{:directory} = ask "Directory: "
      directive{:who} = ask "Who (IP): "
      directive{:action} =  ask "action (allow/deny): "
      directive{:position} =  ask"Priority: "
      
      pagoda.app_add_directive(app, directive)
      display "Directive added to #{app}"
    end
    
    def info
      app = NAME #extract_app
      
      if args.any?
        directives = parse pagoda.app_get_directive(app, (args.first))
        display "=== Access Directive ==="
        display "  ID:          #{directives['directive']['id']}"
        display "  Directory:   #{directives['directive']['directory']}"
        display "  Who:         #{directives['directive']['who']}"
        display "  Action:      #{directives['directive']['action']}"
        display "  Position:    #{directives['directive']['position']}"
      else
        display "Please specify a directive ID: pagoda directive:info id"
      end
    end
    
    def update
      app = NAME #extract_app
      
      display "=== Update Directive ==="
      id = ask "Application ID: "
      updates = {}
      updates[:directory] = ask "Directory: "
      updates[:who] = ask "Who (IP): "
      updates[:action] =  ask "action (allow/deny): "
      updates[:position] =  ask "Priority: "
      
      pagoda.app_update_directive(app, id, hash)
      display "Directive successfully updated!"
    end
    
    def remove
      app = NAME #extract_app
      if args.any?
        pagoda.app_remove_directive(app, (args.first))
      else
        display "Please specify a directive ID: pagoda directive:remove id"
      end
    end
    
  end
end
