# Docker

1. 从模板创建 `docker-compose.override.yml` 文件
`cp docker-compose.override.yml.template docker-compose.override.yml`

2. 添加service，添加内容到 `docker-compose.override.yml`
```
services:

  serverX:
    container_name: serverX
    <<: *base_service

```
cmap项目
将拥有权限的id_rsa挂载到 `~/.ssh/id_rsa`
将known_hosts挂载到 `~/.ssh/known_hosts`
```
  cmap-web-server:
    container_name: cmap-web-server
    <<: *base_service
    volumes:
      - ./etc/xdebug/xdebug.ini:/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
      - ~/.ssh/id_rsa:/var/www/keys/id_rsa
      - ~/.ssh/known_hosts:/var/www/keys/known_hosts
      - [CMAP_PROJECT_PATH]:/var/www/html
      - [THEMES_PATH]:/var/www/themes
```
3. 启动
`./scripts/docker.sh start`  
