module DataMigrations
  class Instruction
    class Remove < Base
      def initialize(migration, *columns)
        super(migration)
        self.options = columns.extract_options!
        self.columns = columns
      end

      def statements
        remove_statements
      end

      protected

        def remove_statements
          columns.map do |column|
            "ALTER TABLE #{source.quoted_name} DROP COLUMN #{column.quoted_name}"
          end
        end
    end
  end
end
