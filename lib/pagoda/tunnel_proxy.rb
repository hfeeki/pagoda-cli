require "socket"
require 'openssl'  

module Pagoda
  class TunnelProxy
    
    def initialize(type, user, pass, app, instance)
      @type     = type
      @user     = user
      @pass     = pass
      @app      = app
      @instance = instance 
    end
    
    def start
      local_port   = 3307
      remote_host = "www.pagodabox.com"
      remote_port = 3306

      max_threads     = 5
      threads         = []

      chunk           = 4096

      #puts "start TCP server"
      bound = false
      until bound
        begin
          proxy_server = TCPServer.new(nil, local_port)
          bound = true
        rescue Errno::EADDRINUSE
          local_port += 1
        end
      end
      
      puts "connection on localhost:#{local_port}"
      
      loop do

        #puts "start a new thread for every client connection"
        threads << Thread.new(proxy_server.accept) do |client_socket|

          begin
            #puts "client connection"
            begin
              server_socket         = TCPSocket.new(remote_host, remote_port)
              ssl_context           = OpenSSL::SSL::SSLContext.new()  
              ssl_socket            = OpenSSL::SSL::SSLSocket.new(server_socket, ssl_context)  
              ssl_socket.sync_close = true  
              ssl_socket.connect
            rescue Errno::ECONNREFUSED
              #puts "connection refused"
              client_socket.close
              raise
            end

            #puts "authenticte"
            if ssl_socket.readpartial(chunk) == "auth"
              #puts "authentication"
              ssl_socket.write "auth=#{@user}:#{@pass}:#{@app}:#{@instance}" 
              if ssl_socket.readpartial(chunk) == "success"
                #puts "successful connection"
              else
                #puts "failed connection"
              end
            else
              #puts "danger will robbinson! abort!"
            end

            loop do
              #puts "wait for data on either socket"
              (ready_sockets, dummy, dummy) = IO.select([client_socket, ssl_socket])

              #puts "full duplex connection until data stream ends"
              begin
                ready_sockets.each do |socket|
                  data = socket.readpartial(chunk)
                  if socket == client_socket
                    #puts "read from client and write to server"
                    ssl_socket.write data
                    ssl_socket.flush
                  else
                    #puts "read from server and write to client."
                    client_socket.write data
                    client_socket.flush
                  end
                end
              rescue EOFError
                break
              end
            end

          rescue StandardError => error
          end
          client_socket.close rescue StandardError
          ssl_socket.close rescue StandardError
        end

        #puts "clean up the dead threads, and wait until we have available threads"
        threads = threads.select { |thread| thread.alive? ? true : (thread.join; false) }
        while threads.size >= max_threads
          sleep 1
          threads = threads.select { |thread| thread.alive? ? true : (thread.join; false) }
        end
      end
    end
  
  end
end
