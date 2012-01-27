class TimeWindowDropCollector::Results
  attr_reader :keys_values

  def initialize( keys_values )
    @keys_values = keys_values
  end

  def []( key )
    keys_values[key].to_i
  end

  def to_s
    keys_values.to_s
  end
end