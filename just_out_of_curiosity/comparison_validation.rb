# frozen_string_literal: true

require "bundler/inline"
require "byebug"

gemfile(true) do
  source "https://rubygems.org"

  gem "rails", path: '../rails'
  # If you want to test against edge Rails replace the previous line with this:
  # gem "rails", github: "rails/rails", branch: "main"

  gem "sqlite3", "~> 1.4"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :positive_numbers, force: true do |t|
    t.integer :number
  end
end

class PositiveNumber < ActiveRecord::Base
  validates :number, presence: true, comparison: { greater_than: 0 }
end

class BugTest < Minitest::Test
  def test_association_stuff
    n = PositiveNumber.new()
    n.validate
    assert_equal ["can't be blank"], n.errors[:number]
  end
end
