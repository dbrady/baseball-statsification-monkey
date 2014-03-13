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
