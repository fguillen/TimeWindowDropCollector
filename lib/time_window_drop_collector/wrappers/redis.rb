class TimeWindowDropCollector
  module Wrappers
    class Redis
  		attr_reader :client

      def initialize( opts )
        @client = ::Redis.new( opts )
      end

  		def incr( keys, expire_time )
        client.multi do
          keys.each do |key|
            client.incr( key )
            client.expire( key, expire_time )
          end
        end
  		end

  		def get( keys )
  			values = client.mget( *keys )

        result = {}

        keys.each_with_index do |key, i|
          result[key] = values[i]
        end

        result
  		end
  	end
  end
end

