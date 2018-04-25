#!/usr/bin/env ruby

require 'csv'
require 'erb'
require 'awesome_print'
require_relative '../lib/grin'

stations = CSV.read(File.dirname(__FILE__) + "/../data/station_list.csv", { headers: true, converters: :numeric, header_converters: :symbol, col_sep: ';' })
stations = stations.map {|s| s.to_hash.merge(parameters:[]) }

stations_map = {}
stations.each {|s|  stations_map[s[:station_no]] = s}

parameters_map = {}
CSV.foreach(File.dirname(__FILE__) + "/../data/parameter_list.csv", { headers: true, converters: :numeric, header_converters: :symbol, col_sep: ';' }) do |p|
	stations_map[p[:station_no]][:parameters] << { parametertype_id: p[:parametertype_id],
																								 parametertype_name: p[:parametertype_name],
																								 parametertype_label: GRIN::Parametertype_label[p[:parametertype_name]]
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
	<td><%= station[:station_no] %></td>
	<td><a href="<%=station[:station_no].to_s+'-'+station[:station_name].gsub(/[ \\/]+/,'')%>.html"><%= station[:station_name] %></a></td>
  <td><a href="https://maps.google.com/maps/place/<%=station[:station_latitude]%>,<%=station[:station_longitude]%>" target=maps>show on map</a></td>
	<td>
	<% station[:parameters].each do |param| %>
		<%=param[:parametertype_label]%><br />
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

File.open(File.dirname(__FILE__)+ "/../html/index.html", "w") { |f| f.write(station_template.result(binding)) }

