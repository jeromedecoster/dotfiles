
# adds the current direcory to the load path
root = File.expand_path '..', __FILE__
$:.unshift root unless $:.include? root

platform = RUBY_PLATFORM =~ /darwin/i ? 'osx' : 'win'
require "#{platform}/spec/spec_helper"

task :default => :test

desc 'Build support'
task :support do
  # force to rebuild the support directory
  support
end

desc 'Run tests'
task :test do
  # defines everything needed to execute tests
  setup
  # loads and executes all spec files
  Dir.glob("#{platform}/spec/**/*_spec.rb") { |f| require f }
end
