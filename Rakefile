require 'resque/tasks'

desc 'Default: run spec examples'
task :default => :spec

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new do |t|
  t.spec_opts << %w(-fs --color)
  t.spec_files = Dir["spec/**/*_spec.rb"]
end

namespace :resque do
  task :setup do
    require 'wycatsnumber'
  end
end

task :kickoff do
  require 'wycatsnumber'
  wycats = Author.first_or_create(:github_username => 'wycats').update(:distance => 0)
  Resque.enqueue(WalkUser, 'wycats')
end
