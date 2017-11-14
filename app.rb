require 'sinatra/base'
require 'openactive'
require 'redis'
require_relative 'lib/datasets_cache'

class DashboardApp < Sinatra::Base

  configure do
    set :bind, '0.0.0.0'
    enable :logging
    set :logging, Logger::INFO

    if ENV["REDISTOGO_URL"]
      uri = URI.parse(ENV["REDISTOGO_URL"])
      oa_redis_host = uri.host
      oa_redis_port = uri.port
    else
      oa_redis_host = ENV['OA_REDIS_HOST'] || '127.0.0.1'
      oa_redis_port = ENV['OA_REDIS_PORT'] || '6379'
    end

    set :redis, Redis.new(host: oa_redis_host, port: oa_redis_port)
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