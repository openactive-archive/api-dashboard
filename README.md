[![Build Status](https://travis-ci.org/openactive/api-dashboard.svg?branch=master)](https://travis-ci.org/openactive/api-dashboard)
[![Coverage Status](https://coveralls.io/repos/github/openactive/api-dashboard/badge.svg?branch=master)](https://coveralls.io/github/openactive/api-dashboard?branch=master)

![OpenActive Logo](https://avatars1.githubusercontent.com/u/13738713?s=200)

# OpenActive Dashboard

A dashboard to support Openactive API users/publishers.

## Quick Run

If you have docker installed you can build and launch the API Dashboard with the `dockerize.sh` script. All you need to do is clone the repository and from the project directory run the script:

1. [Install docker](https://docs.docker.com/engine/installation/)
2. `git clone https://github.com/openactive/api-dashboard.git`
3. `cd api-dashboard`
4. `./dockerize.sh`

## Getting started with development

The API Dashboard is built with [Sinatra](https://sinatrarb.com), a Ruby web application framework. The dashboard uses [Redis](https://redis.io) to store API calls. 

To manage versions of Ruby we recommend installing rbenv or rvm. 

Once you have the requisite ruby version, install gems using `bundle install`. Once installed you should be able to launch the application with the command `bundle exec rackup`. The application should be available at: `http://localhost:9292`.

For the application to work you will also need to have a redis server running. The application will try to connect to the default redis host and port (`127.0.0.1:6379`). Alternatively, you can specify the host and port with the environment variables `OA_REDIS_HOST` and `OA_REDIS_PORT`. NB the application reads these, and other environment variables in `config/environment.rb`. 

## Tests

The API Dashboard use the Rspec test suite. To run the tests install the testset gems with `bundle install`, and then run `bundle exec rspec`.    