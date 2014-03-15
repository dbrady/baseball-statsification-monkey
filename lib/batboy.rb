require_relative "../patches/scoped_attr_accessors"
require_relative "stats_grinder"

# Main Batboy Stats Reporting App
# This is the app-loading and startup lib file. You should be able to
# require 'batboy' and then do Batboy.new and get what you want.
class Batboy
  private_attr_reader :ostream, :stats_grinder

  def initialize(ostream=$stdout, stats_grinder=StatsGrinder.new)
    @ostream = ostream
    @stats_grinder = stats_grinder
  end

  # Refactor me: do we want a factory here?
  # e.g.:
  # def self.build_batboy
  #   new($stdout,
  # StatsGrinder.new(StatsData.parse_csv("./data/Master-small.csv")))
  # etc

  def report_all_done
    ostream.puts "All done."
  end

  # refactor me: these will all have the same basic structure: display
  # caption, get answer, display answer or default
  # Note: StatsGrinder gives back nil or a batter name. There's no
  # reason for Batboy to have access to Batter objects yet.
  #
  # Refactor me: I don't like Batboy knowing that Batter has a
  # name, but the alternative is to have Batter know how to write its
  # name to a stream, e.g. batter.write_name_to(ostream). This is very
  # Smalltalk-y, and might improve testability. Will think some on
  # this.
  def report_most_improved_batter_in(year)
    from, to = year-1, year
    ostream.puts "Most improved batter #{from}->#{to}:"
    batter = stats_grinder.most_improved_batter(from, to)
    ostream.puts batter.name
    ostream.puts
  end

  def report_slugging_percentage_roster_for(team, year)
    ostream.puts "#{year} Slugging percentages for #{team}:"
    batters = stats_grinder.team_members_for_year(team, year)
    batters = batters.sort_by {|batter| -batter.stats_for_year(year).slugging_percentage }
    batters.each do |batter|
      ostream.puts "%20s: %6.3f" % [batter.name, batter.stats_for_year(year).slugging_percentage]
    end
    ostream.puts
  end

  def report_triple_crown_winner_in_league_for(league, year)
    ostream.puts "#{year} #{league} Triple Crown Winner:"
    if winner = stats_grinder.triple_crown_winner_in_league_for(league, year)
      ostream.puts winner.name
    else
      ostream.puts "(No winner)"
    end
  end
end
