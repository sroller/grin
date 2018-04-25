#!/usr/bin/env ruby
#
# take the list of stations and download the available timeseries
# one by one

require 'awesome_print'
require 'csv'
require 'erb'
require 'date'
require_relative "../lib/grin"

stations = CSV.read(File.dirname(__FILE__) + '/../data/station_list.csv', { headers: true, converters: :all, header_converters: :symbol, col_sep: ';'})

stations.each do |station|
	STDERR.puts station[:station_name]
	ts = GRIN.timeseries_list(station[:station_no])
	ts.map! {|e| { ts_id: e[0], ts_name: e[1], parametertype_name: e[3] }}
	erb = ERB.new <<~end_of_station
	<!DOCTYPE html5>
	<html>
	<head>
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
	<title>Station: <%= station[:station_name] %></title>
	</head>
	<body>
	<form>
	<% ts.each do |t| %>
	<input type="radio" name="" value=""><br /><a href="http://kiwis.grandriver.ca/KiWIS/KiWIS?service=kisters&type=queryServices&request=gettimeseriesvalues&datasource=0&format=html&ts_id=<%= t[:ts_id] %>&header=true&from=#{(Date.today-1).strftime('%Y-%m-%d')}&to=#{Date.today.strftime('%Y-%m-%d')}"><%= t[:ts_id] %>, <%= t[:ts_name] %>, <%= t[:parametertype_name] %></a>
	<% end %>
	</form>
	</body>
	</html>
	end_of_station
	File.open("#{station[:station_no].to_s+"-"+station[:station_name].gsub(/[\/\ ]+/,"")}.html", "w") {|f| f.write(erb.result(binding)) }
end
