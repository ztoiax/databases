
<!-- vim-markdown-toc GFM -->

* [database management systems (DBMS): 数据库管理系统](#database-management-systems-dbms-数据库管理系统)
    * [数据库体系结构](#数据库体系结构)
        * [共享和不共享架构](#共享和不共享架构)
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
        * [NewSQL](#newsql)
            * [H-Store](#h-store)
            * [VoltDB](#voltdb)
    * [OLAP引擎](#olap引擎)
        * [大数据](#大数据)
        * [Snowflake](#snowflake)
    * [HTAP](#htap)
        * [白鳝的洞穴：你真的了解HTAP吗](#白鳝的洞穴你真的了解htap吗)
    * [国产数据库](#国产数据库)
        * [白鳝的洞穴：国产数据库百态(1)](#白鳝的洞穴国产数据库百态1)
        * [分布式数据库](#分布式数据库)
            * [TiDB](#tidb)
            * [中兴的GoldenDB](#中兴的goldendb)
            * [蚂蚁集团的Oceanbase](#蚂蚁集团的oceanbase)
            * [华为GaussDB](#华为gaussdb)
            * [阿里的PolarDB](#阿里的polardb)
            * [腾讯的TDSQL](#腾讯的tdsql)
    * [如何判断HTAP数据库的水平](#如何判断htap数据库的水平)
    * [HTAP的数据库](#htap的数据库)
* [数据库对比](#数据库对比)
    * [mongodb的大数据平台优势](#mongodb的大数据平台优势)
* [数据存储结构](#数据存储结构)
* [数据库范式（Normal Form ）](#数据库范式normal-form-)
* [ER模型](#er模型)
* [行业](#行业)
    * [云数据库](#云数据库)
* [业务](#业务)
* [第三方工具](#第三方工具)
    * [sql](#sql)
    * [AI](#ai)
    * [画图](#画图)
    * [gui客户端工具](#gui客户端工具)
* [数据库流行度](#数据库流行度)
    * [国产数据库](#国产数据库-1)
* [性能测试](#性能测试)
* [新闻](#新闻)

<!-- vim-markdown-toc -->

# database management systems (DBMS): 数据库管理系统

## 数据库体系结构

![image](./Pictures/database_concept/architecture_database.avif)

- 1.shared memory（共享内存）:

    - cpu和磁盘通过总线或网络访问一个内存

    - 优点:提高cpu之间的通信效率, 不需要通过软件通信

    - 缺点:规模不能超过32-64个cpu, 因为cpu会把大部分时间花在等待总线或网络

- 2.shared disk（共享磁盘）:

    - cpu通过网络访问所有硬盘

    - 优点:一个cpu坏了, 其他cpu可以接替他

    - 缺点:当出现大量访问磁盘的操作时会出现瓶颈

- 3.shared nothing（无共享）:

    - 每个结点一个cpu, 一个内存, 多个磁盘.结点通过网络与另一个结点通信

    - 优点:只有访问非本地磁盘才需要访问网络

    - 缺点:通信代价比共享内存,共享磁盘架构要高

- **分布式数据库与无共享的区别**:分布式一般是地理上的分离, 网络延迟更高

    - 局部事务:本结点发起的数据事务

    - 全局事务:本结点外的数据


### 共享和不共享架构

- 1.SMP（对称多处理器结构）架构：

    ![image](./Pictures/database_concept/架构-smp.avif)

    - 一个计算机上汇集了一组处理器（多核 CPU），各 CPU 之间共享内存子系统以及总线结构。代表数据库有 Oracle 、MySQL 。

    - 在 SMP 中，每个 CPU 都有自己的缓存，无论双核还是四核，其余资源都是共享的。

    - 缺点：
        - 扩展能力非常有限。
        - 访问异地内存的时延远远超过访问本地内存，因此，当CPU数量增加时，系统性能无法线性增加。

- 2.NUMA(Non Uniform Memory Access 非统一内存访问)架构:

    - 结合共享内存, 共享磁盘, 无共享架构的特点
    - 这种架构就是为了解决SMP扩展能力不足的问题

    - 节点之间可以通过互联模块进行连接和信息交互，所以，每个CPU可以访问整个系统的内存（这是与MPP系统的重要区别）。

    - 缺点：
        - 访问异地内存的时延远远超过访问本地内存，因此，当CPU数量增加时，系统性能无法线性增加。

- 3.MPP（大规模并行处理结构）架构：

    ![image](./Pictures/database_concept/架构-mpp.avif)

    - 是一种Share Nothing架构

    - 大数据计算引擎有很多都是MPP架构的。代表数据库有 ClickHouse 、Snowflake 、Azure Synapse Analytics 、Impala 、Doris、Druid、Greenplum 、Elasticsearch、 Presto 。
    - 采用MPP架构的很多OLAP引擎号称：亿级秒开。

    - 优点：
        - MPP结构扩展能力最强，理论可以无限扩展。
        - MPP是多台SPM服务器连接的，每个节点的CPU不能访问另一个节点内存，所以也不存在异地访问的问题。

    - 批处理架构（如 MapReduce）和MPP架构的区别

        - 共同点：批处理架构与MPP架构都是分布式并行处理，将任务并行的分散到多个服务器和节点上，在每个节点上计算完成后，将各自部分的结果汇总在一起得到最终的结果。

        - 不同点：

            - MapReduce：这些tasks被随机的分配在空闲的Executor上
                - 优点：如果某个Executor执行过慢，那么这个Executor会慢慢分配到更少的task执行，批处理架构有个推测执行策略，推测出某个Executor执行过慢或者有故障，则在接下来分配task时就会较少的分配给它或者直接不分配，这样就不会因为某个节点出现问题而导致集群的性能受限。
                - 缺点：需要将中间结果写入到磁盘中，这严重限制了处理数据的性能。

            - MPP架构：每个处理数据的task被绑定到持有该数据切片的指定Executor上。
                - 优点：MPP架构不需要将中间数据写入磁盘。因为一个单一的Executor只处理一个单一的task，因此可以简单直接将数据stream到下一个执行阶段。这个过程称为pipelining，它提供了很大的性能提升。
                - 缺点：
                    - 1.因为task和Executor是绑定的，如果某个Executor执行过慢或故障，将会导致整个集群的性能就会受限于这个故障节点的执行速度(所谓木桶的短板效应)，所以MPP架构的最大缺陷就是——短板效应。
                    - 2.集群中的节点越多，则某个节点出现问题的概率越大，而一旦有节点出现问题，对于MPP架构来说，将导致整个集群性能受限，所以一般实际生产中MPP架构的集群节点不易过多。

            - 例子：数据落盘。要实现两个大表的join操作
                - 批处理：如Spark将会写磁盘三次(第一次写入：表1根据join key进行shuffle；第二次写入：表2根据join key进行shuffle；第三次写入：Hash表写入磁盘)
                - MPP：只需要一次写入(Hash表写入)。
                - 结论：这是因为MPP将mapper和reducer同时运行，而MapReduce将它们分成有依赖关系的tasks(DAG),这些task是异步执行的，因此必须通过写入中间数据共享内存来解决数据的依赖。


            - 批处理架构和MPP架构融合：两个架构的优势和缺陷都很明显，并且它们有互补关系，如果我们能将二者结合起来使用，是不是就能发挥各自最大的优势。目前批处理和MPP也确实正在逐渐走向融合，也已经有了一些设计方案，技术成熟后，可能会风靡大数据领域，我们拭目以待！



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

- 分布式数据库，无论是存算分离还是存算一体，都会对就近计算这个优化理念产生背离。
    - 跨节点的操作，无论是扫描还是JOIN，都会因为网络开销而带来成本。分布式事务更是会让事务的延时有所增加。
    - 分布式数据库可能会让一条SQL跑得更快，这主要取决于并发执行会对这条SQL带来多大的好处，如果这些好处比分布式计算所需要的网络开销以及分布式事务开销带来的负面影响更大，那么就会成为现实。而一些十分简单的SQL操作，往往无法从中受益。

- Tidb为代表的的完全存算分离的分布式数据库对开发是十分友好的，应用开发人员不需要考虑复杂的数据存储的分片策略，对于传统的集中式数据库用户来说，学习成本极低。但是在某些情况下对于应用性能优化是不友好的，因为我们没有办法根据应用特性去优化相关的表的存储结构，并更好地支持MPP计算。
- 相对而言，OCEANBASE和Gaussdb这类分布式数据库可以使用类似表组和表复制的方法来优化某些应用场景，如果应用设计充分利用这些特性，那么是可以更好的下推某些算子，甚至将分布式事务变为本地事务，从而极大地降低应用的延时。这种优化在TiDB上就无法实现，只能通过对集群软硬件环境的极致优化来降低总体延时了。

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

## OLAP引擎

- [五分钟学大数据：ClickHouse、Doris、 Impala等MPP架构详解](https://mp.weixin.qq.com/s/oLzfye6HiHNMqZkv_5GO7A)

- MPP架构的OLAP引擎分为两类：
    - 1.自身不存储数据，只负责计算的引擎
    - 2.自身既存储数据，也负责计算的引擎。

![image](./Pictures/database_concept/OLAP引擎对比.avif)

- 1.只负责计算，不负责存储的引擎

    - 1.Impala

        - Apache Impala是采用MPP架构的查询引擎，本身不存储任何数据，直接使用内存进行计算，兼顾数据仓库，具有实时，批处理，多并发等优点。
        - 提供了类SQL（类Hsql）语法，在多用户场景下也能拥有较高的响应速度和吞吐量。它是由Java和C++实现的，Java提供的查询交互的接口和实现，C++实现了查询引擎部分。
        - Impala支持共享Hive Metastore，但没有再使用缓慢的 Hive+MapReduce 批处理，而是通过使用与商用并行关系数据库中类似的分布式查询引擎（由 Query Planner、Query Coordinator 和 Query Exec Engine 三部分组成），可以直接从 HDFS 或 HBase 中用 SELECT、JOIN 和统计函数查询数据，从而大大降低了延迟。
        - Impala经常搭配存储引擎Kudu一起提供服务，这么做最大的优势是查询比较快，并且支持数据的Update和Delete。

    - 2.Presto

        - Presto是一个分布式的采用MPP架构的查询引擎，本身并不存储数据，但是可以接入多种数据源，并且支持跨数据源的级联查询。Presto是一个OLAP的工具，擅长对海量数据进行复杂的分析；但是对于OLTP场景，并不是Presto所擅长，所以不要把Presto当做数据库来使用。

        - Presto是一个低延迟高并发的内存计算引擎。需要从其他数据源获取数据来进行运算分析，它可以连接多种数据源，包括Hive、RDBMS（Mysql、Oracle、Tidb等）、Kafka、MongoDB、Redis等。

- 2.既负责计算，又负责存储的引擎

    - 1.ClickHouse

        - ClickHouse是近年来备受关注的开源列式数据库，主要用于数据分析（OLAP）领域。

        - 它自包含了存储和计算能力，完全自主实现了高可用，而且支持完整的SQL语法包括JOIN等，技术上有着明显优势。相比于hadoop体系，以数据库的方式来做大数据处理更加简单易用，学习成本低且灵活度高。当前社区仍旧在迅猛发展中，并且在国内社区也非常火热，各个大厂纷纷跟进大规模使用。

        - ClickHouse在计算层做了非常细致的工作，竭尽所能榨干硬件能力，提升查询速度。它实现了单机多核并行、分布式计算、向量化执行与SIMD指令、代码生成等多种重要技术。

        - ClickHouse从OLAP场景需求出发，定制开发了一套全新的高效列式存储引擎，并且实现了数据有序存储、主键索引、稀疏索引、数据Sharding、数据Partitioning、TTL、主备复制等丰富功能。以上功能共同为ClickHouse极速的分析性能奠定了基础。

    - 2.Doris

        - Doris是百度主导的，根据Google Mesa论文和Impala项目改写的一个大数据分析引擎，是一个海量分布式 KV 存储系统，其设计目标是支持中等规模高可用可伸缩的 KV 存储集群。

        - Doris可以实现海量存储，线性伸缩、平滑扩容，自动容错、故障转移，高并发，且运维成本低。部署规模，建议部署4-100+台服务器。

        - Doris3 的主要架构：DT（Data Transfer）负责数据导入、DS（Data Seacher）模块负责数据查询、DM（Data Master）模块负责集群元数据管理，数据则存储在 Armor 分布式 Key-Value 引擎中。Doris3 依赖 ZooKeeper 存储元数据，从而其他模块依赖 ZooKeeper 做到了无状态，进而整个系统能够做到无故障单点。

    - 3.Druid

        - Druid是一个开源、分布式、面向列式存储的实时分析数据存储系统。

        - Druid的关键特性如下：

            - 亚秒级的OLAP查询分析：采用了列式存储、倒排索引、位图索引等关键技术；
            - 在亚秒级别内完成海量数据的过滤、聚合以及多维分析等操作；
            - 实时流数据分析：Druid提供了实时流数据分析，以及高效实时写入；
            - 实时数据在亚秒级内的可视化；
            - 丰富的数据分析功能：Druid提供了友好的可视化界面；
            - SQL查询语言；
            - 高可用性与高可拓展性：
                - Druid工作节点功能单一，不相互依赖；
                - Druid集群在管理、容错、灾备、扩容都很容易；

    - 4.TiDB

        - TiDB 是 PingCAP 公司自主设计、研发的开源分布式关系型数据库，是一款同时支持OLTP与OLAP的融合型分布式数据库产品。

        - TiDB 兼容 MySQL 5.7 协议和 MySQL 生态等重要特性。目标是为用户提供一站式 OLTP 、OLAP 、HTAP 解决方案。TiDB 适合高可用、强一致要求较高、数据规模较大等各种应用场景。

    - 5.Greenplum

        - Greenplum 是在开源的 PostgreSQL 的基础上采用了MPP架构的性能非常强大的关系型分布式数据库。为了兼容Hadoop生态，又推出了HAWQ，分析引擎保留了Greenplum的高性能引擎，下层存储不再采用本地硬盘而改用HDFS，规避本地硬盘可靠性差的问题，同时融入Hadoop生态。

### 大数据

- [DuckDB CEO 发表的宣言《大数据已死》](https://mp.weixin.qq.com/s/gk3BOirM6uCTQ1HFTQz3ew)

### Snowflake

- [Snowflake：从雪花到风暴](https://mp.weixin.qq.com/s/GKdLNoTAPCK3HtInzyvtYw)

## HTAP

### [白鳝的洞穴：你真的了解HTAP吗](https://mp.weixin.qq.com/s/GzO2joQXvocXPJimMcwbrg)

- HTAP=OLTP+OLAP，这个公式真的成立吗？

- 一个传统的交易域和数仓域分离的传统数据仓库架构。

    ![image](./Pictures/database_concept/传统HTAP.avif)

    - 大量的在线交易系统首先把数据复制到贴贴源层的ODS，然后经过ETL工具加载到数据仓库中，同时数据仓库中还会存储一些来自外部的数据，甚至一些外购的数据。存储在数据仓库中的是高价值数据，经过处理后形成一系列的数据集市，供业务系统使用。这种架构中将在线交易与数据分析两种截然不同的负载区分开来，避免相互干扰。

    - 问题：不过这种架构最大的问题是，ETL的延时比较大，很多需要及时分析的业务无法得到保证。因此缩短在线交易系统到数据仓库之间的延时就十分重要了。

- Oracle公司推出了一套基于准实时ETL产品ODI的解决方案。

    ![image](./Pictures/database_concept/HTAP-Oracle的ETI产品ODI解决方案.avif)

    - 生产系统使用ORACLE的交易型数据库模式，通过ODI捕获生产系统的变化，并通过定义好的转换规则，准实时进行ETL操作，复制数据到ORACLE OLAP模式的数据仓库中。

    - 问题：虽然能解决一部分数据仓库的延时问题，但是对于实时性要求更高的一些业务就无法满足了。

- 解决方法：因此在在线交易系统中支撑比较强大的数据分析功能的需求就应运而生了，这个需求就是HTAP计算模式。

    - 这种HTAP计算!= OLTP+OLAP
        - 因为如果我们要把一个企业的所有高价值数据都存储在一个数据库里，才能实现这个替代数据仓库的目标。而这种设计会让单一的数据库太重了，一旦这个数据库出现一点点问题，可能就会影响整个企业的业务，这是我们无法承受的。
        - 企业需要的HTAP能力不需要完全覆盖数据仓库业务，仅仅需要对核心业务需要的在线分析能力做一定的提升就可以了。
            - 因此在HTAP数据库中需要存储的就是OLTP系统本身的数据以及部分分析必须的从外部提取过来的高价值数据。

    ![image](./Pictures/database_concept/HTAP.avif)

    - 上面的图看上去是不是简单多了，不过这个简化了的业务需求也并不容易实现。
        - TP系统跑的是稳定，高并发，低延时，大多数通过索引访问，大量写操作的小业务，对于并发写入量较大的表，尽可能减少不必要的索引
        - AP系统跑的是随机性大，资源开销极大，大部分需要对大表进行并行扫描，持续时间很长的的以读为主的分析类业务。读写操作之间会有相互影响，大量的写操作希望索引越少越好，而大量的读操作希望索引越丰富越好。
        - AP操作的临时性资源开销可能会导致TP业务的延时出现经常性的抖动，这些都是会让TP业务无法忍受的。TP业务经常需要访问一张表中的多个字段，从而实现复杂的业务逻辑，因此用行存储的方式性能最佳。AP业务经常对某一列的数据做扫描分析，因此如果数据按列存储具有较好的性能。这些业务之间的矛盾都使一个数据库中承载混合的HTAP负载十分困难。

- 而实际上，我们的OLTP系统中，真的都需要HTAP工作负载吗？答案是否定的。

    - 大多数OLTP系统中仅仅需要一定量的批处理负载，用于对数据进行一些复杂的加工。在一个设计的比较好的OLTP系统中，通过定期自动汇总数据，物化视图等方式，可以大幅度减少开销极大的AP工作负载。
    - 只有极少数的系统是真的必须有复杂的准实时OLAP需求的。而对于AP的实时性要求，如果通过更实时的数据复制和ETL，大部分问题是可以解决的。
    - 此外，分布式SQL引擎的效率、OLTP/OLAP的资源隔离与防干扰措施、数据存储格式、大型集群管理、读写副本的使用方式、主副本切换带来的性能抖动等都会影响数据库的HTAP能力。

- 既然HTAP负载并不是业务系统一定要追求的，那么为什么现在我们随便看到一个分布式数据库，就一定说自己是HTAP数据库呢？

    - 这实际上是和分布式数据库的发展历史分不开的。分布式数据库刚刚出现的时候，主要还是为了高并发的OLTP写入业务。因此这些数据库产品的多表关联，复杂分析功能是很弱的。分布数据库厂家也在不断地优化产品，努力提升这方面的能力。因此为了标榜自己的技术优势，大家都在HTAP能力上开展起军备竞赛了。

    - 虽然如此，如果真的有一个HTAP能力极强的数据库产品放在我们面前，对于用户和软件开发商来说，肯定是一件好事情。这会让我们的管理系统，交易系统的功能变得更加丰富。对于某些行业的业务系统来说，可能会促进业务的革命性变革。比如说能源行业鼓吹了多年的源网核储互动，因为我们的数据处理能力不足，不及时，导致我们在电力生产、消费、储能、调度等方面的数据无法及时进行处理分析，大大降低了能源的综合利用率。

    - 目前来说，电是不可大规模存储的资源，而且电源侧发出的电必须平衡的被消耗掉，否则多发出来的电必须被尽快消耗掉，而某个局部网络上的电能不足时，就只能拉闸限电，确保电能在网络上整个是平衡的。当电源侧发电量过大，或者用电需求过大，供给不足或者电力调度不及时，导致用电缺口达到一定程度的时候，电网会因为不平衡而解裂，2013年洛杉矶大停电或者前几年美国德州大停电的惨剧就会重演了。

    - 我们国家这些年没有出现过类似的情况，这说明我国的大电网调度运营水平是很高的。不过这种水平很高并不意味着很高效。我们的电网调度十分依赖于相对稳定的电源，比如火力发电。而水电、光伏、风能这些清洁能源因为其不稳定，会大大加大电网调度的难度。因此目前我国弃风弃光的比例一直是高于西方发达国家的。

    - 为了完成碳中和目标，加大清洁能源供给是必然的，因此源网核储互动能力的提升十分关键。而要提升源网核储互动的效率，精准及时的数据采集与数据分析是关键。我们必须提高电能表采集的频率（欧洲最先进的电网计量已经实现了5分钟全量采集，而我们目前的主流水平还只是重点电表15分钟间隔采集），提升与发电企业之间的数据交换的水平，对气候、社会热点、制造业增长态势、外贸等数据进行更广泛的采集与处理分析，这样才能逐步提升电网调度计划的水平。以目前电能采集系统到大数据平台数据复制的一天时延来看，要实现这个任务是几乎不可能的。

    - 具有强大HTAP处理能力的数据库是解决这个计算难题的十分关键的IT基础设施，这是一个十分现实的HTAP计算场景。十分可惜的是，在我们为这个场景选择数据库产品的时候，还没有找到一款国产数据库产品具备处理这个业务场景的能力。

## 国产数据库

### [白鳝的洞穴：国产数据库百态(1)](https://mp.weixin.qq.com/s/9L3m8KhzoOvdp9pMzx-vhQ)

- 选择那些通过国测的数据库产品。
    - 数据库国测的要求不低，根据国测的流程和标准分析，能够过国测的厂家，最起码有三五十个比较靠谱的数据库产品研发人员，从公司规模上是可以让人放心的。
    - 目前过国测的公司拿到的证书都是1级，今年的国测比以往更加严格，能通过今年国测的数据库产品不会太差，不知道今年能不能出现通过二级的产品。

- 达梦：

    - 完全自主研发的关系型数据库管理系统，特别是DM7做了一次彻底代码重构优化后，其核心代码的自助率应该是比较高的。

        - 现在有些声音是“某数据库不是自主研发的，是当年买了Oracle 9的代码”，这是因为达梦数据库与Oracle在SQL等方面太像了，其主要功能基本上可以与Oracle 9i对标。实际上这是一个模仿秀而已，购买Oracle早期代码是一种误解。以我对Oracle与达梦数据库的 了解，以及与达梦研发团队多年的合作来看，这个说法百分之百是假的。

            - 首先底层块结构是完全不同的，Oracle是堆结构的，达梦是B树结构的。
            - 另外是进程架构，达梦是采用单进程多线程架构的。
            - 再看REDO机制，达梦没有Oracle的LOG SWITCH机制。
            - 从这几点上看，两种数据库是完全不同的。

    - 达梦与Oracle在应用代码迁移方面的便捷性是目前所有国产数据库中最好的

        - 2016年的时候我们参与南方电网人资系统从Oracle向DM8的迁移，其应用代码除了一个拼接字符串的函数之外，没有做任何的改造。

    - 目前达梦在党政，金融行业的OA系统国产数据库替代中占有较高的市场份额，也是国网、南网调度系统国产化替代的主力数据库，主要也是受益于其良好的兼容性。

    - 在对标Oracle RAC的DM DSC上也投入了大量的研发，RAC功能是不大好做的功能，目前国产数据库只有达梦正式商用了此类功能，不过在实际应用中还是遇到了不少问题，全局热块和缓冲区融合带来的闩锁争用会导致系统性能出现瓶颈，必须通过应用改造来解决。当年Oracle 9i遇到的问题，DM DSC也正在面对。

    - 达梦数据库基于DM8已经衍生出了DM DSC/DM DPC/DM MPP等产品
        - DM8主打主从复制高可用
        - DM DSC是类似Oracle RAC的产品
        - DM DPC是为金融、工业互联网、物联网打造的存算分离的分布式数据库产品。
        - DM MPP主打OLAP场景

- 人大金仓：
    - KingbaseES数据库是基于PostgreSQL开源代码开发的，早期的KingbaseES基于PG 9.X, 后续版本采用了较新的PG内核。
        - 这些年在KingbaseES中也针对PG优化器的一些能力不足做了大量的增强，在这方面积累了大量的经验。
    - KingbaseES做了大量的Oracle、MySQL、SQL SERVER、DB2、Informix等语法兼容方面的改造，因此当用户有在做数据库国产化改造时有大量上述种类的数据库的时候，人大金仓数据库会给与比较好的支持。
    - 与金仓的合作中给我感受比较深的是他们的服务是不错的，对于客户的需求响应速度与配合度都是相当不错的，后来在与一些金仓的客户接触的时候，他们给我的反馈也大多如此。
    - 目前人大金仓主推KingbaseES。其中也有一个模仿Oracle RAC的共享存储多读多写的版本，不过仅在一些重点客户处应用，并没有做大规模推广。
        - 人大金仓的“RAC”目前主打的还是高可用切换，TAF等方面的能力对比Oracle来说还有一定的差距，对应用而言，最好做一定的隔离，否则缓冲区融合很可能会遇到一些性能问题。
    - 另外金仓在去年推出了一个类似于Oracle  apex的低代码开发平台，主要也是希望给客户一站式解决方案。
    - 金仓数据库的传统客户在能源、党政、军方等领域，也是目前电网调度系统的两个主要供应商之一。KingbaseES也是最早通过国测的数据库厂家之一。

- 南大通用：
    - 最早是做MPP架构的OLAP数据库的，当时主要的目标是解决Oracle不太擅长的数据仓库领域。
    - 2012年开始到2015年，我曾经配合用户对GBase 8A做过多次测试，评估其是否能够用于替代TD、GP等国外的数据仓库。在我们的测试报告一次次的给它判死刑的过程中，我也有幸见证了一款数据库产品的不断提高与成熟的过程。从早期的负载上去集群都会TIMEOUT到能够完成我们近于残酷的即席查询，后面是厂商多个团队的不断努力。从那以后，我收起了对国产数据库的轻视，觉得只要给他们时间，在中国的复杂应用场景中，是能够磨练出几款成功的数据库产品的。

    - 后来南大通用购买了IBM INFORMIX的IP授权，拿到了除去安全模块的所有Informix源代码，并基于此搞出了Gbase 8S/8T，并通过了国测，我们也祝愿他们能够在IP授权到期前吃透Informix代码，改写出一套真正国产的GBase 8S来。

    - 去年开始，南大通用基于openGauss内核开发了Gbase 8C，Gbase 8C作为目前openGauss生态里唯一一个分布式数据库产品，其对标的是华为GaussDB分布式，在市场上主打性价比。

    - Gbase 8A目前在国产OLAP数据库替代中应用中用户数量较多，是华为DWS的强劲对手。
    - Gbase 8S/8T在金融行业有一定的客户群体，在电网调度系统中也有部分应用。

- 神舟通用：

    - 是早期四大国产数据库厂商里最为神秘的一个，主要专注于其传统行业：航天、党政军和金审工程等，近些年才看到他们参与一些外部活动。

    - 神通Oscar也是基于PG源代码开发的一个 数据库产品，不过已经经过了魔改。
        - Oscar对PG做了魔改，进程架构上采用了单进程多线程架构，存储引擎也做了较大的修改，底层采用了和Oracle类似的表空间，数据文件的结构。
        - REDO LOG虽然也采用了类似Oracle的可回绕文件结构，不过并没有采用多个REDO LOG，因此在WAL算法上与Oracle有较大的差异。
        - Oscar的参数体系、监控视图也参考了Oracle数据库，与原生PG差异较大，在运维中不能按照原生PG的方式。
    - 神通数据库目前也加入了openGauss生态，除了Oscar外，也有基于openGauss的版本。

### 分布式数据库

- [白鳝的洞穴：国产数据库百态2-分布式数据库](https://mp.weixin.qq.com/s?__biz=MzA5MzQxNjk1NQ==&mid=2647852073&idx=1&sn=a0a7182c62f4e63a176a0cf307bd8522&chksm=887998bdbf0e11abcfec4a8d60f7269754ae83fa2a142dfabe184d6af8518cde4dd9554053a3&cur_album_id=2294485017978552321&scene=190#rd)

- 分布式数据库有三种流派

    - 1.分布式中间件+单机数据库组成多数据库实例的分布式集群，多个数据库实例按照可用组分成多个复制组，数据通过sharding key分散于各个数据库实例中。
        - GoldenDB、HotDB、TDSQL for MySQL、StarDB等都属于这个流派

    - 2.非对称计算节点+分布式存储本身在底层的分布式存储上实现了数据的多副本，而只读备库可以随时快速升级为主库，替代故障的主库，从而确保数据的可靠性，这种形态与集中式数据库十分类似
        - 阿里PolarDB-o，AWS AURORA 、谷歌AlloyDB等属于此流派。此流派的数据库产品目前还在继续演进中，一种类似Oracle RAC的共享存储并发读写的模式也加入进来，比如崖山YashanDB

    - 3.原生分布式数据库则天然设计为数据多副本，并通过分布式选举协议自动选主，实现透明故障切换
        - 技术上还分为两派
            - Oceanbase采用完全对等的计算模式，每个Observer管理自己的分片数据，整个集群是完全对等的，计算与存储是一体的。
            - TiDB和GaussDB则采用存算分离的模式，计算与存储引擎是分离在不同的服务中的。
        - OceanBase、TiDB、GaussDB、HubbleDb等采用此流派。

#### [TiDB](https://github.com/pingcap/tidb)

> 参考 Google Spanner 和 Goolge F1 实现的NEWSQL

![image](./Pictures/database_concept/tidb架构.avif)

- `TiDB` 兼容 MySQL 5.7 协议和 MySQL 生态的层

    - TiDB 层本身是无状态的，可以启动多个 TiDB 实例，提高并发能力。

- `SQL层`：则由TiDB Server实现，对外暴露 MySQL 协议，负责客户端连接，实现SQL 解析和优化，最终生成分布式执行计划。

- `Tiky` ：用rust开发的一种使用LSM-TREE存储架构的KV存储引擎。

- `Tiflash`：是被TiDB用于OLAP分析的列存引擎。4.0版本新增支持kv


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

#### 中兴的GoldenDB

![image](./Pictures/database_concept/GoldenDB架构.avif)

- GoldenDB是基于MySQL数据库开发的一款国产分布式数据库。包含计算节点（SQL代理层）、全局事务管理节点（GTM）和数据节点（分布式MySQL数据库组）构成，这种架构在基于MySQL的国产分布式数据库中被广泛使用。

- 其主要用户集中在金融行业
    - 从2016年开始，GoldenDB就在中信实业银行实现了银行核心系统的国产化替代。目前在一些银行中都有GoldenDB的应用，很多都是核心、次核心系统。其中不乏工商银行这样的大行。
- 在中国移动，GoldenDB也有BOSS系统替代的成功案例，浙江移动的BOSS系统就是用GoldenDB实现了对Oracle的替代的。

- GoldenDB的成功来自于中兴通讯良好的售后支持服务，对于能够投入大量资金改造核心系统的企业级用户来说，数据库产品技术上的某些问题都是可以克服的，通过应用系统的适配与优化，基本上可以搞定数据库本身存在的一些缺陷。只要数据库厂商的配合态度比较好，那么国产化替代工作是完全可以顺利进行下去的。GoldenDB目前的主要客户也是集中在这种大型企业级客户上。

#### 蚂蚁集团的Oceanbase

- Oceanbase分社区版和企业版两个版本
    - 企业版中有兼容Oracle数据库的Oracle租户
        - 在我们参与的一些客户的数据库国产化替代的测试项目中，OB与Oracle的兼容性仅次于达梦

- Oceanbase是采用存算一体，完全对等模式的，每个OBServer都可以独立完成数据库的所有操作，因此也支持仅有一个Observer的集中式部署模式。

- Oceanbase目前的主要市场是在金融、政企和公有云三个方面。银行、保险、证券公司都已经有大量的Oceanbase应用场景。在中国移动也已经入围了核心系统替代，山东移动、江苏移动、广东移动等大型移动运营商使用OB在BOSS系统中替代了Oracle。

#### 华为GaussDB

- GaussDB同样是首先在金融行业发力。我想这些企业这些年在金融行业势头很猛的主要原因是这个行业在数据库国产化方面走得比较坚决，目前进度也比较快。GaussDB有集中式部署模式与分布式部署模式两种，两种模式使用的是同一套核心介质。

![image](./Pictures/database_concept/GaussDB架构.avif)

- 自从GaussDB去年高调召开发布会以来，在党政、金融、能源等行业进展迅猛。在国网陕西电力的用电信息采集系统上也实现了国产数据库对Oracle的首次替代。在这样大型OLTP系统上实现对Oracle的替代，其意义十分重大。

#### 阿里的PolarDB

- 实际上是一个数据库家族，而不是一个简单的数据库产品。这些年发展过程中也有过数次变迁，到目前为止已经比较稳定了。

- PolarDB目前分为MySQL版，Postgresql版和分布式版三种。

    - PolarDB MySQL版和Postgresql版都是类似亚马逊Aurora的架构，共享存储，计算存储分离的架构。
        - 虽然说PolarDB MySQL版在语法上兼容MySQL，不过其代码已经做了完全的重构，不能说是MySQL套壳。

    - Postgresql版基于PG开源代码开发，做了大量的改造，其语法上依然兼容Postgresql，同时也对Oracle有比较好的支持。

    - PolarDB的分布式版本是兼容MySQL生态的，可以实现对阿里云DRDS的替代。
        - PolarDB的分布式版本和Postgresql版本除了公有云和专有云版本外，还提供DBSTACK部署模式，也就是说支持客户在云下独立部署。

#### 腾讯的TDSQL

- 与PolarDB类似，TDSQL也不是一个数据库产品，而是一个数据库家族的统称。

    - TDSQL-C和TDSQL分布式是TDSQL的两个主要分支，其中都有MySQL与Postgresql版本。

    - 集中式版本也是与AWS AURORA类似的，共享存储，存算分离的模式，这一点与PolarDB十分类似。

    - TDSQL分布式 MySQL版采用的是分布式数据库的流派一的技术，与GoldenDB、HotDB等采用类似的架构。

    - TDSQL分布式 Postgresql版本则是基于PGXC/PGXL开源项目经过多年的迭代升级而形成。目前还衍生出了大量的与Oracle兼容的特性。

- TDSQL目前在金融、证券、税务等行业有大量的应用，在某些用户那边用得还相当不错。其成功的主要原因是TDSQL不仅仅是一个数据库产品，而是一个十分不错的数据库云平台。其良好的管理能力让用户可以很方便地管理大量的数据库实例。

## 如何判断HTAP数据库的水平

- [白鳝的洞穴：数据库HTAP能力强弱怎么看](https://mp.weixin.qq.com/s?__biz=MzA5MzQxNjk1NQ==&mid=2647847529&idx=1&sn=63cdefa013d0d62d69d8f13c0776dd93&chksm=88786efdbf0fe7eb9b9809516f1d1acfec5c122bfaf79ea1616837ce4f8d483931984191bfe9&cur_album_id=2004584439858692098&scene=189#wechat_redirect)

- 数据库选型是个既复杂又简单的事情，如果你能根据自己的实际情况，应用场景去做理性的分析，不难找到一个相对靠谱的选择。

- 1.看TP/AP能力是不是原生融合的，也就是一个SQL引擎可以智能化处理TP/AP能力，最起码TP/AP用用的入口是统一的，一套数据

    - 多种处理引擎的模式虽然也能解决一些TP/AP的问题，不过两个引擎很难做统一资源管理，在某些时候会产生相互干扰，如果AP业务严重影响了TP业务的稳定性，那么就会引发大问题的。

    - 原生融合实际上对SQL引擎和优化器的要求很高
        - 如果SQL引擎存在一些BUG或者有些考虑不周的地方，就可能会引起TP/AP负载被错误识别，引起不必要的麻烦
        - 因此SQL引擎支持HINT是十分必要的，而且在HINT中最好一些针对TP/AP识别，只读副本使用，弱复制一致性数据读取，资源限制等方面的支持。

- 2.有行存为主，列存为辅 或者 行列混合存储 的存储机制

    - 一个数据的写入一定是行存储，不过必须具备数据通过列模式提供查询的能力。

    - 或者数据采用折中的方式，采用范围分片后的行列混合存储模式，既照顾TP应用的行访问需求，也满足AP应用负载的列访问需求。

    - 很多数据库也号称是行存列存都支持的，不过一张表只能建为行存表或者列存表，那么这种行列存储能力对于HTAP的支持是打了折扣的，一份行存数据必须转储到列存表中，才能更好的支持OLAP业务负载。
        - HTAP的准实时数据仓库应用能力就无法实现了。

- 3.OLTP/OLAP负载的隔离性

    - 这两种负载不能相互影响，应该有一定的资源隔离和资源限制能力。能够对一些开销较大，执行时间超长的OLAP负载限定资源使用，避免造成对OLTP的太大的影响。
        - 可以按需挂起/恢复后台OLAP工作任务，临时修改某个或者某些OLAP负载的资源限制等，都是HTAP能力精细化的体现。
        - 一个优秀的HTAP系统，底层资源管理和任务调度做的好坏是关键。

- 4.资源扩展的能力

    - 计算能力，存储能力，IO吞吐能力等都不存在严重的瓶颈，可以随时进行扩展，以满足日益增长的业务需要。
    - 不管是通过MPP节点扩展还是只读节点扩展，只要这种扩展能力对你的业务场景是有效的，都是可以接受的，并不限于某种架构。

- 5.SQL能力
    - SQL能力主要是考察SQL引擎和CBO优化器的能力。
    - 支持的SQL标准，特别是统计函数，分析函数，窗口函数等的支持能力。并行扫描的能力，算子下推的能力，索引类型的支持等都是重要的考察内容。
    - SQL引擎不能对表连接的数量以及表的规模有任何限制，也不能要求建表的时候必须指定SHARDING KEY。

- 6.容灾能力
    - 这个能力和你的应用对高可用，灾备的要求要相匹配。可以实现自动化复制，自动化切换，最小的RTO/RPO，甚至零数据丢失是最佳的选择。

- 7.接口能力
    - 是否能够提供C语音、JDBC、ODBC/OLEDB等多种接口，支持你所是使用的主要编程语言等也是极为重要的，这对于你今后的应用开发与应用迁移十分重要。现在的数据库产品十分庞杂，有些数据库产品甚至只提供一个JDBC引擎就敢发布了。

- 此外易部署，易管理、可观测能力强、生态工具齐全、数据类型支持、字符集支持等因素也是你需要去考虑的因素。如果你还需要从老数据库上迁移数据和应用到新系统，那么与你原有数据库的SQL语法兼容性、数据复制工具、数据迁移工具的完备性与符合度等也是你必须考虑的因素。

## HTAP的数据库

- [白鳝的洞穴：HTAP是有代价的](https://mp.weixin.qq.com/s?__biz=MzA5MzQxNjk1NQ==&mid=2647847524&idx=1&sn=3746295fddcaaeff43cf1647cd22a7be&chksm=88786ef0bf0fe7e6a5916c67531f53d52fcc79e7f6b413e94089ce61c58e1dbf117bd7541ded&cur_album_id=2004584439858692098&scene=189#wechat_redirect)

- 亚马逊的Aurora

- Oracle的Mysql HTAP方案HeatWave
    ![image](./Pictures/database_concept/HTAP-HeatWave.avif)
    - 只能在Oracle Cloud上购买，没有线下版，暂时是没法去享用了。
    - Mysql HeatWave是在Innodb引擎上部署一个HeatWave的插件，会自动将Innodb中需要下载到Heatwave节点的数据发送给分布式的Heatwave集群，这个集群是一个内存数据库集群，最多64个节点，在内存中会产生一份数据表的列存副本。
    - 当SQL引擎发现查询是一个OLAP或者ML应用请求时，自动会卸载给Heatwave引擎去处理。从而实现OLTP/OLAP的负载分离，以及实现OLAP的高性能（内存+列存）。
        - 实际上AlloyDB、Aurora等也采用OFFLOAD的方式来减轻主实例的负担，只是实现方式不同。
    - Heatwave的数据会持久化到一个OCI存中，从而减少系统重启时恢复列存数据的开销。
    - 所有的客户端都是连到一个MYSQL实例上操作，不管OLTP/OLAP还是ML，会不会让这个MYSQL实例成为系统的瓶颈呢。答案是否定的，因为Heatwave集群可以接受来自MYSQL实例的下推，在集群内实现大量的计算操作，从而减轻MYSQL主实例的负担。
        ![image](./Pictures/database_concept/HTAP-HeatWave1.avif)

- 谷歌推出了第一个HTAP云原生数据库AlloyDB for Postgresql

    - 比较可贵的是，AlloyDB是通过PG的Extension实现的，今后完全可以随着PG社区版的发展而发展。

    - 选择PG引擎的原因我就不讨论了，最主要是Alloy的集群解决方案，这个集群中包含一个主节点和一个read pool。

        ![image](./Pictures/database_concept/HTAP-AlloyDB.avif)

        - 如果看上面的图，AlloyDB 真的和Aurora十分相似。都是一个基于LOG的共享存储读写分离的数据库（国产的Polardb-O/PG也采用了类似的架构）。

    - 不过AlloyDB不仅仅如此，它还引入了一个类似Oracle HeatWave的机制，那就是列存内存，在实现方法上，AlloyDB和Oracle in-memory db更为类似。
        - 与Heatwave相同的是，对于需要创建列存的表，需要手工装载，Heatwave使用alter table,AlloyDb用SELECT google_columnar_engine_add('xxx');

        - AlloyDB没有学习Heatwave一样疯狂的用硬件来砸性能，所以在谷歌的官方文档中，仅仅号称AlloyDB比原生PG快4倍。而在一些朋友的实际测试中，一些大型统计SQL性能提升几十倍还是有的。

    - 谷歌在整体实现架构上的另外一个优化是针对WAL APPLY的优化，在只读节点，Alloydb仅仅重演在主实例CACHE中的数据，其他的数据不需要做WAL重演，直接从数据文件中获取就可以了。

- SnowFlake也发布了一个HTAP数据库产品Unistore

- 除了Polardb之外，国内的大多数具有HTAP能力的数据库产品都是分布式数据库。

    - 提到国产的具有HTAP能力的数据库产品，就不得不提到两个头部产品TIDB和Oceanbase。

    - TIDB：
        - 早期在OLAP能力上是比较弱的，因此需要使用TISPARK来进行一些复杂的AP操作。
        - TP操作走TIDB引擎，分析操作走TISPARK引擎。
            - 虽然也实现了一份数据两种计算，不过实现的并不优雅。因此在TIDB 4.0中推出了列存储TiFlash。同时引入了ClickHouse的计算层，辅助TiDB进行AP计算。
        - 数据写入TiDB是行存储，这符合OLTP应用的特征，不过在做MERGE的时候，会生成一个列存的TiFlash副本，用以支撑AP工作负载。
            - 在TiDB计算层可以自动识别访问负载，自动将AP负载OFFLOAD到TiFlash层。

        - 到了TiDB 5.0，这种OFFLOAD和计算协同机制更加成熟，算子下推到ClockHouse计算层的粒度更为细化，类似Heatwave的这种协同计算机制可以让TiFlash层负担更多的AP计算负载，向TiDB层返回的数据的加工程度更高，这样就进一步提升了AP工作负载的性能，同时让TP计算负载不会因为AP负载较大而受到较大影响，从而实现一部分TP/AP隔离的能力。虽然目前TiDB在这方面的技术还不够完美，不过我想随着版本的演进，这方面会进一步得到提升。

        - TiDB是通过一个额外的TiFlash副本来实现AP负载的OFFLOAD的，这其实也是需要额外的成本的，不仅仅是存储成本，还有计算成本。还有从TiKV副本生成TiFlash副本的成本，这些成本不仅仅是在投资上，在数据库系统高负载运行的时候，难免会产生一些对TP业务的影响，产生系统的抖动，如果这些抖动控制的不好，则会引起SQL执行延时的不稳定。这方面也是今后TiDB重点优化的地方。

    - OceanBase：没有使用额外的列存，整个OB的存储是统一的，采用了基于微块的混合列压缩技术的行列混存技术。最早使用这个技术的知名数据库产品是Oracle的Exadata，Oracle当年就是利用这种技术，将计算负载OFFLOAD到CELL单元，通过SmartScan等技术在一个OLTP数据库上利用高性能硬件实现了令人瞠目结舌的OLAP工作能力。我想OB大概也在从中吸取必要的养分。
        - OB分离TP/AP负载还通过对副本的只读访问，通过HINT，OB中可以指定一些非强实时性的AP访问可以十分放心的访问异步的副本，从而进一步减轻AP负载对TP负载的影响。
            - 这种机制是对应用开发十分友好的，重要应用开发团队掌握了这种使用技巧，可以玩出很多花样来。
            - 前阵子看到一个携程团队的分享，通过改造OBPROXY，引入了几个参数，可以让应用不使用HINT，只是通过连接专门的OBPROXY就可以实现这种工作负载的自动隔离。另外OB的资源管理器也可以对AP负载进行资源总量的控制，从而确保集群中TP应用的平稳运行。

# 数据库对比

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

# 数据存储结构

- [云数据库技术：程序员必备的数据库知识——数据存储结构](https://mp.weixin.qq.com/s/gWXaSsZLt4dM-JJKJn2kWQ)

- 本文介绍了五种常见数据存储结构，另外还有图、表格、链式、R-TREE等数据结构并未涉及

| 类型         | 优点                                 | 不足                             | 应用场景            | 表数据库                              |
|--------------|--------------------------------------|----------------------------------|---------------------|---------------------------------------|
| HEAP         | 基本数据结构 结构简单 全表查询性能好 | 没有查询优化                     | OLTP表数据          | Oracle(堆表) MySQL(MyISAM) PostgreSQL |
| B+TREE       | 小数据量查询性能高 响应时间稳定      | 全表查询性能差 维护复杂          | OLTP索引 OLTP索引表 | Oracle(索引组织表) MySQL(InnoDB)      |
| COLUMN-STORE | 按字段查询性能好 压缩存储            | 单行查询差 实时更新难            | OLAP                | ClickHouse Snowflake Greenplum        |
| LSM-TREE     | 写入友好 压缩存储                    | 查询效率差（二级索引，范围查询） | 大吞吐量读          | 日志写入 大数据量管理                 | HBase OceanBase RocksDB MySQL 的MyRocks存储引擎|
| HASH         | 资源使用率高 相比String性能更好      | 集群下无法大规模使用             | NoSQL               | Redis Memcache                        |

- 常见关系型数据库逻辑架构单元从小到大是：块(block，MySQL称为page 页) > 区(extent) > 段(segment) > 表空间(tablespace)。
    ![image](./Pictures/database_concept/MySQL-InnoDB逻辑存储架构图.avif)
    - 块是数据库存储的最小单元，也是最小逻辑存储结构。不同数据库块的默认大小不一样，MySQL是16k，Oracle是8k。当数据写入块中，如果一条数据过大，就会连续占用几个块。块和块之间并不一定在物理上相连，只是在逻辑上使用双向链表关联，它们之间的物理位置有可能很远，所以数据库一般不以块作为最小的存储分配单位。
    - 区（extent）是由一个或多个连续的块组成，区是Oracle和MySQL数据库的最小分配单位。
    - 段（segment）是由一个或多个区组成。它可以是连续的，也可以不连续。它是一个独立的逻辑结构，是存储对象、表、索引的数据对象，一个段属于一个数据对象，每创建一个新的的数据对象，就会创建新的独立段。
        - 不同类型的数据对象有不同的段：数据段、索引段、回滚段、临时段。
        - 表空间（tablespace）是逻辑结构最高一级，数据库由一个或多个表空间组成，一个表空间则对应着一个或多个物理的数据文件，常见的表空间有数据表空间、索引表空间、系统表空间、日志表空间。

- HEAP

    - Heap表，也就是堆表，是Oracle数据库最常见、也是默认的表类型。堆表的数据会以堆的方式管理，意味着它的数据存取是随机的。数据库写数据时，会找到能放下此数据的合适空间。从表中删除数据时，则允许以后的写入和更新重用这部分空间。

        - 比如先插入一个小行，接着插入一个大行，而且这个大行无法和小行无法存储在同一个块上，接着又插入一个小行。查询这三行数据它的默认排序是：小行、小行、大行。这些行并不按插入的顺序显示的，Oracle会找到能放下此数据的合适空间，而不是按照时间或者事务的某种顺序来存放。

    - 堆表的特点是数据存储在表中，索引存储在索引里，这两者分开的。数据在堆中是无序的，索引让键值有序，但数据还是无序的。堆表中主键索引和普通索引一样的，都是存放指向堆表中数据的指针。

- B+TREE

    - MySQL InnoDB 引擎将数据划分为若干页（page），以页作为磁盘与内存交互的基本单位，页默认的大小为16KB。这样每次磁盘IO至少读取一页数据到内存中或者将内存中一页数据写入磁盘，通过这种方式减少内存与磁盘的交互次数，从而提升性能。page的格式如下图：
        ![image](./Pictures/database_concept/B+TREE的page.avif)

    - MySQL InnoDB 引擎是使用B+Tree，B+Tree的特性是主键索引（又称聚集索引）的叶子节点保存的是真正的数据，而辅助索引（又称二级索引、非聚集索引）叶子节点的数据保存的是通过指向主键索引然后获得数据（也就是只根据辅助索引查询，需要进行一次回表）。

- CLOUMN-STORE

    - 传统的在线业务系统（OLTP）一般是以行存的方式，因为一行一行的写入读取符合在线业务场景。在联机分析处理系统（OLAP）中，常常需要统计分析某些列的数据，并对其进行分组、聚合运算，此时使用列存将会更高效。
        - 因为这样可以避免读取到不需要的列数据，另外同一列中的数据类型存储在一起也十分适合压缩，从而一个块可以存储更多的数据。

    - Apache Parquet是面向分析型业务的列式存储格式
        - 一个Parquet文件的内容有Header、Data Block和Footer三部分组成。
            - Data Block是具体存放数据的区域，它由多个Row Group（行组）组成，每个Row Group包含了一批数据。在Row Group中，数据按列汇集存放，每列的所有数据组合成一个Column Chunk（列块），一个列块具有相同的数据类型，不同的列块可以使用不同的压缩。因此一个Row Group由多个Column Chunk组成，Column Chunk的个数等于列数。每个Column Chunk中，数据按照Page为最小单元来存储，根据内容分为Data Page和Index Page。如下图。
            ![image](./Pictures/database_concept/Parquet-data_block.avif)

- LSM-TREE
    - 简单说LSM是一种磁盘严格顺序写入、数据分level存储、每level的数据都按主键（Key）排序后存储、各level中的数据会定期merge然后写入下一level等特性的数据结构
    - 顺序写的性能比随机写性能好很多，通过顺序写替代随机写，提升数据库性能是常见的方法之一，比如WAL技术。LSM 的数据数据写入是日志式的（append only）顺序写入，写入数据时直接追加一条新记录。
    ![image](./Pictures/database_concept/lsm-tree.avif)
    - 当进行写数据时。先写入 Memtable 和预写日志(Write Ahead Logging, WAL)。因为Memtable 是内存操作，防止掉电需要将记录写入磁盘中的 WAL 保证数据不会丢失。当 MemTable 写满后会被转换为不可修改的 Immutable MemTable，并创建一个新的空  MemTable。后台线程会将 Immutable MemTable 写入到磁盘中形成一个新的 SSTable 文件，并随后销毁 Immutable MemTable。
    - SSTable (Sorted String Table) 是 LSM 树中在持久化存储的数据结构，它是一个有序的键值对文件。LSM 不会修改已存在的 SSTable，LSM 在修改数据时会直接在 MemTable 中写入新版本的数据，并等待 MemTable 落盘形成新的 SSTable。这样保证在同一个 SSTable 中 key 不会重复，但是不同的 SSTable 中还是会存在相同的 Key。
    - 当读取数据时。因为最新的数据总是先写入 MemTable，所以在读取数据时首先要读取 MemTable 然后从新到旧搜索 SSTable，找到某个 key 第一个版本就是其最新版本。我们知道，刚写入的数据是很有可能被马上读取的，因此MemTable 还起到了很好的缓存作用。
    - 随着不断的写入 SSTable 数量会越来越多，数据库持有的文件句柄(FD)会越来越多，读取数据时需要搜索的 SSTable 也会越来越多。另一方面对于某个 Key 而言只有最新版本的数据是有效的，其它记录都是在白白浪费磁盘空间。因此对 SSTable 进行合并和压缩(Compact)就十分重要。在合并和压缩的过程中，会遇到读放大、写放大、空间放大等问题，这些不同的问题需要做取舍，也就诞生了多种合并压缩策略。

- HASH

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

# 行业

- [AustinDatabases：临时工说：云DBA 该做什么，云灭了DBA 不可能，完全不可能](https://mp.weixin.qq.com/s/rJmHVdlr42-rBcnCijFo4A)

- 基于云的特性，对比线下的数据库产品
    - 优点：基于云维护的方便和安全
    - 缺点：
        - 1.一会这个不行没权限
            - 例子：上周的一个工作，将数据导入到POSTGRESQL数据库中，线下分分钟解决的问题，线上就不行了，你没权限就是最大的权限也不行，因为这涉及了云数据库的底线，无法直接访问磁盘，然后客服给了3种方案，在给出了第一时刻我们就灭了2个方案，还剩一个方案给出的文档也不对，最后还是我们给纠正了，最终把这个工作完成了。
        - 2.一会那个不行因为云数据库本身不支持
        - 结论：原来直来直去的事情，到了云上就非常的困难，你需要更深的知识层次来提高自己，你需要掌握完成这个工作更多的方法，并规避云不提供的方式来进行相关的工作，对于部分工作，云增加了工作量，而不是减少了。

- 很多企业认为上云就可以FIRE DBA，你当然可以，但后面的烂摊子你就自己拾掇吧
    - 到底这个云数据库的为什么不能扩展了
    - 为什么这个数据库OOM了
    - 为什么这个数据库违反了什么条款，就被封禁了
    - 为什么明明这个数据库还有 50%的磁盘空间，他就锁定了。

    - 然后你就和那些所答非所问的云客服，搅和一天，最终你还是明白不了这些都是为什么，实际上那些客服有的自己也不明白，说句大言不惭的话，我还教授过一些知识给这些客服，这些客服还拿着我的文章在给我解释某些数据库的故障，当我告诉他，你有点搞笑，拿着我写的文章 告诉我怎么回事，最后我们双方都笑了好尴尬呀 ！
        - 这就透露了另一个问题，你要不专业，那么云客服玩弄你，分分钟的事情，此时那些领导们，你还认为 你手里没有一个厉害的DBA 被人欺骗玩弄是一件，非常赏心悦目的事情吗？

## 云数据库

- [云数据库技术：云数据库价格一瞥](https://mp.weixin.qq.com/s/EJTH_RLLPHQ98yt2dp65zg)

# 业务

- 2019年淘宝 11.11 活动。去年 11.11 一共成交了 12.92 亿笔订单，在电商领域是核心业务。算了一下，差不多每秒 15000 笔下单的操作。

    - 看起来还好并不高，但这是个平均值，我们要看峰值。11.11 前 1 小时肯定是最高峰的，根据我的经验，峰值少说应该是平均值的 10 倍，但 11.11 少说是 20 倍。

    - 每笔事务里有 5 - 6 次 SQL Query 操作，那 QPS 就可能达到 150 万。

# 第三方工具

- [ingestr：不同数据库的数据源导入导出](https://github.com/bruin-data/ingestr)

## sql

- [natural-sql：文本生成sql的llm模型](https://github.com/cfahlgren1/natural-sql)

- [SQLkiller：在线的AI生成sql语句](https://www.sqlkiller.com/)

- [sqlfluff: sql语句语法检查](https://github.com/sqlfluff/sqlfluff)

- [sql-formatter：sql语句格式化的js库](https://github.com/sql-formatter-org/sql-formatter)

- [Migrate：数据库迁移/变更工具](https://github.com/golang-migrate/migrate)

    - 支持 MySQL、MariaDB、PostgreSQL、SQLite、Neo4j、ClickHouse 等不同类型的数据库。

- [sqlmap: 自动检测和利用 SQL 注入漏洞，获得数据库服务器的权限。](https://github.com/sqlmapproject/sqlmap)

- [SQLGlot：sql转换器，支持20多种如DuckDB, Presto / Trino, Spark / Databricks, Snowflake, and BigQuery.](https://github.com/tobymao/sqlglot)
    ```py
    import sqlglot

    # SQL 转 Spark
    sql = """WITH baz AS (SELECT a, c FROM foo WHERE a = 1) SELECT f.a, b.b, baz.c, CAST("b"."a" AS REAL) d FROM foo f JOIN bar b ON f.a = b.a LEFT JOIN baz ON f.a = baz.a"""
    print(transpile(sql, write="spark", identify=True, pretty=True)[0])
    ```

- 客户端

    - [harlequin：sql tui](https://github.com/tconbeer/harlequin)
        ```sh
        // sqlite
        harlequin -a sqlite "path/to/sqlite.db" "another_sqlite.db"

        // DuckDB
        harlequin "path/to/duck.db" "another_duck.db"

        // mysql
        pip install harlequin-mysql
        harlequin -a mysql -h localhost -p 3306 -U root --password example --database dev
        ```

## AI

- [sqlchat](https://github.com/sqlchat/sqlchat)

- [DB-GPT:local GPT](https://github.com/csunny/DB-GPT)

- [Chat with your SQL database 📊. Accurate Text-to-SQL Generation via LLMs using RAG](https://github.com/vanna-ai/vanna)

- [vanna](https://github.com/vanna-ai/vanna)
    - 与你的 SQL 数据库聊天。该项目使用 LLM+RAG+数据库技术，让用户能够通过自然语言查询 SQL 数据库，用生成的 SQL 回答你的问题。

## 画图

- [dbdiagram：在线创建数据库的实体-关系图的工具](https://dbdiagram.io)

- [drawdb：数据库实体关系（DBER）在线编辑器，无需注册即可直接在浏览器中使用。它提供了直观、可视化的操作界面，用户通过点击即可构建数据库表和导出建表语句，还可以导入建表语句，实现可视化编辑、错误检查等。支持 MySQL、PostgreSQL、SQLite、MariaDB、SQL Server 共 5 种常用的关系数据库。](https://github.com/drawdb-io/drawdb)
    - [在线运行](https://drawdb.vercel.app/editor)

## gui客户端工具

- MySQL Workbench：这是 Oracle 公司开发的一款免费的 MySQL 集成环境。MySQL Workbench 提供了数据建模、SQL开发、数据库管理、用户管理、备份等功能，并支持导入和导出数据，以及与其他数据库进行交互。MySQL Workbench 面向数据库架构师、开发人员和 DBA。 MySQL Workbench 可在 Windows、Linux 和 Mac OS X 上使用。

- HeidiSQL：HeidiSQL 是免费软件，其目标是易于学习。“Heidi”可让您查看和编辑运行数据库系统 MariaDB、MySQL、Microsoft SQL、PostgreSQL 和 SQLite 的数据和结构。

- phpMyAdmin：phpMyAdmin 是一个用 PHP 编写的免费软件工具，旨在通过 Web 处理 MySQL 的管理。 phpMyAdmin 支持 MySQL 和 MariaDB 上的各种操作。 常用的操作（管理数据库、表、列、关系、索引、用户、权限等）可以通过用户界面执行，同时您仍然可以直接执行任何 SQL 语句。

- Navicat for MySQL：Navicat for MySQL 是管理和开发 MySQL 或 MariaDB 的理想解决方案。它是一套单一的应用程序，能同时连接 MySQL 和 MariaDB 数据库，并与 OceanBase 数据库及 Amazon RDS、Amazon Aurora、Oracle Cloud、Microsoft Azure、阿里云、腾讯云和华为云等云数据库兼容。这套全面的前端工具为数据库管理、开发和维护提供了一款直观而强大的图形界面。

- DBeaver：DBeaver 是一个通用的数据库管理和开发工具，支持包括 MySQL 在内的几乎所有的数据库产品。它基于 Java 开发，可以运行在 Windows、Linux、macOS 等各种操作系统上。

- DataGrip：DataGrip 是一个多引擎数据库环境，使用者无需切换多种数据库工具，即可轻松管理 MySQL 等数据库。DataGrip 支持智能代码补全、实时分析和快速修复特性，並集成了版本控制。

- SQL Developer：這是一款由 Oracle 公司开发的集成开发环境（IDE），它专为数据库管理和开发而设计。这款工具提供了从数据库设计、建模、开发到维护的一站式服务，使得开发者能够在一个统一的界面中完成所有的数据库相关工作。Oracle SQL Developer 是基於 Java 開發的，不僅可以連接到 Oracle 数据库，也可以连接到选定的第三方（非 Oracle）数据库、查看元数据和数据，以及将这些数据库迁移到 Oracle。

- [dbgate](https://github.com/dbgate/dbgate) 是一款跨平台数据库管理工具，它适用于 MySQL、PostgreSQL、SQL Server、MongoDB、SQLite 及其他数据库，可在 Windows、Linux、Mac 运行。dbgate 还可以作为 Web 应用程序运行，使用户能够通过浏览器轻松访问和管理数据库。

- [mayfly-go](https://github.com/dromara/mayfly-go)web 版 linux(终端[终端回放] 文件 脚本 进程 计划任务)、数据库（mysql postgres oracle sqlserver 达梦 高斯 sqlite）、redis(单机 哨兵 集群)、mongo 等集工单流程审批于一体的统一管理操作平台

- [FastoNoSQL](https://github.com/fastogt/fastonosql)支持Redis, Memcached, SSDB, LevelDB, RocksDB, UnQLite, LMDB, ForestDB, Pika, Dynomite, KeyDB

- [Chat2DB](https://github.com/chat2db/Chat2DB)集成了AI和BI报表功能的新一代数据库管理系统。支持MySQL, PostgreSQL, H2, Oracle, SQLServer, SQLite, MariaDB, ClickHouse, DM, Presto, DB2, OceanBase, Hive, KingBase, MongoDB, Redis, Snowflake

# 数据库流行度

- [db-engines：数据库流行度排行榜](https://db-engines.com/en/)

    - [db-engine 数据分析](https://demo.pigsty.cc/d/db-analysis)

- [墨天轮国产数据库排行榜](https://www.modb.pro/dbRank)

- [StackOverflow 7年调研数据](https://demo.pigsty.cc/d/sf-survey/stackoverflow-survey?orgId=1)

## 国产数据库

- [爱可生开源社区：第八期话题：国产数据库，TiDB、巨杉、OceanBase，谁会最终胜出？](https://mp.weixin.qq.com/s/M6W-6wvOc8zGnQnlNQhQZw)

- [未来智库：数据库行业专题研究：关键三问深度解读](https://mp.weixin.qq.com/s/RlF0eTu5xBQ-LosJ6Vt7Zg)

- [非法加冯：国产数据库到底能不能打？](https://mp.weixin.qq.com/s/AqcYpOgVj91JnkB1B3s4sA)

# 性能测试

- [ClickBench：a Benchmark For Analytical DBMS](https://benchmark.clickhouse.com/)

# 新闻

- [数据库内核月报](http://mysql.taobao.org/monthly/)
  通过搜索引擎输入以下格式进行搜索(我这里搜索的是 binlog)

  > site:mysql.taobao.org binlog

