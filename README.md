
<!-- vim-markdown-toc GFM -->

* [database management systems (DBMS): 数据库管理系统](#database-management-systems-dbms-数据库管理系统)
    * [数据库体系结构](#数据库体系结构)
        * [服务器体系结构](#服务器体系结构)
        * [并行](#并行)
    * [RDBMS (关系性数据库)](#rdbms-关系性数据库)
        * [关系数据库理论笔记](#关系数据库理论笔记)
        * [MySQL](#mysql)
        * [MariaDB](#mariadb)
        * [PostgreSQL](#postgresql)
            * [babelfish(亚马逊的postgresql)](#babelfish亚马逊的postgresql)
        * [sqlite](#sqlite)
            * [sqlite个人笔记](#sqlite个人笔记)
        * [dolt: git 命令的数据库](#dolt-git-命令的数据库)
    * [NOSQL(非关系数据库)](#nosql非关系数据库)
        * [基本理论](#基本理论)
        * [key-value](#key-value)
            * [Redis](#redis)
            * [Kvrocks: 基于rosedb, 并兼容redis协议. 存储成本小于redis](#kvrocks-基于rosedb-并兼容redis协议-存储成本小于redis)
            * [IndexedDB](#indexeddb)
            * [leveldb](#leveldb)
            * [rocksdb: 基于leveldb, 由facebook维护](#rocksdb-基于leveldb-由facebook维护)
            * [boltdb](#boltdb)
                * [absurd-sql](#absurd-sql)
            * [junodb:paypal开发的kv nosql](#junodbpaypal开发的kv-nosql)
        * [文档](#文档)
            * [MonogoDB](#monogodb)
            * [exist: XML](#exist-xml)
        * [Wide-column (列存储)](#wide-column-列存储)
            * [BigTable论文pdf](#bigtable论文pdf)
            * [HBase](#hbase)
            * [Cassandra](#cassandra)
        * [图](#图)
            * [neo4j](#neo4j)
            * [HugeGraph: 百度基于JanusGraph开发的分布式图数据库](#hugegraph-百度基于janusgraph开发的分布式图数据库)
            * [nebula graph: 分布式图数据库](#nebula-graph-分布式图数据库)
        * [对象](#对象)
        * [时序数据库](#时序数据库)
            * [influxdb](#influxdb)
    * [DDBS(分布式数据库)](#ddbs分布式数据库)
        * [分布式数据库理论笔记](#分布式数据库理论笔记)
        * [rqlite: 分布式sqlite](#rqlite-分布式sqlite)
        * [PGXC](#pgxc)
            * [TDSQL: 腾讯开发的HTAP数据库](#tdsql-腾讯开发的htap数据库)
            * [openGauss: 华为基于PostgreSQL开发的分布式HTAP数据库](#opengauss-华为基于postgresql开发的分布式htap数据库)
        * [NewSQL](#newsql)
            * [H-Store](#h-store)
            * [VoltDB](#voltdb)
            * [TiDB](#tidb)
    * [Snowflake](#snowflake)
* [数据库范式（Normal Form ）](#数据库范式normal-form-)
* [ER模型](#er模型)
* [数据库对比](#数据库对比)
    * [B-tree和lsm-tree的数据库使用情况](#b-tree和lsm-tree的数据库使用情况)
    * [mongodb的大数据平台优势](#mongodb的大数据平台优势)
* [工具](#工具)
* [reference](#reference)
* [类似项目](#类似项目)
* [新闻](#新闻)

<!-- vim-markdown-toc -->

# database management systems (DBMS): 数据库管理系统

## 数据库体系结构

![image](./Pictures/database_concept/architecture_database.avif)

- 1.共享内存:

    - cpu和磁盘通过总线或网络访问一个内存

    - 优点:提高cpu之间的通信效率, 不需要通过软件通信

    - 缺点:规模不能超过32-64个cpu, 因为cpu会把大部分时间花在等待总线或网络

- 2.共享磁盘:

    - cpu通过网络访问所有硬盘

    - 优点:一个cpu坏了, 其他cpu可以接替他

    - 缺点:当出现大量访问磁盘的操作时会出现瓶颈

- 3.无共享:

    - 每个结点一个cpu, 一个内存, 多个磁盘.结点通过网络与另一个结点通信

    - 优点:只有访问非本地磁盘才需要访问网络

    - 缺点:通信代价比共享内存,共享磁盘架构要高

- 4.NUMA(Non Uniform Memory Access 非统一内存访问):

    - 结合共享内存, 共享磁盘, 无共享架构的特点

    - 结点之间通过网络通信, 结点之间不共享内存,磁盘

        - 最上层为无共享

        - 每个结点逻辑上是共享一个内存,多个硬盘架构; 物理上是多个内存

- **分布式数据库与无共享的区别**:分布式一般是地理上的分离, 网络延迟更高

    - 局部事务:本结点发起的数据事务

    - 全局事务:本结点外的数据


### 服务器体系结构

![image](./Pictures/database_concept/architecture_server.avif)

- 进程架构

    - 每个用户会话分配一个进程

    - 所有用户使用同一进程, 但使用多线程进行查询

    - 多进程,多线程的混合架构

- 如果采用共享内存:

    - 所有数据库进程都可以访问内存, 因此表需要互诉(一般使用信号量实现)

### 并行

- 粒度:

    - 粗粒度:由**少量的性能强大的cpu组成**

    - 细粒度:由**大量的性能弱小的cpu组成**

- 加速比:通过增加并行度(cpu,磁盘等),使其在更短时间内完成任务. 即单个任务的完成时间(响应时间)

    - `Ts(增加并行度后的完成时间) / Tl(之前并行度完成时间) = N`

        - 线性加速比:加速比 = N

        - 亚线性加速比:加速比 < N

        ![image](./Pictures/database_concept/speedup.avif)

- 扩展比:通过增加并行度(cpu,磁盘等),使其在相同时间内完成更多的任务. 即完成任务的数量(吞吐量)

    - `Ts(增加并行度后的任务量) / Tl(之前并行度的任务量) = N`

        - 线性扩展比:Ts = Tl

        - 亚线性扩展比:Tl > Ts

            - 考虑到进程的启动代价,上下文切换, 以及总线,硬盘,锁的占用.实际情况往往是Tl > Ts, 也就是亚线性扩展比

        ![image](./Pictures/database_concept/scaleup.avif)

## RDBMS (关系性数据库)

- [SQLite vs MySQL vs PostgreSQL: A Comparison Of Relational Database Management Systems](https://www.digitalocean.com/community/tutorials/sqlite-vs-mysql-vs-postgresql-a-comparison-of-relational-database-management-systems)

    > 数据类型, 优缺点等对比

### [关系数据库理论笔记](./rdbms.md)

### MySQL

Port:3306

- Mysql 是一个单进程多线程架构的关系性数据库

- `client/server` 架构

    - 即使用TCP/IP进行通信

**特点：**

- 免费开源

- 因为开源提供高度多样性支持 C+,Perl,Java,PHP,以及 Python,以及各种客户端

- MySQL 区别于其他数据库的一个最重要的特点是插件式存储引擎.它是基于表的,而不是数据库

- MySQL 数据库实例由后台线程以及一个共享内存区组成,负责操作数据库文件

---

**缺点:**
?? N + 1查询: 数据库的频繁访问,导致性能降低
- 没有一种存储过程(Stored Procedure)语言
- 其安全系统,主要是复杂而非标准,另外只有到调用 mysqladmin 来重读用户权限时才发生改变
- [十款常见的开源数据库学习资料大汇总](https://linux.cn/article-3758-1.html)
- [深入理解 InnoDB -- 架构篇](https://mp.weixin.qq.com/s?__biz=MzI2MDQzMTU2MA==&mid=2247483850&idx=1&sn=4611d9744b70a00d411eb4c91246eb7d&chksm=ea688a6ddd1f037bd6bc592bd13feb76abb36c3ea0aeb13e3fb355753d1a64f20f1521f2e1df&token=1896344902&lang=zh_CN#rd)

### [MariaDB](https://mariadb.org/documentation/)

> Oracle收购mysql后, 独立出来. 使用GPLv2许可证, 是自由软件

- Mariadb10 主要是基于 mysql5.6 的原型

- 很多linux发行版, 默认的mysql安装命令, 实际上是安装Mariadb

### [PostgreSQL](https://www.postgresql.org/about/)

数据类型丰富,可以自定义类型的关系型数据库:

- 比sqlite, mysql更符合sql标准

- 除了关系性, 还有对象数据库的功能

- 并发性:mvcc不需要读锁, 比mysql要好

- 提供外围数据库的接口连接

- 缺点:

    - 内存: 每个客户端的连接, 都需要创建一个10M左右的进程

- [PostgreSQL 详细配置参数](https://postgresqlco.nf/en/doc/param/)

#### [babelfish(亚马逊的postgresql)](https://babelfishpg.org/)

- 取代SQL Server

    - 支持 `SQL Server wire-protocol`: 非windows平台的驱动程序

    - 支持 `Transact-SQL (T-SQL)`: [微软专有的拓展sql语言](https://en.wikipedia.org/wiki/Transact-SQL)

### sqlite

- 关系性数据库

- 使用`serverless`, 也就是不采用 `client/server` 架构

- 没有任何配置

- self-contained(少量的外部库)

- 支持Transactional(事务),符合ACID:

- 有内存模式

- 数据类型:

    - 动态类型

    - 列的字段即使声明了数据类型, 也可以存储其它类型

    - 创建数据库时, 列字段可以选择不声明数据类型

    - 没有`BOOLEAN`(布尔), `DATETIME` 类型

    - 默认关闭 `Foreign Key`(外键)

    - `PRIMARY KEY` 支持 `NULL`, `INTEGER PRIMARY KEY`(是`ROWID`列的别名)和`WITHOUT ROWID`的表除外.

- 文件保存格式像版本控制系统:

    - 性能:比文件系统的fread(), fwrite()快35%

        - 给sqlite的内存分配越大, 速度越快

    - sqlite打包所有blob,而open(),close()对单个文件的每个blob,都要调用一次

    - 只需覆盖文件修改的部分,减少ssd的损耗

    - 只需读取文件所需的数据进内存,而不是读取整个文件

    - 不需要自己写文件I/O

    - 读取性能对比

        ![image](./Pictures/database_concept/benchmark_read.avif)

    - 写入性能对比

        ![image](./Pictures/database_concept/benchmark_write.avif)

    - 对100M大小的文件, 分割成不同大小的块, 进行性能对比

        - 大于1的: 文件系统更快, 小于1: 数据库更快

        ![image](./Pictures/database_concept/benchmark_blob.avif)

- 使用N + 1, 但没有传统N + 1的问题(因此可以使用大量查询):

    - 第一组查询是从`Fossil数据库` 的`config`, `global_config`中提取

    - timeline的代码可以对不同部分进行分离

    - sqlite与应用程序共同使用进程空间

    - 查询只是函数调用,而不是消息往返

        - `client/server` 架构的数据库,每条sql语句都需要应用程序与数据库之间来回往返

- 缺点:

    - 低并发: 只能有一个进程访问

    - 没有用户权限管理

    - 由于不是`client/server`, 在服务器上, 可能会出现更多的bug

#### [sqlite个人笔记](./sqlite.md)

### [dolt: git 命令的数据库](https://github.com/dolthub/dolt)

## NOSQL(非关系数据库)

![image](./Pictures/database_concept/databases-type.avif)

### 基本理论

- [Michael Stonebraker: SQL Databases v. NoSQL Databases](https://cacm.acm.org/magazines/2010/4/81482-sql-databases-v-nosql-databases/fulltext)

    - nosql的性能和灵活性, 是通过牺牲acid实现的, 与sql本身无关

        - nosql设计之初就考虑分布式环境, 通过多个结点分摊了一些瓶颈, sql也可以实现

            - 但涉及磁盘写入,缓存管理也难以回避以下的1个或多个瓶颈

    - 主要瓶颈:

        - `client/server` 之间的通信开销

            - 解决方法: 存储过程或者嵌入式

        - logging(日志): 为了实现持久性, 需要两次写入磁盘, 第二次为写入日志

        - locking: 事务锁

        - latching(内存锁): 对b+树等数据结构访问时需要加锁

        - Buffer Management(缓存管理): 数据库需要管理内存, 磁盘

- [Michael Stonebraker: Errors in Database Systems, Eventual Consistency, and the CAP Theorem](https://cacm.acm.org/blogs/blog-cacm/83396-errors-in-database-systems-eventual-consistency-and-the-cap-theorem/fulltext)
    - 对cap理论, 提出意见

### key-value

#### [Redis](https://github.com/redis/redis)

- Port:6379

- In-memory 存储

#### [Kvrocks: 基于rosedb, 并兼容redis协议. 存储成本小于redis](https://github.com/bitleak/kvrocks)

- [rosedb](https://github.com/roseduan/rosedb)

- docker安装
```sh
docker run -it -p 6666:6666 bitleak/kvrocks
redis-cli -p 6666
```

#### IndexedDB

- [浏览器数据库 IndexedDB 入门教程](http://www.ruanyifeng.com/blog/2018/07/indexeddb.html)

- 存储JavaScript 对象

- 每一个数据库对应创建它的域名

    - 网页只能访问自身域名下的数据库，而不能访问跨域的数据库

- [Why IndexedDB is slow and what to use instead](https://rxdb.info/slow-indexeddb.html)

    - 事务太多

#### [leveldb](https://github.com/google/leveldb)

- LevelDB 只是一个 C/C++ 编程语言的库, 不包含网络服务封装, 所以无法像一般意义的存储服务器(如 MySQL)那样, 用客户端来连接它. LevelDB 自己也声明, 使用者应该封装自己的网络服务器.

- 存储基于内存 + SSD

- 底层数据结构为 `LSM-tree`

- 单进程

- [leveldb-cli](https://github.com/liderman/leveldb-cli)

- [python库:plyvel](https://plyvel.readthedocs.io/en/latest/user.html#getting-started)
    ```py
    import plyvel

    # 打开数据库
    db = plyvel.DB('/tmp/testdb/', create_if_missing=True)

    # 创建key
    db.put(b'a', b'1')
    db.get(b'a')

    # 遍历kv
    for key, value in db:
         print(key)
         print(value)

    # 删除key
    db.delete(b'a')
    ```


#### [rocksdb: 基于leveldb, 由facebook维护](https://github.com/facebook/rocksdb)

- [木鸟杂记：一文科普 RocksDB 工作原理]()

#### [boltdb](https://github.com/boltdb/bolt)

- 纯go语言写的kv数据库
##### [absurd-sql](https://github.com/jlongster/absurd-sql)

- 在浏览器与IndexedDB之间, 添加一层sqlite

#### [junodb:paypal开发的kv nosql](https://github.com/paypal/junodb)

- [Unlocking the Power of JunoDB: PayPal’s Key-Value Store Goes Open-Source](https://medium.com/paypal-tech/unlocking-the-power-of-junodb-paypals-key-value-store-goes-open-source-ee85f935bdc1)

### 文档

#### MonogoDB

- Port:27017

#### [exist: XML](https://github.com/eXist-db/exist)

### Wide-column (列存储)

#### [BigTable论文pdf](https://static.googleusercontent.com/media/research.google.com/en//archive/bigtable-osdi06.pdf)

#### HBase

- Hadoop的组件之一: Google BigTable 的衍生开源版本

#### Cassandra

> 最早由facebook开发, 后交由apache的Google BigTable 的衍生数据库

### 图

- [Neo4j vs Nebula Graph vs JanusGraph](https://nebula-graph.io/posts/performance-comparison-neo4j-janusgraph-nebula-graph/)

#### [neo4j](https://github.com/neo4j/neo4j)

#### [HugeGraph: 百度基于JanusGraph开发的分布式图数据库](https://github.com/hugegraph/hugegraph)

#### [nebula graph: 分布式图数据库](https://github.com/vesoft-inc/nebula)

### 对象

### 时序数据库

#### [influxdb](https://github.com/influxdata/influxdb)

- 使用tsm树

```sh
# 启动server
influxb

# 初始化
influx setup

# 写入tzb
influx write --bucket tzb --precision s "m v=2 $(date +%s)"

# 查询tzb
influx query 'from(bucket:"tzb") |> range(start:-1h)'
```

## DDBS(分布式数据库)

### [分布式数据库理论笔记](./ddbs.md)

### [rqlite: 分布式sqlite](https://github.com/rqlite/rqlite)

- 基本使用

```sh
# 创建三个节点. rqlite需要两个端口, 一个是http api, 另一个是节点之间的通信
rqlited -node-id 1 ~/node.1

rqlited -node-id 2 -http-addr localhost:4003 -raft-addr localhost:4004 -join http://localhost:4001 ~/node.2

rqlited -node-id 3 -http-addr localhost:4005 -raft-addr localhost:4006 -join http://localhost:4001 ~/node.3

# 通过http查看状态
curl 'localhost:4001/status?pretty'

# 进入数据库查看状态
rqlite
.status
```

- 使用Raft实现所有sqlite实例的一致性

    - 所有对数据库的修改都需要log, 必须经过quorum节点的提交才能生效

    - 查询不不一定经过log

    ```sh
    # 创建数据库
    curl -XPOST 'localhost:4001/db/execute?pretty&timings' -H "Content-Type: application/json" -d '[
        "CREATE TABLE foo (id INTEGER NOT NULL PRIMARY KEY, name TEXT, age INTEGER)"
    ]'

    # 插入数据
    curl -XPOST 'localhost:4001/db/execute?pretty&timings' -H "Content-Type: application/json" -d '[
        "INSERT INTO foo(name, age) VALUES(\"fiona\", 20)"
    ]'

    # 查询
    curl -G 'localhost:4001/db/query?pretty&timings' --data-urlencode 'q=SELECT * FROM foo'
    ```

- 默认情况下sqlite layer 是在内存创建数据库

- 默认开启log压缩

- 使用https api

    - 写入会发送给leader node

    - 查询默认会发送给leader node(防止其他节点的更新落后于leader)

        - 也可以发送给其他node, 取决于read consistency(读一致性设置): `none`, `weak`, `strong`

        ```sh
        # none 不检查是否为leader, 速度最快
        curl -G 'localhost:4001/db/query?level=none' --data-urlencode 'q=SELECT * FROM foo'
        # weak 只检查本地是否为leader, 再查询
        curl -G 'localhost:4001/db/query?level=weak' --data-urlencode 'q=SELECT * FROM foo'
        # strong 必须确保节点在整个查询过程为leader
        curl -G 'localhost:4001/db/query?level=strong' --data-urlencode 'q=SELECT * FROM foo'
        ```


### PGXC

#### [TDSQL: 腾讯开发的HTAP数据库](https://github.com/Tencent/TBase)

- 兼容MYSQL, PostgreSQL

- TDSQL-A: 分析数据库

- TDSQL-C: 云原生数据库

#### [openGauss: 华为基于PostgreSQL开发的分布式HTAP数据库](https://gitee.com/opengauss/openGauss-server)

### NewSQL

> 支持NoSQL的OLTP和使用SQL作为主要接口并兼容ACID的关系性数据库

#### [H-Store](https://github.com/apavlo/h-store)

> 最早的NewSQL数据库

- SN(不共享架构)

- 数据库被划分为不同的分区,每个分区分配一个线程

    - 因为它是单线程的,系统中不包括锁, 一次只能有一个事务访问

    - 增加吞吐量方法

        - 增加节点数

        - 减少分区大小

#### [VoltDB](https://github.com/VoltDB/voltdb)

> 兼容ACID的内存RDBMS

- 基于H-Store

- SN(不共享架构)

#### [TiDB](https://github.com/pingcap/tidb)

> 参考 Google Spanner 和 Goolge F1 实现的NEWSQL

- [TiDB介绍](https://en.pingcap.com/blog/how-we-build-an-htap-database-that-simplifies-your-data-platform)

- 使用HTAP

- `TiDB` 兼容 MySQL 5.7 协议和 MySQL 生态的层

- `Tiky` 行存储引擎

- `Tiflash` 是4.0版本新增支持kv, 事务的列存储引擎


    - `Tiky`->`Tiflash`: 行存储 -> 列存储

        - 使用Raft一致性算法, 从TiKV异步复制数据

        - TiKV和TiFlash之间没有中间层,数据复制快速简单, 因此行列是实时更新的

    - 并通过验证Raft索引和多版本并发控制(MVCC)来保证快照隔离级别的一致性
    - 优化器会根据成本模型选择列工作, 还是行工作

- `TiSpark`是用于在TiKV或TiFlash之上的可以运行Spark的中间层,以响应复杂的OLAP查询

- 安装

```sh
# 下载tiup
curl --proto '=https' --tlsv1.2 -sSf https://tiup-mirrors.pingcap.com/install.sh | sh

# 下载安装tidb, 默认开启是一个db, pd, kv
cd tiup/bin
 ./tiup playground

# 也可以指定db, pd, kv的数量
tiup playground v5.0.0 --db 2 --pd 3 --kv 3 --monitor

# Grafana: 用户密码为为admin
http://127.0.0.1:3000
```

## Snowflake

- [Snowflake：从雪花到风暴](https://mp.weixin.qq.com/s/GKdLNoTAPCK3HtInzyvtYw)

# 数据库范式（Normal Form ）

- 范式：
    - 优点：它避免了大量的数据冗余，节省了存储空间，保持了数据的一致性。范式化的表通常更小，可以更好地放在内存里，所以执行操作会更快。
    - 缺点：关联查询慢。范式越高意味着表的划分更细，一个数据库中需要的表也就越多，用户不得不将原本相关联的数据分摊到多个表中。稍微复杂一些的查询语句在符合范式的数据库上都可能需要至少一次关联，也许更多，这不但代价昂贵，也可能使一些索引策略无效。

- 反范式：
    - 优点：只需要查询1个表就可以了，不需要关联查询
    - 缺点：需要考虑数据一致性和数据冗余

- 第一范式（1NF）：数据库表的每一列（也称为属性）都是不可分割的原子数据项

    - 不能是集合，数组，记录等非原子数据项。

    - 以下就`所在地`一列就不符合1NF，应该拆分省份、城市字段

        | id | 名字 | 所在地         |
        |----|------|----------------|
        | 1  | 张三 | 广东省，深圳市 |
        | 2  | 李四 | 海南省，海口市 |

    - 以下不符合1NF

        ![image](./Pictures/database_concept/第一范式例子.avif)

        - 解决方法：

        ![image](./Pictures/database_concept/第一范式例子1.avif)

- 第二范式（2NF）：每个表必须有且仅有一个主键（primary key），其他属性需完全依赖于主键。除了主键，还定义了不允许存在对主键的部分依赖

    - 第二范式（2NF）是在第一范式（1NF）的基础上建立起来的，即满足第二范式（2NF）必须先满足第一范式（1NF）。

    - 以下订单号和商品号为联合主键，但对于商品类别这个属性，仅仅与商品ID有关，也就是仅依赖于主键的一部分。不符合2NF

        | 订单号 | 商品号 | 商品名称 | 价格 | 商品类别 |
        |--------|--------|----------|------|----------|
        | o1     | g1     | 洗衣液   | 23   | 家居     |
        | o2     | g2     | 吹风机   | 125  | 电器     |

    - 以下学生信息表。但学号不是主键，学号能决定姓名，地址，但是凭学号这一项，是决定不了成绩这一项，所以这里学号不是主键。它只依赖于主键里面的学号这一项，只依赖于主键的一部分，所以这张表的主键是（学号，课程号）。不符合2NF

        - 问题：
            - 插入异常：如计划开新课，由于没人选修，没有课程号信息，那么因为（学号，课程号）是主键，所以连学生基本信息也不能插入，只有学生选课之后，才能插入信息。
            - 数据冗余：假设一个学生选修 50 门课，那么学生基本信息就重复了很多次，造成数据冗余。

        - 解决方法：拆分成两个表，学生基本信息表和选课成绩表。总的来说，一张表只管一件事情，就不会出现这种问题。

        | 学号 | 姓名 | 地址   | 成绩 |
        |------|------|--------|------|
        | 1    | 张三 | 北京市 | 80   |

- 第三范式（3NF）：每一列都和主键直接相关，不能是间接相关

    - 以下的城市气候、城市人口属性，仅仅依赖于城市，而不是用户，所以只能算作间接关系。不符合3NF
        - 解决方法：将城市相关的属性分离到一个城市的表中

        | id | 名字 | 城市   | 城市气候       | 城市人口 |
        |----|------|--------|----------------|----------|
        | 1  | 张三 | 北京市 | 温带大陆性气候 | 1300万人 |
        | 2  | 李四 | 海口市 | 热带季风气候   | 230万人  |

    - 以下的工资依赖于工资级别，工资级别依赖于员工号。不符合3NF

        | 员工号 | 工资级别 | 工资  |
        |--------|----------|-------|
        | 1      | 1        | 10000 |

- 巴斯-科德范式（BCNF，Boyce-Codd Normal Form）
- 第四范式（4NF）
- 第五范式（5NF）

# ER模型

- ER模型（实体-联系模型）：描述数据库所存储的数据。

    - 1.实体：凡是可以相互区别，并可以被识别的事、物概念等均可认为是实体。
        - 例子：学生李明，黄颖等都是实体，为了便于描述，可以定义学生这样的一个实体集，所有学生都是这个集合的成员。

    - 2.属性：每个实体都具有各种特征，称其为实体的属性，如学生有学号，姓名，年龄等属性。
        - 实体的属性值是数据库存储的主要数据。能唯一标识实体的属性或属性组称为实体键，如一个实体有多个键存在。则可从中选取一个作为主键。

    - 3.联系：实体间会存在各种关系，如人与人之间可能存在领导与雇员关系等，实体间的关系被抽象为联系。

- ER图的四个组成的部分
    - 1.矩形框：表示实体，在矩形框中写上实体的名字
    - 2.椭圆形框：表示实体或联系的属性
    - 3.菱形框：表示联系，在框中记入联系名
    - 4.连线：实体与属性之间；实体与联系之间；联系与属性之间用直线相连
        - 对于一对一联系：要在两个实体连线方向各写1
        - 对于一对多联系：要在一的一方写1，多的一方写N
        - 对于多对多关系：则要在两个实体连线方向各写N,M。

    ![image](./Pictures/database_concept/ER图.avif)

# 数据库对比

## B-tree和lsm-tree的数据库使用情况

- B-tree：一般被关系型数据库使用
    - oracle、 sql server、 db2、 mysql(innodb)、 postgresql

- lsm-tree：
    - 列数据库：cassandra、hbase
    - google bigtable、leveldb、rocksdb、elasticsearch（lucene）

## mongodb的大数据平台优势

| 数据库类型      | 数据量大 | 速度与并发 | 多结构数据 | 事务支持 |
|-----------------|----------|------------|------------|----------|
| RDBMS           | 较差     | 一般       | 差         | 很好     |
| MPP（数据仓库） | 较好     | 较差       | 差         | 很好     |
| Hadoop          | 很好     | 差         | 很好       | 差       |
| mongodb         | 较好     | 很好       | 很好       | 较好     |
| newsql          | 较好     | 很好       | 差         |          |

- newsql、rdbms、mpp就是对多结构数据支持不特别理想，mongodb也有一些缺点，不适合进行多表关联

- hadoop适合离线批量数据

- mongodb适合实时处理大数据

- mongodb提供spark连接器，

- mongodb对比HDFS的优势：

    - HDFS的每个文件大小为64MB - 128MB。而mongodb更细粒化

    - mongodb支持索引，而hdfs没有，因此读取更快

    - mongodb更易于修改写入后的数据

    - 可以使用aggregate进行数据筛选处理

# 工具

- 数据

    - [ingestr：不同数据库的数据源导入导出](https://github.com/bruin-data/ingestr)

- ai

    - [sqlchat](https://github.com/sqlchat/sqlchat)

    - [DB-GPT:local GPT](https://github.com/csunny/DB-GPT)

# reference

- [《数据库系统概念第7版》课件(英文)](https://www.db-book.com/slides-dir/index.html)

- [《Readings in Database Systems》 第五版](http://www.redbook.io/)

- [db-tutorial 是一个数据库教程](https://github.com/dunwu/db-tutorial)

- [db-engines](https://db-engines.com/en/)

- [nosql-database](https://hostingdata.co.uk/nosql-database/)

- [awesome-db](https://github.com/numetriclabz/awesome-db#readme)

- [sqlfluff: sql语句语法检查](https://github.com/sqlfluff/sqlfluff)

- [FastoNoSQL](https://github.com/fastogt/fastonosql)

    | 支持数据库                          |
    |-------------------------------------|
    | Redis                               |
    | Memcached                           |
    | SSDB                                |
    | LevelDB                             |
    | RocksDB                             |
    | UnQLite                             |
    | LMDB                                |
    | ForestDB (Available in PRO version) |
    | Pika (Available in PRO version)     |
    | Dynomite (Available in PRO version) |
    | KeyDB                               |

# 类似项目

- [db-tutorial 是一个数据库教程](https://github.com/dunwu/db-tutorial)
    > 包含分布式, mysql, redis, mongodb, hbase, elasticsearch

# 新闻

- [数据库内核月报](http://mysql.taobao.org/monthly/)
  通过搜索引擎输入以下格式进行搜索(我这里搜索的是 binlog)

  > site:mysql.taobao.org binlog

