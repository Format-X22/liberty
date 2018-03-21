require_relative 'Candle'

class Trigger
	attr_reader :direction, :candle, :prepare_candle, :next_green_date

	def initialize(tick, prepare_sigma)
		@tick = tick
		@prepare_sigma = prepare_sigma
		@candle = Candle.new
		@prepare_candle = Candle.new
	end

	def update
		green = @tick.green
		red = @tick.red
		high = @tick.high
		low = @tick.low

		if (@tick.ma_cross == @tick.date) and ((green >= red and high >= green) or (green < red and low <= green))
			reset
		else
			update_prepare_candle

			if @prepare_candle.date != 0
				update_candle
			end
		end
	end

	def reset
		@candle.reset
		@prepare_candle.reset
		@direction = nil
	end

	private

	def update_prepare_candle
		high = @tick.high
		low = @tick.low

		if @tick.green > @tick.red
			low = low * (1 - @prepare_sigma)
		else
			high = high * (1 + @prepare_sigma)
		end

		if high > @tick.red and low <= @tick.red
			@prepare_candle.update(@tick.raw)
			update_direction
		end
	end

	def update_candle
		if @tick.high > @tick.green and @tick.low <= @tick.green and @candle.date <= @prepare_candle.date
			@candle.update(@tick.raw)
			@next_green_date = 0
			update_direction
		else
			catch_next_green
		end
	end

	def catch_next_green
		if @next_green_date == 0 and @tick.break_green?
			@next_green_date = @tick.date
		end
	end

	def update_direction
		if @tick.green >= @tick.red
			@direction = :up
		else
			@direction = :down
		end
	end

end