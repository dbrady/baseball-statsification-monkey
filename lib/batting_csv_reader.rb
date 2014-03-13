require 'csv'

class BattingCsvReader
  def initialize(filename)
    @filename = filename
  end

  def all
    data
  end

  def data
    @data ||= CSV.read(@filename, headers: true)
  end
end
