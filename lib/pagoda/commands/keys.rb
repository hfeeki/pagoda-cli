module Pagoda::Command
  class Keys < Base
    
    def list
      long = args.any? { |a| a == '--long' }
      keys = parse pagoda.keys
      if keys['keys']
        display "=== Keys ==="
        keys['keys'].each do |key|
          display "ID: #{key['id']}"
          display "Title: #{key['title']}"
          display "Email: #{key['email']}"
        end
      else
        display "No keys found."
      end
    end
    alias :index :list

    def add
      keyfile = args.first || find_key
      key = File.read(keyfile)
      display "Uploading ssh public key #{keyfile}"
      display pagoda.add_key(key)
    end

    def remove
      pagoda.remove_key(args.first)
      display "Key #{args.first} removed."
    end

    def clear
      pagoda.remove_all_keys
      display "All keys removed."
    end

    protected
      def find_key
        %w(rsa dsa).each do |key_type|
          keyfile = "#{home_directory}/.ssh/id_#{key_type}.pub"
          return keyfile if File.exists? keyfile
        end
        raise CommandFailed, "No ssh public key found in #{home_directory}/.ssh/id_[rd]sa.pub.  You may want to specify the full path to the keyfile."
      end

      def format_key_for_display(key)
        type, hex, local = key.strip.split(/\s/)
        [type, hex[0,10] + '...' + hex[-10,10], local].join(' ')
      end
  end
end