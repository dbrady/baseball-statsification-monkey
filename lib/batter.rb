require_relative "batter_csv_reader"

class Batter
  attr_reader :id, :last_name, :first_name
  def initialize(id, last_name, first_name)
    @id, @last_name, @first_name = id, last_name, first_name
  end

  def name
    "%s %s" % [first_name, last_name]
  end

  def self.first
    batter_data.first.last
  end

  def self.find_by_id(id)
    batter_data[id]
  end

  def self.batter_data
    @@batter_data ||= load_batter_data
  end

  def self.load_batter_data
    # Refactor me: hardcodey much? [SPIKE]
    BatterCsvReader.new("./data/Master-small.csv").all.map {|row|
      Batter.new(row["playerID"], row["nameLast"], row["nameFirst"])
    }.each_with_object({}) {|batter, batter_data|
      batter_data[batter.id] = batter
    }
  end
end
