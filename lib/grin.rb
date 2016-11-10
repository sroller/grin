#!/usr/bin/env ruby
#
require 'httpclient'
require 'json'
require 'awesome_print'

module GRIN

  def self.get_station_list
    clnt = HTTPClient.new
    r = clnt.get('http://kiwis.grandriver.ca/KiWIS/KiWIS?service=kisters&type=queryServices&request=getStationList&datasource=0&format=json')

    { status: r.status, content: JSON.parse(r.body)}
  end

  def self.get_station_by_name(name='*')
    clnt = HTTPClient.new
    r = clnt.get("http://kiwis.grandriver.ca/KiWIS/KiWIS?service=kisters&type=queryServices&request=getStationList&datasource=0&format=json&station_name=#{name}")
    { status: r.status, content: JSON.parse((r.body))}
  end

end
