require 'json'
require 'rest-client'
require 'time'
require 'active_support/core_ext/numeric/time'
require 'active_support/core_ext/integer/time'

class SimLoader

	URL = 'https://www.bitmex.com/api/udf/history'
	MAX_TICKS_MUL = 10000 * 60
	SAFE_TIME_MARGIN = 1000
	STORAGE = 'sim.txt'

	def load(start, resolution)
		@resolution = resolution
		@from = start.to_i
		@to = next_chunk
		@stop = Time.now.to_i
		@result_hash = {}

		cycle

		File.write STORAGE, Marshal.dump(@result_hash.values)
	end

	private

	def cycle
		loop do
			if @from > @stop
				break
			end

			response = RestClient.get(URL, params: params)
			data = JSON.parse response.body

			begin
				puts data['t'].length

				extract_tick(data)
			rescue
				puts data
				raise 'Parsing fail'
			end

			@from = next_chunk
			@to = next_chunk
		end
	end

	def extract_tick(data)
		data['t'].each.with_index do |date, index|
			@result_hash[date] = [
				date,
				data['o'][index],
				data['h'][index],
				data['l'][index],
				data['c'][index]
			]
		end
	end

	def next_chunk
		@from + (MAX_TICKS_MUL * @resolution) - SAFE_TIME_MARGIN
	end

	def params
		{
			symbol: 'XBTUSD',
			from: @from,
			to: @to,
			resolution: @resolution
		}
	end

end

SimLoader.new.load(30.month.ago, 5)