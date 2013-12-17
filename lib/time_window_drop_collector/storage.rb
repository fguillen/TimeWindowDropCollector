class TimeWindowDropCollector::Storage
  include TimeWindowDropCollector::Utils

  attr_reader :wrapper, :window, :slices

  def initialize( wrapper, window, slices )
    @wrapper = wrapper
    @window  = window
    @slices  = slices
  end

  def incr( keys, amount=1 )
    now = Time.now
    wrapper.incr( timestamp_key_multi( keys, now), window, amount )
    now
  end

  def decr( timestamp, keys, amount=1 )
    wrapper.decr(timestamp_key_multi( keys, timestamp), window, amount)
  end

  def count( keys )
    return {} if keys.empty?

    window_keys = window_keys_multi( keys )
    keys_values = wrapper.get( window_keys )

    grouping_count( keys_values )
  end
end
