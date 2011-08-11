module DataMigrations
  class Instruction
    class Copy < Instruction
      attr_reader :columns, :options

      def initialize(migration, *columns)
        super(migration)
        options = columns.extract_options!
        self.columns = columns.zip(Array(options[:to]))
      end

      def statements
        [insert_statement]
      end

      def insert_statement
        statement = "INSERT INTO #{target.quoted_name} SELECT #{aliased_column_names} FROM #{source.quoted_name} "
        statement << "WHERE #{condition} " if condition
        statement << "AS t(#{column_definitions})"
      end
    end
  end
end
