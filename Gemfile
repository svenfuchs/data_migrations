source :rubygems

gemspec

group :development, :test do
  platforms :mri_18 do
    # required as linecache uses it but does not have it as a dep
    gem "require_relative", "~> 1.0.1"
    gem 'ruby-debug'
  end

  unless RUBY_VERSION == '1.9.3' && RUBY_PLATFORM !~ /darwin/
    # will need to install ruby-debug19 manually for 1.9.3:
    # gem install ruby-debug19 -- --with-ruby-include=$rvm_path/src/ruby-1.9.3-preview1
    gem 'ruby-debug19', :platforms => :mri_19
  end
end

