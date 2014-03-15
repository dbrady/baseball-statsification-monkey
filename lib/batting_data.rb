require_relative 'batter'
require_relative 'patches'

# Stats aggregation/integration class
class BattingData
  attr_reader :player_id, :player, :year, :league, :team, :games, :at_bats, :runs, :hits, :doubles, :triples, :home_runs, :runs_batted_in, :stolen_bases, :caught_stealing
  private_attr_writer :player_id, :player, :year, :league, :team, :games, :at_bats, :runs, :hits, :doubles, :triples, :home_runs, :runs_batted_in, :stolen_bases, :caught_stealing

  def initialize(data={})
    @player_id = data.fetch(:player_id)
    @player = Batter.find_by_id(player_id)

    @league, @team = data[:league], data[:team]

    %i(year games at_bats runs hits doubles triples home_runs runs_batted_in stolen_bases caught_stealing).each {|key| send "#{key}=", data[key].to_i }
  end

  def batting_average
    return 0.0 unless at_bats > 0
    hits / at_bats.to_f
  end

  def slugging_percentage
    return 0.0 unless at_bats > 0
    (hits + doubles + 2*triples + 3*home_runs) / at_bats.to_f
  end

  # Add BattingData to another and return a new BattingData containing
  # the sums of the stats.
  def +(other)
    # It may seem odd to init player, year, league and team here, but we may
    # be adding a valid BattingData to a player's empty BattingData,
    # and if so we want to return the valid one.
    ors = %i(player_id player year league).each_with_object({}) {|key, hash|
      hash[key] = send(key) || other.send(key)
    }
    sums = %i(games at_bats runs hits doubles triples home_runs runs_batted_in stolen_bases caught_stealing).each_with_object({}) {|key, hash|
      hash[key] = send(key) + other.send(key)
    }

    BattingData.new(ors.merge sums)
  end
end
