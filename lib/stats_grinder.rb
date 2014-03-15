require_relative "batter"

# StatsGrinder is a class that is aware of BattingData from a higher
# level than BattingData itself; specifically it is able to compare
# BattingData objects to each other to determine improvement, identify
# triple crown winners, etc. It also knows how to search for relevant
# Batters to satisfy a given query.
#
# It may be possible to offload some of the stats to BattingData. For
# example, BattingData#batting_average_improvement(other_batting_data)
# but for now the purpose of StatsGrinder is to satisfy our curiosity
# about various baseball statistics that are fussy and hand-tweaked
# (like only considering batters with a certain number of at-bats for
# a given report)
class StatsGrinder
  def most_improved_batter(from, to)
    batters1 = Batter.find_all year: from
    batters1 = with_at_least_200_at_bats(batters1, from)
    batters2 = Batter.find_all year: to
    batters2 = with_at_least_200_at_bats(batters2, to)

    batters = common_batters(batters1, batters2)

    most_improved(batters, from, to)
  end

  # So far Batboy has only ever needed to talk to StatsGrinder. No
  # need for it to talk directly to Batter just yet--let's proxy this
  # for now and get an intention-revealing name in the bargain.
  def team_members_for_year(team, year)
    Batter.find_all(team: team, year: year)
  end

  def triple_crown_winner_in_league_for(league, year)
    # BattingData already has everything we need here -- just need to
    # teach Batter to cobble up and return BattingDatas that only
    # include data from the desired league and year. Then ask each
    # batter for stats_for_league_and_year, and see if the max_by
    # :home_runs, :runs_batted_in, and :batting_average are all the
    # same person.
    contenders = Batter.find_all league: league, year: year
    contenders.reject! {|batter|
      # FIXME: there's code below to filter batters with fewer than
      # 200 at bats. Seems like a good potential re-use case
      #
      # I'm not sayin', I'm just sayin'
      batter.stats_for_league_and_year(league, year).at_bats < 400
    }

    homer = contenders.max_by {|batter|
      batter.stats_for_league_and_year(league, year).home_runs
    }
    run_batter_inner = contenders.max_by {|batter|
      batter.stats_for_league_and_year(league, year).runs_batted_in
    }
    # optimization: return nil early here unless homer ==
    # run_batter_inner because BA doesn't matter--we do not have a
    # triple crown winner this year in this league. Not doing any
    # optimization until/unless the program gets too slow, however,
    # because optimizing correct code is easy, but correcting
    # optimized code is a bear.
    best_hitter = contenders.max_by {|batter|
      batter.stats_for_league_and_year(league, year).batting_average
    }
    if homer == run_batter_inner && homer == best_hitter
      homer
    else
      nil # ;-)
    end
  end

  private

  # Isolating this method because the coding exercise does not
  # adequately explain how to calculate improvement -- do we want
  # percentage improvement, or raw points gained? Fortunately, for
  # the year in question the most improved batter wins by a wide
  # enough margin to take both raw points AND percentage, so here
  # endeth my pondering--it's isolated and I'm done. :-) [Update: this
  # was bugging me so I called my baseball-stats-loving friend, and he
  # informed me that it's preferred to calculate based on raw points,
  # not percentage, because batting average is already a percentage,
  # and grinding out "percentages of percentages" becomes
  # statistically problematic.]
  def batter_improvement(batter, from, to)
    tba, fba = batter.stats_for_year(to).batting_average,
         batter.stats_for_year(from).batting_average
    improvement = tba - fba
    # improvement_percent = improvement / fba
  end

  def with_at_least_200_at_bats(batters, year)
    batters.reject {|batter| batter.stats_for_year(year).at_bats < 200 }
  end

  # reject batters not present in both years
  def common_batters(batters1, batters2)
    batter2_ids = batters2.map(&:id)
    batters1.reject {|batter| !batter2_ids.include?(batter.id) }
  end

  # return most-improved batter in set for the 2 years in
  # question. This could be extracted into a sort_by / first method
  # pair but ruby already gives us max_by.
  def most_improved(batters, from, to)
    batters_with_improvements = batters.map {|batter|
      [batter, batter_improvement(batter, from, to)]
    }.max_by {|b, bwi| bwi }.first
  end
end
