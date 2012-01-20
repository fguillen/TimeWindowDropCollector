module TimeWindowDropCollector::Wrapper
  def self.instance( type, opts = nil )
    case type
    when :memcache
      TimeWindowDropCollector::Wrappers::Memcache.new( opts )
    when :redis
      TimeWindowDropCollector::Wrappers::Redis.new( opts )
    when :rails_cache
      TimeWindowDropCollector::Wrappers::RailsCache.new( opts )
    when :mock
      TimeWindowDropCollector::Wrappers::Mock.new( opts )
    else
      raise ArgumentError, "type not supported: '#{type}'"
    end
  end
end