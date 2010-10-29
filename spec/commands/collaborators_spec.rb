module Pagoda::Command
  describe Collaborators do
    before do
      @cli = prepare_command(Collaborators)
    end

    it "lists collaborators" do
      @cli.pagoda.should_receive(:list_collaborators).and_return([])
      @cli.list
    end

    it "adds collaborators with default access to view only" do
      @cli.stub!(:args).and_return(['joe@example.com'])
      @cli.pagoda.should_receive(:add_collaborator).with('myapp', 'joe@example.com')
      @cli.add
    end

    it "removes collaborators" do
      @cli.stub!(:args).and_return(['joe@example.com'])
      @cli.pagoda.should_receive(:remove_collaborator).with('myapp', 'joe@example.com')
      @cli.remove
    end
  end
end