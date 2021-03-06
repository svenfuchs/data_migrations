require 'logger'
require 'bundler/setup'
require 'test/unit'
require 'mocha'
require 'test_declarative'
require 'capture_stdout'
require 'data_migrations'

log = '/tmp/data_migrations.log'
FileUtils.touch(log) unless File.exists?(log)
ActiveRecord::Base.logger = Logger.new(log)

adapter = ENV['ADAPTER'] || 'postgresql'


config = begin
  configs = YAML.load_file(File.expand_path('../database.yml', __FILE__)).symbolize_keys
  configs[adapter.to_sym].symbolize_keys
rescue Errno::ENOENT => e
  { :adapter => 'postgresql', :database => 'data_migrations_test', :min_messages => 'warning' }
end

puts "Running tests against #{adapter}"
ActiveRecord::Base.establish_connection(config)
ActiveRecord::Migration.verbose = false



module TestHelpers
  def setup
    super
    rebuild_tables
  end

  def rebuild_tables
    ActiveRecord::Schema.define(:version => 1) do
      drop_table :builds rescue nil
      drop_table :tasks rescue nil

      create_table :builds, :force => true do |t|
        t.integer :parent_id
        t.integer :status
        t.string :commit
      end

      create_table :tasks, :force => true do |t|
        t.integer :owner_id
        t.integer :result
        t.string :hash
      end
    end
  end

  def migrate_table_statements(&block)
    migrate_table(&block).instructions.last.statements
  end

  def migrate_table(&block)
    DataMigrations::Migration.new(:builds, :to => :tasks, &block)
  end
end

Test::Unit::TestCase.send(:include, TestHelpers)

class Build < ActiveRecord::Base; end
class Task < ActiveRecord::Base; end
