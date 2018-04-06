#!/usr/bin/env ruby

$LOAD_PATH << '../lib'

require_relative '../lib/grin'

[:westmontrose, :bridgeport, :doon, :galt].each do |station|
    flow = GRIN.waterflow(station)
    # ap flow
    unless flow.nil?
        print station.to_s.capitalize, " %.2f m3/s" % flow, " (", "%d%% Summer low)\n" % (GRIN.relative_flow(station)*100)
    else
        print "problem with station ", station
    end
end

