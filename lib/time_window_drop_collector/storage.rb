class TimeWindowDropCollector::Storage
  attr_reader :wrapper, :window, :slices

  def initialize( wrapper, window, slices )
    @wrapper = wrapper
    @window = window
    @slices = slices
  end

  def incr( key )
    wrapper.incr( time_key( key ), window )
  end

  def count( key )
    time_keys = time_keys( key )
    values    = wrapper.values_for( time_keys )

    values.map( &:to_i ).inject( :+ ).to_i
  end

  def time_key( key, time = timestamp )
    "drop_window_#{key}_#{slice_start_timestamp( time )}"
  end

  def time_keys( key )
    now = timestamp

    ( 0..( slices - 1 ) ).map{ |i|
      time_key( key, now - ( ( i*slice_milliseconds ) / 1000 ) )
    }
  end

  def timestamp
    Time.now
  end

  def slice_milliseconds
    ( window * 1000 ) / slices
  end

  def slice_start_timestamp( time )
    time_milliseconds = ( time.to_f * 1000 ).truncate

    ( time_milliseconds / slice_milliseconds ) * slice_milliseconds
  end
end