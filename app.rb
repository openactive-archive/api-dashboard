require 'sinatra/base'
require 'openactive'
require 'redis'
require_relative 'lib/datasets_cache'

class DashboardApp < Sinatra::Base
  
  REDIS_HOST = ENV['REDIS_HOST'] || '127.0.0.1'
  REDIS_PORT = ENV['REDIS_PORT'] || '6379'

  configure do
    set :bind, '0.0.0.0' 
    set :redis, Redis.new(host: REDIS_HOST, port: REDIS_PORT)
  end

  get '/' do
    datasets = DatasetsCache.all
    erb :index, locals: { datasets: datasets }
  end

  get '/agent' do
    "you're using #{request.user_agent}"
  end

  get '/test' do
    erb :test
  end

end

DashboardApp.run!