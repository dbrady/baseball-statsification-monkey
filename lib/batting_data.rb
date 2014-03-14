require_relative 'batter'

class BattingData
  attr_reader :player_id, :player, :year, :league, :team, :games, :at_bats, :runs, :hits, :doubles, :triples, :home_runs, :runs_batted_in, :stolen_bases, :caught_stealing

  def initialize(data={})
    @player_id = data.fetch(:player_id)
    @player = Batter.find_by_id(data.fetch(:player_id))

    @year, @league, @team = data[:year].to_i, data[:league], data[:team]

    @games, @at_bats, @runs, @hits, @doubles, @triples, @home_runs, @runs_batted_in, @stolen_bases, @caught_stealing = data[:games].to_i, data[:at_bats].to_i, data[:runs].to_i, data[:hits].to_i, data[:doubles].to_i, data[:triples].to_i, data[:home_runs].to_i, data[:runs_batted_in].to_i, data[:stolen_bases].to_i, data[:caught_stealing].to_i
  end

  def games; @games || 0; end
  def at_bats; @at_bats || 0; end
  def runs; @runs || 0; end
  def hits; @hits || 0; end
  def doubles; @doubles || 0; end
  def triples; @triples || 0; end
  def home_runs; @home_runs || 0; end
  def runs_batted_in; @runs_batted_in || 0; end
  def stolen_bases; @stolen_bases || 0; end
  def caught_stealing; @caught_stealing || 0; end

  def batting_average
    return 0.0 unless at_bats > 0
    hits / at_bats.to_f
  end

  def slugging_percentage
    return 0.0 unless at_bats > 0
    ((hits - (doubles+triples+home_runs)) + 2*doubles + 3*triples + 4*home_runs) / at_bats.to_f
  end

  # Add BattingData to another and return a new BattingData containing
  # the sums of the stats.
  def +(other)
    # It may seem odd to init player, year, league and team here, but we may
    # be adding a valid BattingData to a player's empty BattingData,
    # and if so we want to return the valid one.
    BattingData.new({
                      player_id: player_id || other.player_id,
                      player: player || other.player,
                      year: year || other.year,
                      league: league || other.league,
                      team: team || other.team,
                      games: games + other.games,
                      at_bats: at_bats + other.at_bats,
                      runs: runs + other.runs,
                      hits: hits + other.hits,
                      doubles: doubles + other.doubles,
                      triples: triples + other.triples,
                      home_runs: home_runs + other.home_runs,
                      runs_batted_in: runs_batted_in + other.runs_batted_in,
                      stolen_bases: stolen_bases + other.stolen_bases,
                      caught_stealing: caught_stealing + other.caught_stealing
                    })
  end
end
