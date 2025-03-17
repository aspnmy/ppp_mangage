#!/bin/bash

# 创建 Docker 网络
docker network create redis-sentinel-network

# 运行 Redis 主节点
docker run -d --name redis-master \
    --network redis-sentinel-network \
    --hostname redis-master \
    -p 6379:6379 \
    redis redis-server --requirepass "20f299a1f5ac2974"

# 获取 redis-master 容器的 IP 地址
REDIS_MASTER_IP=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' redis-master)

# 运行 Redis 从节点
docker run -d --name redis-slave1 \
    --network redis-sentinel-network \
    --hostname redis-slave1 \
    redis redis-server --slaveof $REDIS_MASTER_IP 6379 --requirepass "20f299a1f5ac2974" --masterauth "20f299a1f5ac2974"

docker run -d --name redis-slave2 \
    --network redis-sentinel-network \
    --hostname redis-slave2 \
    redis redis-server --slaveof $REDIS_MASTER_IP 6379 --requirepass "20f299a1f5ac2974" --masterauth "20f299a1f5ac2974"

# 创建配置目录
mkdir -p runtime/sentinel{1,2,3}

# 为每个sentinel创建配置
for i in {1..3}; do
    cat <<EOF > runtime/sentinel$i/sentinel.conf
port 26379
dir "/data"
sentinel monitor mymaster $REDIS_MASTER_IP 6379 1
sentinel auth-pass mymaster 20f299a1f5ac2974
sentinel down-after-milliseconds mymaster 30000
sentinel failover-timeout mymaster 180000
sentinel parallel-syncs mymaster 1
protected-mode no
EOF
done

# 设置目录权限
chmod -R 777 runtime/

# 运行 Sentinel 节点
docker run -d --name sentinel1 \
    --network redis-sentinel-network \
    --hostname sentinel1 \
    -v $(pwd)/runtime/sentinel1:/data \
    -p 26379:26379 \
    -p 16379:16379 \
    --add-host redis-master:$REDIS_MASTER_IP \
    redis redis-sentinel /data/sentinel.conf --sentinel

docker run -d --name sentinel2 \
    --network redis-sentinel-network \
    --hostname sentinel2 \
    -v $(pwd)/runtime/sentinel2:/data \
    -p 26380:26379 \
    --add-host redis-master:$REDIS_MASTER_IP \
    redis redis-sentinel /data/sentinel.conf --sentinel

docker run -d --name sentinel3 \
    --network redis-sentinel-network \
    --hostname sentinel3 \
    -v $(pwd)/runtime/sentinel3:/data \
    -p 26381:26379 \
    --add-host redis-master:$REDIS_MASTER_IP \
    redis redis-sentinel /data/sentinel.conf --sentinel

# 验证部署
docker ps