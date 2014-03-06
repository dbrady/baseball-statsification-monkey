# Main Batboy Stats Reporting App
# This is the app-loading and startup lib file. You should be able to
# require 'batboy' and then do Batboy.new and get what you want.
require_relative "../patches/scoped_attr_accessors"

class Batboy
  private_attr_reader :ostream

  def initialize(ostream=$stdout)
    @ostream = ostream
  end

  def report_all_done
    ostream.puts "All done."
  end
end
