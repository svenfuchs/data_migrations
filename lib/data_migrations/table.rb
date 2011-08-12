module DataMigrations
  class Table
    delegate :connection, :to => :'ActiveRecord::Base'

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def columns
      connection.columns(name)
    end

    def column_names
      columns.map(&:name)
    end

    def column(name)
      columns.detect { |column| column.name.to_s == name.to_s } || raise_column_not_found(name)
    end

    def quoted_name
      connection.quote_table_name(name)
    end

    def raise_column_not_found(name)
      raise "could not find column #{name} on #{self.name}"
    end
  end
end
