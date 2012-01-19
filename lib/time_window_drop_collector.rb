require "dalli"

require_relative "time_window_drop_collector/version"
require_relative "time_window_drop_collector/config"
require_relative "time_window_drop_collector/logger"
require_relative "time_window_drop_collector/storage"
require_relative "time_window_drop_collector/wrapper"
require_relative "time_window_drop_collector/wrappers/memcache"
require_relative "time_window_drop_collector/wrappers/mock"
require_relative "time_window_drop_collector/wrappers/redis"
require_relative "time_window_drop_collector/wrappers/rails_cache"

class TimeWindowDropCollector
  attr_reader :config, :client, :storage

  def initialize( &block )
    @config = {
      :window       => 600,
      :slices       => 10,
      :client       => :memcache,
      :client_opts  => "localhost:11211"
    }

    @config.merge!( TimeWindowDropCollector::Config.extract( block ) ) if block_given?

    @client  = TimeWindowDropCollector::Wrapper.instance( config[:client], config[:client_opts] )
    @storage = TimeWindowDropCollector::Storage.new( client, config[:window], config[:slices] )
  end

  def drop( key )
    storage.incr( key )
  end

  def count( key )
    storage.count( key )
  end
end
