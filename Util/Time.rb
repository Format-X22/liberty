module Util
	class Time
		attr_writer :direct_time

		def initialize(direct = false)
			@direct = direct
			@direct_time = nil
		end

		def now
			if @direct
				@direct_time
			else
				Object::Time.now
			end
		end

		def now_text
			now.strftime('%Y-%m-%d %H:%M')
		end

	end
end
