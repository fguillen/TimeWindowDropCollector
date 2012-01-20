require_relative "test_helper"

class StorageTest < Test::Unit::TestCase
  def setup
    @client = mock()
    @storage = TimeWindowDropCollector::Storage.new( @client, 600, 10 )
  end

  def test_time_key_when_time_is_present
    timestamp = Time.new( 2001, 2, 3, 4, 5 )
    assert_equal( "drop_window_key_981169500000", @storage.time_key( "key", timestamp ) )
  end

  def test_time_key_when_time_is_not_present
    @storage.stubs( :timestamp ).returns( Time.new( 2012, 4, 3, 2, 1 ))
    assert_equal( "drop_window_key_1333411260000", @storage.time_key( "key" ))
  end

  def test_time_keys_should_return_10_keys_for_the_last_10_minutes
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
      assert_equal( keys, @storage.time_keys( "key" ))
    end
  end

  def test_incr
    @storage.expects( :time_key ).with( "key" ).returns( "time_key" )
    @client.expects( :incr ).with( "time_key", 600 )

    @storage.incr( "key" )
  end

  def test_count
    keys = [
      "drop_window_key_201201031416",
      "drop_window_key_201201031415",
      "drop_window_key_201201031414",
      "drop_window_key_201201031413",
      "drop_window_key_201201031412"
    ]

    values = [nil, 1, "2", 3, 4, 5]

    @storage.expects( :time_keys ).with( "key" ).returns( "keys" )
    @client.expects( :values_for ).with( "keys" ).returns( values )

    assert_equal( 15, @storage.count( "key" ))
  end

  def test_count_when_empty_values
    @storage.stubs( :time_keys )
    @client.expects( :values_for ).returns( [] )
    assert_equal( 0, @storage.count( "key" ))
  end

  def test_integration_count
    client  = TimeWindowDropCollector::Wrapper.instance( :mock )
    storage = TimeWindowDropCollector::Storage.new( client, 600, 10 )

    key_1 = 1
    key_2 = 2
    key_3 = 3

    storage.incr( key_1 )
    storage.incr( key_2 )
    storage.incr( key_3 )
    storage.incr( key_2 )

    assert_equal( 1, storage.count( key_1 ))
    assert_equal( 2, storage.count( key_2 ))
    assert_equal( 1, storage.count( key_3 ))
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

    key_1 = 1

    Delorean.time_travel_to( '2012-01-03 11:00' ) do
      storage.incr( key_1 )
    end

    Delorean.time_travel_to( '2012-01-03 11:01' ) do
      storage.incr( key_1 )
    end

    Delorean.time_travel_to( '2012-01-03 11:02' ) do
      storage.incr( key_1 )
    end

    Delorean.time_travel_to( '2012-01-03 11:03' ) do
      storage.incr( key_1 )
    end

    Delorean.time_travel_to( '2012-01-03 11:04' ) do
      storage.incr( key_1 )
    end

    Delorean.time_travel_to( '2012-01-03 11:05' ) do
      storage.incr( key_1 )
    end

    Delorean.time_travel_to( '2012-01-03 11:06' ) do
      storage.incr( key_1 )
    end

    Delorean.time_travel_to( '2012-01-03 11:07' ) do
      storage.incr( key_1 )
    end

    Delorean.time_travel_to( '2012-01-03 11:08' ) do
      storage.incr( key_1 )
    end

    Delorean.time_travel_to( '2012-01-03 11:09' ) do
      storage.incr( key_1 )
    end

    Delorean.time_travel_to( '2012-01-03 11:10' ) do
      storage.incr( key_1 )
    end

    # counters
    Delorean.time_travel_to( '2012-01-03 10:59' ) do
      assert_equal( 0, storage.count( key_1 ))
    end

    Delorean.time_travel_to( '2012-01-03 11:00' ) do
      assert_equal( 1, storage.count( key_1 ))
    end

    Delorean.time_travel_to( '2012-01-03 11:05' ) do
      assert_equal( 6, storage.count( key_1 ))
    end

    Delorean.time_travel_to( '2012-01-03 11:10' ) do
      assert_equal( 10, storage.count( key_1 ))
    end

    Delorean.time_travel_to( '2012-01-03 11:15' ) do
      assert_equal( 5, storage.count( key_1 ))
    end

    Delorean.time_travel_to( '2012-01-03 11:19' ) do
      assert_equal( 1, storage.count( key_1 ))
    end

    Delorean.time_travel_to( '2012-01-03 11:20' ) do
      assert_equal( 0, storage.count( key_1 ))
    end
  end
end