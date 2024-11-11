# Docker 环境启动
## Docker 配置
1. 从模板创建 `docker-compose.override.yml` 文件 
`cp docker-compose.override.yml.template docker-compose.override.yml`

2. 添加service内容到 `docker-compose.override.yml`
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
4. 添加 [container_name] 的配置到nginx配置文件
5. 启动
`./scripts/docker.sh start`  

## 关于证书
1. 安装 [mkcert](https://github.com/FiloSottile/mkcert) `sudo apt install mkcert`
2. 进入etc/nignx/certs目录
3. 生成证书 `mkcert loca.cmap.com`
4. 将证书导入倒浏览器 `mkcert -install` （支持google chrome 和 Firefox）

## Q&A
1. /tmp/debug.log 文件权限问题
2. id_rsa 权限问题