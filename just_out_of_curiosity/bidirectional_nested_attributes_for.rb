$VERBOSE = nil
begin
    require "bundler/inline"
  rescue LoadError => e
    $stderr.puts "Bundler version 1.10 or later is required. Please update your Bundler"
    raise e
  end
  
  gemfile(true) do
    source "https://rubygems.org"
    gem "rails", "5.2.4.5"
    gem 'sqlite3'
  end
  
  require "active_record"
  require "minitest/autorun"
  require "logger"
  
  ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  
  ActiveRecord::Schema.define do
    create_table :posts do |t|
      t.string :title
    end
  
    create_table :comments do |t|
      t.integer :post_id
      t.string :body
    end
  end
  
  class Post < ActiveRecord::Base
    has_many :comments, inverse_of: :post
    accepts_nested_attributes_for :comments
  
    validates :title, presence: true
  end
  
  class Comment < ActiveRecord::Base
    belongs_to :post, inverse_of: :comments
    accepts_nested_attributes_for :post
    
    validates :body, presence: true
  end
  
  class BugTest < Minitest::Test
    # currently fails
    def test_invalid_attributes
      post = Post.new(title: 'foo', comments_attributes: [{body: 'bar'}, {body: nil}, {body: 'baz'}])

      refute post.valid?
      refute post.errors.empty?
    end
    
    # currently passes
    def test_invalid_attributes_end_of_list
      post = Post.new(title: 'foo', comments_attributes: [{body: 'bar'}, {body: 'baz'}, {body: nil}])

      post.errors.full_messages.each do |message|
        puts "- #{message}"
      end
      refute post.valid?
      refute post.errors.empty?
    end
    
    # currently passes
    def test_invalid_attributes_one_attribute
      post = Post.new(title: 'foo', comments_attributes: [{body: nil}])
      
      refute post.valid?
      refute post.errors.empty?
    end
  end
