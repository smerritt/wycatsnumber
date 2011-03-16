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
    require 'wycatsnumber'
  end
end

task :kickoff do
  require 'wycatsnumber'
  Resque.enqueue(WalkRepo, 'rails/rails')
end
