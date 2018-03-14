class Calm

	def initialize(max)
		@max = max
		@val = max
	end

	def refill
		@val = @max
	end

	def dec
		@val -= 1
	end

	def done?
		@val == 0
	end

end