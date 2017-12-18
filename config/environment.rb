require 'sinatra/base'
require 'openactive'
require 'redis'
require 'time'
require 'bothan'

require_relative '../lib/datasets_cache'
require_relative '../lib/availability_cache'
require_relative '../lib/dataset_summary'
require_relative '../lib/dataset_parser'
require_relative '../lib/local_geocoder/local_authority_geocoder'

ENV["LA_GEOJSON_PATH"] = "./lib/local_geocoder/uk_local_authorities.geojson"
ENV["GOOGLE_ANALYTICS_CODE"] ||= "UA-XXXXX-Y"
ENV["SUMMARY_SAMPLE_LIMIT"] ||= "500"

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
  require 'webmock/rspec'
  require 'redis-namespace'
  require 'pry'
end