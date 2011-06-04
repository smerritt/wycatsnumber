require 'resque/tasks'

begin
  desc 'Default: run spec examples'
  task :default => :spec

  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = %w(-fs --color)
    t.pattern = "spec/**/*_spec.rb"
  end
rescue LoadError
end

namespace :resque do
  task :setup do
    $LOAD_PATH.unshift(File.dirname(__FILE__))
    $LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'app'))
    require 'wycatsnumber'
  end
end

task :kickoff => 'resque:setup' do
  Resque.enqueue(WalkRepo, 'rails/rails')
end

task :refresh => 'resque:setup' do
  Author.needs_fetch.each do |author|
    Resque.enqueue(WalkUser, author.github_username)
  end

  Project.needs_fetch.each do |project|
    Resque.enqueue(WalkProject, project.name)
  end
end

namespace :db do
  task :migrate => 'resque:setup' do
    # hokey, but good enough for now
    DataMapper.auto_upgrade!
  end
end


def db_clj_for(env)
  require 'yaml'
  dbinfo = YAML.load_file('config/database.yml')[env]

  [
    ";; autogenerated by rake; edits will be lost",
    "(ns org.andcheese.wycatsnumber.db)",
    "(def connection {",
    # XXX hardcoded postgres
    ":classname \"org.postgresql.Driver\"",
    ":subprotocol \"postgresql\"",
    ":subname \"//#{dbinfo['host']}:5432/#{dbinfo['database']}\"",
    ":user \"#{dbinfo['user']}\"",
    ":password \"#{dbinfo['password']}\"",
    "})",
  ].join("\n")

end

desc "set up db.clj for ENV (reads config/database.yml)"
task :db_clj, :env do |t, args|
  File.open("src/org/andcheese/wycatsnumber/db.clj", "w") do |fh|
    fh.write db_clj_for(args[:env])
  end
end

desc "Build a (uber)war file for ENV (reads config/database.yml)"
task :uberwar, :env do |t, args|
  Rake::Task[:db_clj].invoke(args[:env])
  system("lein ring uberwar")
end
