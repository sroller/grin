#!/usr/bin/env ruby
#
# take the list of stations and download the available timeseries
# one by one

require 'awesome_print'
require 'csv'
require 'erb'
require 'date'
require_relative "../lib/grin"

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


stations = CSV.read(File.dirname(__FILE__) + '/../data/stations.csv', { headers: true, converters: :all, header_converters: :symbol, col_sep: ';'})

stations.each do |station|
	STDERR.puts station[:station_name]
	ts = GRIN.timeseries_list(station[:station_no])
	ts.map! {|e| { ts_id: e[0], ts_name: e[1], parametertype_name: e[3] }}
	erb = ERB.new <<~end_of_station
	<!DOCTYPE html>
	<meta charset='UTF-8'>
	<html>
	<head>
	<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" integrity="sha384-Gn5384xqQ1aoWXA+058RXPxPg6fy4IWvTNh0E263XmFcJlSAwiGgFAW/dAiS6JXm" crossorigin="anonymous">
	<title>Station: <%= station[:station_name] %></title>
	</head>
	<body onload="init_page()">
	<h1><%= station[:station_name] %></h1>
	<form action="https://waterdata.grandriver.ca/KiWIS/KiWIS?service=kisters&type=queryServices&request=gettimeseriesvalues&datasource=0&format=html&header=true">
		<input type="hidden" name="service" value="kisters">
		<input type="hidden" name="type" value="queryServices">
		<input type="hidden" name="request" value="getTimeSeriesValues">
		<input type="hidden" name="datasource" value="0">
		<input type="hidden" name="header" value="true">
		<input type="hidden" name="format" value="html">
		<div class="form-row">
			<div class="col-sm-2">
				<input type="date" class="form-control gestern" name="from" value="2018-01-01"><br />
			</div>
			<div class="col-sm-2">
				<input type="date" class="form-control heute" name="to" value="2018-01-01"><br />
			</div>
			<div class="col-sm-2">
				<input type="submit" class="form-control" value="Send">
			</div>
		</div>
		<hr />
		<% first = true
       ts.each do |t| %>
		<div class="form-check">
			<input class="for-check-input" type="radio" name="ts_id" id="id-<%=t[:ts_id]%>" value="<%=t[:ts_id]%>" <%= first ? "checked" : "" %>>
			<% first = false %>
			<label class="form-check-label" for="id-<%=t[:ts_id]%>">
         <%= parametertype_label[t[:parametertype_name]]%> (<%=t[:ts_name]%>)
			</label>
		</div>
		<% end %>
	</div>
	</form>
	</body>
	<script>
	function set_date_value(field_class, datum) {
		var field = document.querySelector(field_class);
		field.value = datum.toISOString().split('T')[0];
	}

	function init_page() {
		var heute, heute_field, gestern, gestern_field;

		heute = new Date();
		set_date_value('.heute', heute);
		// heute_field = document.querySelector('.heute');
		// heute_field.value = heute.toISOString().split('T')[0];

		gestern = new Date(heute - 86400000);
		set_date_value('.gestern', gestern);
		// gestern_field = document.querySelector('.gestern');
		// gestern_field.value = gestern.toISOString().split('T')[0];


		// console.log("heute  : "+heute);
		// console.log("heute feld: "+ heute_field);
		// console.log("gestern: " + gestern);
		// console.log("gestern feld: " + gestern_field);
	}
	</script>
	</html>
	end_of_station
	File.open(File.dirname(__FILE__)+"/../html/#{station[:station_no].to_s+"-"+station[:station_name].gsub(/[\/\ ]+/,"")}.html", "w") {|f| f.write(erb.result(binding)) }
end

