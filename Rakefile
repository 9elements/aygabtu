require "bundler/gem_tasks"

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.rspec_opts = "--exclude-pattern spec/_generated_spec.rb"
  end
rescue LoadError
end

task default: :spec

