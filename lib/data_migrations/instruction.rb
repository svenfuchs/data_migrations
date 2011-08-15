module DataMigrations
  class Instruction
    autoload :Base,   'data_migrations/instruction/base'
    autoload :Copy,   'data_migrations/instruction/copy'
    autoload :Exec,   'data_migrations/instruction/exec'
    autoload :Remove, 'data_migrations/instruction/remove'
    autoload :Set,    'data_migrations/instruction/set'
  end
end
