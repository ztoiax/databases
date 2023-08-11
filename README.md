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

#### 分表, 分库(IO并行)

> 数据库出现瓶颈时, 可以使用分表, 分库

- 分表, 分库开源产品

    ![image](./Pictures/mysql/split.avif)

- 水平分库

    - 减少cpu, io

    - 将表的**数据**拆分成不同库, 没有交集

    - 每个库的结构都一样; 数据不一样

    ![image](./Pictures/mysql/transverse_database.avif)

- 垂直分库

    - 将表的**列字段**拆分成不同库, 没有交集

    - 每个库的结构都不一样; 数据也不一样

    ![image](./Pictures/mysql/vertical_database.avif)

- 水平分表

    - 减少cpu

    - 将表的**数据**拆分成不同表, 没有交集

    - 每个表的结构都一样; 数据不一样

    ![image](./Pictures/mysql/transverse_table.avif)

- 垂直分表

    - 将表的**列字段**拆分成不同表, 有交集:每个表至少有一列交集(一般是主键)

    - 每个表的结构都不一样; 数据也不一样

    ![image](./Pictures/mysql/vertical_table.avif)

- 磁盘读 IO 瓶颈: 热点数据太多,数据库缓存放不下,每次查询时会产生大量的 IO,降低查询速度

    - 分库和垂直分表

- 网络 IO 瓶颈:请求的数据太多,网络带宽不够
    - 分库

- CPU 瓶颈第一种: SQL 中包含 join,group by,order by,非索引字段条件查询等

    - SQL 优化,建立合适的索引,在业务 Service 层进行业务计算

- CPU 瓶颈第二种: 单表数据量太大,查询时扫描的行太多

    - 水平分表

##### 划分技术

- 轮转法(round-robin):

    - 对关系进行顺序扫描, 将第i个元组发送到磁盘Di

    - 保障了元组的平均分布

    - 适合整个关系查询

- 散列划分(hash partitioning):

    - 基于属性salary的划分时, 当执行 `salary = 10000 - 1000`查询语句时, 只需扫描保存这个属性值的单个磁盘

    - 适合单个属性值查询, 整个关系查询. 不适合范围查询

- 范围划分(range partitioning):

    ![image](./Pictures/database_concept/range_partitioning.avif)

    - 基于属性的范围划分, 一般查询只需扫描单个磁盘

    - 适合范围查询, 单个属性值查询, 不适合整个关系查询

- 编斜(skew)

    ![image](./Pictures/database_concept/skew.avif)

    - 散列划分和范围划分会出现偏斜

    - 解决方法:

        - 虚拟结点(virtual node):

            - 创建实际结点几倍的虚拟结点,虚拟结点依次映射到实际结点

            - 随着关系的增长, 也会动态的创建新虚拟结点.并将数量更多虚拟结点移动到数量少的结点

            ![image](./Pictures/database_concept/virtual-node.avif)

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

# AI工具

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

