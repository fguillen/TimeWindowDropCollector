class TimeWindowDropCollector
  module Wrappers
    class Redis
  		attr_reader :client

      def initialize( opts )
        @client = ::Redis.new( *opts )
      end

  		def incr( key, expire_time )
  			client.incr( key )
  		end

  		def values_for( keys )
  			client.mget( *keys )
  		end
  	end
  end
end

