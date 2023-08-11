<!-- vim-markdown-toc GFM -->

* [Redis](#redis)
    * [软件架构](#软件架构)
    * [基本命令](#基本命令)
        * [遍历key命令](#遍历key命令)
        * [数据库迁移命令](#数据库迁移命令)
        * [高级技巧](#高级技巧)
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
        * [HyperLogLog（概率集合）](#hyperloglog概率集合)
    * [Module(模块)](#module模块)
        * [RedisJSON](#redisjson)
        * [RediSearch](#redisearch)
    * [transaction (事务)](#transaction-事务)
    * [pipelining(流水线执行命令)](#pipelining流水线执行命令)
    * [client（客户端）](#client客户端)
        * [client list（客户端连接信息）vs info clients](#client-list客户端连接信息vs-info-clients)
            * [客户端配置](#客户端配置)
        * [RESP（与服务端通信的字符串格式）](#resp与服务端通信的字符串格式)
        * [编程语言](#编程语言)
            * [java](#java)
            * [python](#python)
                    * [redis-py](#redis-py)
                    * [redis-om-python: 对象模板](#redis-om-python-对象模板)
                    * [pottery:以python的语法访问redis](#pottery以python的语法访问redis)
            * [Lua 脚本](#lua-脚本)
                * [脚本示例](#脚本示例)
    * [配置](#配置)
        * [config](#config)
        * [info](#info)
        * [ACL](#acl)
        * [slowlog(慢查询日志)](#slowlog慢查询日志)
            * [mysql 存储redis慢查询日志](#mysql-存储redis慢查询日志)
            * [客户端周期性连接超时](#客户端周期性连接超时)
        * [远程登陆](#远程登陆)
        * [使用unix sock连接](#使用unix-sock连接)
    * [persistence (持久化) RDB AOF](#persistence-持久化-rdb-aof)
        * [RDB(Redis DataBase)快照](#rdbredis-database快照)
        * [AOF(append only log)](#aofappend-only-log)
            * [AOFRW（重写）](#aofrw重写)
            * [redis 7.0.0的multi part AOF（多文件AOF机制）](#redis-700的multi-part-aof多文件aof机制)
            * [通过AOF文件恢复删除的数据](#通过aof文件恢复删除的数据)
        * [RDB/AOF重写子进程对性能的影响](#rdbaof重写子进程对性能的影响)
        * [RDB + AOF混合持久化](#rdb--aof混合持久化)
        * [只用作内存缓存，禁用RDB + AOF](#只用作内存缓存禁用rdb--aof)
    * [master slave replication (主从复制)](#master-slave-replication-主从复制)
        * [主从建立过程](#主从建立过程)
        * [主从复制过程](#主从复制过程)
        * [心跳](#心跳)
        * [redis 6.0 无盘全量复制和无盘加载](#redis-60-无盘全量复制和无盘加载)
        * [redis 7.0 共享主从复制缓冲区](#redis-70-共享主从复制缓冲区)
        * [一些问题和注意事项](#一些问题和注意事项)
    * [sentinel (哨兵模式)](#sentinel-哨兵模式)
        * [开启 sentinal](#开启-sentinal)
        * [sentinel 的命令](#sentinel-的命令)
    * [cluster (集群)](#cluster-集群)
    * [publish subscribe (发布和订阅)](#publish-subscribe-发布和订阅)
        * [键空间通知（监控改动的键）](#键空间通知监控改动的键)
    * [调试和性能测试](#调试和性能测试)
        * [redis-benchmark性能测试](#redis-benchmark性能测试)
        * [监控](#监控)
* [docker](#docker)
    * [Grafana监控](#grafana监控)
* [k8s](#k8s)
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

- 单线程:

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

        - 问题:单命令队列

            - 每次客户端的命令都经历3个过程：发送命令、执行命令、返回结果。

            - redis采用单线程处理命令，所有命令被放入一个队列中顺序执行

                - 采用非阻塞I/O，epoll作为I/O多路复用实现

        - 解决方法:多命令队列

            - 1.每个客户端的连接都会初始化一个`client` 的对象, 并维护有一条命令队列

            - 2.I/O线程读取命令队列, 并解析第一条命令, **但不执行命令**

            - 3.等所有I/O线程完成读取后, 命令交由主线程处理, 将结果写入每个`client` 对象的buf

            - 4.I/O线程把`client`里的buf, 写回客户端

    - Redis 会设置cpu affinity, 也就是把进程/线程, 子进程/线程绑定到不同的cpu, 从而防止上下文切换的缓存失效

- Redis 相比 Memcached：

    - 1.不依赖操作系统的类库；memcache需要依赖libevent这样的类库
    - 2.拥有更多的数据结构，能支持更丰富的数据操作,此外单个 value 的最大限制是 1GB，不像 memcached 只能保存 1MB 的数据

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

    # 关闭redis服务器
    redis-cli shutdown
    # 关闭服务前进行持久化
    redis-cli shutdown save

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

### 遍历key命令

- redis采用hashtable数据结构存储键
![avatar](./Pictures/redis/internal-hashtable.avif)

- 遍历所有key

    - `keys` 命令: 遍历所有key(阻塞命令, 不建议在生成环境下使用)。时间复杂度是O(n)

    - `scan` 命令: 渐进式遍历key. 以0为游标开始, 默认搜索10个key. 然后返回一个游标,如果游标的结果为0,表示所有key已经遍历过了(非阻塞. 时间复杂度O(1))

        - 问题: 如果执行过程中key发生变化, 那么可能无法遍历到新的key, 也可能会遍历重复的key

    | 阻塞     | 非阻塞 |
    |----------|--------|
    | keys     | scan   |
    | hgetall  | hscan  |
    | smembers | sscan  |
    | zrange   | zscan  |

    ```redis
    # 搜索所有key
    keys *

    # 搜索包含 s 的key
    keys *s*

    # 搜索以a, b开头123结尾的key
    keys [a,b]123

    # 搜索hill hello
    keys h?ll*

    # 从0游标开始
    scan 0

    # 以0为游标开始搜索,count指定搜索100个key(默认值是10)
    scan 0 count 100

    # match 搜索包含 s 的key
    scan 0 match *s* count 100

    # type 搜索不同对象的key
    scan 0 count 100 type list
    ```

 | 命令   | 时间复杂度 |
 |--------|------------|
 | dbsize | O(1)       |

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

### 数据库迁移命令

| 命令           | 作用域        | 原子性 | 支持多个键 |
|----------------|---------------|--------|------------|
| move           | redis实例内部 | 是     | 否         |
| dump + restore | redis实例之间 | 否     | 否         |
| migrate        | redis实例之间 | 是     | 是         |

- `migrate` 命令: 将 **key** 迁移到另一个 **redis-server**

    - 迁移单个键
    ```redis
    set a 0

    # 将a 迁移到127.0.0.1:7777(对docker启动的redis无效)
    # 0表示迁移到数据库0, 1000表示迁移超时时间
    MIGRATE 127.0.0.1 7777 a 0 1000
    ```

    ![avatar](./Pictures/redis/migrate.gif)

    - 迁移多个键
    ```redis
    MIGRATE 127.0.0.1 7777 "" 0 1000 keys key1 key2 key3
    ```

    - `copy` 选项迁移后不删除源键
    ```redis
    MIGRATE 127.0.0.1 7777 a 0 1000 copy
    ```

    - `replace` 选项覆盖目标数据库相同的键
    ```redis
    MIGRATE 127.0.0.1 7777 a 0 1000 copy replace
    ```

### 高级技巧

```sh
# 删除video开头的键
redis keys video* | xargs redis-cli del
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
        - 视频播放计数

    - 计时器
        - 手机验证码：超过5次失败就倒计时1分钟
        - ip在规定时间范围内的访问次数

    - 共享session：分布式web服务会将用户的session（用户登录信息）保存到各自服务器。负载均衡可能会造成用户每刷新一次都需要重复登录。
        - 通过redis对session集中管理，用户每次更新或查询登录信息直接从redis获取

字符串对象的编码: [**详情**](http://redisbook.com/preview/object/string.html)

| 编码   | 作用                                   |
|--------|----------------------------------------|
| int    | 8个字节的整型                          |
| embstr | <=39 字节的字符串型: 分配1次内存. 只读 |
| raw    | >=39 字节的字符串型: 分配2次内存       |

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

- `setnx`避免多个客户端同时执行`setnx key value`

    - [setnx分布式锁的实现方法](https://redis.io/docs/manual/patterns/distributed-locks/)

```redis
# setnx 如果健不存在,才创建
# 因为msg健已经存在,所以创建失败
setnx msg "test exists"
# 创建成功
setnx test "test exists"

# 查看字符串长度
strlen key

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

- incr命令：对值做自增操作，返回3种结果：
    - 1.值不少整数，返回错误
    - 2.值是整数，返回自增后的结果
    - 3.值不存在，按照值为0自增，返回结果1
```redis
set a 1

# incr 对a加1(只能对 64位 的unsigned操作)
incr a

# 由于b键不存在，按照0自增，返回1
incr b

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

- 记录网站每天有多少用户登陆：1为登陆，0为没有登陆，偏移量作为用户的id

    - set集合 vs Bitmaps：假设网站有1亿用户

        - 每天5000万用户登陆存储一天的登陆内存量：bitmaps胜

            - 用户数量越多越能节省空间

            | 数据类型 | 每个用户占用的空间 | 需要存储的用户量 | 全部内存量             |
            |----------|--------------------|------------------|------------------------|
            | set      | 64位               | 50000000         | 64 * 50000000 = 400MB  |
            | bitmaps  | 1位                | 10000000         | 1 * 100000000 = 12.5MB |

        - 每天10万用户登陆存储一天的登陆内存量：set胜

            - 那么大部分位都是0

            | 数据类型 | 每个用户占用的空间 | 需要存储的用户量 | 全部内存量             |
            |----------|--------------------|------------------|------------------------|
            | set      | 64位               | 100000           | 64 * 100000 = 800KB    |
            | bitmaps  | 1位                | 10000000         | 1 * 100000000 = 12.5MB |

```redis
# 2022-3-19. id为5, 10, 15用户登陆
setbit 2022-3-19 5 1
setbit 2022-3-19 10 1
setbit 2022-3-19 15 1

# 2022-3-20
setbit 2022-3-20 5 1
setbit 2022-3-20 15 1

# 查看id10的用户是否登陆
getbit 2022-3-19 10

# 查看登陆用户的总数
bitcount 2022-3-19

# 查看登陆当中, 最小的用户id
bitpos 2022-3-19 1

# 查看不登陆当中, 最小的用户id
bitpos 2022-3-19 0
```

- 复合运算: `bitop <op> key key`

    - `and`(交集), `or`(并集), `not`(非), `xor`(异或)

```redis
# 交集. 查看这两天都登陆的用户总数, 并保存2022-3-19:and:2022-3-20
bitop and 2022-3-19:and:2022-3-20 2022-3-19 2022-3-20
bitop or 2022-3-19:or:2022-3-20 2022-3-19 2022-3-20
```

### hash (哈希散列)

- 应用:

    - 缓存关系型数据库的用户信息。相比于关系型数据库新增列后，所有行都需要设置值（即使是null）；hash是稀疏结构则不需要，但难以实现复杂的查询

        | id | name | age | city    |
        |----|------|-----|---------|
        | 1  | tom  | 23  | beijing |
        | 2  | mike | 30  | tianjin |

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

- 数据结构：

    - stack(栈): lpush + lpop

    - queue(队列): lpush + rpop

    - 环形队列: lpush + ltrim

    - mq(消息队列): lpush + brpop实现阻塞队列

- 应用:

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

- brpop（阻塞）

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
        ```redis
        # 计算用户共同兴趣的标签
        sinter user:1 user:2
        ```

    - 随机数（抽奖）：spop/srandmember

集合对象的编码: [**详情**](http://redisbook.com/preview/object/set.html)

| 编码                | 作用                                                                                |
|---------------------|-------------------------------------------------------------------------------------|
| intset（整数集合）  | 当集合中的元素个数小于set-max-intset-entries（默认512个）使用该实现。节省内存, O(n) |
| hashtable（哈希表） | 无法满足intset条件时使用该编码. 时间复杂度为O(1)                                    |


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

# 查看test元素是否在jihe内
sismember jihe test

# 查看集合元素个数
scard jihe

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
        - 用户mike上传了一个视频，并获得了3个赞
        ```redis
        zadd user:ranking:2016_03_15 mike 3
        ```
        - 之后在获得了1个赞
        ```redis
        zincrby user:ranking:2016_03_15 mike 1
        ```
        - 删除用户
        ```redis
        zrem user:ranking:2016_03_15 mike
        ```
        - 显示top 10 赞数的用户
        ```redis
        zrevrangebyrank user:ranking:2016_03_15 0 9
        ```
        - 显示用户信息和用户排名
        ```redis
        hgetall user:info:tom
        zscore user:ranking:2016_03_15 mike
        zrank user:ranking:2016_03_15 mike
        ```

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

# 查看指定score值范围内的个数
zcount z 50 100

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

# 由于是zset类型，所以使用zrem删除成员
zrem china beijing
```

- geohash 将经纬度转换为字符串。redis就是通过zset（有序集合）结合geohash实现geo的若干命令

    - 字符串长度越长精度越高

        | 长度 | 精度（km） |
        |------|------------|
        | 1    | 2500       |
        | 2    | 630        |
        | 3    | 78         |
        | 4    | 20         |
        | 5    | 2.4        |
        | 6    | 0.61       |
        | 7    | 0.076      |
        | 8    | 0.019      |
        | 9    | 0.002      |

    - 两个字符串越相似, 距离越短

    ```redis
    # 生成北京的经纬度的hash
    geohash china beijing
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

### HyperLogLog（概率集合）

- 实际上是string类型, 通过一种基数算法实现set(集合)的效果

    - 算法论文: [Hyperloglog: the analysis of a near-optimal cardinality estimation algorithm](http://algo.inria.fr/flajolet/Publications/FlFuGaMe07.pdf)

    - 优点: 比set(集合)占用的内存小的多的多

    - 缺点: 存在误差率(官方数据是0.81%)

    - set vs HyperLogLog：假的每天100万个用户
        | 数据类型    | 1天 | 1个月 | 1年 |
        |-------------|-----|-------|-----|
        | set         | 80M | 2.4G  | 28G |
        | HyperLogLog | 15K | 450K  | 5M  |

        - 以上数据来源于《redis开发与运维》第3章的数据

        - 以下数据是在redis 7.0.11版本，我使用chatgpt生成的脚本进行测试

        ![avatar](./Pictures/redis/set-vs-hyperloglog.avif)
        ![avatar](./Pictures/redis/set-vs-hyperloglog1.avif)
        ![avatar](./Pictures/redis/set-vs-hyperloglog2.avif)

        | 数据类型    | 100万用户          |
        |-------------|--------------------|
        | set         | 53.77552795410156M |
        | hyperloglog | 14.078125K         |

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

## transaction (事务)

- transaction是原子操作, 保证执行多条命令的原子性

- 如果命令出现错误, 事务当同于未执行

- 不支持回滚

- 打错字会造成事务无法运行。比方说：set写成sett

```redis
# 新建一个key
set t 100

# 开启事务
multi
# 修改key
incr t

# 保存事务。如果结果为nil表示事务没有执行
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

## client（客户端）

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

`monitor`命令：监听其他客户端正在执行的命令，并记录详细时间戳

    ![avatar](./Pictures/redis/client.avif)

### client list（客户端连接信息）vs info clients

| 命令         | 优点                 | 缺点                                                       |
|--------------|----------------------|------------------------------------------------------------|
| client list  | 能精确分析每个客户端 | 阻塞命令，需要遍历所有客户端连接，收集连接信息             |
| info clients | 速度快               | 只是返回已保存的统计，不需要遍历客户端，所以不会阻塞服务器 |

- `client list` 命令:

    ![avatar](./Pictures/redis/client.avif)

    - [官方文档](https://redis.io/commands/client-list/)

    - `id`:客户端连接的唯一标识。这个id会随着reids连接自增，重启后为0
    - `fd`:socket文件描述符，与`lsof`命令中的fd是同一个，如果不是外部客户端，而是redis内部的伪装客户端fd=-1
        ![avatar](./Pictures/redis/client-list-fd.avif)

    - `flag`：客户端类型

        | 类型 | 描述                                                |
        |------|-----------------------------------------------------|
        | A    | 尽可能快地关闭连接                                  |
        | b    | 客户端正在等待阻塞事件                              |
        | c    | 回复完整输出后，关闭链接                            |
        | d    | 一个受监视（watched）的键已被修改， EXEC 命令将失败 |
        | i    | 客户端正在等待 VM I/O 操作（已废弃）                |
        | M    | 客户端是主节点（master）                            |
        | N    | 未设置任何 flag                                     |
        | O    | 客户端正在执行monitor                               |
        | P    | 客户端是Pub/Sub subscriber                          |
        | r    | 客户端对集群节点处于只读模式                        |
        | S    | 普通客户端（normal）                                |
        | u    | 客户端未被阻塞（unblocked）                         |
        | U    | 客户端通过unix domain socket进行连接                |
        | x    | 客户端正在执行事务                                  |

    - 连接/空闲时间:

        - `age` 客户端连接的时间

        - `idle`(空闲时间)

    - 输入/输出缓冲区:

        - 输入缓冲区: `qbuf`, `qbuf-free`: 将client的发送的命令暂时保存, redis服务器会拉取并执行
            - 没有相应配置可以规定qbuf、qbuf-free的大小
            - 大小根据输入内容的大小不同动态调整，至少要求每个客户端不能超过1G，超过会被kill掉

            - bigkey：如果输入缓冲区的命令包含大量bigkey，会造成redis阻塞，短期内不能处理命令

                - `info clients`命令中的`client_recent_max_input_buffer`代表最大输入缓冲区，可以设置超过10M就进行报警

        - 输出缓冲区: `obl`(固定缓冲区: 16KB的字节数组), `oll`(动态缓冲区: 列表), `omem`(使用的字节数) : 将client的发送的命令暂时保存, redis服务器会拉取并执行

            - `obl` 用完后, 会使用`oll`
                - 例子：当前客户端固定缓冲区的长度为0，动态缓冲区有4869个对象，两部分共使用了133081288直接=126M内存
                ```redis
                127.0.0.1:6379> client list
                id=3 addr=127.0.0.1:47586 laddr=127.0.0.1:6379 fd=7 name= age=1020 idle=0 flags=N db=0 sub=0 psub=0 ssub=0 multi=-1 qbuf=26 qbuf-free=20448 argv-mem=10 multi-mem=0 rbs=1024 rbp=0 obl=0 oll=4869 omem=133081288 tot-mem=22298 events=r cmd=client|list user=default redir=-1 resp=2
                ```

            - 相比输入缓冲区，输出缓冲区出现异常的概率更大

            - 输出缓冲区分3种客户端:

                - normal(普通客户端)

                - pusbsub(发布/订阅客户端)

                - slave(主从复制里的从客户端)

                    - 应适量增大slave客户端的输出缓冲区: 因为slave会比较大, 如果缓冲区溢出会被kill

                ```redis
                # 配置从客户端, hard limit为256mb(大于时, 客户端会被立刻关闭), soft limit为64mb(大于时, 超过60秒后才关闭)
                client-out-buffer-limit slave 256mb 64mb 60
                ```

            - `info clients`命令中的`client_logest_output_list`：代表最大输出缓冲区的对象数

            - monitor监控命令：生产环境应禁止使用。因为monitor在高并发的情况下, 会让输出缓冲区增大, 最后内存超过`maxmemory` 导致OOM

        - 输入/输出缓冲区大小不受maxmemory控制：假设maxmemory设置了4G，已经使用2G，而此时输入缓冲区的大小为3G，可能会造成数据丢失、键值淘汰、oom等情况。
            ![avatar](./Pictures/redis/client-list-qbuf.avif)

- `info client` 命令:

    ![avatar](./Pictures/redis/client1.avif)

    | 参数                       | 内容                                                       |
    |----------------------------|------------------------------------------------------------|
    | connected_clients          | 已连接客户端的数量（不包括通过从属服务器连接的客户端）     |
    | client_longest_output_list | 当前连接的客户端当中，最长的输出列表                       |
    | client_longest_input_buf   | 当前连接的客户端当中，最大输入缓存                         |
    | blocked_clients            | 正在等待阻塞命令（BLPOP、BRPOP、BRPOPLPUSH）的客户端的数量 |

- `info stats`的有两个客户端相关的命令
    - `total_connections_received`：redis自启动以来，处理的客户端连接总数
    - `rejected_connections`：redis自启动以来，拒绝的客户端连接总数

#### 客户端配置


- client list命令的`idle`(空闲时间): 一旦`idle` 超过`timeout` 值(默认为0), 客户端会被关闭

    - `age`等于`idle`：表示一直处于空闲

    - 因此建议设置为300秒, 防止客户端bug

        ```redis
        # 查看timeout
        config get timeout

        # 设置timeout为300秒
        config set timeout 300

        # 写入配置文件
        config rewrite
        ```

        - 如果设置了`loglevel`为debug级别，可以看到客户端被关闭的日志
        ```
        12885:M 26 Aug 08:46:40.085 - Closing idle client
        ```

- `maxclients`：客户端最大连接数

- `tcp-keepalive`：检测tcp连接活性的周期（默认值为0，也就是不进行检测）。如果设置，建议设置60秒，那么redis每隔60秒会对它创建的tcp连接进行活性检测，防止大量死连接占用系统资源

### RESP（与服务端通信的字符串格式）
- `set hello world`命令的RESP格式
    ```
    *3
    $3
    SET
    $5
    hello
    $5
    world
    ```

    - 第1行的*号：参数数量3个
    - 第2行的$号：参数的字节数

    - 并且每一行之间会以CRLF（\r\n）表示。以下为实际RESP格式
    ```
    *3\r\n$3\r\nSET\r\n$5\r\nhello\r\n$5\r\nworld\r\n
    ```

### 编程语言

#### java

|        | 优点                                                                         | 缺点                                                                                                           |
|--------|------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------|
| 直连   | 简单方便，适用于少量长期连接的场景                                           | 1.存在每次新建/关闭tcp连接开销  2.无法限制Jedis对象的个数，在极端情况下可能造成连接泄漏 3.Jedis对象线程不安全 |
| 连接池 | 1.无需每次连接都生成Jedis对象，降低开销 2.使用连接池形式保护和控制资源的使用 | 更麻烦，资源管理上需要很多参数保证，一旦规划不合规也会出现问题                                                 |

- jedis的直连

    ```java
    Jedis jedis = new Jedis("127.0.0.1", 6379)
    jedis.set("hello", "world")
    jedis.close()
    ```

- 连接池：生产环境一般使用连接池进行管理。预先初始化好Jedis连接，每次只需要向连接池借用就可以了。借用和归还都是本地操作，只有少量同步开销，远远小于tcp连接的开销。

    ```java
    // 使用默认连接池配置（默认8个Jedis对象，超过后就需要等待）
    GenericObjectPoolConfig poolConfig = new JedisPoolConfig();

    //创建Jedis连接池
    JedisPool jedisPool = new JedisPool(poolConfig,"localhost",6379);
    Jedis jedis = null;
    try {
        jedis = jedisPool.getResource()
        jedis.set("key1", "value1");
        jedis.get("key1");
    } catch (Exception e) {
        logger.error(e.getMessage(), e);
    } finally {
        if (jedis != null){
            // 如果使用jedisPool.close();操作不是关闭连接，而是归还连接池
            jedis.close();
        }
    }
    ```

#### python

- [python的redis客户端列表](https://redis.io/clients#python)

###### redis-py

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

###### [redis-om-python: 对象模板](https://github.com/redis/redis-om-python)

###### [pottery:以python的语法访问redis](https://github.com/brainix/pottery)

```py
import pottery

# 列表
list1 = pottery.RedisList([1, 4, 9, 16, 25], key='list1')
for i in list1:
    print(i)
```

#### Lua 脚本

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

    - 避免每次发送lua脚本

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

##### 脚本示例

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

- 慢查询只记录命令的执行时间，不包含命令排队和网络传输时间

    - 也就是说：客户端执行命令的时间会大于记录的时间

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

#### mysql 存储redis慢查询日志

- 慢查询过多的情况下会丢失，可以定期执行`slow get` 命令将日志持久化到其他存储（例如mysql）

第13章cachecloud

#### 客户端周期性连接超时

- 分析

    - 服务端没有异常，只有一些慢查询

    - 网络是正常的

    - reids日志统计没有异常

    - 发现只有慢查询出现，客户端就会大量连接超时

- 发现是应用方有个定期（每5分钟）任务，执行了hgetall造成阻塞，那个键有200万个元素

- 这得益于客户端的监控工具，如果redis是黑盒运行很难快速发现问题。
    - 监控慢查询，一旦超过阈值就报警

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

## persistence (持久化) RDB AOF

- [官方文档](https://redis.io/docs/management/persistence/)

- [字节跳动技术团队：Redis 持久化策略浅析]()

- 获取RDB/AOF持久化的路径
```redis
config get dir
```

- RDB vs AOF:

    - RDB

        - 优点

            - 是一个二进制文件，表示redis某个时间点的数据快照（适合冷备份）

                - 比如每6小时执行bgsave备份，并把RDB文件复制到远程机器或文件系统（hdfs），用于灾难恢复

            - 恢复数据比AOF快

        - 缺点

            - 无法做到实时的持久化/秒级持久化

            - redis有多个版本的RDB文件格式。老版本的redis无法兼容新版的RDB

    - AOF优势:

        - 实时性

        - RDB并不是每个版本都互相兼容

            - redis7.0 使用新的RDB(第10版), 并不兼容旧版

        - 只有执行重写时才fork子进程, 而RDB每次都fork

            ```redis
            # info命令查看最近一次fork的耗时(微秒)
            latest_fork_usec
            ```

- redis服务器启动加载RDB/AOF过程（优先使用AOF，AOF默认关闭）：

    ![avatar](./Pictures/redis/重启加载数据文件.avif)

    - AOF成功加载的日志：
        ```redis
        * DB loaded from disk: 0.269 seconds
        ```

    - RDB成功加载的日志：
        ```redis
        * DB loaded from append only file: 5.841 seconds
        ```

    - AOF文件错误的日志：
        ```redis
        # Bad file format reading the append only file: make a backup of your AOF file, then use ./redis-check-aof --fix <filename>
        ```

        - 需要使用`redis-check-aof --fix`命令进行修复，修复后用`diff -u`对比数据差异，找出丢失的数据
        - AOF文件可能存在结尾不完整的情况，比如机器掉电。使用`aof-load-truncated`配置兼容（默认开启），就算遇到文件有问题，也继续启动
        ```redis
        * Reading RDB preamble from AOF file...
        * Reading the remaining AOF tail...
        # !!! Warning: short read while loading the AOF file !!!
        # !!! Truncating the AOF at offset 439 !!!
        # AOF loaded anyway because aof-load-truncated is enabled
        ```

### RDB(Redis DataBase)快照

- [《Redis 设计与实现》: RDB 文件结构](http://redisbook.com/preview/rdb/rdb_struct.html)

- 查看rdb文件信息
```sh
redis-check-rdb  dump.rdb
```

```redis
# 主动触发RDB备份
bgsave

# 上一次RDB的时间（日期格式）
lastsave
(local time) 2023-08-09 10:04:39
# 上一次RDB的时间(时间戳)
info PERSISTENCE
rdb_last_save_time:1691546679

# 关闭 RDB
config set save ""

# RDB只会对大于20字节的字符串进行压缩(LZF算法)。默认开启
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

    - 执行`debug reload`命令

    - 主从复制中: 主结点在进行全量复制时

    - 手动触发命令: `bgsave`

        - 如果已经存在正在执行的`bgsave`子进程, 则直接返回


- `bgsave` 执行过程:

    ![avatar](./Pictures/redis/rdb.avif)

    - 1.查看bgsave子进程是否运行: `rdb_bgsave_in_progress`参数

        - 检测是否存在rdb/zof的子进程, 有则直接返回

    - 2.fork创建子进程（阻塞）。
    ```redis
    # 查看最近一次fork的耗时（单位：微妙）
    info stats
    latest_fork_usec:0
    ```

    - 3.子进程fork完成。bgsave命令返回"background saving started"，表示不在阻塞主进程，可以继续响应其他命令

        - fork 的子进程初始时与父进程（Redis 的主进程）共享同一块内存；父进程继续给响应client，遇到写命令的时候，会使用COW (Copy On Write)技术，复制要修改内存页的副本

        ![avatar](./Pictures/redis/rdb-cow.avif)

    - 4.子进程根据父进程的内存生成RDB文件

    - 5.完成后，子进程发送信号给父进程，父进程更新统计信息
    ```redis
    info PERSISTENCE
    rdb_changes_since_last_save:0
    rdb_bgsave_in_progress:0
    rdb_last_save_time:1691546679
    rdb_last_bgsave_status:ok
    rdb_last_bgsave_time_sec:-1
    rdb_current_bgsave_time_sec:-1
    rdb_saves:0
    rdb_last_cow_size:0
    rdb_last_load_keys_expired:0
    rdb_last_load_keys_loaded:16
    ```

### AOF(append only log)

- AOF 与 WAL：

    - Write Ahead Log（WAL）写前日志：先把修改的数据记录到日志中，再进行写数据的提交，可以方便通过日志进行数据恢复。

    - AOF（Append Only File）写后日志：先执行写命令，把数据写入内存中，再记录日志。

- AOF默认关闭

    ```redis
    # 设置开启AOF（重启后会失效）
    config set appendonly yes

    # 查看 appendonly 配置
    config get append*
    ```

    - 配置文件（永久开启）
    ```
    appendonly yes
    ```

- AOF执行过程：

    ![avatar](./Pictures/redis/aof.avif)

    > 写入的是命令是RESP(以\r\n结尾)文本（有很好的兼容性）

    - 1.命令写入（append）：将命令追加到aof_buf(缓冲区)

    - 2.命令同步（sync）：将aof_buf同步硬盘, 有以下3中同步机制:

        | 同步机制       | 操作                                                |
        |----------------|-----------------------------------------------------|
        | always         | 写入aof_buf后, 立即fsync                            |
        | everysec(默认) | 写入aof_buf后, 执行write. fsync由专门线程1秒调用1次 |
        | no             | 写入aof_buf后, 由操作系统负责fsync(一般30秒1次)     |

        - `everysec` 执行过程:

            - 对比距离上次同步的时间

                - 小于2秒时: 返回

                - 大于2秒时: 阻塞等待同步完成

                    ```redis
                    # 阻塞的次数会增加
                    info persistence
                    aof_delayed_fsync
                    ```
            - 因此: 最多丢失2秒内的数据, 而不是1秒

    - 3.文件重写（rewrite）：AOF文件越来越大，需要定期进行重写

    - 4.重启加载（load）：redis服务器重启时，加载AOF文件进行数据恢复

#### AOFRW（重写）

> 把当前进程的数据转换为命令后, 实现更小的AOF文件

- 重写触发条件:

    - 自动触发必须**同时满足**以下2个条件:

        - `aof_current_size`：当前 AOF 文件大小

        - `aof_base_size`：上一次重写后 AOF 文件大小

        - 1.`aof_current_size` > `auto-aof-rewrite-min-size`(默认64MB)

        - 2.当前 AOF 相比上一次 AOF 的增长率：(`aof_current_size - aof_base_size`) / `aof_base_size` >= `auto-aof-rewrite-percentage`

            - `auto-aof-rewrite-percentage`默认100，指定为0表示禁用AOF重写

    - 手动触发命令: `bgrewriteaof`

- AOF重写过程

    ![avatar](./Pictures/redis/AOFRW.avif)

    - 1.fork子进程(阻塞)

        - AOF重写子进程是否运行: `aof_rewrite_in_progress`参数

        - 父进程继续响应新的命令，除了将写入命令缓存`aof_buf`外，还会缓存到`aof_rewrite_buf`(重写缓冲区)。——也就是同一份数据会产生2次磁盘IO。redis7.0.0之前

    - 2.子进程分批写入硬盘. 参数`aof-rewrite-incrememntal-fsync`(默认32MB)

        - 防止1次写入过多数据, 造成硬盘busy

    - 3.AOF写入完成后，子进程通知父进程。父进程更新统计信息
        ```redis
        info PERSISTENCE
        aof_enabled:0
        aof_rewrite_in_progress:0
        aof_rewrite_scheduled:0
        aof_last_rewrite_time_sec:-1
        aof_current_rewrite_time_sec:-1
        aof_last_bgrewrite_status:ok
        aof_rewrites:0
        aof_rewrites_consecutive_failures:0
        aof_last_write_status:ok
        aof_last_cow_size:0
        ```

    - 4.父进程将aof_rewrite_buf(重写缓冲区)使用pipe发送给子进程, 子进程再追加到新的AOF文件

    - 5.新的AOF文件原子替换旧的

#### redis 7.0.0的multi part AOF（多文件AOF机制）

- [阿里技术: Redis 7.0 Multi Part AOF的设计和实现](https://developer.aliyun.com/article/866957)

    - 此特性由阿里云数据库Tair团队贡献

    - 7.0.0之前的AOFRW（重写）

        - cpu开销：在AOFRW期间，主进程需要花费CPU时间向aof_rewrite_buf写数据
        - 内存开销：info命令的`aof_rewrite_buffer_length`字段可以看到当前时刻aof_rewrite_buf占用的内存大小
            - 在高写入流量下aof_rewrite_buffer_length几乎和aof_buffer_length占用了同样大的内存空间，几乎浪费了一倍的内存。

            - AOFRW带来的内存开销有可能导致Redis内存突然达到maxmemory限制，从而影响正常命令的写入，甚至会触发操作系统限制被OOM Killer杀死

            ```redis
            info
            aof_pending_rewrite:0
            aof_buffer_length:35500
            aof_rewrite_buffer_length:34000
            aof_pending_bio_fsync:0
            ```

        - 磁盘开销：在aof重写期间，新的写入命令。父进程除了会将执行的写命令写入aof_buf，还会写一份到aof_rewrite_buf中进行缓存。同一份数据会产生2次磁盘IO

    - 7.0.0之后的MP-AOF（multi part AOF）
        ![avatar](./Pictures/redis/AOFRW1.avif)

        - 多份aof文件，并分为三种文件类型：原来只有1份

            - BASE（基础）文件：可以是rdb或aof重写时生成的文件。只能存在一个
            - INCR（增量）文件：一般会在AOFRW开始执行时被创建，该文件可能存在多个。

                - 没有了aof_rewrite_buf(重写缓冲区)，改为写入INCR AOF文件

            - HISTORY（历史）文件：每次AOFRW成功完成时，本次AOFRW之前对应的BASE和INCR AOF都将变为HISTORY，HISTORY类型的AOF会被Redis自动删除。

            - Redis父进程使用一个manifest（清单）文件来跟踪这些aof文件

                - AOFRW结束时，主进程会原子更新manifest文件，将新生成的BASE AOF和INCR AOF信息加入进去，并将之前的BASE AOF和INCR  AOF标记为HISTORY（这些HISTORY AOF会被Redis异步删除）。一旦manifest文件更新完毕，就标志整个AOFRW流程结束。

                - 所有的AOF文件和manifest文件放入一个单独的文件目录中
                ```redis
                # 获取aof文件和manifest文件的目录
                get appenddirname
                ```

    - 兼容老版本升级

        - 满足下面三种情况之一时我们会认为这是一个升级启动
            - 1.如果appenddirname目录不存在
            - 2.或者appenddirname目录存在，但是目录中没有对应的manifest清单文件
            - 3.如果appenddirname目录存在且目录中存在manifest清单文件，且清单文件中只有BASE AOF相关信息，且这个BASE AOF的名字和server.aof_filename相同，且appenddirname目录中不存在名为server.aof_filename的文件

    - AOFRW限流

        - AOF大小超过一定阈值时支持自动执行AOFRW，当出现磁盘故障或者触发了代码bug导致AOFRW失败时，Redis将不停的重复执行AOFRW直到成功为止。在MP-AOF出现之前，这看似没有什么大问题（顶多就是消耗一些CPU时间和fork开销）。

        - 但是在MP-AOF中，因为每次AOFRW都会打开一个INCR AOF，并且只有在AOFRW成功时才会将上一个INCR和BASE转为HISTORY并删除。因此，连续的AOFRW失败势必会导致多个INCR AOF并存的问题。极端情况下，如果AOFRW重试频率很高我们将会看到成百上千个INCR AOF文件。

        - AOFRW限流机制：当AOFRW已经连续失败三次时，下一次的AOFRW会被强行延迟1分钟执行，依次类推延迟4、8、16...，当前最大延迟时间为1小时。

            - 在AOFRW限流期间，我们依然可以使用bgrewriteaof命令立即执行一次AOFRW。

#### 通过AOF文件恢复删除的数据

```redis
# 设置key
set a 123

# 再把它删了
del a
```

打开 `/var/lib/redis/appendonly.aof` 文件，把和 **del** 相关的行删除

![avatar](./Pictures/redis/aof恢复.avif)

删除后：

![avatar](./Pictures/redis/aof恢复1.avif)

```sh
# 然后使用redis-check-aof 修复 appendonly.aof 文件
redis-check-aof --fix /var/lib/redis/appendonly.aof

# 重启redis-server后，key就会恢复
```

演示:
![avatar](./Pictures/redis/aof.gif)

### RDB/AOF重写子进程对性能的影响

- fork耗时与内存量成正比（需要复制父进程的页表），建议redis内存控制在10GB以下（每GB20毫秒左右）

    - 写时复制cow（copy-on-wirte）：当父进程有写请求操作时，会创建内存页的副本

        - 因此避免在子进程备份时，进行大量写入操作，导致父进程维护大量内存页副本

        - linux kernel的Transparent Huge Pages（THP）大内存页（2MB）功能（默认开启）

            - 可以减少fork的时间，但会增加父进程创建内存页副本的消耗
            ```sh
            # 关闭THP
            echo never > /sys/kernel/mm/transparent_hugepage/enabled
            ```

        - rdb的copy-on-wirte日志。这里消耗了5MB

        ```redis
        * Background saving started by pid 10337
        * DB saved on disk
        * RDB: 5 MB of memory used by copy-on-write
        * Background saving terminated with success
        ```

        - aof重写的copy-on-wirte日志。这里消耗了53 + 1.49MB
        ```redis
        * Background append only file rewriting started by pid 8937
        * AOF rewrite child asks to stop sending diffs.
        * Parent agreed to stop sending diffs. Finalizing AOF...
        * Concatenating 0.00 MB of AOF diff received from parent.
        * SYNC append only file rewrite performed* AOF rewrite: 53 MB of memory used by copy-on-write*Background AOF rewrite terminated with success
        * Residual parent diff successfully flushed to the rewritten AOF (1.49 MB)
        * Background AOF rewrite finished successfully
        ```

- cpu开销：子进程分批写入文件，属于cpu密集操作，cpu利用率接近90%。不要绑定单核cpu，会和父进程竞争单核

    - 不要和cpu密集的服务部署在一起

    - 如果部署多redis实例，尽量保证同一时刻只有1个子进程

- 硬盘：写入会造成硬盘压力
    - 可以用iostat、iotop命令监控
    - 不要和高硬盘负载的服务部署在一起：存储服务、消息队列等...
    - aof重写可以配置`no-appendfsync-on-rewrite`（默认关闭），表示aof重写不做fsync操作
    - 多redis实例，可以配置不同的硬盘存储aof文件

### RDB + AOF混合持久化

- Redis 4.0 开始支持。Redis4.0 后大部分的使用场景都不会单独使用 RDB 或者 AOF 来做持久化机制，而是兼顾二者的优势混合使用。

- 需要redis.conf配置文件开启`aof-use-rdb-preamble`；并且必须开启aof

- 明显特征是aof文件的名字开头为：REDIS

- 在进行重写的时候，内存中的原始数据被持久化为RBD格式的数据，而重写开始到重写结束（RDB持久化）期间的数据则记录为AOF格式的增量日志。

    ![avatar](./Pictures/redis/rdb+aof.avif)

    - 通常这部分AOF日志很小

    - Redis 服务器启动并载入 AOF 文件时，它会检查 AOF 文件的开头是否包含了 RDB 格式的内容。

        - 如果包含，那么服务器就会先载入开头的 RDB 数据，然后再载入之后的 AOF 数据。

        - 如果 AOF 文件只包含 AOF 数据，那么服务器将直接载入 AOF 数据。

### 只用作内存缓存，禁用RDB + AOF

## master slave replication (主从复制)

- [百度开发者中心：Redis 主从复制的原理及演进]()

```redis
# 打开 主从复制 连接6379服务器
slaveof 127.0.0.1 6379

# 查看当前服务器在主从复制扮演的角色
role

# 关闭 主从复制
slaveof no one
```

- **本地**主从复制：

    - 左边连接的是 127.0.0.1:6379 主服务器
    - 右边连接的是 127.0.0.1:7777 从服务器

    ![avatar](./Pictures/redis/slave.gif)

- **远程**主从复制：

    - 左边连接的是 虚拟机 192.168.100.208:6379 主服务器
    - 右边连接的是 本机 127.0.0.1:6379 从服务器

    ![avatar](./Pictures/redis/slave1.gif)


- 主从架构: 可实现读写分离: **master (主服务器)** 负责写入; **slave (从服务器)** 负责读取

    - 1.一主一从

        - 写命令比较多时: 可以只在从节点开启AOF，避免主节点的性能干扰

        - 注意：master没有开启持久化，自动重启后会数据清空：导致slave数据也被清空。先在从节点`slaveof no one`关闭主从复制，再进行master重启。

    - 2.一主多从(星型)

        > 优点即是缺点, 缺点即是优点

        - 优点: 多个从节点，分摊读命令的压力（比如keys、sort等慢查询命令）

        - 缺点: 主节点写命令时, 需要复制多个从节点, 从而导致更大的网络开销

        ![avatar](./Pictures/redis/slave2.avif)

    - 3.树状

        > 部分从服务器也是主服务器, 数据一层一层向下复制

        - 优点: 解决一主多从（星型）架构的缺点, 降低主节点复制压力

        ![avatar](./Pictures/redis/slave3.avif)

- 从节点的配置:

    - `replica-read-only=yes`（默认yes，也就是只读）redis6.0以前为`slave-read-only: yes`：从节点无法删除和修改key。开启可能会导致主从数据不一致, 因此不建议修改

        ```redis
        // 查看 replica-read-only
        config get replica-read-only

        // 设置 replica-read-only yes
        config set replica-read-only yes
        ```

        - 以下是关闭 slave 节点只读 后的演示:

            - 右边连接的是 127.0.0.1:6380 从服务器,在 slaveof 过程中无法使用 set 写入，执行 config set replica-read-only no 后，便可以使用 set

            ![avatar](./Pictures/redis/slave2.gif)

- 主节点的配置:

    - 默认关闭master在全量复制期间生成的rdb, 不保存硬盘(`repl-diskless-sync`): 开启后RDB并不会保存硬盘, 而是直接发送给slave

### 主从建立过程

- 主从建立过程:

    - 1.从节点执行命令或配置文件写入`slaveof 127.0.0.1 6379`：保存主节点信息后返回，复制流程是异步执行
        ```redis
        # 查看保存的主从信息
        info replication

        # 查看当前节点是master, 还是slave
        role
        ```

    - 2.从节点建立socket: 专门接受master发送的复制命令

        - 以下的45572端口，便是从节点的套节字
        ![avatar](./Pictures/redis/slave-socket.avif)

        - 注意：如果从节点无法建立连接，会定时无限重试，或者执行`slaveof no one`取消复制

            - 查看与主节点连接失败的时间
            ```redis
            info replication
            master_link_down_since_seconds
            ```

    - 3.发送`PING` 命令
        - 检测socket是否可用
        - 如果从节点没有收到主节点回复的`PONG`，从节点会点开复制连接，然后定时发起重连

    - 4.权限验证

        - 如果master设置了`requirepass` 参数, 则需要密码验证

    - 5.全量复制: slave执行`psync` 命令, 请求master复制数据

    - 6.增量复制

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

- psync命令:

    - 1.slave发送`psync {runid} {offset}` 命令:

        - `runid`：slave保存的master节点id

            - master会核对id与自己是否一致。id重启时重新生成，如果master重启过，会导致全量复制。可以使用`debug reload`进行重启，就不会丢失id

        - `offset`：slave的偏移量。如果是第一次复制，那么值就是-1，将会引发全量复制

    - 1.复制偏移量

        - master写入命令后，会将命令的字节长度（偏移量）保存在`master_repl_offset`里

        - slave每秒上报自身的偏移量`slave_repl_offset`，因此主节点也会保存slave的偏移量

            - 两者可通过`info relication`命令查看

        - master和slave的偏移量差值，就是要复制的偏移量

            - slave接受master后会累加偏移量`slave_repl_offset`

    - 2.master维护一个`repl-backlog-buffer`复制缓冲区(默认1MB)：建立主从关系时创建。复制期间master响应的写命令，会复制给slave, 也会写入复制缓冲区

        - 如果repl_back_buffer的大小超过了这个限制，Redis会开始丢弃最早的命令。

        ![avatar](./Pictures/redis/slave.avif)

        ```redis
        // 查看缓冲区
        info relication
        ...

        repl_backlog_active:1                   // 开启复制缓冲区
        repl_backlog_size:1048576               // 缓冲区最大长度
        repl_backlog_first_bytes_offset:7479    // 起始偏移量
        repl_backlog_histlen:1048576            // 已保存数据的有效长度
        ...
        ```

    - master收到psync后的回复
        - 1.`+FULLRESYNC`：全量复制
        - 2.`+CONTINUE`：增量复制
        - 3.`-ERR`：表示redis的版本低于2.8，无法使用`psync`命令，将使用旧版的`sync`命令


- 全量复制过程：6G的数据大概2分钟左右

    - 1.slave发送`psync id -1`。偏移量的值-1，表示全量复制

    - 2.master响应`+FULLRESYNC`

    - 3.slave接受master的响应数据保存运行id和offset（偏移量）

    - 4.master执行`bgsave` 命令生成RDB文件

        - 生成的RDB会保存到硬盘再发送, 可以开启`repl-diskless-sync`(默认关闭), 开启后并不会保存硬盘, 而是直接发送给slave

    - 5.master将RDB发送给slave, slave接受RDB文件

        - `repl-diskless-sync`：生成的RDB文件直接发送给slave，而不会保存磁盘

        - 如果传输超过`repl-timeout` (默认60秒), 会导致全量复制失败, slave会删除已经接受的临时RDB文件

    - 6.master生成rdb和传输rdb期间，依然响应读写命令，并写入复制客户端缓冲区

        - slave复制完成RDB快照后：master将复制客户端缓冲区发送给slave

            - 复制客户端缓冲区长度`client-output-buffer-limit slave 256MB 64MB 60`

                - 如果复制客户端缓冲区直接超过256MB或60秒内超过64MB, 会导致全量复制失败

    - 7.slave接受完全部数据后，会清空旧数据

        - 在执行全量复制期间, slave依然响应读命令, 如果时间过长, 可能会导致客户端读取到旧的数据

            - 可以开启`slave-server-stale-data` (默认关闭), 解决数据不一致

                - 开启后slave只会响应`info` `salveof` 命令，其他命令会回复"SYNC with master in progess"


    - 8.加载新的RDB后, 如果slave开启了AOF持久化, 会立刻执行`bgrewriteaof` 命令重写AOF


- 部分复制:当 slave 与 master 连接断开后重连如果每次都进行全量复制，效率很低。因此Redis 2.8 版本后，引入了部分复制

    ![avatar](./Pictures/redis/slave4.avif)

    ![avatar](./Pictures/redis/slave1.avif)

    - 如果offset（偏移量）在master的`repl-backlog-buffer`（复制缓冲区），那么会回复`+CONTINUE`进行部分复制。如果不在就全量复制

        - master根据`repl-backlog-buffer`（复制缓冲区）的数据发送给slave


- 以前slave重启后丢失了master的id和复制偏移量，这导致重启后需要全量同步（已解决）：Redis 4.0 后，主节点的编号信息被写入到 RDB 中持久化保存。

- 以前slave切换master会导致全量复制（已解决）：Redis 4.0 以后，对 PSYNC 进行了改进。主从切换后，新的主节点会将先前的主节点记录下来。 info replication 的结果，可以可以看到 `master_replid` 和 `master_replid2` 两个id，前者是当前主节点的id，后者为先前主节点的id

    - 新的master能够认识 <原master id>，并明白自己的数据就是从该节点复制来的。那么新的master就应该清楚它和该slave师出同门，应该接受部分复制。

### 心跳

- master默认每隔10秒发送`ping`命令

    - `repl-ping-slave-period`参数控制

- slave每隔1秒发送`replconf ack {offset}`，上报偏移量

    - master会将最后一次的通信延迟的秒数，保存为lag（正常应该是0,1）
        ```redis
        info replication
        slave0:ip=127.0.0.1,port=6380,state=online,offset=1526,lag=0
        ```

        - 如果超过`repl-timeout`（默认60秒），就会断开连接。如果slave之后恢复，那么心跳继续

### redis 6.0 无盘全量复制和无盘加载

- 无盘全量复制：以前的全量复制，RDB 生成后，在主进程中，会读取此文件并发送给从节点。

    - redis 6.0后：dump 后直接将数据直接发送数据给从节点，不需要将数据先写入到 RDB

        - 缺点：在子进程中直接使用网络发送数据，这比在子进程中生成 RDB 要慢，这意味着子进程需要存活的时间相对较长。子进程存在的时间越长，写时复制造成的影响就越大，进而导致消耗的内存会更多。

- 无盘加载：以前slave一般是先接收 RDB 将其存在本地，接收完成后再载入 RDB。

    - redis 6.0后：slave也可以直接载入master发来的数据，避免将其存入本地的 RDB 文件中，而后再从磁盘加载。

### redis 7.0 共享主从复制缓冲区

- master执行了写命令后，就会将命令内容写入到各个连接的发送缓冲区中。发送缓冲区存储的是待传播的命令，这意味着多个发送缓冲区中的内容其实是相同的。而且，这些命令还在复制积压缓冲区中存了一份呢。这就造成了大量的内存浪费，尤其是存在很多slave的时候。

    ![avatar](./Pictures/redis/slave5.avif)

    - Redis 7.0 中，百度团队的同学提出并实现了共享主从复制缓冲区的方案解决了这个问题。该方案让发送缓冲区与复制积压缓冲区共享，避免了数据的重复，可有效节省内存。

### 一些问题和注意事项

- 复制是异步的：master不等待slave复制完成

- 数据延迟：延迟取决于网络带宽和命令阻塞

    - 一般会把master和slave放在同一机房/同城机房

    - 需要监控程序定期检查master/slave的偏移量，同样也是延迟的偏移量。当超过10MB监控程序会厨房报警，并统治客户端
        - 可以使用zookeeper监听回调机制实现client通知
        - client收到通知后，将读命令路由到其他从节点
            - 需要修改客户端，方案成本比较高。也可以采用redis集群做水平拓展

    - `repl-disable-tcp-nodelay=no`（默认关闭）：
        - 关闭：主节点产生的命令无论大小，都及时发送给从节点
        - 开启：会合并较小的tcp包，可以节省带宽, 但增大了延迟。默认发送时间根据liunx内核，一般为40秒。
        - 建议：同机架、机房关闭；同城跨机房开启

- master处理过期数据的2种方式：

    - 1.惰性删除：master每次处理读命令，检查是否过期，有则del，同时异步发送给slave

    - 2.定时删除：定时循环采样一定数量的key，发现过期后del

        - 如果此时有大量key过期，master采样的速度跟不上过期的速度，此时在slave会读取到过期的key

    - 注意：从节点自身永远不会主动删除过期的数据

- 主从配置不一致：有些配置必须一致

    - `maxmemory`：如果slave小于master，slave复制的数据大于maxmemory时，数据会丢失，但复制还在继续

    - `hash-max-ziplist-entries`（哈希编码的触发条件）：主从复制一致，但实际内存不一样

- 节点id：

    > redis服务器启动时会分配一个不同的id, 从而识别不同的redis服务器

    - `info server` 命令查看id

    - 开启主从复制后, 主节点如果重启, 导致前后id不一致, 引发全量复制

        - 解决方法: 主节点使用`debug reload` 命令(阻塞)重启, 从而保持id一致, 避免全量复制

            - 缺点: 虽然可以避免全量复制, 但`debug reload` 是阻塞命令, 而阻塞期间会生成新的RDB文件, 并加载

- 部分复制退化为全量复制：

    - 如果offset（偏移量）不在`repl-backlog-buffer`（默认为1M），则会退化为全量复制

        - 确保`repl-backlog-buffer` > 复制偏移量的差值 * 网络中断的时长

- 星型架构复制风暴：单个master同时向多个slave发送RDB全量复制。导致网络带宽消耗严重，甚至连接断开

    - 解决方法：改为树状架构

- 单机器多master：如果机器故障时间长，恢复时会导致大量的全量复制

    - 解决方法：避免单机器部署过多master

- master没有开启持久化，自动重启后会数据清空：导致slave数据也被清空。先在从节点`slaveof no one`关闭主从复制，再进行master重启。

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

- 只能在同一个 `redis-server` 下使用

- 应用：聊天室、公告牌、b站等视频服务、服务之间的消息解耦

> ```redis
> # 发布
> pubhlish 订阅号 内容
> ```

> ```redis
> # 订阅
> subscribe 订阅号1 订阅号2
> ```

- 视频服务
    ```redis
    # 客户端订阅
    subscribe video:changes

    # 另一个客户端push
    publish video:changes "video1, video2"
    ```

- 我这里一共三个客户端.左边为发布者;右边上订阅 rom,rom1;右边下只订阅 rom

    ![avatar](./Pictures/redis/subscribe.gif)

- `psubscribe` 通过通配符*,可以匹配 rom,rom1 等订阅.

    - psubscribe 信息类型为 `pmessage`
    - subscribe 信息类型为 `message`

    ```redis
    psubscribe rom*
    ```

    ![avatar](./Pictures/redis/subscribe1.gif)

### 键空间通知（监控改动的键）

接收那些以某种方式改动了 Redis 数据集的事件。[详情](http://redisdoc.com/topic/notification.html)

```redis
# 开启键空间通知
config set notify-keyspace-events "AKE"
```

```redis
# 订阅监听key
psubscribe '__key*__:*'
```

![avatar](./Pictures/redis/keyspace.avif)

## 调试和性能测试

- 网络延迟
```sh
# 测试于服务器的网络延迟
redis-cli --latency

# 测试于服务器的网络延迟，每15秒输出1次可以通过-i控制
redis-cli --latency-history

# 图表显示
redis-cli --latency-dist
```

```sh
# 获取大key(内部采用scan)
redis-cli --bigkeys

# 每隔1秒获取内存占用, 一共获取100次. -r: 执行多次, -i: 每隔几秒执行一次
redis-cli -r 100 -i 1 info | grep used_memory_human

# 每隔一秒获取info的统计信息
redis-cli --stat
```

- 检测系统是否可以稳定分配指定容量内存

```sh
# 测试1G。测试检测时间比较长
# 并不需要每次redis开启都要进行测试。该功能偏向于调试和测试
redis-server --test-memory 1024
```

### [redis-benchmark性能测试](https://redis.io/topics/benchmarks)

- [loopback benchmarks is silly](https://redis.io/topics/pipelining#appendix-why-are-busy-loops-slow-even-on-the-loopback-interface)

- 默认使用redis-benchmark会插入3个键：`counter:__rand_int__` ，`key:__rand_int__`，`mylist`

    - 如果想插入更多键，使用-r参数

```sh
# -c 表示100个客户端，-n表示200000个get，-q表示
redis-benchmark -c 100 -n 200000 -q

# 测试set, lpush命令的吞吐量
redis-benchmark -t set,lpush -n 100000 -q
```

- unxi socket vs tcp/ip性能对比

```sh
time redis-benchmark -h 127.0.0.1 -p 6379
# 输出: redis-benchmark -h 127.0.0.1 -p 6379  10.25s user 14.48s system 83% cpu 29.676 total

time redis-benchmark -s /var/run/redis/redis.sock
# 输出: redis-benchmark -s /var/run/redis/redis.sock  10.36s user 10.83s system 98% cpu 21.558 total
```

### 监控

- 要监控输入/输出缓冲区，防止过大

    - 输入缓冲区：`client list`命令会阻塞，可以使用`info clients`命令查看最大输入缓冲区，超过10M就报警

    - 输出缓冲区：slave客户端的大小可能会比较大；最好不要使用`monitor`命令

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

# k8s

- [字节跳动技术团队：火山引擎 Redis 云原生实践]()

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
