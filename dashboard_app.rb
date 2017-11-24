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

  get '/test' do
    erb :test
  end

end