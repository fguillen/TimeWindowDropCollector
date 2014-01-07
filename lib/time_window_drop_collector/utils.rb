module TimeWindowDropCollector::Utils
  def grouping_count( key_values )
    groups = key_values.group_by { |k,v| k.match( /drop_window_(.*)_/ )[1]  }

    result = {}

    groups.each do |k,v|
      result[k] = v.inject(0) { |acc,e| acc += e[1].to_i }
    end

    result
  end

  def timestamp_key( key, time = timestamp )
    "drop_window_#{key}_#{slice_start_timestamp( time )}"
  end

  def timestamp_key_multi( keys, time = timestamp)
    keys.map { |key| timestamp_key( key, time) }.flatten
  end

  def window_keys( key, time = timestamp )
    ( 0..( slices - 1 ) ).map{ |i|
      timestamp_key( key, time - ( ( i*slice_milliseconds ) / 1000 ) )
    }
  end

  def window_keys_multi( keys )
    keys.map { |key| window_keys( key ) }.flatten
  end

  def timestamp
    Time.now
  end

  def slice_milliseconds
    @slice_milliseconds ||= ( window * 1000 ) / slices
  end

  def slice_start_timestamp( time )
    time_milliseconds = ( time.to_f * 1000 ).truncate

    ( time_milliseconds / slice_milliseconds ) * slice_milliseconds
  end
end
