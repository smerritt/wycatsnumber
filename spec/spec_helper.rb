ENV["RACK_ENV"] = 'test'
require 'spec'
require 'wycatsnumber'
Bundler.setup(:test)
Bundler.require(:test)

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

Spec::Runner.configure do |config|
  config.include WN::TransactionalRunner
end

DataMapper.auto_migrate!
FakeWeb.allow_net_connect = false
