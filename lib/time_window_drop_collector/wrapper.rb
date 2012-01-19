module TimeWindowDropCollector::Wrapper
  def self.instance( type, opts )
    case type
    when :memcache
      TimeWindowDropCollector::Wrappers::Memcache.new( opts )
    else
      raise ArgumentError, "type not supported: '#{type}'"
    end
  end
end