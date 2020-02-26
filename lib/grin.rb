#!/usr/bin/env ruby

require 'httpclient'
require 'json'
require 'awesome_print'
require 'date'

module GRIN

BASE_URL = 'https://waterdata.grandriver.ca/KiWIS/KiWIS?service=kisters&type=queryServices&datasource=0&format=json&request='

Parametertype_label =
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

Stammdaten = {
  west_montrose:  { waterflow: '8725042', name: "Westmontrose", summerflow: 5.0 },
  bridgeport:    { waterflow: '8665042', name: "Bridge Port", summerflow: 11.0 },
  hidden_valley: { waterflow: '8695042', name: "Hidden Valley", summerflow: 10.0 },
  doon:          { waterflow: '8677042', name: "Doon Valley", body: "Grand River", summerflow: 11.0 },
  galt:          { waterflow: '8671042', name: "Galt", body: "Grand River", summerflow: 15.0 },
  new_hamburg:    { waterflow: '8827042', name: "New Hamburg", body: "Nith River", summerflow: 1.5 },
  st_jacobs:      { waterflow: '8641042', name: "St. Jacobs", body: "Conestogo River", summerflow: 4.0 }
}


  def self.station_list
    clnt = HTTPClient.new
    begin
        r = clnt.get(BASE_URL+'getStationList')
    rescue StandardError => e
        puts "ERRRO: #{e}"
    end

    { status: r.status, content: JSON.parse(r.body)}
  end

  def self.station_by_name(name='*')
    clnt = HTTPClient.new
		r = clnt.get(BASE_URL+"getStationList&station_name=#{URI.escape(name)}")
    { status: r.status, content: JSON.parse((r.body))}
  end

	def self.station_id_by_name(name)
		return nil if name.nil?
    clnt = HTTPClient.new
		r = clnt.get(BASE_URL+"getStationList&station_name=#{URI.escape(name)}")
		JSON.parse(r.body)[1][2]
	end

	def self.timeseries_list(station_id)
		id = station_id.to_i
		raise ArgumentError, "expected number, but station_id was #{station_id}" unless id.kind_of? Numeric
		clnt = HTTPClient.new
		r = clnt.get(BASE_URL+"getTimeSeriesList&station_no=#{id}")
		list = JSON.parse(r.body)
		list.map {|serie| [serie[3], serie[4], serie[5], serie[6]] }[1..-1]
	end

	def self.timeseries_values(ts_id, from, to=from)
    return nil if ts_id.nil? || from.nil? || to.nil?
  
		clnt = HTTPClient.new
    r = clnt.get(BASE_URL+"getTimeSeriesValues&ts_id=#{ts_id}&from=#{from}&to=#{to}")
    JSON.parse(r.body)
	end

  # get list of parameters for a giving station
  def self.parameter_list(station_id)
    clnt = HTTPClient.new
    r = clnt.get(BASE_URL+"getParameterList&station_id=#{station_id}")
    # ap JSON.parse(r.body)
    JSON.parse(r.body)
  end

  def self.waterflow(station, day=nil)
    return nil unless Stammdaten.has_key? station
		unless day.nil?
      day = DateTime.parse(day) if day.kind_of? String
		else
			day = DateTime.now
		end
    url = BASE_URL+"gettimeseriesvalues&ts_id=#{Stammdaten[station][:waterflow]}"
		# fetch the last 24 hours
    url += "&from=#{(day-1).strftime("%Y-%m-%dT%H:%M:%SZ")}&to=#{day.strftime("%Y-%m-%dT%H:%M:%SZ")}"
    clnt = HTTPClient.new
    # ap url
    begin
        r = clnt.get(url)
				# ap r
    rescue StandardError => e
        puts "ERROR: #{e}"
        exit
    end
    # ap r.body
    begin
        data = JSON.parse(r.body)[0]['data']
    rescue StandardError => e
        puts "ERROR: JSON parse error"
        ap url
    else
      # puts data
			# print "%.2f/%.2f/%.2f" % [data[-1][1], data[-2][1], data[0][1]]
			# "%.2f/%.2f/%.2f" % [data[-1][1], data[-2][1], data[0][1]]
      # avg = data.inject(0.0) { |sum,item| sum += item[1] } / data.size
      # data.inject(0.0) { |sum,item| sum += item[1] } / data.size
			data[-1][1]
    end
  end

  # flow relative to normal Summer low flow
  # 1.0 would be normal
  # 2.0 would be double
  # 0.5 would be half and so on
  def self.relative_flow(station, day=nil)
    return nil unless Stammdaten.has_key? station
    flow = waterflow(station, day)
    flow / Stammdaten[station][:summerflow]
  end
end

if __FILE__ == $0
  puts "Waterflows"
  puts "Bridgeport #{GRIN}"
end

