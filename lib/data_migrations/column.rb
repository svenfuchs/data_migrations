module DataMigrations
  class Column
    attr_reader :table, :name, :alias

    def initialize(table, name, alias_ = nil)
      @table = table
      @name  = name
      @alias = alias_
    end

    def definition
      [quoted_alias_name, type].join(' ')
    end

    def type
      column.sql_type
    end

    def column
      table.column(name)
    end

    def aliased_name
      self.alias.present? ? "#{quote(name)} AS #{quote(self.alias)}" : quote(name)
    end

    def quoted_name
      quote(name)
    end

    def quoted_alias_name
      quote(self.alias.present? ? self.alias : name)
    end

    def quote_value(value)
      table.connection.quote(value, column)
    end

    def quote(name)
      table.connection.quote_column_name(name)
    end

    def ==(other)
      name == other.name
    end
  end
end
