require_relative "test_helper"

class RedisMock
  def multi(&block)
    yield
  end
  def incr(key);end
  def expire(key);end
  def mget(keys);end
end

class RedisWrapperTest < Test::Unit::TestCase
  def test_initialize
    Redis.expects( :new ).with( ["arg1", "arg2"] ).returns( "client" )
    wrapper = TimeWindowDropCollector::Wrappers::Redis.new( ["arg1", "arg2"] )

    assert_equal( "client", wrapper.client )
  end

  def test_incr
    Redis.expects( :new ).returns( RedisMock.new )
    wrapper = TimeWindowDropCollector::Wrappers::Redis.new( nil )

    wrapper.client.expects( :incr ).with( "key" )
    wrapper.client.expects( :expire ).with( "key", "expire_time" )

    wrapper.incr( "key", "expire_time" )
  end

  def test_incr_agregates_commands_under_multi
    Redis.expects( :new ).returns( RedisMock.new )
    wrapper = TimeWindowDropCollector::Wrappers::Redis.new( nil )

    wrapper.client.expects( :multi )

    wrapper.incr( nil, nil )
  end

  def test_values_for
    Redis.expects( :new ).returns( RedisMock.new )
    wrapper = TimeWindowDropCollector::Wrappers::Redis.new( nil )

    wrapper.client.expects( :mget ).with( "key1", "key2" ).returns( [1, 2] )

    assert_equal( [1, 2], wrapper.values_for( ["key1", "key2"] ))
  end
end