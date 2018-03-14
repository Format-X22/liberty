require_relative 'Options'
require_relative 'Polymorph'
require_relative 'Config'

OPTIONS = Options.new(Config.options)

if Config.prod?
	require_relative 'Bitmex'
	PROXY = Bitmex.new(OPTIONS)
else
	require_relative 'Simulator'
	PROXY = Simulator.new(OPTIONS)
end

Polymorph.new(PROXY, OPTIONS)