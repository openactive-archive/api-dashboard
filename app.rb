require 'sinatra/base'
require 'openactive'
require 'redis'
require_relative 'lib/datasets_cache'

class DashboardApp < Sinatra::Base
  
  OA_REDIS_HOST = ENV['OA_REDIS_HOST'] || '127.0.0.1'
  OA_REDIS_PORT = ENV['OA_REDIS_PORT'] || '6379'

  configure do
    set :bind, '0.0.0.0'
    enable :logging
    set :logging, Logger::INFO
    set :redis, Redis.new(host: OA_REDIS_HOST, port: OA_REDIS_PORT)
    Redis.current = settings.redis
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

DashboardApp.run!