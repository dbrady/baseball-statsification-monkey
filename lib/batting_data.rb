require_relative 'batter'
require_relative 'patches'

# Stats aggregation/integration class
class BattingData

  attr_reader :player_id, :player, :year, :league, :team, :games,
              :at_bats, :runs, :hits, :doubles, :triples, :home_runs,
              :runs_batted_in, :stolen_bases, :caught_stealing

  private_attr_writer :player_id, :player, :year, :league, :team,
                      :games, :at_bats, :runs, :hits, :doubles,
                      :triples, :home_runs, :runs_batted_in,
                      :stolen_bases, :caught_stealing

  def initialize(data={})
    @player_id = data.fetch(:player_id)
    @player = Batter.find(id: player_id)
    @year = data[:year].to_i
    @league, @team = data[:league], data[:team]

    integrable_stats.each {|key| send "#{key}=", data[key].to_i }
  end

  def integrable_stats
    [
     :games, :at_bats, :runs, :hits, :doubles, :triples, :home_runs,
     :runs_batted_in, :stolen_bases, :caught_stealing
    ]
  end

  def batting_average
    return 0.0 unless at_bats > 0
    hits / at_bats.to_f
  end

  def slugging_percentage
    return 0.0 unless at_bats > 0
    bases_advanced / at_bats.to_f
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
    sums = integrable_stats.each_with_object({}) {|key, hash|
      hash[key] = send(key) + other.send(key)
    }

    BattingData.new(ors.merge sums)
  end

  private

  def bases_advanced
    singles + 2*doubles + 3*triples + 4*home_runs
  end

  def singles
    hits - (doubles + triples + home_runs)
  end
end
