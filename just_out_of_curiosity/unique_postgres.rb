# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  gem "rails"
  # If you want to test against edge Rails replace the previous line with this:
  # gem "rails", github: "rails/rails", branch: "main"

  gem "pg", "~> 1.1"
end

require "active_record"
require "minitest/autorun"
require "logger"

ActiveRecord::Base.establish_connection(adapter: "postgresql", database: "ar_enum_test")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_enum :providers, %i[one two], force: true

  create_table :organizations, force: true do |t|
    t.enum :provider, enum_type: :providers, null: false
    t.string :external_id, null: false
  end
end

class Organization < ActiveRecord::Base
  enum :provider, { one: 'one', two: 'two' }, validate: true

  validates :external_id, uniqueness: { scope: :provider }
end

class BugTest < Minitest::Test
  def test_enum_stuff
    org = Organization.new(provider: :three, external_id: '123')

    assert_equal false, org.valid?
  end
end