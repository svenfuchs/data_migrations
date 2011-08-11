module DataMigrations
  class Instruction
    autoload :Copy, 'data_migrations/instruction/copy'
    autoload :Exec, 'data_migrations/instruction/exec'
    autoload :Move, 'data_migrations/instruction/move'

    delegate :connection, :to => :'ActiveRecord::Base'
    delegate :condition, :to => :migration

    attr_reader :migration

    def initialize(migration)
      @migration = migration
    end

    def execute
      statements.each do |statement|
        puts "Executing: #{statement}"
        connection.execute(statement)
      end
    end

    def source
      migration.source
    end

    def target
      migration.target
    end

    def columns=(columns)
      @columns = columns.map { |column, alias_| Column.new(migration.source, column, alias_) }
    end

    def aliased_column_names
      columns.map(&:aliased).join(', ')
    end

    def column_definitions
      columns.map(&:definition).join(', ')
    end
  end
end
