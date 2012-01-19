require "test/unit"
require "mocha"
require "delorean"
require "memcache_mock"

require_relative "../lib/time_window_drop_collector.rb"

class Test::Unit::TestCase
  FIXTURES = "#{File.dirname( __FILE__ )}/fixtures"
end