require File.expand_path('../../spec_helper', __FILE__)

describe 'FindParentRepo#perform' do

  before(:each) do
    Resque.stub!(:enqueue)
  end

  before(:each) do
    @fork_repo_data = {
      "repository" => {
        "name" => "thor",
        "created_at" => "2010/04/30 13:50:26 -0700",
        "parent" => "wycats/thor",
        "has_wiki" => true,
        "watchers" => 1,
        "private" => false,
        "url" => "http://github.com/smerritt/thor",
        "fork" => true,
        "pushed_at" => "2010/07/24 20:28:49 -0700",
        "has_downloads" => true,
        "open_issues" => 0,
        "has_issues" => false,
        "homepage" => "http://www.yehudakatz.com",
        "forks" => 0,
        "description" => "A scripting framework that replaces rake and sake",
        "source" => "wycats/thor",
        "owner" => "smerritt",
      }
    }

    @parent_repo_data = {
      "repository" => {
        "name" => "thor",
        "created_at" => "2008/05/07 13:07:31 -0700",
        "has_wiki" => true,
        "watchers" => 552,
        "private" => false,
        "url" => "http://github.com/wycats/thor",
        "fork" => false,
        "pushed_at" => "2010/08/19 18:31:58 -0700",
        "has_downloads" => true,
        "open_issues" => 9,
        "has_issues" => true,
        "homepage" => "http://www.yehudakatz.com",
        "forks" => 47,
        "description" => "A scripting framework that replaces rake and sake",
        "owner" => "wycats",
      }
    }

    FakeWeb.register_uri(:get,
      'http://github.com/api/v2/json/repos/show/smerritt/thor',
      :body => @fork_repo_data.to_json)
    FakeWeb.register_uri(:get,
      'http://github.com/api/v2/json/repos/show/wycats/thor',
      :body => @parent_repo_data.to_json)
  end

  context "on a fork" do
    it "enqueues a FindParentRepo to look at the fork's parent" do
      Resque.should_receive(:enqueue).with(FindParentRepo, 'wycats/thor')
      FindParentRepo.perform('smerritt/thor')
    end
  end

  context "on a non-fork" do
    it "enqueues a WalkRepo" do
      Resque.should_receive(:enqueue).with(WalkRepo, 'wycats/thor')
      FindParentRepo.perform('wycats/thor')
    end
  end

  # this happens when there's a public fork of a private repo
  context "when the repository isn't there" do
    before(:each) do
      FakeWeb.register_uri(:get,
        'http://github.com/api/v2/json/repos/show/ty/po',
        :body => {"error" => "Not Found"}.to_json,
        :status => ["404", "Not Found"])
    end

    it "does nothing" do
      Resque.should_not_receive(:enqueue)
      lambda do
        FindParentRepo.perform('ty/po')
      end.should_not raise_error
    end
  end

end
