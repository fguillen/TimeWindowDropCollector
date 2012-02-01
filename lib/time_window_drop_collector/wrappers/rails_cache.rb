class TimeWindowDropCollector
	module Wrappers
		class RailsCache
			attr_reader :client

			def initialize( opts )
				@client = Rails.cache
			end

			def incr( keys, expire_time )
				keys.each do |key|
					client.increment( key, 1, :expires_in => expire_time )
				end
			end

			def get( keys )
				client.read_multi( keys )
			end

      def reset
        client.quit
      end
		end
	end
end

