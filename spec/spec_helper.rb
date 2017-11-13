require 'redis'

RSpec.configure do |config|

  config.before(:suite) do
    puts "before suite"
    Redis.current = Redis.new(host: (ENV['OA_REDIS_HOST'] || '127.0.0.1'), port: (ENV['OA_REDIS_PORT'] || '6379'))
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'
end
