require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require

module Wycatsnumber
  def self.database_config_for(env)
    dbconfig = load_config_yaml("database.yml")
    if dbconfig
      dbconfig[env]
    end
  end

  def self.database_uri
    env = ENV['RACK_ENV'] || 'development'
    dbinfo = database_config_for(env)

    unless dbinfo
      $stderr.puts "Warning: no database config for #{env} in config/database.yml."
    end

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

    database_uri
  end

  def self.load_config_yaml(filename)
    config_file = File.expand_path(
      File.join(File.dirname(__FILE__),
        "config",
        filename))

    YAML.load(File.read(config_file)) if File.exist?(config_file)
  end
end

DataMapper.setup(:default, Wycatsnumber.database_uri)

require 'logger'
Log = ::Logger.new((ENV['RACK_ENV'] || 'development') + '-trace.log')

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'app/models'
require 'app/jobs'

endpoints_yaml = File.expand_path(File.join(File.dirname(__FILE__), 'config', 'endpoints.yml'))
if File.exist?(endpoints_yaml)
  Github::Fetcher.endpoints = YAML.load(File.read(endpoints_yaml))['endpoints']
end
