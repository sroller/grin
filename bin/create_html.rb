#!/usr/bin/env ruby

require 'csv'
require 'erb'
require 'awesome_print'

#require_relative '../lib/grin'

parametertype_label =
	{
	  'HG' => 'height, river stage',
		'HK' => 'height, lake above specific datum',
		'HL' => 'Elevation, natural lake',
		'HR' => 'stage height',
		'LS' => 'lake storage',
		'PA' => 'pressure, athmospheric',
		'PN' => 'precipitation normal',
		'QI' => 'discharge, inflow',
		'QR' => 'waterflow',
		'QT' => 'discharge, computed total project outflow',
		'TA' => 'temperature, air',
		'TW' => 'temperature, water',
		'UD' => 'wind direction (degrees)',
		'US' => 'wind speed (mi/hr, m/sec)',
		'VL' => 'power generation (megawatt * duration)',
		'W-DSA' => 'W-DSA',
		'W-LSA' => 'W-LSA',
		'W-NO3' => 'W-NO3',
		'WC' => 'Water conductance',
		'WO' => 'Water, dissolved oxygen',
		'WP' => 'Water, pH value',
		'WT' => 'water temperature',
  }


stations = CSV.read(File.dirname(__FILE__) + "/../data/station_list.csv", { headers: true, converters: :numeric, header_converters: :symbol, col_sep: ';' })
stations = stations.map {|s| s.to_hash.merge(parameters:[]) }

stations_map = {}
stations.each {|s|  stations_map[s[:station_no]] = s}

parameters_map = {}
CSV.foreach(File.dirname(__FILE__) + "/../data/parameter_list.csv", { headers: true, converters: :numeric, header_converters: :symbol, col_sep: ';' }) do |p|
	stations_map[p[:station_no]][:parameters] << { parametertype_id: p[:parametertype_id],
																								 parametertype_name: p[:parametertype_name],
																								 parametertype_label: parametertype_label[p[:parametertype_name]]
																								}
end

# ap stations_map

station_template = ERB.new <<-end_of_stations
<!DOCTYPE html5>
<html>
<head>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
<title>GRIN: List of stations</title>
</head>
<body>
<table class="table">
<thead>
<tr>
<%= "<th>Station</th><th>Number</th><th>Maps</th><th>Parameters</th>" %>
</tr>
</thead>
<tbody>
<% stations.each do |station| %>
<tr>
	<td><%= station[0] %></td>
  <td><%= station[:station_name] %></td>
  <td><%= station[:station_no]%></td>
  <td><a href="https://maps.google.com/maps/place/<%=station[:station_latitude]%>,<%=station[:station_longitude]%>">Show</a></td>
	<td>
	<% station[:parameters].each do |param| %>
		<a href="http://kiwis.grandriver.ca/KiWIS/KiWIS?service=kisters&type=queryServices&request=getTimeseriesList&format=html&parametertype_name=<%=param[:parametertype_name]%>&station_no=<%=station[:station_no]%>"><%=param[:parametertype_label]%></a><br />
	<% end %>
</td>
</tr>
<% end %>
</tbody>
</body>
</html>
end_of_stations

stations.each do |station|
	# puts station
end

puts station_template.result(binding)

