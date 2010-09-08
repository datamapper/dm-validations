require 'rubygems'
require 'rake'

begin
  gem 'jeweler', '~> 1.4'
  require 'jeweler'

  Jeweler::Tasks.new do |gem|
    gem.name        = 'dm-validations'
    gem.summary     = 'Library for performing validations on DM models and pure Ruby object'
    gem.description = gem.summary
    gem.email       = 'vandenberg.guy [a] gmail [d] com'
    gem.homepage    = 'http://github.com/datamapper/%s' % gem.name
    gem.authors     = [ 'Guy van den Berg' ]
    gem.has_rdoc    = 'yard'

    gem.rubyforge_project = 'datamapper'

    gem.add_dependency 'dm-core', '~> 1.0.2'

    gem.add_development_dependency 'rspec',    '~> 1.3'
    gem.add_development_dependency 'dm-types', '~> 1.0.2'
  end

  Jeweler::GemcutterTasks.new

  FileList['tasks/**/*.rake'].each { |task| import task }
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler'
end
