#!/usr/bin/env ruby

$LOAD_PATH << '../lib'

require 'grin'

[:westmontrose, :bridgeport, :doon, :galt].each do |station|
	print station.to_s.capitalize, " %.2f m3/s" % GRIN.waterflow(station), " (", "%d%% Summer low)\n" % (GRIN.relative_flow(station)*100)
end

