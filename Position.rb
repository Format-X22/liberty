class Position
	attr_reader :type, :candle, :fail_price, :exit_price

	def initialize
		@closed = true
	end

	def open(candle, exit_price, fail_price)
		raise 'Open opened position' if closed?

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
		raise 'Close closed position' if closed?

		@closed = true
		@candle = nil
		@type = nil
		@exit_price = nil
		@fail_price = nil
	end

	def closed?
		@closed
	end

	def exit_price=(val)
		raise 'Position closed' if closed?

		if (exit_price <= fail_price and val > fail_price) or (exit_price >= fail_price and val < fail_price)
			raise 'Invalid exit price'
		else
			@exit_price = val
		end
	end
end