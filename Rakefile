require 'rubygems'
require 'bundler'
Bundler.setup

require 'rake'

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "indextank #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "indextank"
    gem.summary = %Q{Ruby wrapper for IndexTank}
    gem.description = %Q{Ruby wrapper for IndexTank}
    gem.email = "hone02@gmail.com"
    gem.homepage = "http://github.com/hone/indextank"
    gem.authors = ["Santiago Perez", "Terence Lee"]

    bundle = Bundler::Definition.build('Gemfile', 'Gemfile.lock', nil)
    bundle.dependencies.each do |dep|
      if dep.groups.include?(:development)
        gem.add_development_dependency(dep.name, dep.requirement.to_s)
      else
        gem.add_dependency(dep.name, dep.requirement.to_s)
      end
    end
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
  puts $!
end
