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
