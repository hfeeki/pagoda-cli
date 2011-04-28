require "socket"
require 'openssl'  

module Pagoda
  module Service
    class Tunnel
      
      def initialize(type, user, pass, app, instance)
        @type     = type
        @user     = user
        @pass     = pass
        @app      = app
        @instance = instance 
      end
      
      def start
        puts "HAY YO IT WORKED"
        return

        upstream_port   = 3307
        downstream_host = "127.0.0.1"
        downstream_port = 3306

        max_threads     = 5
        threads         = []

        chunk           = 4096

        #puts "start TCP server"
        proxy_server = TCPServer.new(nil, upstream_port)

        loop do

          #puts "start a new thread for every client connection"
          threads << Thread.new(proxy_server.accept) do |client_socket|

            begin
              #puts "client connection"
              begin
                puts "create ssl socket"
                server_socket         = TCPSocket.new(downstream_host, downstream_port)
                ssl_context           = OpenSSL::SSL::SSLContext.new()  
                ssl_socket            = OpenSSL::SSL::SSLSocket.new(server_socket, ssl_context)  
                ssl_socket.sync_close = true  
                ssl_socket.connect
                puts "connect socket"
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
              puts "#{Thread.current} got an exception: #{error.inspect}"
            end

            puts "#{Thread.current} closing connection"
            client_socket.close rescue StandardError
            ssl_socket.close rescue StandardError
          end

          #puts "clean up the dead threads, and wait until we have available threads"
          puts "#{threads.size} threads running...\n"
          threads = threads.select { |thread| thread.alive? ? true : (thread.join; false) }
          while threads.size >= max_threads
            sleep 1
            threads = threads.select { |thread| thread.alive? ? true : (thread.join; false) }
          end
        end
      end
    
    end
  end
end
