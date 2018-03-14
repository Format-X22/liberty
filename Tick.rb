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

		update_by_history
	end

	def update(data = nil)
		unless data
			data = @connector.candle
			@history << data
		end

		@date, @open, @high, @low, @close = data

		last = @history.length
		red, green = ma(last)

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

		@history[0...-1].each.with_index do |candle, index|
			next if index < @red_period

			if index == @red_period
				last_date = candle.date
				last_red = @history.sma(index, @red_period)
				last_green = @history.sma(index, @green_period)
				next
			end

			red, green = ma(index)

			if (red >= green and last_red <= last_green) or (red < green and last_red > last_green)
				@prev_ma_cross = @ma_cross
				@ma_cross = last_date
			end
		end

		update(@history.last)
	end

	def ma(index)
		close = @history.last(@red_period).map{|v| v.close}
		red = close.sma(index, @red_period)
		green = close.sma(index, @green_period)

		[red, green]
	end

end