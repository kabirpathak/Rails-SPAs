# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  gem "rails", "7.1.3.4"
  gem "sqlite3", "~> 1.4"
end

require "active_record"
require "minitest/autorun"
require "logger"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
  end

  create_table :comments, force: true do |t|
    t.integer :post_id
    t.string :name
  end
end

class Post < ActiveRecord::Base
  # Scenario 1
  # has_one :comment, validate: true, autosave: true
  # Scenario 2
  # has_one :comment, validate: true, autosave: true
  # Scenario 3
  has_one :comment, validate: true, autosave: false
end

class Comment < ActiveRecord::Base
  belongs_to :post
  validates :name, presence: true
end

class Post2 < Post
  # Scenario 1
  # has_one :comment, class_name: "Comment2", foreign_key: :post_id
  # Scenario 2
  # has_one :comment, class_name: "Comment2", foreign_key: :post_id, validate: false, autosave: false
  # Scenario 3
  has_one :comment, class_name: "Comment2", foreign_key: :post_id, validate: true, autosave: true
end

class Comment2 < Comment
  belongs_to :post, class_name: "Post2", foreign_key: :post_id
end

class BugTest < Minitest::Test
  def test_association_validations_in_parent
    # Scenario 1: Passes
    # Scenario 2: Passes
    # Scenario 3: Fails

    post = Post.build
    post.build_comment

    refute post.valid?
    refute post.comment.valid?
    assert_equal "Comment name can't be blank", post.errors.first.full_message
    assert_equal 0, Comment.count
  end

  def test_association_validations_in_subclass
    # Scenario 1: Passes
    # Scenario 2: Passes
    # Scenario 3: Fails
    post = Post2.build
    post.build_comment

    refute post.valid?
    refute post.comment.valid?
    assert_equal "Comment name can't be blank", post.errors.first.full_message
    assert_equal 0, Comment.count
  end
end