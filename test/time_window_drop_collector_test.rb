require_relative "test_helper"

class TimeWindowDropCollectorTest < Test::Unit::TestCase
  def setup
  end

  def test_initialize_with_empty_config
    TimeWindowDropCollector::Config.expects( :extract ).never
    TimeWindowDropCollector::Wrapper.expects( :instance ).with( :memcache, "localhost:11211" ).returns( "wrapper" )
    TimeWindowDropCollector::Storage.expects( :new ).with( "wrapper", 600, 10 ).returns( "storage" )

    twdc = TimeWindowDropCollector.new

    assert_equal( "wrapper", twdc.wrapper )
    assert_equal( "storage", twdc.storage )
  end


  def test_initialize_with_block_config
    config = {
      :window       => "window",
      :slices       => "slices",
      :client       => "client",
      :client_opts  => "client_opts"
    }

    TimeWindowDropCollector::Config.expects( :extract ).returns( config )
    TimeWindowDropCollector::Wrapper.expects( :instance ).with( "client", "client_opts" ).returns( "wrapper" )
    TimeWindowDropCollector::Storage.expects( :new ).with( "wrapper", "window", "slices" ).returns( "storage" )

    twdc = TimeWindowDropCollector.new {}
  end

  def test_drop
    storage = mock()
    storage.expects( :incr ).with( ["key"], 1 )

    twdc = TimeWindowDropCollector.new
    twdc.stubs( :storage ).returns( storage )

    twdc.drop( "key" )
  end

  def test_drop_with_custom_amount
    storage = mock()
    storage.expects( :incr ).with( ["key"], 15 )

    twdc = TimeWindowDropCollector.new
    twdc.stubs( :storage ).returns( storage )

    twdc.drop( "key", 15 )
  end

  def test_count
    storage = mock()
    storage.expects( :count ).with( ["key"] ).returns( { "key" => 10 } )

    twdc = TimeWindowDropCollector.new
    twdc.stubs( :storage ).returns( storage )

    assert_equal( 10, twdc.count( "key" ) )
  end

  def test_integration_new
    twdc =
      TimeWindowDropCollector.new do
        client :memcache
        window 100
        slices 20
      end

    assert( twdc.wrapper.is_a? TimeWindowDropCollector::Wrappers::Memcache )
    assert( twdc.wrapper.client.is_a? Dalli::Client )
    assert( twdc.storage.is_a? TimeWindowDropCollector::Storage )

    assert_equal( 100, twdc.storage.window )
    assert_equal( 20, twdc.storage.slices )
  end

  def test_integration_drop_and_count
    twdc = TimeWindowDropCollector.new { client :mock }

    twdc.drop( "key_1" )
    twdc.drop( "key_1" )
    twdc.drop( "key_2" )
    twdc.drop( "key_2" )
    twdc.drop( ["key_2"] )
    twdc.drop( ["key_3", "key_4", "key_5"] )

    assert_equal( 2, twdc.count( "key_1" ) )
    assert_equal( 3, twdc.count( "key_2" ) )
    assert_equal( 1, twdc.count( "key_3" ) )
    assert_equal( 1, twdc.count( "key_4" ) )
    assert_equal( 1, twdc.count( "key_5" ) )
    assert_equal( 0, twdc.count( "key_6" ) )

    assert_equal( 2, twdc.count( ["key_1", "key_2"] )["key_1"] )
    assert_equal( 3, twdc.count( ["key_1", "key_2"] )["key_2"] )
    assert_equal( 0, twdc.count( ["key_6"] )["key_6"] )
  end

  def test_integration_drop_array_keys
    twdc = TimeWindowDropCollector.new { client :mock }

    twdc.drop( ["key_1", "key_2"] )

    assert_equal( 1, twdc.count( "key_1" ) )
    assert_equal( 1, twdc.count( "key_2" ) )
  end

  def test_integration_drop_and_count_with_numerical_keys
    twdc = TimeWindowDropCollector.new { client :mock }

    twdc.drop( 1000 )
    twdc.drop( [1001])

    assert_equal( 1, twdc.count( 1000 ) )
    assert_equal( 1, twdc.count( 1001 ) )
  end

  def test_reset
    twdc = TimeWindowDropCollector.new { client :mock }

    twdc.wrapper.expects(:reset)

    twdc.reset
  end
end
