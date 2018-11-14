require 'rake/clean'
require 'httpclient'
require 'rspec/core/rake_task'

DEPLOY_DIR='C:/src/pages/grin'
GRIN_URL='http://kiwis.grandriver.ca/KiWIS/KiWIS?service=kisters&type=queryServices&request=%s&datasource=0&format=csv'

begin
	RSpec::Core::RakeTask.new(:spec)
end

task :default => :deploy

CLEAN.include('html/*.html')
CLOBBER.include('data/*', 'html/*', 'html', 'data')

def download_csv(request, filename)
	File.open(File.dirname(__FILE__)+"/data/#{filename}", "w") do |csv|
		# csv.write(HTTPClient.new.get("http://kiwis.grandriver.ca/KiWIS/KiWIS?service=kisters&type=queryServices&request=#{request}&datasource=0&format=csv").body)
		csv.write(HTTPClient.new.get(GRIN_URL % request).body)
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
	ruby 'lib/create_html.rb'
	ruby 'lib/download_timeseries.rb'
end

directory DEPLOY_DIR

desc "deploy html"
task :deploy do
  puts "copy all and git push"
  files = Rake::FileList['html/*.html']
  files.each do |f|
    puts "copy #{f} -> #{DEPLOY_DIR}"
    FileUtils.cp(f, DEPLOY_DIR)
  end
  Dir.chdir(DEPLOY_DIR)
  puts `git status`
end

