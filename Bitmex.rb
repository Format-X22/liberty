require 'rest-client'
require 'openssl'
require_relative 'ConnectorInterface'

class Bitmex < ConnectorInterface

	def initialize(opt)
		@opt = opt

		@key, @secret = File.read('key.txt').split "\n"
	end

	def long(take)
		#
	end

	def short(take)
		#
	end

	def move_take(take)
		#
	end

	def candle
		#
	end

	def history
		#
	end

	def position?
		#
	end

	def cycle(&iteration)
		#
	end

	private

	def signature
		#
	end

end



# send

[{"symbol": "XBTUSD",
"orderQty": 1,
"ordType": "Market"},


{"symbol": "XBTUSD",
"orderQty": -1,
"price": 8500,
"ordType": "Limit"}]

# check



# remove orders



# drop position