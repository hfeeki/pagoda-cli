require 'em-proxy'


module Pagoda::Command
  class Tunnel < Base
    
    
    def mysql
      puts "attempting to establish a connection with sql ctrl-c to exit"
      
      Proxy.start(:host => "0.0.0.0", :port => 3308, :debug => true) do |conn|
        proxy_server = conn.server :srv, :host => "localhost", :port => 3307

        # modify / process request stream
        conn.on_data do |data|
          data
        end

        # modify / process response stream
        conn.on_response do |server, resp|
          if resp == "auth"
            puts "authenticating."
            proxy_server.send_data "auth=#{@user}:#{@password}:#{@app}"
          end
          if resp =~ /databases=.*/
            proxy_server.send_data determine_db(resp)
          end
          if resp == "success"
            puts "success"
            prxy_server.proxy_incoming_to(conn, 4096)
          end
          resp
        end

        # termination logic
        conn.on_finish do |server, name|
          # terminate connection (in duplex mode, you can terminate when prod is done)
          unbind if server == :srv
        end
      end      
    end
    
    protected
    
    def determine_db(string)
      db_s = string.split('=').last.split(':')
      puts
      puts "You have more then one database for this application."
      puts "Please select 1 database from the list:"
      number = 0
      db_s.each do |db|
        number += 1
        puts "#{number}.  #{db}"
      end
      puts "what database number would you like to connect to? "
      db_number = gets.strip.to_i
      db_s[db_number - 1]
    end
    
  end
end