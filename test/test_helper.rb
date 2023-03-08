ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

DatabaseCleaner.allow_remote_database_url = true
DatabaseCleaner.strategy = :transaction

module AroundEachTest
  def before_setup
    super
    DatabaseCleaner.clean
    DatabaseCleaner.start
  end
end

class Minitest::Test
  include AroundEachTest
end

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  # parallelize(workers: :number_of_processors)

  # Add more helper methods to be used by all tests here...
end
