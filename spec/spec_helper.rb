ENV["RACK_ENV"] = 'test'
require 'rspec'

require 'wycatsnumber'
Bundler.setup(:test)
Bundler.require(:test)

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

RSpec.configure do |config|
  config.include WN::TransactionalRunner

  config.after(:each) { FakeWeb.clean_registry }
end

DataMapper.auto_migrate!
FakeWeb.allow_net_connect = false

# don't care about the multiple endpoints in test mode, and it makes
# it really hard to use FakeWeb
Github::Fetcher.endpoints = ['http://github.com']
