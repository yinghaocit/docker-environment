# Docker 开发环境

基于 Docker 的 PHP/Drupal 项目开发环境，支持多项目同时运行。

## 🚀 核心服务

- **Nginx**: 反向代理和 SSL 终端
- **PHP 8.3 + Apache**: Web 服务器环境（基于 ciandtchina/drupal-web 镜像）
- **MySQL**: 数据库服务（支持持久化存储）
- **Xdebug**: PHP 调试工具

## 📁 目录结构

```
docker-environment/
├── docker-compose.yml                     # 基础服务配置
├── docker-compose.override.yml.template   # 项目配置模板（需复制并自定义）
├── docker-compose.override.yml            # 项目实际配置（自定义）
├── docker-entrypoint.sh                   # Docker 入口脚本
├── etc/                                   # 配置文件
│   ├── apache2/                           # Apache 配置
│   │   └── config/                        # 站点配置
│   ├── localtime/                         # 时区配置
│   ├── nginx/                             # Nginx 配置
│   │   ├── certs/                         # SSL 证书
│   │   ├── config/                        # 站点配置
│   │   └── template/                      # 配置模板
│   └── xdebug/                            # Xdebug 配置
├── images/                                # 自定义 Docker 镜像
│   └── php8.3-apache-devpack/             # PHP 8.3 Apache 环境
├── minica/                                # SSL 证书生成工具
├── persist-data/                          # 持久化数据
│   └── db-data/                           # MySQL 数据存储
└── scripts/                               # 便捷脚本
    ├── composer.sh                        # Composer 命令
    ├── docker-entrypoint.sh.sh            # Docker 入口脚本
    ├── docker.sh                          # Docker 环境管理
    └── drush.sh                           # Drupal Drush 命令
```

## ⚡ 快速开始

```bash
# 1. 复制配置模板
cp docker-compose.override.yml.template docker-compose.override.yml

# 2. 修改项目路径
vim docker-compose.override.yml

# 3. 启动环境
./scripts/docker.sh start

# 4. 停止环境
./scripts/docker.sh stop
```

## 🛠️ 便捷脚本

### 环境管理
```bash
./scripts/docker.sh start    # 启动环境
./scripts/docker.sh stop     # 停止环境
./scripts/docker.sh down     # 销毁环境
./scripts/docker.sh logs     # 查看日志
```

### 开发工具
```bash
./scripts/composer.sh install           # 安装依赖
./scripts/drush.sh cr                   # 清除缓存

### 特殊功能脚本

**`docker-entrypoint.sh.sh`** - 解决容器用户权限问题
- ✅ 容器内外文件权限一致
- ✅ IDE 正常编辑文件
- ✅ Git 操作无权限冲突

## 🔐 SSL 证书配置

### 生成证书
```bash
cd etc/nginx/certs/

# 单个域名
../../../minica/minica -domains "local.example.com"

# 通配符域名
../../../minica/minica -domains "*.local.example.com,local.example.com"
```

### 添加系统信任证书
```bash
# macOS
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain minica.pem

# Linux
sudo cp minica.pem /usr/local/share/ca-certificates/minica.crt
sudo update-ca-certificates
```

### Nginx 配置示例
```nginx
server {
    listen 443 ssl;
    server_name local.example.com;
    
    ssl_certificate /etc/nginx/ssl_certs/local.example.com/cert.pem;
    ssl_certificate_key /etc/nginx/ssl_certs/local.example.com/key.pem;
    
    location / {
        proxy_pass http://web-server:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## 🔄 自定义项目配置

在 `docker-compose.override.yml` 文件中，您可以根据需要添加多个项目服务。每个服务都可以配置以下内容：

1. **项目路径映射**：将本地代码目录映射到容器内部
2. **自定义域名**：在 `etc/nginx/config/` 中创建站点配置
3. **选择 PHP 版本**：通过选择不同的基础镜像

### 示例配置
```yaml
x-service: &web-service
  networks:
    - default-network
  image: local/web-service:1.0.0
  extra_hosts:
    - "host.docker.internal:host-gateway"
  build:
    context: .
    dockerfile: images/php8.3-apache-devpack/Dockerfile

services:
  project-web-server:
    <<: *web-service
    container_name: project-web-server
    volumes:
      - ~/Projects/your-project:/var/www/html
      - ./etc/xdebug/xdebug.ini:/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
      - ~/.ssh/id_rsa:/var/www/keys/id_rsa
```

## 📝 MySQL 数据库管理

MySQL 服务默认配置：
- **账号**: root
- **密码**: root
- **端口**: 3306
- **持久化数据**: 保存在 `persist-data/db-data` 目录

您可以使用任何数据库管理工具（如 MySQL Workbench、Sequel Pro、phpMyAdmin）通过本地端口 3306 连接。

## 🐞 Xdebug 配置

Xdebug 已预先配置，可与 VSCode、PHPStorm 等 IDE 集成。配置文件位于 `etc/xdebug/xdebug.ini`。

## 📋 常见问题

1. **网站无法访问**：检查 Nginx 配置和 SSL 证书
2. **权限问题**：使用 `docker-entrypoint.sh.sh` 脚本解决
3. **端口冲突**：修改 `docker-compose.yml` 中的端口映射

## 🔧 环境维护

- **更新镜像**: `docker-compose pull && ./scripts/docker.sh start`
- **重建容器**: `./scripts/docker.sh down && ./scripts/docker.sh start`
- **查看日志**: `./scripts/docker.sh logs [服务名]`

---

**环境要求**: Docker, Docker Compose, Git
**支持平台**: macOS, Linux
**项目标识**: local-env
