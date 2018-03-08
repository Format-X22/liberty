class Polymorph
	attr_accessor :state

	def initialize(connector)


		@state = :wait

		case state
			when :wait
				if trig_cross? and not squeeze?
					if so_fast_trig?
						state :calm
					else
						state :open
					end
				end

			when :open
				if trig_is_double_break? and not current_is_break?
					state :calm
				else
					if trig_direction == :up
						make_long_position
						state :position
					else
						make_short_position
						state :position
					end
				end

			when :position
				if make_position_failed?
					state :calm
				else
					if position_closed?
						state :wait
					else
						if so_fast_return? or double_ma_cross?
							make_zero_position
							state :zero
						end
					end
				end

			when :zero
				if make_position_failed?
					if position_closed?
						state :calm
					else
						drop
					end
				else
					if position_closed?
						state :wait
					end
				end

			when :calm
				if current_is_break?
					refill_calm
				else
					dec_calm

					if calm_done?
						refill_calm
						state :wait
					end
				end
		end


	end

	def trig_cross?
		#
	end

	def squeeze?
		#
	end

	def trig_direction
		#
	end

	def in_position?
		#
	end

	def so_fast_trig?
		#
	end

	def trig_is_double_break?
		#
	end

	def current_is_break?
		#
	end

	def make_long_position
		#
	end
	
	def make_short_position
		#
	end

	def refill_calm
		#
	end

	def dec_calm
		#
	end

	def calm_done?
		#
	end

	def make_position_failed?
		#
	end

	def position_closed?
		#
	end

	def so_fast_return?
		#
	end

	def double_ma_cross?
		#
	end

	def make_zero_position
		#
	end

	def is_zero_position?
		#
	end

end