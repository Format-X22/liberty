require 'colorize'

class Log

	def initialize(time)
		@time = time
	end

	def start
		log 'Start', :bold
	end

	def buy
		log 'Buy'
	end

	def buy_profit
		log 'Close buy', :blue
	end

	def buy_fail
		log 'Close buy', :yellow
	end

	def sell
		log 'Sell'
	end

	def sell_profit
		log 'Close sell', :blue
	end

	def sell_fail
		log 'Close sell', :yellow
	end

	def error(prefix, value)
		log "ERROR #{prefix} -> #{value}", :red
	end

	def empty
		log
	end

	def result(prefix, value)
		log "RESULT #{prefix} -> #{value.round(2)}", :bold
	end

	private

	def log(value = nil, color = nil)
		if value
			value = "#{@time.now_text} - #{value}"
		else
			value = @time.now_text
		end

		if color
			puts value.send(color)
		else
			puts value
		end

		File.write('Storage/log.txt', "#{value}\n", mode: 'a')
	end

end
