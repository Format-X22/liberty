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

class Trigger

	attr_reader :tick, :prepare_tick, :direction

	def update
		#
	end

end

class Tick
	attr_reader :index,
		:open, :close, :high, :low,
		:red, :green,
		:ma_cross, :last_ma_cross

	def update
		#
	end

	def break?
		#
	end


end

class PolymorphLang

	def initialize
		@tick = Tick.new
		@trigger = Trigger.new
		@connector = nil
		@calm = Calm.new(0) # todo
	end

	def prepare_cycle
		@tick.update
		@trigger.update
	end

	

	def make_long_position
		@connector.long
	end

	def make_short_position
		@connector.short
	end

	def make_zero_position
		@connector.zero
	end

	def double_ma_cross?
		@connector.position_tick.index < @tick.last_ma_cross
	end

	def so_fast_return?
		@trigger.prepare_tick.index > @trigger.tick.index and
		@trigger.prepare_tick.index - @trigger.tick.index <= (@opt.fast_trig_return + 1)
	end

	def current_is_break?
		@tick.break?
	end

	def in_position?
		!!@connector.position
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

	def position_closed?
		@connector.position_closed?
	end

	def trig?
		@trigger.tick.index == @tick.index
	end

	def so_fast_trig?
		@trigger.tick.index - @trigger.prepare_tick.index <= (@opt.fast_trig + 1)
	end

	def squeeze?
		(@tick.green > @tick.red and @tick.open < @tick.red and @tick.close < @tick.red) or
		(@tick.green < @tick.red and @tick.open > @tick.red and @tick.close > @tick.red)
	end

	def trig_is_double_break?
		tick = @trigger.tick

		(tick.green > tick.red and tick.high > tick.green and tick.low < tick.red  ) or
		(tick.green < tick.red and tick.high > tick.red   and tick.low < tick.green)
	end

	def current_move_under_trig?
		if trig_direction == :up
			@tick.low  > @tick.red and @tick.high > @tick.green
		else
			@tick.high < @tick.red and @tick.low  < @tick.green
		end
	end

end

class Polymorph < PolymorphLang
	attr_accessor :state

	def initialize
		super
		state :wait
	end

	def cycle
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
				if trig_is_double_break? and not current_move_under_trig?
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

end