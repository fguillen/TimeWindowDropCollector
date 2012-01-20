require_relative "test_helper"

class WrapperTest < Test::Unit::TestCase
  def test_instance_when_memcache
    instance = TimeWindowDropCollector::Wrapper.instance( :memcache, "localhost:11211" )
    assert( instance.is_a? TimeWindowDropCollector::Wrappers::Memcache )
  end

  def test_instance_when_mock
    instance = TimeWindowDropCollector::Wrapper.instance( :mock )
    assert( instance.is_a? TimeWindowDropCollector::Wrappers::Mock )
  end

  def test_instance_when_redis
    instance = TimeWindowDropCollector::Wrapper.instance( :redis, ["server", "port"] )
    assert( instance.is_a? TimeWindowDropCollector::Wrappers::Redis )
  end

  def test_instance_when_rails_cache
    instance = TimeWindowDropCollector::Wrapper.instance( :rails_cache )
    assert( instance.is_a? TimeWindowDropCollector::Wrappers::RailsCache )
  end
end
