#!/usr/bin/env ruby

$LOAD_PATH << File.dirname(__FILE__)+ '/../lib'

require 'date'

require_relative '../lib/grin'

[:st_jacobs, :west_montrose, :bridgeport, :hidden_valley, :doon, :galt].each do |station|
  datum = DateTime.now
  flow = GRIN.waterflow(station, datum)
    ap flow
    unless flow.nil?
      puts "#{Time.now.strftime("%Y-%m-%d %H:%M")}:%-14s %6.2f cbm/s (%d%% of Summer low)" % [ station.to_s.capitalize, flow, GRIN.relative_flow(station, datum)*100 ]
        # print station.to_s.capitalize, " %s (now/60min/24h)" % flow, " (", "%d%% Summer low)\n" % (GRIN.relative_flow(station)*100)
    else
        puts "problem with station #{station}"
    end
end

