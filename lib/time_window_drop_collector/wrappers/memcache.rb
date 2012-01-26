class TimeWindowDropCollector
  module Wrappers
    class Memcache
      attr_reader :client

      def initialize( opts )
        @client = Dalli::Client.new( opts )
      end

      def incr( keys, expire_time )
        client.multi do
          keys.each do |key|
            client.incr( key, 1, expire_time, 1 )
          end
        end
      end

      def get( keys )
        client.get_multi( keys )
      end
    end
  end
end
