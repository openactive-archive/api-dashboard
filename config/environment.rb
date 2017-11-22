require 'sinatra/base'
require 'openactive'
require 'redis'
require_relative '../lib/datasets_cache'
require_relative '../lib/availability_cache'

ENV["GOOGLE_ANALYTICS_CODE"] ||= "UA-XXXXX-Y"

if ENV["REDISTOGO_URL"]
  uri = URI.parse(ENV["REDISTOGO_URL"])
  redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
else
  oa_redis_host = ENV['OA_REDIS_HOST'] || '127.0.0.1'
  oa_redis_port = ENV['OA_REDIS_PORT'] || '6379'
  redis = Redis.new(host: oa_redis_host, port: oa_redis_port)
end

Redis.current = redis

if ENV['RACK_ENV'] == 'test'
  require 'rack/test'
  require 'coveralls'
end