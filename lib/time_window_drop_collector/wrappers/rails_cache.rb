class TimeWindowDropCollector
	module Wrappers
		class RailsCache
			attr_reader :client

			def initialize( opts )
				@client = Rails.cache
			end

			def incr( key, expire_time )
				value = client.read( key ).to_i + 1
				client.write( key, value, :expires_in => expire_time )
			end

			def values_for( keys )
				client.read_multi( keys ).values
			end
		end
	end
end

