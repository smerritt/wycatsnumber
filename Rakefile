desc 'Default: run spec examples'
task :default => :spec

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new do |t|
  t.spec_opts << %w(-fs --color)
  t.spec_files = Dir["spec/**/*_spec.rb"]
end
