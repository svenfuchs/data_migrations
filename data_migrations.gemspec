# encoding: utf-8

$:.unshift File.expand_path('../lib', __FILE__)
require 'data_migrations/version'

Gem::Specification.new do |s|
  s.name         = "data_migrations"
  s.version      = DataMigrations::VERSION
  s.authors      = ["Sven Fuchs"]
  s.email        = "svenfuchs@artweb-design.de"
  s.homepage     = "https://github.com/svenfuchs/data_migrations"
  s.summary      = "[summary]"
  s.description  = "[description]"

  s.files        = Dir['{lib/**/*,[A-Z]*}']
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = '[none]'

  s.add_dependency 'rake'
  s.add_dependency 'activerecord'

  s.add_development_dependency 'test_declarative'
  s.add_development_dependency 'capture_stdout'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'pg'
end
