require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require

dbinfo = YAML.load(File.read(File.expand_path(File.join(File.dirname(__FILE__), "config", "database.yml"))))[ENV["RACK_ENV"] || 'development']

database_uri = "#{dbinfo['adapter']}://"
if user = dbinfo['user']
  database_uri << user
end
if password = dbinfo['password']
  database_uri << ":" << password
end
if host = dbinfo['host']
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
