class TimeWindowDropCollector
  module Wrappers
    class Mock
      attr_reader :client

      def initialize( opts )
        @client = MemcacheMock.new
      end

      def incr( keys, expire_time, amount )
        keys.each do |key|
          client.incr( key, amount, nil, 1 )
        end
      end

      def decr( keys, expire_time, amount )
        keys.each do |key|
          client.decr( key, amount, nil, -1 )
        end
      end

      def get( keys )
        client.get_multi( keys )
      end

      def reset
        client.flush
      end
    end
  end
end
