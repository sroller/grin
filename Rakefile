require 'rake/clean'
require 'httpclient'
require 'rspec/core/rake_task'

begin
	RSpec::Core::RakeTask.new(:spec)
end

CLEAN.include('html/*.html')
CLOBBER.include('data/*', 'html/*', 'html', 'data')

def download_csv(request, filename)
	File.open(File.dirname(__FILE__)+"/data/#{filename}", "w") do |csv|
		csv.write(HTTPClient.new.get("http://kiwis.grandriver.ca/KiWIS/KiWIS?service=kisters&type=queryServices&request=#{request}&datasource=0&format=csv").body)
	end
end

directory 'data'

file 'data/stations.csv' do
	download_csv('getStationList', 'stations.csv')
end

file 'data/parameters.csv' do
	download_csv('getParameterList', 'parameters.csv')
end

desc "download list of stations and list of possible parameters"
task :data_dir => ['data', 'data/stations.csv', 'data/parameters.csv'] do
end

directory 'html'

desc "create html files"
task :html_dir => ['html', :data_dir] do
	sh 'ruby lib/create_html.rb'
	sh 'ruby lib/download_timeseries.rb'
end

