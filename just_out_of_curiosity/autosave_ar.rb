# frozen_string_literal: true

require 'bundler/inline'

gemfile(true) do
  source 'https://rubygems.org'

  gem 'rails', github: 'rails/rails', branch: 'main'
  gem 'sqlite3'
end

require 'active_record'
require 'minitest/autorun'

require "active_record"
require "minitest/autorun"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.text :title, default: ''
  end

  create_table :comments, force: true do |t|
    t.integer :post_id
    t.text :body, default: ''
  end
end

class Post < ActiveRecord::Base
  has_many :comments, autosave: true
end

class Comment < ActiveRecord::Base
  belongs_to :post
end

class AutosaveTest < Minitest::Test
  def test_without_autosave_feature
    post = Post.create(title: 'aaaa')
    post.comments.create(body: 'aaaa')

    post.title = 'bbbb'
    post.comments[0].body = 'bbbb'

    post.save

    assert_equal 'bbbb', post.reload.title
    assert_equal 'bbbb', post.comments[0].reload.body
  end
end
