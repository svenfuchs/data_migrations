require 'test_helper'

class DataMigrationsTest < Test::Unit::TestCase
  test 'migrate_table instantiates a migration and executes it' do
    ActiveRecord::Base.connection.stubs(:execute)

    output = capture_stdout do
      Class.new(ActiveRecord::Migration) do
        migrate_table(:builds, :to => :tests) { |t| t.copy :status }
      end
    end

    assert_equal 'Executing: INSERT INTO "tests" SELECT "status" FROM "builds" AS t("status" integer)', output.strip
  end
end
