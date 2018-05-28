require_relative '../spec_helper'

describe 'Grand River Information Network' do

  it 'returns 200' do
    r = GRIN.station_list
    expect(r[:status]).to be(200)
  end

  it 'returns an Array as payload' do
    r = GRIN.station_list
    expect(r[:content]).to be_a(Array)
  end

  it 'gets a station by name' do
    r = GRIN.station_by_name('St. Jacobs')
    expect(r[:content][1][0]).to eq('St. Jacobs')
  end

  it 'gets the id for a given name' do
    r = GRIN.station_id_by_name('St. Jacobs')
		expect(r).to eq("14475")
  end

	it 'gets a timeseries values for a given name' do
		# r = GRIN.get_timeseries_list('8665042', '2016-11-09T09:00:00', '2016-11-09T10:00:00')
		r = GRIN.timeseries_values('8671042', '2016-11-09T09:00:00', '2016-11-09T10:00:00')
		expect(r).to be_a(Array)
	end

	it 'gets a list of possible timeseries' do
		r = GRIN.timeseries_list('19')
		expect(r).to be_a(Array)
		expect(r.size).to eq(12)
	end

  it 'returns a list of possible parameters' do
    r = GRIN.parameter_list(14475)
    expect(r).to be_a(Array)
  end

  it 'returns the waterflow for a station on a given day' do
    r = GRIN.waterflow(:westmontrose, '2016-10-29')
    expect(r).to be_a(Numeric)
  end

  it 'returns nil for an unknown station' do
    r = GRIN.waterflow(:unknown, '2016-10-29')
    expect(r).to be_nil
  end

  it 'return relative flow to normal Summer low flow on a certain day' do
    r = GRIN.waterflow(:westmontrose, '2016-10-29')
    expect(r).to be < 5.0
  end

  it 'return to relative flow to normal Summer low flow today' do
    r = GRIN.waterflow(:westmontrose)
    expect(r).to be_a(Numeric)
  end

	it 'returns the relative flow for a station' do
		r = GRIN.relative_flow(:westmontrose)
		expect(r).to be_a(Numeric)
	end

end
