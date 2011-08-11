require 'active_record'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/array/extract_options'

module DataMigrations
  class Definition
    attr_reader :source, :target, :instructions

    def initialize(source, options = {})
      @source = Table.new(source)
      @target = Table.new(options[:to])
      @instructions = []

      yield self
    end

    def condition(condition = nil)
      condition ? @condition = condition : @condition
    end
    alias :where :condition

    def move(*columns)
      options = columns.extract_options!
      instructions << Move.new(self, columns, options)
    end

    def copy(*columns)
      options = columns.extract_options!
      instructions << Copy.new(self, columns, options)
    end

    def exec(sql)
      instructions << Exec.new(self, sql)
    end
  end

  class Table
    delegate :connection, :to => :'ActiveRecord::Base'

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def columns
      @columns ||= connection.columns(name)
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

  class Instruction
    delegate :connection, :to => :'ActiveRecord::Base'
    delegate :condition, :to => :definition

    attr_reader :definition

    def initialize(definition)
      @definition = definition
    end

    def execute
      statements.each { |statement| connection.execute(statement) }
    end

    def source
      definition.source
    end

    def target
      definition.target
    end

    def columns=(columns)
      @columns = columns.map { |column, alias_| Column.new(definition.source, column, alias_) }
    end

    def aliased_column_names
      columns.map(&:aliased).join(', ')
    end

    def column_definitions
      columns.map(&:definition).join(', ')
    end
  end

  class Copy < Instruction
    attr_reader :columns, :options

    def initialize(definition, columns, options)
      super(definition)
      self.columns = columns.zip(Array(options[:to]))
    end

    def statements
      [insert_statement]
    end

    def insert_statement
      statement = "INSERT INTO #{target.quoted_name} SELECT #{aliased_column_names} FROM #{source.quoted_name} "
      statement << "WHERE #{condition} " if condition
      statement << "AS t(#{column_definitions})"
    end
  end

  class Move < Copy
    def statements
      super + drop_statements
    end

    def drop_statements
      columns.map do |column|
        "ALTER TABLE #{source.quoted_name} DROP COLUMN #{column.quoted_name}"
      end
    end
  end

  def Runner
    attr_reader :definition

    def initialize(definition)
      @definition = definition
    end

    def run!
    end
  end
end
