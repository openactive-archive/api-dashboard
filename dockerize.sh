#!/bin/bash
echo "Removing existing container"

docker stop openactive-dashboard
docker rm openactive-dashboard

echo "Remember to prune unused volumes with: docker volume prune -f"

echo "Rebuilding image"

docker build -t openactive/dashboard .

echo "Runnning container"

docker run -d --name openactive-dashboard -p 3000:3000 \
  --mount type=bind,source="$(pwd)",target=/app \
  -e ENV_VAR_1="hello" openactive/dashboard

echo "Done. Visit http://localhost:3000/ to view app"