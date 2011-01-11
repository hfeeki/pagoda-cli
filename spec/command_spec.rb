
describe Pagoda::Command do
  
  it "extracts error messages from response when available in XML" do
    Pagoda::Command.extract_error('<errors><error>Invalid app name</error></errors>').should == ' !   Invalid app name'
  end

  it "shows Internal Server Error when the response doesn't contain a XML" do
    Pagoda::Command.extract_error('<h1>HTTP 500</h1>').should == ' !   Internal server error'
  end

  it "handles a nil body in parse_error_xml" do
    lambda { Pagoda::Command.parse_error_xml(nil) }.should_not raise_error
  end
  
  it "correctly resolves commands" do
    class Pagoda::Command::Test; end
    class Pagoda::Command::Test::Multiple; end

    Pagoda::Command.parse("foo").should == [ Pagoda::Command::App, :foo ]
    Pagoda::Command.parse("test").should == [ Pagoda::Command::Test, :index ]
    Pagoda::Command.parse("test:foo").should == [ Pagoda::Command::Test, :foo   ]
    Pagoda::Command.parse("test:multiple:foo").should == [ Pagoda::Command::Test::Multiple, :foo ]
  end
  
end