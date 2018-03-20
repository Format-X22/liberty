require 'colorize'

class Log

	def initialize(time)
		@time = time
	end

	def start
		log 'Start', :bold
	end

	def long
		log 'Long'
	end

	def long_profit
		log 'Close long', :blue
	end

	def long_fail
		log 'Close long', :yellow
	end

	def short
		log 'Short'
	end

	def short_profit
		log 'Close short', :blue
	end

	def short_fail
		log 'Close short', :yellow
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

		File.write('log.txt', "#{value}\n", mode: 'a')
	end

end
