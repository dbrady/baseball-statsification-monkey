require_relative "batter_csv_reader"
require_relative "batting_csv_reader"
require_relative "batting_data"
require_relative "patches"

class Batter
  attr_reader :id, :last_name, :first_name
  private_attr_reader :batting_data

  def initialize(id, last_name, first_name)
    @id, @last_name, @first_name = id, last_name, first_name
    @batting_data = Hash.new do |hash, year|
      hash[year] = Hash.new do |hash2, league_id|
        hash2[league_id] = Hash.new do |hash3, team_id|
          hash3[team_id] = BattingData.new
        end
      end
    end
  end

  def name
    "%s %s" % [first_name, last_name]
  end

  def years
    batting_data.keys
  end

  # lifetime stats
  def games; all_batting_data_ever.games; end
  def at_bats; all_batting_data_ever.at_bats; end
  def runs; all_batting_data_ever.runs; end
  def hits; all_batting_data_ever.hits; end
  def doubles; all_batting_data_ever.doubles; end
  def triples; all_batting_data_ever.triples; end
  def home_runs; all_batting_data_ever.home_runs; end
  def runs_batted_in; all_batting_data_ever.runs_batted_in; end
  def stolen_bases; all_batting_data_ever.stolen_bases; end
  def caught_stealing; all_batting_data_ever.caught_stealing; end

  def batting_average
    if hits > 0 && at_bats > 0
      hits / at_bats.to_f
    else
      0.0
    end
  end

  def self.first
    batter_data.first.last
  end

  def self.find_by_id(id)
    batter_data[id]
  end

  def self.batter_data
    @@batter_data ||= load_batter_data
  end

  def self.load_batter_data
    # Refactor me: hardcodey much? [SPIKE]
    batters = BatterCsvReader.new("./data/Master-small.csv").all.map {|row|
      Batter.new(row["playerID"], row["nameLast"], row["nameFirst"])
    }.each_with_object({}) {|batter, hash| hash[batter.id] = batter }
    @@batter_data = batters
    load_batting_data
    batters
  end

  # FIXME: I *REALLY* belong in a data conversion class!!!!
  def self.batting_data_keys
    { id: "playerID",
      year: "yearID",
      league: "leaugeID",
      team: "teamID",
      games: "G",
      at_bats: "AB",
      runs: "R",
      hits: "H",
      doubles: "2B",
      triples: "3B",
      home_runs: "HR",
      runs_batted_in: "RBI",
      stolen_bases: "SB",
      caught_stealing: "CS"
    }
  end

  def self.load_batting_data
    BattingCsvReader.new("./data/Batting-07-12.csv").all.map {|row|
      data = {}
      batting_data_keys.each_pair do |new_key, old_key|
        data[new_key] = row[old_key]
      end

      if batter = Batter.find_by_id(data[:id])
        batter.add_batting_data(BattingData.new(data))
      else
        raise "Unable to find batter by id '%s'; all batter should be loaded" % row["playerID"]
      end
    }
  end

  def add_batting_data(bd)
    @batting_data[bd.year][bd.league][bd.team] += bd
  end

  private

  # Consolidate all my batting data across all years, leagues, teams, etc.
  def all_batting_data_ever
    batting_data.map {|year, league_data|
      all_batting_data_for_year league_data
    }.reduce :+
  end

  def all_batting_data_for_year(data)
    data.map {|league, team_data|
      all_batting_data_for_team team_data
    }.reduce :+
  end

  def all_batting_data_for_team(data)
    data.values.reduce :+
  end
end
