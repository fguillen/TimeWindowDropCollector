require_relative "test_helper"

class StorageTest < Test::Unit::TestCase
  def setup
    @wrapper = mock()
    @storage = TimeWindowDropCollector::Storage.new( @wrapper, 600, 10 )
  end

  def test_timestamp_key_when_time_is_present
    timestamp = Time.new( 2001, 2, 3, 4, 5 )
    assert_equal( "drop_window_key_981169500000", @storage.timestamp_key( "key", timestamp ) )
  end

  def test_timestamp_key_when_time_is_not_present
    @storage.stubs( :timestamp ).returns( Time.new( 2012, 4, 3, 2, 1 ))
    assert_equal( "drop_window_key_1333411260000", @storage.timestamp_key( "key" ))
  end

  def test_window_keys_should_return_10_keys_for_the_last_10_minutes
    keys = [
      "drop_window_key_1325560800000",
      "drop_window_key_1325560740000",
      "drop_window_key_1325560680000",
      "drop_window_key_1325560620000",
      "drop_window_key_1325560560000",
      "drop_window_key_1325560500000",
      "drop_window_key_1325560440000",
      "drop_window_key_1325560380000",
      "drop_window_key_1325560320000",
      "drop_window_key_1325560260000"
    ]

    Delorean.time_travel_to( '2012-01-03 04:20' ) do
      assert_equal( keys, @storage.window_keys( "key" ))
    end
  end

  def test_incr
    @storage.expects( :timestamp_key_multi ).with( ["keys"] ).returns( "timestamp_keys" )
    @wrapper.expects( :incr ).with( "timestamp_keys", 600, 1 )

    @storage.incr( ["keys"] )
  end

  def test_incr_with_val
    @storage.expects( :timestamp_key_multi ).with( ["keys"] ).returns( "timestamp_keys" )
    @wrapper.expects( :incr ).with( "timestamp_keys", 600, 30.5 )

    @storage.incr( ["keys"], 30.5 )
  end

  def test_count
    @storage.expects( :window_keys_multi ).with( "keys" ).returns( "window_keys" )
    @wrapper.expects( :get ).with( "window_keys" ).returns( "keys_values" )
    @storage.expects( :grouping_count ).with( "keys_values" ).returns( "grouping_keys_counts" )

    assert_equal( "grouping_keys_counts", @storage.count( "keys" ))
  end

  def test_grouping_count
    key_values = {
      "drop_window_key1_201201031416" => 1,
      "drop_window_key1_201201031415" => 2,
      "drop_window_key1_201201031414" => 3,
      "drop_window_key1_201201031413" => 4,
      "drop_window_key1_201201031412" => 5,
      "drop_window_key2_201201031413" => 6,
      "drop_window_key2_201201031412" => 7
    }

    key_counts = @storage.grouping_count( key_values )

    assert_equal( 15, key_counts["key1"])
    assert_equal( 13, key_counts["key2"])
  end

  def test_grouping_count_with_nil_values
    key_values = {
      "drop_window_key1_201201031416" => 1,
      "drop_window_key1_201201031414" => nil,
      "drop_window_key2_201201031413" => 6,
      "drop_window_key2_201201031412" => 7,
      "drop_window_key3_201201031412" => nil
    }

    key_counts = @storage.grouping_count( key_values )

    assert_equal( 1, key_counts["key1"])
    assert_equal( 13, key_counts["key2"])
    assert_equal( 0, key_counts["key3"])
  end

    def test_grouping_when_not_key
    key_values = {
      "drop_window_key1_201201031416" => 1,
      "drop_window_key2_201201031412" => 7
    }

    key_counts = @storage.grouping_count( key_values )

    assert_equal( 1, key_counts["key1"])
    assert_equal( 7, key_counts["key2"])
    assert_equal( nil, key_counts["key3"])
  end

  def test_integration_count
    client  = TimeWindowDropCollector::Wrapper.instance( :mock )
    storage = TimeWindowDropCollector::Storage.new( client, 600, 10 )

    storage.incr( ["key_1"] )
    storage.incr( ["key_2"] )
    storage.incr( ["key_3"] )
    storage.incr( ["key_2"] )
    storage.incr( ["key_2", "key_1"] )

    keys_values = storage.count( ["key_1", "key_2", "key_3", "key_4"] )

    assert_equal( 2, keys_values["key_1"])
    assert_equal( 3, keys_values["key_2"])
    assert_equal( 1, keys_values["key_3"])
    assert_equal( nil, keys_values["key_4"])
  end

  def test_slice_start_timestamp
    storage = TimeWindowDropCollector::Storage.new( nil, 100, 10 )
    time    = Time.new( 2001, 2, 3, 4, 5 )

    assert_equal( 981169500000, storage.slice_start_timestamp( time ) )
    assert_equal( 981169500000, storage.slice_start_timestamp( time + 1 ) )
    assert_equal( 981169500000, storage.slice_start_timestamp( time + 9 ) )
    assert_equal( 981169520000, storage.slice_start_timestamp( time + 25 ) )
    assert_equal( 981169600000, storage.slice_start_timestamp( time + 100 ) )
  end

  def test_slice_start_timestamp_with_slice_sizes_no_integer
    storage = TimeWindowDropCollector::Storage.new( nil, 100, 12 )
    time    = Time.new( 2001, 2, 3, 4, 5 )

    assert_equal( 981169493317, storage.slice_start_timestamp( time ) )
    assert_equal( 981169493317, storage.slice_start_timestamp( time + 1 ) )
    assert_equal( 981169501650, storage.slice_start_timestamp( time + 9 ) )
    assert_equal( 981169518316, storage.slice_start_timestamp( time + 25 ) )
    assert_equal( 981169593313, storage.slice_start_timestamp( time + 100 ) )
  end

  def test_slice_start_timestamp_with_slice_size_less_than_a_second
    storage = TimeWindowDropCollector::Storage.new( nil, 100, 101 )
    time    = Time.new( 2001, 2, 3, 4, 5 )

    assert_equal( 981169499970, storage.slice_start_timestamp( time ) )
    assert_equal( 981169500960, storage.slice_start_timestamp( time + 1 ) )
    assert_equal( 981169508880, storage.slice_start_timestamp( time + 9 ) )
    assert_equal( 981169524720, storage.slice_start_timestamp( time + 25 ) )
    assert_equal( 981169599960, storage.slice_start_timestamp( time + 100 ) )
  end

  def test_window_size_consistency
    window  = 100
    slices  = 10
    storage = TimeWindowDropCollector::Storage.new( nil, window, slices )
    time    = Time.new( 2001, 2, 3, 4, 5 )

    first_slice = storage.slice_start_timestamp( time )
    last_slice = storage.slice_start_timestamp( time + 101 )

    assert_equal( window, ( last_slice - first_slice ) / 1000 )
  end

  def test_window_size_consistency_with_slice_sizes_no_integer
    window  = 100
    slices  = 12
    storage = TimeWindowDropCollector::Storage.new( nil, window, slices )
    time    = Time.new( 2001, 2, 3, 4, 5 )

    first_slice = storage.slice_start_timestamp( time )
    last_slice = storage.slice_start_timestamp( time + 101 )

    assert_equal( 99, ( last_slice - first_slice ) / 1000 )
  end

  def test_window_size_consistency_with_slice_sizes_less_than_a_second
    window  = 100
    slices  = 101
    storage = TimeWindowDropCollector::Storage.new( nil, window, slices )
    time    = Time.new( 2001, 2, 3, 4, 5 )

    first_slice = storage.slice_start_timestamp( time )
    last_slice = storage.slice_start_timestamp( time + 101 )

    assert_equal( window, ( last_slice - first_slice ) / 1000 )
  end

  def test_integration_store_of_the_count_for_10_minutes
    client  = TimeWindowDropCollector::Wrapper.instance( :mock )
    storage = TimeWindowDropCollector::Storage.new( client, 600, 10 )

    Delorean.time_travel_to( '2012-01-03 11:00' ) do
      storage.incr( ["key_1"] )
    end

    Delorean.time_travel_to( '2012-01-03 11:01' ) do
      storage.incr( ["key_1"] )
    end

    Delorean.time_travel_to( '2012-01-03 11:02' ) do
      storage.incr( ["key_1"] )
    end

    Delorean.time_travel_to( '2012-01-03 11:03' ) do
      storage.incr( ["key_1"] )
    end

    Delorean.time_travel_to( '2012-01-03 11:04' ) do
      storage.incr( ["key_1"] )
    end

    Delorean.time_travel_to( '2012-01-03 11:05' ) do
      storage.incr( ["key_1"] )
    end

    Delorean.time_travel_to( '2012-01-03 11:06' ) do
      storage.incr( ["key_1"] )
    end

    Delorean.time_travel_to( '2012-01-03 11:07' ) do
      storage.incr( ["key_1"] )
    end

    Delorean.time_travel_to( '2012-01-03 11:08' ) do
      storage.incr( ["key_1"] )
    end

    Delorean.time_travel_to( '2012-01-03 11:09' ) do
      storage.incr( ["key_1"] )
    end

    Delorean.time_travel_to( '2012-01-03 11:10' ) do
      storage.incr( ["key_1"] )
    end

    # counters
    Delorean.time_travel_to( '2012-01-03 10:59' ) do
      assert_equal( nil, storage.count( ["key_1"] )["key_1"] )
    end

    Delorean.time_travel_to( '2012-01-03 11:00' ) do
      assert_equal( 1, storage.count( ["key_1"] )["key_1"] )
    end

    Delorean.time_travel_to( '2012-01-03 11:05' ) do
      assert_equal( 6, storage.count( ["key_1"] )["key_1"] )
    end

    Delorean.time_travel_to( '2012-01-03 11:10' ) do
      assert_equal( 10,  storage.count( ["key_1"] )["key_1"])
    end

    Delorean.time_travel_to( '2012-01-03 11:15' ) do
      assert_equal( 5, storage.count( ["key_1"] )["key_1"] )
    end

    Delorean.time_travel_to( '2012-01-03 11:19' ) do
      assert_equal( 1,  storage.count( ["key_1"] )["key_1"] )
    end

    Delorean.time_travel_to( '2012-01-03 11:20' ) do
      assert_equal( nil,  storage.count( ["key_1"] )["key_1"] )
    end
  end
end