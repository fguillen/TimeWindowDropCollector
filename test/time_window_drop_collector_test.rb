require_relative "test_helper"

class TimeWindowDropCollectorTest < Test::Unit::TestCase
  def setup
    @twdc = TimeWindowDropCollector::Logger.stubs( :log )
  end

  def test_initialize_with_empty_config
    TimeWindowDropCollector::Config.expects( :extract ).never
    TimeWindowDropCollector::Wrapper.expects( :instance ).with( :memcache, "localhost:11211" ).returns( "client" )
    TimeWindowDropCollector::Storage.expects( :new ).with( "client", 600, 10 ).returns( "storage" )

    twdc = TimeWindowDropCollector.new

    assert_equal( "client", twdc.client )
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
    TimeWindowDropCollector::Wrapper.expects( :instance ).with( "client", "client_opts" ).returns( "client" )
    TimeWindowDropCollector::Storage.expects( :new ).with( "client", "window", "slices" ).returns( "storage" )

    twdc = TimeWindowDropCollector.new {}
  end

  def test_drop
    storage = mock()
    storage.expects( :incr ).with( "key" )

    twdc = TimeWindowDropCollector.new
    twdc.stubs( :storage ).returns( storage )

    twdc.drop( "key" )
  end

  def test_count
    storage = mock()
    storage.expects( :count ).with( "key" )

    twdc = TimeWindowDropCollector.new
    twdc.stubs( :storage ).returns( storage )

    twdc.count( "key" )
  end
end
