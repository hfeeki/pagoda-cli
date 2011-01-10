require 'pagoda/version'
require 'rexml/document'
require 'rest_client'
require 'uri'
require 'json/pure' unless {}.respond_to?(:to_json)

class Pagoda::Client

  attr_reader :user, :password

  class << self
    def version
      Pagoda::VERSION
    end
    
    def gem_version_string
      "pagoda-gem/#{version}"
    end
  end
  
  def initialize(user, password)
    @user       = user
    @password   = password
  end
  
  def app_list
    get("/apps.xml").to_s
  end
  
  def app_create(app)
    post("/apps.xml", {:app => app}).to_s
  end
  
  def app_info(app)
    get("/apps/#{app}.xml").to_s
  end
  
  def app_update(app, updates)
    put("/apps/#{app}.xml", {:update => updates}).to_s
  end
  
  def app_destroy(app)
    delete("/apps/#{app}.xml").to_s
  end
  
  def app_credit_card_info(app)
    get("/apps/#{app}/card.xml").to_s
  end
  
  def app_add_card(app, card)
    post("/apps/#{app}/card.xml", {:card => card}).to_s
  end
  
  def rollback(app)
    get("/apps/#{app}/rollback.xml").to_s
  end
  
  def deploy(app)
    get("app/#{app}/deploy.xml").to_s
  end
  
  def list_collaborators(app)
    get("/apps/#{app}/collaborators.xml").to_s
  end
  
  def add_collaborator(app, email)
    post("/apps/#{app}/collaborators.xml", {:email => email}).to_s
  end
  
  def remove_collaborator(app, email)
    delete("/apps/#{app}/collaborators/#{email}.xml").to_s
  end
  
  def transfer_owner(app, email)
    put("/apps/#{app}/owner/#{email}.xml").to_s
  end
  
  def user_create(email)
    post("/users.xml", {:user => {:username => @user, :password => @password, :email => email}}).to_s
  end

  def user_info
    get("/users/#{@user}.xml").to_s
  end

  def user_update(updates)
    put("/users/#{@user}.xml", {:user => updates}).to_s
  end
  
  def reset_password(password)
    put("/users/#{@user}/password/reset.xml", {:user =>{:password => password}}).to_s
    @password = password
  end
  
  def user_delete_card(card)
    delete("/users/#{@user}/cards/#{card}.xml").to_s
  end
  
  def user_list_cards 
    get("/users/#{@user}/cards.xml").to_s
  end
  
  def user_add_card(card)
    post("/users/#{@user}/cards.xml", {:card => card}).to_s
  end
  
  def on_warning(&blk)
    @warning_callback = blk
  end
  
  protected
  
  def resource(uri)
    RestClient.proxy = ENV['HTTP_PROXY'] || ENV['http_proxy']
    if uri =~ /^https?/
      RestClient::Resource.new(uri, @user, @password)
    else
      RestClient::Resource.new("www.pagodabox.com#{uri}", @user, @password)
    end
  end

  def get(uri, extra_headers={})
    process(:get, uri, extra_headers)
  end

  def post(uri, payload="", extra_headers={})    
    process(:post, uri, extra_headers, payload)
  end

  def put(uri, payload="", extra_headers={})    
    process(:put, uri, extra_headers, payload)
  end

  def delete(uri, extra_headers={})    
    process(:delete, uri, extra_headers)
  end

  def process(method, uri, extra_headers={}, payload=nil)
    headers  = pagoda_headers.merge(extra_headers)
    args     = [method, payload, headers].compact
    response = resource(uri).send(*args)
  end
  
  def pagoda_headers
    {
      'User-Agent'           => self.class.gem_version_string,
      'X-Ruby-Version'       => RUBY_VERSION,
      'X-Ruby-Platform'      => RUBY_PLATFORM,
    }
  end

  def xml(raw)   # :nodoc:
    REXML::Document.new(raw)
  end
  
end
