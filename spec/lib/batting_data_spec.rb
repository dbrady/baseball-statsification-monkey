require 'spec_helper'
require_relative '../../lib/batting_data'

describe BattingData do
  before(:each) do
    batter = double("Batter")
    Batter.stub(:find_by_id).and_return(batter)
  end

  describe "#batting_average" do
    let(:batting_data) { BattingData.new player_id: "test", at_bats: 100, hits: 20 }
    it "calculates hits / at_bats" do
      batting_data.batting_average.should be_within(0.0005).of(0.200)
    end
  end

  describe "#slugging_percentage" do
    let(:batting_data) { BattingData.new player_id: "test", at_bats: 100, hits: 20, doubles: 6, triples: 2, home_runs: 1 }

    it "calculates slugging percentage" do
      batting_data.slugging_percentage.should be_within(0.0005).of(0.330)
    end
  end

  describe "#+" do
    let(:one) { BattingData.new Hash.new(1).merge({player_id: 1}) }
    let(:two) { BattingData.new Hash.new(2).merge({player_id: 2}) }
    let(:three) { one + two }

    it "sums the BattingData data" do
      three.player_id.should == 1
      three.year.should == 1
      three.league.should == 1
      three.games.should == 3
      three.at_bats.should == 3
      three.runs.should == 3
      three.hits.should == 3
      three.doubles.should == 3
      three.triples.should == 3
      three.home_runs.should == 3
      three.runs_batted_in.should == 3
      three.stolen_bases.should == 3
      three.caught_stealing.should == 3
    end
  end
end
