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
  
  def initialize(user, password, host='pagodagrid.com')
    @user     = user
    @password = password
    @host     = host
  end
  
  def info(app)
    doc = xml(get("/apps/#{app}").to_s)
    doc.elements.to_a('//app/*').inject({}) do |hash, element|
      case element.name
        when "owner"
          hash[:owner] = {:username => element.elements['username'].text, :email => element.elements['email'].text}
        when "collaborators"
          hash[:collaborators] = element.elements.to_a('//collaborator/').inject([]) do |list, collaborator|
            list << {:username => collaborator.elements['username'].text, :email => collaborator.elements['email'].text}
          end
        else
          hash[element.name.gsub(/-/, '_').to_sym] = element.text
      end
      hash
    end
  end
  
  def rollback(app)
    get("/apps/#{app}/rollback").to_s
  end
  
  def add_collaborator(app, email)
    post("/apps/#{app}/collaborators", { 'collaborator[email]' => email }).to_s
  end
  
  def remove_collaborator(app, email)
    delete("/apps/#{app}/collaborators/#{email}").to_s
  end
  
  def list
    doc = xml(get("/apps").to_s)
    doc.elements['apps'].elements.to_a('//app/').inject([]) { |list, app| list << app.elements['name'].text }
  end
  
  def create(app)
    doc = xml(post("/apps", {'name' => 'testapp'}).to_s)
    doc.elements.to_a('//app/*').inject({}) {|hash, element| hash[element.name.gsub(/-/, '_').to_sym] = element.text; hash }
  end
  
  def destroy(app)
    delete("/apps/#{app}").to_s
  end
  
  def keys
    doc = xml(get('/keys').to_s)
    doc.elements.to_a('//keys/key').inject([]) {|list, key| list << key.text }
  end
  
  def add_key(key)
    post('/keys', key, { 'Content-Type' => 'text/ssh-authkey' }).to_s
  end
  
  def remove_key(email)
    delete("/keys/#{email}").to_s
  end
  
  def remove_all_keys
    delete("/keys").to_s
  end
  
  def on_warning(&blk)
    @warning_callback = blk
  end
  
  protected
  
  def resource(uri)
    RestClient.proxy = ENV['HTTP_PROXY'] || ENV['http_proxy']
    if uri =~ /^https?/
      RestClient::Resource.new(uri, user, password)
    else
      RestClient::Resource.new("https://api.pagodagrid.com", user, password)[uri]
    end
  end

  def get(uri, extra_headers={})    
    process(:get, uri, extra_headers)
  end

  def post(uri, payload="", extra_headers={})    
    process(:post, uri, extra_headers, payload)
  end

  def put(uri, payload, extra_headers={})    
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
      'X-Ruby-Platform'      => RUBY_PLATFORM
    }
  end

  def xml(raw)   # :nodoc:
    REXML::Document.new(raw)
  end
  
end
