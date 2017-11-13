#!/bin/bash
echo "Building and running containers"

./dockerize.sh

echo "Executing tests"

docker exec -e OA_REDIS_HOST="openactive-redis" openactive-dashboard bundle exec rspec spec
