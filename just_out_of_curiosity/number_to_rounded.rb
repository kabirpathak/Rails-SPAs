# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  # If you want to test against edge Rails replace the previous line with this:
  gem "rails", github: "rails/rails", branch: "main"
end

require "minitest/autorun"
require "action_view"

class BugTest < ActionView::TestCase

  def test_no_number_to_rounded
    render inline: <<~ERB
      <% include ActiveSupport::NumberHelper %>
      <p><%= number_to_rounded(10) %></p>
    ERB
  end
end
