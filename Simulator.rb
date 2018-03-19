require_relative 'ConnectorInterface'
require_relative 'Candle'
require_relative 'Position'

class Simulator < ConnectorInterface

	def initialize(opt)
		@opt = opt
		@data = Marshal.restore File.read 'sim.txt'
		@history = []
		@position = Position.new

		@deposit = 1.0

		# TODO logger
	end

	def long(take)
		fail = @candle.close * (1 - @opt.fail)
		
		@position.open(@candle, take, fail)
	end

	def short(take)
		fail = @candle.close * (1 + @opt.fail)

		@position.open(@candle, take, fail)
	end

	def move_take(take)
		@position.exit_price = take
	end

	def candle
		@candle
	end

	def history
		@history
	end

	def position?
		not @position.closed?
	end

	def cycle(&iteration)
		@data.each do |raw|
			@candle = Candle.new(raw)
			@history << @candle

			handle_position if position?

			iteration.call
		end
	end

	private

	def handle_position
		if @position.type == :long
			if @candle.low <= @position.fail_price
				fail(@position.fail_price, 1)
			elsif @candle.high > @position.exit_price
				profit(@position.exit_price, 1)
			end
		else
			if @candle.high >= @position.fail_price
				fail(@position.fail_price, -1)
			elsif @candle.low < @position.exit_price
				profit(@position.exit_price, -1)
			end
		end
	end

	def profit(price, direction_mul)
		# TODO log profit

		close_position(price, direction_mul)
	end

	def fail(price, direction_mul)
		# TODO log fail

		close_position(price, direction_mul)
	end

	def close_position(close_price, direction_mul)
		amount = direction_mul * @deposit * @opt.mul
		basic_profit = (1 / @position.candle.close - 1 / close_price)

		@deposit += amount * basic_profit
	end

end