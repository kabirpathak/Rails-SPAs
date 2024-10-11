require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  gem "rails", path: '../rails'
  # If you want to test against edge Rails replace the previous line with this:
  # gem "rails", github: "rails/rails", branch: "main"

  gem "sqlite3", "~> 1.4"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :lineups, force: true do |t|
  end

  create_table :arena_requests, force: true do |t|
    t.integer :lineup_id
  end

  create_table :challengers, force: true do |t|
    t.integer :lineup_id
    t.integer :challenge_id
  end

  create_table :challenges, force: true do |t|
    t.boolean :arena
  end
end

class Lineup < ActiveRecord::Base
  has_many :challengers

  has_many :arena_challengers, -> { arena }, class_name: 'Challenger'  # works
  has_one :arena_challenger, -> { arena }, class_name: 'Challenger'  # works

  has_many :arena_challengers_no_merge, -> { arena_no_merge }, class_name: 'Challenger' 
  has_one :arena_challenger_no_merge, -> { arena_no_merge }, class_name: 'Challenger' 
end

class Challenger < ActiveRecord::Base
  belongs_to :lineup, optional: true
  belongs_to :challenge

  scope :arena, -> { joins(:challenge).merge(Challenge.arena) }
  scope :arena_no_merge, -> { joins(:challenge).where(challenges: { arena: true }) }
end

class Challenge < ActiveRecord::Base
  has_many :challengers

  scope :arena, -> { where(arena: true) }
end

# ArenaRequest -> Lineup -> Challengers (+ join Challenges)
class ArenaRequest < ActiveRecord::Base
  belongs_to :lineup

  has_many :arena_challengers, through: :lineup, source: :arena_challengers # fails
  has_one :arena_challenger, through: :lineup # fails

  has_many :arena_challengers_no_merge, through: :lineup, source: :arena_challengers_no_merge # works
  has_one :arena_challenger_no_merge, through: :lineup # works
end

class BugTest < Minitest::Test

  ### Raise error with merge ### 

  def test_has_many_through_with_scope_merge
    lineup = Lineup.create!
    arena_request = ArenaRequest.create!(lineup:)
    challenge = Challenge.create!(arena: true)
    challenger = Challenger.create!(lineup:, challenge:)

    assert_equal [challenger], arena_request.arena_challengers
  end

  def test_has_one_through_with_scope_merge
    lineup = Lineup.create!
    arena_request = ArenaRequest.create!(lineup:)
    challenge = Challenge.create!(arena: true)
    challenger = Challenger.create!(lineup:, challenge:)

    assert_equal challenger, arena_request.arena_challenger
  end

  ### Works without merge ### 

  def test_has_many_through_with_scope_no_merge
    lineup = Lineup.create!
    arena_request = ArenaRequest.create!(lineup:)
    challenge = Challenge.create!(arena: true)
    challenger = Challenger.create!(lineup:, challenge:)

    assert_equal [challenger], arena_request.arena_challengers_no_merge
  end

  def test_has_one_through_with_scope_no_merge
    lineup = Lineup.create!
    arena_request = ArenaRequest.create!(lineup:)
    challenge = Challenge.create!(arena: true)
    challenger = Challenger.create!(lineup:, challenge:)

    assert_equal challenger, arena_request.arena_challenger_no_merge
  end

  ### Works without through ### 

  def test_has_many_with_scope_merge
    lineup = Lineup.create!
    challenge = Challenge.create!(arena: true)
    challenger = Challenger.create!(lineup:, challenge:)

    assert_equal [challenger], lineup.arena_challengers
  end

  def test_has_one_with_scope_merge
    lineup = Lineup.create!
    challenge = Challenge.create!(arena: true)
    challenger = Challenger.create!(lineup:, challenge:)

    assert_equal challenger, lineup.arena_challenger
  end
end