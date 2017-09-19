require_relative "test_helper"

class RailsCacheWrapperTest < MiniTest::Test
  def setup
    rails_cache = mock()
    Rails.stubs( :cache ).returns( rails_cache )
  end

  def test_initialize
    Rails.expects( :cache ).returns( "client" )
    wrapper = TimeWindowDropCollector::Wrappers::RailsCache.new( ["arg1"] )
    assert_equal( "client", wrapper.client )
  end

  def test_incr
    wrapper = TimeWindowDropCollector::Wrappers::RailsCache.new( ["arg1"] )
    wrapper.client.expects( :increment ).with( "key1", 5, :expires_in => "expire_time" )
    wrapper.client.expects( :increment ).with( "key2", 5, :expires_in => "expire_time" )

    wrapper.incr( ["key1", "key2"], "expire_time", 5 )
  end

  def test_decr
    wrapper = TimeWindowDropCollector::Wrappers::RailsCache.new( ["arg1"] )
    wrapper.client.expects( :decrement ).with( "key1", 5, :expires_in => "expire_time" )
    wrapper.client.expects( :decrement ).with( "key2", 5, :expires_in => "expire_time" )

    wrapper.decr( ["key1", "key2"], "expire_time", 5 )
  end

  def test_values_for
    wrapper = TimeWindowDropCollector::Wrappers::RailsCache.new( ["arg1"] )
    wrapper.client.expects( :read_multi ).with( "keys" ).returns( "keys_values" )
    assert_equal( "keys_values", wrapper.get( "keys" ))
  end

  def test_reset
    wrapper = TimeWindowDropCollector::Wrappers::RailsCache.new( ["arg1"] )
    wrapper.client.expects( :reset )
    wrapper.reset
  end
end
