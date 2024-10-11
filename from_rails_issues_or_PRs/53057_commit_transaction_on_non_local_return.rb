# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  gem "rails", "~> 7.1.0"
  # If you want to test against edge Rails replace the previous line with this:
  # gem "rails", github: "rails/rails", branch: "main"

  gem "sqlite3"
  gem "pry"
  gem "pry-rails"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord.commit_transaction_on_non_local_return = false

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
  end
end

class Post < ActiveRecord::Base
end

class BugTest < Minitest::Test
  def test_association_stuff
    Post.transaction do
      Post.create!
      binding.pry
      return
    end
    binding.pry
    # => DEPRECATION WARNING: A transaction is being rolled back because the transaction block was
  end
end