require File.expand_path('../../spec_helper', __FILE__)
require 'digest/md5'

describe 'WalkRepo#perform' do
  
  before(:each) do
    @wycats = Author.gen(:github_username => 'wycats', :distance => 0)
  end

  before(:each) do
    @repo = 'test/repo'
  end

  before(:each) do
    Resque.stub!(:enqueue)
  end

  def repo_data_with_collaborators(collabs)
    {
      "contributors" => collabs.map do |collab|
        {
          "login"         => collab,
          "gravatar_id"   => Digest::MD5.new.hexdigest(collab),
          "contributions" => rand(10),
          "type"          => "User",
        }
      end
    }
  end

  def repo_has_collaborators(collabs)
    FakeWeb.register_uri(:get,
      "http://github.com/api/v2/json/repos/show/#{@repo}/contributors",
      :body => repo_data_with_collaborators(collabs).to_json
      )
  end


  it "creates new authors as it sees them" do
    repo_has_collaborators(%w[alice bob])
    lambda { WalkRepo.perform(@repo) }.should change(Author, :count).by(2)
  end

  it "enqueues new users for walking" do
    repo_has_collaborators(%w[alice bob])
    Resque.should_receive(:enqueue).with(WalkUser, 'alice')
    Resque.should_receive(:enqueue).with(WalkUser, 'bob')

    WalkRepo.perform(@repo)
  end

  it "does not create duplicate authors" do
    alice = Author.gen(:github_username => 'alice')

    repo_has_collaborators(%w[alice bob])
    lambda { WalkRepo.perform(@repo) }.should change(Author, :count).by(1)
  end

  it "does not enqueue existing users for walking" do
    alice = Author.gen(:github_username => 'alice')
    repo_has_collaborators(%w[alice bob])
    
    Resque.should_receive(:enqueue).with(WalkUser, 'bob')
    Resque.should_not_receive(:enqueue).with(WalkUser, 'alice')

    WalkRepo.perform(@repo)
  end
    
  it "creates the project" do
    repo_has_collaborators(%w[zoidberg])
    lambda { WalkRepo.perform(@repo) }.should change(Project, :count).by(1)
  end

  it "does nothing if the project exists" do
    repo_has_collaborators(%w[zoidberg])
    project = Project.gen(:name => @repo)

    # this shouldn't happen, but in case it does, don't screw up the DB

    Resque.should_not_receive(:enqueue)
    lambda do
      lambda do
        WalkRepo.perform(@repo)
      end.should_not change(Project, :count)
    end.should_not change(Author, :count)

  end

  it "updates distances and paths" do
    repo_has_collaborators(%w[alice wycats])

    WalkRepo.perform(@repo)

    Author.first(:github_username => 'alice').distance.should == 1
  end

  it "includes gravatar ids" do
    repo_has_collaborators(%w[alice])

    WalkRepo.perform(@repo)

    Author.first(:github_username => 'alice').gravatar_id.should ==
      "6384e2b2184bcbf58eccf10ca7a6563c"   # md5sum of 'alice'

  end

  # this is more of a reminder for me than an actual spec
  it "wraps the whole thing in a serializable transaction"

end