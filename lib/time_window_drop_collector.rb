require "dalli"

require_relative "time_window_drop_collector/version"
require_relative "time_window_drop_collector/config"
require_relative "time_window_drop_collector/logger"
require_relative "time_window_drop_collector/utils"
require_relative "time_window_drop_collector/storage"
require_relative "time_window_drop_collector/wrapper"
require_relative "time_window_drop_collector/results"
require_relative "time_window_drop_collector/wrappers/memcache"
require_relative "time_window_drop_collector/wrappers/mock"
require_relative "time_window_drop_collector/wrappers/redis"
require_relative "time_window_drop_collector/wrappers/rails_cache"

class TimeWindowDropCollector
  attr_reader :config, :wrapper, :storage

  def initialize( &block )
    TimeWindowDropCollector::Logger.log "INITIALIZING version: #{TimeWindowDropCollector::VERSION}"

    @config = {
      :window       => 600,
      :slices       => 10,
      :client       => :memcache,
      :client_opts  => "localhost:11211"
    }

    @config.merge!( TimeWindowDropCollector::Config.extract( block ) ) if block_given?

    TimeWindowDropCollector::Logger.log "CONFIG: #{config}"

    @wrapper = TimeWindowDropCollector::Wrapper.instance( config[:client], config[:client_opts] )
    @storage = TimeWindowDropCollector::Storage.new( wrapper, config[:window], config[:slices] )
  end

  def drop( keys, amount=1 )
    keys = [keys] unless keys.is_a? Array
    keys = keys.map(&:to_s)

    TimeWindowDropCollector::Logger.log "DROP keys: #{keys.join(", ")}, amount: #{amount}"
    storage.incr( keys, amount )
  end

  def pick( time, keys, amount=1)
    keys = [keys] unless keys.is_a? Array
    keys = keys.map(&:to_s)

    TimeWindowDropCollector::Logger.log "PICK keys: #{keys.join(", ")}, amount: #{amount}"

    storage.decr( time, keys, amount )
  end

  def count( orig_keys )
    keys = orig_keys.is_a?(Array) ? orig_keys : [orig_keys]
    keys = keys.map(&:to_s)

    TimeWindowDropCollector::Logger.log "COUNT keys: #{keys.join(", ")}"

    result = storage.count( keys )
    result = TimeWindowDropCollector::Results.new( result )
    result = result[orig_keys.to_s] unless orig_keys.is_a? Array

    TimeWindowDropCollector::Logger.log "COUNT result: #{result}"

    result
  end

  def reset
    wrapper.reset
  end
end
