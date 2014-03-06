require_relative "batter"

class StatsGrinder
  def most_improved_batter(from, to)
    Batter.first.name
    # Batter.valid_batters_in(from, to).max_by {|batter|
    #   batter.batting_average_in(to) - batter.batting_average_in(from)
    # }.name

    # Actually grind some stats!
    # - Get all players from year "from"
    # - Discard players with < 200 at-bats
    # - Get all players from year "to"
    # - Discard players with < 200 at-bats
    # - Discard non-intersecting players
    # - Get batting averages, then and now
    # - Sort players by diff
    # - Get name of most-improved batter

    # batter_name(valid_batters(batters_in(from) & batters_in(to)).max_by {|batter|
    #   batter.batting_average_in(to) - batter.batting_average_in(from)
    # })
  end

  private

  # def all_batters
  # end

  # def load_batting_data
  #   # Yuck, here we go
  #   @batters = {}

  # end

  # def batters_in(year)
  #   all_batters.select {|b| b.batted_in? year }
  # end

end
