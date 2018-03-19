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
		@date, @open, @high, @low, @close = raw
	end

	def raw
		[@date, @open, @high, @low, @close]
	end

	def reset
		update([0,0,0,0,0])
	end
end