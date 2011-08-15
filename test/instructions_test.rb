require 'test_helper'

class InstructionsTest < Test::Unit::TestCase
  test 'copy: generates an INSERT INTO ... SELECT FROM statement (for a single column)' do
    statements = migrate_table_statements { |t| t.copy :commit }
    assert_equal 'UPDATE "tasks" SET "id" = source."id", "commit" = source."commit" FROM (SELECT "id", "commit" FROM "builds" WHERE "builds".id IN (SELECT id FROM "tasks")) AS source WHERE "tasks".id = source.id', statements.first
    assert_equal 'INSERT INTO "tasks" ("id", "commit") SELECT "id", "commit" FROM "builds" WHERE "builds".id NOT IN (SELECT id FROM "tasks")', statements.second
  end

  test 'copy: generates an INSERT INTO ... SELECT FROM statement (for a multiple columns)' do
    statements = migrate_table_statements { |t| t.copy :parent_id, :commit, :status }
    assert_equal 'UPDATE "tasks" SET "id" = source."id", "parent_id" = source."parent_id", "commit" = source."commit", "status" = source."status" FROM (SELECT "id", "parent_id", "commit", "status" FROM "builds" WHERE "builds".id IN (SELECT id FROM "tasks")) AS source WHERE "tasks".id = source.id', statements.first
    assert_equal 'INSERT INTO "tasks" ("id", "parent_id", "commit", "status") SELECT "id", "parent_id", "commit", "status" FROM "builds" WHERE "builds".id NOT IN (SELECT id FROM "tasks")', statements.second
  end

  test 'copy: aliases column names if specified (for a single column)' do
    statements = migrate_table_statements { |t| t.copy :commit, :to => :hash }
    assert_equal 'UPDATE "tasks" SET "id" = source."id", "hash" = source."commit" FROM (SELECT "id", "commit" FROM "builds" WHERE "builds".id IN (SELECT id FROM "tasks")) AS source WHERE "tasks".id = source.id', statements.first
    assert_equal 'INSERT INTO "tasks" ("id", "hash") SELECT "id", "commit" AS "hash" FROM "builds" WHERE "builds".id NOT IN (SELECT id FROM "tasks")', statements.second
  end

  test 'copy: aliases column names if specified (for a multiple columns)' do
    statements = migrate_table_statements { |t| t.copy :parent_id, :commit, :status, :to => [:owner_id, :hash, :result] }
    assert_equal 'UPDATE "tasks" SET "id" = source."id", "owner_id" = source."parent_id", "hash" = source."commit", "result" = source."status" FROM (SELECT "id", "parent_id", "commit", "status" FROM "builds" WHERE "builds".id IN (SELECT id FROM "tasks")) AS source WHERE "tasks".id = source.id', statements.first
    assert_equal 'INSERT INTO "tasks" ("id", "owner_id", "hash", "result") SELECT "id", "parent_id" AS "owner_id", "commit" AS "hash", "status" AS "result" FROM "builds" WHERE "builds".id NOT IN (SELECT id FROM "tasks")', statements.second
  end

  test 'copy: includes a condition if given' do
    statements = migrate_table_statements { |t| t.where 'status = 1'; t.copy :commit }
    assert_equal 'UPDATE "tasks" SET "id" = source."id", "commit" = source."commit" FROM (SELECT "id", "commit" FROM "builds" WHERE "builds".id IN (SELECT id FROM "tasks") AND status = 1) AS source WHERE "tasks".id = source.id', statements.first
    assert_equal 'INSERT INTO "tasks" ("id", "commit") SELECT "id", "commit" FROM "builds" WHERE "builds".id NOT IN (SELECT id FROM "tasks") AND status = 1', statements.second
  end

  test 'copy: using :all columns' do
    statements = migrate_table_statements { |t| t.copy :all }
    assert_equal 'UPDATE "tasks" SET "id" = source."id", "parent_id" = source."parent_id", "status" = source."status", "commit" = source."commit" FROM (SELECT "id", "parent_id", "status", "commit" FROM "builds" WHERE "builds".id IN (SELECT id FROM "tasks")) AS source WHERE "tasks".id = source.id', statements.first
    assert_equal 'INSERT INTO "tasks" ("id", "parent_id", "status", "commit") SELECT "id", "parent_id", "status", "commit" FROM "builds" WHERE "builds".id NOT IN (SELECT id FROM "tasks")', statements.second
  end

  test 'copy: using :all columns with :except given as a symbol' do
    statements = migrate_table_statements { |t| t.copy :all, :except => :parent_id }
    assert_equal 'UPDATE "tasks" SET "id" = source."id", "status" = source."status", "commit" = source."commit" FROM (SELECT "id", "status", "commit" FROM "builds" WHERE "builds".id IN (SELECT id FROM "tasks")) AS source WHERE "tasks".id = source.id', statements.first
    assert_equal 'INSERT INTO "tasks" ("id", "status", "commit") SELECT "id", "status", "commit" FROM "builds" WHERE "builds".id NOT IN (SELECT id FROM "tasks")', statements.second
  end

  test 'copy: using :all columns with :except given as an array' do
    statements = migrate_table_statements { |t| t.copy :all, :except => [:id, :parent_id] }
    assert_equal 'UPDATE "tasks" SET "status" = source."status", "commit" = source."commit" FROM (SELECT "status", "commit" FROM "builds" WHERE "builds".id IN (SELECT id FROM "tasks")) AS source WHERE "tasks".id = source.id', statements.first
    assert_equal 'INSERT INTO "tasks" ("status", "commit") SELECT "status", "commit" FROM "builds" WHERE "builds".id NOT IN (SELECT id FROM "tasks")', statements.second
  end

  test 'copy: using :all columns with instructions for some columns already being defined' do
    statements = migrate_table_statements { |t| t.copy :parent_id; t.copy :status; t.copy :all }
    assert_equal 'UPDATE "tasks" SET "id" = source."id", "commit" = source."commit" FROM (SELECT "id", "commit" FROM "builds" WHERE "builds".id IN (SELECT id FROM "tasks")) AS source WHERE "tasks".id = source.id', statements.first
    assert_equal 'INSERT INTO "tasks" ("id", "commit") SELECT "id", "commit" FROM "builds" WHERE "builds".id NOT IN (SELECT id FROM "tasks")', statements.second
  end

  test 'move: drops the columns after copying them (for a single column)' do
    statements = migrate_table_statements { |t| t.move :commit }
    assert_equal 'ALTER TABLE "builds" DROP COLUMN "commit"', statements.first
  end

  test 'move: drops the columns after copying them (for a single column, with aliases)' do
    statements = migrate_table_statements { |t| t.move :commit, :to => :hash }
    assert_equal 'ALTER TABLE "builds" DROP COLUMN "commit"', statements.first
  end

  test 'move: drops the columns after copying them (for multiple columns)' do
    statements = migrate_table_statements { |t| t.move :parent_id, :commit, :status }
    [:parent_id, :commit, :status].each_with_index do |column, ix|
      assert_equal %(ALTER TABLE "builds" DROP COLUMN "#{column}"), statements[ix]
    end
  end

  test 'move: drops the columns after copying them (for multiple columns, with aliases)' do
    statements = migrate_table_statements { |t| t.move :parent_id, :commit, :status, :to => [:status, :result, :owner_id] }
    [:parent_id, :commit, :status].each_with_index do |column, ix|
      assert_equal %(ALTER TABLE "builds" DROP COLUMN "#{column}"), statements[ix]
    end
  end

  test 'set: sets the target column to the given string value' do
    statements = migrate_table_statements { |t| t.set :hash, 'abcd' }
    assert_equal %(UPDATE "tasks" SET "hash" = 'abcd'), statements.first
  end

  test 'set: sets the target column to the given integer value' do
    statements = migrate_table_statements { |t| t.set :result, 1 }
    assert_equal %(UPDATE "tasks" SET "result" = 1), statements.first
  end

  test 'exec: executes the given sql' do
    sql = 'UPDATE foo SET bar = 1'
    assert_equal sql, migrate_table_statements { |t| t.exec sql }.first
  end
end
