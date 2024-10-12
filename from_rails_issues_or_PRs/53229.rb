# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  # gem "rails"
  # If you want to test against edge Rails replace the previous line with this:
  gem "rails", github: "rails/rails", branch: "main"

  gem "sqlite3"
  gem "active_record_union"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
  end

  create_table :books, force: true do |t|
    t.integer :user_id
  end
end

class User < ActiveRecord::Base
  has_one :book
end

class Book < ActiveRecord::Base
  belongs_to :user
end

class BugTest < ActiveSupport::TestCase
  def test_association_stuff
    count = User.where(id: 1).union(User.where(id: 2)).includes(:book).merge(Book.where(id: 2)).references(:book).count(:all)
    assert_equal 0, User.where(id: 1).union(User.where(id: 2)).count(:all) # true
    assert_equal 0, count # throw exception
  end
end
