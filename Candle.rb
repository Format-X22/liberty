class Candle
	attr_reader :date, :open, :high, :low, :close

	def initialize(raw)
		@date, @open, @high, @low, @close = raw
	end
end