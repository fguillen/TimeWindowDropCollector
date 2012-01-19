require_relative "test_helper"

class Rails
end

class MemcacheWrapperTest < Test::Unit::TestCase
  def setup
    @rails_client = mock()
    Rails.stubs( :cache ).returns( @rails_cache )
  end

  def test_initialize
    Rails.expects( :cache ).returns( "client" )
    wrapper = TimeWindowDropCollector::Wrappers::RailsCache.new( ["arg1"] )
    assert_equal( "client", wrapper.client )
  end

  def test_incr
    wrapper = TimeWindowDropCollector::Wrappers::RailsCache.new( ["arg1"] )
    wrapper.client.expects( :read ).with( "key" ).returns( 2 )
    wrapper.client.expects( :write ).with( "key", 3, :expires_in => "expire_time" )

    wrapper.incr( "key", "expire_time" )
  end

  def test_values_for
    wrapper = TimeWindowDropCollector::Wrappers::RailsCache.new( ["arg1"] )
    wrapper.client.expects( :read_multi ).with( "keys" ).returns( {:a => 1, :b => 2} )
    assert_equal( [1, 2], wrapper.values_for( "keys" ))
  end
end