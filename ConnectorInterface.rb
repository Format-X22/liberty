require_relative 'Log'

class ConnectorInterface

	def initialize(opt)
		# abstract
	end

	def long(take)
		# abstract
	end

	def short(take)
		# abstract
	end

	def move_take(take)
		# abstract
	end

	def candle
		# abstract
	end

	def history
		# abstract
	end

	def position_closed?
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