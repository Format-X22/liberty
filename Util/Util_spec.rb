require 'require_all'
require_all './'

describe "Time util" do
	it 'just show current time' do
		expect(Util::Time.new.now.strftime('%d-%m-%Y %H:%M:%S')).to eq(Time.now.strftime('%d-%m-%Y %H:%M:%S'))
	end

	it 'show parsed current time' do
		expect(Util::Time.new.now_text).to eq(Util::Time.new.now.strftime('%Y-%m-%d %H:%M'))
	end

	it 'show direct time' do
		now = Time.now
		obj1 = Util::Time.new(true)
		obj2 = Util::Time.new(false)
		obj3 = Util::Time.new
		obj1.direct_time = now
		obj2.direct_time = now
		obj3.direct_time = now

		expect(obj1.now).to eq(now)
		expect(obj2.now).to_not eq(now)
		expect(obj3.now).to_not eq(now)
	end
end