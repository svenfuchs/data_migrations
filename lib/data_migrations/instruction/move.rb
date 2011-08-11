module DataMigrations
  class Instruction
    class Move < Copy
      def statements
        super + drop_statements
      end

      def drop_statements
        columns.map do |column|
          "ALTER TABLE #{source.quoted_name} DROP COLUMN #{column.quoted_name}"
        end
      end
    end
  end
end
