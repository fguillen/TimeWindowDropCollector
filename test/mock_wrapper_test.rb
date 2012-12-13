require_relative "test_helper"

class MockWrapperTest < Test::Unit::TestCase
  def test_initialize
    MemcacheMock.expects( :new ).returns( "client" )
    wrapper = TimeWindowDropCollector::Wrappers::Mock.new( ["arg1"] )
    assert_equal( "client", wrapper.client )
  end

  def test_incr
    wrapper = TimeWindowDropCollector::Wrappers::Mock.new( ["arg1"] )
    wrapper.client.expects( :incr ).with( "key1", 1, nil, 1 )
    wrapper.client.expects( :incr ).with( "key2", 1, nil, 1 )
    wrapper.incr( ["key1", "key2"], "expire_time" )
  end

  def test_incr_with_custom_amount
    wrapper = TimeWindowDropCollector::Wrappers::Mock.new( ["arg1"] )
    wrapper.client.expects( :incr ).with( "key1", 2, nil, 1 )
    wrapper.client.expects( :incr ).with( "key2", 2, nil, 1 )
    wrapper.incr( ["key1", "key2"], "expire_time", 2 )
  end

  def test_values_for
    wrapper = TimeWindowDropCollector::Wrappers::Mock.new( ["arg1"] )
    wrapper.client.expects( :get_multi ).with( "keys" ).returns( "keys_values" )
    assert_equal( "keys_values", wrapper.get( "keys" ))
  end

  def test_reset
    wrapper = TimeWindowDropCollector::Wrappers::Mock.new( ["arg1"] )
    wrapper.client.expects( :flush )
    wrapper.reset
  end
end