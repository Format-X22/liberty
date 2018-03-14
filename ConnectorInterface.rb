class ConnectorInterface

	def long(take)
		# abstract
	end

	def short(take)
		# abstract
	end

	def move_take(take)
		# abstract
	end

	def drop
		# abstract
	end

	def make_position_failed?
		# abstract
	end

	def change_position_failed?
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