require 'pagoda/version'
require 'rexml/document'
require 'rest_client'
require 'uri'
require 'json/pure' unless {}.respond_to?(:to_json)

class Pagoda::Client

  attr_reader :user, :password, :host

  class << self
    def version
      Pagoda::VERSION
    end
    
    def gem_version_string
      "pagoda-gem/#{version}"
    end
  end
  
  def initialize(user, password, host='localhost')
    @user     = user
    @password = password
    @host     = host
  end
  
  def app_list
    get("/apps").to_s
    # doc = xml(get("/apps").to_s)
    # doc.elements['apps'].elements.to_a('//app/').inject([]) { |list, app| list << app }
  end
  
  def app_info(app)
    get("/apps/#{app}").to_s
    # doc = xml(get("/apps/#{app}").to_s)
    # doc.elements.to_a('//app/*').inject({}) do |hash, element|
    #   case element.name
    #     when "owner"
    #       hash[:owner] = {:username => element.elements['username'].text, :email => element.elements['email'].text}
    #     when "collaborators"
    #       hash[:collaborators] = element.elements.to_a('//collaborator/').inject([]) do |list, collaborator|
    #         list << {:username => collaborator.elements['username'].text, :email => collaborator.elements['email'].text}
    #       end
    #     else
    #       hash[element.name.gsub(/-/, '_').to_sym] = element.text
    #   end
    #   hash
    # end
  end
  
  def app_credit_card_info(app)
    get("/apps/#{app}/card").to_s
    # doc = xml(get("/apps/#{app}/card").to_s)
    # doc.elements.to_a("//card/*").inject({}) { |hash, element| hash[:number] = element.elements['number'].text; hash}
  end
  
  def app_add_card(app, card)
    post("/apps/#{app}/card", {:card => card})
  end
  
  def app_create(app)
    post("/apps", {:app => {:name => app}}).to_s
    # doc = xml(post("/apps", {'name' => app}).to_s)
    # doc.elements.to_a('//app/*').inject({}) {|hash, element| hash[element.name.gsub(/-/, '_').to_sym] = element.text; hash }
  end
  
  def app_destroy(app)
    delete("/apps/#{app}").to_s
  end
  
  def rollback(app)
    get("/apps/#{app}/rollback").to_s
  end
  
  def deploy(app)
    get("app/#{app}/deploy").to_s
  end
  
  def list_collaborators(app)
    get("/apps/#{app}/collaborators").to_s
    # doc = xml(get("/apps/#{app}/collaborators").to_s)
    # doc.elements.to_a('//collaborators/*').inject({}) do |hash, element|
    #   hash[:collaborators] = element.elements.to_a('//collaborator/').inject([]) do |list, collaborator|
    #     list << {:username => collaborator.elements['username'].text, :email => collaborator.elements['email'].text}
    #     hash
    #   end
    # end
  end
  
  def add_collaborator(app, email)
    post("/apps/#{app}/collaborators/#{email}").to_s
  end
  
  def remove_collaborator(app, email)
    delete("/apps/#{app}/collaborators/#{email}").to_s
  end
  
  def transfer_owner(app, email)
    put("/app/#{app}/owner/#{email}").to_s
  end
  
  #KEYS command file
  def keys
    get("/users/#{@user}/keys").to_s
    # doc = xml(get("/users/#{@user}/keys").to_s)
    # doc.elements.to_a('//keys/key').inject([]) {|list, key| list << key.text }
  end

  def add_key(key)
    post("/users/#{@user}/keys", {:user => {:key => key}}, { 'Content-Type' => 'text/ssh-authkey' }).to_s
  end
  
  def remove_key(email)
    delete("/users/#{@user}/keys/#{email}").to_s
  end
  
  def remove_all_keys
    delete("/users/#{@user}/keys").to_s
  end
  
  #USER command file
  def user_list
    get("/users").to_s
    # doc = xml(get("/users").to_s)
    # array = doc.elements.to_a('//users/*').inject() do |array, element|
    #   array << element.elements['user']
    #   array
    # end
  end
  
  def user_create(email)
    post("/users", {:user => {:username => @user, :password => @password, :email => email}}).to_s
  end

  def user_info
    get("/users/#{@user}").to_s
    # doc = xml(get("/users/#{@user}").to_s)
    # doc.elements.to_a('//user/*').inject({}) do |hash, element|
    #   hash[:user] = {:username => element.elements['username'].text, :email => element.elements['email'].text}
    #   hash
    # end
  end

  def user_update(attrib)
    put("/users/#{@user}", attrib).to_s
  end
  
  def reset_password(password)
    put("/users/#{@user}/password/reset", {:user =>{:password => password}}).to_s
    @passwrod = password
  end
  
  def forgot_password
    get("/users/#{@user}/password/forgot").to_s
    
  end
  
  def user_delete_card(card)
    delete("/users/#{@user}/cards/#{card}").to_s
  end
  
  def user_list_cards #implified because the api is still not nailed down
    get("/users/#{@user}/cards").to_s
    # doc = xml(get("/users/#{@user}/cards").to_s)
    # array = doc.elements.to_a('//cards/*').inject() do |array, element|
    #   array << element
    #   array
    # end
  end
  
  def user_add_card(card)
    post("/users/#{@user}/cards", {:card => card}).to_s
    
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
      RestClient::Resource.new("localhost:3000#{uri}", @user, @password)
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
