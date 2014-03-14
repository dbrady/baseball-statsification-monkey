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

end
