# -*- encoding: utf-8 -*-
require File.expand_path('../lib/data_mapper/validation/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors     = [ 'Guy van den Berg', 'Emmanuel Gomez' ]
  gem.email         = [ "emmanuel.gomez@gmail.com" ]
  gem.summary       = "Library for performing validations on DataMapper resources and plain Ruby objects"
  gem.description   = gem.summary
  gem.homepage      = "http://datamapper.org"

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {spec}/*`.split("\n")
  gem.extra_rdoc_files = %w[LICENSE README.rdoc]

  gem.name          = "dm-validations"
  gem.require_paths = [ "lib" ]
  gem.version       = DataMapper::Validation::VERSION

  gem.add_development_dependency('rake',  '~> 0.9.2')
  gem.add_development_dependency('rspec', '~> 1.3.2')
end
