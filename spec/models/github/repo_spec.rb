# -*- coding: utf-8 -*-
require File.expand_path('../../../spec_helper', __FILE__)

describe "Github::Repo#committers" do
  before(:each) do

    # trimmed for conciseness (such as it is)
    commits_page1 = {
      "commits" => [
        {
          "author" => {
            "name" => "Carlhuda",
            "login" => "",
            "email" => "carlhuda@engineyard.com"
          },
          "parents" => [
            {
              "id" => "60fb50f45bab346dda618fe623cfad5bf86c1e1f"
            }
          ],
          "url" => "http://github.com/wycats/thor/commit/e7f1e5835638af5c635fb4d538222fa9925eebc9",
          "id" => "e7f1e5835638af5c635fb4d538222fa9925eebc9",
          "committed_date" => "2010-08-02T16:26:09-07:00",
          "authored_date" => "2010-08-02T16:26:09-07:00",
          "message" => "common.jos√©",
          "committer" => {
            "name" => "Carlhuda",
            "login" => "",
            "email" => "carlhuda@engineyard.com"
          },
          "tree" => "f88fb85888911eea13d7aed55b7bfb5249e43576"
        },
        {
          "author" => {
            "name" => "Jos√© Valim",
            "login" => "josevalim",
            "email" => "jose.valim@gmail.com"
          },
          "parents" => [
            {
              "id" => "4647c98f0a8ec0a7db6a648588f0680df259803e"
            }
          ],
          "url" => "http://github.com/wycats/thor/commit/60fb50f45bab346dda618fe623cfad5bf86c1e1f",
          "id" => "60fb50f45bab346dda618fe623cfad5bf86c1e1f",
          "committed_date" => "2010-07-27T02:34:01-07:00",
          "authored_date" => "2010-07-27T02:34:01-07:00",
          "message" => "Improve docs on invoke.",
          "committer" => {
            "name" => "Jos√© Valim",
            "login" => "josevalim",
            "email" => "jose.valim@gmail.com"
          },
          "tree" => "8a63b78a2f52e73c07b552c3fe574cf582ae4ea0"
        },
        {
          "author" => {
            "name" => "Jos√© Valim",
            "login" => "josevalim",
            "email" => "jose.valim@gmail.com"
          },
          "parents" => [
            {
              "id" => "db85b667362c0e0a70ebce56d1dd89b0ebba904c"
            }
          ],
          "url" => "http://github.com/wycats/thor/commit/4647c98f0a8ec0a7db6a648588f0680df259803e",
          "id" => "4647c98f0a8ec0a7db6a648588f0680df259803e",
          "committed_date" => "2010-07-26T02:34:13-07:00",
          "authored_date" => "2010-07-26T02:34:13-07:00",
          "message" => "Bump to 0.14.0.",
          "committer" => {
            "name" => "Jos√© Valim",
            "login" => "josevalim",
            "email" => "jose.valim@gmail.com"
          },
          "tree" => "6728dd3ac4ab8bc3c7ec8c025da408e0d8139e2b"
        },
        # ...
        {
          "author" => {
            "name" => "Sam Merritt",
            "login" => "smerritt",
            "email" => "smerritt@engineyard.com"
          },
          "parents" => [
            {
              "id" => "e969b1403719794f249cadd09f0434f10da96517"
            }
          ],
          "url" => "http://github.com/wycats/thor/commit/6aec03f46272eb4fc3a352a4607a21f9d69289d9",
          "id" => "6aec03f46272eb4fc3a352a4607a21f9d69289d9",
          "committed_date" => "2010-07-25T01:02:06-07:00",
          "authored_date" => "2010-07-24T20:28:25-07:00",
          "message" => "Make lazy_default work for all option types.",
          "committer" => {
            "name" => "Jos√© Valim",
            "login" => "josevalim",
            "email" => "jose.valim@gmail.com"
          },
          "tree" => "441f20cc1f868df1172cd5b3711a441062101e9f"
        },
        {
          "author" => {
            "name" => "wycats",
            "login" => "wycats",
            "email" => "wycats@gmail.com"
          },
          "parents" => [
            {
              "id" => "3cf7db3435e5f7731a4db63aff2138be6148046b"
            }
          ],
          "url" => "http://github.com/wycats/thor/commit/1543156fa82b4c3246dc4db792784ff3afb4c68a",
          "id" => "1543156fa82b4c3246dc4db792784ff3afb4c68a",
          "committed_date" => "2010-07-24T15:04:31-07:00",
          "authored_date" => "2010-07-24T15:04:31-07:00",
          "message" => "Allow with_padding with regular #say",
          "committer" => {
            "name" => "wycats",
            "login" => "wycats",
            "email" => "wycats@gmail.com"
          },
          "tree" => "c76d1d740c6b2031b70585103982761cfca724ca"
        },
        {
          "author" => {
            "name" => "Cory Flanigan",
            "login" => "seeflanigan",
            "email" => "seeflanigan@gmail.com"
          },
          "parents" => [
            {
              "id" => "b087d7025c9df1d637be69226e16642b9ad0f354"
            }
          ],
          "url" => "http://github.com/wycats/thor/commit/3cf7db3435e5f7731a4db63aff2138be6148046b",
          "id" => "3cf7db3435e5f7731a4db63aff2138be6148046b",
          "committed_date" => "2010-07-21T19:37:24-07:00",
          "authored_date" => "2010-07-21T18:29:34-07:00",
          "message" => "Minor documentation tweaks",
          "committer" => {
            "name" => "Brian Donovan",
            "login" => "eventualbuddha",
            "email" => "brian.donovan@gmail.com"
          },
          "tree" => "1b2383ea9c0bde3819ce1470c0383562df8d84ec"
        },
        {
          "author" => {
            "name" => "Dr Nic Williams",
            "login" => "drnic",
            "email" => "drnicwilliams@gmail.com"
          },
          "parents" => [
            {
              "id" => "5ff34ce76a32308c210d5a6f84d0377871825143"
            }
          ],
          "url" => "http://github.com/wycats/thor/commit/6ac9473932b62ad0df5a754bcf886342b824d491",
          "id" => "6ac9473932b62ad0df5a754bcf886342b824d491",
          "committed_date" => "2010-06-23T16:36:16-07:00",
          "authored_date" => "2010-06-20T18:28:50-07:00",
          "message" => "Thor::Shell::HTML class (selectable by HTML env variable => ENV['THOR_SHELL'] = 'HTML') to output shell with HTML wrapper elements for color + bold",
          "committer" => {
            "name" => "Jos√© Valim",
            "login" => "josevalim",
            "email" => "jose.valim@gmail.com"
          },
          "tree" => "a482bc2a0e93d7b067f338c7e8b5b084435c1108"
        },
      ]
    }

    commits_page2 = {
      "commits" => [
        {
          "author" => {
            "name" => "Joshua Hull",
            "login" => "joshbuddy",
            "email" => "joshbuddy@gmail.com"
          },
          "parents" => [
            {
              "id" => "396c4a3e06c468dba02b33261ac64db14e1b5c3a"
            }
          ],
          "url" => "http://github.com/wycats/thor/commit/473ea671bd33aab15685a42af5bf55a2a90c83a2",
          "id" => "473ea671bd33aab15685a42af5bf55a2a90c83a2",
          "committed_date" => "2010-05-20T09:43:09-07:00",
          "authored_date" => "2010-05-18T19:14:14-07:00",
          "message" => "Added long descriptions to tasks for more detailed help messages",
          "committer" => {
            "name" => "Andre Arko",
            "login" => "indirect",
            "email" => "andre@arko.net"
          },
          "tree" => "0e69752471d1f63a95ee9819bb4c2df563a5fa16"
        },
        {
          "author" => {
            "name" => "Brian Donovan",
            "login" => "eventualbuddha",
            "email" => "brian.donovan@gmail.com"
          },
          "parents" => [
            {
              "id" => "8c16b9115dd6501d2d5bfacad035c2ece949c4bb"
            }
          ],
          "url" => "http://github.com/wycats/thor/commit/396c4a3e06c468dba02b33261ac64db14e1b5c3a",
          "id" => "396c4a3e06c468dba02b33261ac64db14e1b5c3a",
          "committed_date" => "2010-05-13T20:31:09-07:00",
          "authored_date" => "2010-05-13T20:31:09-07:00",
          "message" => "Provide some backtrace info when a thor file fails to load.\n\nBy default the first line will be sent to stderr. If the --debug flag is\npassed then the whole backtrace will be printed.",
          "committer" => {
            "name" => "Brian Donovan",
            "login" => "eventualbuddha",
            "email" => "brian.donovan@gmail.com"
          },
          "tree" => "288eff47854575b1111346318376cda24f4ac404"
        },
        {
          "author" => {
            "name" => "Jos√© Valim",
            "login" => "josevalim",
            "email" => "jose.valim@gmail.com"
          },
          "parents" => [
            {
              "id" => "dfd6b056a9f82c734ac16dc8a64b5fa107496fa7"
            }
          ],
          "url" => "http://github.com/wycats/thor/commit/8c16b9115dd6501d2d5bfacad035c2ece949c4bb",
          "id" => "8c16b9115dd6501d2d5bfacad035c2ece949c4bb",
          "committed_date" => "2010-05-05T03:00:10-07:00",
          "authored_date" => "2010-05-05T03:00:10-07:00",
          "message" => "Allow more actions to accept options as second argument.",
          "committer" => {
            "name" => "Jos√© Valim",
            "login" => "josevalim",
            "email" => "jose.valim@gmail.com"
          },
          "tree" => "4563289f019b3972457effd6d4d01bfb619e9e3f"
        },
      ]
    }

    FakeWeb.register_uri(:get,
      'http://github.com/api/v2/json/commits/list/wycats/thor/master?page=1',
      :body => commits_page1.to_json)
    FakeWeb.register_uri(:get,
      'http://github.com/api/v2/json/commits/list/wycats/thor/master?page=2',
      :body => commits_page2.to_json)
    FakeWeb.register_uri(:get,
      'http://github.com/api/v2/json/commits/list/wycats/thor/master?page=3',
      :body => {"error" => "Not Found"}.to_json,
      :status => ["404", "Not Found"])

    @repo = Github::Repo.new('wycats/thor')
  end

  it "finds committers from the first page of results" do
    @repo.committers.should include(Github::User.new('josevalim'))
    @repo.committers.should include(Github::User.new('seeflanigan'))
  end

  it "finds committers from subsequent pages of results" do
    @repo.committers.should include(Github::User.new('joshbuddy'))
  end

  it "ignores commits by people without github logins" do
    @repo.committers.should_not include(Github::User.new(''))
  end

  it "filters out duplicates" do
    @repo.committers.find_all do |user|
      user.name == 'josevalim'
    end.size.should == 1
  end
end
