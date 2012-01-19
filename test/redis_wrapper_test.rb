require_relative "test_helper"

class Redis
  def initialize( *opts )
  end
end

class MemcacheWrapperTest < Test::Unit::TestCase
  def test_initialize
    Redis.expects( :new ).with( "arg1", "arg2" ).returns( "client" )
    wrapper = TimeWindowDropCollector::Wrappers::Redis.new( ["arg1", "arg2"] )
    assert_equal( "client", wrapper.client )
  end

  def test_incr
    wrapper = TimeWindowDropCollector::Wrappers::Redis.new( ["arg1"] )
    wrapper.client.expects( :incr ).with( "key" )
    wrapper.incr( "key", "expire_time" )
  end

  def test_values_for
    wrapper = TimeWindowDropCollector::Wrappers::Redis.new( ["arg1"] )
    wrapper.client.expects( :mget ).with( "key1", "key2" ).returns( [1, 2] )
    assert_equal( [1, 2], wrapper.values_for( ["key1", "key2"] ))
  end
end