<!-- vim-markdown-toc GFM -->

* [Redis](#redis)
    * [软件架构](#软件架构)
        * [从单线程Reactor到redis6.0多线程架构演进](#从单线程reactor到redis60多线程架构演进)
        * [Redis vs Memcached](#redis-vs-memcached)
    * [基本命令](#基本命令)
        * [遍历key命令](#遍历key命令)
        * [数据库迁移命令](#数据库迁移命令)
        * [高级技巧](#高级技巧)
    * [数据类型](#数据类型)
        * [编码](#编码)
            * [ziplist编码](#ziplist编码)
            * [intset编码](#intset编码)
        * [string (字符串)](#string-字符串)
            * [Bitmaps(位图)](#bitmaps位图)
        * [hash (哈希散列)](#hash-哈希散列)
        * [list (列表)](#list-列表)
        * [set (集合)](#set-集合)
            * [交集,并集,补集](#交集并集补集)
        * [zset(有序集合)](#zset有序集合)
            * [交集,并集](#交集并集)
            * [geo(地理信息定位)](#geo地理信息定位)
        * [publish subscribe (发布和订阅)](#publish-subscribe-发布和订阅)
            * [键空间通知（监控改动的键）](#键空间通知监控改动的键)
        * [streams(消息队列)](#streams消息队列)
            * [消息队列的发展](#消息队列的发展)
            * [基本命令](#基本命令-1)
        * [HyperLogLog（概率集合）](#hyperloglog概率集合)
    * [Module(模块)](#module模块)
        * [RedisJSON](#redisjson)
        * [RediSearch](#redisearch)
        * [RedisBloom（布隆过滤器）](#redisbloom布隆过滤器)
        * [redis-cuckoofilter（布谷鸟过滤器）](#redis-cuckoofilter布谷鸟过滤器)
        * [docker中的redismod（包含所有模块）](#docker中的redismod包含所有模块)
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
        * [debug命令](#debug命令)
        * [ACL](#acl)
        * [远程登陆](#远程登陆)
        * [使用unix sock连接](#使用unix-sock连接)
        * [安全](#安全)
    * [persistence (持久化) RDB AOF](#persistence-持久化-rdb-aof)
        * [RDB(Redis DataBase)快照](#rdbredis-database快照)
        * [AOF(append only log)](#aofappend-only-log)
            * [AOFRW（重写）](#aofrw重写)
            * [redis 7.0.0的multi part AOF（多文件AOF机制）](#redis-700的multi-part-aof多文件aof机制)
        * [RDB/AOF重写子进程对性能的影响](#rdbaof重写子进程对性能的影响)
        * [RDB + AOF混合持久化](#rdb--aof混合持久化)
        * [只用作内存缓存，禁用RDB + AOF](#只用作内存缓存禁用rdb--aof)
        * [flushall/flushdb等命令误删除数据](#flushallflushdb等命令误删除数据)
    * [master slave replication (主从复制)](#master-slave-replication-主从复制)
        * [主从建立过程](#主从建立过程)
        * [主从复制过程](#主从复制过程)
        * [心跳](#心跳)
        * [redis 6.0 无盘全量复制和无盘加载](#redis-60-无盘全量复制和无盘加载)
        * [redis 7.0 共享主从复制缓冲区](#redis-70-共享主从复制缓冲区)
        * [一些问题和注意事项](#一些问题和注意事项)
    * [sentinel (哨兵模式)](#sentinel-哨兵模式)
        * [sentinal的配置](#sentinal的配置)
        * [sentinel演示](#sentinel演示)
        * [专属API](#专属api)
        * [实现原理](#实现原理)
        * [slave（从节点）高可用](#slave从节点高可用)
    * [cluster (集群)](#cluster-集群)
        * [集群功能限制](#集群功能限制)
        * [手动建立集群](#手动建立集群)
            * [节点握手](#节点握手)
            * [分配槽（slot）](#分配槽slot)
        * [自动建立集群](#自动建立集群)
            * [演示](#演示)
        * [Gossip通信协议](#gossip通信协议)
        * [集群的扩容和收缩](#集群的扩容和收缩)
            * [扩容](#扩容)
            * [收缩](#收缩)
        * [key的重定向](#key的重定向)
            * [Smart客户端](#smart客户端)
        * [故障转移](#故障转移)
            * [日志演示](#日志演示)
            * [手动故障转移](#手动故障转移)
        * [集群倾斜](#集群倾斜)
        * [单机redis数据迁移到cluster](#单机redis数据迁移到cluster)
        * [常见问题](#常见问题)
    * [调试和性能测试和优化](#调试和性能测试和优化)
        * [redis-benchmark性能测试](#redis-benchmark性能测试)
        * [阻塞](#阻塞)
            * [jedis发现阻塞](#jedis发现阻塞)
            * [slowlog(慢查询日志)](#slowlog慢查询日志)
            * [mysql 存储redis慢查询日志](#mysql-存储redis慢查询日志)
            * [客户端周期性连接超时](#客户端周期性连接超时)
            * [cpu](#cpu)
            * [持久化阻塞](#持久化阻塞)
            * [网络问题](#网络问题)
        * [理解内存](#理解内存)
            * [内存的消耗](#内存的消耗)
            * [内存管理](#内存管理)
            * [内存优化](#内存优化)
        * [处理bigkey](#处理bigkey)
        * [寻找热点key](#寻找热点key)
        * [linux相关的性能配置](#linux相关的性能配置)
        * [监控](#监控)
            * [cachecloud](#cachecloud)
            * [Grafana](#grafana)
    * [缓存（cache）](#缓存cache)
        * [缓存穿透、缓存雪崩、缓存击穿](#缓存穿透缓存雪崩缓存击穿)
        * [缓存一致性问题](#缓存一致性问题)
            * [最终一致性策略](#最终一致性策略)
            * [强一致性策略](#强一致性策略)
        * [如何减少缓存删除/更新的失败？](#如何减少缓存删除更新的失败)
        * [如何处理复杂的多缓存场景？](#如何处理复杂的多缓存场景)
* [k8s](#k8s)
* [redis 安装](#redis-安装)
    * [centos7 安装 redis6.0.9](#centos7-安装-redis609)
    * [docker install](#docker-install)
* [其他版本的redis](#其他版本的redis)
    * [阿里云的Tair](#阿里云的tair)
    * [腾讯云的Tendis](#腾讯云的tendis)
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

- [深入学习Redis（1）：Redis内存模型](https://www.cnblogs.com/kismetv/p/8654978.html)

    > 内存, 数据类型

### 从单线程Reactor到redis6.0多线程架构演进

- [刘Java：Redis 的线程模型—文件事件处理器的详解](https://juejin.cn/post/7109446432116981796)

- [刘Java：Redis 6.0 引入的多线程机制简介](https://juejin.cn/post/7109841068669009933)

- [腾讯技术工程: Redis 多线程网络模型全面揭秘](https://segmentfault.com/a/1190000039223696)

![avatar](./Pictures/redis/redis-version.avif)

- 演进：

    - Redis6.0之前：单线程 Reactor 网络模型

        - 对于一个 DB 来说，CPU 通常不会是瓶颈，因为大多数请求不会是 CPU 密集型的，而是 I/O 密集型，也就是客户端和服务端之间的网络传输延迟。使用单线程的 I/O 多路复用网络模型。能带来更好的可维护性，方便开发和调试。

            - 所有的操作都在一个线程中处理，如果某个 handler 阻塞时，会导致其他所有的 client 的 handler 都得不到执行，更严重的是会导致整个服务不能接收新的 client 请求 (因为 acceptor 也被阻塞了)，因为有这么多的缺陷，因此单线程 Reactor 模型用的比较少，但是却很适合 Redis 的网络模型，因为 Redis 要求保证每个操作的原子性。

        - 优点:

            - 没有并发问题, 因此没有锁

            - 减少上下文切换

        - 缺点:

            - 只有1条队列, 可能会造成其他命令阻塞

            - Redis4.0 加入多线程处理异步任务

                - 问题: 耗时的命令的阻塞问题

                    - 如果键值的内存小：单线程同步删除损耗也不会太大

                    - 如果键值的内存大（几十兆的文件），毫秒内是无法删除的；还有`DEL`命令在删除上百个对象，会非常耗时。都会阻塞之后的命令。

                        - 但是这些删除释放操作对其它操作并没有任何影响，所以可以异步执行，通过多线程非阻塞的释放内存空间，提高执行效率。

                - 解决方法: 加入一些非阻塞命令如 `UNLINK`(DEL的异步版), `FLUSHALL ASYNC`, `FLUSHDB ASYNC`

                    - `UNLINK` 并不会同步删除key, 只是从keyspace移除key, 将任务放入一个异步队列, 再由后台线程删除

                        - 如果是小key, 异步删除反而开销更大, 因此只有元素大于64才会使用异步删除

    - Redis6.0 多线程 Reactor 网络模型（默认关闭）：主要是为了提高网络 IO 读写性能，读写网络的 read/write 系统调用占用了 Redis 执行期间大部分 CPU 时间，瓶颈主要在于网络的 IO 消耗（还有一个瓶颈是内存）。多线程并行的进行网络 IO 操作，执行命令仍然是单线程顺序执行。因此不需要担心线程安全问题。

        - 开启多线程：在`redis.conf`配置文件设置
        ```redis
        # 开启多线程（默认为no）
        io-threads-do-reads true

        # 设置线程数（4 核的机器建议设置为 2 或 3 个线程，8 核的建议设置为 6 个线程）
        io-threads 6
        ```

        - Multi-Reactors 模式：不再是单线程的事件循环，而是有多个线程（Sub Reactors）各自维护一个独立的事件循环

            - 类似于Nginx 和 Memcached 等

        - 这里需要额外关注 I/O 线程初次启动时会设置当前线程的 CPU 亲和性，也就是绑定当前线程到用户配置的 CPU 上，在启动 Redis 服务器主线程的时候同样会设置 CPU 亲和性

        ![avatar](./Pictures/redis/redis6多线程.avif)

        - 特点：
            - 1.IO 线程组要么同时在读，要么同时在写，不会同时读或写。
            - 2.IO 线程只负责读写 socket 解析命令，不负责命令处理，命令的执行由主线程串行执行 (保持单线程)。
            - 3.无须担心命令执行的安全问题。

        - benchmark：[美图技术：正式支持多线程！Redis 6.0与老版性能对比评测]()

            - GET/SET 命令在 4 线程 IO 时性能相比单线程是几乎是翻倍了
            ![avatar](./Pictures/redis/redis6多线程1.avif)
            ![avatar](./Pictures/redis/redis6多线程2.avif)


- Redis 通过设置 CPU 亲和性，可以将主进程 / 线程和子进程 / 线程绑定到不同的核隔离开来，使之互不干扰，能有效地提升系统性能。

    - 可以解决CPU 高速缓存问题：Redis 主进程正在 CPU-1 上运行，给客户端提供数据服务，此时 Redis 启动了子进程进行数据持久化（BGSAVE 或者 AOF），系统调度之后子进程抢占了主进程的 CPU-1，主进程被调度到 CPU-2 上去运行，导致之前 CPU-1 的高速缓存里的相关指令和数据被汰换掉，CPU-2 需要重新加载指令和数据到自己的本地高速缓存里，浪费 CPU 资源，降低性能。

    - 可以解决NUMA 架构问题：多个处理器之间通过 QPI 数据链路互联，跨 NUMA 节点的内存访问开销远大于本地内存的访问

- 多client命令队列

    - 问题:单命令队列

        - 每次客户端的命令都经历3个过程：发送命令、执行命令、返回结果。

        - redis采用单线程处理命令，所有命令被放入一个队列中顺序执行

            - 采用非阻塞I/O，epoll作为I/O多路复用实现

    - 解决方法:多命令队列

        - 1.每个客户端的连接都会初始化一个`client` 的对象, 并维护有一条命令队列

        - 2.I/O线程读取命令队列, 并解析第一条命令, **但不执行命令**

        - 3.等所有I/O线程完成读取后, 命令交由主线程处理, 将结果写入每个`client` 对象的buf

        - 4.I/O线程把`client`里的buf, 写回客户端

### Redis vs Memcached

- [刘Java：Redis的概述以及与memecached的区别](https://juejin.cn/post/7107623464848080932?searchId=2023081400322375A81D3F816B729C969C)

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

- 所有的数据都有`redisObject`来封装

    ![avatar](./Pictures/redis/redisObject.avif)

    ```c
    #define LRU_BITS 24

    typedef struct redisObject {
        unsigned type:4;
        unsigned encoding:4;
        unsigned lru:LRU_BITS; /* LRU time (relative to global lru_clock) or
                                * LFU data (least significant 8 bits frequency
                                * and most significant 16 bits access time). */
        int refcount;
        void *ptr;
    } robj;
    ```

    - type：字符串对象、 列表对象（list object）、 哈希对象（hash object）、 集合对象（set object）、 有序集合对象（sorted set object）这五种对象中的其中一种

        - key：总是一个字符串对象（string object）

        | 对象         | type 命令输出 |
        | ------------ | ------------- |
        | 字符串对象   | "string"      |
        | 列表对象     | "list"        |
        | 哈希对象     | "hash"        |
        | 集合对象     | "set"         |
        | 有序集合对象 | "zset"        |

    - refcount：引用次数
        - `object refcount {key}`命令查看引用次数
            - =0时表示可以安全回收
            - 大于1时, 表示共享对象
        - 对象为整数且数值范围在[0-9999]时，redis会使用共享对象池，从而节省内存

    - *ptr：如果是整数，直接存储数据；否则表示指向数据的指针

### 编码

- redis不做编码回退：数据转向压缩编码非常消耗cpu得不偿失

#### ziplist编码

- zlplist
   ![avatar](./Pictures/redis/ziplist.avif)
   - 1.zlbytes：整体长度（字节)。在对ziplist重新分配内存或者计算zlend的位置时有用。
   - 2.zltail：最后一个节点距离头部的偏移量，无需遍历整个ziplist即可确定尾节点的地址，在反向遍历ziplist或者pop尾部节点的时候很有用。
   - zllen：ziplist的节点（entry）个数。
   - entry：数据节点，长度不固定，自己的长度保存在每一个entry节点内部。
   - zlend：8位无符号整数固定值为0xFF，用于标记ziplist的结尾。

- 不同类型耗时排序 list < hash < zset

    | 类型 | 数据量 | key总数量 | 长度 | value大小 | 普通编码内存量/平均耗时 | 压缩编码内存量/平均耗时 | 内存低比例 | 耗时增长倍数 |
    |------|--------|-----------|------|-----------|-------------------------|-------------------------|------------|--------------|
    | hash | 100万  | 1000      | 1000 | 36字节    | 103.37M/0.84微秒        | 43.83M/13.24微秒        | 57.5%      | 15倍         |
    | list | 100万  | 1000      | 1000 | 36字节    | 92.46M/0.84微秒         | 39.92M/5.45微秒         | 56.8%      | 2.5倍        |
    | zset | 100万  | 1000      | 1000 | 36字节    | 151.84M/1.85微秒        | 43.83M/13.24微秒        | 71%        | 42倍         |

    - 命令平均耗时使用`info commandstats`命令获取：包含调用次数、总耗时、平均耗时（微秒）

- 建议长度不超过1000，每个元素大小控制在512字节以内

#### intset编码

- intset：
    - 1.encoding：分3种int-16、int-32、int-64
        - 超过后自动升级，但不会回退
        - 因此尽量保持整数范围一致，如都在int-16范围内，防止个别元素触发集合升级，浪费内存
    - 2.length：集合个数
    - 3.contents：整数数组按从小到大排序
        - 因此intset是有序的

| 数据量 | key大小 | value大小 | 编码      | 集合长度 | 内存量  | 内存降低比例 | 平均耗时  |
|--------|---------|-----------|-----------|----------|---------|--------------|-----------|
| 100w   | 20字节  | 7字节     | hashtable | 1000     | 61.97MB |              | 0.78毫秒  |
| 100w   | 20字节  | 7字节     | intset    | 1000     | 4.77MB  | 92.6%        | 0.51毫秒  |
| 100w   | 20字节  | 7字节     | ziplist   | 1000     | 8.67MB  | 86.2%        | 13.12毫秒 |

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

- redis采用SDS（simple dynamic string）来实现简单动态字符串
    ```c
    struct sdshdr {
        int len; // 字符串的实际内容所占长度
        int free; // 空闲空间长度
        char buf[];
    };
    ```

- C 字符串 vs SDS(动态字符串)：

    - 获取字符串长度的时间复杂度: C为O(n), SDS为O(1)

    - 杜绝缓冲区溢出, SDS缓冲区溢出时会重新分配内存

    - 修改字符串长度: C每次都需要重新分配内存, SDS记录free(剩余空间)可以减少分配内存的次数

    - 存储二进制数据: C以`0` 结尾, SDS以len记录为结尾

    - 使用SDS存储文本时, 可以兼容 C 字符串函数.


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

- Redis 6.2.0开始提供了`LMOVE`命令，将列表a的最左/最右元素，移动到列表b的最左/最右
```redis
# LMOVE自身
127.0.0.1:6379> LRANGE a 0 -1
1) "cc"
2) "bb"
3) "aa"
127.0.0.1:6379> LMOVE a a left right
"cc"
127.0.0.1:6379> LRANGE a 0 -1
1) "bb"
2) "aa"
3) "cc"

将列表a的最左元素，移动到b的最右
127.0.0.1:6379> LPUSH a aa bb cc dd
(integer) 4
127.0.0.1:6379> LRANGE a 0 -1
1) "dd"
2) "cc"
3) "bb"
4) "aa"
127.0.0.1:6379> LPUSH b aa bb cc dd
(integer) 4
127.0.0.1:6379> LRANGE b 0 -1
1) "dd"
2) "cc"
3) "bb"
4) "aa"
127.0.0.1:6379> lmove a b left right
"dd"
127.0.0.1:6379> LRANGE b 0 -1
1) "dd"
2) "cc"
3) "bb"
4) "aa"
5) "dd"
127.0.0.1:6379> LRANGE a 0 -1
1) "cc"
2) "bb"
3) "aa"
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

- intset编码是有序的：
```redis
127.0.0.1:6379> sadd set:test 7 5 9 8 3 0
(integer) 6
127.0.0.1:6379> 2609:M 17 Aug 2023 23:09:28.091 * 1 changes in 900 seconds. Saving...
127.0.0.1:6379> object encoding set:test
"intset"
127.0.0.1:6379> smembers set:test
1) "0"
2) "3"
3) "5"
4) "7"
5) "8"
6) "9"
```

- hashtable编码是无序的：
```redis
127.0.0.1:6379> config set set-max-intset-entries 6
CONFIG SET will change the server's configs.
Do you want to proceed? (y/n): y
Your Call!!
OK
127.0.0.1:6379> sadd set:test 1
(integer) 1
127.0.0.1:6379> object encoding set:test
"hashtable"
127.0.0.1:6379> smembers set:test
1) "8"
2) "7"
3) "3"
4) "0"
5) "1"
6) "5"
7) "9"
```

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

- [刘Java：Redis GEO 地理位置的使用与原理解析以及Java实现GEOHash算法](https://juejin.cn/post/7113202149533679630?searchId=202308270748512C0BDDB8FBBD7BAB391C)

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

### publish subscribe (发布和订阅)

- [刘Java：Redis Pub/Sub 发布订阅模式的深度解析与实现消息队列](https://juejin.cn/post/7112434646851584013?searchId=202308270748512C0BDDB8FBBD7BAB391C)

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

- Pub/Sub 原理

    - 每个 Redis 服务器进程维持着一个标识服务器状态的`redis.h/redisServer`结构

        ```c
        struct redisServer {
            // ...
            dict *pubsub_channels;  // 订阅频道
            list *pubsub_patterns;  // 订阅模式
            // ...
        };
        ```

        - `pubsub_channels`是一个 dict 字典结构，key（数组元素）为 channel，value 就是某个 client，client 以链表的方式串联起来

            - `SUBSCRIBE`：就是将 channel 和 client 加入到 dict 中
            - `PUBLISH`：只需要通过上述字典定位到具体的 channel，就能找到所有订阅该 channel 的客户端，再把消息发送给它们就好了。
            - `UNSUBSCRIBE`：将对应 channel 下面的链表中的 client 删除即可。

    - pubsub_patterns用于存储所有的 glob channel，它是一个 list 结构，节点类型为redis.h/pubsubPattern

        ```c
        typedefstruct pubsubPattern {
            redisClient *client;  // 订阅模式的客户端
            robj *pattern;        // 订阅的模式
        } pubsubPattern;
        ```

        - `PSUBSCRIBE`：程序就创建一个pubsubPattern添加到 pubsub_patterns 链表中。如果另一个客户端也订阅一个模式，则向链表的后面新增一个 pubsubPattern 节点即可。
        - `PUBLISH`：除了会在 pubsub_channels 中定位具体的 channel 之外，还会将指定的 channel 与 pubsub_patterns 中的模式进行对比，如果 指定的 channel 和某个模式匹配的话，那么也将 message 发送到订阅那个模式的全部客户端。
        - `PUNSUBSCRIBE`：删除 pubsub_patterns 中，client 和 pattern 信息对比一致的节点。

#### 键空间通知（监控改动的键）

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

### streams(消息队列)

- [官方文档](https://redis.io/topics/streams-intro)

- [刘Java：Redis Stream 流的深度解析与实现高级消息队列【一万字】](https://juejin.cn/post/7112825943231561741?searchId=202308270748512C0BDDB8FBBD7BAB391C)

#### 消息队列的发展

- [阿里云开发者：Redis消息队列发展历程]()

    - List（列表）：

        - 1.通过 lpush 命令写入消息，通过 rpop 命令拉取消息，也可以使用 BRPOP 实现阻塞式的拉取消息。

            - brpop阻塞接口实现了长轮询，该效果等同于服务端推送，消费者能立刻感知到新的消息，而且通过设置合理的超时时间，使系统资源的消耗降到很低。

            ![avatar](./Pictures/redis/stream-list.avif)

        - 2.rpop或brpop这样接口消费消息会先从队列中删除消息，然后再由应用消费，如果应用应用在处理消息前异常宕机了，消息就丢失了。

            - 但如果使用lindex这样的只读命令先读取消息处理完毕后在删除，又需要额外的机制来保证一条消息不会被其他消费者重复读到。

                - 因此需要通过2个list组和来完成消息的消费和确认功能。使用rpoplpush从list A中消费消息并移入list B，等消息处理完毕后在从list B中删除消息。

            ![avatar](./Pictures/redis/stream-list1.avif)

        - 优点：

            - Redis的接口是并发安全的，可以同时有多个生产者向一个list中生产消息，多个消费者从list中读取消息。

        - 缺点：

            - 不支持消息广播机制（每个消息只会被读取一次）。生产者生产的一个消息可以被多个消费者消费到，这个功能在分布式系统中非常重要。

    - Pub/Sub（发布/订阅）：支持消息多播

        ![avatar](./Pictures/redis/stream-pub_sub.avif)

        - 优点：
            - 支持广播

            - psubscribe能按字符串通配符匹配：消费者可以会订阅一批channel
                - 例子：一个用户订阅了浙江的新闻的推送，但浙江新闻还会进行细分，例如“浙江杭州xx”、“浙江温州xx”，这里订阅者不需要获取浙江的所有子类在挨个订阅，只需要调用psubscribe“浙江*”就能订阅所有以浙江开头的新闻推送了

            - 能订阅特定key或特定命令的系统消息

            - 与数据库也无关：在 db10 上发布，将可以被 db1 上的订阅者听到。

        - 缺点：

            - 消息不会持久化

                - 必须先执行订阅，再等待消息发布。如果先发布了消息，那么该消息由于没有订阅者，消息将被直接丢弃。

            - 消息只管发送，不管接收，也没有 ACK 机制，无法保证消息的消费成功。如果某个消费者中途加入进来，或者挂掉重启，那么这之前丢失的消息也不能再次消费。

            - 如果消费者应用处理能力不足，消息就会在Redis的client buf中堆积，当堆积数据超过一个阈值后会断开这条连接，这意味着这些消息全部丢失了，在也找不回来了。

                - 如果同时有多个消费者的client buf堆积数据但又还没达到断开连接的阈值，那么Redis服务端的内存会膨胀，进程可能因为oom而被杀掉，这导致了整个服务中断。

            - 只能在同一个 `redis-server` 下使用

            - 结论：以上的缺点导致 Redis 的 Pub/Sub 模式就像个小玩具，在生产环境中几乎无用武之地，非常的尴尬！为此，Redis5.0 版本新增了 Stream 数据结构，不但支持多播，还支持数据持久化

    - Redis 5.0 stream


        - 优点：

            - 开销成本：存储message数据使用了listpack结构，这是一个紧凑型的数据结构，不同于list的双向链表每个节点都要额外占用2个指针的存储空间，这使得小msg情况下stream的空间利用率更高。

            - 持久化：stream的数据会存储在aof和rdb文件中
            - ack机制：保证消息至少被处理一次
                - 已经读取但没有ack的消息，stream会标示这条消息的状态为pending，等客户端重连后通过xpending命令可以重新读取到pengind状态的消息，继续处理。
                - 如果这个应用永久宕机了，并通过xclaim命令将转移到其他消费者

        - 消费组 (Consumer Group)：从 Kafka 借鉴的概念

            - `XREAD`命令可以实现一个消费者监听多个 Stream
            - 消费组`XREADGROUP`命令：多个消费者获取一个stream. entry被哪个消费者获取? 取决于哪个消费者更快(竞争)

                - kafka 的消费者组中的消费者还需要和分区对应，而 Redis 的消费者组中的消费者相当于直接从 Stream 中获取消息。

            - 功能：

                - 1.每条消息都提供给不同的消费者，因此不可能将相同的消息传递给同一个组内的多个消费者。
                - 2.在消费者组中，消费者通过名称进行标识，该名称是实现消费者的客户端必须提供的区分大小写的字符串。
                    - 即使在断开连接后，流消费者组仍保留所有消费者的状态，客户端可以再次声明为同一个消费者。
                - 3.ack：消费消息需要使用特定命令进行显式确认，表示此消息已正确处理，可以移除。

                    - 消费者组跟踪所有当前未 ack 的消息。因此每个消费者只会看到传递给它的消息。

            - 优点：
                - 消费者组实现同组多个消费者并行但不重复消费消息的能力，提升消费能力。
                - 消费者组能够记住最新消费的信息，保证消息连续消费
                - 消费者组能够记住消息转移次数
                    - 实现消费失败重试以及永久性故障的消息转移。
                    - 借此可以实现死信消息的功能（需自己实现）。
                - 消费者组提供了 PEL 未确认列表和 ACK 确认机制，保证消息被成功消费，不丢失

            - 数据结构：

                - 像是一个仅追加内容的消息链表，每个消息都有一个唯一的 ID 和内容
                ![avatar](./Pictures/redis/stream.avif)

                - 1.消费者组（Consumer Group）：一个消费组可以有多个消费者 (Consumer) 同时进行组内消费，所有消费者共享 Stream 内的所有信息

                    - 但同一条消息只会有一个消费者消费到，不同的消费者会消费 Stream 中不同的消息，这样就可以应用在分布式的场景中来保证消息消费的唯一性。

                - 2.游标（last_delivered_id）：用来记录某个消费者组在 Stream 上的消费位置信息 **，每个消费组会有个游标，任意一个消费者读取了消息都会使游标 last_delivered_id 往前移动。

                    - 就是最新消费的消息ID：创建消费者组时需要指定从 Stream 的哪一个消息 ID（哪个位置）开始消费，该位置之前的数据会被忽略

                - 3.pending_ids：消费者内部的状态变量，作用是维护消费者的未确认的消息 ID。
                    - pending_ids 记录了当前已经被客户端读取，但是还没有 ack (Acknowledge character：确认字符）的消息。
                    - 如果客户端没有 ack，那么这个变量里面的消息 ID 就会越来越多，一旦某个消息被 ack，它就会对应开始减少。这个变量也被 Redis 官方称为 PEL (Pending Entries List)。

        - 重复处理问题：消息被重复处理要么是生产者重复投递，要么是消费者重复消费。

            - 解决生产者重复投递问题：

                - 每个消息都设置了一个唯一递增的id。当xadd超时后应用并不能确定消息是否投递成功，可以通过xread查询该id的消息是否存在，存在就说明已经投递成功，不存在则重新投递

                - 而且stream限制了id必须递增，这意味了已经存在的消息重复投递会被拒绝。

            - 解决消费者重复消费问题：考虑一个场景，消费者读取消息后业务处理完毕，但还没来得及ack就发生了异常，应用恢复后对于这条没有ack的消息进行了重复消费。这个问题因为ack和消费消息的业务逻辑发生在2个系统，没法做到事务性，需要业务来改造，保证消息处理的幂等性。


- 相比其他消息队列

    - 优点：基于内存存储，其速度相比于真正的消息队列比如 kafka、rocketmq 等更快
    - 缺点：
        - 也是因为内存的原因，我们无法使用 Redis Stream 长时间的存储大量的数据
        - 没有提供延时消息的能力

- 应用场景：由于基于内存，无法存储大量数据，因此在生产环境的应用也并不多

    - 更适用于小型、廉价的应用程序，以及可以丢弃数据的场景（限制 Stream 长度），比如记录某些不重要的操作日志。

#### 基本命令

| 命令       | 时间复杂度 |
|------------|------------|
| xpending   | O(N)       |
| xread      | O(N)       |
| xrange     | O(log(N)) 来寻找，然后 O(M) 来返回 M 个元素 |
| xrevrange  | O(log(N)) 来寻找，然后 O(M) 来返回 M 个元素 |
| xtrim      | O(N)       |
| xinfo      | O(N)       |
| xreadgroup | O(M)       |
| xclaim     | O(log N)   |
| xack       | O(1)       |
| xlen       | O(1)       |
| xadd       | O(1)       |
| xdel       | O(1)       |
| xgroup     | O(1)       |

```redis
# Stream 中每一个消息都有一个唯一的id
# 一条消息由一组字段值对组成，它基本上是一个小 dict 字典。键值对将会按照用户给定的顺序存储

# 添加消息到stream末尾(返回id值), *表示自动生成唯一id(毫秒时间戳 + 偏移量))
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

# 删除entry（不会真正的删除消息，它只是给消息做了个标志位）
XDEL mystream <id值>

# 数量限制（自动将最老的消息清除，确保最多不超过指定长度）。如果消息积累太多，那么 Stream 链表会很长，对内存来说是一个大问题。
XTRIM mystream MAXLEN 3

# 查看长度. 返回2
XLEN mystream

# 查看队列.复杂度 O(log(N))，迭代的每一步都很快。不需要 XSCAN 命令（Redis 没有提供 XSCAN）。
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


# XREAD(非阻塞), 查看mystream队列（非阻塞模式和 XRANGE 似乎没有太大的区别）
XREAD STREAMS mystream 0

# 读取多个队列
XREAD STREAMS mystream mystram1 0 0

# 查看前2条entry
XREAD COUNT 2 STREAMS mystream 0

# 阻塞获取最新的entry, 获取后返回。$表示返回的最大的 ID。
# 单位是毫秒，超时自动返回 null；0表示永久阻塞直到任何一个的 Stream 有数据返回。
XREAD BLOCK 0 STREAMS mystream $
```

- Consumer groups(消费者组)

```redis
# 为mystream创建消费者组。最后一个参数表示从哪里开始，0从第一条开始，$表示仅消费最新消息
XGROUP CREATE mystream mygroup $
# 如果mygroup不存在，才创建
XGROUP CREATE mystream mygroup $ MKSTREAM

# 查看组内的指定队列
XINFO GROUPS mystream

# 创建user0, 并获取最新的1条entry. > 表示获取到目前为止，从未传递给其他消费者的消息，并且会更新 last_delivered_id，通常都是传递这个参数。
XREADGROUP GROUP mygroup user0 COUNT 1 STREAMS mystream >

# 创建user1, 并获取最新的1条entry(最新的entry, 被user0还是user1获取? 取决于谁更快执行这条命令)
XREADGROUP GROUP mygroup user1 COUNT 1 STREAMS mystream >

# 查看user0, 已经获取的entry. 0表示消费者因故障重启时可以指定 ID 为 0 来获取分配给该消费者的所有未 ACK 的消息，实现消息的不丢失。
XREADGROUP GROUP mygroup user0 STREAMS mystream 0

# 查看指定队列的entry的未处理（待确认的）消息.消费者可能会永久失败并且永远无法恢复。待处理消息该怎么办呢？
# XDEL命令并未真正被移除，只是被标记为已删除，使用 XPENDING 也能够看到其还在存在于 PEL 中。
XPENDING mystream mygroup

# 查看所有entry的users获取情况(第三个参数为: entry从XADD到user XREADGROUP的时间(毫秒))
XPENDING mystream mygroup - + 2

# 查看每个user的entry的处理情况
XINFO CONSUMERS mystream mygroup

# 转移消息（假设用户故障无法恢复）。1小时后修改指定entry的ack用户为user1
XCLAIM mystream mygroup user1 3600000 <id值>

# 自动转移（相当于先调用 XPENDING，然后调用 XCLAIM）。1小时后修改指定entry在内的后10条entry的, ack用户为user1
XAUTOCLAIM mystream mygroup user1 3600000 <id值> COUNT 10

# 确认已经获取的entry, 确认后的entry无法从XREADGROUP获取，这条消息的 PEL 记录也被清除，从 Redis 服务器释放内存。
# 一旦消费者成功处理了一条消息，它就应该调用 XACK
XACK mystream mygroup <id值>
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

### [RedisBloom（布隆过滤器）](https://github.com/RedisBloom/RedisBloom)

- [官方文档](https://redis.io/docs/data-types/probabilistic/bloom-filter/)

```redis
# 添加foo
BF.ADD newFilter foo

# 查询foo
BF.EXISTS newFilter foo

# MADD
BF.MADD myFilter foo bar baz

# 自定义过滤器。0.0001表示错误率 600000表示期望元素个数
#1% error rate requires 10.08 bits per item
#0.1% error rate requires 14.4 bits per item
#0.01% error rate requires 20.16 bits per item
BF.RESERVE customFilter 0.0001 600000
```

### [redis-cuckoofilter（布谷鸟过滤器）](https://github.com/kristoff-it/redis-cuckoofilter)

- [官方文档](https://redis.io/docs/data-types/probabilistic/cuckoo-filter/)

### docker中的redismod（包含所有模块）

```sh
docker run -d -p 6379:6379 redislabs/redismod
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

### debug命令

- 在配置文件加入`enable-debug-command local`开启debug（默认为no，因此不能执行debug相关的命令）

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

### 安全

- 2015年11月，全球数万个redis遭到攻击，数据全部被清楚，还有一个crackit的键存在，这个键其实是攻击者的公钥

- 被攻击的redis有以下特点：
    - redis所在的机器有外网ip
    - redis以默认端口6379启动，并且对外网开放
    - redis以root用户启动
    - redis的bind（防火墙）设置为0.0.0.0

- 攻击在利用`dir`和`dbfilename`两个配置可以使用`config set`动态配置，以RDB持久化的特性，把自己公钥写入到`/root/.ssh/authotrized_keys`文件中，机器就被攻陷了

    ![avatar](./Pictures/redis/crackit.avif)

- 预防：

    - 1.设置redis密码

        - 密码要足够复杂，不然会被暴力破解
        - 开启主从复制，从节点的配置要加入`masterauth`，不然会失效
        - auth是明文传输，有被攻击者劫持的风险

    ```sh
    # 服务器启动时，设置密码为testpasswd
    redis-server ~/redis/redis.conf --requirepass testpasswd
    ```

    ```sh
    # 客户端登陆后，auth命令进行密码验证
    redis-cli
    127.0.0.1:6379> ping
    (error) ERROR Authentication required.
    127.0.0.1:6379> auth testpasswd
    OK
    127.0.0.1:6379> ping
    "PONG"
    ```

    2.将危险命令改名

        | 危险命令         | 操作                    |
        |------------------|-------------------------|
        | keys             | 如果key很多，会阻塞     |
        | flushall/flushdb | 数据全部清除            |
        | save             | 如果key很多，会阻塞     |
        | debug            | debug reload会重启redis |
        | config           | 应该交给管理员使用      |
        | shutdown         | 关闭redis               |

        ```redis
        // flushall改名为qweqwe。之后在执行flushall就会显示找不到命令
        rename-command flushall qweqwe
        ```

        - 问题：
            - 1.`jedis.flushall()`内部使用的是flushall命令，改名后将报错。需要对客户端进行修改，有一定开发维护成本
            - 2.rename-command不支持`config set`命令的修改
            - 3.如果RDB/AOF文件包含了rename-command之前的命令，redis将无法启动
            - 4.对config命令改名，sentinel可能会无法工作

        - 最佳实践：
            - 对于危险命令如`flushall`进行改名
            - 第一次配置redis时，就配置rename-command，因为rename-command不支持config set
            - 要保证主从一致性

    - 3.防火墙只允许如80端口对外开放

        - bind配置的错误认识：bind指定的是网卡，而不是网址和端口

            ```sh
            # redis只能从10.10.xx.192这张网卡访问。默认为127.0.0.1。如果设置成0.0.0.0，表示允许任何人访问
            bind 10.10.xx.192
            ```
    - 4.定期备份数据
    - 5.不使用默认端口
    - 6.使用非root用户启动
        - resin、jetty、habase、hadoop都应该非root启动

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

### RDB/AOF重写子进程对性能的影响

- fork耗时与内存量成正比（需要复制父进程的页表），建议redis内存控制在10GB以下（每GB20毫秒左右）

    - 写时复制cow（copy-on-wirte）：当父进程有写请求操作时，会创建内存页的副本

        - 因此避免在子进程备份时，进行大量写入操作，导致父进程维护大量内存页副本

        - linux kernel的Transparent Huge Pages（THP）大内存页（2MB）功能（默认开启）

            - 可以减少fork的时间，但会增加父进程创建内存页副本的消耗。从4KB变为2MB，每次写命令引起的复制内存页放大了512倍，拖慢写操作的时间，导致写操作慢查询
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

### flushall/flushdb等命令误删除数据

- 会造成缓存雪崩

- 如果没有做业务降级操作，那么用户应用的最终反馈可能就是报错或空白页面

- AOF恢复：只不过是aof文件追加一条记录，删除对应的命令即可恢复

    - **如果AOF重写发生了，那么数据也就真的丢了**

        - 所以当误操作后需要做：

            - 1.调大AOF重写参数：`auto-aof-rewrite-min-size`和`auto-aof-rewrite-percentage`
                ```redis
                config set auto-aof-rewrite-percentage 1000
                config set auto-aof-rewrite-min-size 10000000000
                ```

            - 2.拒绝手动执行`bgrewriteaof`

    ```redis
    # 设置key
    set a 123

    # 再把它删了
    del a
    ```

    - 打开 `/var/lib/redis/appendonly.aof` 文件，把和 **del** 相关的行删除

    ![avatar](./Pictures/redis/aof恢复.avif)

    删除后：

    ![avatar](./Pictures/redis/aof恢复1.avif)

    ```sh
    # 然后使用redis-check-aof 修复 appendonly.aof 文件
    redis-check-aof --fix /var/lib/redis/appendonly.aof

    # 重启redis-server后，key就会恢复
    ```

    ![avatar](./Pictures/redis/aof.gif)

- RDB的变化

    - 除非执行过`save`, `bgsave`还有主从的全量复制，不然rdb会保存flush之前的数据

- 如果从节点同步了flash命令，数据也会被清除。但AOF和RDB的变化和主节点一样

- 建议维护人员提前准备好shell脚本或者其他自动化的方式处理，因为故障不等人。像flush这样的危险操作，应该通过有效方式进行规避

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

            - master会核对id与自己是否一致。runid重启时重新生成，如果master重启过，会导致全量复制。可以使用`debug reload`进行重启，就不会丢失runid

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

    - 3.slave接受master的响应数据保存runid和offset（偏移量）

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


- 以前slave重启后丢失了master的runid和复制偏移量，这导致重启后需要全量同步（已解决）：Redis 4.0 后，主节点的编号信息被写入到 RDB 中持久化保存。

- 以前slave切换master会导致全量复制（已解决）：Redis 4.0 以后，对 PSYNC 进行了改进。主从切换后，新的主节点会将先前的主节点记录下来。 info replication 的结果，可以可以看到 `master_replid` 和 `master_replid2` 两个id，前者是当前主节点的runid，后者为先前主节点的runid

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

- runid：

    > redis服务器启动时会分配一个不同的runid, 从而识别不同的redis服务器

    - `info server` 命令查看runid

    - 开启主从复制后, 主节点如果重启, 导致前后id不一致, 引发全量复制

        - 解决方法: 主节点使用`debug reload` 命令(阻塞)重启, 从而保持runid一致, 避免全量复制

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

- [《Redis使用手册》中的sentinel章](http://redisdoc.com/topic/sentinel.html)

- 如果master故障（以下步骤都需要手动操作）
    - 1.将slave-1晋升为master（`slaveof no one`）
    - 2.将slave-2成为new master的slave（`slaveof {NewMaster-ip} {NewMaster-port}`
    - 3.客户端修改master的地址

    - 结论：上述都需要人介入，所以不是高可用，sentinal就是为了解决这一问题而生

- sentinel本身是redis节点，不存储数据，只支持部分命令

- sentinel 会不断地检查你的主服务器和从服务器是否运作正常

- 发现故障后，如果部署了多个sentinel（集群），会选举领导者负责故障转移（自动完成）
    - 1.对slave-1节点执行：`slaveof no one`
    - 2.对slave-2节点执行：`slaveof {NewMaster-ip} {NewMaster-port}`
    - 3.通知客户端

- 生产环境建议sentinel的节点分布在不同的物理机上

- 至少部署3个或奇数个sentinel节点
    - 3个是提高对于故障判定的准确性
    - 领导者选举要一半+1个节点，奇数可以节省1个节点

- sentinel集合监控1个master？还是多个master？两套方案的优点即另一方的缺点
    - 监控1个master：
        - 优点：每套sentinel相互隔离
        - 缺点：资源浪费
    - 监控多个master：
        - 优点：降低运维成本，只需要一套sentinel集合就可以了
        - 缺点：
            - 如果这套sentinel集合出现异常，对多个redis造成影响
            - 如果redis节点过多，会造成sentinel节点产生过多的网络连接

- 部署sentinel的机器时间要同步（NTP服务），否则日志的时序会混乱。

- sentinal节点的配置要尽可能一致

### sentinal的配置

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

- 所有配置可以通过`sentinel set`命令进行调整。如`sentinel set mymaster quorum 2`

- **sentinel** 配置文件 `~/redis/sentinel/redis-sentinel-26379.conf`加入以下代码:

```sh
# 端口
port 26379

# 允许后台启动
daemonize yes

# 日志文件的目录
dir "/home/tz/redis/sentinel"

# 日志文件名
logfile "26379.log"

# 仅仅只需要指定要监控的主节点，并自己定义名字
# 1表示quorum：要判定master最终不可达的票数（设置越小，下线条件越宽松，反之越严格）一般设置sentinel节点数的一半+1（例如3个sentinel节点就设置2）
# quorum除了代表票数外，还与领导者选举有关，至少要max(quorum, num(sentinels) / 2 + 1)个sentinel节点参与投票才能进行选举领导者（例如quorum=4，那么至少4个在线sentinel节点才能进行选举）
sentinel monitor YouMasterName 127.0.0.1 6379 1

# sentinel定期PING 主从节点和其他sentinel节点，超过时间(单位毫秒，这里为60秒)没有答复，则判定不可达
sentinel down-after-milliseconds YouMasterName 60000

# 当主服务器失效时， 在不询问其他 Sentinel 意见的情况下， 强制开始一次自动故障迁移
# 故障转移超时时间，超过后故障转移失败。下一次在故障超时时间设置为2倍
sentinel failover-timeout YouMasterName 5000

# 在执行故障转移，选举出新master后：最多可以有多少个slave同时对新master进行复制操作， 这个数字越大表示多个slave向新master同时发起复制操作（虽不会阻塞master，但会造成master的网络和磁盘IO开销）
# =1表示slave会轮询发起复制
sentinel parallel-syncs YouMasterName 1
```

- 其他配置参数。

    - `sentinel auth-pass <YouMasterName> <password>`：master如果设置密码，这里要添加master的密码

    - `sentinel notification-script <master-name> <script-path>`：故障转移期间，出现重要事件（如-sdown客观下线、-odown主观下线）时，会触发对应路径的shell脚本，并向脚本发送相应事件的参数。脚本的时间不能大于60秒，超过后会被kill掉
        ```sh
        #!bin/sh
        # 获取所有参数
        msg=$*

        # 退出
        exit 0
        ```

        - shell脚本记得设置执行权限（x），不然启动sentinel节点时会报以下错误
        ```
        >>> 'sentinel notification-script YouMasterName /home/tz/redis/sentinel/notification-script.sh'
        Notification script seems non existing or non executable.
        ```

    - `sentinel client-reconfig-script <master-name> <script-path>`：将故障转移后的结果发送给对应路径的shell脚本（也可以使用上一个参数的脚本）。脚本的时间不能大于60秒，超过后会被kill掉

### sentinel演示

开启 sentiel 服务器（默认端口为26379）

```sh
redis-sentinel ~/redis/sentinel/redis-sentinel-26379.conf
# 或者
redis-server ~/redis/sentinel/redis-sentinel-26379.conf --sentinel
```

```sh
# 连接 sentinel
redis-cli -p 26379
```

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

### 专属API
```redis
# 只显示指定master的ip和端口
sentinel get-master-addr-by-name YouMasterName

# 显示所有被监控的master的状态和统计信息
sentinel masters

# 指定master
sentinel masters YouMasterName

# 显示指定master中所有slave的状态和统计信息
sentinel slaves YouMasterName

# 显示监控指定master的其他sentinel节点信息（不包含自己）
sentinel sentinels YouMasterName

# 清除指定master的相关状态（如故障转移）
sentinel reset YouMasterName

# 对指定强制故障转移
sentinel failover YouMasterName

# 检测sentinel节点的总数，是否达到<quorum>的个数。如果quorum=3，sentinel节点个数是2，那么将无法进行故障转移
sentinel ckquorum YouMasterName

# 保存sentinel节点的配置，如配置文件还在则不会保存（只有配置文件丢失时有用）
sentinel flushconfig

# 取消指定master的监控。取消后可通过info Sentinel命令查看
sentinel remove YouMasterName

# 监控master（与配置文件一样）
sentinel monitor YouMasterName 127.0.0.1 6379 1
```

### 实现原理

- 3个定时任务

    - 1.每隔10秒，每个sentinel节点会向master和slave发送`info`命令获取最新的拓扑图
        - 通过向master执行`info`命令获取slave信息，这也是为什么不需要显示配置slave
        - 节点故障，可以实时获取

    - 2.每隔2秒，每个sentinel节点会订阅redis数据节点的`__sentinel__:hello频道`，并发送自身对master的判断以及自身的信息，从而了解其他sentinel节点
        - 可以发现新的sentinel节点
        - sentinel节点交换master的信息，并作为之后领导人选举的依据

    - 3.每隔1秒，每个sentinel会给主从节点、其他sentinel节点，发送`PING`命令做一次心跳检测，判断是否可达
        - 主观下线：超过`down-after-milliseconds`配置参数时，则对该节点做出失败判断。也叫主观下线，也就是存在误判的可能

        - 客观下线：当主观下线的是master的时候，该sentinel节点会通过`sentinel is-master-down-by-addr`命令向其他sentinel节点询问对master的判断，当超过<quorum>个数时，就做出客观下线的决定

            - master下线后sentinel节点依然会对其进行定期监控。日志设置`loglevel=debug`，可以查看
                - 缺点：造成网络资源浪费
    
- 领导者sentinel节点选举：故障转移只需1隔sentinel节点完成，所有需要选举。redis使用raft算法实现

    - 1.每个sentinel都有资格成为领导者，当主观下线master的时，sentinel节点会通过`sentinel is-master-down-by-addr`命令，会将自己设置为领导者
    - 2.收到命令的sentinel，如果没有同意其他节点的发过来的命令，则同意该节点，否则拒绝
    - 3.sentinel节点发现自己的票数>= max(quorum, num(sentinels) / 2 + 1)时，就成为领导者
    - 4.如果此轮没有选举成功，则进入下一次选举
    
- 故障转移：领导者sentinel节点进行

    - 1.在slave列表里选出一个作为master

        - 1.过滤以下不健康：

            | 不健康                                          |
            |-------------------------------------------------|
            | 主观下线                                        |
            | 断线                                            |
            | 5秒内没有回复过sentinel节点的`PING`命令心跳检测 |
            | 与master失联超过`down-after-milliseconds*10秒`  |

        - 2.选择`slave-priority`（优先级）最高的slave。存在则返回，不存在则继续下一步
        - 3.选择复制偏移量最大的slave。存在则返回，不存在则继续下一步
        - 4.选择`runid`最小的slave

    - 2.对选择好的slave执行`slaveof no one`命令，成为master
    - 3.向剩余的slave执行`slaveof {NewMaster-ip} {NewMaster-port}`

- 如果没有可用的slave，将无法完成故障转移

    - 可以手动启动一个从节点（配置添加`slaveof {master-ip} {master-port}`），它会被sentinel自动发现

### slave（从节点）高可用

- 只有master高可用：

    ![avatar](./Pictures/redis/sentinel-slave.avif)

    - 如果slave-1故障，client-1将失联，sentinel节点只会对slave-1做主观下线，因为故障转移是针对master的。

    - 所以很多时候slave只是热备份，不让它参与客户端的读操作

- 实现slave高可用：
    - sentinel监控的slave变动事件
        - `+switch-master`：切换master（从升主），说明减少了1个slave
        - `+convert-to-slave`：切换slave（主降从），说明增加了1个slave
        - `+sdown`：主观下线。说明某个slave可能不可用，sentinel没有slave客观下线。需要客户端自己实现
        - `+reboot`：重启某节点，如果它是slave,说明添加了1个slave

    - 只要掌握所有slave的状态，把所有slave看作一个资源池。无论上线还是下线都能感知到，高可用就到达了

    ![avatar](./Pictures/redis/sentinel-slave1.avif)

## cluster (集群)

- 数据分布理论

| 分区方式 | 哈希分区                                 | 顺序分区                                 |
|----------|------------------------------------------|------------------------------------------|
| 特点     | 离散度好、数据分布业务无关、无法顺序访问 | 离散度倾斜、数据分布业务相关、可顺序访问 |
| 代表产品 | redis、cassandra、dynamo                 | bigtable、hbase、hypertable              |

- 哈希分区的几个方法：

    - 1.节点取余分区（hash算法）：根据特定数据，如redis的key或用户id，hash(key) % N（节点数）计算哈希值，映射到对应节点

        - 优点：简单。常用于数据库分库分表（一般采用预分区方式，提前规划好分区数），扩容时通常翻倍扩容，避免映射全部被打乱，导致全量迁移

        - 缺点：扩容或收缩节点时，映射关系需要重新计算，会导致数据重新迁移

    - 2.一致性哈希分区（Distributed Hash Table）：为每个节点分配一个token（0-2^32），这些token构成一个哈希环。先根据key计算hash值，然后顺时针找到第一个大于等于该hash值的token节点

        - 优点：增删节点，只影响哈希环相邻节点

        - 缺点：
            - 增删节点，会造成哈希环部分数据无法命中，需要手动处理或忽略这些数据
                - 因此常用于缓存场景

            - 使用少量节点时，节点变化将大范围影响哈希环中数据映射
                - 因此不适合少量节点

            - 增删节点，需要增加1倍或删除1半节点，才能保证数据和负载的均衡

    - 3.虚拟槽分区：槽（slot）的数量远远大于节点数，采用大范围的槽是方便数据拆分和集群扩容。

        - Dynamo也使用这方案

        - redis cluster槽的范围为0-16383，假设有5个节点，每个节点负责3276个槽
            - slot=CRC16(key) & 16383

            ![avatar](./Pictures/redis/cluster7.avif)

### 集群功能限制

- 1.key批量操作受限：如`mget`、`mset`，只支持相同slot值的key。不同的slot值key不被支持
- 2.事务：只支持key在同一个节点，不支持多个节点
- 3.key为数据分区的最小粒度：不能将一个大key如hash、list映射到不同节点
- 4.不支持多数据库：单机下redis支持16个数据库，集群只能使用默认的db 0 号数据库
- 5.主从复制结构只支持一层：不支持嵌套树状复制结构

### 手动建立集群

- 开启6个redis

    ```sh
    # 通过for循环,开启6个实例
    for (( i=6379; i<=6384; i=i+1 )); do
        redis-server /var/lib/redis/$i/redis.conf
    done
    ```

    - 第一次开启，没有内部配置文件，会自动创建一份

        - redis会自动维护集群内部文件，不要手动修改，防止集群重启时产生错误

        - nodes-6379.conf文件内容

            ```
            253e27e0d617bb3c9cdbede1468ecc23e54e4ee9 :0@0 myself,master - 0 0 0 connected
    vars currentEpoch 0 lastVoteEpoch 0
            ```
            - 最重要的是节点id（40位16进制字符串），用于标识集群内的唯一性，很多操作需要借助节点id来完成。
                - 节点id不同于runid，节点id在集群初始化时只创建1次，重启后重用；runid重启是会重置，因此master节点重启会触发全量备份

    - 开启后检测节点日志是否正确

#### 节点握手

- 由客户端连接6379节点，发起`cluster meet 127.0.0.1 6380`命令

    - `cluster meet`是异步命令，执行后立刻返回

    - 流程：
        - 1.6379节点本地创建6380节点信息对象，并发送meet
            ![avatar](./Pictures/redis/cluster-meet.avif)

        - 2.6380节点收到后，回复`PONG`

        - 3.之后6379和6380定期通过`PING/PONG`小学进行节点通信

    - 在6379和6380分别执行`cluster nodes`命令（等同于nodes-6379.conf配置文件），可以看到双方已经建立集群
        ![avatar](./Pictures/redis/cluster-meet1.avif)

        ```redis
        eaf4548fff6106be87d672019ecb600f2481f18d 127.0.0.1:6380@16380 master - 0 1692435953323 0 connected
        253e27e0d617bb3c9cdbede1468ecc23e54e4ee9 127.0.0.1:6379@16379 myself,master - 0 0 1 connected
        ```

- 握手没能正常工作，集群还在下线状态，读写都被禁止

    ```redis
    127.0.0.1:6379> set hello 11111
    (error) ERROR CLUSTERDOWN Hash slot not served
    ```

    - `cluster info`命令查看
    ```redis
    127.0.0.1:6379> cluster info
    cluster_state:fail
    //以下省略
    ```

    - 只有当16384个槽全部分配给节点后，才进入在线状态

#### 分配槽（slot）

- 分配槽

    ```sh
    #!/bin/sh
    for (( i=0; i<=5461; i=i+1 )); do
        redis-cli -h 127.0.0.1 -p 6379 cluster addslots $i
    done

    for (( i=5462; i<=10922; i=i+1 )); do
        redis-cli -h 127.0.0.1 -p 6380 cluster addslots $i
    done

    for (( i=10923; i<=16383; i=i+1 )); do
        redis-cli -h 127.0.0.1 -p 6381 cluster addslots $i
    done
    ```

    - `cluster nodes`查看节点分配的槽
    ```redis
    127.0.0.1:6379> cluster nodes
    ba17a754f45ce4ac259768d973de8354eee10a1b 127.0.0.1:6384@16384 master - 0 1692437361478 5 connected
    253e27e0d617bb3c9cdbede1468ecc23e54e4ee9 127.0.0.1:6379@16379 myself,master - 0 1692437358000 1 connected 0-5461
    a18392ee91e8494d1ab2ddaf2cbaa7c0ca204ff3 127.0.0.1:6382@16382 master - 0 1692437359000 2 connected
    4d36091538f0cfb2c73d18dd1d43dc37f4d198d2 127.0.0.1:6383@16383 master - 0 1692437360000 3 connected
    d1ab3a98eb3f46bcb5572ecef1c29ba97fb668b2 127.0.0.1:6381@16381 master - 0 1692437361000 4 connected 10923-16383
    eaf4548fff6106be87d672019ecb600f2481f18d 127.0.0.1:6380@16380 master - 0 1692437362480 0 connected 5462-10922
    ```

- 建立主从复制，必须在从节点上执行`cluster replicate {master nodeid}`

    ```sh
    redis-cli -h 127.0.0.1 -p 6382 cluster replicate 253e27e0d617bb3c9cdbede1468ecc23e54e4ee9
    redis-cli -h 127.0.0.1 -p 6383 cluster replicate eaf4548fff6106be87d672019ecb600f2481f18d
    redis-cli -h 127.0.0.1 -p 6384 cluster replicate d1ab3a98eb3f46bcb5572ecef1c29ba97fb668b2
    ```

    - `cluster nodes`可以看到节点状态变为`slave`
    ```redis
    127.0.0.1:6379> cluster nodes
    ba17a754f45ce4ac259768d973de8354eee10a1b 127.0.0.1:6384@16384 slave d1ab3a98eb3f46bcb5572ecef1c29ba97fb668b2 0 1692438829285 4 connected
    253e27e0d617bb3c9cdbede1468ecc23e54e4ee9 127.0.0.1:6379@16379 myself,master - 0 1692438825000 1 connected 0-5461
    a18392ee91e8494d1ab2ddaf2cbaa7c0ca204ff3 127.0.0.1:6382@16382 slave 253e27e0d617bb3c9cdbede1468ecc23e54e4ee9 0 1692438827280 1 connected
    4d36091538f0cfb2c73d18dd1d43dc37f4d198d2 127.0.0.1:6383@16383 slave eaf4548fff6106be87d672019ecb600f2481f18d 0 1692438826277 0 connected
    d1ab3a98eb3f46bcb5572ecef1c29ba97fb668b2 127.0.0.1:6381@16381 master - 0 1692438827000 4 connected 10923-16383
    eaf4548fff6106be87d672019ecb600f2481f18d 127.0.0.1:6380@16380 master - 0 1692438829000 0 connected 5462-10922
    ```

- 此时集群已经创建成功，已经可以使用`set`命令了
    ```redis
    127.0.0.1:6379> cluster info
    cluster_state:ok
    //省略
    ```

### 自动建立集群

```sh
# 通过for循环,开启6个实例
for (( i=6379; i<=6384; i=i+1 )); do
    redis-server /var/lib/redis/$i/redis.conf
done

# 自动建立集群
redis-cli --cluster create 127.0.0.1:6379 127.0.0.1:6380 127.0.0.1:6381 127.0.0.1:6382 127.0.0.1:6383 127.0.0.1:6384 --cluster-replicas 1

# 查看集群是否建立成功（包含cluster nodes命令）
redis-cli --cluster check 127.0.0.1:6379
```

#### 演示

- 至少配置6个节点，才能实现高可用

    - 配置 6 个实例,从端口 6380 到 6385:

    ```sh
    # 端口
    port 6380

    # 后台运行
    daemonize yes
    pidfile "/var/run/redis-6380.pid"

    # 日志和集群内部配置文件的保存目录
    dir "/var/lib/redis/6380"

    # 日志文件名
    logfile "6380.log"

    # 从节点只读模式
    replica-read-only yes

    # 开启集群模式
    cluster-enabled yes

    # 集群内部配置文件
    cluster-config-file nodes-6380.conf

    # 节点超时时间（单位毫秒）。每个节点每秒会执行 10 次 ping，每次会选择 5 个最久没有通信的其它节点。当然如果发现某个节点通信延时达到了 cluster_node_timeout / 2
    cluster-node-timeout 15000
    ```

- 开启 6 个实例:

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

### Gossip通信协议

- 分布式存储需要维护node的元数据信息（故障信息、状态信息等）。维护方式分为：集中式、P2P

     - redis采用P2P的Gossip（流言）协议。node彼此不断通信交换信息，一段时间后所有node都知道cluster的完整信息

- 通信过程：

    - 1.每个node都会开通一个tcp通道，与其他node通信。端口为基础端口加上10000

    - 2.每个node每秒1次选择几个node发送`PING`消息
        - 通信node过多虽然可以及时获取信息，但交换成本过高。因此选择通信的node列表就变得非常重要
            - 1.每秒随机5次找出最久没有通信的1个node，发送`PING`
            - 2.每100毫秒都会扫描本地node节点，如果发现最后通信时间大于`node-timeout` / 2，则立刻发送`PING`
            - 根据以上2个规则可以计算出：每个node每秒发送`PING`的数量= 1 + 10 * num(node.pong_received > cluster_node_timeout / 2)
                - 因此`cluster_node_timeout`参数对消息发送的影响非常大。带宽资源紧张时可以调整为30秒（默认为15秒）

    - 3.接受`PING`的node，回复`PONG`

- 消息类型：消息格式划分为`消息头` + `消息体`。消息头是固定的2KB，消息体包含其他node的信息

    - ping消息：封装了自己node和其他node状态的数据。用于检测node是否在线，并交换彼此状态信息。cluster内最频繁的消息

    - pong消息：响应ping和meet。封装了自身node状态的数据。也可以向cluster广播自身pong，对自身状态的更新
        ![avatar](./Pictures/redis/gossip-pong.avif)

    - meet消息：通知有新node加入

    - fail消息：判断一个node下线时，会向cluster广播一个fail消息。其他node收到后会把对应node更新为下线状态

### 集群的扩容和收缩

- 扩容和收缩：可以看作是槽（slot）和对应数据在不同node之间移动

#### 扩容

- 扩容是cluster最常见的需求

- 1.准备好2个新节点（1个master + 1个slave）
```sh
redis-server redis-6385.conf
redis-server redis-6386.conf
```
- 2.加入集群
```sh
# 加入到6379集群
redis-cli --cluster add-node 127.0.0.1:6385 127.0.0.1:6379
redis-cli --cluster add-node 127.0.0.1:6386 127.0.0.1:6379
```
```sh
# 设置6386为6385的slave。这里输入6385的节点id（nodeid）
redis-cli -p 6386 cluster replicate 38df4d6291d994f1a9aa629fd23404f74abed9db
```

- 3.分配槽
```sh
redis-cli --cluster reshard 127.0.0.1:6379
# 以下为输出
# 输入4096。之前3个主节点，现在4个主节点16384 /4 = 4096
How many slots do you want to move (from 1 to 16384)? 4096
# 这里输入新节点6385的节点id
What is the receiving node ID? 38df4d6291d994f1a9aa629fd23404f74abed9db
# 这里输入源节点的id，分别输入6379、6380、6381的节点id，最后输入done
Source node #1: 253e27e0d617bb3c9cdbede1468ecc23e54e4ee9
Source node #2: eaf4548fff6106be87d672019ecb600f2481f18d
Source node #3: d1ab3a98eb3f46bcb5572ecef1c29ba97fb668b2
Source node #4: done
```

```sh
# 检测节点的均衡性。在2%以内表示相对均衡，无需调整
redis-cli --cluster rebalance 127.0.0.1:6379
*** No rebalancing needed! All nodes are within the 2.00% threshold.
```

- 4.最后`cluster nodes`命令查看cluster

#### 收缩

- 需要把自身的槽（slot）均匀的迁移到其他主节点

- cluster有4个节点，平均每个4096个槽。现在要下线1个节点（6385端口），剩下3个节点也就是4096 / 3 = 1365 + 1365 + 1366个槽。一共3次迁移

- 1.迁移

    - 从6385迁移到6379
    ```sh
    redis-cli --cluster reshard 127.0.0.1:6385
    # 以下为输出
    # 输入1365
    How many slots do you want to move (from 1 to 16384)? 1365
    # 输入目标的节点id，我这里是6379
    What is the receiving node ID? 253e27e0d617bb3c9cdbede1468ecc23e54e4ee9
    # 输入源的节点id，也就是下线的6385节点id
    Source node #1: 38df4d6291d994f1a9aa629fd23404f74abed9db
    Source node #2: done
    ```

    - 从6385迁移到6380
    ```sh
    redis-cli --cluster reshard 127.0.0.1:6385
    # 以下为输出
    # 输入1365
    How many slots do you want to move (from 1 to 16384)? 1365
    # 输入目标的节点id，这次是6380
    What is the receiving node ID? eaf4548fff6106be87d672019ecb600f2481f18d
    # 输入源的节点id，也就是下线的6385节点id
    Source node #1: 38df4d6291d994f1a9aa629fd23404f74abed9db
    Source node #2: done
    ```

    - 从6385迁移到6380
    ```sh
    redis-cli --cluster reshard 127.0.0.1:6385
    # 以下为输出
    # 这次输入1366
    How many slots do you want to move (from 1 to 16384)? 1366
    # 输入目标的节点id，这次是6381
    What is the receiving node ID? d1ab3a98eb3f46bcb5572ecef1c29ba97fb668b2
    # 输入源的节点id，也就是下线的6385节点id
    Source node #1: 38df4d6291d994f1a9aa629fd23404f74abed9db
    Source node #2: done
    ```

- 2.忘记节点：不在让其他node与下线node进行Gossip消息交换

    - 如果只有master下线，则需要把slave指向其他master
    - 如果主从都下线，建议先下线slave，在下线master。防止不必要的全量复制

    - 错误做法：`cluster foget {nodeid}`命令

        - 会把nodeid的node加入节点禁用列表，有效期是60秒，超过会再次进行Gossip消息交换。也就是只有60秒时间，要集群内的每个node都要执行此命令

            - 因此不建议线上用使用命令，需要大量节点命令交互，容易遗漏

    - 正确做法：

        ```sh
        # 下线slave 6386 最后输入节点id
        redis-cli --cluster del-node 127.0.0.1:6386 16a182f86987e9b2336f6eff4ba5f95db7bbe324

        # 下线master 6385 最后输入节点id
        redis-cli --cluster del-node 127.0.0.1:6385 38df4d6291d994f1a9aa629fd23404f74abed9db
        ```

- 3.最后`cluster nodes`命令查看cluster
    - 不包含6385和6386表示安全下线

### key的重定向

- key的重定向：

    - `redis-cli -c`开启自动重定向get key。不过我建议直接使用`iredis`客户端

    ```redis
    # 如果key不在本地，会显示MOVED。我这里表示key在6379节点的866槽。
    127.0.0.1:6380> get hello
    MOVED 866 127.0.0.1:6379
    "11111"

    # 查看key所在的槽（slot）
    cluster keyslot hello
    ```
    ![avatar](./Pictures/redis/cluster-client重定向.avif)

- `hash-tag`：如果key包含`{}`只计算{}内的hash值。这样可以指定一些key，存储在同一个槽

    ```redis
    # 只计算1的hash值
    set hello:{1}:1 11111
    set hello:{1}:2 11111
    set hello:{1}:3 11111

    # 使用mget测试是否在同一个槽
    mget hello:{1}:3 hello:{1}:2 hello:{1}:1
    ```

#### Smart客户端

- 通过客户端内部维护slot->node的映射关系，直接到目的node查找。从而减少1次网络往返

- jedis客户端需要自行修改

### 故障转移

- 故障发现：

    - 主观下线（pfail）：`cluster-node-timeout`时间内，发送的`PING`消息没有回复。会更新本地对node的状态为主观下线。然后在cluster内广播

    - 客观下线：node接受到其他node的pfail，都会尝试触发客观下线
        - 统计下线报告的数量
            - 小于cluster主节点总数的一半，则退出
            - 大于cluster主节点总数的一半，则标记客观下线
                - 广播`fail`
                    - 通知cluster内的node标记故障节点为客观下线状态，并立刻生效
                    - 通知故障节点的slave触发故障转移

                    - 但可能会存在cluster被分割成一大一小两个独立cluster
                        - 大cluster完成客观下线，并广播`fail`
                        - 小cluster无法接受到`fail`。但只要恢复后，只要故障节点变为客观下线，最终可以通过Gossip消息传播到所有node

                        ![avatar](./Pictures/redis/cluster-网络分区.avif)

- 故障恢复：下线的master的所有slave，从中选一个成为新master

    - 1.资格检查：每个slave都要检查与master的断线时间。如果超过`cluster-node-time * cluster-slave-validity-factor（有效因子，默认10）`则没有资格

    - 2.准备选举时间：复制偏移量越大的slave，说明延迟越低，应该具有更高的优先级，将提前触发故障选举流程
        ![avatar](./Pictures/redis/cluster-准备选举时间.avif)

    - 3.发起选举：slave定时任务检测到达故障选举时间（failover_auth_time）到达后，发起选举

        - 1.更新配置纪元

            - 配置纪元：是一个只增不减的整数。

                - 作用：标识cluster内每个master的不同版本，和当前cluster的最大版本。每次出现新的master（新加入或由slave转换而来）、slave竞争选举。都会递增cluster全局的配置纪元，赋值给相关master
                    - 新节点的加入
                    - 槽节点映射冲突检测
                    - slave投票选举冲突检测

                - cluster维护一个全局的配置纪元（clusterState.current Epoch），记录cluster内所有master配置纪元的最大版本

                - master维护自身的配置纪元，表示当前master的版本，每个master的配置纪元都不相等

                    - 配置纪元会跟随`PING/PONG`消息在cluster内传播，如果发送方和接收方的master配置纪元相等，则表示出现了冲突，节点id（nodeid）更大的一方会递增全局配置纪元，并赋值给当前node来区分冲突

                - slave会复制master的配置纪元。

                    - slave每次发起投票都会自增cluster的全局配置纪元

        - 2.在cluster内广播选举信息，并记录已发送过的消息状态，保证该slave在一个配置纪元内只能发起一次选举。

    - 4.选举投票：每个配置纪元代表一次选举周期，在开始投票之后的`cluster-node-timeout * 2`时间内slave没有获取足够数量的投票，则本次选举作废。slave将自增配置单元发起下一轮投票，直到选举成功为止。
        - cluster内的master进行领导者选举。
        - 当slave收集到N/2+1个持有槽的master投票，slave就会替换为master
            - 故障master也算在投票数内，假设cluster是3主3从，有2个master部署在同一个机器上，当这台机器宕机时，slave无法收集到3/2+1个master选票导致故障转移失败
                - 解决方法：部署cluster时，所有master最少需要部署3台物理机上，才能避免单点问题

    - 5.替换master
        - slave取消复制变为master
        - 执行`clusterDelSlot`撤销故障master的槽，并执行`clusterAddSlot`把这些槽委派给自己
        - 向cluster广播pong，通知cluster内的所有node：当前slave变为master，并接管了槽的信息

#### 日志演示

![avatar](./Pictures/redis/cluster-故障转移演示.avif)

- 故障转移

    - 1.强制关闭redis 6379
    ```sh
    kill -9 4748
    ```
    - 2.查看6379的slave 6382的日志，显示复制中断
    ```
    4906:S 20 Aug 2023 22:18:16.610 # Connection with master lost.
    4906:S 20 Aug 2023 22:18:16.610 * Caching the disconnected master state.
    4906:S 20 Aug 2023 22:18:16.610 * Reconnecting to MASTER 127.0.0.1:6379
    4906:S 20 Aug 2023 22:18:16.610 * MASTER <-> REPLICA sync started
    4906:S 20 Aug 2023 22:18:16.610 # Error condition on socket for SYNC: Connection refused
    ```

    - 3.其他两个master（6380、6381）将6379标记为主观下线，超过半数后标记为客观下线

    ```
    4854:M 20 Aug 2023 22:18:33.344 * Marking node 253e27e0d617bb3c9cdbede1468ecc23e54e4ee9 as failing (quorum reached).
    4906:S 20 Aug 2023 22:18:33.344 # Cluster state changed: fail
    ```

    - 4.6382在客观下线后准备选举时间，日志显示延迟879毫秒之后执行
    ```
    4906:S 20 Aug 2023 22:18:33.430 # Start of election delayed for 879 milliseconds (rank #0, offset 16993).
    ```

    - 5.延迟选举时间达到后，slave更新配置纪元（epoch），并发起故障选举
    ```
    4906:S 20 Aug 2023 22:18:34.333 # Starting a failover election for epoch 13.
    ```

    - 6.两个master（6380和6381）对slave（6385）投票
    ```
    4854:M 20 Aug 2023 22:18:34.334 # Failover auth granted to a18392ee91e8494d1ab2ddaf2cbaa7c0ca204ff3 for epoch 13
    ```
    - 7.slave获取超过半数的投票后，执行替换master操作，完成故障转移
    ```
    4906:S 20 Aug 2023 22:18:34.336 # Failover election won: I'm the new master.
    4906:S 20 Aug 2023 22:18:34.336 # configEpoch set to 13 after successful failover
    ```

    - 8.`cluster nodes`命令查看状态。6379状态是fail（客观下线），6382成为master
    ```redis
    a18392ee91e8494d1ab2ddaf2cbaa7c0ca204ff3 127.0.0.1:6382@16382 master - 0 1692541920389 13 connected 0-1364 1366-5461
    253e27e0d617bb3c9cdbede1468ecc23e54e4ee9 127.0.0.1:6379@16379 master,fail - 1692541096691 1692541092000 10 disconnected
    ```

- 故障节点恢复
    - 1.重新启动6379
    ```sh
    redis-server ~/redis/cluster/redis-6379.conf
    ```
    - 2.6379日志：成为了6382的slave
    ```
    8141:M 20 Aug 2023 22:35:33.617 # Configuration change detected. Reconfiguring myself as a replica of a18392ee91e8494d1ab2ddaf2cbaa7c0ca204ff3
    ```
    - 3.cluster内其他node接收到6382发来`PING`，清空客观下线
    ```
    4801:M 20 Aug 2023 22:35:33.713 * Clear FAIL state for node 253e27e0d617bb3c9cdbede1468ecc23e54e4ee9: master without slots is reachable again.
    ```
    - 4.6379发起6382的复制流程
    ```
    8141:S 20 Aug 2023 22:35:38.618 * MASTER <-> REPLICA sync: Flushing old data
8141:S 20 Aug 2023 22:35:38.618 * MASTER <-> REPLICA sync: Loading DB in memory
    ```

#### 手动故障转移

- 在slave执行`cluster failover`命令，slave会变为master（默认情况下，客户端会有短暂阻塞，但不会丢失数据）

    - 1.slave统治master停止处理所有客户端请求
    - 2.master发送对应slave延迟复制的数据
    - 3.slave接受处理延迟复制的数据，知道主从复制的偏移量一致为止，保证复制数据不丢失

    - 4.slave立刻发起投票选举（不需要延迟触发机制）。选举成功后成为master，向cluster广播master`PONG`消息
    - 5.旧master接受到消息后，更新自身配置成为slave，解除所有客户端的阻塞，这些请求会被重定向到新master上执行
    - 6.新slave向新master发起全量复制流程

- 应用场景：

    - 1.调整节点部署时，如节点所在的老机器替换到了新机器。

    - 2.强制故障转移。当自动故障转移失败时，只要master有存活的slave就可以了。自动转移失败的场景有以下
        - 1.master和所有slave同时故障。尽量保证master和slave不在同一机器/机架上。除非机房大面积故障，不然两台机器/机架故障概率很低
        - 2.slave与master复制断线时间爱你超过`cluster-slave-validity-factor * cluster-node-timeout + repl-ping-slave-period`导致slave被判定为没有故障转移资格。
            - 手动故障转移不做中断超时检查
        - cluster超过一半以上的master同时故障

    - 针对以上情况`cluster failover`命令提供两个参数`force/takeover`
        - `cluster failover force`：salve直接发起选举，不再跟master确认复制偏移量（数据会丢失），slave选举成功后替换新master，并向cluster广播配置
            - 应用场景：master宕机无法完成自动故障转移

        - `cluster failover takeover`：不在进行选举，而是直接替换成为新master。由于没有领导者选举发起故障转移，可能会导致配置纪元（epoch）冲突。冲突发生后以节点id（nodeid）高的一方为准，低的一方在这段时间内写入的数据会丢失

            - 应用场景：cluster内超过一半以上master故障，因为slave无法收到超过半数以上master的投票，所以无法完成选举

            - 例子：cluster分别部署在2个同城机房，每个机房都有4个master和4个slave

                ![avatar](./Pictures/redis/cluster-takeover.avif)

                - 当两个机房网络中断后：
                    - 机房A：完成自动故障转移，slave-4成为master-4
                    - 机房B：运维人员对slave-1、slave-2、slave-3分别执行`cluster failover takeover`命令强制故障转移
                - 当两个机房网络恢复后：cluster会有两套持有相同槽信息的node，cluster会使用配置纪元（epoch）高的master槽信息，相等时使用节点id（nodeid）更高的一方。另一方在这段时间内写入的数据将会丢失

- 建议优先级：`cluster failover` > `cluster failover force` > `cluster failover takeover`

### 集群倾斜

- 数据倾斜

    - 1.node和槽（slot）分配严重不均

        ```sh
        # 查看每个node负责的槽和key总量，以及每个槽平均的key数
        redis-cli --cluster info 127.0.0.1:6379
        127.0.0.1:6382 (a18392ee...) -> 3 keys | 5461 slots | 1 slaves.
        127.0.0.1:6381 (d1ab3a98...) -> 3 keys | 5462 slots | 1 slaves.
        127.0.0.1:6380 (eaf4548f...) -> 3 keys | 5461 slots | 1 slaves.
        [OK] 9 keys in 3 masters.
        0.00 keys per slot on average.
        ```

        ```sh
        # 节点对应的槽数量不均匀，可以使用
        redis-cli --cluster rebalance 127.0.0.1:6379
        ```

    - 2.不同槽对应的key数量差异过大
        - CRC16哈希函数，正常情况槽内key的数量会相对均衡
        - 当大量使用`hash_tag`时，会映射到同一个槽
            ```redis
            # 获取槽有多少个key
            cluster countkeysinslot {slof}

            # count代表循环获取所有key，从而发现过度使用hash_tag的槽
            cluster getkeysinslot {slof} {count}
            ```
    - 3.集合对象包含大量元素（也就是bigkey）

        - cluster的槽迁移是对key执行`migrate`命令，如果key过大可能会超时导致迁移失败。

        ```sh
        # 搜索bigkey
        redis-cli --bigkey
        ```

    - 4.内存相关配置不一致
        - 如`hash-max-ziplist-value`、`set-max-intset-entries`等压缩数据配置。如果有大量hash、set的key，极端情况下可能会有数倍内存差异，造成node内存倾斜

- 请求倾斜：对热key或大key使用算法复杂度比较高的命令（如hgetall、smembers等），会导致node负载过高

    - 1.合理设计key：热key拆分，使用`hmget`代替`hgetall`
    - 2.不要使用热key作为`hash_tag`，避免映射到同一个槽
    - 3.对于一致性不高的场景，客户端使用本地缓存减少热key调用

### 单机redis数据迁移到cluster
```sh
redis-cli import 127.0.0.1:6379 --from --copy --replace
```
### 常见问题

- 为了完整性，默认情况下16384个槽，任何一个没有指派到node时，cluster是不可用的。执行任何命令会返回`（error）CLUSTERDOWN Hash slot not served`错误。

    - 但当持有槽的master下线时：从故障发现到自动完成转移期间cluster是不可用的。可以设置参数`cluster-require-full-coverage=no`，当有master下线也只影响它负责槽的相关命令执行，不影响其他master

- 带宽消耗

    - cluster带宽消耗分为：读写命令消耗 + Gossip消息消耗

        - cluster内每个node通过`PING/PONG`消息彼此交换信息，官方建议cluster的node控制在1000以内

        - 消息数据量：每个消息包含：slots槽数组（2KB）+ cluster 1/10的状态数据（10个node状态数据约为1KB）

            - 例子：200个node的cluster，部署在20台物理机上，每台划分10个node，`cluster-node-timeout`（默认15秒），这时`PING/PONG`消息占用25MB，如果设置成20，降低到15MB以下

    - 合理规划：

        - 满足业务尽量避免大集群。同一个系统可以针对不同业务常见拆分多套cluster

        - 由于机器上线带宽是固定的，相同规模的cluster分布的机器越多，每台机器划分的节点划分的越均匀，则cluster内的整体可用带宽越高

            - 例子：《redis开发与运维》作者维护一个推荐系统，根据数据特征使用了5个cluster， 每个cluster的node规模控制在100以内

            - 如果cluster有60个node，部署在3台物理机上，每台部署20个node。这时带宽消耗将非常严重。

        - 适度提高`cluster-node-time`降低消息发送频率，同时此参数还影响故障转移速度，因此需要兼顾二者平衡
            - 主观下线（pfail）识别时间=cluster-node-timeout
            - 主观下线状态消息传播时间<=cluster-node-timeout / 2。超过此时间未通信的node,会发起`ping`
            - slave转移时间<=1000毫秒。由于存在延迟发起选举机制，偏移量最大的slave会最多延迟1秒发起选举。通常第一次就会选举成功，所以slave执行转移时间在1秒以内
            - 故障转移时间：failover-time（毫秒）<= cluster-node-timeout + cluster-node-timeout / 2 + 1000

- 避免在大量node的集群内，频繁使用Pub/Sub功能，否则会严重造成网络带宽的消耗

    - 建议使用sentinel结构专门用于Pub/Sub功能

- 集群读写分离

    - 只读连接：cluster模式下，slave不接受任何读写请求（复制配置的`slave-read-only`在cluster模式下无效）

        - 可以使用`readonly`命令打开客户端只读状态，让slave读取，分担master的压力。

            - `readonly`只是连接级别生效，每次新建连接都要执行。开启readonly想关闭使用`readwrite`命令

    - 读写分离：

        - 需要修改客户端：
            - 1.维护每个master可用的slave列表
            - 2.针对读命令维护请求node路由
            - 3.slave新建连接开启`readonly`状态

        - 不建议做读写分离，因为成本很高，可以直接拓展master数量
        - 读写分离用于特殊的业务场景
            - 1.利用复制的最终一致性，使用多个slave做跨机房部署，降低命令网络延迟
            - 2.master故障转移时间过长，业务把读请求路由给slave保证读操作可用
            - 以上场景，也可以在不同机房独立部署redis cluster解决，通过客户端多写来维护；读命令直接请求到最近机房的cluster，故障时客户端转向另一个cluster

## 调试和性能测试和优化

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

### 阻塞

#### jedis发现阻塞

- redis阻塞时，jedis客户端会抛出`JedisConnectionException`的异常

    - 解决方法：

        - 在应用方加入异常统计，并通过邮件/短信/微信报警（如1分钟超过10个异常）

            - redis调用api会分散在项目的多个地方，每个地方都加入监控代码难以维护。解决方法是日志系统，java可以使用`logback`或`log4j`

        - 但绝大多数客户端类库没有在异常信息打印ip和port的信息，在cluster集群无法快速定位是哪个节点
            - 解决方法：修改redis客户端的成本很低，比如Jedis只需要修改`Connection`类下的connect、sendCommand、readProtocolWithCheckingBroken方法专门捕抓连接、发送命令、协议读取事件异常。

- 引入如cachecloud的监控系统发现阻塞

#### slowlog(慢查询日志)

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

- API或数据结构使用不合理导致bigkey：发现是应用方有个定期（每5分钟）任务，执行了hgetall（复杂度O(n)）造成阻塞，那个bigkey有200万个元素

    - 解决方法：
        - 修改为使用`hmget`命令
        - 处理bigkey：根据业务拆分，如用户好友集合，热点用户会关注大量好友，可以按时间或其他拆分多个集合

- 这得益于客户端的监控工具，如果redis是黑盒运行很难快速发现问题。
    - 监控慢查询，一旦超过阈值就报警

- 要避免在bigkey上执行超过O(n)复杂度的命令

#### cpu

- cpu饱和：

    - 单线程的redis只能使用1个cpu，cpu饱和指把单核cpu跑到接近100%

        - 这会导致redis无法处理更多命令

    - `info commandstats`命令统计命令不合理的开销时间

        ```redis
        cmdstat_hset:calls=198757512,userc=27021957243,userc_per_call=135.95
        ```

        - 这个输出发现了问题：hset复杂度只有O(1)，但平均耗时135微米，显然不合理，正常耗时应该10微妙以下。

            - 这是因为hash使用了`ziplist`编码，操作的复杂度在O(n)到O(n^2)之间

- cpu竞争：redis进程绑定cpu，降低上下文切换

    - 开启持久化和主节点不建议绑定cpu：子进程会和父进程共享1个cpu，导致相互竞争

- 内存swap问题：可以降低swap的优先级`echo 10 > /proc/sys/vm/swappiness`

#### 持久化阻塞

- fork阻塞：查看`info stats`中的`latest_fork_usec`指标，表示最近一次的fork耗时，如果超过1秒，需要优化
    - 解决方法：建议每个redis内存控制在10GB以内

- AOF阻塞：设置`everysec`配置时，当硬盘压力过大，fsync需要等待，当主线程发现距离上一次fsync超过2秒时，会阻塞直到fsync完成，并打印如下日志。并且`info persistence`中的`aof_delayed_fsync`指标会累加。
    ```redis
    Asynchronous AOF fsync is taking too long (disk is busy?). Writeing the AOF buffer without wating for fsync to complete, this may slow down Redis.
    ```

    - 解决方法：
        - 不要和高硬盘负载的服务部署在一起：存储服务、消息队列等...
        - aof重写可以配置`no-appendfsync-on-rewrite`（默认关闭），表示aof重写不做fsync操作
        - 多redis实例，可以配置不同的硬盘存储aof文件

- HugePage：开启了THP，即使是`incr`命令也会出现在慢查询

- 也可能是其他进程引起的：使用`iotop`命令查看

#### 网络问题

- 网络闪断：发生在网络切割或者带宽耗尽，使用`sar -n DEV`查看流量是否正常；或者借助系统监控工具（如Ganglia）进行识别

- redis连接被拒绝：redis通过`maxclients`控制客户端的最大连接数，超过后会拒绝。`info stats`中的`rejected_connections`统计被拒绝连接的数量

    - 客户端访问redis时，尽量采用NIO长连接或连接池

    - 当redis用于大量分布式节点访问且生命周期比较短的场景时（如map/reduce）。客户端会频繁启动和销毁，默认redis不会主动关闭长时间闲置的连接或检查关闭无效的tcp连接，会导致redis无法快速释放的问题

        - 解决方法：配置`tcp-keepalive`和`timeout`参数，让redis主动检测和关闭连接

- 连接溢出：

    - 1.进程限制：最大打开文件数，通过`ulimit -n`查看（默认1024），设置`ulimit -n 65535`

    - 2.tcp-backlog（tcp三次握手中的accept 全连接队列长度）：

        - 查看backlog溢出。如果怀疑是backlog溢出，可以使用cron定时执行
        ```sh
        netstat -s | grep overflowed
        ```

        - 增大队列长度`echo 511 > /proc/sys/net/core/somaxconn`

- 网络延迟：
    - 网络延迟的快到慢：同物理机 > 同机架 > 跨机架 > 同机房 > 同城机房 > 异地机房
        - 容灾性与延迟正好相反

    - `redis-cli --latency`相关命令进行测试

- 网卡软中断：

    - 单个网卡队列只能使用1个cpu，高并发下网卡数据交互都集中在同1个cpu，无法充分利用多核。通过`top`命令中的`si`指标查看

    - linux 2.6.35之后支持Receive Packet Steering(RPS)，实现软件层模拟硬件多队列网卡

### 理解内存

#### 内存的消耗

| info memory命令的属性   | 属性说明                                                                            |
|-------------------------|-------------------------------------------------------------------------------------|
| used_memory             | redis分配器的内存总量，所有数据的内存占用量。单位字节                               |
| used_memory_human       | 和上一个属性一样，只是单位会自动转换为KB、MB、GB                                    |
| used_memory_rss         | 从操作系统的角度显示redis进程的内存总量                                             |
| used_memory_peak        | used_memory属性的峰值，也就是内存使用的最大值                                       |
| used_memory_peak_perc   | 内存峰值所占内存的占比                                                              |
| used_memory_lua         | lua引擎消耗的内存大小                                                               |
| mem_fragmentation_ratio | used_memory_rss/used_memory的比值：内存碎片率                                       |
| mem_allocator           | 内存分配器默认为jemalloc                                                            |
| used_memory_overhead    | string等数据结构的管理需要一定的额外内存开销（overhead）                            |
| used_memory_startup     | 启动时临时内存开销                                                                  |
| used_memory_dataset     | 实际数据存储的内存，即减去overhead、startup额外的开销                               |
| used_memory_vm_eval     | 在虚拟内存中的大小，比used_memory更高。包括实际使用的内存以及预分配的内存缓冲区大小 |

`mem_fragmentation_ratio` > 1：说明多出的部分内存没有用于数据存储，而是内存碎片
`mem_fragmentation_ratio` < 1：操作系统把redis交换（swap）到硬盘

- 内存消耗的划分：自身内存 + 对象内存 + 缓冲内存 + 内存碎片

    - 对象内存：最大的一块，可以理解为`sizeof(keys) + sizeof(values)`

        - key本身是string类型。很容易忽略其对内存的消耗，要避免使用过长的key

    - 缓冲内存：

        - 1.客户端缓冲区：每条tcp连接的输入输出缓冲区。输入缓冲区无法设置，最大为1G；输出缓冲区通过`client-output-buffer-limit`控制

            > 输出缓冲区在大流量场景很容易失控，造成redis内存的不稳定，需要重点监控

            - 普通客户端：
                - 默认配置：`client-output-buffer-limit normal 0 0 0`
                - 有大量慢连接客户端接入时，可以设置`maxclient`做限制
                - 使用`monitor`命令会造成输出缓冲区飙升。

            - 从客户端：
                - 默认配置：`client-output-buffer-limit slave 256mb 64mb 60`
                - 如果主从之间延迟较高或者挂载了大量从节点时，会有很大的内存消耗
                    - 建议主从节点不要部署在较差的网络环境
                    - 建议主节点挂载的从节点不超过2个

            - 订阅客户端：
                - 默认配置：`client-output-buffer-limit pusbsub 32mb 8mb 60`
                - 当生产速度快于消费速度时，会造成输出缓冲区积压

        - 2.复制积压缓冲区：负责部分复制的功能，主节点只有一个，所有从节点共享
            - `repl-backlog-size`（默认1MB），可以设置为100MB

        - 3.AOF缓冲区：重写期间保存的写入命令，无法设置

    - 内存碎片：默认采用jemalloc（freebsd社区开发），可选的还有glibc、tcmalloc（google开发）
        - jemalloc在64位系统将内存空间划分为：小、大、巨大三个范围
            - 小：[8byte], [16byte, 32byte, ... 128byte], [256byte, ... 512byte], [768byte, ... 3840byte]
            - 大：[4KB, 8KB, ... 4072KB]
            - 巨大：[4MB, 8MB, ...]
            - 保存5KB的对象时，jemalloc可能会采用8KB的块，剩下的3KB成为内存碎片，不能再分配给其他对象存储。

        - 正常碎片率`mem_fragmentation_ratio` 在1.03左右

        - 高内存碎片的场景
            - 频繁对已存在的key执行`append`、`setrange`等更新命令
            - 大量过期key删除后，释放的空间无法充分利用，碎片率上升
            - 数据对齐：尽量采用数字类型或者固定长度的字符串等。但要根据业务而定，有些场景无法做到
            - 安全重启：重启节点可以做到内存碎片的重新整理
                - sentinel或cluster将碎片过高的主节点，转化为从节点，从而安全重启

- 开启了THP大内存页（2MB）机制，导致内存消耗

    - THP可以降低fork子进程的速度，但copy-on-wirte期间复制的内存页从4KB变为2MB，放大512倍，如果父进程有大量写命令，会造成过度的内存消耗

    - AOF重写期间的内存消耗日志，每秒写200条左右
    ```redis
    //开启THP：
    C * AOF rewrite: 1039 MB of memory used by copy-on-write
    //关闭THP：
    C * AOF rewrite: 9 MB of memory used by copy-on-write
    ```

    - 解决方法：
        - 1.关闭THP
        - 2.设置`sysctl vm.overcommit_memory=1`允许内核分配所有物理内存，防止fork期间写命令过多，导致内存不足而失败

#### 内存管理

- redis默认无限制使用内存，建议所有redis都设置`maxmemory`

    - 由于内存碎片的存在，实际的内存消耗大于`maxmemory`

    - 24GB的服务器，开4个redis，每个redis 4G内存（maxmemory 4GB），预留4G给其他进程或redis 的fork进程

        - 得益于单线程的架构，即使没有虚拟化，也可以实现cpu和内存的隔离性

        - 动态调整：当发现redis-2只用了2G，而redis-1需要扩容到6G才够用。
            ```redis
            redis-1>config set maxmemory 6GB
            redis-2>config set maxmemory 2GB
            ```

            - 如果此时redis-3和redis-4也需要扩容到6GB就超出了物理限制：

                - 解决方法：
                    - 1.需要在线迁移数据
                    - 2.复制切换服务器达到扩容

- 内存回收

    - 1.删除过期key：
        - 1.惰性删除：客户端读取过期的可以时，才删除。是节省cpu成本的考虑，不需要维护TTL链表来处理过期key。
            - 存在内存泄漏的问题：如果过期key一直没有访问，就无法释放

        - 2.定时任务删除：定时任务（默认每秒10次）`hz`参数控制。

            - 根据过期的可以的比例，使用快慢两种速率回收key
            ![avatar](./Pictures/redis/memory-recovery.avif)
                - 每个数据库空间随机检查20个key，发现过期时删除
                - 如果超过检查数量的25%的key，循环执行到不足25%或运行到超时为止
                - 如果之前回收key逻辑超时，则会以快模式运行回收

                - 快慢模式逻辑一样，只是超时时间不同
                    - 慢模式：25毫秒
                    - 快模式：1秒且2秒内只能运行1次

    - 2.超过`maxmemory`触发策略：

- 内存溢出策略：`maxmemory-policy`

    - [vivo互联网技术：深入解析Redis的LRU与LFU算法实现]()

        - LRU算法不会仅使用简单的队列或链表去缓存数据，而是会采用Hash表 + 双向链表的结构，利用Hash表确保数据查找的时间复杂度是O(1)，双向链表又可以使数据插入/删除等操作也是O(1)。

            ![avatar](./Pictures/redis/lru-lfu.avif)

            - LRU算法流程：
                - 1.向一个缓存空间依次插入三个数据A/B/C，填满了缓存空间；
                - 2.读取数据A一次，按照访问时间排序，数据A被移动到缓存头部；
                - 3.插入数据D的时候，由于缓存空间已满，触发了LRU的淘汰策略，数据B被移出，缓存空间只保留了D/A/C。

            - Redis内部只使用Hash表缓存了数据，并没有创建一个专门针对LRU算法的双向链表

            - redisObject对象保存着lru时钟的字段（默认的单位是秒），每次Key被访问或修改都会引起lru字段的更新

                - lru字段仅占用了24bit的空间，按秒为单位也只能存储194天，所以可能会出现一个意想不到的结果，即间隔194天访问Key后标记的时间戳一样，Redis LRU淘汰策略局部失效。

            - 缺点：仅关注数据的访问时间或访问顺序，忽略了访问次数的价值，在淘汰数据过程中可能会淘汰掉热点数据。

                ![avatar](./Pictures/redis/lru缺点.avif)

                - 时间轴自左向右，数据A/B/C在同一段时间内被分别访问的数次。数据C是最近一次访问的数据，按照LRU算法排列数据的热度是C>B>A，而数据的真实热度是B>A>C。

                - 为了解决这个问题衍生出来LFU算法。

        - LFU（Least frequently used）即最不频繁访问，其原理是：如果一个数据在近期被高频率地访问，那么在将来它被再访问的概率也会很高，而访问频率较低的数据将来很大概率不会再使用。

            - 与LRU一样，也采用Hash表 + 双向链表的结构，数据在双向链表内按照热度值排序。

            - LFU算法的实现没有使用额外的数据结构，复用了redisObject数据结构的lru字段，把这24bit空间拆分成两部分去使用。

                - 由于记录时间戳在空间被压缩到16bit，所以LFU改成以分钟为单位，大概45.5天会出现数值折返，比LRU时钟周期还短。

                - 低位的8bit用来记录热度值（counter），8bit空间最大值为255，无法记录数据在访问总次数。

            - 缺点：实际上，访问频率不能等同于访问次数，抛开访问时间谈访问次数就是在“耍流氓”。

                ![avatar](./Pictures/redis/lru缺点.avif)

                - 在这段时间片内数据A被访问了5次，数据B与C各被访问了4次，如果按照访问次数判断数据热度值，必然是A>B=C；如果考虑到时效性，距离当前时间越近的访问越有价值，那么数据热度值就应该是C>B>A。

        - LRU和LFU策略选择：

            - 如果业务数据的访问较为均匀，OPS或CPU利用率一般不会出现周期性的陡升或陡降，数据没有体现出相对的“冷热”特性，即建议采用LRU算法，可以满足一般的运维需求。

            - 相反，业务具备很强时效性，在活动推广或大促期间，业务某些数据会突然成为热点数据，监控上呈现出OPS或CPU利用率的大幅波动，为了能抓取热点数据便于后期的分析或优化，建议一定要配置成LFU算法。

    | 策略 | 算法 | key范围 | 描述                                                                       |
    |------|------|---------|----------------------------------------------------------------------------|
    | noeviction |  |  | 默认策略，不删除任何key，在进行写操作时返回错误信息。此时redis只进行读操作 |
    | volatile-lru    | LRU                                                                        | 设置了expire过期的key           | 删除直到有可用的内存，如果没有可删除的key，回退到noeviction |
    | allkeys-lru     | LRU                                                                        | 所有key                         | 删除直到有可用的内存                                        |
    | allkeys-random  | 随机删除一部分key                                                          | 所有key                         | 删除直到有可用的内存                                        |
    | volatile-random | 随机删除一部分key                                                          | 一部分设置了expire过期的key     | 删除直到有可用的内存                                        |
    | volatile-ttl    | 根据优先剩余时间(time to live TTL) 删除最短的key                           | 适用于设置了expire过期时间的key | 删除直到有可用的内存，如果没有可删除的key，回退到noeviction |
    | allkeys-lfu     | LFU                                                                        | 所有key                         | 删除直到有可用的内存，如果没有可删除的key，回退到noeviction |
    | volatile-lfu    | LFU                                                                        | 设置了expire过期时间的key       | 删除直到有可用的内存，如果没有可删除的key，回退到noeviction |

    - 可以调小`maxmemory`手动触发内存回收

    - 纯缓存的redis：建议设置`allkeys-lru`

    - `info stats`中的`evicted_keys`查询已经被删除的key的数量

    - 如果redis一直工作在内存溢出（used_memory > maxmemory），且设置了非noeviction策略时，会频繁的触发内存回收操作，影响性能（主要包含查询可回收key和删除key的开销）。

#### 内存优化

- 内存不足时，优先考虑内存优化；而不是水平拓展，遇到瓶颈时在做水平拓展，即使是cluster垂直层面的优化也很重要

- 缩减键值：

    - key长度：在完整描述业务情况下，越短越好

        - user:{uid}:friends:notify:{fid}可以简化为u:{uid}:fs:nt:{fid}

    - value长度：

        - 常见需求是把业务对象序列化成二进制数组

            - java内置的序列化压缩不尽人意，可以选择更高效的序列化工具

        - 通用格式如json、xml等。在内存紧张的情况下，可以压缩后再存入redis

- 共享对象池：redis维护一个[0-9999]的整数对象池。list、hash、set、zset的内部元素都可以使用这个对象池。因此尽量使用整数对象

    - 可以通过`object refcount {key}`查看引用数，来判断

    - 使用共享对象后内存使用减低30%以上

        | 操作      | 是否对象共享 | key大小 | value大小    | used_mem | used_memory_rss |
        |-----------|--------------|---------|--------------|----------|-----------------|
        | 插入200万 | 否           | 20字节  | [0-9999]整数 | 199.91MB | 205.28MB        |
        | 插入200万 | 是           | 20字节  | [0-9999]整数 | 138.87MB | 143.28MB        |

    - 当`maxmemory-policy`设置了LRU和LFU算法的策略，将无法使用共享对象池

        - 共享意味着redisObject对象中的lru字段也会被共享，导致无法获取对象的最后访问时间

    - `ziplist`编码的值对象，即使是整数，也无法使用共享对象池

        - ziplist使用压缩内存连续结构，共享判断成本过高

    - 为什么只有整数共享？
        - 整数的比较算法O(1)
        - 字符串的比较算法O(n)
        - hash、list等的比较算法O(n^2)

        - 对于单线程的redis来说，显然不合理

- 字符串优化

    - redis3.0之后key的值为字符串且长度<=39时，内部编码为embstr，字符串sds和redisObject只要1次内存分配

        - 建议字符串长度控制在39以下，减少创建redisObject内存分配次数

    - 预分配机制

        | 阶段 | 数据量 | 操作说明                        | 命令   | key大小 | value大小 | used_mem | used_memory_rss | mem_fragmentation_ratio |
        |------|--------|---------------------------------|--------|---------|-----------|----------|-----------------|-------------------------|
        | 1    | 200w   | 新插入200w数据                  | set    | 20字节  | 60字节    | 321.98MB | 311.44MB        | 1.02                    |
        | 2    | 200w   | 在阶段1基础上每个对象追加60字节 | append | 20字节  | 60字节    | 657.67MB | 752.80MB        | 1.14                    |
        | 3    | 200w   | 重新插入200w数据                | set    | 20字节  | 120字节   | 473.56MB | 482.56MB        | 1.02                    |

        ![avatar](./Pictures/redis/sds-append.avif)

        - 结果显示append后内存消耗严重：append后字符串对象预分配了1倍容量作为预留空间；而且大量追加操作需要内存重新分配，造成内存碎片率（mem_fragmentation_ratio）上升

            - 尽量减少字符串频繁修改命令如`append`、`setrange`，可以改为直接`set`来修改字符串


    - 字符串重构：不一定把每份数据作为字符串存储，像json这样的数据可以使用hash结构

        | 数据量 | key    | 存储类型 | value       | 配置                      | used_mem |
        |--------|--------|----------|-------------|---------------------------|----------|
        | 200W   | 20字节 | string   | json字符串  | 默认                      | 612.62MB |
        | 200W   | 20字节 | hash     | key-value对 | 默认                      | 1.88GB   |
        | 200W   | 20字节 | hash     | key-value对 | hash-max-ziplist-value:66 | 535.60MB |

        - 结果：第一次使用默认配置下的hash，内存非但没有降低，反而比string类型多出2倍

            - 调整`hash-max-ziplist-value=66`（默认值65）后使用ziplist编码，内存降低。因为json的其中一个属性长度是65，采用hashtable编码反而消耗了大量内存

- ziplist编码实现的类型耗时排序：list < hash < zset
- ziplist编码元素要控制在1000以内，不然存储时间就是O(n)到O(n^2)
- ziplist编码适合存储小对象，超过1KB的对象，反而得不偿失

- intset编码的集合：整数类型有3种int-16、int-32、int-64。因此元素尽量保持整数范围一致，如都在int-16范围内，防止个别元素触发集合升级，浪费内存

- 通过hash降低key的数量
    - 100万个key可以映射1000个hash，每个hash保存1000个元素
    - field设置原始key的字符串，方便哈希查找

        - key离散度较高时：可以按字符串位截断，后三位作为哈希的field，之前的部分作为hash的key
            - 例子：key=1948480 -> 哈希key=group:hash:1948, 哈希field=480

        - key离散度较低时：可以用哈希算法打散key
            - 例子：crc32(key) & 10000函数把key映射到0-9999的整数范围（共享对象），哈希field存储原始value

    - value设置原始key的value，确保不要超过`hash-max-ziplist-value`限制（即尽量使用ziplist编码）

    | 数据量 | key大小 | value大小 | string占用的内存 | hash-ziplist占用的内存 | 内存降低比例 | string:set耗时 | hash:hset耗时 |
    |--------|---------|-----------|------------------|------------------------|--------------|----------------|---------------|
    | 200w | 20字节 | 512字节 | 1392.64MB | 1000.97MB | 28.1% | 2.13微秒 | 21.28微秒 |
    | 200w | 20字节 | 200字节 | 596.62MB  | 399.38MB  | 33.1% | 1.49微秒 | 16.08微秒 |
    | 200w | 20字节 | 100字节 | 382.99MB  | 211.88MB  | 44.6% | 1.30微秒 | 14.92微秒 |
    | 200w | 20字节 | 50字节  | 291.46MB  | 110.32MB  | 62.1% | 1.28微秒 | 13.48微秒 |
    | 200w | 20字节 | 20字节  | 246.40MB  | 55.63MB   | 77.4% | 1.10微秒 | 13.21微秒 |
    | 200w | 20字节 | 5字节   | 199.93MB  | 24.42MB   | 87.7% | 1.10微秒 | 13.06微秒 |

    - hash-ziplist比string更节省内存。节省内存随着value的减少递增
    - hash-ziplist比string写入更耗时。但随着value的减少，耗时逐渐降低

### 处理bigkey

- [阿里开发者：一文详解Redis中BigKey、HotKey的发现与处理](https://developer.aliyun.com/article/788271?spm=a2c6h.14164896.0.0.2a3a303akyut8e)

- [vivo互联网技术：Bigkey问题的解决思路与方式探索]()

- 由于网络的一次传输 MTU 最大为 1500 字节，所以为了保证高效的性能，建议单个 k-v 大小不超过 1KB，一次网络传输就能完成，避免多次网络交互

- bigkey：key对应的value的占用内存较大

    - 字符串：最大可以512MB

        - string的value值超过1MB，就可以认为是Bigkey。

    - 列表：最大2^32-1个元素
        - 非字符串的类型，存储其实也是字符串。元素个数超过2000个，就可以认为是Bigkey。

    - STRING类型的Key，它的值为5MB（数据过大）

    - LIST类型的Key，它的列表数量为20000个（列表数量过多）

    - ZSET类型的Key，它的成员数量为10000个（成员数量过多）

    - HASH格式的Key，它的成员数量虽然只有1000个但这些成员的value总大小为100MB（成员体积过大）

- Bigkey是怎么产生的：程序设计不当或者对于数据规模预料不清楚造成的

    - 【统计】：遇到一个统计类的key，是记录某网站的访问用户的IP，随着时间的推移，网站访问的用户越来越多，这个key的元素数量也会越来越大，形成Bigkey。

    - 【队列】：把Redis当做队列使用，处理任务，如果消费出现不及时情况，将导致队列越来越大，形成Bigkey。

    - 【缓存】： 缓存失效，从数据库查询出来序列化放到Redis里，短时间内会缓存大量的数据到Redis的key中，形成Bigkey。

- 危害：

    > bigkey的存在并不是致命的，如果bigkey同时还是热点key，才是致命

    - 1.在cluster中内存使用不均匀（平衡）。不均匀会不利于cluster对内存的统一管理，有数据丢失风险。

        ![avatar](./Pictures/redis/bigkey1.avif)

        - 图中的三个节点是同属于一个集群，它们的key的数量比较接近，但内存容量相差比较多
        - 可以使用使用Daas平台“工具集-操作项管理”，选择对应的slave实例执行分析，找出具体的Bigkey。

    - 2.超时阻塞：redis的单线程，操作bigkey比较耗时会阻塞，导致客户端访问超时，更严重的会造成master-slave的故障切换。造成阻塞的操作不仅仅是业务程序的访问，还有key的自动过期的删除、del删除命令

        - 业务方反映程序访问Redis集群出现超时现象，hkeys访问Redis的平均响应时间在200毫秒左右，最大响应时间达到了500毫秒以上，如下图。

        ![avatar](./Pictures/redis/bigkey2.avif)

        - 1.使用Daas平台“服务监控-数据库实例监控”，选择master节点，选择Redis响应时间监控指标`redis.instance.latency.max`，如下图所示，从监控图中我们可以看到

            - (1).正常情况下，该实例的响应时间在0.1毫秒左右。

            - (2).监控指标上面有很多突刺，该实例的响应时间到了70毫秒左右，最大到了100毫秒左右，这种情况就是该实例会有100毫秒都在处理Bigkey的访问命令，不能处理其他命令。

            - 我们找到了具体的master实例，然后使用master实例的slave去分析下Bigkey情况。

            ![avatar](./Pictures/redis/bigkey3.avif)
            ![avatar](./Pictures/redis/bigkey4.avif)

        - 2.使用Daas平台“工具集-操作项管理”，选择slave实例执行分析，分析结果如下图，有一个hash类型key有12102218个fields。

            ![avatar](./Pictures/redis/bigkey5.avif)

            - 和业务沟通，这个Bigkey是连续存放了30天的业务数据了，建议根据二次hash方式拆分成多个key，也可把30天的数据根据分钟级别拆分成多个key，把每个key的元素数量控制在5000以内，目前业务正在排期优化中。优化后，监控指标的响应时间的突刺就会消失了。

    - 3.网络拥塞：假设bigkey为1MB，每秒访问1000次，就是1000MB流量，而千兆网卡才128MB/s
        - vivo的Redis服务器是采用单机多实例的方式来部署Redis实例的，也就是说一个Bigkey可能会对同一个服务器上的其他Redis集群实例造成影响，影响到其他的业务。

    - 4.迁移困难：

        - cluster水平扩容就会涉及到key的迁移。

            - (1).通过migrate命令来完成的，migrate实际上是通过dump + restore + del三个命令组合成原子命令完成，它在执行的时候会阻塞进行迁移的两个实例，直到以下任意结果发生才会释放：迁移成功，迁移失败，等待超时。
            - (2).如果key的迁移过程中遇到Bigkey，会长时间阻塞进行迁移的那两个实例，可能造成客户端阻塞，导致客户端访问超时；也可能迁移时间太长，造成迁移超时导致迁移失败，水平扩容失败。

            - vivo失败例子：一个Redis集群水平扩容的工单，需要进行key的迁移，当工单执行到60%的时候，迁移失败了。

                ![avatar](./Pictures/redis/bigkey6.avif)

                - 进入工单找到失败的实例，使用失败实例的slave节点，在Daas平台的“工具集-操作项管理”进行Bigkey分析。经过分析找出了hash类型的Bigkey有8421874个fields，正是这个Bigkey导致迁移时间太长，超过了迁移时间限制，导致工单失败了。

                ![avatar](./Pictures/redis/bigkey7.avif)

                - 和业务沟通，这些key是记录用户访问系统的某个功能模块的ip地址的，访问该功能模块的所有ip都会记录到给key里面，随着时间的积累，这个key变的越来越大。同样是采用拆分的方式进行优化，可以考虑按照时间日期维度来拆分，就是一段时间段的访问ip记录到一个key中。Bigkey优化后，扩容的工单可以重试，完成集群扩容操作。

        - vivo分析了Daas平台的水平扩容时迁移key的过程及影响参数

            - 1.`cluster-node-timeout`：控制集群的节点切换参数，master堵塞超过cluster-node-timeout/2这个时间，就会主观判定该节点下线pfail状态，如果迁移Bigkey阻塞时间超过cluster-node-timeout/2，就可能会导致master-slave发生切换。

                - 优化：默认是60秒，在迁移之前设置为15分钟，防止由于迁移Bigkey阻塞导致master-slave故障切换。

            - 2.`migrate timeout`：控制迁移io的超时时间，超过这个时间迁移没有完成，迁移就会中断。

                - 优化：每次重试的超时时间都是10秒，3次重试之间间隔30秒，这样最多只会连续阻塞Redis实例10秒。

            - 3.`迁移重试周期`：迁移的重试周期是由水平扩容的节点数决定的，比如一个集群扩容10个节点，迁移失败后的重试周期就是10次。

            - 4.`一个迁移重试周期内的重试次数`：在一个起迁移重试周期内，会有3次重试迁移，每一次的migrate timeout的时间分别是10秒、20秒、30秒，每次重试之间无间隔。

                - 例子：一个集群扩容10个节点，迁移时候遇到一个Bigkey，第一次迁移的migrate timeout是10秒，10秒后没有完成迁移，就会设置migrate timeout为20秒重试，如果再次失败，会设置migrate timeout为30秒重试，如果还是失败，程序会迁移其他新9个的节点，但是每次在迁移其他新的节点之前还会分别设置migrate timeout为10秒、20秒、30秒重试迁移那个迁移失败的Bigkey。这个重试过程，每个重试周期阻塞（10+20+30）秒，会重试10个周期，共阻塞600秒。其实后面的9个重试周期都是无用的，每次重试之间没有间隔，会连续阻塞了Redis实例。

                - 优化：迁移失败后，只重试3次，每次重试间隔30秒，重试3次后都失败了，会暂停迁移，日志记录下Bigkey，去掉了其他节点迁移的重试。

            - 5.`迁移失败日志`：迁移失败后，记录的日志没有包括迁移节点、solt、key信息，不能根据日志立即定位到问题key。

                - 优化：记录迁移失败的节点、solt、key信息，可以立即定位到问题节点及key。


- 发现bigkey

    - 开发人员对redis的理解不尽相同，bigkey的出现在所难免，重要的是能够通过合理机制发现它们。

    - `redis-cli --bigkeys`命令分析：

        - 优点：在于方便及安全
        - 缺点：分析结果不可定制化。只能计算每种数据结构的top1，无法只分析STRING类型或是找出全部成员数量超过10的HASH Key

        - Daas平台集成了基于原生--bigkeys代码实现的查询Bigkey的方式，

        ```sh
        # 获取bigkey(内部采用scan)。
        # bigkeys仅能分别输出Redis六种数据结构中的最大Key，
        redis-cli --bigkeys
        ```

    - 可以使用scan + debug object key计算每个key的serializedlength后，进行处理和报警

        ```redis
        # serializedlength属性代表编码序列化后的字节大小。值会比strlen key命令偏小
        debug object key
        ```
        ![avatar](./Pictures/redis/bigkey.avif)

        - 如果键比较多会比较慢，可以使用pipeline机制完成
        - 如果有从节点，建议在从节点完成

    - RDB文件分析：使用redis-rdb-tools工具以定制化方式找出bigKey

        - 分析RDB文件为离线工作，因此对线上服务不会有任何影响，这是它的最大优点但同时也是它的最大缺点：离线分析代表着分析结果的较差时效性。

        - 对于一个较大的RDB文件，它的分析可能会持续很久很久。

            - 建议在slave节点执行，因为生成RDB文件会影响节点性能。

        - Daas平台集成了基于RDB文件分析代码实现的查询Bigkey的方式，可以根据实际需求自定义填写N，分析的top N个Bigkey。该方式相对有一定风险，只有DBA有权限执行分析。

        - 提前解决，避免故障的发生，进行全网Bigkey的巡检：vivo的存储研发组分布式数据库同学计划开发一个高效的RDB解析工具，通过大规模解析RDB文件来分析Bigkey，可以提高分析速度，实现Bigkey的巡检。

- 解决方法：

    - 1.拆分复制数据结构：

        - big list：list1、list2、...listN
        - 如果是类似hash这样的二级数据结构，元素个数过多时，可以进行拆分为多个key，并分布到不同的redis节点上
        - 按照日期拆分多个：key20220310、key20220311、key202203212



    - 2.对失效数据进行定期清理：HASH结构中以增量的形式不断写入大量数据而忽略了这些数据的时效性，这些大量堆积的失效数据会造成大Key的产生

        - 建议使用HSCAN并配合HDEL对失效数据进行清理

    - 3.删除

        - 通常来说del bigkey会阻塞

        - del不同数据类型的耗时统计

            | 数据类型 | 512KB  | 1MB    | 2MB    | 5MB    | 10MB |
            |----------|--------|--------|--------|--------|------|
            | string   | 0.22ms | 0.31ms | 0.32ms | 0.56ms | 1ms  |

            | 数据类型   | 10万个元素（8个字节） | 100万个元素（8个字节） | 10万个元素（16个字节） | 100万个元素（16个字节） | 10万个元素（128个字节） | 100万个元素（128个字节） |
            |------------|-----------------------|------------------------|------------------------|-------------------------|-------------------------|--------------------------|
            | hash       | 51ms                  | 950ms                  | 58ms                   | 970ms                  | 96ms                    | 2000ms                   |
            | list       | 23ms                  | 134ms                  | 23ms                   | 138ms                  | 23                      | 266                      |
            | set        | 44ms                  | 873ms                  | 58ms                   | 881ms                  | 73ms                    | 1319ms                   |
            | sorted set | 51ms                  | 845ms                  | 57ms                   | 859ms                  | 59ms                    | 969ms                   |

            - 除了string外，其他类型的del速度很慢。使用sscan、hscan、zscan命令进行del，每次del 100个

        - redis4.0后支持lazy delete free模式：UNLINK命令，该命令能够以非阻塞的方式缓慢逐步的清理传入的Key

- vivo例子：

    - 全网Redis集群有2200个以上，实例数量达到4.5万以上，有的比较大的集群的实例数量达到了1000以上，在当前阶段进行一次全网 Bigkey检查，估计需要以年为时间单位，非常耗时。我们需要新的思路去解决Bigkey问题。

    - 可以从集群维度选择全部slave进行分析。

    - 同一个集群的相同服务器slave实例串行分析，不同服务器的slave实例并行分析，最大并发度默认10，同时可以分析10个实例，并且可以自定义输入执行分析的并发度。

    - 分析出符合Bigkey规定标准的所有key信息：大于1MB的string类型的所有key，如果不存在就列出最大的50个key；hash、list、set、zset等类型元素个数大于2000的所有key，如不存在就给出每种类型最大的50个key。

    - 增加暂停、重新开始、结束功能，暂停分析后可以重新开始。

### 寻找热点key

- 热门新闻事件或商品会给系统带来巨大的流量

- hotkey（热点key）：

    - 某Redis实例的每秒总访问量为10000，而其中一个Key的每秒访问量达到了7000（访问次数显著高于其它Key）

    - 对一个拥有上千个成员且总大小为1MB的HASH Key每秒发送大量的HGETALL（带宽占用显著高于其它Key）

    - 对一个拥有数万个成员的ZSET Key每秒发送大量的ZRANGE（CPU时间占用显著高于其它Key）

- 危害：

    - cluster为例，会造成整体流量不均衡，个别node出现ops过大的情况，甚至会超过所能承受的ops，造成缓存击穿，大量强求将直接指向后端存储将其打挂并影响到其它业务

- 发现热点key的方法：

    | 方法   | 优点                       | 缺点                                                                     |
    |--------|----------------------------|--------------------------------------------------------------------------|
    | 客户端 | 实现简单                   | 1.内存泄漏风险 2.维护成本高 3.只能统计单个客户端                         |
    | 代理端 | 实现最方便、最系统         | 增加代理端开发部署成本                                                   |
    | 服务端 | 实现简单                   | 1.monitor本身有危害（如输出缓冲区），只能在短时间使用 2.只能统计单个节点 |
    | 机器   | 对客户端和服务端无侵入影响 | 需要专业的运维团队开发，并且增加部署成本                                 |

    - 1.客户端：离key最近的地方

        - 设置全局字典（key的调用次数），每次执行命令，使用这个字典进行记录

    - 2.代理端：如推特开发的[twemproxy](https://github.com/twitter/twemproxy)、豌豆荚开发的[codis](https://github.com/CodisLabs/codis)这些基于代理redis的分布式架构，最适合作为热点key统计
        ![avatar](./Pictures/redis/hotkey-proxy.avif)

    - 3.服务端：

        ```sh
        # maxmemory-policy参数必须为LFU。返回所有Key的被访问次数，它的缺点同样为不可定制化输出报告
        redis-cli --hotkeys
        ```

        - 使用`monitor`命令进行统计

            - facebook开发的[redis-faina](https://github.com/facebookarchive/redis-faina)就是使用`            monitor`命令进行统计
            ```sh
            # 统计10万条命令的热点key
            redis-cli -p 6490 MONITOR | head -n 100000 | ./redis-faina.py
            ```

    - 4.机器：对机器上的tcp包进行抓取、分析，最终形成热点key统计。

        - 可以使用ELK体系下的packetbeat插件，实现对redis、mysql等主流服务进行抓包、分析、报表

- 解决热点key：

    - 1.拆分复制数据结构：如果是类似hash这样的二级数据结构，元素个数过多时，可以进行拆分为多个key，并分布到不同的redis节点上

    - 2.迁移热点key：cluster为例，热点key所在的slot，迁移到新的redis节点上

    - 3.本地缓存+通知机制：将热点key放在业务端的本地缓存。因为是业务端，处理速度比redis高出数十倍，当数据更新时，数据会不一致，可以使用发布订阅机制解决

### linux相关的性能配置

- `/proc/sys/vm/overcommit_memory` 调整申请内存是否允许overcommit：默认为0

    ```sh
    # redis启动时候打印的日志
    2980:M 15 Aug 2023 16:57:21.878 # WARNING Memory overcommit must be enabled! Without it, a background save or replication may fail under low memory condition. Being disabled, it can can also cause failures without low memory condition, see https://github.com/jemalloc/jemalloc/issues/1328. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
    ```

    - 上面日志表示：redis希望设置为1`sysctl vm.overcommit_memory=1`

        - 如果redis持久化fork子进程时，没有足够内存，就会失败。并输出以下日志
            ```redis
            Cannot allocate memory
            ```

- `vm.swapniess`：调整文件页和匿名页的回收倾向

    - 要避免redis死掉；相反如果redis是高可用，死掉比阻塞更好

    | 值  | 策略                                                                           |
    |-----|--------------------------------------------------------------------------------|
    | 0   | linux3.5以上：宁愿oom killer也不用swap；linux3.4以下：宁愿swap也不用oom killer |
    | 1   | linux3.5以上：宁愿swap也不用oom killer                                         |
    | 60  | 默认值                                                                         |
    | 100 | 操作系统主动使用swap                                                           |

    ```sh
    # 数值为0-100（默认为60）。越大越积极回收匿名页；越小越积极回收文件页，因此一般建议设置为0，但是并不代表不会回收匿名页。
    cat /proc/sys/vm/swappiness
    60
    ```

    ```sh
    # 查看swap的使用量
    free -h

    # 实时查看swap的使用。si和so表示swap in swap on
    dstat --vmstat 1

    # 查看redis进程的swap使用情况，求和可以得出总的swap量
    cat /proc/$(pidof redis-server)/smaps | grep -i swap
    ```

- oom killer：oom killer进程回味每个用户进程设置一个权值，越高被“下手”的几率就越高。不同linux版本默认值不一样，我这里为0

    - 要避免redis死掉；相反如果redis是高可用，死掉比阻塞更好

    ```sh
    # 设置最小值时（-15到-17），表示该进程不会被oom killer杀掉
    echo -17 > /proc/$(pidof redis-server)/oom_adj
    ```

- linux kernel的Transparent Huge Pages（THP）大内存页（2MB）功能（默认开启）

    - 可以减少fork的时间，但会增加父进程创建内存页副本的消耗。从4KB变为2MB，每次写命令引起的复制内存页放大了512倍，拖慢写操作的时间，导致写操作慢查询
    ```sh
    # 关闭THP
    echo never > /sys/kernel/mm/transparent_hugepage/enabled
    ```

- 使用NTP时间同步服务：像sentinel和cluster需要多个node。如果node时间不一致，对于异常情况的日志排查是非常困难的。

    ```sh
    # 在cron每小时同步一次
    0 * * * * /usr/sbin/ntpdate ntp.xx.com > /dev/null 2>&1
    ```

- ulimit中的打开文件描述符的数量：redis可以设置`maxclients`来限制客户端连接，对于linux来说这些连接都是文件描述符（默认为1024）。
    - redis建议至少设置为10032。因为`maxclients`默认为10000，此外redis内部会使用32个文件描述符，所以总共10000 + 32 = 10032

    ```sh
    # 查看所有配额限制
    ulimit -a

    # 设置文件描述符数量为10032
    ulimit -Sn 10032
    ```

- tcp-backlog（tcp三次握手中的accept 全连接队列长度）：

- redis默认的tcp-backlog为511：低于此值时redis启动时会显示
    ```
    8625:M 15 Aug 2023 17:45:44.106 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 510.
    ```

    ```sh
    # 查看
    cat /proc/sys/net/core/somaxconn

    # 设置
    echo 511 > /proc/sys/net/core/somaxconn
    ```

### 监控

- 输出缓冲区：在大流量场景很容易失控，造成redis内存的不稳定

#### [cachecloud](https://github.com/sohutv/cachecloud)

- [安装文档](https://github.com/sohutv/cachecloud/blob/main/cachecloud-web/src/main/resources/static/wiki/quickstart/index.md)

#### Grafana

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

## 缓存（cache）

- 大部分的流量实际上都是读请求，而且大部分数据也是没有那么多变化的，如热门商品信息、微博的内容等常见数据就是如此。此时，缓存就是我们应对此类场景的利器。

- 业务的数据——例如订单、会员、支付等——都是持久化到数据库中的，因为数据库能有很好的事务保证、持久化保证。

    - 使得数据库在设计上通常难以兼顾到性能，因此往往不能满足大型流量下的性能要求，像是 MySQL 数据库只能承担“千”这个级别的 QPS，否则很可能会不稳定，进而导致整个系统的故障。而redis可以做到100000QPS

- 缓存的收益与成本：
    - 收益：
        - 1.加速读写：因为缓存是全内存，优化用户体验
        - 2.降低后端负载：减少后端的访问量、计算量

    - 成本：
        - 1.数据不一致：存在着一定窗口期的不一致性。时间窗口跟更新策略相关
        - 2.代码运维成本：要同时处理缓存和存储的逻辑
        - 3.运维成本：特别是redis cluster

- 3种更新策略：

    | 策略                 | 一致性 | 维护成本 |
    |----------------------|--------|----------|
    | LRU/LFU/FIFO算法剔除 | 最差   | 最低     |
    | 超市剔除             | 较差   | 较低     |
    | 主动更新             | 强     | 高       |

    - 1.LRU/LFU/FIFO算法剔除：超过`maxmemory-policy`内存最大值时启用

    - 2.超市剔除：设置过期时间，过期后自动删除。

        - 可以容忍一段时间的数据不一致

            - 例子：视频的描述信息，可以容忍几分钟。但如果是交易方面的业务就不行

    - 3.主动更新：真实数据更新后，立即更新缓存

- 缓存粒度：

    - 假设用户表有100个列，需要缓存的什么粒度呢？
        - 缓存全部列：
        ```
        set user:(id) 'select * from user where id = {id}'
        ```

        - 缓存部分列：
        ```
        set user:(id) 'select {importColumn1}, {importColumn2}, {importColumn3} from user where id = {id}'
        ```

        | 缓存粒度 | 通用性 | 空间占用（内存空间+网络带宽） | 代码维护 |
        |----------|--------|-------------------------------|----------|
        | 全部数据 | 高     | 大                            | 简单     |
        | 部分数据 | 低     | 小                            | 较为复杂 |

### 缓存穿透、缓存雪崩、缓存击穿

- [刘Java：Redis的缓存穿透、缓存雪崩、缓存击穿问题的概念与解决办法](https://juejin.cn/post/7111680002508193805)

- 缓存穿透：查询一个在缓存和数据库中一定不存在的数据。导致每次查询都会去请求数据库

    - 问题：如果有恶意用户，就可以利用这个漏洞，模拟请求很多缓存和数据库中不存在的数据，比如传递负数 id，导致这些请求短时间内直接落在了数据库上

    - 解决方法

        - 1.业务层的代码中做好数据校验：自增 ID 肯定是不能为负数的，对于一些很直观的异常请求执行进行拦截。

            - 这一点说起来简单，但是却需要开发者足够的细心，考虑的情况要足够全面，很多小公司的参数是没有进行类似的校验的。

        | 解决缓存穿透 | 适用场景                  | 维护成本                             |
        |--------------|---------------------------|--------------------------------------|
        | 缓存空对象   | 1.命中不高 2.数据频繁变化 | 1.简单 2.需要过度的空间 3.数据不一致 |
        | 布隆过滤器   | 1.命中不高 2.数据相对固定 | 1.复杂 2.需要过度的空间              |

        - 2.缓存空值：如果在缓存和数据库都取不到，则将不存在的结果也存入缓存，可以是空字符串或者空对象。并且设定较短的的缓存过期时间，比如设置为 30 秒。这个方法有2个问题

            - 1.需要更多的内存：如果某个攻击者在短时间内恶意制造大量不存在的不同的 id，那么缓存中会有很多无效数据，内存很可能会被打爆

                - 解决方法：对请求的 IP 进行限制。真正用户不会在短时间内发起这么多的请求。限制同一个 IP 在一定时间内对某个接口最多发起多少次请求，超出的请求直接拦截，或者直接将 IP 放入黑名单，限制所有请求，这一点 Nginx、API 网关、Redis 或者其他中间件都能做到。

            - 2.如果对空值设置了过期时间，那么可能会存在缓存层和存储层的数据会有一段时间的不一致的情况，这对于需要保持强一致性的业务会有影响。

        - 3.使用 [Redis 的布隆过滤器（Bloom Filter）](https://github.com/RedisBloom/RedisBloom)，概率性数据结构，快速的判某个 key 是否存在。

            ![avatar](./Pictures/redis/cache-bloomfilter.avif)

            - 当用户请求过来，先判断用户发来的请求的值是否存在于布隆过滤器中，不存在就直接 return，存在时才会走真正的查缓存和数据库的逻辑。

            - Bloom Filter 常被用来解决缓存穿透的问题，或者网页黑名单系统、垃圾邮件过滤系统、爬虫网址判重系统等大量数据并且允许一定误差的系统。

            - 问题：有一定的误识别率和删除困难

- 缓存雪崩：大量缓存集中在一段时间内失效，发生大量的缓存穿透

    - 1.大量的缓存被同时设置或者刷新，并且缓存的失效时间相同。

        - 解决方法：设置缓存超时时间的时候加上一个随机的时间长度，比如这个缓存 key 的超时时间是固定的 5 分钟加上随机的 2 分钟

    - 2.缓存层不致命原因不能提供服务：

        - 解决方法：保证高可用。就像飞机有多个引擎一样。即使个别节点、个别机器、整个机房出现问题，依然可以提供服务。可以使用sentinel和cluster实现

    - 3.并发量较大的系统，假如有一个资源不可用，可能造成现场全部阻塞在这个资源上，造成系统不可用。

        - 解决方法：服务降级。对重要资源（redis、mysql、hbase、外部接口）进行隔离，让每个资源都单独运行在自己的线程池，即使个别出问题，对其他服务也不造成影响。

            - java的[Hystrix](https://github.com/Netflix/Hystrix)是隔离利器

            - 降级机制在高并发系统非常普遍，如推荐服务中的个性化推荐不可用，可以降级补充热点数据，不至于造成前端页面开天窗。


- 缓存击穿：热点key（大并发集中对这一个点进行访问），当这个 Key 在失效的瞬间，持续的大并发线程就穿破缓存，直接请求数据库，造成数据库宕机。

    - 解决方法：

        | 解决方法     | 优点             | 缺点                                                 |
        |--------------|------------------|------------------------------------------------------|
        | 分布式互诉锁 | 简单；保证一致性 | 代码复杂度大；存在死锁风险；存在线程池阻塞风险       |
        | 永不过期     | 基本杜绝问题     | 不保证一致性；逻辑过期时间增加代码维护成本和内存成本 |

        - 1.互诉锁（mutex）减少重建缓存次数：先从缓存中尝试获取，如果没有那么再尝试获取锁，获取到锁之后，再次尝试从缓存中获取，如果获取到了就直接返回，如果没有获取到就查库，然后设置到缓存中再返回

            ![avatar](./Pictures/redis/cache-non-mutex.avif)

            ![avatar](./Pictures/redis/cache-mutex.avif)

            - 使用`setnx`命令
                - 结果为true时：表示没有其他线程重建缓存
                - 结果为false时：表示已经有其他线程正在重建缓存，可以指定当前线程休息（比如50毫米），在重新执行函数，直到获取数据

        - 2.对于热点数据直接设置永远不过期，有更新操作就更新缓存就好了。

            - 可以设置“逻辑”的过期时间（从redis缓存角度来看确实没有设置过期时间）。超过逻辑时间后，是使用单独的线程构建缓存。
                - 缺点：重构缓存期间，会出现数据不一致。取决于应用方是否能容忍

                ![avatar](./Pictures/redis/cache-timeout.avif)

- 缓存预热：系统上线后，将相关的缓存数据直接加载到缓存系统中。避免了系统刚上线的时候，在用户请求的时候，先查询数据库，然后再将数据缓存导致数据库压力大的问题

    - 在更新完数据库之后，再 sleep 一段时间，然后再次删除缓存。

        - sleep 时间要考虑大于另一个请求读取数据库旧数据 + 写缓存的时间，以及如果有 redis 主从同步、数据库分库分表，还要考虑数据同步的耗时，在 Sleep 之后再次尝试删除缓存（无论新的还是旧的）。

- 无底洞优化：更多的节点不代表更高的性能

    - 例子：2010年，facebook的memcache已经有3000个节点了，承载着TB级别的缓存。但为了满足业务继续添加了新节点。但是发现性能非但没有好转反而下降了。这种现象叫：缓存无底洞现象

        - 大量新节点，造成水平扩容，导致键值分布到更多的节点上，因此`mget`等分布式批量操作命令，需要访问更多的的节点和网络往返时间，相比之下单机只需要1次网络往返

    - 优化：
        - 1.命令本身的优化：如sql语句等
        - 2.客户端连接：使用长连接、连接池、NIO（非阻塞IO）等
        - 3.降低网络通信的次数

        - 以下假设前两点已经优化好了，重点看待第3点。对比有4种实现方法：

            | 方法     | 优点                             | 缺点                           | 网络IO的时间复杂度 |
            |----------|----------------------------------|--------------------------------|--------------------|
            | 串行命令 | 实现简单；少量key，性能可以满足  | 大量的key延迟严重              | O(keys)           |
            | 串行IO   | 实现简单；少量节点，性能可以满足 | 大量的node延迟严重             | O(nodes)          |
            | 并行IO   | 延迟取决于最慢的node             | 实现复杂；由于多线程，定位麻烦 | O(max_slow(node)) |
            | hash_tag | 性能最高                         | 维护成本高；容易出现数据倾斜   | O(1)              |

            - 1.串行命令：client n次get：n次网络 + n次get命令

                ![avatar](./Pictures/redis/cache-串行命令.avif)

                - 在redis cluster无法使用`mget`命令，最简单的方法就是逐个`get`，时间复杂度

            - 2.串行IO：client 1次pipeline get：1次网络 + n次get命令

                ![avatar](./Pictures/redis/cache-串行IO.avif)

                - Smart客户端会保存slot和节点的关系，得到每个节点的key子列表，之后对节点执行`mget`或者pipeline操作：操作时间 = node次网络时间 + n次命令

            - 3.并行IO：根据方法2基础上，加入多线程执行，由于多线程网络时间为O(1)，所以max_slow(node网络时间) + n次命令时间

                ![avatar](./Pictures/redis/cache-并行IO.avif)

            - 4.hash_tag实现：cluster的hash_tag可以强制将多个key分配到1个node上

                - 操作时间 = 1次网络时间 + n次命令时间

                ![avatar](./Pictures/redis/cache-hash_tag.avif)

### 缓存一致性问题

- [腾讯技术工程：认识 MySQL 和 Redis 的数据一致性问题](https://cloud.tencent.com/developer/article/1898550)

- [腾讯技术工程：万字图文讲透数据库缓存一致性问题](https://cloud.tencent.com/developer/article/2168718)

#### 最终一致性策略

- 缓存不一致性的问题无法在客观上完全消灭，因为我们无法保证数据库和缓存的操作是一个事务里的，而我们能做到的只是尽量缩短不一致的时间窗口。

- 结论：

    - 一般推荐使用 “更新数据库 + 删除缓存” 的方案。如果根据需要，热点数据较多，可以使用 “更新数据库 + 更新缓存” 策略。

    - “更新数据库 + 删除缓存” 中：优先使用先更新数据库，再删除缓存，原因主要有两个：

        - 先删除缓存值再更新数据库策略：
            - 1.有可能导致请求因缓存缺失而访问数据库，给数据库带来压力
            - 2.延迟双删中的 sleep 时间不好设置。

        - “更新数据库 + 更新缓存” 策略：在高并发情况下，有数据不一致问题

    - 包括Facebook的论文《Scaling Memcache at Facebook》也使用了这个策略。

- 只读缓存：只在缓存进行数据查找，即使用 “更新数据库+删除缓存” 策略

    - 无并发情况：有两步操作：更新数据库+删除缓存值

        - 单线程中步骤 1 和步骤 2 是串行执行的：
            - 可能存在“步骤 1 成功，步骤 2 失败” 的情况
            - 不太可能会发生 “步骤 2 成功，步骤 1 失败” 的情况

        | 执行顺序                 | 步骤1成功，步骤2失败的最后结果   | 是否存在一致性问题 |
        |--------------------------|----------------------------------|--------------------|
        | 先删除缓存，再更新数据库 | 请求无法命中缓存，读取数据库旧值 | 是                 |
        | 先更新数据库，再删除缓存 | 请求命中缓存，读取缓存旧值       | 是                 |

        - 1.先删除缓存，再更新数据库
        ![avatar](./Pictures/redis/cache-consistency-onlyread.avif)

        - 2.先更新数据库，再删除缓存
        ![avatar](./Pictures/redis/cache-consistency-onlyread1.avif)

        - 解决方法：

            - 1.消息队列+异步重试：无论使用哪一种执行时序，可以在执行步骤 1 时，将步骤 2 的请求写入消息队列，当步骤 2 失败时，就可以使用重试策略，对失败操作进行 “补偿”。
            ![avatar](./Pictures/redis/cache-consistency-onlyread2.avif)

                - 1.把要删除缓存值或者是要更新数据库值操作生成消息，暂存到消息队列中（例如使用 Kafka 消息队列）
                - 2.操作成功时：把这些消息从消息队列中去除（丢弃），以免重复操作
                    - 操作失败时：重试服务从消息队列中重新读取（消费）这些消息，然后再次进行删除或更新，重试超过的一定次数，向业务层发送报错信息。

            - 2.通过 Binlog 变更日志，使用MQ/Canal 或者 MQ+Canal 的策略来异步更新缓存：

                - Canal策略：即将负责更新缓存的服务伪装成一个 MySQL 的从节点，从 MySQL 接收 Binlog，解析 Binlog 之后，得到实时的数据变更信息，然后根据变更信息去更新/删除 Redis 缓存

                - MQ+Canal 策略：将 Canal Server 接收到的 Binlog 数据直接投递到 MQ 进行解耦，使用 MQ 异步消费 Binlog 日志，以此进行数据同步
                ![avatar](./Pictures/redis/cache-consistency-canal.avif)

    - 高并发情况（以上策略后，可以保证在单线程/无并发场景下的数据一致性。但是，在高并发场景下，由于数据库层面的读写并发，会引发的数据库与缓存数据不一致的问题）：

        - 1.先删除缓存，再更新数据库

            - 有可能导致请求因缓存缺失而访问数据库，给数据库带来压力，也就是缓存穿透的问题。针对缓存穿透问题，可以用缓存空结果、布隆过滤器进行解决。

            - 例子：现在缓存和数据库都是100，这时候需要对此计数减1，减成功后。那么数据库和缓存都是99才能满足数据一致性

            | 时间 | 线程 A | 线程 B                   | 问题            |
            |----|--------------|-------------------------------------|--------------------------|
            | T1 | 删除缓存     |                                     |                          |
            | T2 |              | 读取缓存，缓存丢失，从数据库读取100 | 线程B读取到旧值          |
            | T3 |              | 更新缓存100                         |                          |
            | T4 | 更新数据库99 |                                     | 缓存是100，数据库是99 |

            或者

            | 时间 | 线程 A | 线程 B                   | 问题            |
            |----|--------------|-------------------------------------|--------------------------|
            | T1 | 删除缓存     |                                     |                          |
            | T2 |              | 读取缓存，缓存丢失，从数据库读取100 | 线程B读取到旧值          |
            | T3 | 更新数据库99 |                                     |                          |
            | T4 |              | 更新缓存100                         | 缓存是旧值，数据库是新值 |

            - 解决方法：

                - 1.设置缓存过期时间：缓存过期后，读请求仍然可以从 DB 中读取最新数据并更新缓存，可减小数据不一致的影响范围。

                - 2.延时双删：在线程 A 更新完数据库值以后，让它先 sleep 一小段时间，确保线程 B 能够先从数据库读取数据，再把缺失的数据写入缓存，然后，线程 A 再进行删除。后续，其它线程读取数据时，发现缓存缺失，会从数据库中读取最新值。

                    - sleep 时间：在业务程序运行的时候，统计下线程读数据和写缓存的操作时间，以此为基础来进行估算：
                        - 可以使用延时队列进行替代代替sleep

                    ```
                    redis.delKey(X)
                    db.update(X)
                    Thread.sleep(N)
                    redis.delKey(X)
                    ```

                    | 时间 | 线程 A（写请求） | 线程 C（新的读请求）         | 线程 D（新的读请求）                     | 问题                               |
                    |------|------------------|------------------------------|------------------------------------------|------------------------------------|
                    | T5 | sleep(N)   | 缓存存在，读取到缓存旧值 100 |                                          | 其他线程可能在双删成功前读到脏数据 |
                    | T6 | 删除缓存值 |                              |                                          |
                    | T7 |            |                              | 缓存缺失，从数据库读取数据的最新值（99） |                                    |

        - 2.先更新数据库，再删除缓存

            | 时间 | 线程 A（写请求）                | 线程 B（读请求） | 线程 C（读请求） | 潜在问题 |
            |----|---------------------------------|---------------------------------------------|----------------------------------------|----------------------|
            | T1 | 更新主库 X = 99（原值 X = 100） |                                             |                                        |                      |
            | T2 |                                 |                                             | 读取缓存值100 | 线程 C 读取了旧值100 |
            | T3 | 删除缓存                        |                                             |
            | T4 |                                 | 查询缓存，缓存缺失，查询数据库得到当前值 99 |                                        |
            | T5 |                                 | 将 99 写入缓存                              |                                        |

            - 在更新数据库后删除缓存这个场景下，不一致窗口仅仅是 T2 到 T3 的时间，内网状态下通常不过 1ms

            - 但是真实场景下，还是会有一个情况存在不一致的可能性，这个场景是读线程发现缓存不存在，于是读写并发时，读线程回写进去老值：

                - 这个不一致场景出现条件非常严格，因为并发量很大时，缓存不太可能不存在；如果并发很大，而缓存真的不存在，那么很可能是这时的写场景很多，因为写场景会删除缓存。

                | 时间 | 线程 A（写请求）                | 线程 B（读请求--缓存不存在场景）             | 潜在问题        |
                |----|---------------------------------|----------------------------------------------|-------------------------|
                | T1 |                                 | 查询缓存，缓存缺失，查询数据库得到当前值 100 |                         |
                | T2 | 更新主库 X = 99（原值 X = 100） |                                              |                         |
                | T3 | 删除缓存                        |                                              |                         |
                | T4 |                                 | 将 100 写入缓存                              | 缓存值100，数据库值是99 |

            - “读写分离 + 主从库延迟”也会导致不一致：

                | 时间 | 线程 A（写请求）                | 线程 B（读请求）                          | MYSQL集群           | 潜在问题                        |
                |------|---------------------------------|-------------------------------------------|---------------------|---------------------------------|
                | T1   | 更新主库 X = 99（原值 X = 100） |                                           |                     |
                | T2   | 删除缓存                        |                                           |                     |
                | T3   |                                 | 查询缓存，缓存失效，读取从库，得到旧值100 |                     |
                | T4   |                                 | 更新缓存100                               |                     |
                | T5   |                                 |                                           | 从库完成同步X值为99 | 缓存值是旧值100，主从库为新值99 |

            - 解决方法：
                - 1.sleep或者发送「延迟消息」到队列中：延迟删除缓存，同时也要控制主从库延迟
                - 2.通过binlog，异步删除：canal将 binlog 日志采集发送到 MQ 中，然后通过 ACK 机制确认处理删除缓存。
                - 3.加锁（保证两步操作的“原子性”）：更新数据时，加写锁；查询数据时，加读锁
                ![avatar](./Pictures/redis/cache-consistency-lock.avif)

- 读写缓存：更新数据库+更新缓存

    - 同步直写：使用事务，保证缓存和数据更新的原子性，并进行失败重试（如果 Redis 本身出现故障，会降低服务的性能和可用性）

    - 异步回写：写缓存时不同步写数据库，等到数据从缓存中淘汰时，再写回数据库（没写回数据库前，缓存发生故障，会造成数据丢失） 该策略在秒杀场中有见到过，业务层直接对缓存中的秒杀商品库存信息进行操作，一段时间后再回写数据库。

    - 无并发情况：

        | 执行顺序                 | 步骤1成功，步骤2失败的最后结果 | 是否存在一致性问题 | 解决方法          |
        |--------------------------|--------------------------------|--------------------|-------------------|
        | 先更新缓存，再更新数据库 | 数据库为旧值               | 是 | 消息队列+重试机制 |
        | 先更新数据库，再更新缓存 | 请求命中缓存，读取缓存旧值 | 是 | 消息队列+重试机制 |

    - 高并发情况：

        | 策略                | 并发场景                                                                         | 潜在问题                                               | 应对方案 |
        |---------------------|----------------------------------------------------------------------------------|--------------------------------------------------------|----------|
        | 先更新数据库，再更新缓存 | 写+读 | 线程 A 未更新完缓存之前，线程 B 的读请求会短暂读到旧值                           | 可以忽略           |
        | 先更新缓存，再更新数据库 | 写+读 | 线程 A 未更新完数据库之前，线程 B 的读新值，只存在短暂的不一致                   | 可以忽略           |
        | 先更新数据库，再更新缓存 | 写+写 | 更新数据库的顺序是先 A 后 B，但更新缓存时顺序是先 B 后 A，数据库和缓存数据不一致 | 分布式锁（操作重） |
        | 先更新缓存，再更新数据库 | 写+写 | 更新缓存的顺序是先 A 后 B，但更新数据库时顺序是先 B 后 A，数据库和缓存数据不一致 | 分布式锁（操作重） |  |  | 分布式锁（操作重） |

        - 分布式锁：保证同一时间只有一个线程去更新数据库和缓存；没有拿到锁的线程把操作放入到队列中，延时处理。

            | 分布式锁策略       | 实现原理                                                                              |
            |--------------------|---------------------------------------------------------------------------------------|
            | 乐观锁             | 版本号，updatetime；只允许高版本覆盖低版本                                            |
            | redis的watch乐观锁 | key修改过，则回滚                                                                     |
            | setnx              | 获取锁：set/setnx；释放锁：del命令/lua脚本                                            |
            | redisson分布式锁   | 利用hash类型，将业务名称作为key，使用随机的uuid或线程id作为field，加锁的次数作为value；线程安全 |

#### 强一致性策略

- 上述策略只能保证数据的最终一致性。

- 强一致性，最常见的方案是 2PC、3PC、Paxos、Raft 这类一致性协议

    - 但它们的性能往往比较差，而且这些方案也比较复杂，还要考虑各种容错问题。如果业务层要求必须读取数据的强一致性，可以采取以下策略：

        - 1.暂存并发读请求：在更新数据库时，先在 Redis 缓存客户端暂存并发读请求，等数据库更新完、缓存值删除后，再读取数据，从而保证数据一致性。

        - 2.串行化：读写请求入队列，工作线程从队列中取任务来依次执行

            - 1.修改服务 Service 连接池：id 取模选取服务连接，能够保证同一个数据的读写都落在同一个后端服务上
            - 2.修改数据库 DB 连接池：id 取模选取 DB 连接，能够保证同一个数据的读写在数据库层面是串行的

        - 3.分布式读写锁：将淘汰缓存与更新库表放入同一把写锁中，与其它读请求互斥，防止其间产生旧数据。

### 如何减少缓存删除/更新的失败？

- 删除缓存这一步因为服务重启没有执行，或者 Redis 临时不可用导致删除缓存失败了，就会有一个较长的时间（缓存的剩余过期时间）是数据不一致的。

    - 把删除 Redis 的请求以消费 MQ 消息的手段去失效对应的 Key 值，如果 Redis 真的存在异常导致无法删除成功，我们依旧可以依靠 MQ 的重试机制来让最终 Redis 对应的 Key 失效。
        ![avatar](./Pictures/redis/cache-consistency-mq.avif)

        - 极端场景下，是否存在更新数据库后 MQ 消息没发送成功，或者没机会发送出去机器就重启的情况？

            - 1.如果 MQ 使用的是 RocketMQ，我们可以借助 RocketMQ 的事务消息，来让删除缓存的消息最终一定发送出去。

            - 2.如果使用的消息中间件并没有事务消息的特性：则可以采取消息表的方式让更新数据库和发送消息一起成功。

### 如何处理复杂的多缓存场景？

- 真实的缓存场景

    - 1.并不是数据库中的一个记录对应一个 Key 这么简单，有可能一个数据库记录的更新会牵扯到多个 Key 的更新。

    - 2.另外一个场景是，更新不同的数据库的记录时可能需要更新同一个 Key 值，这常见于一些 App 首页数据的缓存。

- 以一个数据库记录对应多个 Key 的场景来举例：缓存了一个粉丝的主页信息、主播打赏榜 TOP10 的粉丝、单日 TOP 100 的粉丝等多个信息。如果这个粉丝注销了，或者这个粉丝触发了打赏的行为，上面多个 Key 可能都需要更新。

    ```
    updateMySQL();//更新数据库一条记录
    deleteRedisKey1();//失效主页信息的缓存
    updateRedisKey2();//更新打赏榜TOP10
    deleteRedisKey3();//更新单日打赏榜TOP100
    ```

    - 涉及多个 Redis 的操作，每一步都可能失败，影响到后面的更新。

        - 甚至从系统设计上，更新数据库可能是单独的一个服务，而这几个不同的 Key 的缓存维护却在不同的 3 个微服务中

        - 最可怕的是，操作更新记录的地方很大概率不只在一个业务逻辑中，而是散发在系统各个零散的位置。

    - 解决方法：更新缓存的操作以 MQ 消息的方式发送出去，由不同的系统或者专门的一个系统进行订阅，而做聚合的操作。

        - 不同业务系统订阅 MQ 消息单独维护各自的缓存 Key
        ![avatar](./Pictures/redis/cache-consistency-mutlikey.avif)

        - 专门更新缓存的服务订阅 MQ 消息维护所有相关 Key 的缓存操作
        ![avatar](./Pictures/redis/cache-consistency-mutlikey1.avif)

# k8s

- [字节跳动技术团队：火山引擎 Redis 云原生实践]()

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

# 其他版本的redis

## 阿里云的[Tair](https://github.com/alibaba/tair)

- TairHash是一种可为field设置过期时间和版本的hash

    - 使用高效的Active Expire算法，实现了在对响应时间几乎无影响的前提下，高效完成对field过期判断和删除的功能。

- [ 阿里云瑶池数据库：好好的 Tair 排行榜不用，非得自己写？20 行代码实现高性能排行榜]()
    - 通过TairZset实现分布式排行榜
    - 通过TairZset实现实时、小时、日、周和月维度的排行榜

## 腾讯云的[Tendis](https://github.com/Tencent/Tendis)

- [朱小厮的博客：腾讯的Tendis能否干掉Redis，用了什么牛逼的技术呢？]()

- 3种版本：

    - 缓存版：适用于对延迟要求特别敏感, 并且对 QPS 要求很高的业务。基于社区 Redis 4.0 版本进行定制开发。
    - 存储版：适用于大容量, 延迟不敏感型业务, 数据全部存储在 磁盘, 适合温冷数据的存储。使用 RocksDB 作为底层存储引擎。
    - 冷热混合存储版：综合了缓存版和存储版的优点, 缓存层存放热数据, 全量数据存放在存储层。
        - 同步层 Redis-sync 模拟 Redis Slave 的行为, 接收 RDB 和 Aof, 然后并行地导入到存储层 Tendis。

    ![avatar](./Pictures/redis/tendis.avif)

- 冷热混合存储版

    ![avatar](./Pictures/redis/tendis-冷热混合存储版.avif)

    - 缓存层 Redis 存储全量的 Keys 和热 Values(All Keys + Hot values), 存储层 Tendis 存储全量的 Keys 和 Values(All Keys + All values)。

    - 版本控制：每个 Key 和 每条 Aof 增加一个 Version，单调递增

        - 增量 RDB：

            - 主从在断线重连后, 如果 slave 发送的 psync_offset 对应的数据不在当前的 Master 的 repl_backlog 中, 则主备需要重新进行全量同步。

            - 引入 Version 之后, slave 断线重连, 给 Master 发送 带 Version 的 PSYNC replid psync_offset version命令。如果出现上述情况, Master 将大于等于 Version 的数据生成增量 RDB, 发给 Slave, 进而解决需要增量, 同步比较慢的问题。

    - Key 降冷：

        - 放弃了 Redis 缓存全量 Keys 的方案。使用Cuckoo Filter来解决缓存击穿和缓存穿透

            - Cuckoo Filter（布谷鸟过滤器）：可以删除并且误判率更高的布隆过滤器。

        - 收益：业务总共有 6620 W 个 Keys , 在缓存全量 Keys 的时候 占用 18408 MB 的内存, 在 Key 降冷后 仅仅占用 593MB 。

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
