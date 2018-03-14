class Options
	attr_accessor :resolution,
		:fast_trig, :fast_trig_return,
		:red_period, :green_period,
		:max_no_green_break_again,
		:calm_period,
		:take, :small_take, :position_ma_mul,
		:prepare_sigma
	# TODO

	def initialize(raw_options)
		raw_options.each do |key, value|
			name = "#{key}=".to_sym
			self.send(name, value)
		end
	end

end