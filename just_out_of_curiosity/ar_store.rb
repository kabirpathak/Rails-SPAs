# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  gem "rails", github: "rails/rails", branch: "main"
  gem "sqlite3"
end

require "active_record"
require "minitest/autorun"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.json :settings, default: {}
  end

  create_table :store_users, force: true do |t|
    t.text :settings, default: ''
  end
end

class User < ActiveRecord::Base
end

class StoreUser < ActiveRecord::Base
  store :settings, accessors: %i[color], coder: JSON
end

class BugTest < Minitest::Test
  def setup
    @user = User.create!(settings: { color: "red" })
    @store_user = StoreUser.create!(color: "red")
  end

  def test_search_by_json_column
    # This assertion passes
    assert_equal User.find_by("id = ? AND settings ->> 'color' = ?", @user.id, "red"), @user
    # This assertion fails
    assert_equal StoreUser.find_by("id = ? AND settings ->> 'color' = ?", @store_user.id, "red"), @store_user
  end

  def test_value_before_type_cast
    user_value_before_type_cast = @user.read_attribute_before_type_cast("settings")
    # => "{\"color\":\"red\"}"
    store_user_value_before_type_cast = @store_user.read_attribute_before_type_cast("settings")
    # => "\"{\\\"color\\\":\\\"red\\\"}\""

    # This assertion fails
    assert_equal user_value_before_type_cast, store_user_value_before_type_cast
  end
end