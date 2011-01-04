module Pagoda::Command
  describe App do
    before(:each) do
      @cli = prepare_command(App)
    end
    
    it "should list all apps" do
      @cli.pagoda.should_receive(:list).and_return(['app1', 'app2'])
      @cli.should_receive(:display).with("=== Your Apps ===")
      @cli.should_receive(:display).with("app1\napp2")
      @cli.list
    end
    
    it "should inform no apps available" do
      @cli.pagoda.should_receive(:list).and_return([])
      @cli.should_receive(:display).with("You have no apps.")
      @cli.list
    end

    it "shows app info using the --app syntax" do
      @cli.stub!(:args).and_return(['--app', 'myapp'])
      @cli.pagoda.should_receive(:info).with('myapp').and_return({
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
      })
      @cli.should_receive(:display).with("=== testapp ===")
      @cli.should_receive(:display).with("IP:           24.116.177.210")
      @cli.should_receive(:display).with("Instances:    4")
      @cli.should_receive(:display).with("Created At:   2008-07-08T17:21:50-07:00")
      @cli.should_receive(:display).with("\n")
      @cli.should_receive(:display).with("== Owner ==")
      @cli.should_receive(:display).with("Username:     owner1")
      @cli.should_receive(:display).with("Email:        owner1@test.com")
      @cli.should_receive(:display).with("\n")
      @cli.should_receive(:display).with("== Collaborators ==")
      @cli.should_receive(:display).with("guy1 -> guy1@test.com")
      @cli.should_receive(:display).with("guy2 -> guy2@test.com")
      @cli.info
    end

    it "shows app info reading app from current git dir" do
      @cli.stub!(:args).and_return([])
      @cli.stub!(:extract_app_in_dir).and_return('myapp')
      @cli.pagoda.should_receive(:info).with('myapp').and_return({
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
      })
      @cli.should_receive(:display).with("=== testapp ===")
      @cli.should_receive(:display).with("IP:           24.116.177.210")
      @cli.should_receive(:display).with("Instances:    4")
      @cli.should_receive(:display).with("Created At:   2008-07-08T17:21:50-07:00")
      @cli.should_receive(:display).with("\n")
      @cli.should_receive(:display).with("== Owner ==")
      @cli.should_receive(:display).with("Username:     owner1")
      @cli.should_receive(:display).with("Email:        owner1@test.com")
      @cli.should_receive(:display).with("\n")
      @cli.should_receive(:display).with("== Collaborators ==")
      @cli.should_receive(:display).with("guy1 -> guy1@test.com")
      @cli.should_receive(:display).with("guy2 -> guy2@test.com")
      @cli.info
    end
    
    it "should create (register) an app" do
      @cli.stub!(:args).and_return(['myapp'])
      @cli.pagoda.should_receive(:create).and_return({
        :name => 'myapp',
        :ip   => '24.116.177.210'
      })
      @cli.should_receive(:display).with("=== myapp ===")
      @cli.should_receive(:display).with("IP:    24.116.177.210")
      @cli.should_receive(:display).with("\n")
      @cli.should_receive(:display).with("From myapp's root directory, run: pagoda init myapp")
      @cli.create
    end
    
    it "should require an app name to be specified" do
      @cli.stub!(:args).and_return([])
      @cli.stub!(:error)
      @cli.should_receive(:error).with("Please specify an app name: pagoda create appname")
      @cli.create
    end
    
    it "should not allow user to create an app without valid account" do
      
    end
    
    it "should require app name" do
      @cli.stub!(:args).and_return([])
      @cli.stub!(:error)
      @cli.should_receive(:error).with("Please specify an app name: pagoda init appname")
      @cli.init
    end
    
    it "should warn and exit when if specified app doesn't exist" do
      @cli.stub!(:args).and_return(['myapp'])
      @cli.pagoda.stub!(:list).and_return(['app1', 'app2'])
      @cli.stub!(:error)
      @cli.should_receive(:error).with("myapp doesn't match any of the existing apps.\nYou must first create myapp if it doesn't already exist. # pagoda create myapp\nList all available apps # pagoda list")
      @cli.init
    end
    
    it "should confirm root directory" do
      @cli.stub!(:args).and_return(['myapp'])
      @cli.pagoda.stub!(:list).and_return(['myapp'])
      @cli.stub!(:confirm).and_return(false)
      @cli.stub!(:error)
      @cli.should_receive(:confirm).with("Is this myapp's root directory? (y/n)")
      @cli.should_receive(:error).with("Please change into myapp's root directory and try again.")
      @cli.init
    end
    
    it "should init git repo if not already created" do
      @cli.stub!(:args).and_return(['myapp'])
      @cli.pagoda.stub!(:list).and_return(['myapp'])
      @cli.stub!(:confirm).and_return(true)
      @cli.stub!(:is_git?).and_return(false)
      @cli.stub!(:init_app)
      @cli.should_receive(:init_app)
      @cli.should_receive(:add_remote)
      @cli.should_receive(:display).with("myapp is ready for deployment! # pagoda deploy")
      @cli.init
    end
    
    it "should not init already existing repo" do
      @cli.stub!(:args).and_return(['myapp'])
      @cli.pagoda.stub!(:list).and_return(['myapp'])
      @cli.stub!(:confirm).and_return(true)
      @cli.stub!(:is_git?).and_return(true)
      @cli.should_not_receive(:init_app)
      @cli.should_receive(:add_remote)
      @cli.should_receive(:display).with("myapp is ready for deployment! # pagoda deploy")
      @cli.init
    end
    
    it "should confirm before destroying app" do
      @cli.stub!(:args).and_return(['--app', 'myapp'])
      @cli.stub!(:confirm).and_return(false)
      @cli.should_receive(:confirm).with("Are you sure you want to destroy myapp? This cannot be undone! (y/n)")
      @cli.pagoda.stub!(:destroy)
      @cli.pagoda.should_not_receive(:destroy)
      @cli.destroy
    end
    
    it "should destroy app after confirmation" do
      @cli.stub!(:args).and_return(['--app', 'myapp'])
      @cli.stub!(:confirm).and_return(true)
      @cli.should_receive(:confirm).with("Are you sure you want to destroy myapp? This cannot be undone! (y/n)")
      @cli.pagoda.stub!(:destroy)
      @cli.pagoda.should_receive(:destroy)
      @cli.should_receive(:display).with("myapp permanently destroyed.")
      @cli.destroy
    end
    
  end
end