require File.expand_path('../../spec_helper', __FILE__)

describe 'WalkUser#perform' do

  before(:each) do
    Resque.stub!(:enqueue)
  end

  before(:each) do
    @repo_data = {
      "repositories" => [
        {
          "name" => "spiffy-elisp",
          "has_wiki" => true,
          "created_at" => "2009/01/05 12:34:56 -0800",
          "watchers" => 11,
          "private" => false,
          "fork" => false,
          "url" => "http://github.com/smerritt/spiffy-elisp",
          "pushed_at" => "2010/06/09 13:53:45 -0700",
          "open_issues" => 0,
          "has_downloads" => true,
          "has_issues" => true,
          "homepage" => "",
          "forks" => 1,
          "description" => "Minor modes I use.",
          "owner" => "smerritt"
        },
        {
          "name" => "rails-2.3.2-app",
          "has_wiki" => true,
          "created_at" => "2009/05/21 13:26:58 -0700",
          "watchers" => 2,
          "private" => false,
          "fork" => true,
          "url" => "http://github.com/smerritt/rails-2.3.2-app",
          "pushed_at" => "2010/06/21 16:38:55 -0700",
          "open_issues" => 0,
          "has_downloads" => true,
          "has_issues" => false,
          "homepage" => "",
          "forks" => 0,
          "description" => "Clone of rails-2.2.2-app for Rails 2.3.2",
          "owner" => "smerritt"
        },
      ],
    }

    FakeWeb.register_uri(:get,
      'http://github.com/api/v2/json/repos/show/smerritt',
      :body => @repo_data.to_json)
  end

  it "enqueues the user's repos for walking" do
    Resque.should_receive(:enqueue).with(WalkRepo, "smerritt/spiffy-elisp")

    WalkUser.perform('smerritt')
  end

  it "ignores forked repos" do
    Resque.should_not_receive(:enqueue).with(WalkRepo, "smerritt/rails-2.3.2-app")
    
    WalkUser.perform('smerritt')
  end
  
end
