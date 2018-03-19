require_relative 'ConnectorInterface'
require_relative 'Candle'
require_relative 'Position'
require_relative 'TimeControl'
require_relative 'Log'

class Simulator < ConnectorInterface

	def initialize(opt)
		@opt = opt
		@data = Marshal.restore File.read 'sim.txt'
		@history = []
		@position = Position.new

		@deposit = 100.0

		@time = TimeControl.new(true)
		@logger = Log.new(@time)
	end

	def long(take)
		fail = @candle.close * (1 - @opt.fail)

		@logger.long
		@position.open(@candle, take, fail)
	end

	def short(take)
		fail = @candle.close * (1 + @opt.fail)

		@logger.short
		@position.open(@candle, take, fail)
	end

	def move_take(take)
		@position.exit_price = take
	end

	def candle
		@candle
	end

	def history
		@logger.start
		@logger.empty
		@history
	end

	def position?
		not @position.closed?
	end

	def cycle(&iteration)
		last = @data.length - 1

		@data.each.with_index do |raw, index|
			@candle = Candle.new(raw)
			@history << @candle

			@time.direct_time = Time.at @candle.date

			handle_position if position?

			iteration.call

			if index == last
				@logger.empty
				@logger.result('cum', @deposit)
			end
		end
	end

	private

	def handle_position
		exit_price = @position.exit_price
		fail_price = @position.fail_price

		if @position.type == :long
			if @candle.low <= fail_price
				fail(fail_price, 1)
			elsif @candle.high > exit_price
				profit(exit_price, 1)
			end
		else
			if @candle.high >= fail_price
				fail(fail_price, -1)
			elsif @candle.low < exit_price
				profit(exit_price, -1)
			end
		end
	end

	def profit(price, direction_mul)
		if direction_mul > 0
			@logger.long_profit
		else
			@logger.short_profit
		end

		close_position(price, direction_mul)
	end

	def fail(price, direction_mul)
		if direction_mul > 0
			@logger.long_fail
		else
			@logger.short_fail
		end

		close_position(price, direction_mul)
	end

	def close_position(close_price, direction_mul)
		open_price = @position.candle.close
		amount = direction_mul * @deposit * @opt.mul
		basic_profit = (1 / open_price - 1 / close_price)

		@deposit += amount * basic_profit
	end

end