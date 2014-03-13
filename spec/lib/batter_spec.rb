require 'spec_helper'
require_relative '../../lib/batter'

describe Batter do
  context "with autoloaded data" do
    # Josh Wilson played 345 games for 6 teams in both leagues. He
    # played 45 games in 2009 and 108 games in 2010 for SEA; the other
    # teams (ARI, MIL, SDN, WAS, TBA) were all in the NL.
    let(:wilson) { Batter.find_by_id "wilsojo03" }

    # Kim Byung-Hyun played 28 games for three teams in both leagues
    # in 2007. He's interesting because he's the only player with four
    # entries for a single year--and it's the only year he played.
    let(:kimby) { Batter.find_by_id "kimby01" }

    # Jeremy Accardo is interesting because he's got a few records
    # listed as 0,0,0,0,0,0,0,0,0,0 and a few records listed as
    # ,,,,,,,,,. He's also interesting because he's played a total of
    # 134 games from 2007 to 2012 and he's never had a single at-bat.
    let(:accardo) { Batter.find_by_id "accarje01" }

    describe ".first" do
      it "returns Hank Aaron" do
        Batter.first.name.should == "Hank Aaron"
      end
    end

    describe ".find_by_id" do
      it "finds batter" do
        wilson.name.should == "Josh Wilson"
      end
    end

    describe "#years" do
      it "returns years played" do
        kimby.years.should == [2007]
      end
    end

    describe "BattingData interface" do

      describe "#games" do
        it "returns total games played" do
          wilson.games.should == 345
          kimby.games.should == 28
          accardo.games.should == 134
        end
      end

      describe "#at_bats" do
        it "returns total at_bats" do
          accardo.at_bats.should == 0
          wilson.at_bats.should == 920
          kimby.at_bats.should == 33
        end
      end

      describe "#runs" do
        it "returns total runs" do
          accardo.runs.should == 0
          wilson.runs.should == 0
          kimby.runs.should == 0
        end
      end

      describe "#hits" do
        it "returns total hits" do
          accardo.hits.should == 0
          wilson.hits.should == 210
          kimby.hits.should == 2
        end
      end

      describe "#doubles" do
        it "returns total doubles" do
          accardo.doubles.should == 0
          wilson.doubles.should == 45
          kimby.doubles.should == 1
        end
      end

      describe "#triples" do
        it "returns total triples" do
          accardo.triples.should == 0
          wilson.triples.should == 6
          kimby.triples.should == 0
        end
      end

      describe "#home_runs" do
        it "returns total home_runs" do
          accardo.home_runs.should == 0
          wilson.home_runs.should == 9
          kimby.home_runs.should == 0
        end
      end

      describe "#runs_batted_in" do
        it "returns total runs_batted_in" do
          accardo.runs_batted_in.should == 0
          wilson.runs_batted_in.should == 67
          kimby.runs_batted_in.should == 1
        end
      end

      describe "#stolen_bases" do
        it "returns total stolen_bases" do
          accardo.stolen_bases.should == 0
          wilson.stolen_bases.should == 13
          kimby.stolen_bases.should == 0
        end
      end

      describe "#caught_stealing" do
        it "returns total caught_stealing" do
          accardo.caught_stealing.should == 0
          wilson.caught_stealing.should == 4
          kimby.caught_stealing.should == 0
        end
      end

      describe "#batting_average" do
        it "returns lifetime batting average" do
          accardo.batting_average.should be_within(0.0005).of(0.000)
          wilson.batting_average.should be_within(0.0005).of(0.228)
          kimby.batting_average.should be_within(0.0005).of(0.061)
        end
      end
    end

    describe "#stats_for_year" do
      let(:stats) { kimby.stats_for_year(2007) }
      it "returns BattingData for year" do
        stats.should be_a(BattingData)
        stats.games.should == 28
        stats.at_bats.should == 33
        stats.batting_average.should be_within(0.0005).of(0.061)
      end
    end
  end
end
