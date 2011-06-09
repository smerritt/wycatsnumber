require File.expand_path('../../spec_helper', __FILE__)
require 'digest/md5'

describe 'WalkRepo#perform' do

  before(:each) do
    @wycats = Author.gen(:github_username => 'wycats')
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

  it "enqueues stale old users for walking" do
    repo_has_collaborators(%w[alice])
    Author.gen(:github_username => 'alice',
      :fetched_at => Time.now - 300*DAY)

    Resque.should_receive(:enqueue).with(WalkUser, 'alice')

    WalkRepo.perform(@repo)
  end

  it "does not enqueue fresh users for walking" do
    repo_has_collaborators(%w[bob])
    Author.gen(:github_username => 'bob',
      :fetched_at => Time.now - 1)

    Resque.should_not_receive(:enqueue).with(WalkUser, 'bob')

    WalkRepo.perform(@repo)
  end

  it "does not create duplicate authors" do
    alice = Author.gen(:github_username => 'alice')

    repo_has_collaborators(%w[alice bob])
    lambda { WalkRepo.perform(@repo) }.should change(Author, :count).by(1)
  end

  it "creates the project" do
    repo_has_collaborators(%w[zoidberg])
    lambda { WalkRepo.perform(@repo) }.should change(Project, :count).by(1)
  end

  it "doesn't double-create projects" do
    repo_has_collaborators(%w[zoidberg])
    lambda do
      2.times { WalkRepo.perform(@repo) }
    end.should change(Project, :count).by(1)
  end

  it "does nothing if the project exists and has been fetched recently" do
    repo_has_collaborators(%w[zoidberg])
    project = Project.gen(:name => @repo)
    project.fetched!

    Resque.should_not_receive(:enqueue)
    lambda do
      lambda do
        WalkRepo.perform(@repo)
      end.should_not change(Project, :count)
    end.should_not change(Author, :count)

  end

  it "updates #fetched_at" do
    repo_has_collaborators(%w[dontcare])

    project = Project.gen(:name => @repo, :fetched_at => Time.now - DAY*10)

    now = Time.now
    Time.stub!(:now).and_return(now)

    lambda do
      WalkRepo.perform(@repo)
    end.should change { project.reload.fetched_at }.to(now.to_datetime)
  end

  it "does nothing if the project has been recently fetched" do
    repo_has_collaborators(%w[zoidberg])
    project = Project.gen(:name => @repo, :fetched_at => Time.now - 5)

    lambda do
      WalkRepo.perform(@repo)
    end.should_not change { project.reload.fetched_at }
  end

  it "includes gravatar ids" do
    repo_has_collaborators(%w[alice])

    WalkRepo.perform(@repo)

    Author.first(:github_username => 'alice').gravatar_id.should ==
      "6384e2b2184bcbf58eccf10ca7a6563c"   # md5sum of 'alice'
  end

end
