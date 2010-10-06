require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require

dbinfo = YAML.load(File.read(File.expand_path(File.join(File.dirname(__FILE__), "config", "database.yml"))))[ENV["RACK_ENV"] || 'development']

database_uri = "#{dbinfo['adapter']}://"

user = dbinfo['user']
pass = dbinfo['password']
host = dbinfo['host']

if user && pass && host
  database_uri << user << ':' << pass << '@' << host
elsif user && host
  database_uri << user << '@' << host
elsif host
  database_uri << host
end

database_uri << "/" << dbinfo['database']

DataMapper.setup(:default, database_uri)

require 'logger'
Log = ::Logger.new((ENV['RACK_ENV'] || 'development') + '-trace.log')

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'app/models'
require 'app/jobs'

endpoints_yaml = File.expand_path(File.join(File.dirname(__FILE__), 'config', 'endpoints.yml'))
if File.exist?(endpoints_yaml)
  Github::Fetcher.endpoints = YAML.load(File.read(endpoints_yaml))['endpoints']
end
