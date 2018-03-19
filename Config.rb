# TODO Check ma calc
# TODO Check profit/fail calc

class Config

	def self.prod?
		false
	end

	def self.options
		{
			resolution: 5,
			fast_trig: 5,
			fast_trig_return: 5,
			red_period: 100,
			green_period: 50,
			max_no_green_break_again: 10,
			calm_period: 12,
			take: 0.01,
			fail: 0.1,
			small_take: 0.002,
			position_ma_mul: 2,
			prepare_sigma: 0.001
		}
	end
end