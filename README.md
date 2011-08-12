# data\_migrations [![Build Status](https://secure.travis-ci.org/svenfuchs/data_migrations.png)](http://travis-ci.org/svenfuchs/data_migrations)

    class CreateBuilds < ActiveRecord::Migration
      def self.up
        create_table :tests do |t|
          # ...
        end

        migrate_table :builds, :to => :tests |t|
          t.where 'parent_id IS NULL'
          t.move :number
          t.copy :parent_id, :to => :build_id
          t.copy :commit, :result, :to => [:hash, :status]
          t.copy :all

          # t.copy :all, :except => :foo
          # t.exec 'UPDATE foo ...'
        end
      end

      def self.down
        # revert the whole thing. not sure we can derive this automatically?

        migrate_table :builds, :to => :tests |t|
          t.move :number
          t.copy :build_id, :to => :parent_id
          t.copy :hash, :status, :to => [:commit, :result]
        end

        drop_table :tests
      end
    end
