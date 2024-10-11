# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  # This works, version 7.2
  gem "rails", "~> 7.2"

  # This does not, version 8.0
  # gem "rails", github: "rails/rails"
gem "pry-rails"
  gem "pry"
  gem "sqlite3"
end

require "active_record"
require "minitest/autorun"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

class BugTest < Minitest::Test
  def test_stuff
    data = ActiveRecord::Base
        .connection
        .select_all("select 1 as id, 20 as age")
        .first

        binding.pry
      data = data.transform_values(&:to_f)
      OpenStruct.new(data)
  end
end