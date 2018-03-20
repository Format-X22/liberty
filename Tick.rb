require 'moving_average'
require_relative 'Candle'

class Tick < Candle
	attr_reader :red, :green,
		:last_green, :green_break,
		:ma_cross, :prev_ma_cross

	def initialize(connector, red_period, green_period)
		@connector = connector
		@history = connector.history.dup
		@red_period = red_period
		@green_period = green_period

		update(@history.last)
	end

	def update(candle = nil)
		unless candle
			candle = @connector.candle
			@history << data
		end

		@date, @open, @high, @low, @close = candle.raw

		last = @history.length - 1
		red, green = ma(last)

		@red ||= red
		@green ||= green

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

	def ma(index)
		close = @history.last(@red_period + 1).map{|v| v.close}
		
		red = close.sma(index, @red_period)
		green = close.sma(index, @green_period)

		[red, green]
	end

end