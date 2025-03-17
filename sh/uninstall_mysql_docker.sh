#!/bin/bash


echo "开始卸载 MariaDB Docker..."

# 停止并删除容器
if docker ps -a | grep -q mariadb_hub; then
    echo "停止并删除 mariadb_hub 容器..."
    docker stop mariadb_hub
    docker rm mariadb_hub
fi

# 等待容器完全停止
sleep 3

# 删除网络
if docker network ls | grep -q mariadb-hub-network; then
    echo "删除 mariadb-hub-network 网络..."
    docker network rm mariadb-hub-network || true
fi

# 清理数据目录
echo "清理数据目录..."
if [ -d "$(dirname $0)/../mysql" ]; then
    # 修改权限
    sudo chmod -R 777 $(dirname $0)/../mysql
    # 强制删除
    sudo rm -rf $(dirname $0)/../mysql
    if [ $? -ne 0 ]; then
        echo "尝试使用find删除..."
        sudo find $(dirname $0)/../mysql -type f -exec rm -f {} \;
        sudo find $(dirname $0)/../mysql -type d -exec rm -rf {} \;
    fi
fi

echo "MariaDB Docker 卸载完成"

# End: uninstall_mysql_docker.sh