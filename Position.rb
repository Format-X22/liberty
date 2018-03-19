class Position
	attr_reader :type, :candle, :fail_price
	attr_accessor :exit_price

	def initialize
		@closed = false
	end

	def open(candle, exit_price, fail_price)
		@closed = false
		@candle = candle
		@exit_price = exit_price
		@fail_price = fail_price

		if exit_price > fail_price
			@type = :long
		else
			@type = :short
		end
	end

	def close
		@closed = true
		@candle = nil
		@type = nil
		@exit_price = nil
		@fail_price = nil
	end

	def closed?
		@closed
	end
end