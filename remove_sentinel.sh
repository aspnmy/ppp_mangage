docker stop sentinel1 sentinel2 sentinel3 redis-master redis-slave1 redis-slave2
docker rm sentinel1 sentinel2 sentinel3 redis-master redis-slave1 redis-slave2
docker network rm redis-sentinel-network

rm -rf runtime/sentinel{1,2,3}
# End: remove_sentinel.sh
