require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"
  gem "rails"
  gem "sqlite3"
end

require "active_record"
require "minitest/autorun"
require "logger"

module Scopable
  extend ActiveSupport::Concern

  included do
    scope :active, -> { where(active: true) }

    def full_name
      name
    end
  end

  class_methods do
    def update_all(updates)
      puts "custom method has run"
    end

    def search_by_name(name)
      where("name LIKE ?", "#{name}%")
    end
  end
end

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

# Define the Product model with the Searchable concern included
class Product < ActiveRecord::Base
  include Scopable
end

# Migration to create the products table
ActiveRecord::Schema.define do
  create_table :products, force: true do |t|
    t.boolean :active
    t.string :name
  end
end

# Seed some data into the products table
Product.create(name: "Product 1", active: true)
Product.create(name: "Product 2", active: false)
Product.create(name: "Product 3", active: true)

# Minitest test case to demonstrate the usage of scopes
class ScopeTest < Minitest::Test
  def test_active_products
    active_products = Product.active
    assert_equal 2, active_products.count
    active_products.each do |product|
      assert product.active
    end
    assert_equal 3, Product.search_by_name('Product').count
    assert_equal Product.search_by_name('Product').last.full_name, 'Product 3'
    Product.update_all(name: 'k')
    puts '+' * 100
    Product.where(name: 'Product 1').update_all(name: 'k')
  end
end
