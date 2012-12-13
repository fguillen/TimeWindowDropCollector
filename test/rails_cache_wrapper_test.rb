require_relative "test_helper"

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
    wrapper.client.expects( :increment ).with( "key1", 1, :expires_in => "expire_time" )
    wrapper.client.expects( :increment ).with( "key2", 1, :expires_in => "expire_time" )

    wrapper.incr( ["key1", "key2"], "expire_time" )
  end

  def test_incr_with_custom_amount
    wrapper = TimeWindowDropCollector::Wrappers::RailsCache.new( ["arg1"] )
    wrapper.client.expects( :increment ).with( "key1", 5, :expires_in => "expire_time" )
    wrapper.client.expects( :increment ).with( "key2", 5, :expires_in => "expire_time" )

    wrapper.incr( ["key1", "key2"], "expire_time", 5 )
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