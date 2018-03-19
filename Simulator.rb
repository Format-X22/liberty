require_relative 'ConnectorInterface'
require_relative 'Candle'
require_relative 'Position'

class Simulator < ConnectorInterface

	def initialize(opt)
		@opt = opt
		@data = Marshal.restore File.read 'sim.txt'
		@history = []
		@position = Position.new
	end

	def long(take)
		@position.open(@candle)

		# TODO make close trigger
	end

	def short(take)
		@position.open(@candle)

		# TODO make close trigger
	end

	def move_take(take)
		# TODO modify close trigger
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

			iteration.call
		end
	end

	private

	#

end