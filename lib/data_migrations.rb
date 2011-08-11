require 'active_record'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/array/extract_options'

module DataMigrations
  autoload :Column,      'data_migrations/column'
  autoload :Instruction, 'data_migrations/instruction'
  autoload :Migration,   'data_migrations/migration'
  autoload :Table,       'data_migrations/table'

  extend ActiveSupport::Concern

  module ClassMethods
    def migrate_table(name, options, &block)
      Migration.new(name, options, &block).run!
    end
  end

  ActiveRecord::Migration.send(:include, self)
end
