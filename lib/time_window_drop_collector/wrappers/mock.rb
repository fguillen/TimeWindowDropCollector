class TimeWindowDropCollector
	module Wrappers
		class Mock
			attr_reader :client

			def initialize( opts )
				@client = MemcacheMock.new
			end

			def incr( key, expire_time )
				client.incr( key, 1, nil, 1 )
			end

			def values_for( keys )
				client.get_multi( keys ).values
			end
		end
	end
end