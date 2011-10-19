require 'rubygems'
require 'rake'

begin
  gem 'jeweler', '~> 1.6.4'
  require 'jeweler'

  Jeweler::Tasks.new do |gem|
    gem.name        = 'dm-validations'
    gem.summary     = 'Library for performing validations on DataMapper resources and plain Ruby objects'
    gem.description = gem.summary
    gem.email       = 'emmanuel.gomez@gmail.com'
    gem.homepage    = 'http://github.com/datamapper/%s' % gem.name
    gem.authors     = [ 'Guy van den Berg', 'Emmanuel Gomez' ]
    gem.has_rdoc    = 'yard'

    gem.rubyforge_project = 'datamapper'
  end

  Jeweler::GemcutterTasks.new

  FileList['tasks/**/*.rake'].each { |task| import task }
rescue LoadError
  puts 'Jeweler (or a dependency) not available. Install it with: gem install jeweler -v 1.6.4'
end
