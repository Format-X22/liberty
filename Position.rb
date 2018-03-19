class Position
	attr_reader :candle

	def initialize
		@closed = false
	end

	def open(candle)
		@closed = false
		@candle = candle
	end

	def close
		@closed = true
		@candle = nil
	end

	def closed?
		@closed
	end
end