require_relative 'config/environment'

class DashboardApp < Sinatra::Base

  configure do
    set :bind, '0.0.0.0'
    enable :logging
    set :logging, Logger::INFO
  end

  get '/' do
    datasets = DatasetsCache.all    
    erb :index, locals: { datasets: datasets }
  end

  get '/inspect' do
    datasets = DatasetsCache.all
    "Inspect: #{datasets.inspect}"
  end

  get '/test' do
    erb :test
  end

end