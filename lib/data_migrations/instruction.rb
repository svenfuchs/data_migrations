module DataMigrations
  class Instruction
    autoload :Base, 'data_migrations/instruction/base'
    autoload :Copy, 'data_migrations/instruction/copy'
    autoload :Exec, 'data_migrations/instruction/exec'
    autoload :Move, 'data_migrations/instruction/move'
  end
end
