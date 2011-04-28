require 'crack'

module Pagoda
  module Helpers
    def home_directory
      running_on_windows? ? ENV['USERPROFILE'] : ENV['HOME']
    end

    def running_on_windows?
      RUBY_PLATFORM =~ /mswin32|mingw32/
    end

    def running_on_a_mac?
      RUBY_PLATFORM =~ /-darwin\d/
    end

    def display(msg="", newline=true)
      if newline
        puts(msg)
      else
        print(msg)
        STDOUT.flush
      end
    end
    
    
    def option_value(short_hand = nil, long_hand = nil)
      match = false
      value = nil
      
      if short_hand
        if args.include?(short_hand)
          value = args[args.index(short_hand) + 1]
          match = true
        end
      end
      if long_hand && !match
        if match = args.grep(/#{long_hand}=.*/).first
          value = match.split("=").last
        end
      end
      
      value
    end

    def format_date(date)
      date = Time.parse(date) if date.is_a?(String)
      date.strftime("%Y-%m-%d %H:%M %Z")
    end

    def ask(message=nil)
      display message, false if message
      gets.strip
    end
    
    def confirm(message="Are you sure you wish to continue? (y/n)?")
      display("#{message} ", false)
      ask.downcase == 'y'
    end

    def error(msg)
      STDERR.puts
      STDERR.puts("** Error: #{msg}")
      STDERR.puts
      exit 1
    end
    
    def loop_transaction(transaction, app_name=nil)
      app_name ||= app
      finished = false
      until finished
        display ".", false
        sleep 1
        updated = client.transaction_status(app_name, transaction[:id])
        case updated[:state]
        when /.*aborted$/
          display
          display updated[:status]
          exit
        when 'complete'
          display
          finished = true
        end
      end
    end
    
  end
end

unless String.method_defined?(:shellescape)
  class String
    def shellescape
      empty? ? "''" : gsub(/([^A-Za-z0-9_\-.,:\/@\n])/n, '\\\\\\1').gsub(/\n/, "'\n'")
    end
  end
end