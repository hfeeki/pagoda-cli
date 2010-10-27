require "#{File.dirname(__FILE__)}/helper"
require "#{File.dirname(__FILE__)}/../lib/pagoda/client"

describe Pagoda::Client do
  
  before do
    @client   = Pagoda::Client.new(nil, nil)
  end
  
  describe "an app" do
    
    it "should display information" do
      stub = %{
        <?xml version='1.0' encoding='UTF-8'?>
        <app>
          <name>testapp</name>
          <ip>24.116.177.210</ip>
          <instances>4</instances>
          <created-at type='datetime'>2008-07-08T17:21:50-07:00</created-at>
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
        </app>
      }
      stub_api_request(:get, "/apps/testapp").to_return(:body => stub)
      @client.info('testapp').should == {
        :name           => 'testapp',
        :ip             => '24.116.177.210',
        :instances      => '4',
        :created_at     => '2008-07-08T17:21:50-07:00',
        :owner          => {
          :username     => 'owner1',
          :email        => 'owner1@test.com'
        },
        :collaborators => [
          {:username   => 'guy1', :email => 'guy1@test.com'},
          {:username   => 'guy2', :email => 'guy2@test.com'}
        ]
      }
    end

    it "should rollback code base" do
      stub_api_request(:get, '/apps/testapp/rollback')
      @client.rollback('testapp')
    end

    it "should add a collaborator" do
      stub_api_request(:post, '/apps/testapp/collaborators').with(:body => 'collaborator%5Bemail%5D=test%40test.com')
      @client.add_collaborator('testapp', 'test@test.com')
    end

    it "should remove a collaborator" do
      stub_api_request(:delete, '/apps/testapp/collaborators/test%40test%2Ecom')
      @client.remove_collaborator('testapp', 'test@test.com')
    end
    
  end
  
  describe "a user" do
    
    it "should list all active apps" do
      stub = %{
        <?xml version='1.0' encoding='UTF-8'?>
        <apps type="array">
          <app><name>burt</name></app>
          <app><name>ernie</name></app>
        </apps>
      }
      stub_api_request(:get, "/apps").to_return(:body => stub)
      @client.list.should == ['burt', 'ernie']
    end
    
    it "should create a new app" do
      stub = %{
        <?xml version='1.0' encoding='UTF-8'?>
        <app>
          <name>testapp</name>
          <ip>24.116.177.210</ip>
        </app>
      }
      stub_api_request(:post, '/apps').with(:body => "name=testapp").to_return(:body => stub)
      @client.create('testapp').should == {
        :name => 'testapp',
        :ip   => '24.116.177.210'
      }
    end

    it "should destroy an active app" do
      stub_api_request(:delete, '/apps/testapp')
      @client.destroy('testapp')
    end
    
    it "should list ssh keys" do
      stub = %{
        <?xml version='1.0' encoding='UTF-8'?>
        <keys type="array">
          <key>ssh-rsa AAAA== test@test.com</key>
        </keys>
      }
      stub_api_request(:get, '/keys').to_return(:body => stub)
      @client.keys.should == ['ssh-rsa AAAA== test@test.com']
    end

    it "should add ssh key" do
      stub_api_request(:post, '/keys').with(:body => 'ssh-rsa AAAA== test@test.com')
      @client.add_key('ssh-rsa AAAA== test@test.com')
    end

    it "should remove an ssh key" do
      stub_api_request(:delete, '/keys/test@test.com')
      @client.remove_key('test@test.com')
    end

    it "should remove all ssh keys" do
      stub_api_request(:delete, '/keys')
      @client.remove_all_keys
    end
    
  end
  
end
