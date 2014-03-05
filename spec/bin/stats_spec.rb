require 'spec_helper'

describe "stats" do
  describe "when run" do
    it "emits 'All done.'" do
      `bundle exec bin/stats`.should include("All done.")
    end
  end

end
