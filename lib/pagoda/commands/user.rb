module Pagoda::Command
  class User < Base
    
    def list
      users = parse pagoda.user_list
      if users['users']
        display "=== users ==="
        list = users['users']['user']
        list.each do |user|
          display "Username: #{user}"
        end
      else
        display "no users found"
      end
    end
    
    def create
      puts "Enter your PagodaGrid credentials."
      print "email:"
      email = ask
      pagoda.user_create(email)
      display "user created successful"
    end
    
    def info
      rtn = parse pagoda.user_info
      if rtn['user']
        user = rtn['user']
        display "=== user info ==="
        display "Username: #{user['username']}"
        display "Email:    #{user['email']}"
        display "ID:       #{user['id']}"
      else
        display "you are not a registered user."
        display "run: pagoda user:create"
      end
    end
    
    def update
      display "=== Not Yet Implemented ==="
    end
    
    def reset
      pagoda.reset_password("password")
      display "=== user reset ==="
      display "password reset to: 'password'"
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