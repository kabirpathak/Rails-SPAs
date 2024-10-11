# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  gem "rails"
  # If you want to test against edge Rails replace the previous line with this:
  # gem "rails", github: "rails/rails", branch: "main"
end

require "active_model"
require "active_support"
require "active_support/core_ext/object/blank"
require "minitest/autorun"

class BugTest < Minitest::Test
  class TestModel
    include ::ActiveModel::Validations

    attr_accessor :position

    validates :position, numericality: { only_integer: true }

    def initialize(position)
      @position = position
    end
  end

  def test_stuff
    refute TestModel.new(4.0).valid?
    assert TestModel.new(4).valid?
    puts 4.eql?(4.0)
    assert_equal 4.class, 4.0.class
  end
end