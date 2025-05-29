# frozen_string_literal: true
require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  # Activate the gem you are reporting the issue against.
  gem "activerecord", "8.0.2"
  gem "sqlite3"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new($stdout)

ActiveRecord::Schema.define do
  create_table "comments", force: :true do |t|
    t.integer "post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_comments_on_post_id"
  end

  create_table "posts", force: :true do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "comments", "posts"
end


class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class Post < ApplicationRecord
  has_many :comments

  validate :has_valid_comments

  def has_valid_comments
    comments.each do |c|
      # loops on comment
      # Should trigger an error if not included
    end
  end
end

class Comment < ApplicationRecord
  has_one :post
end


class StrictLoadingTestTest < Minitest::Test
  def setup
    Post.create!(comments: [Comment.create!, Comment.create!])
  end

  def test_strict_loading_instance
    post = Post.first
    post.strict_loading!
    assert_raises(ActiveRecord::StrictLoadingViolationError) do
      # Raises as expected
      post.comments.to_a
    end
  end

  def test_strict_loading_validation_should_raise
    post = Post.first
    post.strict_loading!
    assert_raises(ActiveRecord::StrictLoadingViolationError) do
      # Does not raise, but I'd expect to
      post.valid?
    end
  end

  def test_strict_loading_calling_the_validation_method_manually
    post = Post.first
    post.strict_loading!
    assert_raises(ActiveRecord::StrictLoadingViolationError) do
      # Raises as expected
      post.has_valid_comments
    end
  end
end
