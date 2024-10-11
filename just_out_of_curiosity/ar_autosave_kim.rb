# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  # gem "rails"
  # If you want to test against edge Rails replace the previous line with this:
  gem "rails", github: "rails/rails", branch: "main"

  gem "sqlite3", "~> 1.4"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
  end

  create_table :comments, force: true do |t|
    t.integer :post_id
    t.string :name
  end
end

class Post < ActiveRecord::Base
  has_one :comment, validate: true, autosave: true
end

class Comment < ActiveRecord::Base
  belongs_to :post
  validates :name, presence: true
end

class Post2 < Post
  has_one :comment, class_name: "Comment2", foreign_key: :post_id
end

class Comment2 < Comment
  belongs_to :post, class_name: "Post2", foreign_key: :post_id
end

class BugTest < Minitest::Test
  def test_association_stuff
    post = Post.build
    post.build_comment

    refute post.valid?
    refute post.comment.valid?
    assert_equal "Comment name can't be blank", post.errors.first.full_message
    assert_equal 0, Comment.count
  end

  def test_association_stuff2
    post = Post2.build
    post.build_comment

    refute post.valid?
    refute post.comment.valid?
    assert_equal "Comment name can't be blank", post.errors.first.full_message
    assert_equal 0, Comment.count
  end
end