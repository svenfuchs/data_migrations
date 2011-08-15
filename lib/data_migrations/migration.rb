module DataMigrations
  class Migration
    attr_reader :source, :target, :instructions

    def initialize(source, options = {})
      @source = Table.new(source)
      @target = Table.new(options[:to])
      @instructions = []

      yield self
    end

    def run!
      instructions.each(&:execute)
    end

    def condition(condition = nil)
      condition ? @condition = condition : @condition
    end
    alias :where :condition

    def copy(*args)
      instructions << Instruction::Copy.new(self, *args)
    end

    def move(*args)
      copy(*args)
      instructions << Instruction::Remove.new(self, *args)
    end

    def set(*args)
      instructions << Instruction::Set.new(self, *args)
    end

    def exec(*args)
      instructions << Instruction::Exec.new(self, *args)
    end
  end
end
