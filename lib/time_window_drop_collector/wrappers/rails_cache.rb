class TimeWindowDropCollector
  module Wrappers
    class RailsCache
      attr_reader :client

      def initialize( opts )
        @client = Rails.cache
      end

      def incr( keys, expire_time, amount )
        keys.each do |key|
          client.increment( key, amount, :expires_in => expire_time )
        end
      end

      def decr( keys, expire_time, amount )
        keys.each do |key|
          client.decrement( key, amount, :expires_in => expire_time )
        end
      end

      def get( keys )
        client.read_multi( *keys, { :raw => true } )
      end

      def reset
        client.reset
      end
    end
  end
end

