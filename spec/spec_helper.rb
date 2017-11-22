ENV['RACK_ENV'] = 'test'

require "./config/environment"

Coveralls.wear!

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:suite) do
    Redis.current = Redis.new(host: (ENV['OA_REDIS_HOST'] || '127.0.0.1'), port: (ENV['OA_REDIS_PORT'] || '6379'))
    Redis.current.del('datasets')
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end

def load_fixture(filename)
  File.read( File.join( File.dirname(__FILE__), "fixtures", filename ) )
end