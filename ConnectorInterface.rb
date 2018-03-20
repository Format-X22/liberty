require_relative 'Log'

class ConnectorInterface
	attr_reader :position

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

	def position?
		# abstract
	end

	def cycle(&iteration)
		# abstract
	end

end