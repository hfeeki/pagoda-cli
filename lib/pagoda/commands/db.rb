module Pagoda::Command
  class Help < Base

    def create
      app
      display
      client.app_database_create(app)
      display "+> creating a sql database on pagodabox...", false
      loop_transaction
      display "+> created"
      display
    end




  end
end