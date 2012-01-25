class TimeWindowDropCollector
  module Wrappers
    class Redis
  		attr_reader :client

      def initialize( opts )
        @client = ::Redis.new( opts )
      end

  		def incr( key, expire_time )
        client.multi do
          client.incr( key )
          client.expire( key, expire_time )
        end
  		end

  		def values_for( keys )
  			client.mget( *keys )
  		end
  	end
  end
end

