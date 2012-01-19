require_relative "test_helper"

class StorageTest < Test::Unit::TestCase
  def setup
    @client = mock()
    @storage = TimeWindowDropCollector::Storage.new( @client, "window", "slices" )
  end

  def test_time_key_when_time_is_present
    timestamp = Time.new( 2001, 2, 3, 4, 5 )
    assert_equal( "drop_window_key_200102030405", @storage.time_key( "key", timestamp ) )
  end

  def test_time_key_when_time_is_not_present
    @storage.stubs( :timestamp ).returns( Time.new( 2012,4,3,2,1 ))
    assert_equal( "drop_window_key_201204030201", @storage.time_key( "key" ))
  end

  def test_time_keys_should_return_10_keys_for_the_last_10_minutes
    keys = [
      "drop_window_key_201201030420",
      "drop_window_key_201201030419",
      "drop_window_key_201201030418",
      "drop_window_key_201201030417",
      "drop_window_key_201201030416",
      "drop_window_key_201201030415",
      "drop_window_key_201201030414",
      "drop_window_key_201201030413",
      "drop_window_key_201201030412",
      "drop_window_key_201201030411"
    ]

    Delorean.time_travel_to( '2012-01-03 04:20' ) do
      assert_equal( keys, @storage.time_keys( "key" ))
    end
  end

  def test_incr
    @storage.expects( :time_key ).with( "key" ).returns( "time_key" )
    @client.expects( :incr ).with( "time_key", "window" )

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

    values = [1, "2", 3, 4, 5]

    @storage.expects( :time_keys ).with( "key" ).returns( "keys" )
    @client.expects( :values_for ).with( "keys" ).returns( values )

    assert_equal( 15, @storage.count( "key" ))
  end

  def test_integration_count
    client  = TimeWindowDropCollector::Wrapper.instance( :mock )
    storage = TimeWindowDropCollector::Storage.new( client, "window", "slices" )

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

  def test_integration_store_of_the_count_for_10_minutes
    key_1 = 1

    Delorean.time_travel_to( '2012-01-03 11:00' ) do
      @storage.incr( key_1 )
    end

    Delorean.time_travel_to( '2012-01-03 11:01' ) do
      @storage.incr( key_1 )
    end

    Delorean.time_travel_to( '2012-01-03 11:02' ) do
      @storage.incr( key_1 )
    end

    Delorean.time_travel_to( '2012-01-03 11:03' ) do
      @storage.incr( key_1 )
    end

    Delorean.time_travel_to( '2012-01-03 11:04' ) do
      @storage.incr( key_1 )
    end

    Delorean.time_travel_to( '2012-01-03 11:05' ) do
      @storage.incr( key_1 )
    end

    Delorean.time_travel_to( '2012-01-03 11:06' ) do
      @storage.incr( key_1 )
    end

    Delorean.time_travel_to( '2012-01-03 11:07' ) do
      @storage.incr( key_1 )
    end

    Delorean.time_travel_to( '2012-01-03 11:08' ) do
      @storage.incr( key_1 )
    end

    Delorean.time_travel_to( '2012-01-03 11:09' ) do
      @storage.incr( key_1 )
    end

    Delorean.time_travel_to( '2012-01-03 11:10' ) do
      @storage.incr( key_1 )
    end

    # counters
    Delorean.time_travel_to( '2012-01-03 10:59' ) do
      assert_equal( 0, @storage.count( key_1 ))
    end

    Delorean.time_travel_to( '2012-01-03 11:00' ) do
      assert_equal( 1, @storage.count( key_1 ))
    end

    Delorean.time_travel_to( '2012-01-03 11:05' ) do
      assert_equal( 6, @storage.count( key_1 ))
    end

    Delorean.time_travel_to( '2012-01-03 11:10' ) do
      assert_equal( 10, @storage.count( key_1 ))
    end

    Delorean.time_travel_to( '2012-01-03 11:15' ) do
      assert_equal( 5, @storage.count( key_1 ))
    end

    Delorean.time_travel_to( '2012-01-03 11:19' ) do
      assert_equal( 1, @storage.count( key_1 ))
    end

    Delorean.time_travel_to( '2012-01-03 11:20' ) do
      assert_equal( 0, @storage.count( key_1 ))
    end
  end
end