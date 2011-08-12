module DataMigrations
  class Instruction
    class Base
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

      protected

        def source
          migration.source
        end

        def target
          migration.target
        end
    end
  end
end

