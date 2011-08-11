module DataMigrations
  class Column
    attr_reader :table, :name, :alias

    def initialize(table, name, alias_)
      @table = table
      @name  = name
      @alias = alias_
    end

    def aliased
      self.alias ? "#{quote(name)} AS #{quote(self.alias)}" : quote(name)
    end

    def definition
      [quote(self.alias || name), type].join(' ')
    end

    def type
      column.sql_type
    end

    def column
      @column ||= table.column(name)
    end

    def quoted_name
      quote(name)
    end

    def quote(name)
      ActiveRecord::Base.connection.quote_column_name(name)
    end
  end
end
