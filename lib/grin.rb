#!/usr/bin/env ruby
#
require 'httpclient'
require 'json'
require 'awesome_print'
require 'date'

module GRIN

Waterflow = {
  westmontrose: '8725042',
  bridgeport: '8665042',
  victoria: '8899042',
  doon: '8677042',
  galt: '8671042',
  newhamburg: '8827042',
	stjacobs: '8641042'
}

Summerflow = {
  westmontrose: 5.0,
  bridgeport: 11.0,
  doon: 11.0,
  galt: 15,
  newhamburg: 1.5,
	stjacobs: 4.0
}


BASE_URL = 'http://kiwis.grandriver.ca/KiWIS/KiWIS?service=kisters&type=queryServices&datasource=0&format=json&request='

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

	def self.timeseries_list(ts_id, from, to=from)
    return nil if ts_id.nil? || from.nil? || to.nil?
  
		clnt = HTTPClient.new
    r = clnt.get(BASE_URL+"gettimeseriesvalues&ts_id=#{ts_id}&from=#{from}&to=#{to}")
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
    return nil unless Waterflow.has_key? station
		unless day.nil?
			day = DateTime.parse(day)
		else
			day = DateTime.now
		end
    url = BASE_URL+"gettimeseriesvalues&ts_id=#{Waterflow[station]}"
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
			# ap data
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
    return nil unless Summerflow.has_key? station
    flow = waterflow(station, day)
    flow / Summerflow[station]
  end
end
