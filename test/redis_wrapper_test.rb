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

    wrapper.client.expects( :incr ).with( "key1" )
    wrapper.client.expects( :expire ).with( "key1", "expire_time" )

    wrapper.client.expects( :incr ).with( "key2" )
    wrapper.client.expects( :expire ).with( "key2", "expire_time" )

    wrapper.incr( ["key1", "key2"], "expire_time" )
  end

  def test_incr_agregates_commands_under_multi
    Redis.expects( :new ).returns( RedisMock.new )
    wrapper = TimeWindowDropCollector::Wrappers::Redis.new( nil )

    wrapper.client.expects( :multi )

    wrapper.incr( nil, nil )
  end

  def test_get
    Redis.expects( :new ).returns( RedisMock.new )
    wrapper = TimeWindowDropCollector::Wrappers::Redis.new( nil )

    wrapper.client.expects( :mget ).with( "key1", "key2" ).returns( [1, 2] )

    assert_equal( { "key1" => 1, "key2" => 2 }, wrapper.get( ["key1", "key2"] ))
  end
end