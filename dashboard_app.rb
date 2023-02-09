require_relative 'config/environment'
require './dashboard_helpers'

class DashboardApp < Sinatra::Base

  configure do
    set :bind, '0.0.0.0'
    enable :logging
    set :logging, Logger::INFO
    set :public_folder, './public/'
  end

  helpers do
    include DashboardHelpers
  end

  get '/' do
    datasets = DatasetsCache.all
    last_updated = DatasetsCache.last_updated
    availability = AvailabilityCache.all
    erb :index, locals: { datasets: datasets, availability: availability, last_updated: last_updated }
  end

  get '/datasets.json' do
    content_type :json

    datasets = DatasetsCache.all
    availability = AvailabilityCache.all
    max_local_authorities = 418
    la_ids = LocalGeocoder::LocalAuthorities.new().dictionary

    datasets.each_pair do |k,d|
      summary = DatasetSummary.new(k)
      d.delete('mailchimp')
      d.delete('keyword-1')
      d.delete('keyword-2')
      d.delete('created')
      d.delete('rpde-version')
      d.delete('copyright-notice')
      d.delete('odi-certificate-number')
      d.delete('publish')
      d.merge!(available: availability[d["dataurl"]])
      d.merge!(activities: summary.activities(max_local_authorities))

      boundaries = []
      summary.boundaries(max_local_authorities).each_pair do |key, value|
        boundaries.push({ id: la_ids[key], name: key, occurrences: value })
      end

      d.merge!(boundaries: boundaries)
     end

    { meta: { 
      "licence" => "https://creativecommons.org/licenses/by/4.0/", 
      "last-updated" => DatasetsCache.last_updated,
      "attribution-text" => "Contains National Statistics data © Crown copyright and database right 2017",
      "attribution-url" => "http://geoportal.statistics.gov.uk/datasets/local-authority-districts-december-2016-generalised-clipped-boundaries-in-the-uk/"
      }, data: datasets }.to_json
  end

  get '/summary/*' do
    dataset_key = params[:splat].first
    summary = DatasetSummary.new(dataset_key)
    erb :summary, layout: false, locals: {
      dataset_key: dataset_key, 
      activities: summary.activities,
      boundaries: summary.boundaries,
      samples: summary.samples,
      last_updated: summary.last_updated,
      last_attempt: summary.last_attempt,
      error_code: summary.error_code
    }
  end

  get '/about' do
    erb :about
  end

  get '/test' do
    erb :test
  end

end