class TimeWindowDropCollector
  module Wrappers
    class Memcache
      attr_reader :client

      def initialize( opts )
        @client = Dalli::Client.new( opts )
      end

      def incr( keys, expire_time, amount )
        client.multi do
          keys.each do |key|
            client.incr( key, amount, expire_time, 1 )
          end
        end
      end

      def get( keys )
        client.get_multi( keys )
      end

      def reset
        client.reset
      end
    end
  end
end
