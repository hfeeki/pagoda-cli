module Pagoda::Command
  class User < Base
    
    #internal only
    def list
      users = parse pagoda.user_list
      if users['users']
        display "=== Users ==="
        users['users'].each do |user|
          display "#{user['username']}"
        end
      else
        display "Oh Noes, Pagoda found no users in the system!"
      end
    end
    
    def create
      display "Enter a username, password, and email to create a new user."
      Pagoda::Command.run_internal 'auth:reauthorize', nil
      pagoda.user_create(ask "email: ")
      
      user = parse pagoda.user_info
      display "User #{user['user']['username']} successfully created"
    end
    
    def whoami?
      info = parse pagoda.user_info
      if info['user']
        display "=== Current User ==="
        display "You are: #{info['user']['username']}"
        display "For more information use 'pagoda user:info'"
      else
        display "Oops, for some reason you aren't set as a user."
        display "Use 'pagoda user:switch' to designate your user"
        display "or use 'pagoda user:create' to create yourself a user."
      end
    end
    
    def switch
      Pagoda::Command.run_internal 'auth:delete_credentials', nil
      Pagoda::Command.run_internal 'auth:get_credentials', nil
      display "You have switched users"
    end
    
    def info
      info = parse pagoda.user_info
      if info['user']
        display "=== User Information ==="
        display "Username:  #{info['user']['username']}"
        display "Password:  #{info['user']['password']}"
        display "Email:     #{info['user']['email']}"
      else
        display "Oops, looks like you aren't a user just yet!"
        display "Using 'pagoda user:create' will help."
      end
    end
    
    def update
      updates = {}
      
      display "=== Update User Information ==="
      updates[:username]   = ask "New username: " if confirm "Update username (y/n)?"
      updates[:password]   = ask "New password: " if confirm "Update password (y/n)?"
      updates[:email]      = ask "New email: " if confirm "Update email (y/n)?"
        
      pagoda.user_update(updates)
    end
    
    def reset
      pagoda.reset_password("password")
      display "=== User Password Reset ==="
      display "Your password has been reset to: 'password'."
    end
    
    def forgot
      pagoda.forgot_password
      display "=== user forgot password ==="
      display "an email has been sent to you with the updated password"
      display "please be sure to update pagoda's password on your client"
    end
    
    def add_card
      display "Enter credit card number:"
      number = ask
      valid = false
      until valid
        display "Expiration date YYYY-MM:"
        expiration = ask
        if expiration  =~ /\d{4}\-\d{2}/
          valid = true
        end
        if valid == false
          display "invalid expiration format"
        end
      end
      display "CVV number:"
      cvv = ask
      card = {:number => number, :expiration => expiration, :code => cvv}
      pagoda.user_add_card(card)
      display "card added to your account"
      display "card number: #{number}"
      display "expiration : #{expiration}"
    end
    
    def list_card #simplified because api isnt nailed down yet
      cards = parse pagoda.user_list_cards
      if cards['credit_cards']
        display "=== your cards ==="
        list = cards['credit_cards']
        list.each do |card|
          display "= Card ="
          display "last four: #{card['last_four']}"
          display "ID:        #{card['id']}"
        end
      else
        display "you do not have any credit cards on your account"
        display "to add a card run: pagoda user:add_card"
      end
    end
    
    def delete_card
      if args.length > 0
        num = args.first
        pagoda.user_delete_card(num)
        display "=== user card removied ==="
        display "removed card with the id number of: #{num}"
      else
        display "missing arguemnt: card.id"
        display "expected: pagoda user:delete_card <card id>"
      end
    end

  end
end