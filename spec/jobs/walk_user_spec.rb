require File.expand_path('../../spec_helper', __FILE__)

describe 'WalkUser#perform' do

  before(:each) do
    Resque.stub!(:enqueue)
  end

  before(:each) do
    @author = Author.gen(:github_username => 'smerritt')
  end

  before(:each) do
    @owned_repo_data = {
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

    # you always watch your own stuff
    @watched_repo_data = @owned_repo_data
    @watched_repo_data["repositories"] << {
      "name" => "bundler",
      "created_at" => "2010/01/25 16:46:38 -0800",
      "has_wiki" => true,
      "watchers" => 772,
      "private" => false,
      "url" => "http://github.com/carlhuda/bundler",
      "fork" => false,
      "pushed_at" => "2010/08/20 21:18:41 -0700",
      "has_downloads" => true,
      "open_issues" => 44,
      "has_issues" => true,
      "homepage" => "http://gembundler.com",
      "forks" => 110,
      "description" => "Manage your application's gem dependencies with less pain",
      "owner" => "carlhuda",
    }
    @watched_repo_data["repositories"] << {
      "name" => "ey-cloud-recipes",
      "created_at" => "2009/02/20 15:46:57 -0800",
      "has_wiki" => false,
      "watchers" => 573,
      "private" => false,
      "url" => "http://github.com/engineyard/ey-cloud-recipes",
      "fork" => true,
      "pushed_at" => "2010/08/20 16:31:21 -0700",
      "open_issues" => 1,
      "has_downloads" => true,
      "has_issues" => true,
      "homepage" => "http://www.engineyard.com/products/appcloud",
      "forks" => 91,
      "description" => "A starter repo for custom chef recipes on EY's cloud platform.  These are for reference, and do not indicate a supported status.",
      "source" => "subpoprecords/ey-cloud-recipes",
      "owner" => "engineyard"
    }

    FakeWeb.register_uri(:get,
      'http://github.com/api/v2/json/repos/show/smerritt',
      :body => @owned_repo_data.to_json)
    FakeWeb.register_uri(:get,
      'http://github.com/api/v2/json/repos/watched/smerritt',
      :body => @watched_repo_data.to_json)
  end

  it "walks the non-fork and watched repos and finds the parents of forks" do
    Resque.should_receive(:enqueue).with(WalkRepo, "smerritt/spiffy-elisp")
    Resque.should_receive(:enqueue).with(FindParentRepo, "smerritt/rails-2.3.2-app")
    Resque.should_receive(:enqueue).with(WalkRepo, "carlhuda/bundler")
    Resque.should_receive(:enqueue).with(FindParentRepo, "engineyard/ey-cloud-recipes")

    WalkUser.perform('smerritt')
  end

  it "updates #fetched_at" do
    @author.update(:fetched_at => Time.now - 60*60*24*8)  # 8 days ago
    now = Time.now
    Time.stub!(:now).and_return(now)

    lambda do
      WalkUser.perform('smerritt')
    end.should change { @author.reload.fetched_at }.to(now.to_datetime)
  end

  it "does nothing unless the author's #fetched_at is old enough" do
    Resque.should_not_receive(:enqueue)

    @author.update(:fetched_at => Time.now - 10)

    lambda do
      WalkUser.perform('smerritt')
    end.should_not change { @author.reload.fetched_at }
  end

end
