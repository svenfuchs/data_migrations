# data\_migrations

    class CreateRepositories < ActiveRecord::Migration
      def self.up
        create_table :tests do |t|
          # ...
        end

        migrate_table :builds, :to => :tests |t|
          t.where 'parent_id IS NULL'
          t.move :number
          t.copy :result, :to => :status
          t.copy :commit, :result, :to => [:hash, :status]
          t.copy :all, :except => :foo
          t.exec 'UPDATE foo ...'
        end
      end

      def self.down
      end
    end
