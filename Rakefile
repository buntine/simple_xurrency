# coding: utf-8
require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "simple_xurrency_buntine"
    gem.summary = "A really easy interface to the Xurrency API"
    gem.description = "A really easy interface to the Xurrency API. It's Ruby 1.8, 1.9 and JRuby compatible and has supoort for historical rates"
    gem.email = "info@andrewbuntine.com"
    gem.homepage = "http://github.com/buntine/simple_xurrency"
    gem.authors = ["Oriol Gual", "Josep M. Bach", "Josep Jaume Rey", "Alfonso Jimenez", "Andrew Buntine"]

    gem.add_dependency 'crack', ">= 0.1.8"

    gem.add_development_dependency "jeweler", '>= 1.4.0'
    gem.add_development_dependency "rspec", '>= 2.0.0.beta.20'
    gem.add_development_dependency "fakeweb", '>= 1.3.0'
    gem.add_development_dependency "bundler", '>= 1.0.0'
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

# Rake RSpec2 task stuff
gem 'rspec', '>= 2.0.0.beta.20'
gem 'rspec-expectations'

require 'rspec/core/rake_task'

desc "Run the specs under spec"
RSpec::Core::RakeTask.new do |t|
end

task :default => :spec
