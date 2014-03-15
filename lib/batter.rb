require_relative "csv_reader"
require_relative "batting_data"
require_relative "patches"

# Representation of a player. Class-level finders search the dataset
# while instance methods provide stats and convenience lookup into
# player demographic data
class Batter
  extend Forwardable

  attr_reader :id, :last_name, :first_name
  private_attr_reader :batting_data

  def initialize(id:, last_name:, first_name:)
    @id, @last_name, @first_name = id, last_name, first_name
    @batting_data = Hash.new do |hash, year|
      hash[year] = Hash.new do |hash2, league_id|
        hash2[league_id] = Hash.new do |hash3, team_id|
          hash3[team_id] = BattingData.new player_id: id
        end
      end
    end
  end

  def_delegators :all_batting_data_ever, :games, :at_bats, :runs,
                 :hits, :doubles, :triples, :home_runs,
                 :runs_batted_in, :stolen_bases, :caught_stealing,
                 :batting_average

  # Selectors -- similar to ActiveRecord, we can find the first batter
  # or find by id.
  def self.first
    batter_data.first.last
  end

  def self.find(id:)
    batter_data.fetch id
  end

  def self.find_all(year: nil, league: nil, team: nil)
    return batter_data.map(&:last) unless year
    return find_all_by_year(year) unless league || team
    # subtle: if you supply both league and team, ignore league
    return find_all_by_league_and_year(league, year) unless team
    find_all_by_team_and_year(team, year)
  end

  def name
    "%s %s" % [first_name, last_name]
  end

  def sortable_name
    "%s, %s" % [last_name, first_name]
  end

  def years
    batting_data.keys
  end

  def stats_for_year(year)
    all_batting_data_for_year batting_data[year]
  end

  def stats_for_league_and_year(league, year)
    return nil unless batting_data.key?(year) &&
      batting_data[year] && batting_data[year].key?(league)
    # FIXME: dis nasty. Have to pass in a key with the hash, which
    # means having to lump on the league key again here. Mai ow--do
    # not want. Is it really necessary? Need to revisit the method
    # breakdown and see if it can't be cleaned up
    all_batting_data_for_year({ league => batting_data[year][league] })
  end

  def played_any_games?(year:, league: nil, team: nil)
    return played_any_games_in_year?(year) unless league || team
    return played_any_games_in_league_in_year?(league, year) unless team
    played_any_games_for_team_in_year?(team, year)
  end

  # I hate methods like this, but whatchagonnado. Basically this
  # method lets us cram a line of data from the CSV file into the
  # Batter and the Batter will init a new record with it, or add it to
  # any existing stats for that year/league/team (the data file has
  # over 550 entries that are same player/year, and often same
  # player/year/league/team. And often same player/year but different
  # team, and occasionally different league. The fact is this data is
  # SUPER messy and we gotta live with it, because the reality it's
  # tracking is also super messy
  def add_batting_data(bd)
    @batting_data[bd.year][bd.league][bd.team] += bd
  end

  #
  # END OF PUBLIC API
  #

  private

  # Private Finders
  private_class_method def self.find_all_by_year(year)
    batter_data.reject {|id, batter|
      !batter.played_any_games?(year: year)
    }.map(&:last)
  end

  private_class_method def self.find_all_by_team_and_year(team, year)
    batter_data.reject {|id, batter|
      !batter.played_any_games?(year: year, team: team)
    }.map(&:last)
  end

  private_class_method def self.find_all_by_league_and_year(league, year)
    batter_data.reject {|id, batter|
      !batter.played_any_games?(year: year, league: league)
    }.map(&:last)
  end

  # Internal caching method so we only ever load batter data once per
  # program run
  private_class_method def self.batter_data
    @@batter_data ||= load_batter_data
  end

  # Internal caching method, ugh, WHY IS THIS ON THIS CLASS--please
  # give me a reason other than "I suck". Okay, fine: "I suck until I
  # refactor."
  private_class_method def self.load_batter_data
    # Refactor me: hardcodey much? [SPIKE]
    batters = CsvReader.new("./data/Master-small.csv")
      .all
      .reject {|row| row["playerID"].nil? }
      .map {|row|
        Batter.new(
                   id: row["playerID"],
                   last_name: row["nameLast"],
                   first_name: row["nameFirst"]
                   )
      }
      .each_with_object({}) {|batter, hash| hash[batter.id] = batter }


    @@batter_data = batters
    load_batting_data
    batters
  end

  # FIXME: I *REALLY* belong in a data conversion class!!!! These are
  # the CSV header identifiers keyed by our internal data columns. Why
  # not use what's in the CSV, you ask? Let me answer that question by
  # stating authoritatively that if you are asking that question you
  # obviously have no clue what's IN that frickin' CSV file. You wanna
  # know what's in that file? Do you? DO YOU REALLY? MADNESS! MADNESS
  # I SAY! MADNESS IS WHAT IS IN THAT FILE! When Nietzche famously
  # wrote "If you gaze long into the Abyss, the Abyss gazes also into
  # you," HE WAS TALKING ABOUT THIS CSV FILE. IT'S BAT-POO CRAZY IS
  # WHAT I AM TRYING TO TELL YOU--NO, DON'T LOOK, DON'T LOOK IN THE
  # FILE, DON'T OPEN THE...
  #
  # You looked, didn't you.
  #
  # Well. Welcome to my madness. Make yourself comfortable; THERE IS
  # NO WAY BACK.
  #
  # I did try to warn you.
  private_class_method def self.batting_data_keys
    { player_id: "playerID",
      year: "yearID",
      league: "league",
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


  # Internal caching method. See earlier note about the technical
  # depth and temporal breadth within which I suck.
  private_class_method def self.load_batting_data
    CsvReader.new("./data/Batting-07-12.csv").all.map {|row|
      data = {}
      batting_data_keys.each_pair do |new_key, old_key|
        data[new_key] = row[old_key]
      end

      Batter.find(id: data[:player_id]).add_batting_data(BattingData.new(data))
    }
  end

  def played_any_games_in_year?(year)
    years.include? year
  end

  def played_any_games_for_team_in_year?(team, year)
    played_any_games?(year: year) && batting_data[year].any? {|_, team_data|
      team_data.keys.include?(team)
    }
  end

  def played_any_games_in_league_in_year?(league, year)
    played_any_games?(year: year) && batting_data[year].any? {|league_name, _|
      league == league_name
    }
  end

  # Consolidate all my batting data across all years, leagues, teams,
  # etc.
  def all_batting_data_ever
    batting_data.map {|year, league_data|
      all_batting_data_for_year league_data
    }.reduce :+
  end

  # Helper: given a subtree of BattingDatas for a given year, dive
  # into each league. Private method because it accepts a subtree of
  # the batting_data structure. Knows too much about our internals.
  def all_batting_data_for_year(data)
    data.map {|league, team_data|
      all_batting_data_for_league team_data
    }.reduce :+
  end

  # Helper: given a subtree of BattingDatas for a given league, dive
  # into each team. Private method because it accepts a subtree of the
  # batting_data structure. Knows too much about our internals.
  def all_batting_data_for_league(data)
    # We could extract all_batting_data_for_team here, but Hash#values
    # gives us the same thing at this point. Private methods FTW--no
    # using this method, you public-API-using knuckledraggers!
    data.values.reduce :+
  end
end
