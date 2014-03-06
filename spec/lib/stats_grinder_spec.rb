require 'spec_helper'
require_relative '../../lib/stats_grinder'

describe StatsGrinder do
  let(:stats_grinder) { StatsGrinder.new }

  describe "#most_improved_batter" do
    it "finds most improved batter between years" do
      stats_grinder.most_improved_batter(2008, 2010).should == "Hank Aaron"
    end

#    it "ignores batters with fewer than 200 at-bats"
  end

end
