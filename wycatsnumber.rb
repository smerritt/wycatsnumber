require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require

dbinfo = YAML.load(File.read(File.expand_path(File.join(File.dirname(__FILE__), "config", "database.yml"))))[ENV["RACK_ENV"] || 'development']

database_uri = "%s://%s:%s@%s/%s" % [
  dbinfo['adapter'],
  dbinfo['user'],
  dbinfo['password'],
  dbinfo['host'],
  dbinfo['database'],
]

DataMapper.setup(:default, database_uri)

require 'logger'
Log = ::Logger.new((ENV['RACK_ENV'] || 'development') + '-trace.log')

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'app/models'
require 'app/jobs'
