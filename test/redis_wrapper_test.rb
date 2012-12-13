require_relative "test_helper"

class RedisMock
  def multi
    yield
  end
  def incrby(key,amount);end
  def expire(key);end
  def mget(keys);end
  def pipelined
    yield
  end
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

    wrapper.client.expects( :incrby ).with( "key1",1 )
    wrapper.client.expects( :expire ).with( "key1", "expire_time" )

    wrapper.client.expects( :incrby ).with( "key2",1 )
    wrapper.client.expects( :expire ).with( "key2", "expire_time" )

    wrapper.incr( ["key1", "key2"], "expire_time" )
  end

  def test_incr_with_custom_amount
    Redis.expects( :new ).returns( RedisMock.new )
    wrapper = TimeWindowDropCollector::Wrappers::Redis.new( nil )

    wrapper.client.expects( :incrby ).with( "key1", 10 )
    wrapper.client.expects( :expire ).with( "key1", "expire_time" )

    wrapper.client.expects( :incrby ).with( "key2", 10 )
    wrapper.client.expects( :expire ).with( "key2", "expire_time" )

    wrapper.incr( ["key1", "key2"], "expire_time", 10 )
  end

  def test_incr_agregates_commands_under_pipelined
    Redis.expects( :new ).returns( RedisMock.new )
    wrapper = TimeWindowDropCollector::Wrappers::Redis.new( nil )

    wrapper.client.expects( :pipelined )

    wrapper.incr( nil, nil )
  end

  def test_get
    Redis.expects( :new ).returns( RedisMock.new )
    wrapper = TimeWindowDropCollector::Wrappers::Redis.new( nil )

    wrapper.client.expects( :mget ).with( "key1", "key2" ).returns( [1, 2] )

    assert_equal( { "key1" => 1, "key2" => 2 }, wrapper.get( ["key1", "key2"] ))
  end

  def test_reset
    client = mock
    Redis.expects( :new ).returns( client )
    wrapper = TimeWindowDropCollector::Wrappers::Redis.new( nil )
    client.expects( :quit )
    wrapper.reset
  end

end