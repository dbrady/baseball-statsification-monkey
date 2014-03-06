require 'spec_helper'
require_relative '../../lib/batboy'
require 'stringio'

describe Batboy do
  it "should be sane" do
    Batboy.should_not be_nil
  end

  describe "initialize" do
    let(:buffer) { StringIO.new }

    context "with no arguments" do
      before(:each) do
        $stdout = buffer
      end

      after(:each) do
        $stdout = STDOUT
      end

      it "assumes writing to $stdout" do
        Batboy.new.report_all_done
        buffer.string.should include("All done.\n")
      end
    end

    context "with target buffer" do
      it "accepts buffer to display to" do
        Batboy.new(buffer).report_all_done
        buffer.string.should include("All done.\n")
      end
    end
  end
end
