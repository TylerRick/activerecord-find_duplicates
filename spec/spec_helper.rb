require "bundler/setup"
require "activerecord/find_duplicates"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# Get this error with sqlite3:
#    ActiveRecord::StatementInvalid:
#       SQLite3::SQLException: near "*": syntax error: SELECT COUNT(*) AS count_all, "users"."email" AS users_email FROM "users" GROUP BY "users"."email" HAVING COUNT("users".*) >= 2
#ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
db_type = ENV["DB"].presence || "pg"
config = YAML.load_file(File.expand_path('../database.yml', __FILE__))[db_type]
ActiveRecord::Base.establish_connection config

ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :email
  end
end

class User < ActiveRecord::Base
end
