require_relative '../spec_helper'

describe 'Grand River Information Network' do

  it 'returns 200' do
    r = GRIN.get_station_list
    expect(r[:status]).to be(200)
  end

  it 'returns an Array as payload' do
    r = GRIN.get_station_list
    expect(r[:content]).to be_a(Array)
  end

  it 'gets a station by name' do
    r = GRIN.get_station_by_name('St. Jacobs')
    expect(r[:content][1][0]).to eq('St. Jacobs')
  end

  it 'gets the id for a given name' do
    r = GRIN.get_station_id_by_name('St. Jacobs')
		expect(r).to eq("14475")
  end

	it 'gets a timeseries for a given name' do
		r = GRIN.get_timeseries_list('St. Jacobs')
		expect(r).to be_a(Array)
	end
end
