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
    erb :index, locals: { datasets: datasets }
  end

  get '/test' do
    erb :test
  end

end