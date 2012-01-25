class TimeWindowDropCollector
  module Wrappers
    class Memcache
      attr_reader :client

      def initialize( opts )
        @client = Dalli::Client.new( opts )
      end

      def incr( key, expire_time )
        client.incr( key, 1, expire_time, 1 )
      end

      def values_for( keys )
        client.get_multi( keys ).values
      end
    end
  end
end
