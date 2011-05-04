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
    doc = xml(get("/apps.xml").to_s)
    doc.elements['apps'].elements.to_a('//app/').inject([]) do |list, app| 
      list <<  {
          :name => app.elements['name'].text,
          :instances => app.elements['instances'].text,
          :git_url => app.elements['git-url'].text
        }
    end
  end
  
  def database_exists?(app, mysql_instance)
    begin
      response = get("/apps/#{app}/databases/#{mysql_instance}.xml")
      true
    rescue RestClient::ResourceNotFound => e
      false
    end
    
  end
  
  def app_create(name, git_url)
    doc = xml(post("/apps.xml", {:app => {:name => name, :git_url => git_url}}).to_s)
    doc.elements.to_a('//app/*').inject({}) do |hash, element|
      case element.name
        when "owner"
          hash[:owner] = {:username => element.elements['username'].text, :email => element.elements['email'].text}
        when "collaborators"
          hash[:collaborators] = element.elements.to_a('//collaborator/').inject([]) do |list, collaborator|
            list << {:username => collaborator.elements['username'].text, :email => collaborator.elements['email'].text}
          end
        when "transactions"
          hash[:transactions] = element.elements.to_a('//transaction/').inject([]) do |list, transaction|
            list << {
                :id          => transaction.elements["id"].text,
                :name        => transaction.elements["name"].text,
                :description => transaction.elements["description"].text,
                :state       => transaction.elements["state"].text,
                :status      => transaction.elements["status"].text
              }
          end
        else
          hash[element.name.gsub(/-/, '_').to_sym] = element.text
      end
      hash
    end
  end
  
  def app_info(app)
    doc = xml(get("/apps/#{app}.xml").to_s)
    doc.elements.to_a('//app/*').inject({}) do |hash, element|
      case element.name
        when "owner"
          hash[:owner] = {:username => element.elements['username'].text, :email => element.elements['email'].text}
        when "collaborators"
          hash[:collaborators] = element.elements.to_a('//collaborator/').inject([]) do |list, collaborator|
            list << {:username => collaborator.elements['username'].text, :email => collaborator.elements['email'].text}
          end
        when "transactions"
          hash[:transactions] = element.elements.to_a('//transaction/').inject([]) do |list, transaction|
            list << {
                :id          => transaction.elements["id"].text,
                :name        => transaction.elements["name"].text,
                :description => transaction.elements["description"].text,
                :state       => transaction.elements["state"].text,
                :status      => transaction.elements["status"].text
              }
          end
        else
          hash[element.name.gsub(/-/, '_').to_sym] = element.text
      end
      hash
    end
  end
  
  def app_update(app, updates)
    put("/apps/#{app}.xml", {:update => updates}).to_s
  end
  
  def app_destroy(app)
    delete("/apps/#{app}.xml").to_s
  end
  
  def transaction_list(app)
    doc = xml(get("/apps/#{app}/transactions.xml").to_s)
    doc.elements['transactions'].elements.to_a('//transaction/').inject([]) do |list, transaction| 
      list <<  {
          :id          => transaction.elements['id'].text,
          :name        => transaction.elements['name'].text,
          :description => transaction.elements['description'].text,
          :state       => transaction.elements['state'].text,
          :status      => transaction.elements['status'].text
        }
    end
  end
  
  def transaction_status(app, transaction)
    doc = xml(get("/apps/#{app}/transactions/#{transaction}.xml").to_s)
    doc.elements.to_a('//transaction/*').inject({}) { |hash, element| hash[element.name.gsub(/-/, '_').to_sym] = element.text; hash }
  end
  
  def rewind(app, places=1)
    doc = xml(put("/apps/#{app}/rewind.xml", {:places => places}).to_s)
    doc.elements.to_a('//transaction/*').inject({}) { |hash, element| hash[element.name.gsub(/-/, '_').to_sym] = element.text; hash }
  end
  
  def fast_forward(app, places=1)
    doc = xml(put("/apps/#{app}/fast-forward.xml", {:places => places}).to_s)
    doc.elements.to_a('//transaction/*').inject({}) { |hash, element| hash[element.name.gsub(/-/, '_').to_sym] = element.text; hash }
  end
  
  def rollback(app)
    get("/apps/#{app}/rollback.xml").to_s
  end
  
  def deploy_latest(app)
    doc = xml(post("/apps/#{app}/deploy.xml").to_s)
    doc.elements.to_a('//transaction/*').inject({}) { |hash, element| hash[element.name.gsub(/-/, '_').to_sym] = element.text; hash }
  end
  
  def deploy(app, branch, commit)
    doc = xml(post("/apps/#{app}/deploy.xml", {:deploy => {:branch => branch, :commit => commit}}).to_s)
    doc.elements.to_a('//transaction/*').inject({}) { |hash, element| hash[element.name.gsub(/-/, '_').to_sym] = element.text; hash }
  end
  
  # def deploy(app)
  #   doc = xml(put("/apps/#{app}/deploy.xml").to_s)
  #   doc.elements.to_a('//transaction/*').inject({}) { |hash, element| hash[element.name.gsub(/-/, '_').to_sym] = element.text; hash }
  # end
  
  def scale_up(app, qty=1)
    doc = xml(put("/apps/#{app}/scale-up.xml").to_s)
    doc.elements.to_a('//transaction/*').inject({}) { |hash, element| hash[element.name.gsub(/-/, '_').to_sym] = element.text; hash }
  end
  
  def scale_down(app, qty=1)
    doc = xml(put("/apps/#{app}/scale-down.xml").to_s)
    doc.elements.to_a('//transaction/*').inject({}) { |hash, element| hash[element.name.gsub(/-/, '_').to_sym] = element.text; hash }
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
      # RestClient::Resource.new("http://127.0.0.1:3000#{uri}", @user, @password)
      RestClient::Resource.new("https://dashboard.pagodabox.com#{uri}", @user, @password)
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
