# -*- coding: utf-8 -*-
require File.expand_path('../../../spec_helper', __FILE__)

describe "Github::Repo#users" do
  before(:each) do

    # trimmed for conciseness (such as it is)
    @contributors = {
      "contributors" => [
        {
          "name" => "Jos√© Valim",
          "gravatar_id" => "e837f6b7fd146ab16ed3d663476c063e",
          "company" => "Plataforma",
          "location" => "S√£o Paulo/Brasil, Krak√≥w/Polska",
          "blog" => "http://blog.plataformatec.com.br/",
          "contributions" => 410,
          "type" => "User",
          "login" => "josevalim",
          "email" => "jose.valim@plataformatec.com.br"
        },
        {
          "name" => "Nathan Weizenbaum",
          "gravatar_id" => "39b3031f890ad7ce40661614af8b52a6",
          "company" => "",
          "location" => "Seattle",
          "blog" => "http://nex-3.com",
          "contributions" => 87,
          "type" => "User",
          "login" => "nex3",
          "email" => "nex342@gmail.com"
        },
        {
          "name" => "Yehuda Katz",
          "gravatar_id" => "428167a3ec72235ba971162924492609",
          "company" => "Engine Yard",
          "location" => "San Francisco",
          "blog" => "http://www.yehudakatz.com",
          "contributions" => 34,
          "type" => "User",
          "login" => "wycats",
          "email" => "wycats@gmail.com"
        },
        {
          "name" => "Brian Donovan",
          "gravatar_id" => "d62308e6f4a387595064a6df1cfff538",
          "company" => "",
          "location" => "San Francisco",
          "blog" => "http://brian-donovan.com/",
          "contributions" => 17,
          "type" => "User",
          "login" => "eventualbuddha"
        },
        {
          "name" => "James Herdman",
          "gravatar_id" => "90ebe8da17aabd36cc30d9f96a530e6f",
          "location" => "Toronto, ON",
          "blog" => "http://jherdman.github.com",
          "contributions" => 15,
          "type" => "User",
          "login" => "jherdman",
          "email" => "james.herdman@me.com"
        },
        {
          "name" => "Mislav Marohniƒá",
          "gravatar_id" => "8f93a872e399bc1353cc8d4e791d5401",
          "company" => "Teambox",
          "location" => "Barcelona",
          "blog" => "http://mislav.uniqpath.com/",
          "contributions" => 13,
          "type" => "User",
          "login" => "mislav",
          "email" => "mislav.marohnic@gmail.com"
        },
        {
          "name" => "Fabien Franzen",
          "gravatar_id" => "9871c515e1a284f2861f1d92645fd00a",
          "location" => "Belgium",
          "contributions" => 13,
          "type" => "User",
          "login" => "fabien",
          "email" => "info@atelierfabien.be"
        },
        {
          "name" => "Markus Prinz",
          "gravatar_id" => "0176d9564601b43d75aff59f2cceed88",
          "company" => "Soup.io",
          "location" => "Austria",
          "blog" => "http://blog.nuclearsquid.com/",
          "contributions" => 12,
          "type" => "User",
          "login" => "cypher",
          "email" => "markus.prinz@nuclearsquid.com"
        },
        {
          "name" => "Andre Arko",
          "gravatar_id" => "fb389f1e8b98d5d03be29e9dd309b3be",
          "company" => "Plex",
          "location" => "San Francisco",
          "blog" => "http://arko.net",
          "contributions" => 8,
          "type" => "User",
          "login" => "indirect",
          "email" => "andre.arko@gmail.com"
        },
        {
          "name" => "Sproutit/SproutCore",
          "gravatar_id" => "c6b2ee26a74ce837d5973b81888d4ea8",
          "location" => "Los Altos, CA",
          "blog" => "http://www.sproutcore.com",
          "contributions" => 8,
          "type" => "Organization",
          "login" => "sproutit",
          "email" => "contact@sproutcore.com"
        },
        {
          "name" => "Luis Lavena",
          "gravatar_id" => "e7cff3cfd41c495e1012227d7dc24202",
          "company" => "Multimedia systems",
          "location" => "Tucuman, Argentina",
          "blog" => "http://blog.mmediasys.com",
          "contributions" => 7,
          "type" => "User",
          "login" => "luislavena",
          "email" => "luislavena@gmail.com"
        },
        {
          "name" => "Sam Merritt",
          "gravatar_id" => "f31901d97286576f0d6a939309afabad",
          "blog" => "http://torgomatic.blogspot.com/",
          "contributions" => 4,
          "type" => "User",
          "login" => "smerritt",
          "email" => ""
        },
        {
          "name" => "Andy Delcambre",
          "gravatar_id" => "548ebc3ff174526b6d10fb63f1b7f087",
          "company" => "Engine Yard",
          "location" => "San Francisco, CA",
          "blog" => "http://andy.delcambre.com/",
          "contributions" => 3,
          "type" => "User",
          "login" => "adelcambre",
          "email" => "adelcambre@gmail.com"
        },
        {
          "name" => "Cory Flanigan",
          "gravatar_id" => "b0f73c0eb23d2569d806bebe728dbe83",
          "location" => "Toledo, OH",
          "blog" => "http://increaseyourgeek.wordpress.com/",
          "contributions" => 3,
          "type" => "User",
          "login" => "seeflanigan",
          "email" => "seeflanigan@gmail.com"
        },
        {
          "name" => "Dr Nic Williams",
          "gravatar_id" => "cb2b768a5e546b24052ea03334e43676",
          "company" => "Mocra http://mocra.com",
          "location" => "Brisbane, Australia",
          "blog" => "http://drnicwilliams.com",
          "contributions" => 3,
          "type" => "User",
          "login" => "drnic",
          "email" => "drnicwilliams@gmail.com"
        },
        {
          "name" => "Joshua Peek",
          "gravatar_id" => "bbe5dc8dcf248706525ab76f46185520",
          "company" => "37signals",
          "location" => "Chicago, IL",
          "blog" => "http://joshpeek.com/",
          "contributions" => 3,
          "type" => "User",
          "login" => "josh",
          "email" => "josh@joshpeek.com"
        },
        {
          "name" => "Geoff Garside",
          "gravatar_id" => "4dcfd2f7d671af330bcba3fe03277c71",
          "company" => "M247 Ltd",
          "location" => "Manchester, England",
          "blog" => "http://geoffgarside.co.uk/",
          "contributions" => 2,
          "type" => "User",
          "login" => "geoffgarside",
          "email" => "geoff@geoffgarside.co.uk"
        },
        {
          "name" => "jack dempsey",
          "gravatar_id" => "1ccb5123d1af92e24b32cec62abcf9a8",
          "company" => "Jack Dempsey LLC",
          "location" => "Washington, DC",
          "blog" => "http://jackndempsey.me",
          "contributions" => 2,
          "type" => "User",
          "login" => "jackdempsey",
          "email" => "jack.dempsey@gmail.com"
        },
        {
          "gravatar_id" => "ae49abffb2729fcaa26577535b34fdc0",
          "contributions" => 2,
          "type" => "User",
          "login" => "rheimbuch"
        },
        {
          "gravatar_id" => "55d9de203647686bd5cc91b2c979c066",
          "contributions" => 1,
          "type" => "User",
          "login" => "bappelt"
        },
        {
          "name" => "Joshua Hull",
          "gravatar_id" => "c7e2ce5b40f683dfb6c1bdf5e6af0c72",
          "contributions" => 1,
          "type" => "User",
          "login" => "joshbuddy",
          "email" => "joshbuddy@gmail.com"
        },
        {
          "name" => "Damian Janowski",
          "gravatar_id" => "ffd012d72e7f61639724878825ed25a3",
          "company" => "Citrusbyte",
          "location" => "Buenos Aires, Argentina",
          "contributions" => 1,
          "type" => "User",
          "login" => "djanowski"
        },
        {
          "name" => "Gabriel Horner",
          "gravatar_id" => "8f0660cdc9f5d91c7d97456f8f0be8c7",
          "company" => "self-employed",
          "location" => "Gainesville, FL",
          "blog" => "http://tagaholic.me",
          "contributions" => 1,
          "type" => "User",
          "login" => "cldwalker"
        },
        {
          "name" => "Tyler Hunt",
          "gravatar_id" => "625cb1796316a98d3bbe205a040035c3",
          "company" => "Devoh",
          "location" => "Orlando, FL",
          "blog" => "http://devoh.com/",
          "contributions" => 1,
          "type" => "User",
          "login" => "tylerhunt"
        }
      ]
    }

    @repo = Github::Repo.new('wycats/thor')
  end

  context "smooth sailing" do
    before(:each) do
      FakeWeb.register_uri(:get,
        'http://github.com/api/v2/json/repos/show/wycats/thor/contributors',
        :body => @contributors.to_json)
    end

    it "figures out the usernames" do
      @repo.users.should include(Github::User.new('josevalim'))
      @repo.users.should include(Github::User.new('seeflanigan'))
      @repo.users.should include(Github::User.new('smerritt'))
      @repo.users.should include(Github::User.new('wycats'))
    end
  end

  context "when the rate limiter or other gremlin strikes" do
    before(:each) do
      class << @repo
        def sleep(*) nil end  # there's no need to really sleep in tests
      end
    end

    context "a small number of times" do
      before(:each) do
        FakeWeb.register_uri(:get,
          'http://github.com/api/v2/json/repos/show/wycats/thor/contributors',
          [{
              :body => {"error" => "Unauthorized"}.to_json, # guessing
              :status => ["401", "Unauthorized"],
            }, {
              :exception => Errno::ETIMEDOUT,
            }, {
              :body => @contributors.to_json,
            }])
      end

      it "retries some times" do
        lambda { @repo.users }.should_not raise_error
      end

      it "still works" do
        @repo.users.should include(Github::User.new('josevalim'))
      end
    end

    context "a large number of times" do
      before(:each) do
        FakeWeb.register_uri(:get,
          'http://github.com/api/v2/json/repos/show/wycats/thor/contributors',
          [{
              :body => {"error" => "Unauthorized"}.to_json, # guessing
              :status => ["401", "Unauthorized"],
            }])
      end

      it "gives up eventually" do
        lambda { @repo.users }.should raise_error(RestClient::Unauthorized)
      end
    end

  end
end
