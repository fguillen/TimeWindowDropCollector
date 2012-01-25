require "test/unit"
require "mocha"
require "delorean"
require "memcache_mock"
require "redis"

require_relative "../lib/time_window_drop_collector.rb"

# mocking big classes
class Rails
  def self.cache
  end
end