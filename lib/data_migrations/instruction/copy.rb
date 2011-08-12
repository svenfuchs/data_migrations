module DataMigrations
  class Instruction
    class Copy < Base
      attr_reader :columns, :options

      def initialize(migration, *columns)
        super(migration)
        @options = columns.extract_options!
        @columns = normalize_columns(columns).map do |column, alias_|
          Column.new(migration.source, column, alias_)
        end
      end

      def statements
        [insert_statement]
      end

      protected

        def insert_statement
          statement = "INSERT INTO #{target.quoted_name} (#{alias_names})"
          statement << " SELECT #{aliased_column_names} FROM #{source.quoted_name}"
          statement << " WHERE #{condition}" if condition
          # statement << "AS t(#{column_definitions})"
          statement
        end

        def alias_names
          columns.map(&:quoted_alias_name).join(', ')
        end

        def aliased_column_names
          columns.map(&:aliased).join(', ')
        end

        def column_definitions
          columns.map(&:definition).join(', ')
        end

        def normalize_columns(columns)
          columns = columns.map(&:to_s)
          columns = source.column_names - instructed_columns if columns.include?('all')
          columns -= Array(options[:except]).map(&:to_s) if options[:except]
          columns.zip(Array(options.delete(:to)).map(&:to_s))
        end

        def instructed_columns
          migration.instructions.map(&:columns).flatten.map(&:name)
        end
    end
  end
end
