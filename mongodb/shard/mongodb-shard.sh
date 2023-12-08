#!/bin/bash
# 开启config配置服务器
echo "config配置服务器"
mongod --config ~/mongodb/shard/config-primary/start.conf &
mongod --config ~/mongodb/shard/config-secondary1/start.conf &
mongod --config ~/mongodb/shard/config-secondary2/start.conf &

# 开启shard1
echo "shard1"
mongod --config ~/mongodb/shard/shard1-primary/start.conf &
mongod --config ~/mongodb/shard/shard1-secondary1/start.conf &
mongod --config ~/mongodb/shard/shard1-secondary2/start.conf &

# 开启shard2
echo "shard2"
mongod --config ~/mongodb/shard/shard2-primary/start.conf &
mongod --config ~/mongodb/shard/shard2-secondary1/start.conf &
mongod --config ~/mongodb/shard/shard2-secondary2/start.conf &

# mongos路由进程
echo "mongos路由进程"
mongos --config ~/mongodb/shard/mongos/start.conf &
