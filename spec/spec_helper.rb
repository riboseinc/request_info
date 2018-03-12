# (c) 2018 Ribose Inc.
#
#

require "simplecov"
SimpleCov.start

require "bundler"
Bundler.require :default, :development

Dir[File.expand_path "../support/**/*.rb", __FILE__].sort.each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.include_context "test stack"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
