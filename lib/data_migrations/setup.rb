module DataMigrations
  module Setup
    def setup_data_migrations
      unless @setup
        install_upsert
        @setup = true
      end
    end

    def install_upsert
      ActiveRecord::Base.connection.execute <<-sql
        CREATE FUNCTION upsert (sql_update TEXT, sql_insert TEXT)
            RETURNS VOID
            LANGUAGE plpgsql
        AS $$
        BEGIN
            LOOP
                -- first try to update
                EXECUTE sql_update;
                -- check if the row is found
                IF FOUND THEN
                    RETURN;
                END IF;
                -- not found so insert the row
                BEGIN
                    EXECUTE sql_insert;
                    RETURN;
                    EXCEPTION WHEN unique_violation THEN
                        -- do nothing and loop
                END;
            END LOOP;
        END;
        $$;
      sql
    rescue ActiveRecord::StatementInvalid
      # ignore duplicate installs
    end
  end
end
