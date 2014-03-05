require 'spec_helper'

describe "stats" do
  describe "when run" do
    def program_output
      `bin/stats`
    end

    it "emits 'All done.'" do
      program_output.should include("All done.")
    end

    it "emits 'Most improved batter 2009->2010:'" do
      program_output.should include("Most improved batter 2009->2010:")
    end

    it "emits 'Slugging percentage for all players on the Oakland A's in 2007:'" do
      program_output.should include("2007 Slugging percentages for Oakland A's:")
    end

    it "emits AL triple-crown winner for 2011" do
      program_output.should include("2011 AL Triple Crown Winner:")
    end

    it "emits NL triple-crown winner for 2011" do
      program_output.should include("2011 NL Triple Crown Winner:")
    end

    it "emits AL triple-crown winner for 2012" do
      program_output.should include("2012 AL Triple Crown Winner:")
    end

    it "emits NL triple-crown winner for 2012" do
      program_output.should include("2012 NL Triple Crown Winner:")
    end
  end

end
