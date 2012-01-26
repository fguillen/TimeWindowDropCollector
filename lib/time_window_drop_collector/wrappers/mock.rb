class TimeWindowDropCollector
	module Wrappers
		class Mock
			attr_reader :client

			def initialize( opts )
				@client = MemcacheMock.new
			end

			def incr( keys, expire_time )
				keys.each do |key|
					client.incr( key, 1, nil, 1 )
				end
			end

			def get( keys )
				client.get_multi( keys )
			end
		end
	end
end