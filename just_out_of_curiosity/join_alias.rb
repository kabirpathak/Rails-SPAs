# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  gem "rails", path: "../rails"
    
  # If you want to test against edge Rails replace the previous line with this:
  # gem "rails", github: "rails/rails", branch: "main"
  gem "pry-byebug"
  gem "pry"
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
  end

  create_table :comments, force: true do |t|
    t.integer :post_id
  end
end

class Post < ActiveRecord::Base
  has_one :comment
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

class BugTest < Minitest::Test
  def test_association_stuff
    post = Post.create!
    post.create_comment!

    # -- OK --
    # INNER JOIN "comments" "comment" ON "comment"."post_id" = "posts"."id"
    # assert_equal [1], Post.joins(:comment).where(comment: { id: 1}).pluck(comment: [:id])

    # # -- NG --
    # # INNER JOIN "comments" ON "comments"."post_id" = "posts"."id"
    p Post.joins(:comment).pluck(comment: [:id]).to_sql
    binding.pry

    # assert_equal [1], Post.joins(:comment).merge(Comment.where(id: 1)).pluck(comment: [ :id ])
    # Post.joins(:comment).merge(Comment.where(id: 1)).to_sql
    Post.joins(:comment).merge(Comment.where(id: 1))

  end
end
