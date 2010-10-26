require 'pagoda/version'
# require 'rexml/document'
# require 'rest_client'
# require 'uri'

class Pagoda::Client

  attr_reader :user, :password

  class << self
    def version
      Pagoda::VERSION
    end
  end
  
  def initialize(user, password)
    @user     = user
    @password = password
  end
  
  
end
