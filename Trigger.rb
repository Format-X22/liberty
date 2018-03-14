class Trigger
	attr_reader :candle, :prepare_candle, :direction

	def initialize(tick, prepare_sigma)
		@tick = tick
		@prepare_sigma = prepare_sigma
	end

	def update
		#
	end

end