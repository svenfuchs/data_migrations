require 'rubygems'
require 'rake'
require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/all.rb'
  t.verbose = false
end

task :default => :test
