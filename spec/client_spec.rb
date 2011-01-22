require "#{File.dirname(__FILE__)}/base"
require "#{File.dirname(__FILE__)}/../lib/pagoda/client"

describe Pagoda::Client do
  
  before do
    @client   = Pagoda::Client.new(nil, nil)
  end
  
  describe "app" do
    
    it "should display information" do
      stub = %{
        <?xml version='1.0' encoding='UTF-8'?>
        <app>
          <name>testapp</name>
          <git-url>git@github.com:tylerflint/pagoda-pilot.git</git-url>
          <owner>
            <username>owner1</username>
            <email>owner1@test.com</email>
          </owner>
          <collaborators type="array">
            <collaborator>
              <username>guy1</username>
              <email>guy1@test.com</email>
            </collaborator>
            <collaborator>
              <username>guy2</username>
              <email>guy2@test.com</email>
            </collaborator>
          </collaborators>
          <transactions type="array">
            <transaction>
              <id>1</id>
              <name>app.init</name>
              <description>Deploying app to the Pagoda grid</description>
              <state>started</state>
              <status></status>
            </transaction>
          </transactions>
        </app>
      }
      stub_api_request(:get, "/apps/testapp.xml").to_return(:body => stub)
      @client.app_info('testapp').should == {
        :name           => 'testapp',
        :git_url        => 'git@github.com:tylerflint/pagoda-pilot.git',
        :owner          => {
          :username     => 'owner1',
          :email        => 'owner1@test.com'
        },
        :collaborators => [
          {:username   => 'guy1', :email => 'guy1@test.com'},
          {:username   => 'guy2', :email => 'guy2@test.com'}
        ],
        :transactions => [
          {:id => '1', :name => 'app.init', :description => 'Deploying app to the Pagoda grid', :state => 'started', :status => nil}
        ]
      }
    end
    
    it "lists incomplete transactions" do
      stub = %{
        <?xml version='1.0' encoding='UTF-8'?>
        <transactions type="array">
          <transaction>
            <id>1</id>
            <name>app.increment</name>
            <description>spawn new instance of app</description>
            <state>started</state>
            <status></status>
          </transaction>
          <transaction>
            <id>2</id>
            <name>app.deploy</name>
            <description>deploy code</description>
            <state>ready</state>
            <status></status>
          </transaction>
        </transactions>
      }
      stub_api_request(:get, "/apps/testapp/transactions.xml").to_return(:body => stub)
      @client.transaction_list('testapp').should == [
        {:id => '1', :name => 'app.increment', :description => 'spawn new instance of app', :state => 'started', :status => nil},
        {:id => '2', :name => 'app.deploy', :description => 'deploy code', :state => 'ready', :status => nil}
      ]
    end
    
    it "lists details of a transaction" do
      stub = %{
        <?xml version='1.0' encoding='UTF-8'?>
        <transaction>
          <id>1</id>
          <name>app.increment</name>
          <description>spawn new instance of app</description>
          <state>started</state>
          <status></status>
        </transaction>
      }
      stub_api_request(:get, "/apps/testapp/transactions/123.xml").to_return(:body => stub)
      @client.transaction_status('testapp', '123').should == {:id => '1', :name => 'app.increment', :description => 'spawn new instance of app', :state => 'started', :status => nil}
    end
    
    it "deploys" do
      stub = %{
        <?xml version='1.0' encoding='UTF-8'?>
        <transaction>
          <id>1</id>
          <name>app.deploy</name>
          <description>deploy new code</description>
          <state>started</state>
          <status></status>
        </transaction>
      }
      stub_api_request(:put, "/apps/testapp/deploy.xml").to_return(:body => stub)
      @client.deploy('testapp').should == {:id => '1', :name => 'app.deploy', :description => 'deploy new code', :state => 'started', :status => nil}      
    end
    
    it "rewinds deploy list" do
      stub = %{
        <?xml version='1.0' encoding='UTF-8'?>
        <transaction>
          <id>1</id>
          <name>app.traverse</name>
          <description>traverse the code</description>
          <state>started</state>
          <status></status>
        </transaction>
      }
      stub_api_request(:put, "/apps/testapp/rewind.xml").to_return(:body => stub)
      @client.rewind('testapp', 1).should == {:id => '1', :name => 'app.traverse', :description => 'traverse the code', :state => 'started', :status => nil}
    end
    
    it "fast-forwards deploy list" do
      stub = %{
        <?xml version='1.0' encoding='UTF-8'?>
        <transaction>
          <id>1</id>
          <name>app.traverse</name>
          <description>traverse the code</description>
          <state>started</state>
          <status></status>
        </transaction>
      }
      stub_api_request(:put, "/apps/testapp/fast-forward.xml").to_return(:body => stub)
      @client.fast_forward('testapp', 1).should == {:id => '1', :name => 'app.traverse', :description => 'traverse the code', :state => 'started', :status => nil}
    end

    it "scales up" do
      stub = %{
        <?xml version='1.0' encoding='UTF-8'?>
        <transaction>
          <id>1</id>
          <name>app.scaleup</name>
          <description>scaling app</description>
          <state>started</state>
          <status></status>
        </transaction>
      }
      stub_api_request(:put, "/apps/testapp/scale-up.xml").to_return(:body => stub)
      @client.scale_up('testapp', 1).should == {:id => '1', :name => 'app.scaleup', :description => 'scaling app', :state => 'started', :status => nil}
    end
    
    it "scales down" do
      stub = %{
        <?xml version='1.0' encoding='UTF-8'?>
        <transaction>
          <id>1</id>
          <name>app.scaledown</name>
          <description>scaling app</description>
          <state>started</state>
          <status></status>
        </transaction>
      }
      stub_api_request(:put, "/apps/testapp/scale-down.xml").to_return(:body => stub)
      @client.scale_down('testapp', 1).should == {:id => '1', :name => 'app.scaledown', :description => 'scaling app', :state => 'started', :status => nil}
    end
    
  end
  
  describe "user" do
    
    it "should list all active apps" do
      stub = %{
        <?xml version='1.0' encoding='UTF-8'?>
        <apps type="array">
          <app>
            <id>1</id>
            <name>burt</name>
            <git-url>git@github.com:tylerflint/pagoda-pilot.git</git-url>
          </app>
          <app>
            <id>2</id>
            <name>ernie</name>
            <git-url>git@github.com:tylerflint/pagoda-pilot.git</git-url>
          </app>
        </apps>
      }
      stub_api_request(:get, "/apps.xml").to_return(:body => stub)
      @client.app_list.should == [{:id => '1', :name => 'burt', :git_url => 'git@github.com:tylerflint/pagoda-pilot.git'}, {:id => '2', :name => 'ernie', :git_url => 'git@github.com:tylerflint/pagoda-pilot.git'}]
    end
    
    it "should create a new app" do
      stub = %{
        <?xml version='1.0' encoding='UTF-8'?>
        <app>
          <name>testapp</name>
           <git-url>git@github.com:tylerflint/pagoda-pilot.git</git-url>
           <owner>
             <username>tylerflint</username>
             <email>tylerflint@gmail.com</email>
           </owner>
           <collaborators>
           </collaborators>
           <transactions type="array">
             <transaction>
               <id>1</id>
               <name>app.init</name>
               <description>Deploying app to the Pagoda grid</description>
               <state>started</state>
               <status></status>
             </transaction>
           </transactions>
        </app>
      }
      stub_api_request(:post, '/apps.xml').with(:body => "app[name]=testapp&app[git_url]=git%40github.com%3Atylerflint%2Fpagoda-pilot.git").to_return(:body => stub)
      @client.app_create('testapp', 'git@github.com:tylerflint/pagoda-pilot.git').should == {
        :name => 'testapp',
        :git_url => 'git@github.com:tylerflint/pagoda-pilot.git',
        :owner => {
          :username => 'tylerflint',
          :email => 'tylerflint@gmail.com'
        },
        :collaborators => [],
        :transactions => [
          {:id => '1', :name => 'app.init', :description => 'Deploying app to the Pagoda grid', :state => 'started', :status => nil}
        ]
      }
    end
    
    it "should destroy an active app" do
      stub_api_request(:delete, '/apps/testapp.xml')
      @client.app_destroy('testapp')
    end
    
  end
  
end
