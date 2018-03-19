require_relative 'ConnectorInterface'
require_relative 'Candle'
require_relative 'Position'

class Simulator < ConnectorInterface

	def initialize(opt)
		@opt = opt
		@data = Marshal.restore File.read 'sim.txt'
		@history = []
		@position = Position.new

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

			if position?
				if @position.type == :long
					if @candle.high > @position.exit_price
						# TODO buy logic
					end
				else
					if @candle.low < @position.exit_price
						# TODO sell logic
					end
				end
			end

			iteration.call
		end
	end

	private

	#

end