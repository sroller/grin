#!/usr/bin/env ruby
#
require 'httpclient'
require 'json'
require 'awesome_print'

module GRIN

BASE_URL = 'http://kiwis.grandriver.ca/KiWIS/KiWIS?service=kisters&type=queryServices&datasource=0&format=json&request='

  def self.get_station_list
    clnt = HTTPClient.new
    r = clnt.get(BASE_URL+'getStationList')

    { status: r.status, content: JSON.parse(r.body)}
  end

  def self.get_station_by_name(name='*')
    clnt = HTTPClient.new
    r = clnt.get(BASE_URL+"getStationList&station_name=#{name}")
    { status: r.status, content: JSON.parse((r.body))}
  end

	def self.get_station_id_by_name(name)
		return nil if name.nil?
    clnt = HTTPClient.new
    r = clnt.get(BASE_URL+"getStationList&station_name=#{name}")
		JSON.parse(r.body)[1][2]
	end

	def self.get_timeseries_list(name)
		clnt = HTTPClient.new
    r = clnt.get(BASE_URL+"getTimeseriesList&station_name=#{name}")

	end
end
