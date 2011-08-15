module DataMigrations
  class Instruction
    class Set < Base
      attr_reader :column, :value

      def initialize(migration, column, value)
        super(migration)
        @column = Column.new(migration.target, column)
        @value  = value
      end

      def statements
        [update_statement]
      end

      protected

        def update_statement
          "UPDATE #{target.quoted_name} SET #{column.quoted_name} = #{column.quote_value(value)}"
        end
    end
  end
end
