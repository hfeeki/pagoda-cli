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

    def display(msg, newline=true)
      if newline
        puts(msg)
      else
        print(msg)
        STDOUT.flush
      end
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
      STDERR.puts(msg)
      exit 1
    end
    
    # parse all xml documents given back from the API
    # return:
    #   hash containing all values from the xml doc
    def parse(xml)
      Crack::XML.parse(xml)
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