#!/bin/bash
echo "Removing existing container"

docker stop openactive-dashboard
docker stop openactive-redis
docker rm openactive-dashboard
docker rm openactive-redis

echo "Remember to prune unused volumes with: docker volume prune -f"

echo "Rebuilding image"

docker build -t openactive/dashboard .

echo "Runnning containers"

docker run --name openactive-redis -d redis

docker run -d --name openactive-dashboard -p 3000:3000 \
  --link openactive-redis:redis \
  --mount type=bind,source="$(pwd)",target=/app \
  -e ENV_VAR_1="hello" openactive/dashboard

docker ps

echo "Done. Visit http://localhost:3000/ to view app"