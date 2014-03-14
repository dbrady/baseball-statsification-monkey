require 'spec_helper'
require_relative '../../lib/batboy'
require 'stringio'

describe Batboy do
  let(:buffer) { StringIO.new }
  let(:output) { buffer.string }
  let(:stats_grinder) { double("StatsGrinder") }
  let(:batboy) { Batboy.new buffer, stats_grinder }

  describe "initialize" do
    context "with no arguments" do
      before(:each) do
        $stdout = buffer
      end

      after(:each) do
        $stdout = STDOUT
      end

      it "assumes writing to $stdout" do
        Batboy.new.report_all_done
        output.should include("All done.\n")
      end
    end

    context "with target buffer" do
      it "accepts buffer to display to" do
        Batboy.new(buffer).report_all_done
        output.should include("All done.\n")
      end
    end
  end

  describe "#report_all_done" do
    it "writes 'All done.' to buffer" do
      batboy.report_all_done
      output.should include("All done.\n")
    end
  end

  describe "#report_most_improved_batter_in(year)" do
    before(:each) do
      batter = double("Batter", name: "Hank Aaron")
      stats_grinder.stub(:most_improved_batter).and_return batter
    end

    it "emits 'Most improved batter [year-1]->[year]:'" do
      # Refactor me: this will need something it can get the answer from
      batboy.report_most_improved_batter_in 1999
      output.should include("Most improved batter 1998->1999:")
    end

    it "asks StatsGrinder to find most improved batter" do
      batter = double("Batter", name: "Hank Aaron")
      stats_grinder.should_receive(:most_improved_batter).with(1998, 1999).and_return batter
      batboy.report_most_improved_batter_in 1999
      output.should include("Most improved batter 1998->1999:")
      output.should include("Hank Aaron")
    end

    # TODO: As I move forward with slugging percentages, I see a
    # distinct need for "display a Batter with slugging percentage";
    # did I gloss over the need to display a Batter with batting
    # average improvement? Maybe. Circle back to this later -- what we
    # have now is pretty and shippable.

    describe "#report_slugging_percentage_roster_for('SEA', 2008)" do
      it "asks StatsGrinder for 2008 Seattle team roster" do
        batting_data = double("BattingData", slugging_percentage: 0.5)
        batter1 = double("Batter", name: "Sluggo McLongball",
                         stats_for_year: batting_data)
        batter2 = double("Batter", name: "Ballsmack O'Hittem",
                         stats_for_year: batting_data)
        team = [batter1, batter2]

        stats_grinder.should_receive(:team_members_for_year).with('SEA', 2008).and_return team

        batboy.report_slugging_percentage_roster_for("SEA", 2008)

        output.should include("2008 Slugging percentages for SEA:")
        output.should include("Sluggo McLongball:  0.500")
        output.should include("Ballsmack O'Hittem:  0.500")
      end
    end

    describe "#report_triple_crown_winner_in(league, year)" do
      it "asks StatsGrinder for 2011 NL triple crown winner" do
        stats_grinder.should_receive(:triple_crown_winner_in_league_for).at_least(:once).with("NL", 2011).and_return nil
        batboy.report_triple_crown_winner_in_league_for("NL", 2011)
        output.should include("2011 NL Triple Crown Winner:\n(No winner)")
      end

      it "asks StatsGrinder for 2012 AL triple crown winner" do
        batter = double("Batter", name: "Sluggo McLongball")
        stats_grinder.should_receive(:triple_crown_winner_in_league_for).at_least(:once).with("AL", 2012).and_return batter
        batboy.report_triple_crown_winner_in_league_for("AL", 2012)
        output.should include("2012 AL Triple Crown Winner:\nSluggo McLongball")
      end
    end

    # it "emits 'Slugging percentage for all players on the Oakland A's in 2007:'" do
    #   program_output.should include("2007 Slugging percentages for Oakland A's:")
    # end

    # it "emits AL triple-crown winner for 2011" do
    #   program_output.should include("2011 AL Triple Crown Winner:")
    # end

    # it "emits NL triple-crown winner for 2011" do
    #   program_output.should include("2011 NL Triple Crown Winner:")
    # end

    # it "emits AL triple-crown winner for 2012" do
    #   program_output.should include("2012 AL Triple Crown Winner:")
    # end

    # it "emits NL triple-crown winner for 2012" do
    #   program_output.should include("2012 NL Triple Crown Winner:")
    # end
  end
end
