require_relative 'Tick'
require_relative 'Trigger'
require_relative 'Calm'

class Polymorph

	def initialize(connector, options)
		@opt = options
		@connector = connector
		@tick = Tick.new(@connector, @opt.red_period, @opt.green_period)
		@trigger = Trigger.new(@tick, @opt.prepare_sigma)
		@calm = Calm.new(@opt.calm_period)

		state :wait

		@connector.cycle do
			@tick.update
			@trigger.update

			iteration
		end
	end

	private

	def iteration
		case state
			when :wait
				if trig? and not squeeze?
					if so_fast_trig?
						state :calm
					else
						state :open
					end
				end

			when :open
				if (trig_is_double_break? and not current_move_under_trig?) or so_fast_return?
					state :calm
				else
					if trig_direction == :up
						make_long_position
					else
						make_short_position
					end

					state :in
				end

			when :in
				if position?
					if no_break_green_again?
						change_to_zero_position
						state :zero
					else
						if so_fast_return? or double_ma_cross?
							change_to_small_position
							state :small
						end
					end
				else
					state :wait
				end

			when :small
				if position?
					if no_break_green_again?
						change_to_zero_position
						state :zero
					end
				else
					state :wait
				end

			when :zero
				unless position?
					state :wait
				end

			when :calm
				reset_trig

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

	def state(val = nil)
		if val
			@state = val
		else
			@state
		end
	end

	def make_long_position
		close = @tick.close
		mul = 1 + @opt.take

		bonus = ((close / @tick.green) - 1) * @opt.position_ma_mul

		@connector.long((close * mul) * (1 + bonus))
	end

	def make_short_position
		close = @tick.close
		mul = 1 - @opt.take

		bonus = ((@tick.green / close) - 1) * @opt.position_ma_mul

		@connector.short((close * mul) * (1 + bonus))
	end

	def change_to_small_position
		if state == :long
			mul = 1 + @opt.small_take
		else
			mul = 1 - @opt.small_take
		end

		take = @connector.position.candle.close * mul

		@connector.move_take(take)
	end

	def change_to_zero_position
		@connector.move_take(@connector.position.candle.close)
	end

	def double_ma_cross?
		if @tick.prev_ma_cross
			@connector.position.candle.date < @tick.prev_ma_cross
		else
			false
		end
	end

	def so_fast_return?
		@trigger.prepare_candle.date > @trigger.candle.date and
		@trigger.prepare_candle.date - @trigger.candle.date <= (@opt.fast_trig_return + 1) * @opt.resolution
	end

	def current_is_break?
		@tick.break?
	end

	def position?
		@connector.position?
	end

	def trig_direction
		@trigger.direction
	end

	def refill_calm
		@calm.refill
	end

	def dec_calm
		@calm.dec
	end

	def calm_done?
		@calm.done?
	end

	def make_position_failed?
		@connector.make_position_failed?
	end

	def trig?
		@trigger.candle.date == @tick.date
	end

	def so_fast_trig?
		@trigger.candle.date - @trigger.prepare_candle.date <= (@opt.fast_trig + 1) * @opt.resolution
	end

	def squeeze?
		(@tick.green > @tick.red and @tick.open < @tick.red and @tick.close < @tick.red) or
		(@tick.green < @tick.red and @tick.open > @tick.red and @tick.close > @tick.red)
	end

	def trig_is_double_break?
		tick = @trigger.candle
		red, green = @tick.ma_registry[tick.date]

		(green > red and tick.high > green and tick.low < red  ) or
		(green < red and tick.high > red   and tick.low < green)
	end

	def current_move_under_trig?
		if trig_direction == :up
			@tick.low  > @tick.red and @tick.high > @tick.green
		else
			@tick.high < @tick.red and @tick.low  < @tick.green
		end
	end

	def no_break_green_again?
		@tick.date - @tick.green_break > @opt.max_no_green_break_again * @opt.resolution
	end

	def reset_trig
		@trigger.reset
	end

end