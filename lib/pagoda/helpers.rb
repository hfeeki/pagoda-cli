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
        (running_on_windows?) ? puts("#{indent}#{msg}") : puts("#{indent}#{msg}".green)
      else
        (running_on_windows?) ? print("#{indent}#{msg}") : print("#{indent}#{msg}".green)
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
            (running_on_windows?) ? display("#{m} ", false, level) : display("#{m} ".blue, false, level)
          else
            (running_on_windows?) ? display("#{m} ", false, level) : display("#{m} ".blue, true, level)
          end
          iteration += 1
        end
      when String
        (running_on_windows?) ? display("#{message} ", false, level) : display("#{message} ".blue, false, level)
      end
      ask.downcase == 'y'
    end

    def error(msg, exit=true, level=1)
      indent = build_indent(level)
      STDERR.puts
      case msg
      when Array
        (running_on_windows?) ? STDERR.puts("#{indent}** Error:") : STDERR.puts("#{indent}** Error:".red)
        msg.each do |m|
          (running_on_windows?) ? STDERR.puts("#{indent}** #{m}") : STDERR.puts("#{indent}** #{m}".red)
        end
      when String
        (running_on_windows?) ? STDERR.puts("#{indent}** Error:") : STDERR.puts("#{indent}** Error:".red)
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


class String

  #
  # Colors Hash
  #
  COLORS = {
    :black          => 0,
    :red            => 1,
    :green          => 2,
    :yellow         => 3,
    :blue           => 4,
    :magenta        => 5,
    :cyan           => 6,
    :white          => 7,
    :default        => 9,
    
    :light_black    => 10,
    :light_red      => 11,
    :light_green    => 12,
    :light_yellow   => 13,
    :light_blue     => 14,
    :light_magenta  => 15,
    :light_cyan     => 16,
    :light_white    => 17
  }

  #
  # Modes Hash
  #
  MODES = {
    :default        => 0, # Turn off all attributes
    #:bright        => 1, # Set bright mode
    :underline      => 4, # Set underline mode
    :blink          => 5, # Set blink mode
    :swap           => 7, # Exchange foreground and background colors
    :hide           => 8  # Hide text (foreground color would be the same as background)
  }
  
  protected
  
  #
  # Set color values in new string intance
  #
  def set_color_parameters( params )
    if (params.instance_of?(Hash))
      @color = params[:color]
      @background = params[:background]
      @mode = params[:mode]
      @uncolorized = params[:uncolorized]
      self
    else
      nil
    end
  end
  
  public

  #
  # Change color of string
  #
  # Examples:
  #
  #   puts "This is blue".colorize( :blue )
  #   puts "This is light blue".colorize( :light_blue )
  #   puts "This is also blue".colorize( :color => :blue )
  #   puts "This is light blue with red background".colorize( :color => :light_blue, :background => :red )
  #   puts "This is light blue with red background".colorize( :light_blue ).colorize( :background => :red )
  #   puts "This is blue text on red".blue.on_red
  #   puts "This is red on blue".colorize( :red ).on_blue
  #   puts "This is red on blue and underline".colorize( :red ).on_blue.underline
  #   puts "This is blue text on red".blue.on_red.blink
  #   puts "This is uncolorized".blue.on_red.uncolorize
  #
  def colorize( params )
    return self unless STDOUT.isatty
    
    begin
      require 'Win32/Console/ANSI' if RUBY_PLATFORM =~ /win32/
    rescue LoadError
      raise 'You must gem install win32console to use colorize on Windows'
    end
    
    color_parameters = {}

    if (params.instance_of?(Hash))
      color_parameters[:color] = COLORS[params[:color]]
      color_parameters[:background] = COLORS[params[:background]]
      color_parameters[:mode] = MODES[params[:mode]]
    elsif (params.instance_of?(Symbol))
      color_parameters[:color] = COLORS[params]
    end
    
    color_parameters[:color] ||= @color ||= COLORS[:default]
    color_parameters[:background] ||= @background ||= COLORS[:default]
    color_parameters[:mode] ||= @mode ||= MODES[:default]

    color_parameters[:uncolorized] ||= @uncolorized ||= self.dup
   
    # calculate bright mode
    color_parameters[:color] += 50 if color_parameters[:color] > 10

    color_parameters[:background] += 50 if color_parameters[:background] > 10

    "\033[#{color_parameters[:mode]};#{color_parameters[:color]+30};#{color_parameters[:background]+40}m#{color_parameters[:uncolorized]}\033[0m".set_color_parameters( color_parameters )
  end

  #
  # Return uncolorized string
  #
  def uncolorize
    @uncolorized || self
  end
  
  #
  # Return true if sting is colorized
  #
  def colorized?
    !defined?(@uncolorized).nil?
  end

  #
  # Make some color and on_color methods
  #
  COLORS.each_key do | key |
    next if key == :default

    define_method key do
      self.colorize( :color => key )
    end
    
    define_method "on_#{key}" do
      self.colorize( :background => key )
    end
  end

  #
  # Methods for modes
  #
  MODES.each_key do | key |
    next if key == :default
    
    define_method key do
      self.colorize( :mode => key )
    end
  end

  class << self
    
    #
    # Return array of available modes used by colorize method
    #
    def modes
      keys = []
      MODES.each_key do | key |
        keys << key
      end
      keys
    end

    #
    # Return array of available colors used by colorize method
    #
    def colors
      keys = []
      COLORS.each_key do | key |
        keys << key
      end
      keys
    end 

    #
    # Display color matrix with color names.
    #
    def color_matrix( txt = "[X]" )
      size = String.colors.length
      String.colors.each do | color |
        String.colors.each do | back |
         print txt.colorize( :color => color, :background => back )
        end
        puts " < #{color}"
      end
      String.colors.reverse.each_with_index do | back, index |
        puts "#{"|".rjust(txt.length)*(size-index)} < #{back}"
      end 
      ""
    end
  end
end