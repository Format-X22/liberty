require_relative 'ConnectorInterface'

class Bitmex < ConnectorInterface

	def initialize(opt)
		@opt = opt
	end

	def long(take)
		#
	end

	def short(take)
		#
	end

	def move_take(take)
		#
	end

	def drop
		#
	end

	def candle
		#
	end

	def history
		#
	end

	def make_position_failed?
		#
	end

	def change_position_failed?
		#
	end

	def position_closed?
		#
	end

	def position?
		#
	end

	def position_tick_date
		#
	end

	def position_tick_close
		#
	end

	def cycle(&iteration)
		#
	end

	private

	#

end