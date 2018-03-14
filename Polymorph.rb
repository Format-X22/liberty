class Trigger

	attr_reader :tick, :prepare_tick, :direction

	def initialize(tick_obj)
		@tick_obj = tick_obj
	end

	def update
		#
	end

end

class ConnectorInterface

	def long(take)
		# abstract
	end

	def short(take)
		# abstract
	end

	def move_take(take)
		# abstract
	end

	def drop
		# abstract
	end

	def make_position_failed?
		# abstract
	end

	def change_position_failed?
		# abstract
	end

	def position_closed?
		# abstract
	end

	def tick
		# abstract
	end

	def position?
		# abstract
	end

	def position_tick_date
		# abstract
	end

	def position_tick_close
		# abstract
	end

	def cycle(&iteration)
		# abstract
	end

end

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

class Tick
	attr_reader :date,
		:open, :high, :low, :close,
		:red, :green, :last_green,
		:green_break,
		:ma_cross, :prev_ma_cross

	def initialize(connector, red_period, green_period)
		@connector = connector
		@history = connector.history.dup
		@red_period = red_period
		@green_period = green_period

		update_by_history
	end

	def update(data = nil)
		unless data
			data = @connector.tick
			@history << data
		end

		@date, @open, @high, @low, @close = @history.last

		last = @history.length

		red = @history.sma(last, @red_period)
		green = @history.sma(last, @green_period)

		if (red >= green and @red <= @green) or (red < green and @red > @green)
			@prev_ma_cross = @ma_cross
			@ma_cross = @date
		end

		if high > green and low < green
			@green_break = @date
		end

		@last_green = @green
		@green = green
		@red = red
	end

	def break?
		(high > green and low < green) or
		(high > red   and low < red  )
	end

	private

	def update_by_history
		last_date = nil
		last_red = nil
		last_green = nil

		@history[0...-1].each.with_index do |tick, index|
			next if index < @red_period

			if index == @red_period
				last_date = tick[0]
				last_red = @history.sma(index, @red_period)
				last_green = @history.sma(index, @green_period)
				next
			end

			red = @history.sma(index, @red_period)
			green = @history.sma(index, @green_period)

			if (red >= green and last_red <= last_green) or (red < green and last_red > last_green)
				@prev_ma_cross = @ma_cross
				@ma_cross = last_date
			end
		end

		update(@history.last)
	end

end

class Options
	attr_accessor :resolution,
		:fast_trig, :fast_trig_return,
		:red_period, :green_period,
		:max_no_green_break_again,
		:calm_period,
		:take, :small_take, :position_ma_mul
	# TODO

	def initialize(raw_options)
		raw_options.each do |key, value|
			name = "#{key}=".to_sym
			self.send(name, value)
		end
	end

end

class Polymorph
	attr_accessor :state

	def initialize(connector, raw_options)
		@opt = Options.new(raw_options)
		@connector = connector
		@tick = Tick.new(@connector, @opt.red_period, @opt.green_period)
		@trigger = Trigger.new(@tick)
		@calm = Calm.new(@opt.calm_period)

		state :wait

		@connector.cycle do
			@tick.update
			@trigger.update

			iteration
		end
	end

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
				if make_position_failed?
					state :calm
				else
					if position_closed?
						state :wait
					else
						if no_break_green_again?
							change_to_zero_position
							state :zero
						else
							if so_fast_return? or double_ma_cross?
								change_to_small_position
								state :small
							end
						end
					end
				end

			when :small
				if change_position_failed?
					if position_closed?
						state :calm
					else
						drop
					end
				else
					if position_closed?
						state :wait
					else
						if no_break_green_again?
							change_to_zero_position
							state :zero
						end
					end
				end

			when :zero
				if change_position_failed?
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

	def make_long_position
		close = @connector.position_tick_close
		mul = 1 + @opt.take

		bonus = ((close / @tick.green) - 1) * @opt.position_ma_mul

		@connector.long((close * mul) * (1 + bonus))
	end

	def make_short_position
		close = @connector.position_tick_close
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

		take = @connector.position_tick_close * mul

		@connector.move_take(take)
	end

	def change_to_zero_position
		@connector.move_take(@connector.position_tick_close)
	end

	def double_ma_cross?
		if @tick.prev_ma_cross
			@connector.position_tick_date < @tick.prev_ma_cross
		else
			false
		end
	end

	def so_fast_return?
		@trigger.prepare_tick.date > @trigger.tick.date and
		@trigger.prepare_tick.date - @trigger.tick.date <= (@opt.fast_trig_return + 1) * @opt.resolution
	end

	def current_is_break?
		@tick.break?
	end

	def in_position?
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

	def position_closed?
		@connector.position_closed?
	end

	def trig?
		@trigger.tick.date == @tick.date
	end

	def so_fast_trig?
		@trigger.tick.date - @trigger.prepare_tick.date <= (@opt.fast_trig + 1) * @opt.resolution
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

	def no_break_green_again?
		@tick.date - @tick.green_break > @opt.max_no_green_break_again * @opt.resolution
	end

	def drop
		@connector.drop
	end

end