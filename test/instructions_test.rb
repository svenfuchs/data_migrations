require 'test_helper'

class InstructionsTest < Test::Unit::TestCase
  test 'copy: generates an INSERT INTO ... SELECT FROM statement (for a single column)' do
    migration = migrate_table { |t| t.copy :commit }
    statement = migration.instructions.first.statements.first
    assert_equal 'INSERT INTO "tasks" SELECT "commit" FROM "builds" AS t("commit" character varying(255))', statement
  end

  test 'copy: generates an INSERT INTO ... SELECT FROM statement (for a multiple columns)' do
    migration = migrate_table { |t| t.copy :parent_id, :commit, :status }
    statement = migration.instructions.first.statements.first
    assert_equal 'INSERT INTO "tasks" SELECT "parent_id", "commit", "status" FROM "builds" AS t("parent_id" integer, "commit" character varying(255), "status" integer)', statement
  end

  test 'copy: aliases column names if specified (for a single column)' do
    migration = migrate_table { |t| t.copy :commit, :to => :hash }
    statement = migration.instructions.first.statements.first
    assert_equal 'INSERT INTO "tasks" SELECT "commit" AS "hash" FROM "builds" AS t("hash" character varying(255))', statement
  end

  test 'copy: aliases column names if specified (for a multiple columns)' do
    migration = migrate_table { |t| t.copy :parent_id, :commit, :status, :to => [:owner_id, :hash, :result] }
    statement = migration.instructions.first.statements.first
    assert_equal 'INSERT INTO "tasks" SELECT "parent_id" AS "owner_id", "commit" AS "hash", "status" AS "result" FROM "builds" AS t("owner_id" integer, "hash" character varying(255), "result" integer)', statement
  end

  test 'copy: includes a condition if given' do
    migration = migrate_table { |t| t.where 'status = 1'; t.copy :commit }
    statement = migration.instructions.first.statements.first
    assert_equal 'INSERT INTO "tasks" SELECT "commit" FROM "builds" WHERE status = 1 AS t("commit" character varying(255))', statement
  end

  test 'move: drops the columns after copying them (for a single column)' do
    migration = migrate_table { |t| t.move :commit }
    statement = migration.instructions.first.statements
    assert_equal 'ALTER TABLE "builds" DROP COLUMN "commit"', statement[1]
  end

  test 'move: drops the columns after copying them (for a single column, with aliases)' do
    migration = migrate_table { |t| t.move :commit, :to => :hash }
    statement = migration.instructions.first.statements
    assert_equal 'ALTER TABLE "builds" DROP COLUMN "commit"', statement[1]
  end

  test 'move: drops the columns after copying them (for multiple columns)' do
    migration = migrate_table { |t| t.move :parent_id, :commit, :status }
    statement = migration.instructions.first.statements
    [:parent_id, :commit, :status].each_with_index do |column, ix|
      assert_equal %(ALTER TABLE "builds" DROP COLUMN "#{column}"), statement[ix + 1]
    end
  end

  test 'move: drops the columns after copying them (for multiple columns, with aliases)' do
    migration = migrate_table { |t| t.move :parent_id, :commit, :status, :to => [:status, :result, :owner_id] }
    statement = migration.instructions.first.statements
    [:parent_id, :commit, :status].each_with_index do |column, ix|
      assert_equal %(ALTER TABLE "builds" DROP COLUMN "#{column}"), statement[ix + 1]
    end
  end

  test 'exec: executes the given sql' do
    sql = 'UPDATE foo SET bar = 1'
    migration = migrate_table { |t| t.exec sql }
    assert_equal sql, migration.instructions.first.statements.first
  end
end
