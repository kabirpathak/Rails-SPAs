# frozen_string_literal: true

## NOTE: this file must be placed inside a Rails
## project for it to find the environment.rb file

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"
  gem "rails", path: "../rails"
    
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
    t.string :body
  end

  create_table :comments, force: true do |t|
    t.string :body
    t.references :parent, polymorphic: true
  end
end

class Post < ActiveRecord::Base
  has_many :comments, as: :parent
end

class Comment < ActiveRecord::Base
  belongs_to :parent, polymorphic: true
  has_many :comments, as: :parent
end

class BugTest < Minitest::Test
  def test_association_stuff
    post = Post.create(body: 'post')
    comment = post.comments.create(body: 'comment')
    nested_comment = comment.comments.create(body: 'nested comment')
    sql = Comment.includes(:comments).where(comments_comments: { body: 'nested comment' })
  end
end
