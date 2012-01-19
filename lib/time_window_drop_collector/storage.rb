class TimeWindowDropCollector::Storage
  attr_reader :client, :window, :slices

  def initialize( client, window, slices )
    @client = client
    @window = window
    @slices = slices
  end

  def self.incr( key )
    client.incr( time_key( key ), window )
  end

  def self.count( key )
    time_keys = time_keys( key )
    values    = client.values( time_keys )

    values.map( &:to_i ).inject( :+ )
  end

  def self.time_key( key, time = timestamp )
    "drop_window_#{key}_#{time.strftime( '%Y%m%d%H%M' )}"
  end

  def self.time_keys( key )
    now = timestamp

    ( 0..9 ).map{ |i|
      time_key( key, now - ( i*60 ) )
    }
  end

  def self.timestamp
    Time.now
  end
end