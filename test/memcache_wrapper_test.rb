require_relative "test_helper"

class MemcacheWrapperTest < Test::Unit::TestCase
  def test_initialize
    Dalli::Client.expects( :new ).with( "arg1" ).returns( "client" )
    wrapper = TimeWindowDropCollector::Wrappers::Memcache.new( ["arg1"] )
    assert_equal( "client", wrapper.client )
  end

  def test_incr
    wrapper = TimeWindowDropCollector::Wrappers::Memcache.new( ["arg1"] )
    wrapper.client.expects( :incr ).with( "key", 5, "expire_time", 1 )
    wrapper.incr( "key", "expire_time", 5 )
  end

  def test_values_for
    wrapper = TimeWindowDropCollector::Wrappers::Memcache.new( ["arg1"] )
    wrapper.client.expects( :get_multi ).with( "keys" ).returns( {:a => 1, :b => 2} )
    assert_equal( [1, 2], wrapper.values_for( "keys" ))
  end
end