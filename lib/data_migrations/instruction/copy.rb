module DataMigrations
  class Instruction
    class Copy < Base
      def initialize(migration, *columns)
        super(migration)
        self.options = columns.extract_options!
        options[:to] = [nil].concat(Array(options[:to]) || [])
        self.columns = ['id'].concat(columns)
      end

      def statements
        [update_statement, insert_statement]
      end

      protected

        def update_statement
          statement = "UPDATE #{target.quoted_name} SET #{alias_setters} FROM ("
          statement << "SELECT #{quoted_column_names} FROM #{source.quoted_name} "
          statement << "WHERE #{source.quoted_name}.id IN (SELECT id FROM #{target.quoted_name})"
          statement << " AND #{condition}" if condition
          statement << ") AS source WHERE #{target.quoted_name}.id = source.id"
          statement
        end

        def insert_statement
          statement = "INSERT INTO #{target.quoted_name} (#{alias_names}) "
          statement << "SELECT #{aliased_column_names} FROM #{source.quoted_name} "
          statement << "WHERE #{source.quoted_name}.id NOT IN (SELECT id FROM #{target.quoted_name})"
          statement << " AND #{condition}" if condition
          statement
        end

        def instructed_columns
          super - ['id']
        end
    end
  end
end
