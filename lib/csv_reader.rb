require 'csv'

# Load CSV file and read it
class CsvReader
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
