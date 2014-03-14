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
      program_output.should include("Josh Hamilton")
    end

    it "emits 'Slugging percentage for all players on the Oakland A's in 2007:'" do
      program_output.should include("2007 Slugging percentages for OAK:")
      program_output.should include("Joe Kennedy:  0.667")
      program_output.should include("Daric Barton:  0.639")
      program_output.should include("Milton Bradley:  0.545")
      program_output.should include("Jerry Blevins:  0.000")
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
