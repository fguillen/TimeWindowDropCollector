require_relative "test_helper"

class MockWrapperTest < Test::Unit::TestCase
  def test_initialize
    MemcacheMock.expects( :new ).returns( "client" )
    wrapper = TimeWindowDropCollector::Wrappers::Mock.new( ["arg1"] )
    assert_equal( "client", wrapper.client )
  end

  def test_incr
    wrapper = TimeWindowDropCollector::Wrappers::Mock.new( ["arg1"] )
    wrapper.client.expects( :incr ).with( "key", 1, nil, 1 )
    wrapper.incr( "key", "expire_time" )
  end

  def test_values_for
    wrapper = TimeWindowDropCollector::Wrappers::Mock.new( ["arg1"] )
    wrapper.client.expects( :get_multi ).with( "keys" ).returns( {:a => 1, :b => 2} )
    assert_equal( [1, 2], wrapper.values_for( "keys" ))
  end
end