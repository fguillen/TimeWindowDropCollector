class TimeWindowDropCollector::Storage
  include TimeWindowDropCollector::Utils

  attr_reader :wrapper, :window, :slices

  def initialize( wrapper, window, slices )
    @wrapper = wrapper
    @window  = window
    @slices  = slices
  end

  def incr( keys )
    wrapper.incr( timestamp_key_multi( keys ), window )
  end

  def count( keys )
    window_keys = window_keys_multi( keys )
    keys_values = wrapper.get( window_keys )

    grouping_count( keys_values )
  end
end