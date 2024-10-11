# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  gem "rails", github: "rails/rails", branch: "main"
  gem "sqlite3", "~> 1.4"
end

require "active_record"

ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
    t.string :title
  end
end

module MyConcern
  extend ActiveSupport::Concern

  included do
    def update_all(updates)
      puts 'kabir pathak'
    end
  end

  class_methods do
    def update_all(updates)
      puts 'kabir  2'
    end
  end
end

module CustomUpdateAll
  def self.update_all(updates)
    puts "custom method has run"
  end
end

# ActiveRecord::Relation.prepend(CustomUpdateAll) # this works

class Post < ActiveRecord::Base
  include MyConcern
end

Post.create(title: 'kabir')

puts "Post.where(id: nil).class: #{Post.where(id: nil).class}"
# => Post::ActiveRecord_Relation
Post.first.update_all(title: 'hello') # -> calls the instance method defined inside included block
Post.update_all(title: "hello")
Post.where(id: nil).update_all(title: "hello")