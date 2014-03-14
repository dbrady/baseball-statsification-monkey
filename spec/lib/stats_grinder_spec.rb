require 'spec_helper'
require_relative '../../lib/stats_grinder'

describe StatsGrinder do
  let(:stats_grinder) { StatsGrinder.new }

  describe "#most_improved_batter" do
    it "finds most improved batter between years" do
      stats_grinder.most_improved_batter(2008, 2010).name.should == "Carlos Gonzalez"
    end
  end

  describe "#team_members_for_year(team, year)" do
    it "asks Batter to find_all_by_team_and_year" do
      team = []
      Batter.should_receive(:find_all_by_team_and_year).and_return(team)
      stats_grinder.team_members_for_year('SEA', 2008)
    end
  end

  describe "#triple_crown_winner_in_league_for(team, year)" do
    context "when a single batter leads the league for batting average, home runs and RBI" do
      let(:winner) { double("Batter", stats_for_league_and_year: double("BattingData", at_bats: 1000, hits: 500, home_runs: 100, runs_batted_in: 100, batting_average: 0.500)) }
      let(:not_enough_plate_appearances) { double("Batter", stats_for_league_and_year: double("BattingData", at_bats: 200, hits: 200, home_runs: 200, runs_batted_in: 600, batting_average: 1.000)) }

      it "reports winner" do
        Batter.should_receive(:find_all_by_league_and_year).with("NL", 2009).and_return [winner]
        stats_grinder.triple_crown_winner_in_league_for("NL", 2009).should == winner
      end

      it "ignores batters with fewer than 400 at_bats" do
        Batter.should_receive(:find_all_by_league_and_year).with("NL", 2009).and_return [not_enough_plate_appearances, winner]
        stats_grinder.triple_crown_winner_in_league_for("NL", 2009).should == winner
      end
    end

    context "when no single winner is found" do
      let(:best_hitter) { double("Batter", stats_for_league_and_year: double("BattingData", at_bats: 500, hits: 500, home_runs: 0, runs_batted_in: 0, batting_average: 1.0)) }
      let(:best_slugger) { double("Batter", stats_for_league_and_year: double("BattingData", at_bats: 1000, hits: 500, home_runs: 500, runs_batted_in: 0, batting_average: 0.500)) }
      let(:best_rbier) { double("Batter", stats_for_league_and_year: double("BattingData", at_bats: 1000, hits: 500, home_runs: 0, runs_batted_in: 1500, batting_average: 0.5)) }

      it "returns no winner" do
        players = [best_hitter, best_slugger, best_rbier]
        Batter.should_receive(:find_all_by_league_and_year).with("NL", 2009).and_return(players)
        stats_grinder.triple_crown_winner_in_league_for("NL", 2009).should be_nil
      end
    end
  end

end
