module DataMigrations
  class Instruction
    class Exec < Instruction
      attr_reader :statement

      def initialize(migration, statement)
        super(migration)
        @statement = statement
      end

      def statements
        [statement]
      end
    end
  end
end
