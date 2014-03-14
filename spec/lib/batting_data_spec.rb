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
end
