class TimeWindowDropCollector
	module Wrappers
		class Mock
			attr_reader :client

			def initialize( opts )
				@client = MemcacheMock.new
			end

			def incr( keys, expire_time, amount=1 )
				keys.each do |key|
					client.incr( key, 1, nil, amount )
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