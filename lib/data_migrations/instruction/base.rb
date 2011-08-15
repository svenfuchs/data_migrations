module DataMigrations
  class Instruction
    class Base
      attr_accessor :columns, :options

      delegate :connection, :to => :'ActiveRecord::Base'
      delegate :condition, :to => :migration

      attr_reader :migration

      def initialize(migration)
        @migration = migration
      end

      def columns=(columns)
        @columns = normalize_columns(columns).map do |column, alias_|
          Column.new(migration.source, column, alias_)
        end
      end

      def execute
        statements.each do |statement|
          puts "Executing: #{statement}"
          connection.execute(statement)
        end
      end

      protected

        def source
          migration.source
        end

        def target
          migration.target
        end

        def alias_names
          columns.map(&:quoted_alias_name).join(', ')
        end

        def alias_setters
          columns.map { |column| "#{column.quoted_alias_name} = source.#{column.quoted_name}" }.join(', ')
        end

        def quoted_column_names
          columns.map(&:quoted_name).join(', ')
        end

        def aliased_column_names
          columns.map(&:aliased_name).join(', ')
        end

        def column_definitions
          columns.map(&:definition).join(', ')
        end

        def normalize_columns(columns)
          columns = columns.map(&:to_s)
          columns = source.column_names - instructed_columns if columns.include?('all')
          columns -= Array(options[:except]).map(&:to_s) if options[:except]
          columns.zip(Array(options[:to]).map(&:to_s))
        end

        def instructed_columns
          migration.instructions.map(&:columns).flatten.map(&:name)
        end
    end
  end
end

