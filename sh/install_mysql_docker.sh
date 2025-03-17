#!/bin/bash

# 检查SQL文件是否存在
SQL_FILE="$(dirname $0)/ppp.sql"
if [ ! -f "$SQL_FILE" ]; then
    echo "错误: ppp.sql 文件不存在于 $(dirname $0) 目录"
    exit 1
fi

# 创建MySQL网络
docker network create mariadb-hub-network

# 创建MySQL数据目录
mkdir -p $(dirname $0)/../mysql/data
chmod -R 777 $(dirname $0)/../mysql

# 运行MySQL容器
docker run -d \
    --name mariadb_hub \
    --network mariadb-hub-network \
    --network-alias mysql \
    -p 127.0.0.1:63306:3306 \
    -v $(dirname $0)/../mysql/data:/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=xT2GT:hGg3kaF:B \
    -e MYSQL_DATABASE=ppp \
    aspnmy/mariadb-aria:root-net-v10.11.5-alpine3.18.4

# 等待MySQL启动
echo "等待Mariadb_MySQL启动..."
sleep 20  # 增加等待时间确保数据库完全启动

# 导入数据库并创建用户
echo "正在导入数据库..."
docker cp "$SQL_FILE" mariadb_hub:/root/ppp.sql
docker exec mariadb_hub /bin/sh -c '
until mysql -uroot -pxT2GT:hGg3kaF:B -e "SELECT 1"; do
    echo "等待数据库就绪..."
    sleep 1
done

mysql -uroot -pxT2GT:hGg3kaF:B ppp < /root/ppp.sql &&
mysql -uroot -pxT2GT:hGg3kaF:B -e "
CREATE USER IF NOT EXISTS '\''ppp'\''@'\''%'\'' IDENTIFIED BY '\''xT2GT:hGg3kaF:B'\'';
GRANT ALL PRIVILEGES ON ppp.* TO '\''ppp'\''@'\''%'\'';

CREATE USER IF NOT EXISTS '\''rrr'\''@'\''%'\'' IDENTIFIED BY '\''xT2GT:hGg3kaF:B'\'';
GRANT SELECT ON ppp.* TO '\''rrr'\''@'\''%'\'';

FLUSH PRIVILEGES;
"'

echo "Mariadb_MySQL安装完成"