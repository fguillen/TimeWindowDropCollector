require_relative "test_helper"

class MemcacheWrapperTest < Test::Unit::TestCase
  def test_initialize
    Dalli::Client.expects( :new ).with( ["arg1"] ).returns( "client" )
    wrapper = TimeWindowDropCollector::Wrappers::Memcache.new( ["arg1"] )
    assert_equal( "client", wrapper.client )
  end

  def test_incr
    wrapper = TimeWindowDropCollector::Wrappers::Memcache.new( ["arg1"] )
    wrapper.client.expects( :incr ).with( "key", 5, "expire_time", 1)
    wrapper.incr( ["key"], "expire_time", 5 )
  end

  def test_decr
    wrapper = TimeWindowDropCollector::Wrappers::Memcache.new( ["arg1"] )
    wrapper.client.expects( :decr ).with( "key", 5, "expire_time", -1)
    wrapper.decr( ["key"], "expire_time", 5 )
  end
end
