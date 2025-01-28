
<!-- mtoc-start -->

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
      * [mysql vs postgresql](#mysql-vs-postgresql)
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
* [dba行业](#dba行业)
  * [学习](#学习)
    * [白鳝的洞穴：没有一个天才不勤奋](#白鳝的洞穴没有一个天才不勤奋)
    * [白鳝的洞穴：DBA的变与不变](#白鳝的洞穴dba的变与不变)
  * [白鳝的洞穴：知识积累能力是DBA最为重要的能力](#白鳝的洞穴知识积累能力是dba最为重要的能力)
  * [管理](#管理)
    * [白鳝的洞穴：被KPI扭曲的运维](#白鳝的洞穴被kpi扭曲的运维)
    * [白鳝的洞穴：曲突徙薪还是焦头烂额](#白鳝的洞穴曲突徙薪还是焦头烂额)
  * [销售](#销售)
    * [AustinDatabases：临时工访谈：金牌 “女” 销售从ORACLE 转到另类国产数据库 到底 为什么？](#austindatabases临时工访谈金牌-女-销售从oracle-转到另类国产数据库-到底-为什么)
  * [云数据库](#云数据库)
    * [非法加冯：你怎么还在招聘DBA?](#非法加冯你怎么还在招聘dba)
    * [非法加冯：DBA还是一份好工作吗？](#非法加冯dba还是一份好工作吗)
    * [AustinDatabases：临时工说：云DBA 该做什么，云灭了DBA 不可能，完全不可能](#austindatabases临时工说云dba-该做什么云灭了dba-不可能完全不可能)
    * [非法加冯：云计算泥石流：下云合订本](#非法加冯云计算泥石流下云合订本)
* [业务](#业务)
* [第三方工具](#第三方工具)
  * [sql](#sql)
  * [客户端tui](#客户端tui)
  * [AI](#ai)
  * [画图](#画图)
  * [gui客户端工具](#gui客户端工具)
  * [BI数据可视化工具](#bi数据可视化工具)
* [数据迁移](#数据迁移)
  * [数据迁移案例](#数据迁移案例)
    * [爱可生开源社区：技术分享 | 一次数据库迁移](#爱可生开源社区技术分享--一次数据库迁移)
  * [数据迁移工具（支持多种数据库）](#数据迁移工具支持多种数据库)
    * [CloudCanal：可视化数据同步迁移工具](#cloudcanal可视化数据同步迁移工具)
    * [DataX-Web：异构数据迁移工具](#datax-web异构数据迁移工具)
  * [ETL数据迁移](#etl数据迁移)
    * [ETL构建企业级数据仓库五步法的流程](#etl构建企业级数据仓库五步法的流程)
    * [ETL工具](#etl工具)
      * [kettle](#kettle)
      * [canal](#canal)
        * [安装](#安装)
        * [docker安装](#docker安装)
        * [配置kafka](#配置kafka)
* [数据库流行度](#数据库流行度)
  * [国产数据库](#国产数据库-1)
    * [白鳝的洞穴：体系化与碎片化孰优孰劣？](#白鳝的洞穴体系化与碎片化孰优孰劣)
  * [数据库历史](#数据库历史)
* [性能测试](#性能测试)
* [新闻](#新闻)

<!-- mtoc-end -->

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

#### mysql vs postgresql

- [非法加冯：PZ：MySQL还有机会赶上PostgreSQL吗？](https://mp.weixin.qq.com/s/xveP91NMYF4NFlIX_JcpYA)

- [红石PG：Postgres 和 MySQL，到底应该怎么选？](https://mp.weixin.qq.com/s/kT-AhModeJwTjh-UA5LHPQ)

- [红石PG：MySQL 和 PG 性能 PK，基准测试跑起来！](https://mp.weixin.qq.com/s/rgCn_uY9Dol_8DZ0cIJvuw)

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

# dba行业

## 学习

### [白鳝的洞穴：没有一个天才不勤奋](https://mp.weixin.qq.com/s/Ntgv67aXd4S_rveO-eXFgg)

- 一个程序员，35岁还只是拷贝粘贴程序员，对应用架构、数据架构、数据库、服务器、业务逻辑还懵懵懂懂，这时候想要发愤图强，可能周边的环境也无法支撑你了吧。项目经理把你当累赘，只给你脏活累活，领导也不可能提拔你。你靠什么来改变自己的命运呢？跳槽到其他公司？现在这种竞争环境，可能一面你都过不去。如果早五年，30岁的你虽然技术不怎么样，你的项目经理可能还能把你当成新手来试试有没有培养的潜力，这样你的机会还能大一些。如果你真是天才，那么35岁的你无法得到别人的赏识，自己创业可能还有点机会，否则只能看运气了。

- DBA比码农的情况会好很多，DBA的成熟年龄一般都是在35左右。我差不多也是33岁才开始从程序员、架构师改行做专职DBA的。之前的研发经历让我更好地理解数据库和应用的关系，也让我能够更深地理解数据库的内在逻辑。但是**DBA是十分讲究实战的职业，光有理论是无法提升能力的**，必须要通过实战来提升自己，你必须不断去挑战自己的能力极限才能不断突破。

- 在DBA成长的道路上，你需要不断学习各种理论知识（数据库，硬件，操作系统，应用系统，等等），看别人的经验分享，尝试通过实验来验证知识或者别人的经验。做这些工作都是需要付出时间和精力的，因此想做一个优秀的DBA你，更要勤奋。你要成为一个优秀DBA可能需要付出比成为一个优秀程序员更多的辛劳。

### [白鳝的洞穴：DBA的变与不变](https://mp.weixin.qq.com/s/Ne5jGv29A_4XODpHwTktJw)

- 大佬竖立终生方向的历程

    - 2014 年，Michael Stonebraker 获得图灵奖。让人意外的是， Michael Stonebraker 当初的博士论文是关于马尔可夫链算法研究。但毕业时，他意识到这个研究不能谋生，于是在读了 Edgar F. Codd 发表的关系数据库的论文后，转为研究关系数据库，也因此找到了自己的终身发展方向。

    - 另一位图灵奖获得者 James Gray 年轻时进入 IBM，最初研究的是操作系统。后来，James Gray 发现数据库领域还有很多挑战，于是转为研究数据库，并在这个领域取得了巨大成就。James Gray 的《事务处理：概念与技术》几乎永久性地结束了关于事务的探讨。

    - 老盖（盖国强）最初的梦想是成为一个作家，20 年前在云南红河卷烟厂开发 ERP 软件时，接触到 Oracle，完成了技术启蒙。2001 年，老盖通过 ITPUB 技术社区，积累了丰富的个人经验，后来，他把这些经验总结沉淀为《深入浅出  Oracle》、《循序渐进 Oracle》等个人专著。2007 年，老盖成为中国第一位 Oracle ACE。
    - 白鳝（徐戟） 1992 年参加工作，从 DEC 深圳研发中心的码农，到自己创业，后来进入联想，最后离开联想再次创业，成立一家提供数据库优化服务的公司。前面 10 年在不断变化，后来的 10 年，工作以 Oracle 为核心，最近 10 年聚焦在如何让使用 Oracle 数据库的系统升级为国产数据库。白鳝说，自己“有一颗永远折腾的心”。
        - 当数据库在中国流行起来时，白鳝选择了最难的那个：“我觉得 Oracle 数据库很复杂，难以掌握，但是学好了就会是我今后价值的体现。”意识到 Oracle 会给自己的技术生涯带来帮助，白鳝多年来一直坚持学习 Oracle。即使现在已经做技术管理，业余时间还是会看一些资料，学习 Oracle 技术。他认为，过去学习 Oracle，就像现在学习国产数据库，虽然现在很多国产数据库还比较难用，但是能把它用好的人，才会产生独特价值。

- 正如老盖所言，每个行业都会奖励那些最先加入者。 1996年，正是Oracle 在中国最火的时代，白鳝受邀去北京巨龙科技参观。“我当时惊呆了，公司给 Oracle DBA 每人在北京发一套房，发一辆 30 多万的桑塔纳车。那时候我的工资才一千多，北京程序员的平均工资不到 500。”

- 白鳝认为，虽然现在的环境和三十年前不一样，但底层逻辑是相通的。对于不好用的数据库，能用好的人就有价值；好用的数据库要和应用紧密结合，才有价值。针对选择哪一款国产数据库作为未来方向，白鳝给年轻人 3 点建议：
    - 1.选择用户愿意花钱的产品，能产生利润的产品才能长久。
    - 2.选择市场占有率比较高的产品，这样未来的工作机会更多。
    - 3.选择管理复杂度高的产品，DBA 的价值能在这里得到充分体现。

- 快跑几步不如快人半步

    > 在时代潮流的裹挟下，大多数人都不甘人后，想快跑几步完成超越。但林春认为，在时代的变局中，落后太多会被淘汰，快跑几步意义不大，对普通人来说，快人半步刚刚好。如何做到“快人半步”呢？

    - 林春从 DB2 到 Oracle，从 Oracle 到 MySQL，再到现在使用 OceanBase，尤其是在中国太保集团很多重负载的系统优化中，主动处理问题，和数据库厂商一起解决问题，深入业务逻辑，不断发挥自己作为 DBA 的价值。他建议 DBA 群体深入业务学习，在工作中主动处理问题，深入应用侧、架构侧，在业务逻辑中提升技能，发挥价值。

    - 白鳝所在的公司是做第三方数据库服务，对数据库市场的变化很敏感。他周围的同事不需要行政命令，也愿意学习新的数据库知识，这是对自己职业的保障。他建议年轻人通过写作，把以往的知识、经验系统地梳理，通过总结与思考，加深自己对知识点的理解，使自己的技能和业务需求相吻合。

    - 老盖则引用了亚里士多德提出第一性原理。每个系统中都存在一个基本的命题和假设，不能被省略或删除，也不能被违反。因此老盖认为，DBA 群体需要具备终身学习的能力。无论是 Oracle数据库，还是 OceanBase 数据库，所有的知识积累都是未来前进上的基石，保持探索与学习，才能在技术进步的道路上，始终站立潮头。

- 既要脚踏实地，也要抬头看天

    - 我们身处大变局之中，只有符合时代需求，才能拿到比较高的溢价。DBA在日常工作中，不仅要沉下心去做，也要抬起头去看。

    - 老盖在《Oracle 数据库性能优化》这本书里写下一句话：兴趣+勤奋+坚持+方法≈成功。他认为，思想永无边界，但是行胜于言。每个人的际遇各不相同，无论我们在技术生涯中面临什么样的挑战，坚持可以约束自己的，别放弃，咬咬牙就过来了。

    - 老盖提到，当年一起从事数据库运维工作的人如今大多已经各奔南北，他和白鳝一直在这个领域坚持到现在。别人放弃之后，他们在这个领域里的价值也逐渐凸显。他同时建议大家多和周围的人交流，不要独自摸索，前人已经摸过河里的石头，要善于借鉴别人的经验，在成长中探索适合自己的方向和方法。

    - 白鳝建议大家注重知识的梳理和积累，并以云和恩墨的杨廷琨为例。杨廷琨坚持“日更”技术博客，将技术点烂熟于心，被大家称为“Oracle的百科全书”。白鳝认为，这种坚持不懈的总结与思考，会成为我们拓宽职业上升通道的重要基石。他在现场罗列了 DBA 的几个上升通道：

        - 1.DBA 方向，包括高级 DBA、运维专家、数据库产品经理、架构师、迁移工程师，以及数仓方向的岗位。在数字化时代，数据库方向的岗位需求量会很大，值得大家选择。

        - 2.DBA 转应用开发。DBA 岗位的视角全面，可以往很多方向发展，也适合转向应用开发，成为应用专家、云架构师、应用架构师、系统架构师，把 DBA 的能力和应用开发相结合，产生叠加优势，在开发团队中发挥独特价值。

        - 3.DBA 转向管理层。DBA 最直接的上升渠道是转向管理，如运维主管、CTO 等。在现场的嘉宾中，老盖是云和恩墨的创始人兼 CEO，而张劲涛是出行 365 的 CTO，这都属于 DBA 职业升迁通道中的天花板级别。

- 错误的选择 = 职业滑铁卢？

    > 数据库的选择既包括个人基于职业发展的选择，也包括企业基于业务发展的选型。两者出发点不同，但都期望获得长久发展，需要慎之又慎。在现场提问环节，有同学提出，对 DBA 来讲，选择一款错误的数据库产品，意味着职业生涯的滑铁卢，DBA 基于个人发展，应该如何做出选择？

    - 老盖认为，中国的数据库发展有 4 种路线：
        - 第一种是开源数据库的的衍生品
        - 第二种是商业数据库的衍生品
        - 第三种是自主研发，闭源运行
        - 第四种是自研且开源。
            - OceanBase 是年轻人值得追随的数据库之一，完全自主研发且开源。

    - 中国太保集团硬件库容大，备份恢复时间长。在升级至 OceanBase 时，没有做逻辑解耦和业务解耦，一步到位，将很多重负载的系统优化到极致。关于选择 OceanBase 带来的收益，林春介绍到：“我们的硬件成本大大节约，存储成本降低 80%，备份恢复效率提升了 5 倍。”

    - 出行365 每日交易量最高达到百万笔，之前使用的数据库要么性能不足，要么成本上吃不消，因此，出行 365 决定升级数据库。张劲涛说：“因为需要从 MySQL 的单机数据库前往分布式集群，且业务涉及到的复杂查询量非常高，倒逼我们选择一个 TP 级的、可以处理大查询的数据库。”多方考察、多次尝试之后，出行 365 逐步将所有业务系统迁移至 OceanBase。

    - 师文汇介绍说，数据库的选择要基于时代背景和数据库本身的产品力。在互联网飞速发展时期，企业注重效率和成本，新的时代背景需要新的数据库产品支撑业务发展的需要，OceanBase 正是基于这一时代背景诞生。而在后互联网时代，成本效益的概念会非常突出，非结构化的数据将会非常重要，数据库的产品力决定了接下来企业和个人的选择。

- 未来已来，DBA 路在何方？

    - 老盖认为，云和 AI 时代的到来，改变了 DBA 的工作形态，云数据库让数据库运维成为标准化流程，人人都可以成为 DBA。老盖在聊到自己的经历时提到，当初 Oracle 数据库在安装之外，还需要部署 RAC 集群，搭建 DG、MAA 架构等，而现在的数据库里，这些操作已经实现了自动化。新形势下，DBA 的价值该如何体现？

    - 白鳝在分享中给出了自己的答案。维护一个性能很好的数据库，DBA 需要深入业务，把 DBA 的技能和业务需求相结合，当出现需要人工调整的复杂参数时，就能快速定位问题，从而体现出 DBA 的价值。另一方面，DBA 也需要提升自己的开发技能。云上的标准化工具不足以管理复杂的业务系统，有时也需要根据业务具体情况开发一些自动化运维工具，管理数据库集群。

    - 师文汇认为，AI 的发展让数据库的使用和管理更加简单、易用，生产效率有了极大的提升。DBA 群体需要思考 DataBase 能为 AI 带来什么，AI 能给DBA 带来什么。他认为，AI 能做的是 task 的部分，最重要的 job 还需要 DBA 来完成。师文汇建议大家保持学习，并给 DBA 群体一些“学什么”的建议：数据库底层技术的本质，是要解决稳定性、成本、效率这三件事，OceanBase 创始人阳振坤老师曾说，不做工程就等于纸上谈兵，深入业务，用工程化的思路解决这三个问题，就能体现出自己的价值。

## [白鳝的洞穴：知识积累能力是DBA最为重要的能力](https://mp.weixin.qq.com/s/yRRwTGYuo9DJZ0Rp92OqAQ)

## 管理

### [白鳝的洞穴：被KPI扭曲的运维](https://mp.weixin.qq.com/s/-QrdZWT4U93BuCT-czyGhw)

- 从90年代DBA掌握运维的绝对话语权，业务高峰时都可以随时要求系统重启数据库到现在企业十分规范的IT管理，在管理上的进步是十分巨大的。

    - 在严格的KPI管理下，运维工作的精神本质也被扭曲了。很多时候，运维不是为了让系统跑得更好，而是为了满足KPI的要求，因此很多运维工作都是围绕KPI的，而不是围绕运维的最终目标的。

- 为什么会出现KPI扭曲运维的问题呢？
    - 基于KPI的管理体系本身没有问题，有问题的其实是我们的运维体系。因为我们的运维工作还没有数字化，没有从系统运行中抽取出全面合理的系统运行状态相关的指标并加入到KPI体系中，因此所有的KPI都是面向管理的，没有面向系统运行状态本身的，在大多数企业里，KPI都会存在严重背离运维工作本质的方面。如果不能很好地处理这些问题，那么我们的运维工作中的这种KPI扭曲，将会一直存在下去。

- 例子：

    - 十多年前，我去一个客户那边做巡检。采集数据的时候发现运维组突然乱了起来，说是一套核心系统的RAC的 一个节点突然宕机了。我帮忙看了一下，正好是业务高峰期，系统负载不低，单节点宕机后，应用都切到另外一个 节点上了，那个节点的负载也很高，GC REMASTER速度有点慢，不过还凑合能接受，而对于宕机的实例，宕机前出现了一些ORA-600和ORA-7445，报错信息比较陌生，需要进一步分析。我建议他们先查查宕机原因，不急着重启，等几个小时后业务高峰过去后，并且已经搞明白了实例宕机的原因再重启故障节点。反正当前业务连续性也没受到严重影响。

    - DBA主管坚持要立即重启数据库，他说如果不能在30分钟内恢复实例，他们会被扣绩效。当时我就十分不理解这种绩效考核，RAC还有一个节点正常工作，业务连续性是没问题的，为啥还要影响DBA的绩效。经过一顿匆忙的操作，故障实例没有恢复，反而好的那个节点也自动重启了。于是只能关闭两个节点，然后重新启动。整个处置过程造成了业务停服30分钟+，按照公司的考核规定是一个四级事故。

    - 点评：如果不尽快恢复故障节点，如果正常节点再宕了，运维部门是承受不了的。而我们无法确保活着的节点不出问题，因此就无法不制定这样的管理要求。如果我们能够确保或者的节点在营业厅关门前不会宕机，那么我们还需要立即去恢复故障节点吗？亦或是这套RAC集群如果有三个节点，我们还需要立即去做恢复工作吗？KPI不能保障系统的可用性，合理的架构才可以。

- 例子：

    - 月底给一家银行做巡检的时候发现RAC的一个节点因为遇到Oracle 10g的一个BUG，RAC两个节点的共享池都出现了较为严重的碎片。这个问题只能通过重启数据实例来解决问题，我建议他们尽快在晚上交易量较少的时候申请一次重启，一个实例一个实例来，先重启共享池碎片比较严重的那个实例。当时银行的DBA主管和我一起讨论了重启的方案，说争取晚上就把这个变更做了。

    - 第二天我和他在微信上聊了几句，问他数据库重启了没有。他说申请没获得批准，因为根据考核要求，本月的停机检修时间已经满了，反正月底了，下周再搞吧。当时我想离下周也只有几天时间了，也没当回事。没想到第二天下午3点多，系统就出大事了。那个碎片更为严重的节点首先大量报ORA-4031,然后就宕机了。在RAC RECONFIG的时候，活着的节点又HANG住了，业务卡顿了五六分钟才逐渐恢复正常。半个小时内出现了大量核心交易超时和失败，DBA团队被扣绩效是没跑了。

    - 点评：SLA的KPI虽然重要，但是KPI也不能凌驾于运行安全之上。如果遇到有较为紧急的运维变更操作，是不是可以通融一次呢？实际上这个事情对于领导来说也是个难题，因为DBA无法量化故障风险，因此领导也无法在KPI和运维风险之间做出正确的判断。如果DBA明确告诉领导，系统不重启，第二天十有八九会出事故，我想在领导眼里，KPI都可以见鬼去了。可惜当时DBA和我都没有给出一个十分量化的结论，以至于这件事的优先级没有被足够提升，DBA也错失了一次立功的机会。从另一个角度看，如果当时做了重启，系统恢复正常了，谁又会知道DBA立了功呢？

### [白鳝的洞穴：曲突徙薪还是焦头烂额](https://mp.weixin.qq.com/s/uIPBl4jF8nrLqZyd8MPP2A)

- “曲突徙薪无人问，焦头烂额座上客”，这句话出自《汉书.霍光传》中的一个故事。
    - 火灾没发生前指出火灾隐患，提出优化建议的人不会让人重视，甚至会让人讨厌
    - 火灾发生后帮人救火，弄得焦头烂额的人，是可以被当成座上宾来款待的。

- 实际上这句话用在DBA行业里，特别的贴切。昨天的文章中提到一个问题，似乎DBA里外难做人。
    - 遇到一个问题，提前消缺了，那么就会有人质疑如果不做操作，是不是也没问题，或者说领导对此毫无感知，不知道你的贡献；
    - 而如果没做操作，系统出了问题，领导 又会说，为啥明明知道系统带病也不及时处置，你这活是怎么干的！

- 例子：
    - 大概8、9年前，我帮一个国企处理过一个Oracle SCN HEADROOM的问题，当时我和该企业的IT老大说这个问题十分严重，如果不能尽快找到故障源，很快全网大几千套Oracle数据库会出现大面积的宕机故障。领导在我的说服下同意采取措施，在我和几个客户数据库专家的统筹指挥下花了差不多三天三夜的时间，在几十个省市公司的技术人员不眠不休地工作下，在数百个机房的几千台服务器中终于定位了故障源。当时大家都很高兴，领导也在大会小会上表扬这件事情。
    - 不过很快一些质疑的声音出现了，说我小题大做，哪怕当时不做处置，我说的宕机问题也不一定会出现。说实在的，当时想要自证清白是相当不容易的。幸亏正好Oracle的一个负责研发的总监到访中国区，我们邀请了他和客户做了一次现场交流。他用AT&T的那个十分惨痛的例子给各位领导上了一堂课，才算给我作了一个背书，否则真的跳进黄河也洗不清了。

- 原因：有些时候曲突徙薪的成本太高了，企业的IT费用可能无法支撑。

    - 例子：几年前我曾经给一个企业负责运维的领导提出过一个“常态化优化”的方案，他开始十分感兴趣，因为这是提升整体运维水平的一个很好的方案，不过核算了成本，盘点了他们各个省公司技术人员的能力水平后，他认为以当前他们自有的能力无法做到对系统的巡检和问题闭环，如果请外部团队来做，成本又过高。因此这个工作无法开展下去。

    - 在我的这些年的运维工作中，遇到了大量的类似问题。做优化消缺对于运维工作提升肯定是有价值的，但是如果从成本上考虑，很多企业还是宁可让系统凑合跑着，出大问题的时候再花大价钱去请专家来解决问题。这种看似不合理的工作方法，在很多情况下可能是最节约成本的，因此往往会被大多数客户所采用。

    - 再来看看这个常态化优化的项目，如果需要专家到各个省市去做现场分析与实施，成本是极其高昂的，没有几个企业能够承受这种成本。只有把这项工作都数字化了，成本大幅度下降了，这项工作才有开展的可能。数据采集、数据分析、各种分析报告的生成都变成自动化了，专家只要坐镇中央，协助各个数据中心做三线分析。并将分析后的优化建议下发给各个数据中心的一线二线运维人员。那么只需要组织少量的专家参与这个事情，就可以把常态化优化这个工作做起来。

    - 而面对广大的中小企业客户，如果存在一个SAAS服务平台，能够让这些企业用户每年只花费几千块钱，就能够享受到此类的服务，那么我想很多企业可能还是会花这个钱的。

- 在降本增效成为大多数企业的策略性选择的今天，我们依然需要考虑曲突徙薪，尽可能避免焦头烂额。不过如何采取更加高效率低成本的方式来做曲突徙薪的事情，应该是企业应该深入思考的问题。

## 销售

### [AustinDatabases：临时工访谈：金牌 “女” 销售从ORACLE 转到另类国产数据库 到底 为什么？](https://mp.weixin.qq.com/s/Xd_x_zpAYa3CFQ_T0pOQFA)

- 今天的被访者是一位女销售，一位曾经在ORACLE 集成商做销售部门领导的女士，曾经在销售中创造了一次一次的不可能逾越的销售业绩，实际上我能这样说，对她的了解是从前前单位认识的，之前在金融属性的企业，使用了ORACLE 数据库，基于临时工对于ORACLE 浅薄的知识，对于数据库偏科的严重，除了ORACLE 对于其他的数据库还算专业，也因为ORACLE的赛道卷的厉害，单位也招聘了ORACLE 的数据库管理员，可基于金融的属性以及当时作为数据库部门的负责人的双重要求下，还是要找一个外包来进行ORACLE的兜底的，和这个销售是在这样情况下认识的。

- 在认识的时候，她也是她们公司金牌的销售，基于对于当时我工作的那个企业的名气和后续可能带来的其他的合作，她一次一次的通过她的专业和真诚，最终在与一些知名企业一起投标PK后，拿到了ORACLE 维保服务合同，她与其他的一些销售不同，她是一个有骨气的女销售，说话并不软，可能和她带了一群销售的下属有关，但为人在我看来是真诚的，至少不让我讨厌。此篇的故事被访者就从她开始。

    - 金牌女销售：X总您好，好久没联系了，您最近挺好的吧，听说您换工作了，我这还没有拜访您，这里和您抱歉了，最近我也换了工作，我现在在国产数据库XXX公司，因为产品好，您对于数据库产品的文章我也看了一些，特别想和您介绍一下我们公司的产品，让您也鉴别一下，我有没有转错行，哈哈。

    - 临时工：啊，哦，嗯，（临时工脑子在转，这人谁呀，哦这不是那个ORACLE 女销售），你好，你怎么转行了，不是你不是销售ORACLE维保和ORACLE的产品，怎么换公司了。

    - 金牌女销售：嗯，我换了，我对国产数据库非常看好，所以我加入了XXX公司，人总的往前看，我对我们的产品特别有信心，同时我们在开源社区也非常积极，我这有我们公司的资料，您看看。

    - 临时工：好，我看看，诶这是 XXX 数据库，这个数据库可是不和那帮子关系型数据库卷了，嗯但

    - 金牌女销售：我知道您想说的是，这产品卖得出去吗，我和您说，特别好，我们已经在华南市场站住脚了，我现在负责华北市场，我们这个产品在存算能力上特别的突出，我这刚来这，您先看看资料，我这就不打扰您了。

    - 临时工：我插一句，其实我觉得这个产品到是剑走偏锋，和那一堆数据库不在一个竞争的市场，的确，要我说有点小清新，但你从新开拓市场，现在的经济环境，做ORACLE 不好吗？我觉得现在应该保守一些，你说呢？

    - 金牌女销售：（沉默了一会），我知道的，您有时间吗，我和您唠叨几句，实际上我也不愿意换单位，但没有办法，ORACLE 维保和部分市场实在是难做，基本上在我这是接近尾声了，您知道的之前，我去原来您们单位，我是连轴转的，我一个女的，满世界飞，我记得您有一次看我眼睛里面都是血，您还说，让我看看去。

    - 但市场不行了，这没有办法，另外我也的为我未来考虑，终究我一个女性不早做打算，我最后只能回家看孩子，退出社会的大舞台，后面就只能剩下家里的锅台的小舞台了，虽然我不年轻了，我也失去原来的资源，客户，甚至职位，从头做起。但那又能怎么样，我现在不需要眼泪，我需要客户，我需要比以前更努力，我这里已经深入的学习我们公司的产品，您可以考我，看看我不做ORACLE 是不是干这个也能专业，虽然我是销售，但我也不希望做一个别人 嘴里的 “女销售”， 我有我的专业性。

- 临时工：好，其实我最近在做一个访谈系列，其实你是误打误撞，我挺想采访你的，不知道你有没有时间，我有几个问题

    - 1.转行对你的冲击，你做ORACLE 服务的销售估计的有10年了吧或许还长，是无奈，还是针对想在国产数据库赛道上 试一试？
    - 2.虽然你的产品的确小清新，但可能会不好卖，产品的竞品少，或者我个人浅薄我没有听说能有和你这个产品有竞品的，产品剑走偏锋是否是好事，可销售的难度大？
    - 3.年龄不饶人，我看你还是有那股冲劲，从领导，到重新开始，你心里有没有落差？

    - 金牌女销售：我这可能回答不了这么多问题，其实您对我是了解的，我这个人是比较强势的，在我的手里从来没有拿不下的单，我销售的原则是专业性，我一定要有我的专业和我的敬业精神，要不我这没有任何靠山的，我不凭我自己凭什么。

    - Oracle 我是在是做不动了，我这10年付出的太多了，我曾经为了一个大客户，去他行里想见一面，人家不见我，我没辙，当月的业绩我还差一大半，我当时只能指望他。我当时就一狠心，我就调查了一下他们行里面的各个出入口，我就站着，堵到他必经之路，他的下班吧。

    - 临时工：然后呢，你堵到他了，

    - 金牌女销售：我就在那站了5个小时，当时没觉得腿疼，就是想着他怎么还不出来 ，还不出来。等我回家，我转天起来发现我起不来了。但好在他看我不容易，给我一次机会。让我那个月的业绩过关了。有的时候，我拿下一个大客户后，我就想我怎么那么的 J ，公司里面我每次拿下大客户，后面就的把大客户的维护工作给下面的人，我每次找大客户，有的太难了我都现在想起来我都觉得，那是我吗？

    - 临时工：所以你换工作了，就是因为太难了。

    - 金牌女销售：我多难都不怕，哪怕我太难的时候，拿下客户后，在和我地下的人布置工作后，我回家关上门，我大哭一场，哭完我继续打电话找客户。原来带着技术去谈，后来技术有本事了就跳槽了，我没辙我一个不是计算机专业毕业的，我的去啃技术，如果技术不行我的顶上，我心里就是客户怎么拿下，怎么保证我的业绩，业绩不够就的有人走，都跟我干我顶多就是挨批，可下面的人就要失去工作。我也没辙惯性着，推着我干也的干不干也的干。后面ORACLE 我真的干不下去了，要不我的累死，要不下面的人就的被裁，后面我一想， 换地方，换产品。

    - 临时工：那是够难的。

    - 金牌女销售：比这难的还有的是，我还被保安抬出去过，我去XX银行，最后让人家的领导叫保安把我给请出去了。最后怎么样，照样我拿下。 还有更狠的，叫我们去做凑数，我不知道是凑数，最后我太努力了，把他们要的合作的给干下去了，后来我才知道为什么后面进驻后，老是找我们麻烦，我的这些故事都可以写本书了。曾经有一个客户，说我，“就不像一个女的，看到项目了像王八咬筷子，死都不松口”，虽然他说的不好听，但我知道这是夸我。

    - 哎呀我说了这么多，耽误您时间了。

    - 临时工：没事，你周末也和上班一样哈

    - 金牌女销售：我们没有休息日，我稍微说说我的那个数据库吧。

    - 临时工：好，不过咱们说好，如果我写到文章里面可不能有公司的名字，咱们这不是做广告。

    - 金牌女销售：行，只要给我一个机会，我先介绍一下我的这个数据库产品，首先我这个数据库产品主要的市场是数据分析类型的，尤其在现在传统数据库无法解决的，他们是二维表格，我们是点线面我们的客户他们是抢不走的，我们主要和保险，金融，以及反欺诈方面的客户有密切的合作，主要是传统数据库做那些事情他没辙，有一次我去一个行，也有一个同行业去，后面我进去足足两个点和人家介绍我们的产品，在反欺诈，保险行业，金融类行业的一些案例，那个人进去没半小时就走了。后来等我介绍完，客户和我说，那个数据库根本就不是他们要的，解决不了问题，我们这个还算比较靠谱。

    - 临时工：你们和那个数据库比可不是一个维度的，你知道你说的那个数据库算是准一线的产品了。

    - 金牌女销售：没用，她呀，要我说文不对题，人家要的是专业做反欺诈的数据库产品，她那个做不了这个活。我也是做过功课的，我去这家公司也不是随便跳的，我研究过了，我不能去卷的厉害的传统数据库，一个项目一下来八个数据库PK，销售之间卷的厉害，我的这个产品和我们卷的少，只要合适我拿下订单比较容易。

    - 您看我学习新的这个国产数据库的效果，首先我们的这个数据库主要采用的是非结构化的数据格式，支持灵活和高效的对象类型，与我们熟悉的非关系型数据库不同，它是一个以处理复杂数据关系，彻底颠覆传统表JOIN获得数据关系的一种新的方式，尤其在现在经济形势不好的情况下，对于金融，银行，保险的核心，反欺诈，他们的核心是反欺诈部门，而我们的数据库主要做的就是要对症下药，彻底将传统关系型数据库从这些部门里面赶走，比如我们应用的主要应对的是，交易反欺诈，信贷反欺诈，保险骗保，风控大模型，作弊，流氓信息溯源，等。这些都是那些传统数据库做不了的，管你是分布式，还是什么列式，只有我们是这个部分里面唯一的选择。

    - 临时工：你还真是挺聪明的，这你都研究了，不过我刚才想问的是，这个产品本身的受众面小，你销售其实也不容易吧，我估计我这个问题可以不用问了。

    - 金牌女销售：其实我是这样想的，与其去卷，然后恶性竞争，我不如在一开始就选好产品，销售是有技巧的，但是产品很重要，ORACLE那阵就是在代理商之间砸价，服务同质化利润低，特别大的客户都预定了定向的，我根本做不了，后面我在做我就有记性了，自己销售水平好，也的找到好产品，否则就是竹篮打水，空对月。

    - 临时工：你这样的销售少，学技术，搞关系，能豁的出去，还会选赛道。

    - 金牌女销售：那什么，那什么，我能在您文章里面做做我们广告吗？ 我这也是希望更多的客户认识我们的产品，我这刚开始开展业务，您还的多支持。

    - 临时工：嗯，这个，不行，我这不是广告贴，我也不做广告，这不行。

    - 金牌女销售：那这样行吗，我们有开源产品，这个能说吗，能写到文章里面吗？要不您看我一个销售，最后访谈半天我产品都没有说出去，我多失败。

    - 临时工：哎，破例，只能出现开源的产品一点介绍，要有客户想了解，他们会找你的。

    - 金牌女销售：那我就一句话，我们的开源产品可以在国产的操作系统上安装使用，国产的硬件也可以，X信，X易，X手, XXVO都是我们的客户，我们这支持处理千亿节点万亿条边的超大数据集，同时保持毫秒级查询延时的查询速度，主打业务处理关系的业务的非关系数据库，至少我们的根在FACEBOOK，我们的创始人是FB回来的，人家有经验。

    - 临时工：好了好了，你再说都知道是什么了，行今天就到这吧

    - 金牌女销售：好好好，其实我也想说，就算找不到客户，有一些同行我们也可以交流，我想的就是销售之间只要是产品不是竞争关系的，都可以合作，我也想多点人脉扩展机会。

    - 临时工：怕你了，你是真能销售。

    - 这里有想和这个女销售联系的可以加微信 jayce90988

## 云数据库

- [云数据库技术：云数据库价格一瞥](https://mp.weixin.qq.com/s/EJTH_RLLPHQ98yt2dp65zg)

### [非法加冯：你怎么还在招聘DBA?](https://mp.weixin.qq.com/s?__biz=MzU5ODAyNTM5Ng==&mid=2247485292&idx=2&sn=5b08790e3d481833e11b95da476341d5&scene=21#wechat_redirect)

### [非法加冯：DBA还是一份好工作吗？](https://mp.weixin.qq.com/s?__biz=MzU5ODAyNTM5Ng==&mid=2247485064&idx=1&sn=6225a044d8f145cdb07a21a1e0c54ad8&scene=21#wechat_redirect)

### [AustinDatabases：临时工说：云DBA 该做什么，云灭了DBA 不可能，完全不可能](https://mp.weixin.qq.com/s/rJmHVdlr42-rBcnCijFo4A)

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

### [非法加冯：云计算泥石流：下云合订本](https://mp.weixin.qq.com/s?__biz=MzU5ODAyNTM5Ng==&mid=2247488410&idx=1&sn=e44705fce4221458244e7705258ca254&chksm=fe4b2641c93caf57cc46069b82827da873af95b3e157e7e8d2943977bdd1cbb547d79bc16373&scene=21#wechat_redirect)

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

- [qstudio：分析sql执行结果的桌面工具](https://github.com/timeseries/qstudio)

## 客户端tui

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

- [lazysql：支持MySQL、 PostgreSQL、 SQLite、 MSSQL、 MongoDB](https://github.com/jorgerojas26/lazysql)

- [peepdb：支持MySQL, PostgreSQL, MariaDB, SQLite, MongoDB and Firebase.](https://github.com/PeepDB-dev/peepdb)

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

- [chartdb：在线画数据库架构图](https://app.chartdb.io/diagrams/hwomiaf01nirsyqekjqdx9gbg)

## gui客户端工具

- MySQL Workbench：这是 Oracle 公司开发的一款免费的 MySQL 集成环境。MySQL Workbench 提供了数据建模、SQL开发、数据库管理、用户管理、备份等功能，并支持导入和导出数据，以及与其他数据库进行交互。MySQL Workbench 面向数据库架构师、开发人员和 DBA。 MySQL Workbench 可在 Windows、Linux 和 Mac OS X 上使用。

- HeidiSQL：HeidiSQL 是免费软件，其目标是易于学习。“Heidi”可让您查看和编辑运行数据库系统 MariaDB、MySQL、Microsoft SQL、PostgreSQL 和 SQLite 的数据和结构。

- phpMyAdmin：phpMyAdmin 是一个用 PHP 编写的免费软件工具，旨在通过 Web 处理 MySQL 的管理。 phpMyAdmin 支持 MySQL 和 MariaDB 上的各种操作。 常用的操作（管理数据库、表、列、关系、索引、用户、权限等）可以通过用户界面执行，同时您仍然可以直接执行任何 SQL 语句。

- Navicat for MySQL：Navicat for MySQL 是管理和开发 MySQL 或 MariaDB 的理想解决方案。它是一套单一的应用程序，能同时连接 MySQL 和 MariaDB 数据库，并与 OceanBase 数据库及 Amazon RDS、Amazon Aurora、Oracle Cloud、Microsoft Azure、阿里云、腾讯云和华为云等云数据库兼容。这套全面的前端工具为数据库管理、开发和维护提供了一款直观而强大的图形界面。

- [Navicat Premium Lite](https://navicat.com/en/products/navicat-premium-lite)：Navicat的免费版

- DBeaver：DBeaver 是一个通用的数据库管理和开发工具，支持包括 MySQL 在内的几乎所有的数据库产品。它基于 Java 开发，可以运行在 Windows、Linux、macOS 等各种操作系统上。

- DataGrip：DataGrip 是一个多引擎数据库环境，使用者无需切换多种数据库工具，即可轻松管理 MySQL 等数据库。DataGrip 支持智能代码补全、实时分析和快速修复特性，並集成了版本控制。

- SQL Developer：這是一款由 Oracle 公司开发的集成开发环境（IDE），它专为数据库管理和开发而设计。这款工具提供了从数据库设计、建模、开发到维护的一站式服务，使得开发者能够在一个统一的界面中完成所有的数据库相关工作。Oracle SQL Developer 是基於 Java 開發的，不僅可以連接到 Oracle 数据库，也可以连接到选定的第三方（非 Oracle）数据库、查看元数据和数据，以及将这些数据库迁移到 Oracle。

- [dbgate](https://github.com/dbgate/dbgate) 是一款跨平台数据库管理工具，它适用于 MySQL、PostgreSQL、SQL Server、MongoDB、SQLite 及其他数据库，可在 Windows、Linux、Mac 运行。dbgate 还可以作为 Web 应用程序运行，使用户能够通过浏览器轻松访问和管理数据库。

- [mayfly-go](https://github.com/dromara/mayfly-go)web 版 linux(终端[终端回放] 文件 脚本 进程 计划任务)、数据库（mysql postgres oracle sqlserver 达梦 高斯 sqlite）、redis(单机 哨兵 集群)、mongo 等集工单流程审批于一体的统一管理操作平台

- [FastoNoSQL](https://github.com/fastogt/fastonosql)支持Redis, Memcached, SSDB, LevelDB, RocksDB, UnQLite, LMDB, ForestDB, Pika, Dynomite, KeyDB

- [Chat2DB](https://github.com/chat2db/Chat2DB)集成了AI和BI报表功能的新一代数据库管理系统。支持MySQL, PostgreSQL, H2, Oracle, SQLServer, SQLite, MariaDB, ClickHouse, DM, Presto, DB2, OceanBase, Hive, KingBase, MongoDB, Redis, Snowflake

- [whodb](https://github.com/clidey/whodb?tab=readme-ov-file)一个基于浏览器的数据库管理工具，支持 Postgres、MySQL、SQLite、MongoDB、 Redis。

## BI数据可视化工具

- [dataease：人人可用的开源 BI 工具，Tableau、帆软的开源替代。](https://github.com/dataease/dataease)

# 数据迁移

## 数据迁移案例

### [爱可生开源社区：技术分享 | 一次数据库迁移](https://mp.weixin.qq.com/s/wqjmTi1IG74wSDQx0Kl8gA)

- 总的来说数据库迁移总共分三步，和把大象装冰箱差不多。

    - 1.迁移前准备
    - 2.进行迁移
    - 3.数据验证

- 背景描述

    - 客户共有三套业务库，需要迁移至新的实例中，这里称为业务 A，业务 B，业务 C。其中业务 B 和业务 C 需要合并成一套。

- 迁移前准备

    - 迁移前准备包含：环境信息收集，数据同步，迁移前确认

    ![image](./Pictures/mysql/数据迁移案例-迁移前后清单.avif)

    - 数据同步的部分我们需要明确的是，当该步骤完成后应该保证旧实例与新实例数据实时同步，在迁移下发窗口只进行单纯的迁移以及数据验证。

- 数据同步步骤

    - 1.创建新实例

        - 创建新的实例时，尤其需要注意对比旧实例的配置文件，防止由于配置不同，导致数据在新实例出现异常。

    - 2.备份旧实例数据，导入新实例

        - 由于客户旧实例环境只能使用 mysqldump 备份，所以备份还原使用的是 mysqldump。

        - 业务 A 是可以直接全库备份的，但需要注意，全库备份不仅要备份数据，还要备份触发器，存储过程，事件。

            ```sh
            # 全库备份
            mysqldump -h127.0.0.1 -P3306 -uroot -p --default-character-set=utf8mb4 --single-transaction --master-data=2 --flush-logs --hex-blob --triggers --routines --events --all-databases > all_db.sql
            ```

        - 业务 B 以及业务 C 由于需要进行合并，并且这两个业务在各自实例中都是使用了一个单独的库，所以备份时进行单库备份。

            ```sh
            # 单库备份
            mysqldump -h127.0.0.1 -uroot -P3306 -p --default-character-set=utf8mb4 --master-data=2 --flush-logs --single-transaction --set-gtid-purged=off --hex-blob --databases  databasename  > one_database.sql
            ```

        - 在导入完成时需要注意，MySQL 5.7 全库备份时不会备份 mysql.proc 下的系统自身的存储过程，可以在执行完导入后先执行一次升级。

            ```sh
            # 执行升级
            mysql_upgrade --upgrade-system-tables --skip-verbose --force
            ```

    - 3.建立复制保证数据实时同步。

        - 将旧实例与新实例建立复制关系，保证数据实时同步 新实例与旧实例建立复制的地址建议使用 vip 进行，这样能够保证当前使用复制地址的可靠性，若无 vip 或者必须使用旧实例的从库地址进行级联复制，则一定要确保各级复制的正常运行。

        - 首先需要有复制用户，用来建立复制，若无法提供则需要专门创建一个迁移用的复制用户，该用户建议迁移结束后进行回收。

        - 业务 A 旧实例与新实例的复制建立比较简单直接正常建立就没问题。

            ```
            # 新实例的主库执行，建立旧实例到新实例的复制
            CHANGE MASTER TO MASTER_HOST='10.186.60.201',
            MASTER_USER='repl',
            MASTER_PORT=3307,
            MASTER_PASSWORD='repl',
            MASTER_AUTO_POSITION = 1;

            start slave;
            ```

        - 业务 B 与 C 需要合并，所以这次保证数据实时同步采用了多源复制的方式。

            ```
            # 在新实例的主库执行，将业务B与C的数据都复制到新实例中。
            CHANGE MASTER TO MASTER_HOST='10.186.60.209',
            MASTER_USER='repl',
            MASTER_PORT=3307,
            MASTER_PASSWORD='repl',
            MASTER_AUTO_POSITION = 1 FOR CHANNEL 'channel1';

            CHANGE MASTER TO MASTER_HOST='10.186.60.210',
            MASTER_USER='repl',
            MASTER_PORT=3307,
            MASTER_PASSWORD='repl',
            MASTER_AUTO_POSITION = 1 FOR CHANNEL 'channel2';

            start slave;
            ```

- 迁移前确认

    - 迁移前确认事项我这边同样是列了清单，具体事项需要根据具体情况修改。
    ![image](./Pictures/mysql/数据迁移案例-检查清单.avif)

    - 其中 OM 是旧主实例，NM 是新主实例，OS 是旧从实例，NS 是新从实例。

    - 迁移检查需要在迁移前多次确认，比如在迁移准备完成时确认一次，迁移正式开始前再确认一次。

- 进行迁移

    - 1.确认无流量写入

        - 下发开始后首先需要确认业务是否全部停止，是否还有流量写入，

        - 我们也可以查看 gtid 是否还有变化判断。
        ```sql
        # 查看实例状态
        show master status\G
        ```

    - 2.解绑旧集群的 VIP，设置旧实例为只读

        - 在确认无流量写入后，解除旧集群 vip，设置旧实例为只读模式，防止有数据再次写入。
        ```sql
        # 解绑vip
        ip addr del 10.186.60.201/25 dev eth0

        # 设置旧实例为只读库，防止数据写入
        show global variables like '%read_on%';
        set global super_read_only=1;
        show global variables like '%read_on%';
        ```

    - 3.断开新老集群复制

        ```sql
        # 断开复制
        stop slave;
        ```

        - 做完该步骤，新老集群状态应该完全一致，可以对比新老集群状态。

- 数据验证
    - 在确认新老集群状态一致后，可以由业务部门进行数据验证。

## 数据迁移工具（支持多种数据库）

### [CloudCanal：可视化数据同步迁移工具](https://www.clougence.com/)

- [Se7en的架构：笔记可视化数据同步迁移工具 CloudCanal](https://mp.weixin.qq.com/s/fRACj3W1Yn0o9k_MqKyaeQ)

- [cloudcanal-exporter：prometheus监控](https://github.com/dream-mo/cloudcanal-exporter)

### [DataX-Web：异构数据迁移工具](https://github.com/WeiYe-Jing/datax-web)

- 简介：
    - DataX 是阿里巴巴集团内被广泛使用的离线数据同步工具/平台，实现包括 MySQL、SQL Server、Oracle、PostgreSQL、HDFS、Hive、HBase、OTS、ODPS 等各种异构数据源之间高效的数据同步功能。

- 优点：
    - 支持多种同步模式（全量、增量、混合）。
    - 支持MongoDB集群和副本集的同步。
    - 高性能，支持大规模数据传输。

- 缺点：
    - 仅支持MongoDB数据库，适用范围有限。
    - 对于某些复杂场景的配置和调优较为复杂。

- 使用场景：
    - MongoDB数据迁移：在不影响业务运行的情况下，将数据从一个MongoDB集群迁移到另一个集群。
    - 灾备恢复：将MongoDB数据同步到备份集群，用于灾难恢复。
    - 数据同步：在多环境下同步MongoDB数据，保持数据一致性。

- [DBA实战：DataX 异构数据迁移工具：实现 Web 页面轻松操作](https://mp.weixin.qq.com/s/DiwSXFU15QZVwOT9MrUCUg)

## ETL数据迁移

- ETL是数据抽取（Extract）、转换（Transform）、加载（Load ）的简写，它是将OLTP系统中的数据经过抽取，并将不同数据源的数据进行转换、整合，得出一致性的数据，然后加载到数据仓库中。简而言之ETL是完成从 OLTP系统到OLAP系统的过程

- 数据仓库的架构
    - 星型架构中间为事实表，四周为维度表， 类似星星
    - 雪花型架构中间为事实表，两边的维度表可以再有其关联子表，而在星型中只允许一张表作为维度表与事实表关联，雪花型一维度可以有多张表，而星型 不可以。
    - 考虑到效率时，星型聚合快，效率高，不过雪花型结构明确，便于与OLTP系统交互。

- ETL和SQL的区别与联系

    - ETL的优点：
        - 比如我有两个数据源，一个是数据库的表，另外一个是excel数据，而我需要合并这两个数据，通常这种东西在SQL语句中比较难实现。但是ETL却有很多现成的组件和驱动，几个组件就搞定了。
        - 比如跨服务器，并且服务器之间不能建立连接的数据源，比如我们公司系统分为一期和二期，存放的数据库是不同的，数据结构也不相同，数据库之间也不能建立连接，这种情况下，ETL就显得尤为重要和突出。

    - SQL的优点：效率高的多

### ETL构建企业级数据仓库五步法的流程

- 1.确定主题
    - 即 确定数据分析或前端展现的某一方面的分析主题，例如我们分析某年某月某一地区的啤酒销售情况，就是一个主题。主题要体现某一方面的各分析角度（维度）和统 计数值型数据（量度），确定主题时要综合考虑，一个主题在数据仓库中即为一个数据集市，数据集市体现了某一方面的信息，多个数据集市构成了数据仓库。

- 2.确定量度
    - 在 确定了主题以后，我们将考虑要分析的技术指标，诸如年销售额此类，一般为数值型数据，或者将该数据汇总，或者将该数据取次数，独立次数或取最大最小值 等，这样的数据称之为量度。量度是要统计的指标，必须事先选择恰当，基于不同的量度可以进行复杂关键性能指标（KPI）等的计算。

- 3.确定事实数据粒度
    - 在 确定了量度之后我们要考虑到该量度的汇总情况和不同维度下量度的聚合情况，考虑到量度的聚合程度不同，我们将采用“最小粒度原则”，即将量度的粒度设置 到最小，例如我们将按照时间对销售额进行汇总，目前的数据最小记录到天，即数据库中记录了每天的交易额，那么我们不能在ETL时将数据进行按月或年汇总， 需要保持到天，以便于后续对天进行分析。而且我们不必担心数据量和数据没有提前汇总带来的问题，因为在后续的建立CUBE时已经将数据提前汇总了。

- 4.确定维度

    - 维 度是要分析的各个角度，例如我们希望按照时间，或者按照地区，或者按照产品进行分析，那么这里的时间、地区、产品就是相应的维度，基于不同的维度我们可 以看到各量度的汇总情况，我们可以基于所有的维度进行交叉分析。这里我们首先要确定维度的层次（Hierarchy）和级别（Level），维度的层次是指该维度的所有级别，包括各级别的属性；维度的级别是指该维度下的成员，例如当建立地区维度时我们将地区维度作为一 个级别，层次为省、市、县三层，考虑到维度表要包含尽量多的信息，所以建立维度时要符合“矮胖原则”，即维度表要尽量宽，尽量包含所有的描述性信息，而不 是统计性的数据信息。

    - 还有一种常见的情况，就是父子型维度，该维度一般用于非叶子节点含有成员等情况，例如公司员工 的维度，在统计员工的工资时，部 门主管的工资不能等于下属成员工资的简单相加，必须对该主管的工资单独统计，然后该主管部门的工资等于下属员工工资加部门主管的工资，那么在建立员工维度 时，我们需要将员工维度建立成父子型维度，这样在统计时，主管的工资会自动加上，避免了都是叶子节点才有数据的情况。

    - 另外，在建立维度表时要充 分使用代理键，代理键是数值型的ID号码，好处是代理键唯一标识了每一维度成员信息，便于区分，更重要的是在聚合时由于数值型匹 配，JOIN效率高，便于聚合，而且代理键对缓慢变化维度有更重要的意义，它起到了标识历史数据与新数据的作用，在原数据主键相同的情况下，代理键起到了 对新数据与历史数据非常重要的标识作用。

    - 有时我们也会遇到维度缓慢变化的情况，比如增加了新的产品，或者产品的ID号码修改了，或者产品增加了一个新的属性，此时某一维度的成员会随着新的数据的加入而增加新的维度成员，这样我们要考虑到缓慢变化维度的处理，对于缓慢变化维度，有三种情况：

        - 1.缓慢变化维度第一种类型：历史数据需要修改。这样新来的数据要改写历史数据，这时我们要使用UPDATE，例如产品的ID号码为123，后来发现ID 号码错误了，需要改写成456，那么在修改好的新数据插入时，维度表中原来的ID号码会相应改为456，这样在维度加载时要使用第一种类型，做法是完全更 改。

        - 2.缓慢变化维度第二种类型：历史数据保留，新增数据也要保留。这时要将原数据更新，将新数据插入，需要使用UPDATE / INSERT，比如某一员工2005年在A部门，2006年时他调到了B部门。那么在统计2005年的数据时就应该将该员工定位到A部门；而在统计 2006年数据时就应该定位到B部门，然后再有新的数据插入时，将按照新部门（B部门）进行处理，这样我们的做法是将该维度成员列表加入标识列，将历史的 数据标识为“过期”，将目前的数据标识为“当前的”。另一种方法是将该维度打上时间戳，即将历史数据生效的时间段作为它的一个属性，在与原始表匹配生成事 实表时将按照时间段进行关联，这样的好处是该维度成员生效时间明确。

        - 3.缓慢变化维度第三种类型：新增数据维度成员改变了属性。例如某一维度成 员新加入了一列，该列在历史数据中不能基于它浏览，而在目前数据和将来数据中可 以按照它浏览，那么此时我们需要改变维度表属性，即加入新的列，那么我们将使用存储过程或程序生成新的维度属性，在后续的数据中将基于新的属性进行查看。

- 5.创建事实表

    - 在确定好事实数据和维度后，我们将考虑加载事实表。

    - 在公司的大量数据堆积如山时，我们想看看里面究竟是什么，结果发现里面是一笔笔生产记录，一笔笔交易记录… 那么这些记录是我们将要建立的事实表的原始数据，即关于某一主题的事实记录表。

    - 我 们的做法是将原始表与维度表进行关联，生成事实表。注意在关联时有为空的数据时（数据源脏），需要使用外连接，连接后我们将 各维度的代理键取出放于事实表中，事实表除了各维度代理键外，还有各量度数据，这将来自原始表，事实表中将存在维度代理键和各量度，而不应该存在描述性信 息，即符合“瘦高原则”，即要求事实表数据条数尽量多（粒度最小），而描述性信息尽量少。

    - 如果考虑到扩展，可以将事实表加一唯一标识列，以为了以后扩展将该事实作为雪花型维度，不过不需要时一般建议不用这样做。

    - 事 实数据表是数据仓库的核心，需要精心维护，在JOIN后将得到事实数据表，一般记录条数都比较大，我们需要为其设置复合主键和索引，以为了数据的完整性和 基于数据仓库的查询性能优化，事实数据表与维度表一起放于数据仓库中，如果前端需要连接数据仓库进行查询，我们还需要建立一些相关的中间汇总表或物化视图，以方便查询。

### ETL工具

- [数仓与大数据：数据仓库ETL工具全解](https://mp.weixin.qq.com/s/JTE3K6VfiYEAOSyYgN-KPA)

#### [kettle](https://github.com/pentaho/pentaho-kettle)

- [Kettle实战100篇博文](https://github.com/xiaoymin/KettleInAction100)

- [kettle-scheduler：一款简单易用的Kettle调度监控平台](https://github.com/zhaxiaodong9860/kettle-scheduler)

#### [canal](https://github.com/alibaba/canal)

- [李文周：Canal介绍和使用指南](https://mp.weixin.qq.com/s/9jDlMssry-_UWzSm1R-Ypg)

- Canal 是阿里开源的一款 MySQL 数据库增量日志解析工具，提供增量数据订阅和消费。使用Canal能够实现异步更新数据，配合MQ使用可在很多业务场景下发挥巨大作用。
    ![image](./Pictures/mysql/canal.avif)

- MySQL主备复制原理
    - MySQL master 将数据变更写入二进制日志( binary log, 其中记录叫做二进制日志事件binary log events，可以通过 show binlog events 进行查看)
    - MySQL slave 将 master 的 binary log events 拷贝到它的中继日志(relay log)
    - MySQL slave 重放 relay log 中事件，将数据变更反映它自己的数据

- Canal 工作原理
    - Canal 模拟 MySQL slave 的交互协议，伪装自己为 MySQL slave ，向 MySQL master 发送 dump 协议
    - MySQL master 收到 dump 请求，开始推送 binary log 给 slave (即 Canal )
    - Canal 解析 binary log 对象(原始为 byte 流)

[canal 运维工具安装](https://github.com/alibaba/canal/wiki/Canal-Admin-QuickStart)

##### 安装

- [canal 安装](https://github.com/alibaba/canal/wiki/QuickStart) 目前不支持 jdk 高版本

- 1.需要先开启MySQL的 Binlog 写入功能。`my.cnf`配置
    ```ini
    [mysqld]
    log-bin=mysql-bin # 开启 binlog
    binlog-format=ROW # 选择 ROW 模式
    server_id=1 # 配置 MySQL replaction 需要定义，不要和 canal 的 slaveId 重复
    ```

    - 重启mysql

    - 验证
        ```sql
        -- 查看是否开启了binlog
        show variables like 'log_bin';
        +---------------+-------+
        | Variable_name | Value |
        +---------------+-------+
        | log_bin       | ON    |
        +---------------+-------+

        -- 查看是否为row格式
        show variables like 'binlog_format';
        +---------------+-------+
        | Variable_name | Value |
        +---------------+-------+
        | binlog_format | ROW   |
        +---------------+-------+
        ```

- 2.添加授权
    ```sql
    -- 下面的命令是先创建一个名为canal的账号，密码为canal。再对其进行授权，如果已有账户可直接 grant。
    CREATE USER canal IDENTIFIED BY 'canal';
    GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'canal'@'%';
    -- GRANT ALL PRIVILEGES ON *.* TO 'canal'@'%' ;
    FLUSH PRIVILEGES;
    ```

- 3.安装canal

    - 在[release页面](https://github.com/alibaba/canal/releases) 下载

    ```sh
    # 这里的版本为1.0.17
    curl -LO https://github.com/alibaba/canal/releases/download/canal-1.1.7/canal.deployer-1.1.7.tar.gz

    # 解压缩
    x canal.deployer-1.1.7.tar.gz

    # 一共5个目录
    cd canal.deployer-1.1.7
    ll
    drwxr-xr-x 2 - tz tz 20 Apr 17:31 -I bin/
    drwxr-xr-x 5 - tz tz 20 Apr 17:31 -I conf/
    drwxr-xr-x 2 - tz tz 20 Apr 17:31 -I lib/
    drwxr-xr-x 2 - tz tz 13 Oct  2023 -I logs/
    drwxr-xr-x 2 - tz tz 13 Oct  2023 -I plugin/
    ```

- 4.修改配置文件`canal.deployer-1.1.7/conf/example/instance.properties`

    - 将canal.instance.master.address修改为你的MySQL地址。
    - 将canal.instance.tsdb.dbUsername修改为你上面授权的账号。
    - 将canal.instance.tsdb.dbPassword修改为你上面授权账号的密码。

    ```
    canal.instance.master.address=127.0.0.1:3306
    canal.instance.tsdb.dbUsername=canal
    canal.instance.tsdb.dbPassword=canal
    ```
- 启动

    ```sh
    sh bin/startup.sh
    ```

- 查看server日志
    ```sh
    cat logs/canal/canal_stdout.log
    ```

- 关闭
    ```sh
    sh bin/stop.sh
    ```

##### docker安装

```sh
# 拉取canal
docker pull canal/canal-server:latest

# 启动容器
docker run -d --name canal-server -p 11111:11111 canal/canal-server

# 进入容器
docker exec -it canal-server /bin/bash

# 修改配置
# 将canal.instance.master.address修改为你的MySQL地址。
# 将canal.instance.tsdb.dbUsername修改为你上面授权的账号。
# 将canal.instance.tsdb.dbPassword修改为你上面授权账号的密码。
vi canal-server/conf/example/instance.properties

# 重启容器
docker container restart canal-server
```

- 启动Canal Server之后，我们可以使用Canal客户端连接Canal进行消费，本文以Go客户端canal-go为例，演示如何从canal-server消费数据。

```go
package main

import (
 "fmt"
 "time"

 pbe "github.com/withlin/canal-go/protocol/entry"

 "github.com/golang/protobuf/proto"
 "github.com/withlin/canal-go/client"
)

// canal-go client demo

func main() {
 // 连接canal-server
 connector := client.NewSimpleCanalConnector(
  "127.0.0.1", 11111, "", "", "example", 60000, 60*60*1000)
 err := connector.Connect()
 if err != nil {
  panic(err)
 }

 // mysql 数据解析关注的表，Perl正则表达式.
 err = connector.Subscribe(".*\\..*")
 if err != nil {
  fmt.Printf("connector.Subscribe failed, err:%v\n", err)
  panic(err)
 }

 // 消费消息
 for {
  message, err := connector.Get(100, nil, nil)
  if err != nil {
   fmt.Printf("connector.Get failed, err:%v\n", err)
   continue
  }
  batchId := message.Id
  if batchId == -1 || len(message.Entries) <= 0 {
   time.Sleep(time.Second)
   fmt.Println("===暂无数据===")
   continue
  }
  printEntry(message.Entries)
 }
}

func printEntry(entries []pbe.Entry) {
 for _, entry := range entries {
  // 忽略事务开启和事务关闭类型
  if entry.GetEntryType() == pbe.EntryType_TRANSACTIONBEGIN || entry.GetEntryType() == pbe.EntryType_TRANSACTIONEND {
   continue
  }
  // RowChange对象，包含了一行数据变化的所有特征
  rowChange := new(pbe.RowChange)
  // protobuf解析
  err := proto.Unmarshal(entry.GetStoreValue(), rowChange)
  if err != nil {
   fmt.Printf("proto.Unmarshal failed, err:%v\n", err)
  }
  if rowChange == nil {
   continue
  }
  // 获取并打印Header信息
  header := entry.GetHeader()
  fmt.Printf("binlog[%s : %d],name[%s,%s], eventType: %s\n",
   header.GetLogfileName(),
   header.GetLogfileOffset(),
   header.GetSchemaName(),
   header.GetTableName(),
   header.GetEventType(),
  )
  //判断是否为DDL语句
  if rowChange.GetIsDdl() {
   fmt.Printf("isDdl:true, sql:%v\n", rowChange.GetSql())
  }

  // 获取操作类型：insert/update/delete等
  eventType := rowChange.GetEventType()
  for _, rowData := range rowChange.GetRowDatas() {
   if eventType == pbe.EventType_DELETE {
    printColumn(rowData.GetBeforeColumns())
   } else if eventType == pbe.EventType_INSERT || eventType == pbe.EventType_UPDATE {
    printColumn(rowData.GetAfterColumns())
   } else {
    fmt.Println("---before---")
    printColumn(rowData.GetBeforeColumns())
    fmt.Println("---after---")
    printColumn(rowData.GetAfterColumns())
   }
  }
 }
}

func printColumn(columns []*pbe.Column) {
 for _, col := range columns {
  fmt.Printf("%s:%s  update=%v\n", col.GetName(), col.GetValue(), col.GetUpdated())
 }
}
```

##### 配置kafka

- Canal 1.1.1版本之后，默认支持将Canal Server接收到的binlog数据直接投递到MQ，目前默认支持的MQ系统有Kafka、RocketMQ、RabbitMQ、PulsarMQ。

- 加入mq配置`canal.deployer-1.1.7/conf/example/instance.properties`
    ```
    # mq config
    # 设置默认的topic
    canal.mq.topic=example
    # 针对库名或者表名发送动态topic
    #canal.mq.dynamicTopic=mytest,.*,mytest.user,mytest\\..*,.*\\..*
    canal.mq.partition=0
    # hash partition config
    #canal.mq.partitionsNum=3
    #库名.表名: 唯一主键，多个表之间用逗号分隔
    #canal.mq.partitionHash=mytest.person:id,mytest.role:id
    ```

    - `canal.mq.dynamicTopic`配置说明。

        - Canal 1.1.3版本之后, 支持配置格式为：schema 或 schema.table，多个配置之间使用逗号或分号分隔。

            - 例子1：test\\.test 指定匹配的单表，发送到以test_test为名字的topic上
            - 例子2：.*\\..* 匹配所有表，则每个表都会发送到各自表名的topic上
            - 例子3：test 指定匹配对应的库，一个库的所有表都会发送到库名的topic上
            - 例子4：test\\..* 指定匹配的表达式，针对匹配的表会发送到各自表名的topic上
            - 例子5：test,test1\\.test1，指定多个表达式，会将test库的表都发送到test的topic上，test1\\.test1的表发送到对应的test1_test1 topic上，其余的表发送到默认的canal.mq.topic值

        - 为满足更大的灵活性，Canal还允许对匹配条件的规则指定发送的topic名字，配置格式：topicName:schema 或 topicName:schema.table。

            - 例子1: test:test\\.test 指定匹配的单表，发送到以test为名字的topic上
            - 例子2: test:.*\\..* 匹配所有表，因为有指定topic，则每个表都会发送到test的topic下
            - 例子3: test:test 指定匹配对应的库，一个库的所有表都会发送到test的topic下
            - 例子4：testA:test\\..* 指定匹配的表达式，针对匹配的表会发送到testA的topic下
            - 例子5：test0:test,test1:test1\\.test1，指定多个表达式，会将test库的表都发送到test0的topic下，test1\\.test1的表发送到对应的test1的topic下，其余的表发送到默认的canal.mq.topic值

- 修改canal 配置文件 `canal.deployer-1.1.7/conf/canal.properties`

    ```
    # ...
    # 可选项: tcp(默认), kafka,RocketMQ,rabbitmq,pulsarmq
    canal.serverMode = kafka
    # ...

    # 是否为flat json格式对象
    canal.mq.flatMessage = true
    # Canal的batch size, 默认50K, 由于kafka最大消息体限制请勿超过1M(900K以下)
    canal.mq.canalBatchSize = 50
    # Canal get数据的超时时间, 单位: 毫秒, 空为不限超时
    canal.mq.canalGetTimeout = 100
    canal.mq.accessChannel = local

    ...

    ##################################################
    #########                    Kafka                   #############
    ##################################################
    # 此处配置修改为你的Kafka环境地址
    kafka.bootstrap.servers = 127.0.0.1:9092
    kafka.acks = all
    kafka.compression.type = none
    kafka.batch.size = 16384
    kafka.linger.ms = 1
    kafka.max.request.size = 1048576
    kafka.buffer.memory = 33554432
    kafka.max.in.flight.requests.per.connection = 1
    kafka.retries = 0

    kafka.kerberos.enable = false
    kafka.kerberos.krb5.file = ../conf/kerberos/krb5.conf
    kafka.kerberos.jaas.file = ../conf/kerberos/jaas.conf

    # sasl demo
    # kafka.sasl.jaas.config = org.apache.kafka.common.security.scram.ScramLoginModule required \\n username=\"alice\" \\npassword="alice-secret\";
    # kafka.sasl.mechanism = SCRAM-SHA-512
    # kafka.security.protocol = SASL_PLAINTEXT
    ```

- 按上述修改Canal配置后，重启Canal服务即可。

# 数据库流行度

- [db-engines：数据库流行度排行榜](https://db-engines.com/en/)

    - [db-engine 数据分析](https://demo.pigsty.cc/d/db-analysis)

- [墨天轮国产数据库排行榜](https://www.modb.pro/dbRank)

- [StackOverflow 7年调研数据](https://demo.pigsty.cc/d/sf-survey/stackoverflow-survey?orgId=1)

## 国产数据库

- [爱可生开源社区：第八期话题：国产数据库，TiDB、巨杉、OceanBase，谁会最终胜出？](https://mp.weixin.qq.com/s/M6W-6wvOc8zGnQnlNQhQZw)

- [未来智库：数据库行业专题研究：关键三问深度解读](https://mp.weixin.qq.com/s/RlF0eTu5xBQ-LosJ6Vt7Zg)

- [非法加冯：国产数据库到底能不能打？](https://mp.weixin.qq.com/s/AqcYpOgVj91JnkB1B3s4sA)

### [白鳝的洞穴：体系化与碎片化孰优孰劣？](https://mp.weixin.qq.com/s/KBd0LIBFTtDbEi4sq3RYKw)

- 目前的国产数据库的服务网站和知识库还是可以用来做系统学习的，这一点和三十年前的Oracle官网很像。不是因为知识库更加强大，而是因为碎片化的知识不够丰富，所以我们还可以以系统化的方式来学习。

- 而实际上的数据库知识世界是网状的，是接近于混乱的，想要系统学习的时候，只能在表层，要想往下下钻，很快就会被相互缠绕的藤蔓搞得晕头转向。很多DBA朋友都会有这种感觉，刚开始体系化学习某个数据库技术的时候，会觉得学得很明白了，不过遇到具体的问题都会麻爪。随后学习了一些碎片化的技巧和方法，处理起问题来就逐渐有点得心应手了。如果没有碎片化的知识做补充，那么我们学到的体系化知识无法发挥作用。而仅仅是碎片化地去学习，那么学到的可能是一团浆糊。

- RDBMS的核心最初是被按照某种理想的模型设计并开发出来的。不过这种被严格设计出来的系统在面对各种千奇百怪的应用需求的时候，往往无法很好地应对，因此必须对RDBMS核心做大量的优化与改造，打上各种样式的补丁，才能适应多样化的用户需求。另外随着新技术的出现，也需要对RDBMS做升级。

- 大量的改造、补丁与升级叠加起来，数据库系统会变得越来越复杂。而要保持对老版本系统的兼容性，又对升级改造提出了新要求，大大增加了升级改造的难度。新业务可能会对数据库存储引擎提出新的要求，数据块的结构、日志流的结构等等可能都需要变更才能满足新的功能需求，但是我们还需要保证老版本的数据库能够直接UPGRADE到新版本，这种痛苦目前的一些国产数据库厂商可能刚刚尝到。

- 牵一发而动全身，有时候改进一项功能并非易事。经常有朋友在吐槽某开源数据库的某个功能为啥做了N多年还搞不出来，实际上这是数据库的复杂性导致的。2016年ORACLE CAB大会上，我提了一个功能，到去年的大会上回顾环节，这个功能才被部分实现。并不是这个功能没啥用，而是因为这个功能太有用了，牵涉到内核太多的功能模块了。

- 我曾经和一位新锐数据库核心研发的同学做过交流，他认为他们的数据库全面超越Oracle只是时间的问题了，因为Oracle的历史包袱太重，设计思想严重落后，目前堆积的几千万行屎山代码已经快改不动了。而他们的产品是在全新的数据库理念指导下，利用最新的IT技术架构设计出来的，代码高效而优雅，并能充分利用现代硬件的技术能力，因此没有理由会比Oracle差。

    - 他在得意于自己产品的体系化而鄙视Oracle的碎片化的时候，可能没有弄明白一件事，那就是数据库产品不是依靠设计就能做好的，好的数据库产品是在海量的用户场景中不断打磨出来的。他眼中的屎山不是Oracle的弱点，反而是Oracle的优势所在。Oracle在搞出这个屎山的时候还没有崩溃，还依然高质量地帮用户应对各种应用场景，这就是Oracle的最大的成功。

    - 而如果给那位朋友的设计精良的数据库系统以同样的机会，去面对用户千差万别的应用场景的时候，也将开启他们堆积屎山的旅程。我估计他们可能等不到堆积到Oracle 1/10的高度的时候，可能就崩溃了。

- 做数据库产品是要奉行长期主义的，特别是通用关系型数据库，新鲜出炉的产品自己感觉挺好，到用户现场去练练就会发现很多地方是不契合的。

    - 十年可能才是一个数据库厂商刚刚度过童年，仍然不够强健，随时可能会夭折。
    - 能够坚持二十年以上的国产数据库厂商目前还寥寥无几。
    - 而很多国外商用数据库厂商死在了自己的三十岁左右。

- 目前来看，数据库国产化替代的时间要求很紧，国产数据库目前大多没有充分经受应用场景的磨练，存在问题很多。
    - 研发人员觉得产品是体系化的，但是到了用户现场却是项目化的，这实际上还是初级阶段的体系化或者说是设计上的体系化。等第一阶段的磨合完成了，才可能形成较为产品化的版本，进入真正的体系化，然后才能初步满足用户的需求，在用户各种各样变态的场景中继续磨练，逐渐形成体系化下的碎片化能力。
    - 不过O记不也是从不大易用，不大好用，不大稳定的时代经过了三十多年蜕变出来的。国产数据库在大量关键行业应用的锤炼下，所需的成长时间会大大缩短，我坚信5-10年里一定会出现优秀的国产数据库产品。

## 数据库历史

- [码农翻身：漫画 | 历经60年，数据库的王者终于出现了......](https://mp.weixin.qq.com/s/xacTZBq_IFTByH689csc7g)

# 性能测试

- [ClickBench：a Benchmark For Analytical DBMS](https://benchmark.clickhouse.com/)

# 新闻

- [数据库内核月报](http://mysql.taobao.org/monthly/)
  通过搜索引擎输入以下格式进行搜索(我这里搜索的是 binlog)

  > site:mysql.taobao.org binlog

