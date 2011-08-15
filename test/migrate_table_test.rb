require 'test_helper'

class MigrateTableTest < Test::Unit::TestCase
  def migration(&block)
    capture_stdout { Class.new(ActiveRecord::Migration, &block) }
  end

  test 'migrate_table instantiates a migration and executes it' do
    ActiveRecord::Base.connection.stubs(:execute)

    actual = migration { migrate_table(:builds, :to => :tasks) { |t| t.copy :status } }
    expected = 'Executing: UPDATE "tasks" SET "id" = source."id", "status" = source."status" FROM (SELECT "id", "status" FROM "builds" WHERE "builds".id IN (SELECT id FROM "tasks")) AS source WHERE "tasks".id = source.id' + "\n" +
      'Executing: INSERT INTO "tasks" ("id", "status") SELECT "id", "status" FROM "builds" WHERE "builds".id NOT IN (SELECT id FROM "tasks")'

    assert_equal expected, actual.strip
  end

  test 'copys a column' do
    Build.create!(:parent_id => 1, :commit => 'abcd', :status => 0)

    migration do
      create_table :tasks, :force => true do |t|
        t.string :commit
      end

      migrate_table(:builds, :to => :tasks) do |t|
        t.copy :commit
      end
    end

    assert_equal 'abcd', Task.first.commit
  end

  test 'moves a column' do
    Build.create!(:parent_id => 1, :commit => 'abcd', :status => 0)

    migration do
      create_table :tasks, :force => true do |t|
        t.string :commit
      end

      migrate_table(:builds, :to => :tasks) do |t|
        t.move :commit
      end
    end

    assert_equal 'abcd', Task.first.commit
    assert_equal({ 'id' => 1, 'parent_id' => 1, 'status' => 0 }, Build.first.attributes)
  end
end

