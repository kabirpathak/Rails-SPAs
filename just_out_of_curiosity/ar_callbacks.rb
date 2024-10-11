# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem "rails", github: "rails/rails", branch: "main"
  gem "sqlite3"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.string :name
  end

  create_table :comments, force: true do |t|
    t.integer :post_id
    t.string :name
  end
end

class Post < ActiveRecord::Base
  has_one :comment

  before_validation :before_validation_callback_post
  after_validation :after_validation_callback_post

  before_save :before_save_callback_post
  after_save :after_save_callback_post

  before_create :before_create_callback_post
  after_create :after_create_callback_post

  def before_validation_callback_post
    puts 'Post: before_validation_callback'
  end

  def after_validation_callback_post
    puts 'Post: after_validation_callback'
  end

  def before_save_callback_post
    puts 'Post: before_save_callback'
  end

  def after_save_callback_post
    puts 'Post: after_save_callback'
  end

  def before_create_callback_post
    puts 'Post: before_create_callback'
  end

  def after_create_callback_post
    puts 'Post: after_create_callback'
  end
end

class Comment < ActiveRecord::Base
  belongs_to :post

  accepts_nested_attributes_for :post

  before_validation :before_validation_callback_comment
  after_validation :after_validation_callback_comment

  before_save :before_save_callback_comment
  after_save :after_save_callback_comment

  before_create :before_create_callback_comment
  after_create :after_create_callback_comment

  def before_validation_callback_comment
    puts 'Comment: before_validation_callback'
  end

  def after_validation_callback_comment
    puts 'Comment: after_validation_callback'
  end

  def before_save_callback_comment
    puts 'Comment: before_save_callback'
  end

  def after_save_callback_comment
    puts 'Comment: after_save_callback'
  end

  def before_create_callback_comment
    puts 'Comment: before_create_callback'
  end

  def after_create_callback_comment
    puts 'Comment: after_create_callback'
  end
end

class BugTest < Minitest::Test
  def test_association_stuff
    Comment.create!(name: 'foo', post_attributes: {name: 'bar'})
  end
end