# Main Batboy Stats Reporting App
# This is the app-loading and startup lib file. You should be able to
# require 'batboy' and then do Batboy.new and get what you want.
require_relative "../patches/scoped_attr_accessors"
require_relative "stats_grinder"

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
  def report_most_improved_batter_in(year)
    from, to = year-1, year
    ostream.puts "Most improved batter #{from}->#{to}:"
    batter_name = stats_grinder.most_improved_batter(from, to)
    ostream.puts batter_name
  end
end
