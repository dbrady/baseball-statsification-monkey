require 'spec_helper'
require_relative '../../lib/batting_data'

describe BattingData do
  before(:each) do
    batter = double("Batter")
    Batter.stub(:find_by_id).and_return(batter)
  end

  context "with test batter double" do
    # This context and the next 4 lines of code are the first whiff of
    # a testing smell caused by BattingData being able to talk
    # directly to Batter. In a much larger application, I would inject
    # a connection service that we could mock and stub to our heart's
    # content. For now, it's only 3 tests that do this, so... eh. Put
    # 'em in a crappy "with test double" context and call it good
    # enough for now
    let(:batter) { Batter.new(id: "test", last_name: "Tester", first_name: "Testy") }
    before(:each) do
      Batter.stub(:find).with(id: "test").and_return batter
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
      let(:one) { BattingData.new Hash.new(1).merge({player_id: "test"}) }
      let(:two) { BattingData.new Hash.new(2).merge({player_id: "test"}) }
      let(:three) { one + two }

      it "sums the BattingData data" do
        three.player_id.should == "test"
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
end
