<!-- vim-markdown-toc GFM -->

* [Redis](#redis)
    * [软件架构](#软件架构)
    * [基本命令](#基本命令)
        * [使用unix sock连接](#使用unix-sock连接)
    * [数据类型](#数据类型)
        * [string (字符串)](#string-字符串)
            * [Bitmaps(位图)](#bitmaps位图)
        * [hash (哈希散列)](#hash-哈希散列)
        * [list (列表)](#list-列表)
        * [set (集合)](#set-集合)
            * [交集,并集,补集](#交集并集补集)
        * [zset(有序集合)](#zset有序集合)
            * [交集,并集](#交集并集)
            * [geo(地理信息定位)](#geo地理信息定位)
        * [streams(消息队列)](#streams消息队列)
    * [Module(模块)](#module模块)
        * [RedisJSON](#redisjson)
        * [RediSearch](#redisearch)
    * [HyperLogLog](#hyperloglog)
    * [transaction (事务)](#transaction-事务)
    * [pipelining(流水线执行命令)](#pipelining流水线执行命令)
    * [Lua 脚本](#lua-脚本)
            * [脚本示例](#脚本示例)
    * [python](#python)
        * [redis-py](#redis-py)
        * [redis-om-python: 对象模板](#redis-om-python-对象模板)
        * [pottery:以python的语法访问redis](#pottery以python的语法访问redis)
    * [配置](#配置)
        * [config](#config)
        * [info](#info)
        * [ACL](#acl)
        * [slowlog(慢查询日志)](#slowlog慢查询日志)
        * [client](#client)
            * [monitor](#monitor)
        * [远程登陆](#远程登陆)
    * [persistence (持久化) RDB AOF](#persistence-持久化-rdb-aof)
        * [RDB](#rdb)
        * [AOF(append only log)](#aofappend-only-log)
            * [AOF重写](#aof重写)
            * [恢复](#恢复)
    * [master slave replication (主从复制)](#master-slave-replication-主从复制)
        * [主从建立过程](#主从建立过程)
        * [主从复制过程](#主从复制过程)
    * [sentinel (哨兵模式)](#sentinel-哨兵模式)
        * [开启 sentinal](#开启-sentinal)
        * [sentinel 的命令](#sentinel-的命令)
    * [cluster (集群)](#cluster-集群)
    * [publish subscribe (发布和订阅)](#publish-subscribe-发布和订阅)
        * [键空间通知](#键空间通知)
    * [redis-benchmark性能测试](#redis-benchmark性能测试)
    * [优化](#优化)
* [docker](#docker)
    * [Grafana监控](#grafana监控)
* [redis 如何做到和 mysql 数据库的同步](#redis-如何做到和-mysql-数据库的同步)
* [redis 安装](#redis-安装)
    * [centos7 安装 redis6.0.9](#centos7-安装-redis609)
    * [docker install](#docker-install)
* [常见错误](#常见错误)
    * [vm.overcommit_memory = 1](#vmovercommit_memory--1)
* [第三方 redis 软件](#第三方-redis-软件)
        * [iredis: 比redis-cli更强大](#iredis-比redis-cli更强大)
        * [redis-tui](#redis-tui)
        * [redis-memory-analyzer](#redis-memory-analyzer)
        * [RedisInsight: 官方推出的gui, 并且带有补全的cli](#redisinsight-官方推出的gui-并且带有补全的cli)
        * [AnotherRedisDesktopManager: gui](#anotherredisdesktopmanager-gui)
        * [RedisLive: 可视化](#redislive-可视化)
        * [redis-rdb-tools](#redis-rdb-tools)
        * [redis-shake](#redis-shake)
        * [dbatools](#dbatools)
* [reference](#reference)
* [online tool](#online-tool)

<!-- vim-markdown-toc -->

# Redis

## 软件架构

- [腾讯技术工程: Redis 多线程网络模型全面揭秘](https://segmentfault.com/a/1190000039223696)

- [深入学习Redis（1）：Redis内存模型](https://www.cnblogs.com/kismetv/p/8654978.html)

    > 内存, 数据类型

- 数据保存在内存里: 因此 Redis 也常常被用作缓存数据库,实现高性能、高并发

- 单线程: 因此客户端发送的命令, 只会进入1条队列

    - Redis 的多线程部分只是用来处理网络数据的读写和协议解析，执行命令仍然是单线程

    - 优点:

        - 没有并发问题, 因此没有锁

        - 减少上下文切换

    - 缺点:

        - 只有1条队列, 可能会造成其他命令阻塞

    - Redis4.0 加入多线程处理异步任务

        - 问题: 非常耗时的命令如 `DEL`, 在删除上百个对象时, 会阻塞

        - 解决方法: 加入一些非阻塞命令如 `UNLINK`(DEL的异步版), `FLUSHALL ASYNC`, `FLUSHDB ASYNC`

            - `UNLINK` 并不会同步删除key, 只是从keyspace移除key, 将任务放入一个异步队列, 再由后台线程删除

                - 如果是小key, 异步删除反而开销更大, 因此只有元素大于64才会使用异步删除

    - Redis6.0 在网络模型中实现I/O多线程

        - 问题: 网络I/O瓶颈

        - 解决方法:

            - 1.每个客户端的连接都会初始化一个`client` 的对象, 并维护有一条命令队列

            - 2.I/O线程读取命令队列, 并解析第一条命令, **但不执行命令**

            - 3.等所有I/O线程完成读取后, 命令交由主线程处理, 将结果写入每个`client` 对象的buf

            - 4.I/O线程把`client`里的buf, 写回客户端


    - Redis 会设置cpu affinity, 也就是把进程/线程, 子进程/线程绑定到不同的cpu, 从而防止上下文切换的缓存失效

- 使用`epoll`多路 I/O 复用: 非阻塞 I/O [具体可看这个解答](https://www.zhihu.com/question/28594409)

    - redis会将epoll的连接, 读写, 关闭转换为事件

- Redis 相比 Memcached 来说，拥有更多的数据结构，能支持更丰富的数据操作,此外单个 value 的最大限制是 1GB，不像 memcached 只能保存 1MB 的数据

## 基本命令

- [Redis 命令参考](http://doc.redisfans.com/)

- 客户端:

    ```sh
    # 默认以ip127.0.0.1, port6379连接
    redis-cli

    # 等同于上
    redis-cli -h 127.0.0.1 -p 6379

    # 执行命令. key1值为1
    redis-cli set key1 1

    # -x 表示读取最后一个参数. key2值为2\n
    echo 2 | redis-cli -x set key2

    # 获取大key(内部采用scan)
    redis-cli --bigkeys

    # 每隔1秒获取内存占用, 一共获取100次. -r: 执行多次, -i: 每隔几秒执行一次
    redis-cli -r 100 -i 1 info | grep used_memory_human

    # 每隔一秒获取info的统计信息
    redis-cli --stat

    # 关闭redis服务器
    redis-cli shutdown
    # 关闭服务前进行持久化
    redis-cli shutdown save

    # 测试于服务器的网络延迟
    redis-cli --latency

    # 测试于服务器的网络延迟
    redis-cli --latency

    # --eval 执行lua
    redis-cli --eval file.lua arg
    ```

- 常用命令(对单个key)
```redis
# 创建一个 key 为字符串对象, 值也为字符串对象的 key 值对
SET msg "hello world !!!"

# 对同一个 key 设置,会覆盖值以及存活时间
SET msg "hello world"

# 查看msg
get msg

# 返回原来的值, 并设置新的值
getset msg "hw"

# EX 设置 key 的存活时间, 单位秒
SET msg "hello world" EX 100
# 或者
expire msg 100

# 输入负数等同于DEL命令
expire msg -1

# timestamp(时间戳)后过期
expireat msg timestamp

# 毫秒后过期
pexpire msg 10000

# 毫秒timestamp(时间戳)后过期
expireat msg timestamp

# persist 可以移除存活时间
persist msg

# ttl 查看 key 存活时间, 单位秒. -1表示key没有设置过期时间, -2表示key不存在(已经过期)
ttl msg

# pttl 查看 key 存活时间, 单位毫秒
pttl msg

# strlen 查看 key 长度
strlen msg

# exists 查看 key 是否存在
exists msg

# type 查看 key 类型. 对应源代码里的RedisObject结构里的type
type msg

# object 查看 key 的编码. 对应源代码里的RedisObject结构里的encoding
object encoding msg

# 查看最后一次访问该key是多少秒之前. 对应源代码里的RedisObject结构里的lru
object IDLETIME msg

# 查看最后一次访问该key是多少秒之前. 对应源代码里的RedisObject结构里的refcount
object refcount msg

# 随机返回一个key
randomkey

# 改名, 会覆盖a
rename msg a

# renamenx 改名,如果a存在,那么改名失败
renamenx msg a
```

- 遍历所有key

    - `keys` 命令: 遍历所有key(阻塞命令, 不建议在生成环境下使用)

    - `scan` 命令: 渐进式遍历key. 以0为游标开始, 默认搜索10个key. 然后返回一个游标,如果游标的结果为0,表示所有key已经遍历过了(非阻塞. 时间复杂度O(1))

        - 问题: 如果执行过程中key发生变化, 那么可能无法遍历到新的key, 也可能会遍历重复的key

    | 阻塞     | 非阻塞 |
    |----------|--------|
    | keys     | scan   |
    | hgetall  | hscan  |
    | smembers | sscan  |
    | zrange   | zscan  |

    ```redis
    # 搜索包含 s 的key
    keys *s*

    # 从0游标开始
    scan 0

    # 以0为游标开始搜索,count指定搜索100个key(默认值是10)
    scan 0 count 100

    # match 搜索包含 s 的key
    scan 0 match *s* count 100

    # type 搜索不同对象的key
    scan 0 count 100 type list
    ```

- `migrate` 命令: 将 **key** 移动到另一个 **redis-server**

    ```redis
    set a 0

    # 将a 迁移到127.0.0.1:7777(对docker启动的redis无效)
    MIGRATE 127.0.0.1 7777 a 0 1000
    ```

    ![avatar](./Pictures/redis/migrate.gif)

- 常用命令(对多个key)
```redis
# move 将当前数据库的的 key ,移动到数据库1
move msg 1

# select 选择数据库1(默认使用0号数据库, 一共有16个数据库0-15)
select 1

# dbsize 统计当前数据库的 key 数量
dbsize

# swapdb 交换不同数据库的key
swapdb 0 1

# flushdb 删除当前数据库的所有key(阻塞命令)
flushdb

# flushall 删除所有数据库的所有key(阻塞命令)
flushall

# shutdown 关闭redis-server,所有客户端也会被关闭
shutdown

# 导出 csv 文件
hset n a 1 b 2 c 3
redis-cli --csv hgetall n > stdout.csv 2> stderr.txt
```

### 使用unix sock连接

- unix socket 性能要更快

- 修改配置文件
```
# create a unix domain socket to listen on
unixsocket /var/run/redis/redis.sock

# set permissions for the socket
unixsocketperm 775
```

- [docker 上使用unix socket](https://medium.com/@jonbaldie/how-to-connect-to-redis-with-unix-sockets-in-docker-9e94e01b7acd)

```sh
# 使用unxi socket连接
redis-cli -s /var/run/redis/redis.sock
```

## 数据类型

Redis 数据库里面的每个键值对（key-value pair）都是由对象（object）组成的：

- 其中, 数据库键总是一个字符串对象（string object）；
- 而数据库键的值则可以是字符串对象、 列表对象（list object）、 哈希对象（hash object）、 集合对象（set object）、 有序集合对象（sorted set object）这五种对象中的其中一种.

| 对象         | type 命令输出 |
| ------------ | ------------- |
| 字符串对象   | "string"      |
| 列表对象     | "list"        |
| 哈希对象     | "hash"        |
| 集合对象     | "set"         |
| 有序集合对象 | "zset"        |

---

### string (字符串)

- 应用:
    - 计数
    - 计时器
        - 手机验证码
        - ip在规定时间范围内的访问次数

字符串对象的编码: [**详情**](http://redisbook.com/preview/object/string.html)

| 编码   | 作用                         |
|--------|------------------------------|
| int    | 8个字节的整型                |
| embstr | <=39 字节: 分配1次内存. 只读 |
| raw    | >=39 字节: 分配2次内存       |

- C 字符串 vs SDS(动态字符串)：

    - 获取字符串长度的时间复杂度: C为O(n), SDS为O(1)

    - 杜绝缓冲区溢出, SDS缓冲区溢出时会重新分配内存

    - 修改字符串长度: C每次都需要重新分配内存, SDS记录free(剩余空间)可以减少分配内存的次数

    - 存储二进制数据: C以`0` 结尾, SDS以len记录为结尾

    - 使用SDS存储文本时, 可以兼容 C 字符串函数.

- refcount(RedisObject结构里的字段)和共享对象

    - 只支持整数值的字符串类型

        - redis启动时会创建0-9999的整数值, 用作共享对象

        - 因为判断整数的时间复杂度为O(1); 字符串为O(n); list, hash, set, 有序集合为O(n^2)

    - refcount为0时, 就会从内存删除

    - refcount大于1时, 表示共享对象

    - 创建新对象时refcount为1, 有新程序使用时加1, 不再被新程序使用时减1

| 命令        | 时间复杂度       |
|-------------|------------------|
| msetnx      | O(k) k是健的个数 |
| mget        | O(k) k是健的个数 |
| mset        | O(k) k是健的个数 |
| getrange    | O(N)             |
| bitpos      | O(N)             |
| bitop       | O(N)             |
| bitcount    | O(N)             |
| append      | O(1)             |
| strlen      | O(1)             |
| setex       | O(1)             |
| setrange    | O(1)             |
| setnx       | O(1)             |
| setbit      | O(1)             |
| psetex      | O(1)             |
| incrby      | O(1)             |
| incrbyfloat | O(1)             |
| incr        | O(1)             |
| getbit      | O(1)             |
| get         | O(1)             |
| getset      | O(1)             |
| set         | O(1)             |
| decrby      | O(1)             |
| decr        | O(1)             |
| bitfield    | O(1)             |

```redis
# setnx 如果健不存在,才创建
# 因为msg健已经存在,所以创建失败
setnx msg "test exists"
# 创建成功
setnx test "test exists"

# 查看 前5个字符
getrange msg 0 5
# 查看 倒数5个字符
getrange msg -5 -1

# 修改为HELLO,从第一个字符开始
setrange msg 0 'HELLO'

# 修改为WORLD,从第6个字符开始
setrange msg 6 WORLD

# 在末尾添加" tz"
append msg " tz"
```

- `Mset`创建多个健. 可以减少rtt(网络往返时间)

```redis
# 对多个健进行赋值(我这里是a,msg)
mset a 1 msg tz

# 如果这其中有一个健是存在的,那么都不会进行赋值
msetnx a '2' b '3' msg "tz-pc"

# 查看多个健
mget a b msg

# 删除 a,msg健
del a msg
```

- num(数), 依然是string(字符串)类型
```redis
set a 1

# incr 对a加1(只能对 64位 的unsigned操作)
incr a

# incrby 对a加10(只能对 64位 的unsigned操作)
incrby a 10

# incrbyfloat 对a加1.1
incrbyfloat a 1.1

# incrbyfloat 对a减1.1
incrbyfloat a -1.1

# decr 对a减1(只能对 64位 的unsigned操作)
decr a

# decrby 对a减10(只能对 64位 的unsigned操作)
decrby a 10
```

#### Bitmaps(位图)

- 本质上是string类型

- 记录用户是否活跃

```redis
# 2022-3-19. id为5, 10, 15用户活跃
setbit 2022-3-19 5 1
setbit 2022-3-19 10 1
setbit 2022-3-19 15 1

# 2022-3-20
setbit 2022-3-20 5 1
setbit 2022-3-20 15 1

# 查看id10的用户是否活跃
getbit 2022-3-19 10

# 查看活跃用户的总数
bitcount 2022-3-19

# 查看活跃当中, 最小的用户id
bitpos 2022-3-19 1

# 查看不活跃当中, 最小的用户id
bitpos 2022-3-19 0
```

- 复合运算: `bitop <op> key key`

    - `and`(交集), `or`(并集), `not`(非), `xor`(异或)

```redis
# 交集. 查看这两天都活跃的用户总数, 并保存2022-3-19:and:2022-3-20
bitop and 2022-3-19:and:2022-3-20 2022-3-19 2022-3-20
bitop or 2022-3-19:or:2022-3-20 2022-3-19 2022-3-20
```

### hash (哈希散列)

- 应用:

    - 相比于关系性数据库, hash是稀疏结构的(不需要修改表结构), 更灵活
    - 电商app的购物车

哈希对象的编码: [**详情**](http://redisbook.com/preview/object/hash.html)

| 编码      | 作用                                                                                                                                               |
| --------- | ---------------------------------------------------------------------------------------                                                            |
| ziplist   | 压缩列表：元素个数小于`hash-max-ziplist-entries`(默认512个) 和 元素字节小于`hash-max-ziplist-value`(默认64字节) . 该编码更节约内存. 时间复杂度O(n) |
| hashtable | 字典: 无法ziplist条件时使用该编码. 时间复杂度为O(1)                                                                                                |

| 命令         | 时间复杂度          |
|--------------|---------------------|
| hkeys        | O(k) k是filed的总数 |
| hvals        | O(k) k是filed的总数 |
| hgetall      | O(k) k是filed的总数 |
| hmset        | O(k) k是filed的个数 |
| hmget        | O(k) k是filed的个数 |
| hdel         | O(k) k是filed的个数 |
| hscan        | O(1)                |
| hstrlen      | O(1)                |
| hsetnx       | O(1)                |
| hlen         | O(1)                |
| hexists      | O(1)                |
| hincrby      | O(1)                |
| hget         | O(1)                |
| hincrbyfloat | O(1)                |
| hset         | O(1)                |

> ```redis
> HSET 表名 域名1 域值1 域名2 域值2 ...
> ```

```redis
# 一次创建多个域
hset n a 1 b 2 c 3

hmset n a 1 b 2 c 3
# 修改 a域为-1
hset n a -1

# hsetnx 如果a域存在,则不修改值
hsetnx n a 0

# 获取a域
hget n a

# hgetall 获取n的所有域和值(阻塞命令, 类似keys命令)
hgetall n

# 渐进式遍历(非阻塞, 类似于scan命令)
hscan n 0

# hkeys 查看n表里的所有域名
hkeys n

# hvals 查看n表里的所有域值
hvals n

# hexists 查看n表里是否存在a域
hexists n a

# hget 只查看n表里的a域
hget n a

# hmget 查看n表里的a,b域
hmget n a b

# 查看n表有多少个域
hlen n
# 查看a域的长度
hstrlen n a

# 删除指定域
hdel table a

# 删除整个table表
del table
```

对域的值进行加减

```redis
# a域的值加10(只能对 64位 的unsigned操作)
hincrby n a 10

# a域的值减5(只能对 64位 的unsigned操作)
hincrby n a -5

# a域的值加1.1
hincrbyfloat n a 1.1

# a域的值减1.1
hincrbyfloat n a -1.1
```

### list (列表)

- 应用:

    - stack(栈): lpush + lpop

    - queue(队列): lpush + rpop

    - 环形队列: lpush + ltrim

    - mq(消息队列): lpush + brpop实现阻塞队列

    - 文章列表:

        - 文章使用hash实现

            ```redis
            hmset acticle:1 title xx timestamp 1476536196 content xxxx
            ```

            - 问题: 获取多个文章都需要执行多次`hgetall`

                - 解决方法1: 使用pipeline(流水线执行命令)

                - 解决方法2: 文章序列化为string类型, 获取时使用`mget`

        - 使用列表把文章组合起来

            ```redis
            lpush user:1:acticles article:1 article:2
            ```

列表对象的编码: [**详情**](http://redisbook.com/preview/object/list.html)

| 编码         | 作用                                                                                                                                                                                                            |
| ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  |
| ziplist      | 等同于hash的ziplist                                                                                                                                                                                             |
| linkedlist   | 每个双端链表节点（node）都保存了一个字符串对象,而每个字符串对象都保存了一个列表元素.                                                                                                                            |
| 　 quickList | zipList 和 linkedList 的混合体,它将 linkedList 按段切分,每一段使用 zipList 来紧凑存储,多个 zipList 之间使用双向指针串接起来.默认的压缩深度是 0,也就是不压缩.压缩的实际深度由配置参数 `list-compress-depth` 决定 |

![avatar](./Pictures/redis/list5.avif)

| 命令       | 时间复杂度                           |
|------------|--------------------------------------|
| lrange     | O(S+N) S是start, N是start到end的范围 |
| ltrim      | O(N) N是裁剪的元素总数               |
| lset       | O(N) N是索引偏移量                   |
| linsert    | O(N) N是索引偏移量                   |
| lindex     | O(N)                                 |
| lrem       | O(N) N是列表长度                     |
| rpushx     | O(1)                                 |
| rpush      | O(k) k是健的个数                     |
| rpop       | O(1)                                 |
| rpoplpush  | O(1)                                 |
| lpushx     | O(1)                                 |
| lpush      | O(k) k是健的个数                     |
| lpop       | O(1)                                 |
| llen       | O(1)                                 |
| brpoplpush | O(1)                                 |
| brpop      | O(1)                                 |
| blpop      | O(1)                                 |

```redis
# 左插入
lpush list 2
lpush list 1

# 右插入
rpush list 3
rpush list 4

# 查看列表list
lrange list 0 -1

# 查看长度
llen list

# 左弹出
lpop list

# 右弹出
rpop list

# lpushx,rpushx不能对不存在的表进行插入
lpushxlist-null a a b b c c
rpushx list-null a a b b c c
```

```redis
lpush list1 a

# 右弹出list, 左插入到list1
rpoplpush list list1

# 弹出自己的最后一个值, 插入到第一位
rpoplpush list list
```

- brpop

```redis
# brpoplpush 是 rpoplpush 的阻塞版本
# 在 MULTI / EXEC 块(事务)中没有意义

# ll列表元素为空则阻塞, 如不为空则等同于rpop. 以下是阻塞时间3秒, 3秒后没有其它客户端插入就返回nil
brpop ll 3

# 0秒表示一直阻塞下去, 直到有客户端插入
brpop ll 0

# 阻塞多个列表, 只要其中有一个列表插入, 就返回
brpop ll ll1 ll2 0
```

```redis
# 查看ll的第1个值(注意:0表示第1个值)
lindex ll 0

# 查看ll的第2个值(注意:1表示第2个值)
lindex ll 1

# 查看ll的最后一个值
lindex ll -1

# 在第一个a值,前面插入b值
linsert ll before a b

# 在第一个a值,后面插入1值
linsert ll after a 1

# 将ll的第一个值修改为hello
lset ll 0 hello

# 只保留 前两个值(注意:0表示第1个值,1表示第2个值)
ltrim ll 0 1

# 移除两个b值
lrem ll 2 b
```

**sort 排序**: 只能对 _数字_ 或者 _字符串_ 进行排序(默认会按数字排序,如果有数字和字符串会报错)

```redis
# 新建两个列表
lpush gid 1 3 5 2 0
lpush name apple joe john

sort gid

# 倒序
sort gid desc

# 按字符排序
sort name alpha

# limit 进行筛选,倒序显示第 2 个到第 4 个
sort gid limit 2 4 desc
```

`by` 通过**字符串对象的值**来对 list 进行排序:

```redis
# 新建 uid 列表
lpush uid 1 2 3

# 新建三个字符串
set level1 100
set level2 10
set level3 1000

sort uid

# 通过level的大小对uid排序
sort uid by level*
```


`get` 通过 list 的顺序对 字符串 进行排序(反过来的 by)：

```redis
# 新建三个字符串
set name1 joe
set name2 john
set name3 xiaoming

# 通过uid的顺序,对 name 进行排序
sort uid get name*
# 对 name , level 进行排序
sort uid get name* get level*

# by 一个不存在的key(我这里是not).get的key值,不会进行排序
sort uid by not get name* get level*

# store 将结果,保存为新的列表key(注意会覆盖已经存在的列表key)
sort uid get name* get level* store name-level
```

### set (集合)

- 应用:

    - 标签
        ```redis
        # 给用户加标签
        sadd user:1 tag1 tag2
        ```
        ```redis
        # 给标签加用户
        sadd tag:1 user1 user2
        ```

集合对象的编码: [**详情**](http://redisbook.com/preview/object/set.html)

| 编码      | 作用       |
| --------- | ---------- |
| intset    | 整数. 节省内存, O(n)       |
| hashtable | 字典: 无法intset条件时使用该编码. 时间复杂度为O(1) |


| 命令        | 时间复杂度                                      |
|-------------|-------------------------------------------------|
| sinterstore | O(N*M) n是多个集合中元素最少的个数, m是健的个数 |
| sinter      | O(N*M) n是多个集合中元素最少的个数, m是健的个数 |
| sunion      | O(N) n是多个集合的个数和                        |
| sunionstore | O(N)n是多个集合的个数和                         |
| sdiff       | O(N) n是多个集合的个数和                        |
| sdiffstore  | O(N)n是多个集合的个数和                         |
| srem        | O(k) k是元素的个数                              |
| smembers    | O(N) n是元素的总数                              |
| sscan       | O(1)                                            |
| spop        | O(1)                                            |
| sismember   | O(1)                                            |
| srandmember | O(count)                                        |
| sadd        | O(k) k是元素的个数                              |
| scard       | O(1)                                            |
| smove       | O(1)                                            |

```redis
# 新建一个集合,名为jihe .字符串的集合编码为hashtable
sadd jihe 'test'
sadd jihe 'test1' 'test2' 'test3' 123

# 查看集合jihe所有元素, 返回结果是无序的(阻塞命令, 类似keys命令)
smembers jihe

# 渐进式遍历(非阻塞, 类似于scan命令)
sscan jihe 0

# 数字的集合编码为intset
sadd s 123

# 查看编码为intset
object encoding s

# 数字和字符都有的集合,编码为hashtable
sadd s test

# 再次查看编码发现已经变为hashtable
object encoding s
```

那如果一个集合,包含数和字符串,把字符串的值删除后.**编码**会变吗？

```redis
# 新建ss集合,包含数和字符串
sadd ss 123 'test'

# 查看编码为hashtable
object encoding ss

# 删除 ss 集合里的test字符串值
srem ss test

# 再次查看编码为hashtable. 没有变
object encoding ss
```

```redis
# 查看集合个数
scard jihe

# 查看集合是否有test值.有返回1,无返回0
sismember jiehe "test"

# 搜索jihe包含 t 的字符
sscan jihe 0 match *t*

# 删除集合里的test,test1值
srem jihe test test1

# 将jihe里的值123,移到jihe1
smove jihe jihe1 123

# 弹出随机一个数
spop jihe

# 弹出随机2个数
spop jihe 2

# 查看随机一个数
srandmember jihe

# 查看随机2个数
srandmember jihe 2
```

#### 交集,并集,补集

```redis
# 新建两个集合
sadd sss 123 test test1
sadd ssss 123 test abc cba

# sinter 返回两个集合的交集
sinter sss ssss

# sunion 返回两个集合的并集
sunion sss ssss

# sdiff 返回sss的补集
sdiff sss ssss
# sdiff 返回ssss的补集
sdiff ssss sss

# 返回交集,并集,补集的数量
sinterstore sss ssss
sunionstore sss ssss
sdiffstore sss ssss

# 保存集合运算的结果
sinterstore s-inter sss ssss
sunionstore s-union sss ssss
sdiffstore s-diff sss ssss
```

![avatar](./Pictures/redis/set2.avif)

### zset(有序集合)

- 应用

    - 排行榜

有序集合对象的编码: [**详情**](http://redisbook.com/preview/object/sorted_set.html)

| 编码     | 作用                                                                                                                                                                             |
| -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------  |
| ziplist  | 每个集合是两个节点来保存, 第一个节点保存元素的成员（member）, 而第二个元素则保存元素的分值（score）.集合按分值从小到大进行排序, 分值较小的元素放在表头, 而分值较大的元素在表尾. |
| skiplist | 跳跃表: 平均O(logN)、最坏O(N) |

**ziplist:** (其余情况使用 skiplist)

- 有序集合保存的成员(member)数量小于 128 个.
  配置参数:(zset-max-ziplist-entries)

- 成员(member)的长度都小于 64 字节.
  配置参数:(zset-max-ziplist-value)

| 命令             | 时间复杂度                                                                 |
|------------------|----------------------------------------------------------------------------|
| zinterstore      | O(N*K)+O(M*log(M)) n是成员数最小的集合, k是集合的个数, m是结果集合中的个数 |
| zunionstore      | O(N)+O(M*log(M)) n是所有集合成员的个数和, m是结果集合中的个数              |
| zrem             | O(M*log(N)) m是删除成员的个数, n是当前集合的个数                           |
| zrevrange        | O(log(N)+M)                                                                |
| zremrangebyrank  | O(log(N)+M)                                                                |
| zremrangebyscore | O(log(N)+M)                                                                |
| zrevrangebylex   | O(log(N)+M)                                                                |
| zrangebyscore    | O(log(N)+M)                                                                |
| zremrangebylex   | O(log(N)+M)                                                                |
| zrevrangebyscore | O(log(N)+M)                                                                |
| zrangebylex      | O(log(N)+M)                                                                |
| zrange           | O(log(N)+M)                                                                |
| zpopmin          | O(log(N)*M)                                                                |
| zpopmax          | O(log(N)*M)                                                                |
| zrevrank         | O(log(N)) n是当前有序集合的个数                                            |
| zrank            | O(log(N)) n是当前有序集合的个数                                            |
| zlexcount        | O(log(N))                                                                  |
| zincrby          | O(log(N))                                                                  |
| zadd             | O(log(N)*M) m是添加成员的个数, n是当前有序集合的个数                       |
| zcount           | O(log(N))                                                                  |
| bzpopmax         | O(log(N))                                                                  |
| bzpopmin         | O(log(N))                                                                  |
| zscan            | O(1)                                                                       |
| zscore           | O(1)                                                                       |
| zcard            | O(1)                                                                       |

```redis
# 新建有序集合名为z, 按score(分数)排序
zadd z 1 a 1 b 2 c 3 d
zadd z 1 100

# 查看z (阻塞命令, 类似keys命令)
zrange z 0 -1

# 包含score. 渐进式遍历(非阻塞, 类似于scan命令)
zscan z 0

# 查看z的第3个到第4个元素
zrange z 2 3

# 查看z, 包含score
zrange z 0 -1 withscores

# 倒序查看z
zrevrange z 0 -1 withscores

# 查看socre值是1到100的成员
zrangebyscore z 1 100
# 查看所有socre值的成员
zrangebyscore z -inf inf

# 查看所有socre值的成员, 包含socre
zrangebyscore z -inf inf withscores

# 倒序
zrevrangebyscore z 100 1
zrevrangebyscore z inf -inf

# 查看元素的个数
zcard z

# 查看a值是那个score值
zscore z a

# 查看a值的score排名(排名以 0 为底)
zrank z a

# 倒序a值的score排名(排名以 0 为底)
zrevrank z a

# 统计a值到b值的之间个数(包含a,b值)
zlexcount z [a [b

# 对成员100的score加1000
zincrby z 1000 100

# 统计score值是1到100的个数
zcount z 1 100

# 删除成员
zrem z a

# 删除前两个成员
zremrangebyrank z 0 1

# 删除score为2到3的所有成员(包括2,3)
ZREMRANGEBYSCORE z 2 3

# 删除从开头到c的成员(包括c)
zadd zz 1 a 1 b 2 c 3 d
zremrangebylex zz - [c

# 删除从开头到c的成员(不包括c)
zadd zzz 1 a 1 b 2 c 3 d
zremrangebylex zzz - (c

# 删除从a开头到c的成员(不包括c)
zadd zzzz 1 a 1 b 2 c 3 d
zremrangebylex zzzz [aaa (c

# 删除从score大于2的成员(不包含)
zremrangebyscore zzzz (2 +inf
```

#### 交集,并集

**ZUNIONSTORE (并集)**

> ```redis
> ZUNIONSTORE 新建的有序集合名 合并的数量 有序集合1 有序集合2... WEGHTS 有序集合1的乘法因子 有序集合2的乘法因子...
> ```

```redis
# 新建三个有序集合
zadd z1 1 a1 2 b1 3 c1 4 d1 5 e1
zadd z2 1 a2 2 b2 3 c2 4 d2 5 e2
zadd z3 1 a3 3 b3 3 c3 4 d3 5 e3

# 将z1,z2,z3 并集到名为 unionz 的有序集合(3表示合并3个有序集合也就是z1,z2,z3)
zunionstore unionz 3 z1 z2 z3
```

![avatar](./Pictures/redis/sortset.avif)

使用 WIGHTS 给 不同的有序集合 分别 指定一个乘法因子来改变排序 (默认设置为 1 )

```redis
# z1的值乘1,z2乘10,z3乘100
zunionstore unionz 3 z1 z2 z3 WEIGHTS 1 10 100
```

![avatar](./Pictures/redis/sortset1.avif)

```redis
# 这次是z2乘10,z3乘100
zunionstore unionz 3 z1 z2 z3 WEIGHTS 1 100 10
```

![avatar](./Pictures/redis/sortset2.avif)

```redis
# z1,z2乘10,z3乘10
zunionstore unionz 3 z1 z2 z3 WEIGHTS 1 1 10
```

![avatar](./Pictures/redis/sortset3.avif)

**ZINTERSTORE (交集)**

```redis
# 新建math(数学分数表) 小明100分,小红60分
zadd math 100 xiaoming 60 xiaohong

# 新建历史(历史分数表) 小明50分,小红90分
zadd history 50 xiaoming 90 xiaohong

# 通过zinterstore 交集进行相加
zinterstore sum 2 math history
```

![avatar](./Pictures/redis/sortset4.avif)

#### geo(地理信息定位)

- 实际上是zset(有序集合)类型

    - 通过`geohash`命令 和 `zset` 类型, 实现geo的命令

```redis
# 新建北京和广州的经纬度
geoadd china 116.28 39.55 beijing
geoadd china 113.26 23.12 guangzhou

# 查看广州的经纬度
geopos china guangzhou

# 查看广州和北京之间的距离, 单位km
geodist china guangzhou beijing km

# 查看以北京为圆心, 半径为2000km内的城市
georadiusbymember china beijing 2000 km

# 生成北京的经纬度的hash(两个字符串越相似, 距离越短)
geohash china beijing

# 删除成员
zrem china beijing
```

### streams(消息队列)

- [官方文档](https://redis.io/topics/streams-intro)

- append-only数据结构

| 命令       | 时间复杂度 |
|------------|------------|
| xpending   | O(N)       |
| xread      | O(N)       |
| xrange     | O(N)       |
| xtrim      | O(N)       |
| xrevrange  | O(N)       |
| xinfo      | O(N)       |
| xreadgroup | O(M)       |
| xclaim     | O(log N)   |
| xack       | O(1)       |
| xlen       | O(1)       |
| xadd       | O(1)       |
| xdel       | O(1)       |
| xgroup     | O(1)       |

```redis
# 添加队列(返回id值), *表示自动生成id(毫秒 + 偏移量))
XADD mystream * key0 0
XADD mystream * key1 1 key2 2

# 指定id值
XADD mystream1 0-1 key0 0
XADD mystream1 0-2 key1 1 key2 2
XADD mystream1 10-1 key0 0
XADD mystream1 11-1 key0 0
XADD mystream1 100-1 key0 0

# 先插入entry, 并且只保留最新2条entry
XADD mystream MAXLEN 2 * value 1
# 或者
XTRIM mystream MAXLEN 1
XADD mystream * value 1

# 删除entry
XDEL mystream <id值>

# 查看长度. 返回2
XLEN mystream

# 查看队列
XRANGE mystream - +
# 查看队列, 顺序相反显示
XREVRANGE mystream + -

# 查看队列的详细信息
XINFO STREAM mystream

# 查看队列, 通过id值
XRANGE mystream1 <start:id值> <end:id值>

# 查看前2条entry
XRANGE mystream - + COUNT 2

# 查看指定id值后的2条entry
XRANGE mystream <id值> + COUNT 2


# XREAD(非阻塞), 查看mystream队列
XREAD STREAMS mystream 0

# 查看前2条entry
XREAD COUNT 2 STREAMS mystream 0

# 阻塞获取最新的entry, 获取后返回
XREAD BLOCK 0 STREAMS mystream $
```

- Consumer groups(消费者组)

    > 多个消费者获取单个stream. entry被哪个消费者获取? 取决于哪个消费者更快(竞争)

```redis
# 为mystream创建消费者组
XGROUP CREATE mystream mygroup $

# 查看组内的指定队列
XINFO GROUPS mystream

# MKSTREAM: 可以创建一个不存在的流
XGROUP CREATE newstream mygroup $ MKSTREAM

# 创建user0, 并获取最新的1条entry
XREADGROUP GROUP mygroup user0 COUNT 1 STREAMS mystream >

# 创建user1, 并获取最新的1条entry(最新的entry, 被user0还是user1获取? 取决于谁更快执行这条命令)
XREADGROUP GROUP mygroup user1 COUNT 1 STREAMS mystream >

# 查看user0, 已经获取的entry
XREADGROUP GROUP mygroup user0 STREAMS mystream 0

# 确认已经获取的entry, 确认后的entry无法从XREADGROUP获取
XACK mystream mygroup <id值>

# 查看指定队列的entry的处理情况
XPENDING mystream mygroup

# 查看所有entry的users获取情况(第三个参数为: entry从XADD到user XREADGROUP的时间(毫秒))
XPENDING mystream mygroup - + 2

# 查看每个user的entry的处理情况
XINFO CONSUMERS mystream mygroup

# 1小时后修改指定entry的ack用户为user1
XCLAIM mystream mygroup user1 3600000 <id值>

# 1小时后修改指定entry在内的后10条entry的, ack用户为user1
XAUTOCLAIM mystream mygroup user1 3600000 <id值> COUNT 10
```

- 三种查询模式

## Module(模块)

- docker安装

    ```sh
    # 包含所有模块
    docker run -d -p 6379:6379 redislabs/redismod
    ```

### [RedisJSON](https://oss.redis.com/redisjson/)

- [RedisJson 横空出世，性能碾压ES和Mongo！](https://cloud.tencent.com/developer/article/1922607)

    > 性能对比

- 编译安装

    ```sh
    # 进入redisjson的github仓库, 下载Releases里的source.zip文件
    curl -LO https://github.com/RedisJSON/RedisJSON/archive/refs/tags/v2.0.7.zip

    # 解压, 进入目录后

    # 编译
    cargo build --release
    ```

    - 加载模块启动
    ```
    redis-server --loadmodule /home/tz/v2.0.7/RedisJSON-2.0.7/target/release/librejson.so
    ```

    - 写入配置文件, 再启动
    ```
    # 配置文件/var/lib/redis/redis.conf加入以下行
    loadmodule /home/tz/v2.0.7/RedisJSON-2.0.7/target/release/librejson.so

    # 启动
    redis-server /var/lib/redis/redis.conf
    ```

    - 客户端连接后, 查看加载的模块
    ```
    info modules
    ```

- 基础命令

```redis
# 设置key
JSON.SET js $ '"bar"'

# 获取key
JSON.GET js
# 输出: "\"bar\""

# 获取key, 友好的输出
JSON.RESP js
# 输出: "bar"

# 删除key
JSON.DEL js

# 查看key类型
JSON.TYPE js

# 查看key的内存占用, 单位为bytes
JSON.DEBUG MEMORY js
```

- 字符串

```redis
JSON.SET js-str $ '"bar"'

# 查看长度
JSON.STRLEN js-str

# 在尾部添加字符串
JSON.STRAPPEND js-str '"baz"'
```

- 数(包含整数, 小数)

```redis
JSON.SET js-num $ 0

# 加1
JSON.NUMINCRBY js-num $ 1

# 减-0.75
JSON.NUMINCRBY js-num $ -0.75

# 乘2
JSON.NUMMULTBY js-num $ 2

JSON.GET js-num
# 输出: 0.5
```

- 数组

```redis
JSON.SET js-arr $ []

# 在末尾添加元素0
JSON.ARRAPPEND js-arr $ 0

# 0表示在头部添加元素 -2 1
JSON.ARRINSERT js-arr $ 0 -2 -1

JSON.GET js-arr $
# 输出: "[[-2,-1,0]]"

# 删除第1个元素外的其他元素
JSON.ARRTRIM js-arr $ 1 1

JSON.GET js-arr $
# 输出: "[[-1]]"

# pop最后一个元素
JSON.ARRPOP js-arr $
```

- object

```redis
JSON.SET js-obj $ '{"name":"tz","age":24,"married": false}'

# 修改key
JSON.SET js-obj $.age 25

# 操作json内的字符串类型
JSON.STRLEN js-obj $.name

# 操作json内的数类型
JSON.NUMINCRBY js-obj $.age 1

# 查看长度
JSON.OBJLEN js-obj $

JSON.GET js-obj $
# 输出: "[{\"name\":\"tz\",\"age\":26,\"married\":false}]"

JSON.RESP js-obj $
# 输出:以下
1) 1) "{"
   2) "name"
   3) "tz"
   4) "age"
   5) "26"
   6) "married"
   7) "false"

# 查看key
JSON.OBJKEYS js-obj $
# 输出以下
1) 1) "name"
   2) "age"
   3) "married"
```

```redis
JSON.SET js-obj1 $ '{"f1": {"a":1}, "f2":{"a":2}}'

# 修改a值
JSON.SET js-obj1 $..a 3

JSON.GET js-obj1
# 输出: "{\"f1\":{\"a\":3},\"f2\":{\"a\":3}}"

JSON.GET js-obj1 $.f1
# 输出: "[{\"a\":3}]"

JSON.GET js-obj1 $..a
# 输出: "[3,3]"
```

### [RediSearch](https://oss.redis.com/redisearch/)

- 编译安装
    ```sh
    git clone https://github.com/RediSearch/RediSearch.git
    cd RediSearch
    sudo make setup
    make build
    make run
    ```

    ```sh
    redis-server --loadmodule /path/to/module/src/redisearch.so
    ```

> FT.CREATE {index_name} ON JSON SCHEMA {json_path} AS {attribute} {type}

```redis
# 创建name索引
FT.CREATE userIdx ON JSON SCHEMA $.user.name AS name TEXT

# 创建json
JSON.SET myDoc $ '{"user":{"name":"tz","tag":"look book","hp":1000, "age":24}}'

# 搜索name
FT.SEARCH userIdx '@name:(tz)'

    1) "1"
    2) "myDoc"
    3) 1) "$"
       2) "{\"user\":{\"name\":\"tz\",\"tag\":\"look book\",\"hp\":1000,\"age\":24}}"

# 返回指定Field
FT.SEARCH userIdx '@name:(tz)' RETURN 1 name

    1) "1"
    2) "myDoc"
    3) 1) "name"
       2) "tz"

# 高亮
FT.SEARCH userIdx '@name:(tz)' RETURN 1 name HIGHLIGHT FIELDS 1 name TAGS '<b>' '</b>'

    1) "1"
    2) "myDoc"
    3) 1) "name"
       2) "<b>tz</b>"

# 聚合
FT.AGGREGATE userIdx '*' LOAD 6 $.user.hp AS hp $.user.age AS age APPLY '@hp-@age' AS hp-age

    1) "1"
    2) 1) "hp"
       2) "1000"
       3) "age"
       4) "24"
       5) "hp-age"
       6) "976"

# 删除索引
FT.DROPINDEX userIdx

# 添加自动补全
FT.SUGADD autocomplete "tz" 100

# GET
FT.SUGGET autocomplete "t"

    "tz"
```

- 数组索引
```redis
JSON.SET types:1 . '{"title":"fileltype1", "tags":["json","ini","yaml"]}'
JSON.SET types:2 . '{"title":"fileltype2", "tags":["json","yaml"]}'

# 创建索引
FT.CREATE types-idx ON JSON PREFIX 1 types: SCHEMA $.tags.* AS tags TAG

FT.SEARCH types-idx "@tags:{json}"

    1) "2"
    2) "types:1"
    3) 1) "$"
       2) "{\"title\":\"fileltype1\",\"tags\":[\"json\",\"ini\",\"yaml\"]}"
    4) "types:2"
    5) 1) "$"
       2) "{\"title\":\"fileltype2\",\"tags\":[\"json\",\"yaml\"]}"

FT.SEARCH types-idx "@tags:{ini}"

    1) "1"
    2) "types:1"
    3) 1) "$"
       2) "{\"title\":\"fileltype1\",\"tags\":[\"json\",\"ini\",\"yaml\"]}"
```

## HyperLogLog

- 实际上是string类型, 通过一种基数算法实现set(集合)的效果

    - 算法论文: [Hyperloglog: the analysis of a near-optimal cardinality estimation algorithm](http://algo.inria.fr/flajolet/Publications/FlFuGaMe07.pdf)

    - 优点: 比set(集合)占用的内存小的多的多

    - 缺点: 存在误差率(官方数据是0.81%)

```redis
# 新建两个key
pfadd 2022-3-19 'id1' 'id2'
pfadd 2022-3-20 'id1' 'id2' 'id3' 'id4'

# 查看2022-3-19的数量
pfcount 2022-3-19

# 合并为一个2022-3-19:merge:2022-3-20
pfmerge 2022-3-19:merge:2022-3-20 2022-3-19 2022-3-20
pfcount 2022-3-19:merge:2022-3-20
```

## transaction (事务)

- transaction是原子操作, 保证执行多条命令的原子性

- 如果命令出现错误, 事务当同于未执行

- 不支持回滚

    - 因此要小心打错字

```redis
# 新建一个key
set t 100

# 开启事务
multi
# 修改key
incr t

# 保存事务
exec
# 如果不保存,discard可以恢复事务开启前
discard
```

- `watch`(乐观锁) 监视一个(或多个) key ,如果在事务执行之前这个(或这些) key 被其他命令所改动,那么事务将被打断

    - 两个客户端:

        - 右客户端开启事务后, 执行 `incr t` 后

        - 被左边执行 `set t 100` 修改了 t 的值

        - 所以右边在 `exec` 保存事务后,返回(nil).事务对 t 值的操作被取消

    | 左边客户端   | 右边客户端   |
    | ------------ | ------------ |
    |              | set t 100    |
    |              | watch t      |
    |              | multi        |
    |              | incr t       |
    |              | incr t       |
    | set t 100    |              |
    |              | exec         |

    ![avatar](./Pictures/redis/t.gif)

## [pipelining(流水线执行命令)](https://redis.io/topics/pipelining)

- 事务 vs pipelining:

    - 事务是原子的, pipelining不是原子的.因此事务不能同时运行, 而pipelining可以交替运行

    ![avatar](./Pictures/redis/redis-pipeline-vs-transaction.avif)

- 普通timeline vs pipelining:

    - 网络的优势:

        - 普通情况: 客户端向服务器发送命令, 然后等待响应. 每条命令的花费1次rtt(往返时间)

        - pipelining: 客户端向服务器一次发送多条命令. 多条命令花费1次rtt(往返时间)

    - io的优势:

        - 每次执行都需要read(), write()的系统调用

            - 因此pipelining让多条命令只使用1次read(), write(), 从而可以减少上下文调用

- 问题: redis cluster分布式方案下, 不能使用pipeline

    - 解决方法1: 客户端保存slot(哈希槽)和redis结点的关系

        - 支持的客户端有: go-redis

    - 解决方法2: [codis: 在服务器与客户端之间加入一层代理, 通过分槽实现pipeline](https://github.com/CodisLabs/codis)

```sh
# 发送一条PING命令
echo "PING" | nc localhost 6379

# 发送多条PING命令. \r\n结尾是redis客户端协议(RESP)
echo "PING\r\nPING\r\nPING" | nc localhost 6379
```

## Lua 脚本

- lua是原子操作, 保证执行多条命令的原子性

- `eval` 命令: 执行lua语句

```redis
# return 1 (0表示传递参数的数量)
eval "return 1" 0

# return 123
eval "return {1,2,3}" 0

# return key和值(这里是a和123)
eval "return {KEYS[1],ARGV[1]}" 1 a 123
eval "return {KEYS[1],KEYS[2],ARGV[1],ARGV[2]}" 2 a b 123 321
```

- `evalsha` 命令: 执行已经加载进redis内存的lua脚本

```redis
# script load 会把脚本缓存进服务器,并返回hash(SHA1)值
script load "return {1,2,3}"

# evalsha 执行哈希值的脚本, 0表示传递参数的数量 (一般情况下执行eval命令,底层会转换为执行evalsha)
evalsha <hash> 0

# 查看脚本是否已经加载到redis内存当中
script exists "<hash>"

# 清空redis内存中的脚本
SCRIPT FLUSH

# 杀死目前正在执行的脚本(如果lua脚本正在执行写入操作, 则script kill不会生效)
SCRIPT KILL
```

- `redis.call` or `redis.pcall()`

    - 两个函数执行时: Redis 类型转换为 Lua 类型，然后结果再转换回 Redis 类型，结果与初始值相同

    - `redis.call`: 报错就返回

    - `redis.pcall`: 忽略报错继续执行

```redis
# set a 123
eval "return redis.call('set', KEYS[1],'123')" 1 a

# get a
eval "return redis.pcall('get', KEYS[1])" 1 a
```

#### 脚本示例

```redis
# 设置3个用户, 并分配值
mset user1 1 user2 2 user3 3

# 将3个用户, push进列表
lpush list1 user1 user2 user3
```

- lua脚本文件`test.lua`

```lua
-- test.lua

-- 获取list1
local list1 = redis.call("lrange", KEYS[1], 0, -1)
local count = 0

for k, v in ipairs(list1)
do
    -- 自增1
    redis.call("incr", v)
    count = count + 1
end
-- 返回个数
return count
```

- 执行脚本
```sh
redis-cli --eval test.lua list
```

## python

- [python的redis客户端列表](https://redis.io/clients#python)

### redis-py

- [官方文档](https://redis.readthedocs.io/en/stable/)

- `hash`类型对应python的`dict字典`类型

```py
import redis
r = redis.Redis()

# 防止redis连接失败,在r = redis.Redis()后,可以try: r.client()
try:
    r.client()
except redis.exceptions.ConnectionError:
    r.close()
    return 1

# set
r.mset({'1': 'google', '2': 'baidu'})
r.get('1')
```

- transaction(事务), pipeline(流水线执行命令)

```py
import redis

r = redis.Redis()

# 默认transaction=True表示事务执行, 而不是流水线执行
pipe = r.pipeline(transaction=False)
pipe.set('foo', 'bar')
pipe.get('foo')

# pipe缓冲区队列.当execute()才会执行
pipe.execute()
# 或者
pipe.set('foo', 'bar').get('foo').execute()
```

### [redis-om-python: 对象模板](https://github.com/redis/redis-om-python)

### [pottery:以python的语法访问redis](https://github.com/brainix/pottery)

```py
import pottery

# 列表
list1 = pottery.RedisList([1, 4, 9, 16, 25], key='list1')
for i in list1:
    print(i)
```

## 配置

### config

配置文件在 `/etc/redis.conf` 目录

```redis
# config get 查看所有配置
config get *

# 查看所有以r开头的配置
config get r*

# 查看密码
config get requirepass

# config set 设置密码
config set requirepass YouPassword

# 之后登陆的客户端都要验证密码
auth YouPassword

# 清除密码(要重启redis-server才会生效)
config set requirpass ""

# 将 config set 的修改写入到 redis.conf 中(不写入,重启redis-server后修改会失效)
config rewrite
```

### info

[info 详情](http://redisdoc.com/client_and_server/info.html)

```redis
# 查看信息
info

# 查看cpu信息
info cpu

# 重置 info 命令中的某些统计数据
config resetstat

# 查看加载的模块
info modules

# 查看 memory
info memory
```

- rss > used ,且两者的值相差较大时,表示存在（内部或外部的）内存碎片.
- used > rss ,表示 Redis 的部分内存被操作系统换出到交换空间了,在这种情况下,操作可能会产生明显的延迟.

### ACL

redis 6.0 以上的版本

[**ACL:**](https://redis.io/topics/acl)

```redis
# 查看用户列表
acl list

# 创建用户test
acl setuser test

# 创建用户tz,并设置密码123,授予 get 权限
acl setuser tz on >123 ~cached:* +get

# 授予 set 权限
acl setuser tz +set

# 授予 all 所有权限
acl setuser tz +@all

# 查看用户详情
acl getuser tz

# 禁用用户
acl setuser tz off

# 切换用户
auth tz 123
```

### slowlog(慢查询日志)

- 如果出现周期性超时

- redis通过一个列表(FIFO)存储慢查询日志

    - 日志长度为: `slowlog-max-len` 参数(默认128), 建议设置1000

- 慢查询时间为: `slowlog-log-slower-than` 参数(默认10000微妙, 也就是10毫秒), 建议设置1000

```redis
config set slowlog-log-slower-than 1000
config set slowlog-max-len 1000
# 将修改写入配置文件
config rewrite
```

```redis
# 获取日志, n为日志的条数. 有3个值分别为: 标识id, 发生时间戳, 命令耗时
slowlog get <n>

# 获取日志条数
slowlog len

# 删除所有日志
slowlog reset
```

### client

```redis
# 查看当前客户端名字
client getname

# 设置名字
client setname tz

# 查看当前客户端id
client id

# 查看所有客户端
client list

# 关闭客户端(不过即使关闭了,一般会自动重新连接)
client kill 127.0.0.1:56352

# 阻塞客户端(slave客户端除外)
client pause <time(毫秒)>
```

- `client list` 命令:

    ![avatar](./Pictures/redis/client.avif)

    - [每个参数的详情](http://doc.redisfans.com/server/client_list.html)

    - 连接/空闲时间:

        - `age` 客户端连接的时间

        - `idle`(空闲时间): 一旦`idle` 超过`timeout` 值(默认为0), 客户端会被关闭

            - 因此建议设置为300秒, 防止客户端bug

                ```redis
                # 查看timeout
                config get timeout

                # 设置timeout为300秒
                config set timeout 300

                # 写入配置文件
                config rewrite
                ```

    - 输入/输出缓冲区:

        -  输入缓冲区: `qbuf`, `qbuf-free`: 将client的发送的命令暂时保存, redis服务器会拉取并执行

        -  输出缓冲区: `obl`(固定缓冲区: 16KB的字节数组), `oll`(动态缓冲区: 列表), `omem`(字节数) : 将client的发送的命令暂时保存, redis服务器会拉取并执行

            - `obl` 用完后, 会使用`oll`

            - 输出缓冲区分3种客户端:

                - normal(普通客户端)

                - pusbsub(发布/订阅客户端)

                - slave(主从复制里的从客户端)

                    - 应适量增大slave客户端的输出缓冲区: 因为slave会比较大, 如果缓冲区溢出会被kill

                ```redis
                # 配置从客户端, hard limit为256mb(大于时, 客户端会被立刻关闭), soft limit为64mb(大于时, 超过60秒后才关闭)
                client-out-buffer-limit slave 256mb 64mb 60
                ```

        - 注意: 输入/输出缓冲区, 都不受`mexmeory` 参数(最大内存限制)的控制

            - 也就是说redis分配的内存(通过`info memory` 命令的`used_memory_human` 值)可以比`mexmeory`大
                - 这表示redis的处理速度, 跟不上输入缓冲区的输入速度

- `info client` 命令:

    ![avatar](./Pictures/redis/client1.avif)

    | 参数                       | 内容                                                       |
    |----------------------------|------------------------------------------------------------|
    | connected_clients          | 已连接客户端的数量（不包括通过从属服务器连接的客户端）     |
    | client_longest_output_list | 当前连接的客户端当中，最长的输出列表                       |
    | client_longest_input_buf   | 当前连接的客户端当中，最大输入缓存                         |
    | blocked_clients            | 正在等待阻塞命令（BLPOP、BRPOP、BRPOPLPUSH）的客户端的数量 |

#### monitor

- 生产环境应禁止使用该命令: 因为monitor在高并发的情况下, 会让输出缓冲区占用的内存过高(omem通过`clients list`命令查看), 最后内存超过`maxmemory` 导致OOM

```redis
monitor
```

![avatar](./Pictures/redis/monitor.gif)


### 远程登陆

**server (服务端)：**

```redis
# 关闭保护模式
CONFIG SET protected-mode no

# 在/etc/redis.conf文件.把bind修改为0.0.0.0 (*表示允许所有ip)
bind 0.0.0.0
# 也可以加入客户端的 ip
bind 127.0.0.1 You-Client-IP

# 写入 /etc/redis.conf 文件
config set rewrite

# 关闭防火墙
iptable -F

# 最后重启redis-server
```

**client (客户端)：**

```sh
# 关闭防火墙
iptable -F

# 连接服务器的 redis
redis-cli -h You-Server-IP -p 6379
```

## persistence (持久化) RDB AOF

- 获取持久化的路径
```redis
config get dir
```

- 查看rdb文件信息
```sh
redis-check-rdb  dump.rdb
```

- redis服务器启动时: 如果RDB和AOF都是开启配置时, 优先使用AOF

    - AOF默认关闭

- RDB vs AOF:

    - RDB优势:

        - 恢复数据更快

        - 全量复制, 更适合备份

    - AOF优势:

        - 实时性

        - RDB并不是每个版本都互相兼容

            - redis7.0 使用新的RDB(第10版), 并不兼容旧版

        - 只有执行重写时才fork子进程, 而RDB每次都fork

            ```redis
            # info命令查看最近一次fork的耗时(微秒)
            latest_fork_usec
            ```

- 优化:

    - fork出来的子进程: 属于cpu密集型

    - fork时: 如果父进程有内存修改, 对应的页表也会修改和复制

        - 因此: 在此期间避免在写入大量数据

### RDB

> 把当前内存, 写入硬盘

- [《Redis 设计与实现》: RDB 文件结构](http://redisbook.com/preview/rdb/rdb_struct.html)

- RDB只会对大于20字节的字符串进行压缩(LZF算法)
    ```redis
    # 默认开启
    config get rdbcompression
    ```

- `bgsave`触发条件:

    - 自动触发: 可在配置文件添加`save m n`:

        ```
        # 默认的save配置
        config get save
        # 输出
        save: 900 1 300 10 60 10000
        ```

        - 1.3600 秒内最少有 1 个 key 被改动
        - 2.300 秒内最少有 10 个 key 被改动
        - 3.60 秒内最少有 1000 个 key 被改动

    - 执行`shutdown`命令, 并且没有开启AOF持久化

    - 执行`dubug reload`命令

    - 主从复制中: 主结点在进行全量复制时

    - 手动触发命令: `bgsave`

        - 如果已经存在正在执行的`bgsave`子进程, 则直接返回


- `bgsave` 执行过程:

    - 1.fork子进程(阻塞)

        - 查看bgsave子进程是否运行: `rdb_bgsave_in_progress`参数

            - 如果存在bgsave子进程, 则直接返回

        - 虽然有cow(copy on write), 但仍然需要复制父进程的页表

            - 父进程的占用内存越大, 页表也越大

```redis
# 上一次RDB的时间(时间戳)
lastsave

# 关闭 RDB
config set save ""
```

### AOF(append only log)

- AOF默认关闭

    ```redis
    # 设置开启AOF
    config set appendonly yes

    # 查看 appendonly 配置
    config get append*
    ```

- AOF执行过程:

    > 写入的是命令是RESP(以\r\n结尾)文本

    - 1.将命令追加到aof_buf(缓冲区)

    - 2.将aof_buf同步硬盘, 有以下3中同步机制:

        | 同步机制       | 操作                                                |
        |----------------|-----------------------------------------------------|
        | always         | 写入aof_buf后, 立即fsync                            |
        | everysec(默认) | 写入aof_buf后, 执行write. fsync由专门线程1秒调用1次 |
        | no             | 写入aof_buf后, 由操作系统负责fsync(一般30秒1次)     |

        - `everysec` 执行过程:

            - 对比距离上次同步的时间

                - 小于2秒时: 返回

                - 大于2秒时: 阻塞等待同步完成

                    - `aof_delayed_fsync`: 阻塞的次数

            - 因此: 最多丢失2秒内的数据, 而不是1秒

#### AOF重写

> 把当前进程的数据转换为命令后, 实现更小的AOF文件

- 重写触发条件:

    - 自动触发必须**同时满足**以下2个条件:

        - `auto-aof-rewrite-min-size`(默认64MB): AOF文件大于此参数(单位字节)

        - `auto-aof-rewiret-percentage` : 当前AOF文件大小与上一次AOF文件大小的**比值**大于此参数

    - 手动触发命令: `bgrewriteaof`

- AOF重写过程

    ![avatar](./Pictures/redis/AOFRW.avif)

    - 1.fork子进程(阻塞)

        - AOF重写子进程是否运行: `aof_rewrite_in_progress`参数

        - 主进程继续响应新的命令, 并写入aof_rewrite_buf(重写缓冲区)

    - 2.子进程批量写入硬盘. 参数`aof-rewrite-incrememntal-fsync`(默认32MB)

        - 防止1次写入过多数据, 造成硬盘busy

    - 3.主进程将aof_rewrite_buf(重写缓冲区)使用pipe发送给子进程, 子进程再追加到新的AOF文件

    - 4.新的AOF文件替换旧的

- [阿里技术: Redis 7.0 Multi Part AOF的设计和实现](https://developer.aliyun.com/article/866957)

    ![avatar](./Pictures/redis/AOFRW1.avif)

    - 子进程重写的AOF为BASE AOF文件(本质是一个RDB文件)

    - 没有了aof_rewrite_buf(重写缓冲区), 改为INCR AOF文件

    - 主进程通过manifest文件负责管理这些BASE INCR文件

#### 恢复

通过 aof 文件恢复删除的数据

```redis
# 设置key
set a 123

# 再把它删了
del a
```

打开 `/var/lib/redis/appendonly.aof` 文件，把和 **del** 相关的行删除

![avatar](./Pictures/redis/aof.avif)

删除后：

![avatar](./Pictures/redis/aof1.avif)

```sh
# 然后使用redis-check-aof 修复 appendonly.aof 文件
redis-check-aof --fix /var/lib/redis/appendonly.aof

# 重启redis-server后，key就会恢复
```

演示:
![avatar](./Pictures/redis/aof.gif)

## master slave replication (主从复制)

- 主从架构: 可实现读写分离: **master (主服务器)** 负责写入; **slave (从服务器)** 负责读取

    - 1.一主一从

        - 写命令比较多时: 可以只在从节点开启AOF

            - 要避免主节点重启, 由于主节点没有持久化, 重启后会同步从节点, 导致从节点数据清空

    - 2.一主多从(星型)

        > 优点即是缺点, 缺点即是优点

        - 优点: 分摊读命令的压力

        - 缺点: 主节点写命令时, 需要复制多个从节点, 从而导致更大的网络开销

        ![avatar](./Pictures/redis/slave2.avif)

    - 3.树状

        > 部分从服务器也是主服务器, 数据一层一层向下复制

        - 优点: 解决一主多从架构的缺点, 降低主节点复制压力

        ![avatar](./Pictures/redis/slave3.avif)

- 从节点的配置:

    - 默认只读模式(`slave-read-only=yes`): 修改会导致主从数据不一致, 因此不建议修改

- 主节点的配置:

    - 默认关闭小tcp包合并(`repl-disable-tcp-nodelay=no`) :如果开启合并, 可以节省带宽, 但增大了延迟

    - 默认关闭master在全量复制期间生成的rdb, 不保存硬盘(`repl-diskless-sync`): 开启后RDB并不会保存硬盘, 而是直接发送给slave

- 节点id:

    > redis服务器启动时会分配一个不同的id, 从而识别不同的redis服务器

    - `info server` 命令查看id

    - 主从复制是根据ip + port, 主节点如果重启, 导致前后id不一致, 引发全量复制

        - 解决方法: 主节点使用`debug reload` 命令(阻塞)重启, 从而保持id一致, 避免全量复制

            - 缺点: 虽然可以避免全量复制, 但`debug reload` 是阻塞命令, 而阻塞期间会生成新的RDB文件, 并加载

### 主从建立过程

- 主从建立过程:

    - 1.从节点执行`slaveof 127.0.0.1 6379` 命令(异步): 保存主节点信息后返回
        ```redis
        # 查看保存的主从信息
        info replication

        # 查看当前节点是master, 还是slave
        role
        ```

    - 2.建立ip socket: 专门接受master发送的复制命令

    - 3.发送`PING` 命令

    - 4.权限验证

        - 如果master设置了`requirepass` 参数, 则需要密码验证

    - 5.全量复制: slave执行`psync` 命令, 请求master复制数据

    - 6.增量复制

        - 通过对比主从的复制偏移量, 来判断主从数据是否一致:

            - `info relication` 里的`master_repl_offset`(主节点), `slave_repl_offset`(从节点)

            - slave接受master后会累加偏移量`slave_repl_offset`


- 断开主从连接过程: 从节点执行`slaveof no one`命令

    - 1.断开master的复制关系

    - 2.slave升级为master

    - 3.不会删除复制的数据


- 从节点切换主节点过程: 如先执行`slaveof 127.0.0.1 6379`后, 再执行`slaveof 127.0.0.1 6380`

    - 1.断开旧master的复制关系

    - 2.建立新master的复制关系

    - 3.**删除当前slave的数据**

    - 4.开始新的主从复制

### 主从复制过程

> 对应上面主从建立过程中的, 第5的全量复制, 第6的部分复制

- 主从复制过程:

    - master维护一个复制缓冲区(默认1MB): 写命令会复制slave的同时, 也会写入复制缓冲区

        > 复制命令丢失的补救措施

        ![avatar](./Pictures/redis/slave.avif)

        ```redis
        # 查看缓冲区
        info relication
        ...

        repl_backlog_active:1            // 开启复制缓冲区
        repl_backlog_size:               // 最大长度
        repl_backlog_first_bytes_offset: // 偏移量
        repl_backlog_histlen:            // 已使用的长度
        ...
        ```

    - slave发送`psync` 命令:

        - master根据slave是否有复制偏移量, 以及主节点id进行复制

            - 如果没有就执行全量复制, 有就执行部分复制

- 全量复制:

    - 1.slave接受并保存master的复制偏移量和id

    - 2.master执行`bgsave` 命令生成RDB文件

        - 生成的RDB会保存到硬盘再发送, 可以开启`repl-diskless-sync`(默认关闭), 开启后并不会保存硬盘, 而是直接发送给slave

    - 3.master将RDB发送给slave, slave接受RDB文件

        - master生成rdb和传输rdb期间, 依然响应读写命令

            - master会把这期间响应的写命令, 写入复制客户端缓冲区, slave加载RDB后, master再发送给slave
                - 复制客户端缓冲区长度`client-output-buffer-limit slave 256MB 64MB 60`

                    - 如果复制客户端缓冲区直接超过256MB或60秒内超过64MB, 会导致全量复制失败


        - 为了防止RDB文件过大, 如果超过`repl-timeout` (默认60秒), 会导致全量复制失败, slave会删除已经接受的临时RDB文件

    - 4.slave加载新的RDB文件, 并清空旧数据

        - 在执行全量复制期间, slave依然响应读命令, 如果时间过长, 可能会导致客户端读取到旧的数据

            - 可以开启`slave-server-stale-data` (默认关闭), 解决数据不一致

                - 开启后slave只会响应`info` `salveof` 命令

        - 加载RDB后, 如果slave开启了AOF持久化, 会立刻执行`bgrewriteaof` 命令重写AOF

- 部分复制:






- slave 向 master 发送一个 `sync` 命令.

- 接到 `sync` 命令的 master 将开始执行 `BGSAVE` 生成最新的 rdb 快照文件(因此 master 必须开启持久化). 在此同步期间, 所有新执行的写入命令会保存到一个缓冲区里面.

- 当 `BGSAVE` 执行完毕后, master 把 .rdb 文件发送给 slave. slave 接收到后, 将文件中的数据载入到内存中.

- slave 第一次 sync 会全部复制，而之后会进行部分数据复制


当 slave 与 master 连接断开后重连进行增量复制

![avatar](./Pictures/redis/slave1.avif)

```redis
# 打开 主从复制 连接6379服务器
slaveof 127.0.0.1 6379

# 查看当前服务器在主从复制扮演的角色
role

# 关闭 主从复制
slaveof no one
```

**本地**主从复制：

- 左边连接的是 127.0.0.1:6379 主服务器
- 右边连接的是 127.0.0.1:7777 从服务器

![avatar](./Pictures/redis/slave.gif)

**远程**主从复制：

- 左边连接的是 虚拟机 192.168.100.208:6379 主服务器
- 右边连接的是 本机 127.0.0.1:6379 从服务器

![avatar](./Pictures/redis/slave1.gif)

建议设置 slave(从服务器) **只读** `replica-read-only`:

> 在复制过程(slaveof ip port),slave(从服务器)不能使用 set 等命令,避免数据不一致的情况.
>
> 因为主从复制是单向复制，修改 slave 节点的数据， master 节点是感知不到的.

```redis
# 查看 replica-read-only
config get replica-read-only

# 设置 replica-read-only yes
config set replica-read-only yes
```

以下是关闭 slave 节点只读 后的演示:

- 右边连接的是 127.0.0.1:6380 从服务器,在 slaveof 过程中无法使用 set 写入，执行 config set replica-read-only no 后，便可以使用 set

![avatar](./Pictures/redis/slave2.gif)

## sentinel (哨兵模式)

Sentinel 会不断地检查你的主服务器和从服务器是否运作正常: [详情](http://redisdoc.com/topic/sentinel.html)

### 开启 sentinal

> ```redis
> # 命令
> sentinel monitor <name> 127.0.0.1 6379 <quorum>
> ```

quorum = 1 一哨兵一主两从架构:[更多详情](https://github.com/doocs/advanced-java/blob/master/docs/high-concurrency/redis-sentinel.md)

```
+----+         +----+
| M1 |---------| R1 |
| S1 |         | S2 |
+----+         +----+
```

quorum = 2 两哨兵一主三从架构:

```
       +----+
       | M1 |
       | S1 |
       +----+
          |
+----+    |    +----+
| R2 |----+----| R3 |
| S2 |         | S3 |
+----+         +----+
```

**sentinel** 配置文件 `/etc/sentinel.conf`加入以下代码:

```sh
#允许后台启动
daemonize yes

# 仅仅只需要指定要监控的主节点 1
sentinel monitor YouMasterName 127.0.0.1 6379 1

# 主观下线的时间(这里为60秒)
sentinel down-after-milliseconds YouMasterName 60000

# 当主服务器失效时， 在不询问其他 Sentinel 意见的情况下， 强制开始一次自动故障迁移
sentinel failover-timeout YouMasterName 5000

# 在执行故障转移时， 最多可以有多少个从服务器同时对新的主服务器进行同步， 这个数字越小， 完成故障转移所需的时间就越长。
sentinel parallel-syncs YouMasterName 1
```

开启 sentiel 服务器

```sh
redis-sentinel /etc/sentinel.conf
# 或者
redis-server /etc/sentinel.conf --sentinel
```

**sentinel** 端口为`26379`

```sh
# 连接 sentinel
redis-cli -p 26379
```

### sentinel 的命令

```redis
# 查看监听的主机
sentinel masters

# 查看 Maseter name
sentinel get-master-addr-by-name YouMasterName

# 通过订阅进行监听
PSUBSCRIBE *
```

我这里一共 4 个服务器(**一哨兵一主两从架构**):

- 左上连接的是 127.0.0.1:6379 主服务器
- 左下连接的是 127.0.0.1:6380 从服务器
- 右上连接的是 127.0.0.1:6381 从服务器
- 右下连接的是 127.0.0.1:26379 哨兵服务器

![avatar](./Pictures/redis/sentinel.avif)

```redis
# 为了方便实验 哨兵的主观下线时间 我改为了 1 秒
sentinel down-after-milliseconds YouMasterName 1000
```

可见把 **6379** 主服务器关闭后，6380 成为新的主服务器:

![avatar](./Pictures/redis/sentinel.gif)

6379 重新连接后成为 **6380** 的从服务器:

![avatar](./Pictures/redis/sentinel1.gif)

## cluster (集群)

Redis 集群不像单机 Redis 那样支持多数据库功能， 集群只使用默认的 0 号数据库， 并且不能使用 SELECT index 命令。[详情](https://mp.weixin.qq.com/s?src=11&timestamp=1604973763&ver=2697&signature=sfP3uoHQVifP6D8FsI*YtxzMzvqbDieWDj1R8J8iT5codhR2A3LGWF46jHQ8mKJk*RZ4qXixc7DUACwbXbU2-MhaJ2P2Tr0YF-eLIVBPrKdvlX*YGM8UGtJoOR1ee3oB&new=1)

```redis
# 查看 集群 配置
config get cluster*
```

配置 6 个实例,从端口 6380 到 6385:

```sh
# 这是6380
port 6380
daemonize yes
pidfile "/var/run/redis-6380.pid"
logfile "6380.log"
dir "/var/lib/redis/6380"

replica-read-only yes

cluster-enabled yes
cluster-config-file nodes.conf

# 每个节点每秒会执行 10 次 ping，每次会选择 5 个最久没有通信的其它节点。当然如果发现某个节点通信延时达到了 cluster_node_timeout / 2
cluster-node-timeout 15000
```

开启 6 个实例:

```sh
# 通过for循环,开启6个实例
for (( i=6380; i<=6385; i=i+1 )); do
    redis-server /var/lib/redis/$i/redis.conf
done
```

![avatar](./Pictures/redis/cluster.avif)

开启集群:

```sh
redis-cli --cluster create 127.0.0.1:6380 127.0.0.1:6381 127.0.0.1:6382 127.0.0.1:6383 127.0.0.1:6384 127.0.0.1:6385 --cluster-replicas 1
```

![avatar](./Pictures/redis/cluster1.avif)
![avatar](./Pictures/redis/cluster2.avif)

```sh
# -c 参数连接集群
redis-cli -c -p 6380
```

可以看到 set name tz 是在 6381 实例，手动把 6381 kill 掉,

重新连接后 get name 变成了 6384 实例

![avatar](./Pictures/redis/cluster.gif)

Redis 集群包含 16384 个哈希槽（hash slot),每个节点负责处理一部分哈希槽,以及一部分数据

![avatar](./Pictures/redis/cluster7.avif)

```redis
# 查看每个node(节点),等同于nodes.conf文件
cluster nodes
```

我这里是:

- node 6380 负责 0-5460 slots
- node 6384 负责 5461-10922 slots
- node 6385 负责 10923-16383 slots

![avatar](./Pictures/redis/cluster3.avif)

```redis
# 查看每个node(节点) 的 slots(槽)
cluster slots
```

我这里是:

- 6383 是 6380 的从节点
- 6381 是 6384 的从节点
- 6382 是 6385 的从节点

![avatar](./Pictures/redis/cluster4.avif)

也可以在 shell 里执行，通过 grep 显示:

```sh
# master
redis-cli -p 6380 cluster nodes | grep master

# slave
redis-cli -p 6380 cluster nodes | grep slave
```

![avatar](./Pictures/redis/cluster5.avif)

关闭主节点 6384:

```sh
# 等同于kill
redis-cli -p 6384 debug segfault
```

可以看到原属于 6384 的从节点 6381,现在变成了主节点(master)

![avatar](./Pictures/redis/cluster6.avif)

这时再关闭主节点 6381:

```sh
redis-cli -p 6381 debug segfault
```

因为 6381 已经没有从节点了，可以看到整个 cluster 已经 down 掉了

![avatar](./Pictures/redis/cluster1.gif)

重新启动 6381 或者 6384 后会恢复集群

## publish subscribe (发布和订阅)

- 消息不会持久化

只能在同一个 `redis-server` 下使用

> ```redis
> # 发布
> pubhlish 订阅号 内容
> ```

> ```redis
> # 订阅
> subscribe 订阅号1 订阅号2
> ```

我这里一共三个客户端.左边为发布者;右边上订阅 rom,rom1;右边下只订阅 rom

![avatar](./Pictures/redis/subscribe.gif)

`psubscribe` 通过通配符,可以匹配 rom,rom1 等订阅.

- psubscribe 信息类型为 `pmessage`
- subscribe 信息类型为 `message`

```redis
psubscribe rom*
```

![avatar](./Pictures/redis/subscribe1.gif)

### 键空间通知

接收那些以某种方式改动了 Redis 数据集的事件。[详情](http://redisdoc.com/topic/notification.html)

```redis
# 开启键空间通知
config set notify-keyspace-events "AKE"
```

```redis
# 订阅监听key
psubscribe '__key*__:*
```

![avatar](./Pictures/redis/keyspace.avif)

## [redis-benchmark性能测试](https://redis.io/topics/benchmarks)

- [loopback benchmarks is silly](https://redis.io/topics/pipelining#appendix-why-are-busy-loops-slow-even-on-the-loopback-interface)

```sh
# 测试set, lpush命令的吞吐量
redis-benchmark -t set,lpush -n 100000 -q
```

- unxi socket vs tcp/ip

```sh
time redis-benchmark -h 127.0.0.1 -p 6379
# 输出: redis-benchmark -h 127.0.0.1 -p 6379  10.25s user 14.48s system 83% cpu 29.676 total

time redis-benchmark -s /var/run/redis/redis.sock
# 输出: redis-benchmark -s /var/run/redis/redis.sock  10.36s user 10.83s system 98% cpu 21.558 total
```

## 优化


- 不要和其他高硬盘服务放在一起(如存储服务, 消息队列)

- 配置多硬盘分摊AOF文件

# docker

```sh
# 包含所有模块
docker run -d -p 6379:6379 redislabs/redismod
```

## Grafana监控

- reference:

    - [微信: 颜值爆表！Redis 官方可视化工具来啦，功能真心强大！](https://mp.weixin.qq.com/s?src=11&timestamp=1647579448&ver=3683&signature=eBTCSdLn*naHlqkuDmQucrXvHgXpwLEv3BahbB-ilkt5VbUqtLNq25y1tWSu2Q9uIBgd0s1qJzFbKljphryyn9MNx7XcXlwvx-ERZ6cQ33wQ-S9Qy3TA-Y9NIJgwKwxB&new=1)

- 安装grafana
```sh
docker pull grafana/grafana
docker run -p 3000:3000 --name grafana \
-d grafana/grafana
```

- 写入以下配置文件: `/home/tz/prometheus.yml`
```yml
global:
  scrape_interval: 5s
```

- 安装prometheus, 并导入配置文件
```sh
docker pull prom/prometheus
docker run -p 9090:9090 --name prometheus \
-v /home/tz/prometheus.yml:/etc/prometheus/prometheus.yml \
-d prom/prometheus
```

- 安装redis插件
```sh
# 进入grafana
docker exec -it grafana /bin/bash
# 安装redis插件
grafana-cli plugins install redis-datasource

# 退出grafana
exit
# 安装插件后, 需要重启grafana容器
docker container restart b9c68aec9425
```

- 查看redismod容器的ip地址
```sh
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 38a25cf3c110
```

- 进入grafana

    - 浏览器打开`http://127.0.0.1:3000/` 输入帐号秘密`admin:admin`

    - 进入设置, 选择redis数据库, 输入刚才获取的redismod容器的ip地址

        ![avatar](./Pictures/redis/grafana-redis.avif)

# redis 如何做到和 mysql 数据库的同步

- 1.  读: 读 redis->没有，读 mysql->把 mysql 数据写回 redi

- 写: 写 mysql->成功，写 redis（捕捉所有 mysql 的修改，写入和删除事件，对 redis 进行操作）

- 2.  分析 MySQL 的 binlog 文件并将数据插入 Redis

- 借用已经比较成熟的 MySQL UDF，将 MySQL 数据首先放入 Gearman 中，然后通过一个自己编写的 PHP Gearman Worker，将数据同步到 Redis

# redis 安装

## centos7 安装 redis6.0.9

源码安装:

```sh
# 安装依赖
yum install gcc make -y

# 官网下载
curl -LO https://download.redis.io/releases/redis-6.0.9.tar.gz

# 国内用户可以去华为云镜像下载 https://mirrors.huaweicloud.com/redis/
curl -LO https://mirrors.huaweicloud.com/redis/redis-6.0.9.tar.gz
tar xzf redis-6.0.9.tar.gz
cd redis-6.0.9
make
```

使用 `yum` 包管理器安装:

```sh
# epel源可以直接安装(版本为redis-3.2.12-2.el7)
yum install redis -y
```

## [docker install](https://www.runoob.com/docker/docker-install-redis.html)

```sh
# 下载镜像
docker pull redis

# 查看本地镜像
docker images

# -p端口映射
docker run -itd --name redis-tz -p 6379:6379 redis

# 查看运行镜像
docker ps

# 进入docker
docker exec -it redis-tz /bin/bash

docker container stop redis-tz

docker run -d -p 6379:6379 -v $PWD/conf/redis.conf:/usr/local/etc/redis/redis.conf -v $PWD/data:/data --name docker-redis docker.io/redis redis-server /usr/local/etc/redis/redis.conf --appendonly yes
```

# 常见错误

## vm.overcommit_memory = 1

内存分配策略
/proc/sys/vm/overcommit_memory

0: 表示内核将检查是否有足够的可用内存供应用进程使用；如果有足够的可用内存:内存申请允许；否则:内存申请失败:并把错误返回给应用进程.
1: 表示内核允许分配所有的物理内存:而不管当前的内存状态如何.
2: 表示内核允许分配超过所有物理内存和交换空间总和的内存

```sh
# 修复
echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf
sysctl -p
```

# 第三方 redis 软件
[一键安装脚本](https://github.com/ztoiax/userfulscripts/blob/master/awesome-redis.sh)

### [iredis: 比redis-cli更强大](https://github.com/laixintao/iredis)

- 更友好的补全和语法高亮的终端(cli)

![avatar](./Pictures/redis/iredis.avif)

[其他客户端](https://redis.io/clients#c)

### [redis-tui](https://github.com/mylxsw/redis-tui)

- 更友好的补全和语法高亮,有输出,key 等多个界面的终端(tui)

![avatar](./Pictures/redis/redis-tui.avif)

### [redis-memory-analyzer](https://github.com/gamenet/redis-memory-analyzer)

- `RMA`是一个控制台工具,用于实时扫描`Redis`关键空间,并根据关键模式聚合内存使用统计数据

```sh
# 默认只会输出一遍,可以用 watch 进行监控(变化的部分会高亮显示)
watch -d -n 2 rma
```

![avatar](./Pictures/redis/rma.avif)

### [RedisInsight: 官方推出的gui, 并且带有补全的cli](https://github.com/RedisInsight/RedisInsight)

### [AnotherRedisDesktopManager: gui](https://github.com/qishibo/AnotherRedisDesktopManager)

- 一个有图形界面的`Redis`的桌面客户端,其中也可以显示 刚才提到的 `rma` 的内存数据

![avatar](./Pictures/redis/redis-gui.avif)

### [RedisLive: 可视化](https://github.com/nkrode/RedisLive)

### [redis-rdb-tools](https://github.com/sripathikrishnan/redis-rdb-tools)

```sh
# json格式 查看
rdb --command json dump.rdb
```

![avatar](./Pictures/redis/rdbtool.avif)

```sh
rdb -c memory dump.rdb
# 导出 csv 格式
rdb -c memory dump.rdb > /tmp/redis.csv
```

![avatar](./Pictures/redis/rdbtool1.avif)

### [redis-shake](https://github.com/alibaba/RedisShake)

Redis-shake 是一个用于在两个 redis 之间同步数据的工具，满足用户非常灵活的同步、迁移需求。

- [中文文档](https://developer.aliyun.com/article/691794)

- [第一次使用，如何进行配置？](https://github.com/alibaba/RedisShake/wiki/%E7%AC%AC%E4%B8%80%E6%AC%A1%E4%BD%BF%E7%94%A8%EF%BC%8C%E5%A6%82%E4%BD%95%E8%BF%9B%E8%A1%8C%E9%85%8D%E7%BD%AE%EF%BC%9F)

### [dbatools](https://github.com/xiepaup/dbatools)

![avatar](./Pictures/redis/dbatools.avif)

# reference

- [《Redis 设计与实现》部分试读](http://redisbook.com/)
- [《Redis 使用手册》](http://redisdoc.com/)
- [《Redis 实战》部分试读](http://redisinaction.com/)
- [Redis 官方文档](https://redis.io/documentation)
- [Redis 知识扫盲](https://github.com/doocs/advanced-java#%E7%BC%93%E5%AD%98)


- [腾讯技术工程: 一篇详文带你入门 Redis](https://www.modb.pro/db/331298)
- [腾讯技术工程: 这篇Redis文章，图灵看了都说好](https://cloud.tencent.com/developer/article/1840412)

- [redis作者博客](http://antirez.com/latest/0)

# online tool

- [在线 redis](https://try.redis.io/)
- [在线 PhpRedisAdmin](http://dubbelboer.com/phpRedisAdmin/)
