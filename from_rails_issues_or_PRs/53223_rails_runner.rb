#!/usr/bin/env ruby

require_relative 'config/environment'

3.times do
  Rails.application.reloader.wrap do
    puts "Cache size: #{ActiveRecord::Base.connection.query_cache.size}"

    # Do any active record query here
    User.count
  end
end
