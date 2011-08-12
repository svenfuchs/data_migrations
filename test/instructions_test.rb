require 'test_helper'

class InstructionsTest < Test::Unit::TestCase
  test 'copy: generates an INSERT INTO ... SELECT FROM statement (for a single column)' do
    statement = migrate_table_statements { |t| t.copy :commit }.first
    assert_equal 'INSERT INTO "tasks" ("commit") SELECT "commit" FROM "builds"', statement
  end

  test 'copy: generates an INSERT INTO ... SELECT FROM statement (for a multiple columns)' do
    statement = migrate_table_statements { |t| t.copy :parent_id, :commit, :status }.first
    assert_equal 'INSERT INTO "tasks" ("parent_id", "commit", "status") SELECT "parent_id", "commit", "status" FROM "builds"', statement
  end

  test 'copy: aliases column names if specified (for a single column)' do
    statement = migrate_table_statements { |t| t.copy :commit, :to => :hash }.first
    assert_equal 'INSERT INTO "tasks" ("hash") SELECT "commit" AS "hash" FROM "builds"', statement
  end

  test 'copy: aliases column names if specified (for a multiple columns)' do
    statement = migrate_table_statements { |t| t.copy :parent_id, :commit, :status, :to => [:owner_id, :hash, :result] }.first
    assert_equal 'INSERT INTO "tasks" ("owner_id", "hash", "result") SELECT "parent_id" AS "owner_id", "commit" AS "hash", "status" AS "result" FROM "builds"', statement
  end

  test 'copy: includes a condition if given' do
    statement = migrate_table_statements { |t| t.where 'status = 1'; t.copy :commit }.first
    assert_equal 'INSERT INTO "tasks" ("commit") SELECT "commit" FROM "builds" WHERE status = 1', statement
  end

  test 'copy: using :all columns' do
    statement = migrate_table_statements { |t| t.copy :all }.first
    assert_equal 'INSERT INTO "tasks" ("id", "parent_id", "status", "commit") SELECT "id", "parent_id", "status", "commit" FROM "builds"', statement
  end

  test 'copy: using :all columns with :except given as a symbol' do
    statement = migrate_table_statements { |t| t.copy :all, :except => :id }.first
    assert_equal 'INSERT INTO "tasks" ("parent_id", "status", "commit") SELECT "parent_id", "status", "commit" FROM "builds"', statement
  end

  test 'copy: using :all columns with :except given as an array' do
    statement = migrate_table_statements { |t| t.copy :all, :except => [:id, :parent_id] }.first
    assert_equal 'INSERT INTO "tasks" ("status", "commit") SELECT "status", "commit" FROM "builds"', statement
  end

  test 'copy: using :all columns with instructions for some columns already being defined' do
    statement = migrate_table_statements { |t| t.copy :parent_id; t.copy :status; t.copy :all }.first
    assert_equal 'INSERT INTO "tasks" ("id", "commit") SELECT "id", "commit" FROM "builds"', statement
  end

  test 'move: drops the columns after copying them (for a single column)' do
    statements = migrate_table_statements { |t| t.move :commit }
    assert_equal 'ALTER TABLE "builds" DROP COLUMN "commit"', statements[1]
  end

  test 'move: drops the columns after copying them (for a single column, with aliases)' do
    statements = migrate_table_statements { |t| t.move :commit, :to => :hash }
    assert_equal 'ALTER TABLE "builds" DROP COLUMN "commit"', statements[1]
  end

  test 'move: drops the columns after copying them (for multiple columns)' do
    statements = migrate_table_statements { |t| t.move :parent_id, :commit, :status }
    [:parent_id, :commit, :status].each_with_index do |column, ix|
      assert_equal %(ALTER TABLE "builds" DROP COLUMN "#{column}"), statements[ix + 1]
    end
  end

  test 'move: drops the columns after copying them (for multiple columns, with aliases)' do
    statements = migrate_table_statements { |t| t.move :parent_id, :commit, :status, :to => [:status, :result, :owner_id] }
    [:parent_id, :commit, :status].each_with_index do |column, ix|
      assert_equal %(ALTER TABLE "builds" DROP COLUMN "#{column}"), statements[ix + 1]
    end
  end

  test 'exec: executes the given sql' do
    sql = 'UPDATE foo SET bar = 1'
    assert_equal sql, migrate_table_statements { |t| t.exec sql }.first
  end
end
