class Candle
	attr_reader :date, :open, :high, :low, :close

	def initialize(raw = nil)
		if raw
			update(raw)
		else
			reset
		end
	end

	def update(raw)
		raise 'Invalid raw candle' if raw.size != 5

		@date, @open, @high, @low, @close = raw
	end

	def raw
		[@date, @open, @high, @low, @close]
	end

	def reset
		update([0,0,0,0,0])
	end
end