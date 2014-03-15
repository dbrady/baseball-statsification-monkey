require 'spec_helper'
require_relative '../../lib/batter'

def spec_stats_for(description, varname, stats)
  context "#{description}" do
    let(:subject) { instance_eval "#{varname}" }

    its(:games) { should == stats[:games] }
    its(:at_bats) { should == stats[:at_bats] }
    its(:runs) { should == stats[:runs] }
    its(:hits) { should == stats[:hits] }
    its(:doubles) { should == stats[:doubles] }
    its(:triples) { should == stats[:triples] }
    its(:home_runs) { should == stats[:home_runs] }
    its(:runs_batted_in) { should == stats[:runs_batted_in] }
    its(:stolen_bases) { should == stats[:stolen_bases] }
    its(:caught_stealing) { should == stats[:caught_stealing] }
    its(:batting_average) { should be_within(0.0005).of(stats[:batting_average]) }
  end
end

describe Batter do
  context "with autoloaded data" do
    # Josh Wilson played 345 games for 6 teams in both leagues. He
    # played 45 games in 2009 and 108 games in 2010 for SEA; the other
    # teams (ARI, MIL, SDN, WAS, TBA) were all in the NL.
    let(:wilson) { Batter.find id: "wilsojo03" }

    # Kim Byung-Hyun played 28 games for three teams in both leagues
    # in 2007. He's interesting because he's the only player with four
    # entries for a single year--and it's the only year he played.
    let(:kimby) { Batter.find id: "kimby01" }

    # Jeremy Accardo is interesting because he's got a few records
    # listed as 0,0,0,0,0,0,0,0,0,0 and a few records listed as
    # ,,,,,,,,,. He's also interesting because he's played a total of
    # 134 games from 2007 to 2012 and he's never had a single at-bat.
    let(:accardo) { Batter.find id: "accarje01" }

    describe ".first" do
      it "returns Hank Aaron" do
        Batter.first.name.should == "Hank Aaron"
      end
    end

    describe ".find" do
      it "finds batter" do
        wilson.name.should == "Josh Wilson"
      end
    end

    describe ".find_all" do
      context "with no arguments" do
        let(:batters) { Batter.find_all.sort_by(&:sortable_name) }

        it "finds all batters" do
          batters.size.should == 17945
          batters.first.name.should == "David Aardsma"
          batters.last.name.should == "Miguel del Toro"
        end
      end

      context "with year only" do
        let(:batters_2010) { Batter.find_all(year: 2010).sort_by(&:sortable_name) }

        it "finds batters by year" do
          batters_2010.size.should == 1157
          batters_2010.first.name.should == "David Aardsma"
          batters_2010.last.name.should == "Jorge de la Rosa"
        end
      end

      context "with team and year" do
        let(:seattle_2008) { Batter.find_all(team: "SEA", year: 2008).sort_by(&:sortable_name) }

        it "finds batters by team and year" do
          seattle_2008.size.should == 44
          seattle_2008.first.name.should == "Cha Seung Baek"
          seattle_2008.last.name.should == "Jake Woods"
        end
      end

      context "with league and year" do
        let(:al_2008) { Batter.find_all(league: "AL", year: 2008).sort_by(&:sortable_name) }

        it "finds batters by league and year" do
          al_2008.size.should == 624
          al_2008.all? {|batter| batter.played_any_games_in_league_in_year?("AL", 2008) }.should be_true
          al_2008.first.name.should == "David Aardsma"
          al_2008.last.name.should == "Joel Zumaya"
        end
      end
    end

    # This spec is fairly transient; the API started out totally
    # public and I want to assert that I have locked it down
    # completely
    describe "private class API" do
      %i(
         find_all_by_year
         find_all_by_team_and_year
         find_all_by_league_and_year
         batter_data
         load_batter_data
         batting_data_keys
         load_batting_data
         ).each do |private_method|
        describe private_method do
          it "should be private" do
            expect {
              Batter.public_send(private_method)
            }.to raise_error(NoMethodError, /private method/)
          end
        end
      end
    end


    describe "#played_any_games_in?(year)" do
      it "returns truthy if batter played that year" do
        kimby.played_any_games_in?(2007).should be_true
        kimby.played_any_games_in?(2008).should be_false
      end
    end

    describe "#years" do
      it "returns years played" do
        kimby.years.should == [2007]
      end
    end

    describe "#name" do
      it "returns first_name-space-last_name" do
        kimby.name.should == "Byung-Hyun Kim"
      end
    end

    describe "#sortable_name" do
      it "returns Schwartzian-sortable version of name" do
        kimby.sortable_name.should == "Kim, Byung-Hyun"
      end
    end

    describe "BattingData interface" do
      spec_stats_for("Josh Wilson lifetime stats", "wilson", {
                       games: 345,
                       at_bats: 920,
                       runs: 82,
                       hits: 210,
                       doubles: 45,
                       triples: 6,
                       home_runs: 9,
                       runs_batted_in: 67,
                       stolen_bases: 13,
                       caught_stealing: 4,
                       batting_average: 0.228
                     })

      spec_stats_for("Jeremy Accardo lifetime stats", "accardo", {
                       games: 134,
                       at_bats: 0,
                       runs: 0,
                       hits: 0,
                       doubles: 0,
                       triples: 0,
                       home_runs: 0,
                       runs_batted_in: 0,
                       stolen_bases: 0,
                       caught_stealing: 0,
                       batting_average: 0.0
                     })

      spec_stats_for("Kim Byung-Hyun lifetime stats", "kimby", {
                       games: 28,
                       at_bats: 33,
                       runs: 0,
                       hits: 2,
                       doubles: 1,
                       triples: 0,
                       home_runs: 0,
                       runs_batted_in: 1,
                       stolen_bases: 0,
                       caught_stealing: 0,
                       batting_average: 0.061
                     })

    end

    describe "#stats_for_year" do
      let(:kimby_2007_stats) { kimby.stats_for_year(2007) }
      let(:wilson_2011_stats) { wilson.stats_for_year(2011) }

      spec_stats_for("Kim Byung-Hyun 2007 stats", "kimby_2007_stats", {
                       games: 28,
                       at_bats: 33,
                       runs: 0,
                       hits: 2,
                       doubles: 1,
                       triples: 0,
                       home_runs: 0,
                       runs_batted_in: 1,
                       stolen_bases: 0,
                       caught_stealing: 0,
                       batting_average: 0.061
                     })

      spec_stats_for("Josh Wilson 2011 stats", "wilson_2011_stats", {
                       games: 60,
                       at_bats: 85,
                       runs: 13,
                       hits: 19,
                       doubles: 5,
                       triples: 0,
                       home_runs: 2,
                       runs_batted_in: 5,
                       stolen_bases: 1,
                       caught_stealing: 0,
                       batting_average: 0.224
                     })

      context "with empty year" do
        let(:empty_stats) { wilson.stats_for_year(1966) }
        it "returns nil" do
          # HATE returning nil, but I've designed West-facing code,
          # so it's unavoidable until I repent :'-(
          empty_stats.should be_nil
        end
      end
    end

    describe "#stats_for_league_and_year" do
      let(:wilson_al_2009_stats) { wilson.stats_for_league_and_year("AL", 2009) }
      spec_stats_for("Josh Wilson 2009 AL stats", "wilson_al_2009_stats", {
                       games: 45,
                       at_bats: 128,
                       runs: 16,
                       hits: 32,
                       doubles: 8,
                       triples: 1,
                       home_runs: 3,
                       runs_batted_in: 10,
                       stolen_bases: 1,
                       caught_stealing: 2,
                       batting_average: 0.250
                       })
    end
  end
end
