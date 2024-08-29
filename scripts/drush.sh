#!/bin/bash
# Examples:
#   ./drush8.sh status

container=$(docker ps -a --filter "name=$1-web-server" --format "{{.Names}}")
if [ -z "$container" ] || [ -z "$1" ]; then
  container="cmap-web-server"
else
  shift
fi

echo "执行容器" $container
echo "执行命令 drush $@"

# 执行docker exec命令
docker exec -it \
  --user docker \
  --workdir /var/www/html/docroot \
  "${container}" ../vendor/bin/drush "$@"
