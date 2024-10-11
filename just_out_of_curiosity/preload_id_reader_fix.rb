# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem "rails"
  # If you want to test against edge Rails replace the previous line with this:
  # gem "rails", github: "rails/rails", branch: "main"

  gem "sqlite3", '~> 1.4'
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
  end
end

class Post < ActiveRecord::Base
  self.primary_key = [:id]
  has_many :comments
end

class Comment < ActiveRecord::Base
  self.primary_key = [:id]
  belongs_to :post
end

class BugTest < Minitest::Test
  def test_association_stuff
    post = Post.create!
    post.comments.create!

    assert_equal 1, post.comments.count
    assert_equal 1, Comment.count
    assert_equal post.id, Comment.take.post.id

    assert_equal Comment.ids, Post.take.comment_ids
    assert_equal Comment.ids, Post.preload(:comments).take.comment_ids
  end
end