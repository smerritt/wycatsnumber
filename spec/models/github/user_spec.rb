require File.expand_path('../../../spec_helper', __FILE__)

describe Github::User do
  before(:each) do
    # NB: repos/show/:user doesn't paginate

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
          "parent" => "engineyard/rails-2.3.2-app",
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
        {
          "name" => "distlockrun",
          "has_wiki" => true,
          "created_at" => "2009/08/13 16:47:53 -0700",
          "watchers" => 16,
          "private" => false,
          "fork" => false,
          "url" => "http://github.com/smerritt/distlockrun",
          "pushed_at" => "2009/10/13 09:53:27 -0700",
          "open_issues" => 0,
          "has_downloads" => true,
          "has_issues" => true,
          "homepage" => "",
          "forks" => 4,
          "description" => "Distributed lockrun - like lockrun, but the mutual exclusion applies across a group of machines",
          "owner" => "smerritt"
        },
        {
          "name" => "emacs-starter-kit",
          "has_wiki" => true,
          "created_at" => "2009/09/22 11:01:00 -0700",
          "watchers" => 1,
          "private" => false,
          "fork" => true,
          "url" => "http://github.com/smerritt/emacs-starter-kit",
          "pushed_at" => "2010/05/13 11:10:00 -0700",
          "open_issues" => 0,
          "has_downloads" => true,
          "has_issues" => false,
          "homepage" => "",
          "forks" => 0,
          "description" => "All the code you need to get started, with an emphasis on dynamic languages.",
          "owner" => "smerritt"
        },
        {
          "name" => "chowder",
          "has_wiki" => true,
          "created_at" => "2009/10/18 12:33:16 -0700",
          "parent" => "ichverstehe/chowder",
          "watchers" => 3,
          "private" => false,
          "fork" => true,
          "url" => "http://github.com/smerritt/chowder",
          "pushed_at" => "2009/11/10 11:14:49 -0800",
          "open_issues" => 0,
          "has_downloads" => true,
          "has_issues" => false,
          "homepage" => "",
          "forks" => 0,
          "description" => "rack middleware providing session based authentication",
          "owner" => "smerritt"
        },
        {
          "name" => "thor",
          "has_wiki" => true,
          "created_at" => "2010/04/30 13:50:26 -0700",
          "parent" => "wycats/thor",
          "watchers" => 1,
          "private" => false,
          "fork" => true,
          "url" => "http://github.com/smerritt/thor",
          "pushed_at" => "2010/07/24 20:28:49 -0700",
          "open_issues" => 0,
          "has_downloads" => true,
          "has_issues" => false,
          "homepage" => "http://www.yehudakatz.com",
          "forks" => 0,
          "description" => "A scripting framework that replaces rake and sake",
          "owner" => "smerritt"
        },
        {
          "name" => "rackapp",
          "has_wiki" => true,
          "created_at" => "2010/06/21 16:58:26 -0700",
          "watchers" => 3,
          "private" => false,
          "fork" => false,
          "url" => "http://github.com/smerritt/rackapp",
          "pushed_at" => "2010/07/30 13:32:45 -0700",
          "open_issues" => 0,
          "has_downloads" => true,
          "has_issues" => true,
          "homepage" => "",
          "forks" => 1,
          "description" => "Little rack app that I use for testing out deployments",
          "owner" => "smerritt"
        },
      ]
    }

  end

  context "#owned_repos" do
    before(:each) do
      FakeWeb.register_uri(:get,
        'http://github.com/api/v2/json/repos/show/smerritt',
        :body => @repo_data.to_json)

    end

    it "returns a list of the user's repos" do
      user = Github::User.new('smerritt')
      user.owned_repos.map {|r| r.name}.should == %w[
        smerritt/spiffy-elisp
        smerritt/rails-2.3.2-app
        smerritt/distlockrun
        smerritt/emacs-starter-kit
        smerritt/chowder
        smerritt/thor
        smerritt/rackapp
      ]
    end

    it "makes sure the repos know if they are forks or not" do
      user = Github::User.new('smerritt')

      thor = user.owned_repos.find {|r| r.name == 'smerritt/thor' }
      rackapp = user.owned_repos.find {|r| r.name == 'smerritt/rackapp'}

      thor.should be_fork
      rackapp.should_not be_fork
    end
  end

  context "#owned_repos with network gremlins" do
    before(:each) do
      @user = Github::User.new('smerritt')
    end

    it "retries until it gets data" do
      FakeWeb.register_uri(:get,
        'http://github.com/api/v2/json/repos/show/smerritt',
        [{
            :body => {"error" => "Unauthorized"}.to_json, # guessing
            :status => ["401", "Unauthorized"],
          }, {
            :body => {"error" => "Forbidden"}.to_json, # guessing
            :status => ["403", "Forbidden"],
          }, {
            :exception => Errno::ETIMEDOUT,
          }, {
            :body => @repo_data.to_json
          }])

      @user.owned_repos.should_not be_empty
    end
  end

  context "#unowned_watched_repos" do
    before(:each) do
      @watched = {
        "repositories" => [
          {
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
            "owner" => "carlhuda"
          },
          {
            "name" => "thor",
            "created_at" => "2010/04/30 13:50:26 -0700",
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
            "owner" => "smerritt"
          },
          {
            "name" => "rackapp",
            "created_at" => "2010/06/21 16:58:26 -0700",
            "has_wiki" => true,
            "watchers" => 3,
            "private" => false,
            "url" => "http://github.com/smerritt/rackapp",
            "fork" => false,
            "pushed_at" => "2010/08/06 16:10:39 -0700",
            "has_downloads" => true,
            "open_issues" => 0,
            "has_issues" => true,
            "homepage" => "",
            "forks" => 1,
            "description" => "Little rack app that I use for testing out deployments",
            "owner" => "smerritt"
          },
        ]}

      FakeWeb.register_uri(:get,
        'http://github.com/api/v2/json/repos/watched/smerritt',
        :body => @watched.to_json)
    end

    # these are ignored because #owned_repos will return them
    it "returns repos where the owner is not the user" do
      user = Github::User.new('smerritt')
      repos = user.unowned_watched_repos
      repos.size.should == 1
      repos.first.name.should == 'carlhuda/bundler'
    end
  end
end
