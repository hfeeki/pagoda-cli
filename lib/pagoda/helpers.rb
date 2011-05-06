require 'crack'

module Pagoda
  module Helpers
    INDENT = "  "
    
    def home_directory
      running_on_windows? ? ENV['USERPROFILE'] : ENV['HOME']
    end

    def running_on_windows?
      RUBY_PLATFORM =~ /mswin32|mingw32/
    end

    def running_on_a_mac?
      RUBY_PLATFORM =~ /-darwin\d/
    end

    def display(msg="", newline=true, level=1)
      indent = build_indent(level)
      if newline
        puts("#{indent}#{msg}")
      else
        print("#{indent}#{msg}")
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
        if match = args.grep(/#{long_hand}.*/).first
          if match.include? "="
            value = match.split("=").last
          else
            value = true
          end
        end
      end
      
      value
    end

    def format_date(date)
      date = Time.parse(date) if date.is_a?(String)
      date.strftime("%Y-%m-%d %H:%M %Z")
    end

    def ask(message=nil, level=1)
      display("#{message}", false, level) if message
      gets.strip
    end
    
    def confirm(message="Are you sure you wish to continue? (y/n)?", level=1)
      return true if args.include? "-f"
      case message
      when Array
        count = message.length
        iteration = 0
        message.each do |m|
          if iteration == count - 1
            display("#{m} ", false, level)
          else
            display("#{m} ", true, level)
          end
          iteration += 1
        end
      when String
        display("#{message} ", false, level)
      end
      ask.downcase == 'y'
    end

    def error(msg, exit=true, level=1)
      indent = build_indent(level)
      STDERR.puts
      case msg
      when Array
        STDERR.puts("#{indent}** Error:")
        msg.each do |m|
          STDERR.puts("#{indent}** #{m}")
        end
      when String
        STDERR.puts("#{indent}** Error: #{msg}")
      end
      STDERR.puts
      exit 1 if exit
    end
    
    def loop_transaction(app_name = nil)
      finished = false
      until finished
        display ".", false, 0
        sleep 1
        if client.app_info(app_name || app)[:transactions].count < 1
          finished = true
          display
        end
      end
    end
    
    def build_indent(level=1)
      indent = ""
      level.times do
        indent += INDENT
      end
      indent
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