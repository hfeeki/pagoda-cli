require 'iniparse'

module Pagoda
  module Command
    class Base
      include Pagoda::Helpers

      attr_accessor :args
      
      def initialize(args)
        @args = args
      end
      
      def client
        @client ||= Pagoda::Command.run_internal('auth:client', args)
      end

      def shell(cmd)
        FileUtils.cd(Dir.pwd) {|d| return `#{cmd}`}
      end
      
      def app(soft=false)
        if override = option_value("-a", "--app")
          return override
        else
          if name = find_app
            return name
          else
            if locate_app_root
              if extract_git_clone_url
                return false if soft
                error "Unable to determine app, please try again."
              else
                return false if soft
                errors = []
                errors << "It appears you are using git (fantastic)."
                errors << "However we only support git repos hosted with github."
                errors << "Please ensure your repo is hosted with github, and that the origin is set to that url."
                error errors
              end
            else
              return false if soft
              error "Unable to find git config in this directory or in any parent directory"
            end
          end
        end
      end
      
      def parse_branch
        option_value("-b", "--branch") || find_branch
      end
      
      def parse_commit
        option_value("-c", "--commit") || find_commit
      end
      
      def find_app
        read_apps.each do |line|
          app = line.split(" ")
          return app[0] if app[2] == locate_app_root
        end
        false
      end

      def find_branch
        begin
          line = File.new("#{locate_app_root}/.git/HEAD").gets
          line.strip.split(' ').last.split("/").last
        rescue
          nil
        end
      end
      
      def find_commit
        begin
          File.new("#{locate_app_root}/.git/refs/heads/#{parse_branch}").gets.strip
        rescue 
          nil
        end
      end
      
      def read_apps
        return [] if !File.exists?(apps_file)
        File.read(apps_file).split(/\n/).inject([]) {|apps, line| apps << line if line.include?("git@github.com"); apps}
      end
      
      def write_app(name, git_url=nil, app_root=nil)
        git_url = extract_git_clone_url unless git_url
        app_root = locate_app_root unless app_root
        FileUtils.mkdir_p(File.dirname(apps_file)) if !File.exists?(apps_file)
        current_apps = read_apps
        File.open(apps_file, 'w') do |file|
          current_apps.each do |app|
            file.puts app
          end
          file.puts "#{name} #{git_url} #{app_root}"
        end
        set_apps_file_permissions
      end
      alias :add_app :write_app
      
      def remove_app(name)
        current_apps = read_apps
        current_apps.delete_if do |app|
          app.split(" ")[0] == name
        end
        File.open(apps_file, 'w') do |file|
          current_apps.each do |app|
            file.puts app
          end
        end
      end
      
      def set_apps_file_permissions
        FileUtils.chmod 0700, File.dirname(apps_file)
        FileUtils.chmod 0600, apps_file
      end
      
      def apps_file
        "#{home_directory}/.pagoda/apps"
      end
      
      def extract_possible_name
        cleanup_name(extract_git_clone_url.split(":")[1].split("/")[1].split(".")[0])
      end
      
      def cleanup_name(name)
        name.gsub(/-/, '').gsub(/_/, '').gsub(/ /, '').downcase
      end
      
      def extract_git_clone_url(soft=false)
        begin
          url = IniParse.parse( File.read("#{locate_app_root}/.git/config") )['remote "origin"']["url"]
          raise unless url.match(/^git@github.com:.+\.git$/)
          url
        rescue Exception => e
          return false
        end
      end
      
      def version
        display Client.gem_version_string
      end

      def locate_app_root(dir=Dir.pwd)
        return dir if File.exists? "#{dir}/.git/config"
        parent = dir.split('/')[0..-2].join('/')
        return false if parent.empty?
        locate_app_root(parent)
      end

      def extract_option(options, default=true)
        values = options.is_a?(Array) ? options : [options]
        return unless opt_index = args.select { |a| values.include? a }.first
        opt_position = args.index(opt_index) + 1
        if args.size > opt_position && opt_value = args[opt_position]
          if opt_value.include?('--')
            opt_value = nil
          else
            args.delete_at(opt_position)
          end
        end
        opt_value ||= default
        args.delete(opt_index)
        block_given? ? yield(opt_value) : opt_value
      end
    end
  end
end