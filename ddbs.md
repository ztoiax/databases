<!-- vim-markdown-toc GFM -->

* [DDBS(分布式数据库)](#ddbs分布式数据库)
    * [分布式数据库是伪需求吗？](#分布式数据库是伪需求吗)
    * [shared-nothing 不共享架构](#shared-nothing-不共享架构)
    * [CAP理论](#cap理论)
        * [BASE理论](#base理论)
        * [PACELC理论](#pacelc理论)
    * [分布式事务](#分布式事务)
        * [提交协议(确保事务的原子性)](#提交协议确保事务的原子性)
            * [2PC(Two Phase Commit Protocol两阶段提交)](#2pctwo-phase-commit-protocol两阶段提交)
                * [故障处理](#故障处理)
            * [持久消息(presistent message)](#持久消息presistent-message)
        * [美团技术团队：Replication（下）：事务，一致性与共识](#美团技术团队replication下事务一致性与共识)
    * [分布式id生成方案](#分布式id生成方案)
    * [一致性协议](#一致性协议)
        * [Paxos](#paxos)
            * [Multi-Paxos](#multi-paxos)
        * [Raft](#raft)
            * [Replicated State Machine(复制状态机)](#replicated-state-machine复制状态机)
        * [ZooKeeper使用的Zab](#zookeeper使用的zab)
    * [分布式锁](#分布式锁)
        * [实现方案的对比](#实现方案的对比)
        * [基于 MySQL 的分布式锁（ShedLock）](#基于-mysql-的分布式锁shedlock)
        * [基于Redis](#基于redis)
            * [Redlock（红锁）](#redlock红锁)
                * [争议](#争议)
        * [基于 ZooKeeper 的分布式锁](#基于-zookeeper-的分布式锁)
        * [基于 Etcd 的分布式锁](#基于-etcd-的分布式锁)
        * [基于 Google 的 Chubby 的分布式锁](#基于-google-的-chubby-的分布式锁)
    * [Replication复制模型](#replication复制模型)
        * [共识](#共识)
    * [分布式查询](#分布式查询)
        * [分布式连接](#分布式连接)
    * [Amazon Dynamo](#amazon-dynamo)
    * [PNUTS](#pnuts)
    * [Zookeeper](#zookeeper)
    * [etcd](#etcd)

<!-- vim-markdown-toc -->

# DDBS(分布式数据库)

- [Distributed Systems 3rd edition (2017)](https://www.distributed-systems.net/index.php/books/ds3/)

- 半结构化存储(semi-structure storage systems): 兼顾`Consistency`(一致性)和`Availability`(可用性)

## 分布式数据库是伪需求吗？

- [非法加冯：分布式数据库是伪需求吗？](https://mp.weixin.qq.com/s/-eaCoZR9Z5srQ-1YZm1QJA)

- 本文语境中，分布式数据库指事务处理型（OLTP）的分布式关系型数据库

- 真正需要分布式数据库的场景屈指可数，典型的中型互联网公司/银行请求数量级在几万到几十万QPS，不重复TP数据在百TB上下量级。真实世界中 99% 以上的场景用不上分布式数据库，剩下1%也大概率可以通过经典的水平/垂直拆分等工程手段解决。

    - 头部互联网公司可能有极少数真正的适用场景，然而此类公司没有任何付费意愿。市场根本无法养活如此之多的分布式数据库内核，能够成活的产品靠的也不见得是分布式这个卖点。HATP 、分布式单机一体化是迷茫分布式TP数据库厂商寻求转型的挣扎，但离 PMF 仍有不小距离。

- 分布式数据库的起源：

    - 分布式数据库的兴起源于互联网应用的快速发展和数据量的爆炸式增长。在那个时代，传统的关系型数据库在面对海量数据和高并发访问时，往往会出现性能瓶颈和可伸缩性问题。

        - 即使用 Oracle 与 Exadata，在面对海量 CRUD 时也有些无力，更别提每年以百千万计的高昂软硬件费用。

        - 互联网公司走上了另一条路，用诸如 MySQL 这样免费的开源数据库自建。老研发/DBA可能还会记得那条 MySQL 经验规约：单表记录不要超过 2100万，否则性能会迅速劣化；与之对应的是，数据库分库分表开始成为大厂显学。

            - 这里的基本想法是“三个臭皮匠，顶个诸葛亮”，用一堆便宜的 x86 服务器 + 大量分库分表开源数据库实例弄出一个海量 CRUD 简单数据存储。故而，分布式数据库往往诞生于互联网公司的场景，并沿着手工分库分表 → 分库分表中间件 → 分布式数据库这条路径发展进步。

- 分布式的权衡

    - “分布式” 同 “HTAP”、 “存算分离”、“Serverless”、“湖仓一体” 这样的Buzzword一样，对企业用户来说没有意义。务实的甲方关注的是实打实的属性与能力：功能性能、安全可靠、投入产出、成本效益。真正重要的是利弊权衡：分布式数据库相比经典集中式数据库，牺牲了什么换取了什么？

    - 分布式的优点：NewSQL 通常主打“分布式”的概念，通过“分布式”解决水平伸缩性问题。在架构上通常拥有多个对等数据节点以及协调者，使用分布式共识协议 Paxos/Raft 进行复制，可以通过添加数据节点的方式进行水平伸缩。

    - 分布式的缺点：会牺牲许多功能，只能提供较为简单有限的 CRUD 查询支持。其次，分布式数据库因为需要通过多次网络 RPC 完成请求，所以性能相比集中式数据库通常有70%以上的折损。再者，分布式数据库通常由DN/CN以及TSO等多个组件构成，运维管理复杂，引入大量非本质复杂度。最后，分布式数据库在高可用容灾方面相较于经典集中式主从并没有质变，反而因为复数组件引入大量额外失效点。

    - 综合以上优缺点，核心权衡是：“以质换量”，牺牲功能、性能、复杂度、可靠性，换取更大的数据容量与请求吞吐量。

        - 在以前是成立的：但今日，硬件的发展废问了 量 的问题，那么分布式数据库的存在意义就连同着它想解决的问题本身被一并抹除了。

            - 以 NVMe SSD 为代表的硬件遵循摩尔定律以指数速度演进，十年间性能翻了几十倍，价格降了几十倍，性价比提高了三个数量级。单卡 32TB+， 4K随机读写 IOPS 可达 1600K/600K，延时 70µs/10µs，价格不到 200 ¥/TB·年。跑集中式数据库单机能有一两百万的点写/点查 QPS。

        - 在当下，牺牲功能性能复杂度换取伸缩性有极大概率是伪需求。

            - 在现代硬件的加持下，真实世界中  99%+ 的场景超不出单机集中式数据库的支持范围，剩下1%也大概率可以通过经典的水平/垂直拆分等工程手段解决。这一点对于互联网公司也能成立：即使是全球头部大厂，不可拆分的TP单表超过几十TB的场景依然罕见。

            - NewSQL的祖师爷 Google Spanner 是为了解决海量数据伸缩性的问题，但又有多少企业能有Google的业务数据量？从数据量上来讲，绝大多数企业终其生命周期的TP数据量，都超不过集中式数据库的单机瓶颈，而且这个瓶颈仍然在以摩尔定律的速度指数增长中。

            - “过早优化是万恶之源”，为了不需要的规模去设计是白费功夫。如果量不再成为问题，那么为了不需要的量去牺牲其他属性就成了一件毫无意义的事情。

- AP系统和TP系统各有各的模式，强行把两个需求南辕北辙的系统硬捏合在一块，只会让两件事都难以成功。不论是使用经典 ETL/CDC 推拉到专用 ClickHouse/Greenplum/Doris 去处理，还是逻辑复制到In-Mem列存的专用从库，哪一种都要比用一个奇美拉杂交HTAP数据库要更靠谱。

## shared-nothing 不共享架构

> sharding(网络分片): 将数据划分到多个节点

![image](./Pictures/ddbs/share.avif)

- Shard-everting：共享数据库引擎和数据库存储，无数据存储问题

    - 并行处理能力是最差的

- Shared-storage：引擎集群部署，分摊接入压力，无数据存储问题

- Shard-noting：引擎集群部署，分摊接入压力，存储分布式部署，存在数据存储问题

    - 各个处理单元都有自己私有的 CPU/内存/硬盘等，不存在共享资源，类似于 MPP（大规模并行处理）模式，各处理单元之间通过协议通信

    - 并行处理和扩展能力更好

    - 避免单点故障, 导致系统不能运行

    - 分片机制:

        - 按功能分片: 评论, 用户数据, 商品各为独立节点

        - 按键分片: 26个英文字母, 每个字母为独立节点

## [CAP理论](https://en.wikipedia.org/wiki/CAP_theorem)

- CAP

    ![image](./Pictures/ddbs/cap.avif)

    - Consistency(一致性)：每次读取都会收到最新写入

    - Availability(可用性)：一个节点故障后，集群还能否响应客户端的读写请求

    - Partition tolerance(分区容错)：出现网络分区后，系统是否能保持运作

- 在网络分区存在的情况下, 没有一个分布式系统, 能确保没有网络故障

    - 在网络没有故障的情况下, 能同时满足`Consistency`和`Availability`

    - 在网络存在故障的情况下, 必须在`Consistency`和`Availability`之间做出选择(PC|PA)

        - AP: 则不能保证message是最新, 系统返回错误或超时(DNS)

        - CP: 要淘汰数据的备份节点。节点如有错误, 部分数据可能会丢失

        - CA: 分布式事务使用**两阶段**提交, 如出现网络分区会阻塞

- 随着分区恢复技术(P)的发展, 完全有可能同时获得CAP

- 数据库对`CAP`选择

    | 数据库                                                                                     | CAP选择 |
    |--------------------------------------------------------------------------------------------|---------|
    | `Amazon Dynamo`以及它衍生出来的数据库: `Cassandra`, `Project Voldemort`, `CouchDB`, `Riak` | CP      |
    | 图数据库几乎都是                                                                           | AP      |
    | `Google Bigtable`衍生出来的数据库:  `MongoDB`, `HBase`, `Hypertable`, `Redis`              | AP      |
    | 传统RDBMS                                                                                  | CA      |


    ![image](./Pictures/ddbs/cap1.avif)

- 业务对`CAP`选择

    ![image](./Pictures/ddbs/cap2.avif)

- [Michael Stonebraker: Errors in Database Systems, Eventual Consistency, and the CAP Theorem](https://cacm.acm.org/blogs/blog-cacm/83396-errors-in-database-systems-eventual-consistency-and-the-cap-theorem/fulltext)
    - 对cap理论, 提出意见

### BASE理论

- BASE理论：是CAP理论的补充，主要来源于对大规模互联网系统分布式总结
    - Basically Available（基本可⽤）
    - Soft state（软状态）
    - Eventually Consistent（最终⼀致性）

- 相比CAP理论来说，BASE理论将一致性分为：强一致性和弱一致性
    - 选择Basically Available（基本可⽤），也就是弱一致性

- 对一致性和可用性权衡的结果：在达到Eventually Consistent（最终⼀致性）之前，系统会处于一个中间状态
    - 1.Basically Available（基本可⽤）：损失部分可用性，比如响应时间变长，或者部分服务被降级
    - 2.Soft state（软状态）：数据存在不一致，但不影响系统基本使用

### [PACELC理论](https://en.wikipedia.org/wiki/PACELC_theorem)

> PACELC是CAP的拓展

- CAP: 有网络分区存在, 必然有网络故障: 因此必须在`Consistency`(一致性)和`Availability`(可用性)之间选择

- 在没有有网络分区存在: 必须在`Consistency`(一致性)和`Latency`(延迟)之间选择

    - high Availability(高可用性)意味着系统必须复制数据. 一旦复制了数据, 就会在`Consistency`和`Latency`之间进行权衡

- PA/EL: 为了较低`Latency`, 放弃`Consistency`

    -  `DynamoDB`, `Cassandra`, `Riak`, `Cosmos DB`

- PC/EC：为了`Consistency`, 放弃 `Availability` 和 `Latency`

    - `VoltDB/H-Store`, `Megastore`, `MySQL Cluster`等ACID系统几乎都是PC/EC

    - BigTable和相关系统(HBase)

- PC/EL:为了较低`Latency`, 放弃`Availability`

    - PNUTS

- [GFS论文pdf](https://research.google.com/archive/gfs-sosp2003.pdf)

- [Spanner论文pdf](http://research.google.com/archive/spanner-osdi2012.pdf)

- [MapReduce论文pdf](https://research.google.com/archive/mapreduce-osdi04.pdf)

## 分布式事务

- 局部事务(local transactions)

    - 在局部数据库查询, 更新的事务

- 全局事务(global transactions)

    - 在非局部数据库查询, 更新的事务

- 如何确保全局事务满足ACID:

    - 每个站点都有一个**局部的事务管理器(transaction manager)**

        - 管理在局部站点执行的事务(包含局部, 全局事务)

        - 维护恢复日志

    - 每个站点都有一个**事务协调器(transaction coordinator)**

        - 协调局部站点的各个事务(包含局部, 全局事务)

    ![image](./Pictures/ddbs/manager-and-coordinator.avif)

### 提交协议(确保事务的原子性)

- 为了保证原子性, 必须确保事务T的执行在所有站点上一致

- 在多个站点上执行的事务: 要么在所有站点上提交, 要么在所有站点上中止

    - 不能在一个站点提交事务而在另一个站点中止事务

#### 2PC(Two Phase Commit Protocol两阶段提交)

- 假设Si站点发起事务T, C是S站点的事务协调器(transaction coordinator)

![image](./Pictures/ddbs/2pc.avif)

- 阶段1:

    - 1.C将 `<prepare T>` 的记录写入日志, 并写入磁盘

    - 2.将消息 `prepare T` 发送到执行T的站点

    - 3.事务管理器将收到消息 `prepare T` 后, 是否同意提交

        - 不同意:将`<no> T` 的记录写入日志, 然后向C返回`abort T` 消息作为响应

        - 同意:将`<ready T>` 的记录写入日志, 并写入磁盘, 然后向C返回`ready T` 消息作为响应

- 阶段2:

    - 1.C根据响应的结果执行

        - C收到所有站点的`ready T`, 那么T提交

            - 将 `<commit T>` 的记录写入日志, 并写入磁盘

            - 事务提交需要所有站点`ready T`

        - C收到`abort T`, 那么T中止

            - 将 `<abort T>` 的记录写入日志, 并写入磁盘

    - 2.C将commit或abort的消息, 发送给参与事务T的结点

    - 3.参与站点收到后,将消息记录写入日志

##### 故障处理

- 参与事务的站点S故障:

    - `ready T`消息返回前故障:C假定该站点使用`abort T`响应

    - `ready T`消息返回后故障:C忽略该站点故障

        - 站点S恢复时:

        - 如果C在工作:根据日志commit或abort记录, 执行redo或undo

        - 如果C故障:S需要向其他站点发送`querystatus T`的消息, 获取T的最终结果(commit或abort)

            - 如果其他站点没有返回消息, 则定期向其他站点发送`querystatus T`的消息, 直到某个站点返回消息

- 协调器C故障:

    - 根据参与事务T站点的日志记录决定结果

        - `<commit T>`:提交

        - `<abort T>`:中止

        - 没有`<ready T>`:中止

        - 有`<ready T>`:必须等待C恢复, 事务T阻塞

#### 持久消息(presistent message)

- 持久消息:A银行从余额扣除支票的资金, 并把支票送到B银行, B银行根据支票资金增加局部余额. 支票就构成了两家银行的**持久消息**

    - 优点: 避免了2pc的阻塞问题

    - 缺点: 有额外的故障问题

![image](./Pictures/ddbs/persisent-message.avif)

- 发送站点协议(sending site protocol):

    - 1.事务从messages_to_send(专用关系)中写一条消息, 消息被添加唯一标识符

    - 2.并发控制器在事务提交后才读取消息

    - 3.消息传送进程(message delivery process)

        - 收到目标站点的确认

            - 删除消息

        - 目标站点不存在

            - 将失败消息返回源站点, 源站点将支票资金存入源帐户

                - 如果此时源站点故障, 只能人工处理

        - 如果收不到目标站点消息会定期重发

        - 如果消息传送进程故障, 应用会执行异常代码处理故障

- 接受站点协议(receving site protocol):

    - 1.收到消息后, 将消息加入到messages_to_send(专用关系)

    - 2.返回确认

- 延迟问题:

    - 每条消息添加一个timestamp(时间戳), 如果接受到的timestamp消息旧, 则丢弃


### [美团技术团队：Replication（下）：事务，一致性与共识](https://tech.meituan.com/2022/08/25/replication-in-meituan-02.html)

- 事务操作的对象以及事务的提交与重试
    - 单对象写入：《DDIA》的2个例子

        - 1.第一个是单个事物执行一个长时间的写入，例如写入一个20KB的JSON对象，假设写到10KB时断掉会发生什么？
            - 1.数据库是否会存在10KB没法解析的脏数据。
            - 2.如果恢复之后数是否能接着继续写入。
            - 3.另一个客户端读取这个文档，是否能够看到恢复后的最新值，还是读到一堆乱码。

        - 2.隔离性问题导致更新丢失：两个客户端并发的修改DB中的一个counter，由于User2的get counter发生的时刻在User1更新的过程中，因此读到的counter是个旧值，同样User2更新也类似，所以最后应该预期counter值为44，结果两个人看到的counter都是43（类似两个线程同时做value++）。
            ![image](./Pictures/ddbs/隔离性问题导致更新丢失.avif)

        - 解决方法：一般是通过日志回放（原子性）、锁（隔离性）、CAS（隔离性）等方式来进行保证。

    - 多对象事务
        - 在某些分布式系统中，操作的对象可能会跨线程、跨进程、跨分区，甚至跨系统。
        - 事务的一个核心特性就是当发生错误时，客户端可以安全的进行重试，并且不会对服务端有任何副作用
            - 书中给出了一些可能发生的问题和解决手段：
                - 1.假设事务提交成功了，但服务端Ack的时候发生了网络故障，此时如果客户端发起重试，如果没有额外的手段，就会发生数据重复，这就需要服务端或应用程序自己提供能够区分消息唯一性的额外属性（服务端内置的事务ID或者业务自身的属性字段）。

                - 2.由于负载太大导致了事务提交失败，这是贸然重试会加重系统的负担，这时可在客户端进行一些限制，例如采用指数退避的方式，或限制一些重试次数，放入客户端自己系统所属的队列等。

                - 3.在重试前进行判断，尽在发生临时性错误时重试，如果应用已经违反了某些定义好的约束，那这样的重试就毫无意义。

                - 4.如果事务是多对象操作，并且可能在系统中发生副作用，那就需要类似“两阶段提交”这样的机制来实现事务提交。



## 分布式id生成方案

- 分布式id生成方案主要有：
    - UUID
    - 数据库自增ID
    - 基于雪花算法（Snowflake）实现
    - 百度 （Uidgenerator）
    - 美团（Leaf）

- 雪花算法：雪花算法是一种生成分布式全局唯一ID的算法，生成的ID称为Snowflake IDs。这种算法由Twitter创建，并用于推文的ID。

    - 一个Snowflake ID有64位

        - 第1位：Java中long的最高位是符号位代表正负，正数是0，负数是1，一般生成ID都为正数，所以默认为0。
        - 接下来前41位是时间戳，表示了自选定的时期以来的毫秒数。
        - 接下来的10位代表计算机ID，防止冲突。
        - 其余12位代表每台机器上生成ID的序列号，这允许在同一毫秒内创建多个Snowflake ID。

        ![image](./Pictures/ddbs/分布式id-雪花算法（Snowflake）.avif)

## 一致性协议

- [awesome-consensus: 一致性算法列表](https://github.com/dgryski/awesome-consensus)

- [腾讯技术工程: 分布式之系统底层原理](https://mp.weixin.qq.com/s?sub=&__biz=MjM5ODYwMjI2MA==&mid=2649756192&idx=1&sn=b3cca59cf43b15a0f15cef97dbb26f0b&chksm=becc815b89bb084dde98d92356e7f0a67ffa7ee2f64d0104d74e5709733e3d560f161a40ab7a&scene=19&subscene=10000&clicktime=1624521004&enterid=1624521004&ascene=0&devicetype=android-30&version=2800063d&nettype=WIFI&abtest_cookie=AAACAA%3D%3D&lang=zh_CN&exportkey=Ax%2FGPgyBCBMZ%2FKC9WGPpRSs%3D&pass_ticket=YZNCdN21ca7%2BXyA%2BktOjD%2FoxrX%2F6Zuc6h0zU71gwRLYcW7tQd7hPplXykEybT2RR&wx_header=1)

### Paxos

- [the parttime parliament论文pdf](https://lamport.azurewebsites.net/pubs/lamport-paxos.pdf)

- [Paxos Made Simple论文pdf](https://lamport.azurewebsites.net/pubs/paxos-simple.pdf)

- [Paxos的变体](https://paxos.systems/variants/)

- 三种角色:

    - proposer: 提出Proposal(提案)包括提案编号 (number) 和提议的值 (Value)

        - proposer一般是协调器(coordinator)

        - 如果投票出现分歧(split vote), 那么进行下一轮投票, 直到得出结果

        - 协调器可以有多个

        - 协调器可以被选举

    - acceptor：响应Proposal

    - learner: 会选择投票多(Majority)的值

    - 一个节点可以是Proposer + Acceptor + Learner

- 流程:

    ![image](./Pictures/ddbs/paxos.avif)

    - 1.proposer发送编号n给所有结点

        - acceptor结点收到的n, 记住n为max_n, 并响应proposer

    - 2.如果proposer收到的编号n超过半数, 就发送(n, v)给所有acceptor结点

    - 3.acceptor结点接受响应后, 根据n的值作出判断:

        - n 小于max_n: 忽视

        - n 大于max_n: 响应proposer

    - 4.acceptor结点发送给所有learner

#### Multi-Paxos

- 活锁:假设有两个proposer, 并且收到各一半的acceptor的响应

    - 由于无法超过半数, 需要重来

- 系统只有一个proposer为leader proposer

- Multi-Paxos的实际应用

    - Google Chubby 分布式锁管理器

    - X-DB、OceanBase、Spanner

    - [MySQL Group Replication的xcom](http://mysql.taobao.org/monthly/2017/08/01/)

        - 解决异步, 半同步的主从复制

### [Raft](https://raft.github.io/raftscope/index.html)

- 思想来自Multi-Paxos

- [raft可视化](http://thesecretlivesofdata.com/raft/)

- [腾讯技术工程: 分布式一致性算法 Raft](https://zhuanlan.zhihu.com/p/383555591)

- 三种状态:

    - leader（领导者）: 会向其他节点发送心跳。 所有对系统的更改都需要经过leader, 一个网络分区一个leader

        - 一般是协调器(coordinator), 与paxos不同的是, 在raft是一种优化

    - follower（追随者）: leader外的其他结点。响应leader和cadidate的投票请求，如果一定时间内没有受到leader的心跳，则会转换为candidate

    - Candidate（候选者）: follower选举leader时的状态，获得大多数投票后会成为leader

- 基于日志的协议:

    - 每个结点维护日志的副本

        - 日志副本可能存在暂时不一致的状态, 之后会恢复一致

- leader选举流程:

    - 1.一开始全是follower, 其中一些follower结点, 变为candidate

        - 如果leader故障, 并且`election timeout`超时后, follower变为candidate. `election timeout`大概在150ms - 300ms

    - 3.candidate发送投票请求给其他follower, 说投我为leader

    - 4.candidate如果收到大多数follower的响应: 则变为leader

        - 如果出现split vote(有两个candidate), 并且得票一样: 则回到第一步重新选举

    - 5.leader定期发送心跳(heartbeat timeout) `Append Entries` 消息给follower

    - 6.follower响应并返回`Append Entries`消息

        - 如果follower超时心跳(heartbeat timeout)收不到消息, 则leader故障了, 回到第一步重新选举. follower 强制复制 leader 的日志

- 追加日志流程:

    - 1.client发送命令给leader

    - 2.再下一次heartbeat timeout时, leader发送`Append Entries`请求给所有follower, 说要追加日志

        | AppendEntries参数        | 内容                             |
        |--------------------------|----------------------------------|
        | term                     |                                  |
        | previousLogEntryPosition |                                  |
        | previousLogEntryTerm     |                                  |
        | logEntries               | 数组, 多条日志记录               |
        | leaderCommitIndex        | 提交索引之前的所有日志记录的索引 |

    - 3.follower接受`Append Entries`消息后, 根据参数进行返回

        - 1.`term`小于follower的 `currentTerm`: 返回false

        - 2.`previousLogEntryTerm` 不匹配 `previousLogEntryPosition`: 返回false

        - 3.`previousLogEntryPosition` 与第一次日志记录不一样: 删除之前和之后的日志

        - 4.追加 `logEntries` 中的的日志记录

        - 5.如果 `leaderCommitIndex` > `local commitIndex`: 设置`local commitIndex` 为 `min(leaderCommitIndex, last log entry index)`

        - 6.返回true

    - 4.如果大多数follower响应为true:

        - 1.leader成功追加日志

        - 2.leader返回追加日志的消息给client

        - 3.再下一次heartbeat timeout, 发送消息给follower, 让follower追加日志

            - 如果此时follower故障了:

                - ??

    - 4.如果leader收到follower响应为false:

        - follower的`currentTerm`更高: leader变成follower

            - 新leader结点必须提交所有日志记录

        - 如果`previousLogEntryTerm` 不匹配: follower的日志过期需要更新

            - 带上前一个日志任期号和索引, 继续发送日志复制请求, 直到匹配

        ![image](./Pictures/ddbs/raft-log.avif)

    - 4.如果出现网络分区

        - 1.另一个网络分区, 会选举leader. 即有两个分区, 两个leader

        - 2.如果此时新出现的client发送命令给新分区的leader; 原来网络分区的leader收到原来client的新命令

            ![image](./Pictures/ddbs/raft-partition.avif)

            - 新leader**得到**大多数follower的true: 因此提交日志

            - 原leader**得不到**大多数follower的true: 因此无法提交日志


        - 3.如果此时网络分区消失了

            ![image](./Pictures/ddbs/raft-partition1.avif)

            - 原leader会变为follower, 并同步新leader的日志

#### Replicated State Machine(复制状态机)

- State Machine(状态机):

    - 基于Replicated log(复制日志)

![image](./Pictures/ddbs/raft-replicate.avif)

- 复制状态机能实现不同的容错服务

    - lock manager(锁管理器)

    - key-value存储

        - Google Spanner通过State Machine实现key-value存储

### ZooKeeper使用的Zab

- 思想来自Multi-Paxos

## 分布式锁

- [腾讯技术工程：一文讲透Redis分布式锁安全问题](https://cloud.tencent.com/developer/article/2332108)
- [字节跳动技术团队：聊聊分布式锁]()

- 为什么需要分布式锁？

    - 单机互诉锁：当我们在同一台机器的不同进程，想要同时操作一个共享资源（例如修改同一个文件），我们可以使用操作系统提供的「文件锁」或「信号量」来做互斥。

        - 分布式锁：这些互斥操作，都仅限于线程、进程处于同一台机器上，如果是分布在「不同机器」上的不同进程，要同时操作一个共享资源（例如修改数据库的某一行），就需要引入「分布式锁」来解决这个问题了。

    - 想要实现分布式锁，必须借助一个外部系统，所有进程都去这个系统上申请「加锁」。

        - 这个外部系统，可以是 MySQL，也可以是 Redis、Zookeeper、Etcd。但在高并发业务场景下，为了追求更好的性能，我们通常会选择使用 Redis。

### 实现方案的对比

    | 方案             | 复杂度 | 性能 | 可靠性 | 学习成本 |
    |------------------|--------|------|--------|----------|
    | 基于关系型数据库 | 低     | 低   | 低     | 低       |
    | 基于Redis        | 中     | 高   | 中     | 中       |
    | 基于zookeeper    | 高     | 中   | 高     | 高       |

- 基于关系型数据库：
    - 优点：直接借助数据库容易理解
    - 缺点：在使用关系型数据库实现分布式锁的过程中会出现各种问题，例如数据库单点问题和可重入问题，并且在解决过程中会使得整个方案越来越复杂

- 基于Redis：
    - 优点：性能好，实现起来较为方便
    - 缺点：
        - key的过期时间设置难以确定，如何设置的失效时间太短，方法没等执行完，锁就自动释放了，那么就会产生并发问题。如果设置的时间太长，其他获取锁的线程就可能要平白的多等一段时间。
        - Redis的集群部署虽然能解决单点问题，但是并不是强一致性的，锁的不够健壮

- 基于zookeeper：
    - 优点：有效地解决单点问题，不可重入问题，非阻塞问题以及锁无法释放的问题，实现起来较为简单。
    - 缺点：性能上不如使用缓存实现分布式锁


### 基于 MySQL 的分布式锁（ShedLock）

- 需要创建一张加锁用的表：

    ```sql
    CREATE TABLE shedlock
    (
        name VARCHAR(64),
        lock_until TIMESTAMP(3) NULL,
        locked_at TIMESTAMP(3) NULL,
        locked_by VARCHAR(255),
        PRIMARY KEY (name)
    )
    ```

- 加锁：通过插入同一个 name(primary key)，或者更新同一个 name 来抢，对应的 intsert、update 的 SQL 为

    ```sql
    INSERT INTO shedlock
    (name, lock_until, locked_at, locked_by)
    VALUES
    (锁名字,  当前时间+最多锁多久,  当前时间, 主机名)
    ```

    ```sql
    UPDATE shedlock
    SET lock_until = 当前时间+最多锁多久,
    locked_at = 当前时间,
    locked_by = 主机名 WHERE name = 锁名字 AND lock_until <= 当前时间
    ```

- 释放锁：通过设置 lock_until 来实现释放，再次抢锁的时候需要通过 lock_util 来判断锁失效了没。

    ```sql
    UPDATE shedlock
    SET lock_until = lockTime WHERE name = 锁名字
    ```

- 问题：
    - 单点问题
    - 主从同步问题。假如使用全同步模式，分布式锁将会有性能上的问题。

### 基于Redis

- 基于 Redis 分布式锁怎么实现？从最简单的开始讲起

- SETNX 命令实现：

    - 加锁：
        ```redis
        SETNX lock 1
        ```

    - 释放锁：
        ```redis
        DEL lock
        ```

    - 有死锁问题：当客户端 1 拿到锁后，如果发生下面的场景，就会造成「死锁」
        - 1.程序处理业务逻辑异常，没及时释放锁
        - 2.进程挂了，没机会释放锁

        - 这个客户端就会一直占用这个锁，而其它客户端就「永远」拿不到这把锁了（锁饥饿）。

- 解决死锁问题：

    - 解决问题1（程序在处理业务逻辑时发生异常，没及时释放锁）：对这块业务代码加上异常处理，保证无论业务逻辑是否异常，都可以把锁释放掉，例如在 Go 的 defer、Java/Python 的 finally 中及时释放锁：

        ```
        Go：defer redis.del(key)
        Java：try ... catch ... fianlly: redis.del(key)
        Python：try ... except ... fianlly: redis.del(key)
        ```

    - 解决问题2（进程挂了，没机会释放锁）：加上一个「租期」。在 Redis 中实现时，就是给这个 key 设置一个「过期时间」。

        - 在 Redis 2.6.12 之后，Redis 扩展了 SET 命令的参数，把 NX/EX 集成到了 SET 命令中，用这一条命令就可以了：
            ```redis
            // 一条命令保证原子性执行
            SET lock 1 EX 10 NX
            ```
- 存在2个问题：锁过期时间问题、锁被别人释放问题

    | 客户端 1                                                              | 客户端 2 |
    |-----------------------------------------------------------------------|----------|
    | 加锁成功，开始操作共享资源                                            |          |
    | 操作共享资源的时间，「超过」了锁的过期时间，锁被「自动释放」（问题1） |          |
    |                                                                       | 加锁成功 |
    | 操作共享资源完成，释放锁（问题2：但释放的是客户端 2 的锁）            |          |

    - 解决锁过期时间问题：给锁续期

        - 加锁时，先设置一个过期时间，然后我们开启一个「守护线程」，定时去检测这个锁的失效时间，如果锁快要过期了，操作共享资源还未完成，那么就自动对锁进行「续期」，重新设置过期时间。

        - 如果你是 Java 技术栈，幸运的是，已经有一个库把这些工作都封装好了：Redisson。

            ![image](./Pictures/ddbs/Redisson.avif)

            - Redisson 是一个 Java 语言实现的 Redis SDK 客户端：只要线程一加锁成功，就会启动一个watch dog看门狗，它是一个后台线程，会每隔10秒检查一下，如果线程1还持有锁，那么就会不断的延长锁key的生存时间。

            - 除此之外，这个 SDK 还封装了很多易用的功能：可重入锁、乐观锁、公平锁、读写锁、Redlock（红锁）

    - 解决锁被别人释放问题：客户端在加锁时，设置一个只有自己知道的「唯一标识」进去

        - 加锁
        ```redis
        // 锁的VALUE设置为UUID
        SET lock $uuid EX 20 NX
        ```

        - 释放锁
        ```lua
        // 锁是自己的，才释放
        if redis.get("lock") == $uuid:
            redis.del("lock")
        ```

- 释放锁原子性问题： GET + DEL 是两条命令

    | 客户端 1                                       | 客户端 2         |
    |------------------------------------------------|------------------|
    | 执行 GET，判断锁是自己的                       |                  |
    | 执行 GET 结束后，这个锁刚好超时自动释放        |                  |
    |                                                | 又获取到了这个锁 |
    | 执行 DEL 时，释放的却是客户端 2 的锁（冲突）   |                  |

    - 解决方法：Lua 脚本
        ```lua
        // 判断锁是自己的，才释放
        if redis.call("GET",KEYS[1]) == ARGV[1]
        then
            return redis.call("DEL",KEYS[1])
        else
            return 0
        end
        ```

- Redis 分布锁小结：
    - 1.加锁：SET unique_id EX $expire_time NX
    - 2.操作共享资源：没操作完之前，开启守护线程，定期给锁续期
    - 3.释放锁：Lua 脚本，先 GET 判断锁是否归属自己，再 DEL 释放锁
    ![image](./Pictures/ddbs/redis实现分布式锁.avif)

#### Redlock（红锁）

- 那当「主从发生切换」时，这个分布锁会依旧安全吗？

    | 脑裂等导致的主从切换场景
    |------------------------------------------------------------------|
    | 客户端 1 在主库上执行 SET 命令，加锁成功                         |
    | 此时，主库异常宕机，SET 命令还未同步到从库上（主从复制是异步的） |
    | 从库被哨兵提升为新主库，这个锁在新的主库上，丢失了！             |

    ![image](./Pictures/ddbs/主从切换丢失锁.avif)

    - `WAIT` 命令能够为 Redis 实现强一致吗？

        ```redis
        # numreplicas：指定副本（slave）的数量。
        # timeout：超时时间，时间单位为毫秒；当设置为 0 时，表示无限等待，即用不超时。

        WAIT numreplicas timeout
        ```

        - 阻塞当前客户端，直到所有先前的写入命令成功传输，并且由至少指定数量的副本（slave）确认。在主从、sentinel 和 Redis 群集故障转移中， WAIT 能够增强（仅仅是增强，但不是保证）数据的安全性。不能保证 Redis 的强一致性

    - Redis 作者提出的Redlock方案，就是解决这个分布式问题

- Redlock 的方案基于 2 个前提：
    - 1.不再需要部署从库和哨兵实例，只部署主库
    - 2.但主库要部署多个，官方推荐至少 5 个实例
        - 不是部署 Redis Cluster，就是部署 5 个简单的 Redis 实例。
- Redlock流程
    - 1.客户端先获取「当前时间戳 T1」
    - 2.客户端依次向这 5 个 Redis 实例发起加锁请求（用前面讲到的 SET 命令），且每个请求会设置超时时间（毫秒级，要远小于锁的有效时间），如果某一个实例加锁失败（包括网络超时、锁被其它人持有等各种异常情况），就立即向下一个 Redis 实例申请加锁
        ![image](./Pictures/ddbs/redlock.avif)
    - 3.如果客户端从 >=3 个（大多数）以上 Redis 实例加锁成功，则再次获取「当前时间戳 T2」，如果 T2 - T1 < 锁的过期时间，此时，认为客户端加锁成功，否则认为加锁失败
    - 4.加锁成功，去操作共享资源（例如修改 MySQL 某一行，或发起一个 API 请求）
    - 5.加锁失败，向「全部节点」发起释放锁请求（前面讲到的 Lua 脚本释放锁）

    - 注意！！！redLock 会直接连接多个 Redis 主节点，不是通过集群机制连接的。
        - RedLock 的写与主从集群无关，直接操作的是所有主节点，所以才能避开主从故障切换时锁丢失的问题。

    - 有 4 个重点：
        - 1.客户端在多个 Redis 实例上申请加锁
        - 2.必须保证大多数节点加锁成功
        - 3.大多数节点加锁的总耗时，要小于锁设置的过期时间
        - 4.释放锁，要向全部节点发起释放锁请求

- 失败重试（脑裂问题）：最终造成任何一个线程都无法抢到锁的情况。

    ![image](./Pictures/ddbs/redlock-脑裂场景.avif)

    - 所以当一个加锁线程无法获得锁的时候，应该在一个随机延时后再一次尝试获得锁。加锁线程从多数 Redis 实例中获得锁越快，出现脑裂的窗口越小（重试的次数也越少）。所以理想情况下，加锁线程应该多路复用地同时向 N 个实例发送加锁命令。

    - 值得强调的是，如果获取大部分锁失败，加锁线程应该尽可能快的释放（部分）已经获得了的锁。所以为了让锁能够再次被获得就没有必要等待 key 过期（然而如果发生了网络分区导致客户端无法再与 Redis 实例交互，那么就必须等待 key 过期才能重新抢到锁）。

- 崩溃恢复（AOF 持久化）对 Redlock 算法影响

    - 问题：假设 Rodlock 算法中的 Redis 发生了崩溃-恢复，那么锁的安全性将无法保证。假设加锁线程在 5 个实例中对其中 3 个加锁成功，获得了这把分布式锁，这个时候 3 个实例中有一个实例被重启了。重启后的实例将丢失其中的锁信息，这个时候另一个加锁线程可以对这个实例加锁成功，此时两个线程同时持有分布式锁。锁的安全性被破坏。

        ![image](./Pictures/ddbs/redlock-崩溃恢复场景.avif)

    - 如果我们配置了 AOF 持久化，只能减少它发生的概率而无法保证锁的绝对安全。断电的场景下，如果 Redis 被配置了默认每秒同步数据到硬盘，重启之后 lockKey 可能会丢失，理论上，如果我们想要保证任何实例重启的情况下锁都是安全的，需要在持久化配置中设置fsync=always，但此时 Redis 的性能将大大打折扣。

    - 解决方法：Redis 之父 antirez 提出了延迟重启(delayed restarts)的概念。也就是说，一个节点崩溃后，先不立即重启它，而是等待一段时间再重启，这段时间应该大于锁的有效时间(lock validity time)。这样的话，这个节点在重启前所参与的锁都会过期，它在重启后就不会对现有的锁造成影响。

##### 争议

- [How to do distributed locking](https://martin.kleppmann.com/2016/02/08/how-to-do-distributed-locking.html)

- 分布式专家Martin，是英国剑桥大学的一名分布式系统研究员。写的这本分布式系统领域的书《数据密集型应用系统设计》，豆瓣评分高达 9.7，好评如潮。

- Martin 对于 Redlock 的质疑。主要阐述了 4 个论点：

    - 1.分布式锁的目的是什么？

        - 1.效率：使用分布式锁的互斥能力，是避免不必要地做同样的两次工作（例如一些昂贵的计算任务）。
            - 如果锁失效，并不会带来「恶性」的后果，例如发了 2 次邮件等，无伤大雅。

        - 2.正确性（一致性）：如果锁失效，会造成多个进程同时操作同一条数据，产生的后果是数据严重错误、永久性不一致、数据丢失等恶性问题

        - 他认为
            - 如果是效率：那么使用单机版 Redis 就可以了，即使偶尔发生锁失效（宕机、主从切换），都不会产生严重的后果。而使用 Redlock 太重了，没必要。
            - 如果是为了正确性：Martin 认为 Redlock 根本达不到安全性的要求，也依旧存在锁失效的问题！

    - 2.锁在分布式系统中会遇到的问题

        - Martin 表示，一个分布式系统，更像一个复杂的「野兽」，存在着你想不到的各种异常情况。

        - 这些异常场景主要包括三大块，这也是分布式系统会遇到的三座大山：NPC。
            - N：Network Delay，网络延迟
            - P：Process Pause，进程暂停（GC）
            - C：Clock Drift，时钟漂移

        - Martin 用一个进程暂停（GC）的例子，指出了 Redlock 安全性问题：

            - 即使是使用没有 GC 的编程语言，在发生网络延迟时，也都有可能导致 Redlock 出现问题，这里 Martin 只是拿 GC 举例。

            | 客户端 1                                                       | 客户端 2                       |
            |----------------------------------------------------------------|--------------------------------|
            | 请求锁定节点 A、B、C、D、E                                     |                                |
            | 拿到锁后，进入 GC（时间比较久）。所有 Redis 节点上的锁都过期了 |                                |
            |                                                                | 获取到了 A、B、C、D、E 上的锁  |
            | GC 结束，认为成功获取锁                                        |                                |
            |                                                                | 也认为获取到了锁，发生「冲突」 |

            ![image](./Pictures/ddbs/redlock-出现GC后的安全问题.avif)

    - 3.假设时钟正确的是不合理的

        - 当多个 Redis 节点「时钟」发生问题时，也会导致 Redlock 锁失效：
            - 客户端 1 获取节点 A、B、C 上的锁，但由于网络问题，无法访问 D 和 E
            - 节点 C 上的时钟「向前跳跃」，导致锁到期
            - 客户端 2 获取节点 C、D、E 上的锁，由于网络问题，无法访问 A 和 B
            - 客户端 1 和 2 现在都相信它们持有了锁（冲突）

            ![image](./Pictures/ddbs/redlock-出现时钟跳跃后的安全问题.avif)

        - Martin 觉得，Redlock 必须「强依赖」多个节点的时钟是保持同步的，一旦有节点时钟发生错误，那这个算法模型就失效了。

            - 即使 C 不是时钟跳跃，而是「崩溃后立即重启」，也会发生类似的问题。

            - Martin 继续阐述，机器的时钟发生错误，是很有可能发生的：
                - 系统管理员「手动修改」了机器时钟
                - 机器时钟在同步 NTP 时间时，发生了大的「跳跃」

        - 总之，Martin 认为，Redlock 的算法是建立在「同步模型」基础上的，有大量资料研究表明，同步模型的假设，在分布式系统中是有问题的。

            - 在混乱的分布式系统的中，你不能假设系统时钟就是对的，所以，你必须非常小心你的假设。

        - 为什么系统时钟会存在漂移呢？先简单说下系统时间，linux 提供了两个系统时间：`clock realtime` 和 `clock monotonic`
            - clock realtime 也就是 xtime/wall time，这个时间是可以被用户改变的，被 NTP 改变。Redis 的判断超时使用的 gettimeofday 函数取的就是这个时间，Redis 的过期计算用的也是这个时间。
            - clock monotonic，直译过来是单调时间，不会被用户改变，但是会被 NTP 改变。

            - 最理想的情况是：所有系统的时钟都时时刻刻和 NTP 服务器保持同步，但这显然是不可能的。

                - clock realtime 可以被人为修改，在实现分布式锁时，不应该使用 clock realtime。不过很可惜，Redis 使用的就是这个时间，Redis 5.0 使用的还是 clock realtime。Antirez 说过后面会改成 clock monotonic 的。也就是说，人为修改 Redis 服务器的时间，就能让 Redis 出问题了。

                - 人为修改了时钟
                - 从 NTP 服务收到了一个大的时钟更新事件导致时钟漂移
                - 闰秒（是指为保持协调世界时接近于世界时时刻，由国际计量局统一规定在年底或年中或者季末对协调世界时增加或减少 1 秒的调整，此时一分钟为 59 秒或者 61 秒，闰秒曾使许多大型系统崩溃）

    - 4.提出 fecing token 的方案，保证正确性

        - Fencing token 机制：类似 raft 算法、zab 协议中的全局递增数字，对这个 token 的校验需要后端资源进行校验，如此一来，相当于后端资源具备了互斥机制，这种情况下为什么还要一把分布式锁呢？

            - 读者著：类似于版本号

        - fecing token的流程：
            - 1.客户端在获取锁时，锁服务可以提供一个「递增」的 token
            - 2.客户端拿着这个 token 去操作共享资源
            - 3.共享资源可以根据 token 拒绝「后来者」的请求

            ![image](./Pictures/ddbs/fecing_token方案.avif)

        - 这样一来，无论 NPC 哪种异常情况发生，都可以保证分布式锁的安全性，因为它是建立在「异步模型」上的。

- Redis 作者 Antirez 的反驳：重点有 3 个

    - [Is Redlock safe?](http://antirez.com/news/101)

    - 1.解释时钟问题

        - Redis 作者一眼就看穿了对方提出的最为核心的问题：时钟问题。
        - Redis 作者表示，Redlock 并不需要完全一致的时钟，只需要大体一致就可以了，允许有「误差」。
            - 例如要计时 5s，但实际可能记了 4.5s，之后又记了 5.5s，有一定误差，但只要不超过「误差范围」锁失效时间即可，这种对于时钟的精度的要求并不是很高，而且这也符合现实环境。

        - 对于对方提到的「时钟修改」问题，Redis 作者反驳到：
            - 手动修改时钟：不要这么做就好了，否则你直接修改 Raft 日志，那 Raft 也会无法工作...
            - 时钟跳跃：通过「恰当的运维」，保证机器时钟不会大幅度跳跃（每次通过微小的调整来完成），实际上这是可以做到的

    - 2.解释网络延迟、GC 问题

        - Redis 作者反驳那个场景假设其实是有问题的，Redlock 是可以保证锁安全的。

            - 如果在redlock步骤 1-3 发生了网络延迟、进程 GC 等耗时长的异常情况，那在第 3 步 T2 - T1，是可以检测出来的，如果超出了锁设置的过期时间，那这时就认为加锁会失败，之后释放所有节点的锁就好了！

            - 如果对方认为，发生网络延迟、进程 GC 是在步骤 3 之后，也就是客户端确认拿到了锁，去操作共享资源的途中发生了问题，导致锁失效，那这不止是 Redlock 的问题，任何其它锁服务例如 Zookeeper，都有类似的问题，这不在讨论范畴内。

            - redis作者反驳的观点是，Martin提出GC问题场景，不止redlock，Zookeeper等也有这样的问题。
                - 客户端在拿到锁之前，无论经历什么耗时长问题，Redlock 都能够在第 3 步检测出来
                - 客户端在拿到锁之后，发生 NPC，那 Redlock、Zookeeper 都无能为力

    - 3.质疑 fencing token 机制

        - 1.这个方案必须要求要操作的「共享资源服务器」有拒绝「旧 token」的能力。

            - 例如，要操作 MySQL，从锁服务拿到一个递增数字的 token，然后客户端要带着这个 token 去改 MySQL 的某一行，这就需要利用 MySQL 的「事务隔离性」来做。

                ```sql
                // 两个客户端必须利用事务和隔离性达到目的
                // 注意 token 的判断条件
                UPDATE
                    table T
                SET
                    val = $new_val, current_token = $token
                WHERE
                    id = $id AND current_token < $token
                ```

            - 但如果操作的不是 MySQL 呢？例如向磁盘上写一个文件，或发起一个 HTTP 请求，那这个方案就无能为力了，这对要操作的资源服务器，提出了更高的要求。
                - 也就是说，大部分要操作的资源服务器，都是没有这种互斥能力的。

        - 2.退一步讲，即使 Redlock 没有提供 fecing token 的能力，但 Redlock 已经提供了随机值（就是前面讲的 UUID），利用这个随机值，也可以达到与 fecing token 同样的效果。

            - 笔者还原流程：
                - 1.客户端使用 Redlock 拿到锁
                - 2.客户端在操作共享资源之前，先把这个锁的 VALUE，在要操作的共享资源上做标记
                - 3.客户端处理业务逻辑，最后，在修改共享资源时，判断这个标记是否与之前一样，一样才修改（类似 CAS 的思路）

            - 还是以 MySQL 为例：

                - 1.客户端使用 Redlock 拿到锁
                - 2.客户端要修改 MySQL 表中的某一行数据之前，先把锁的 VALUE 更新到这一行的某个字段中（这里假设为 current_token 字段)
                - 3.客户端处理业务逻辑
                - 4.客户端修改 MySQL 的这一行数据，把 VALUE 当做 WHERE 条件，再修改

                ```sql
                UPDATE
                    table T
                SET
                    val = $new_val
                WHERE
                    id = $id AND current_token = $redlock_value
                ```

                - 可见，这种方案依赖 MySQL 的事物机制，也达到对方提到的 fecing token 一样的效果。

            - 但这里还有个小问题，是网友参与问题讨论时提出的：两个客户端通过这种方案，先「标记」再「检查+修改」共享资源，那这两个客户端的操作顺序无法保证啊？

                - 而用 Martin 提到的 fecing token，因为这个 token 是单调递增的数字，资源服务器可以拒绝小的 token 请求，保证了操作的「顺序性」！

                - Redis 作者对于这个问题做了不同的解释，我觉得很有道理，他解释道：分布式锁的本质，是为了「互斥」，只要能保证两个客户端在并发时，一个成功，一个失败就好了，不需要关心「顺序性」。

                    - 前面 Martin 的质疑中，一直很关心这个顺序性问题，但 Redis 的作者的看法却不同。

### 基于 ZooKeeper 的分布式锁

- ZooKeeper 的数据存储结构就像一棵树，这棵树由节点组成，这种节点叫做 Znode。Znode 分为四种类型：

    - 1.持久节点 （PERSISTENT）：默认的节点类型。创建节点的客户端与 ZooKeeper 断开连接后，该节点依旧存在 。

    - 2.持久节点顺序节点（PERSISTENT_SEQUENTIAL）：所谓顺序节点，就是在创建节点时，ZooKeeper 根据创建的顺序给该节点名称进行编号

    - 3.临时节点（EPHEMERAL）：和持久节点相反，当创建节点的客户端与 ZooKeeper 断开连接后，临时节点会被删除

    - 4.临时顺序节点（EPHEMERAL_SEQUENTIAL）：在创建节点时，ZooKeeper 根据创建的时间顺序给该节点名称进行编号；当创建节点的客户端与 ZooKeeper 断开连接后，临时节点会被删除。
        - 使用该类型节点实现分布式锁
        ![image](./Pictures/ddbs/zookeeper临时顺序节点.avif)

- ZooKeeper 的 watch 机制

    - ZooKeeper 集群和客户端通过长连接维护一个 session，当客户端试图创建/lock 节点的时候，发现它已经存在了，这时候创建失败，但客户端不一定就此返回获取锁失败。

    - 客户端可以进入一种等待状态，等待当/lock 节点被删除的时候，ZooKeeper 通过 watch 机制通知它，这样它就可以继续完成创建操作（获取锁）。

    - 这可以让分布式锁在客户端用起来就像一个本地的锁一样：加锁失败就阻塞住，直到获取到锁为止。这样的特性 Redis 的 Redlock 就无法实现。

- 加锁&释放锁

    - 客户端尝试创建一个 znode 节点，比如/lock。那么第一个客户端就创建成功了，相当于拿到了锁；而其它的客户端会创建失败（znode 已存在），获取锁失败。

        - 后面创建的节点会加在节点链最后的位置，等待锁的客户端会按照先来先得的顺序获取到锁。

    - 持有锁的客户端访问共享资源完成后，将 znode 删掉，这样其它客户端接下来就能来获取锁了。（客户端删除锁）

    - znode 应该被创建成 `EPHEMERAL_SEQUENTIAL` 的。这是 znode 的一个特性，它保证如果创建 znode 的那个客户端崩溃了，那么相应的 znode 会被自动删除。

- 流程

    - 1.客户端 1 和 2 都尝试创建「临时节点」，例如 /lock
    - 2.假设客户端 1 先到达，则加锁成功，客户端 2 加锁失败
    - 3.客户端 1 操作共享资源
    - 4.客户端 1 删除 /lock 节点，释放锁

    ![image](./Pictures/ddbs/Zookeeper分布式锁原理.avif)

    - Zookeeper 不像 Redis 那样，需要考虑锁的过期时间问题，它是采用了「临时节点」，保证客户端拿到锁后，只要连接不断，就可以一直持有锁。

    - 如果客户端 1 异常崩溃了，这个临时节点也会自动删除，保证了锁一定会被释放。


- 惊群效应：错误的实现——如果实现 ZooKeeper 分布式锁的时候，所有后加入的节点都监听最小的节点。那么删除节点的时候，所有客户端都会被唤醒，这个时候由于通知的客户端很多，通知操作会造成 ZooKeeper 性能突然下降，这样会影响 ZooKeeper 的使用。

- 时钟变迁问题：ZooKeeper 不依赖全局时间，它使用 zab 协议实现分布式共识算法，不存在该问题。

- 超时导致锁失效问题：ZooKeeper 不依赖有效时间，它依靠心跳维持锁的占用状态，不存在该问题。

- 看起来这个锁相当完美，没有 Redlock 过期时间的问题，而且能在需要的时候让锁自动释放。但仔细考察的话，并不尽然。客户端可以删除锁，ZooKeeper 服务器也可以删除锁，会引发什么问题。

    - 客户端 1 创建临时节点后，Zookeeper 是如何保证让这个客户端一直持有锁呢？

        - 客户端 1 此时会与 Zookeeper 服务器维护一个 Session，这个 Session 会依赖客户端「定时心跳」来维持连接。

        - 如果 Zookeeper 长时间收不到客户端的心跳，就认为这个 Session 过期了，也会把这个临时节点删除。

            ![image](./Pictures/ddbs/Zookeeper心跳.avif)

    - GC（进程暂停）问题对 Zookeeper 的锁有何影响：

        | 客户端 1                                                | 客户端 2                          |
        |---------------------------------------------------------|-----------------------------------|
        | 创建临时节点 /lock 成功，拿到了锁                       |                                   |
        | 发生长时间 GC                                           |                                   |
        | 无法给 Zookeeper 发送心跳，Zookeeper 把临时节点「删除」 |                                   |
        |                                                         | 创建临时节点 /lock 成功，拿到了锁 |
        | GC 结束，它仍然认为自己持有锁（冲突）                   |                                   |

        - 这就是前面 Redis 作者在反驳的文章中提到的：如果客户端已经拿到了锁，但客户端与锁服务器发生「失联」（例如 GC），那不止 Redlock 有问题，其它锁服务都有类似的问题，Zookeeper 也是一样！

- 另外一种使用 zk 作分布式锁的实现方式：不使用临时节点，而是使用持久节点加锁，把 zk 集群当做一个 MySQL、或者一个单机版的 Redis，加锁的时候存储锁的到期时间，这种方案把锁的删除、判断过期这两个职责交给客户端处理。（当做一个可以容错的 MySQL，性能问题！）

- 结论：使用 ZooKeeper 的临时节点实现的分布式锁，它的锁安全期是在客户端取得锁之后到 zk 服务器会话超时的阈值（跨机房部署很容易出现）的时间之间。它无法设置占用分布式锁的时间，何时 zk 服务器会删除锁是不可预知的，所以这种方式它比较适合一些客户端获取到锁之后能够快速处理完毕的场景。

    - 优点：

        - ZooKeeper 分布式锁基于分布式一致性算法实现，能有效的解决分布式问题，不受时钟变迁影响，不可重入问题，使用起来也较为简单；

        - 当锁持有方发生异常的时候，它和 ZooKeeper 之间的 session 无法维护。ZooKeeper 会在 Session 租约到期后，自动删除该 Client 持有的锁，以避免锁长时间无法释放而导致死锁。

    - 缺点：

        - 性能并不太高：每次在创建锁和释放锁的过程中，都要动态创建、销毁瞬时节点来实现锁功能。ZK 中创建和删除节点只能通过 Leader 服务器来执行，然后 Leader 服务器还需要将数据同步不到所有的 Follower 机器上，这样频繁的网络通信，性能的短板是非常突出的。

            - 由于 ZooKeeper 的高可用特性，所以在并发量不是太高的场景，推荐使用 ZooKeeper 的分布式锁。

### 基于 Etcd 的分布式锁

- 流程：

    - Etcd 虽然没有像 Zookeeper 提供临时节点的概念，但 Etcd 提供了一个叫「租约」的概念。

        - 之后，我们定时给这个租约进行「续期」，保证我们创建的节点一直有效，一直持有锁。

            - 这里的定时给租约续期的步骤，和上面 Zookeeper 客户端定时给 Server 发心跳类似，其目的都是让服务端保持这个 Session 或 KV 持续有效。

    | 客户端 1                                   | 客户端 2                               |
    |--------------------------------------------|----------------------------------------|
    | 创建一个 lease 租约（设置过期时间）        |                                        |
    | 携带这个租约，创建 /lock 节点              |                                        |
    | 发现节点不存在，拿锁成功                   |                                        |
    |                                            | 同样方式创建节点，节点已存在，拿锁失败 |
    | 定时给这个租约「续期」，保持自己一直持有锁 |                                        |
    | 操作共享资源                               |                                        |
    | 删除 /lock 节点，释放锁                    |                                        |

    ![image](./Pictures/ddbs/etcd分布式锁原理.avif)

- 它依旧存在和 Zookeeper 相同的GC（进程暂停）问题：

   | 客户端 1                                                        | 客户端 2                          |
   |-----------------------------------------------------------------|-----------------------------------|
   | 创建节点 /lock 成功，拿到了锁                                   |                                   |
   | 发生长时间 GC                                                   |                                   |
   | 无法向 Etcd 发请求给租约「续期」。租约到期，Etcd 「删除」锁节点 |                                   |
   |                                                                 | 创建临时节点 /lock 成功，拿到了锁 |
   | GC 结束，它仍然认为自己持有锁（冲突）                           |                                   |

- 结论：一个分布式锁，无论是基于 Redis 还是 Zookeeper、Etcd 实现，在极端情况下，都无法保证 100% 安全，都存在失效的可能。

- 但为什么我们总是能听到很多人使用 Zookeeper、Etcd 实现分布式锁呢？

    - 因为抛开安全性，Zookeeper 和 Etcd 相比于 Redis 实现分布锁，在功能层面有一个非常好用的特性：Watch。

        - 这个 API 允许客户端「监听」Zookeeper、Etcd 某个节点的变化，以此实现「公平」的分布式锁

### 基于 Google 的 Chubby 的分布式锁

- [《The Chubby lock service for loosely-coupled distributed systems》](https://research.google.com/archive/chubby.html)

- [YouTube 有一个的讲 Chubby 的 talk](https://www.youtube.com/watch?v=PqItueBaiRg&feature=youtu.be&t=487)

- Chubby 给出的用于解决（缓解）这一问题的机制称为 sequencer，类似于DDIA作者Martin的fencing token 机制。锁的持有者可以随时请求一个 sequencer，这是一个字节串，它由三部分组成：
    - 锁的名字。
    - 锁的获取模式（排他锁还是共享锁）。
    - lock generation number（一个 64bit 的单调递增数字）。作用相当于 fencing token 或 epoch number。

- sequencer：客户端拿到 sequencer 之后，在操作资源的时候把它传给资源服务器。然后，资源服务器负责对 sequencer 的有效性进行检查。检查可以有两种方式：

    - 调用 Chubby 提供的 API，CheckSequencer()，将整个 sequencer 传进去进行检查。这个检查是为了保证客户端持有的锁在进行资源访问的时候仍然有效。
    - 将客户端传来的 sequencer 与资源服务器当前观察到的最新的 sequencer 进行对比检查。可以理解为与 Martin 描述的对于 fencing token 的检查类似。

- lock-delay（锁延期机制）：

    - Chubby 允许客户端为持有的锁指定一个 lock-delay 的时间值（默认是 1 分钟）

    - 当 Chubby 发现客户端被动失去联系的时候，并不会立即释放锁，而是会在 lock-delay 指定的时间内阻止其它客户端获得这个锁。这是为了在把锁分配给新的客户端之前，让之前持有锁的客户端有充分的时间把请求队列排空(draining the queue)，尽量防止出现延迟到达的未处理请求。

- 为了应对锁失效问题，Chubby 提供的两种处理方式：CheckSequencer()检查与上次最新的 sequencer 对比、lock-delay，它们对于安全性的保证是从强到弱的。而且，这些处理方式本身都没有保证提供绝对的正确性(correctness)。

    - 但是，Chubby 确实提供了单调递增的 lock generation number，这就允许资源服务器在需要的时候，利用它提供更强的安全性保障。

## Replication复制模型

- [美团技术团队：Replication（上）：常见的复制模型&分布式系统的挑战](https://tech.meituan.com/2022/08/25/replication-in-meituan-01.html)

- 复制的目标需要保证若干个副本上的数据是一致的

    - “一致”是一个十分不确定的词
        - 既可以是不同副本上的数据在任何时刻都保持完全一致
        - 也可以是不同客户端不同时刻访问到的数据保持一致。

    - 一致性的强弱也会不同
        - 有可能需要任何时候不同客端都能访问到相同的新的数据
        - 也有可能是不同客户端某一时刻访问的数据不相同，但在一段时间后可以访问到相同的数据。

    - 为什么不直接让所有副本在任意时刻都保持一致？

        - 性能：因为冗余的目的不完全是为了高可用，还有延迟和负载均衡这类提升性能的目的，如果只一味地为了地强调数据一致，可能得不偿失。

        - 复杂性是因为分布式系统中，有着比单机系统更加复杂的不确定性，节点之间由于采用不大可靠的网络进行传输，并且不能共享统一的一套系统时间和内存地址（后文会详细进行说明），这使得原本在一些单机系统上很简单的事情，在转到分布式系统上以后就变得异常复杂。
            - 这种复杂性和不确定性甚至会让我们怀疑，这些副本上的数据真的能达成一致吗？

- 数据复制模式

    - 1.主从模式：最简单的复制模式

        - 主副本将数据存储在本地后，将数据更改作为日志，或者以更改流的方式发到各个从副本（后文也会称节点）中。在这种模式下，所有写请求就全部会写入到主节点上，读请求既可以由主副本承担也可以由从副本承担，这样对于读请求而言就具备了扩展性，并进行了负载均衡。

        - 但这里面存在一个权衡点，就是客户端视角看到的一致性问题。这个权衡点存在的核心在于，数据传输是通过网络传递的，数据在网络中传输的时间是不能忽略的。

        ![image](./Pictures/ddbs/主从模式-同步和异步复制.avif)

        - 如上图所示，在这个时间窗口中，任何情况都有可能发生。在这种情况下，客户端何时算写入完成，会决定其他客户端读到数据的可能性。


        - 异步复制：这份数据有一个主副本和一个从副本，如果主副本保存后即向客户端返回成功

            - 问题：如果从副本承担读请求，假设reader1和reader2同时在客户端收到写入成功后发出读请求，两个reader就可能读到不一样的值。

            - 解决方法：

                - 1.让客户端只从主副本读取数据，这样，在正常情况下，所有客户端读到的数据一定是一致的
                - 2.同步复制

        - 同步复制：如果等到数据传送到从副本1，并得到确认之后再返回客户端成功

            - 假设使用纯的同步复制，当有多个副本时，任何一个副本所在的节点发生故障，都会使写请求阻塞，同时每次写请求都需要等待所有节点确认，如果副本过多会极大影响吞吐量。

        - 很多系统会把这个决策权交给用户，这里我们以Kafka为例，首先提供了同步与异步复制的语义（通过客户端的acks参数确定），另外提供了ISR机制，而只需要ISR中的副本确认即可，系统可以容忍部分节点因为各种故障而脱离ISR，那样客户端将不用等待其确认，增加了系统的容错性。当前Kafka未提供让从节点承担读请求的设计，但在高版本中已经有了这个Feature。这种方式使系统有了更大的灵活性，用户可以根据场景自由权衡一致性和可用性。

    - 2.多主节点复制

        - 主从复制模型中存在一个比较严重的弊端，就是所有写请求都需要经过主节点，因为只存在一个主节点，就很容易出现性能问题。虽然有从节点作为冗余应对容错，但对于写入请求实际上这种复制方式是不具备扩展性的。

        - 多主节点复制模型：两个主节点在接到写请求后，将数据同步到同一个数据中心的从节点。此外，该主节点还将不断同步在另一数据中心节点上的数据，由于每个主节点同时处理其他主节点的数据和客户端写入的数据，因此需要模型中增加一个冲突处理模块，最后写到主节点的数据需要解决冲突。

        ![image](./Pictures/ddbs/多主节点复制.avif)


        - 使用场景

            - 1.多数据中心部署（异地多活）：在同一个地域使用多主节点意义不大，在多个地域或者数据中心部署相比主从复制模型有如下的优势

                - 性能提升：性能提升主要表现在两个核心指标上，首先从吞吐方面，传统的主从模型所有写请求都会经过主节点，主节点如果无法采用数据分区的方式进行负载均衡，可能存在性能瓶颈，采用多主节点复制模式下，同一份数据就可以进行负载均衡，可以有效地提升吞吐。另外，由于多个主节点分布在多个地域，处于不同地域的客户端可以就近将请求发送到对应数据中心的主节点，可以最大程度地保证不同地域的客户端能够以相似的延迟读写数据，提升用户的使用体验。

                - 容忍数据中心失效：对于主从模式，假设主节点所在的数据中心发生网络故障，需要发生一次节点切换才可将流量全部切换到另一个数据中心，而采用多主节点模式，则可无缝切换到新的数据中心，提升整体服务的可用性。

            - 2.离线客户端操作：网络离线的情况下还能继续工作
                - 例子：我们笔记本电脑上的笔记或备忘录，我们不能因为网络离线就禁止使用该程序，我们依然可以在本地愉快的编辑内容，当我们连上网之后，这些内容又会同步到远程的节点上，这里面我们把本地的App也当做其中的一个副本，那么就可以承担用户在本地的变更请求。联网之后，再同步到远程的主节点上。

            - 3.协同编辑;对离线客户端操作进行扩展
                - 例子：假设我们所有人同时编辑一个文档，每个人通过Web客户端编辑的文档都可以看做一个主节点。这里我们拿美团内部的学城（内部的Wiki系统）举例，当我们正在编辑一份文档的时候，基本上都会发现右上角会出现“xxx也在协同编辑文档”的字样，当我们保存的时候，系统就会自动将数据保存到本地并复制到其他主节点上，各自处理各自端上的冲突。
                    - 另外，当文档出现了更新时，学城会通知我们有更新，需要我们手动点击更新，来更新我们本地主节点的数据。书中说明，虽然不能将协同编辑完全等同于数据库复制，但却是有很多相似之处，也需要处理冲突问题。

        - 冲突解决：多主复制模型最大挑战。《DDIA》中给出的通用解法

            - 冲突实例
                ![image](./Pictures/ddbs/冲突实例.avif)

            - 问题：在图中，由于多主节点采用异步复制，用户将数据写入到自己的网页就返回成功了，但当尝试把数据复制到另一个主节点时就会出问题，这里我们如果假设主节点更新时采用类似CAS的更新方式时更新时，都会由于预期值不符合从而拒绝更新。针对这样的冲突，书中给出了几种常见的解决思路。

            - 解决方法：

                - 1.避免冲突：所谓解决问题最根本的方式则是尽可能不让它发生，如果能够在应用层保证对特定数据的请求只发生在一个节点上，这样就没有所谓的“写冲突”了。

                    - 例子：继续拿上面的协同编辑文档举例，如果我们把每个人的都在填有自己姓名表格的一行里面进行编辑，这样就可以最大程度地保证每个人的修改范围不会有重叠，冲突也就迎刃而解了

                - 2.收敛于一致状态：对于单主节点模式而言，如果同一个字段有多次写入，那么最后写入的一定是最新的。
                    - ZK、KafkaController、KafkaReplica都有类似Epoch的方式去屏蔽过期的写操作，由于所有的写请求都经过同一个节点，顺序是绝对的，但对于多主节点而言，由于没有绝对顺序的保证，就只能试图用一些方式来决策相对顺序，使冲突最终收敛，这里提到了几种方法：

                        - 给每个写请求分配Uniq-ID，例如一个时间戳，一个随机数，一个UUID或Hash值，最终取最高的ID作为最新的写入。如果基于时间戳，则称作最后写入者获胜（LWW）

                            - 但很遗憾，文章一开始也提到了，分布式系统没有办法在机器间共享一套统一的系统时间，所以这个方案很有可能因为这个问题导致数据丢失（时钟漂移）

                                - 每个副本分配一个唯一的ID，ID高的更新优先级高于地域低的，这显然也会丢失数据。

                    - 当然，我们可以用某种方式做拼接，或利用预先定义的格式保留冲突相关信息，然后由用户自行解决。

                - 3.用户自行处理
                    - 其实，把这个操作直接交给用户，让用户自己在读取或写入前进行冲突解决，这种例子也是屡见不鲜，Github采用就是这种方式。

        - 为什么会发生冲突？对事件发生的先后顺序不确定，但这些事件的处理主体都有重叠（比如都有设置某个数据的值）

            - 1.直接指定事件顺序
                - 我们一个最直观的想法就是，两个请求谁新要谁的，那这里定义“最新”是个问题，一个很简单的方式是使用时间戳，这种算法叫做最后写入者获胜LWW。
                - 但分布式系统中没有统一的系统时钟，不同机器上的时间戳无法保证精确同步，那就可能存在数据丢失的风险，并且由于数据是覆盖写，可能不会保留中间值，那么最终可能也不是一致的状态，或出现数据丢失。如果是一些缓存系统，覆盖写看上去也是可以的，这种简单粗暴的算法是非常好的收敛冲突的方式，但如果我们对数据一致性要求较高，则这种方式就会引入风险，除非数据写入一次后就不会发生改变。

            - 2.从事件本身推断因果关系和并发

                - 《DDIA》书中一个多主节点复制的例子

                    ![image](./Pictures/ddbs/违背因果关系示例.avif)

                    - ClientA首先向Leader1增加一条数据x=1
                    - Leader1采用异步复制的方式，将变更日志发送到其他的Leader上。
                    - 在复制过程中，ClientB向Leader3发送了更新请求，内容则是更新Key为x的Value，使Value=Value+1。

                - 原图中想表达的是，update的日志发送到Leader2的时间早于insert日志发送到Leader2的时间，会导致更新的Key不存在。但是，这种所谓的事件关系本身就不是完全不相干的，书中称这种关系为依赖或者Happens-before。

                - 解决方法：书中给出了检测这类事件的一种算法，并举了一个购物车的例子，如图所示（以餐厅扫码点餐的场景为例）：

                    ![image](./Pictures/ddbs/扫码点餐示例.avif)

                    - 图中两个客户端同时向购物车里放东西，事例中的数据库假设只有一个副本

                        - 首先Client1向购物车中添加牛奶，此时购物车为空，返回版本1，Value为[牛奶]。

                        - 此时Client2向其中添加鸡蛋，其并不知道Client1添加了牛奶，但服务器可以知道，因此分配版本号为2，并且将鸡蛋和牛奶存成两个单独的值，最后将两个值和版本号2返回给客户端。此时服务端存储了(鸡蛋) 2 (牛奶)1。

                        - 同理，Client1添加面粉，这时候Client1只认为添加了(牛奶)，因此将面粉与牛奶合并发送给服务端(牛奶，面粉)，同时还附带了之前收到的版本号1，此时服务端知道，新值(牛奶，面粉)可以替换同一个版本号中的旧值(牛奶)，但(鸡蛋)是并发事件，分配版本号3，返回值(牛奶，面粉) 3 (鸡蛋)2。

                        - 同理，Client2向购物车添加(火腿)，但在之前的请求中，返回了(鸡蛋)(牛奶)，因此和火腿合并发送给服务端(鸡蛋，牛奶，火腿)，同时附带了版本号2，服务端直接将新值覆盖之前版本2的值(鸡蛋)，但(牛奶，面粉)是并发事件，因此存储值为(牛奶，面粉) 3 (鸡蛋，牛奶，火腿) 4并分配版本号4。

                        - 最后一次Client添加培根，通过之前返回的值里，知道有(牛奶，面粉，鸡蛋)，Client将值合并(牛奶，面粉，鸡蛋，培根)联通之前的版本号一起发送给服务端，服务端判断(牛奶，面粉，鸡蛋，培根)可以覆盖之前的(牛奶，面粉)但(鸡蛋，牛奶，火腿)是并发值，加以保留。

                - 通过上面的例子，我们看到了一个根据事件本身进行因果关系的确定。书中给出了进一步的抽象流程：

                    - 服务端为每个主键维护一个版本号，每当主键新值写入时递增版本号，并将新版本号和写入值一起保存。

                    - 客户端写主键，写请求比包含之前读到的版本号，发送的值为之前请求读到的值和新值的组合，写请求的相应也会返回对当前所有的值，这样就可以一步步进行拼接。

                    - 当服务器收到有特定版本号的写入时，覆盖该版本号或更低版本号的所有值，保留高于请求中版本号的新值（与当前写操作属于并发）。

                - 有了这套算法，我们就可以检测出事件中有因果关系的事件与并发的事件，而对于并发的事件，仍然像上文提到的那样，需要依据一定的原则进行合并，如果使用LWW，依然可能存在数据丢失的情况。因此，需要在服务端程序的合并逻辑中需要额外做些事情。

                    - 在购物车这个例子中，比较合理的是合并新值和旧值，即最后的值是[牛奶，鸡蛋，面粉，火腿，培根]，但这样也会导致一个问题，假设其中的一个用户删除了一项商品，但是union完还是会出现在最终的结果中，这显然不符合预期。因此可以用一个类似的标记位，标记记录的删除，这样在合并时可以将这个商品踢出，这个标记在书中被称为墓碑（Tombstone）。

    - 无主节点复制

        - 去掉了主节点，任何副本都能直接接受来自客户端的写请求
        - 再有一些系统中，会给到一个协调者代表客户端进行写入（以Group Commit为例，由一个线程积攒所有客户端的请求统一发送），与多主模式不同，协调者不负责控制写入顺序，这个限制的不同会直接影响系统的使用方式。

        - 处理节点失效：

            - 一个数据系统拥有三个副本，当其中一个副本不可用时，在主从模式中，如果恰好是主节点，则需要进行节点切换才能继续对外提供服务，但在无主模式下，并不存在这一步骤

            ![image](./Pictures/ddbs/Quorum写入处理节点失效.avif)

            - 这里的Replica3在某一时刻无法提供服务，此时用户可以收到两个Replica的写入成功的确认，即可认为写入成功，而完全可以忽略那个无法提供服务的副本。

            - 问题：当失效的节点恢复时，会重新提供读写服务，此时如果客户端向这个副本读取数据，就会请求到过期值。
            - 解决方法：这里客户端就不是简单向一个节点请求数据了，而是向所有三个副本请求，这时可能会收到不同的响应，这时可以通过类似版本号来区分数据的新旧（类似上文中并发写入的检测方式）。

            - 问题：副本恢复之后的一致性问题
            - 解决方法：
                - 1.客户端读取时对副本做修复，如果客户端通过并行读取多个副本时，读到了过期的数据，可以将数据写入到旧副本中，以便追赶上新副本。
                - 2.反熵查询，一些系统在副本启动后，后台会不断查找副本之间的数据diff，将diff写到自己的副本中，与主从复制模式不同的是，此过程不保证写入的顺序，并可能引发明显的复制滞后。


        - 读写Quorum
            - 要想保证读到的是写入的新值，每次只从一个副本读取显然是有问题的，那么需要每次写几个副本呢，又需要读取几个副本呢？
                - 一个核心点就是让写入的副本和读取的副本有交集，那么我们就能够保证读到新值了。
                    - 公式：w + r > N
                    - N为副本的数量
                    - w为每次并行写入的节点数
                    - r为每次同时读取的节点数

                - 一般配置方法： w = r = (n+1) / 2
                    - w，r与N的关系决定了能够容忍多少的节点失效
                    - 假设N=3, w=2, r=2，可以容忍1个节点故障。
                    - 假设N=5，w=3, r=3 可以容忍2个节点故障。
                    - N个节点可以容忍(n+1)/2 - 1个节点故障。

            - 对于一些没有很强一致性要求的系统，可以配置w+r <= N，这样可以等待更少的节点即可返回，
                - 这样虽然有可能读取到一个旧值，但这种配置可以很大提升系统的可用性，当网络大规模故障时更有概率让系统继续运行而不是由于没有达到Quorum限制而返回错误。

            - 假设在w+r>N的情况下，实际上也存在边界问题导致一些一致性问题：
                - 首先假设是Sloppy Quorum（一个更为宽松的Quorum算法），写入的w和读取的r可能完全不相交，因此不能保证数据一定是新的。
                - 如果两个写操作同时发生，那么还是存在冲突，在合并时，如果基于LWW，仍然可能导致数据丢失。
                - 如果写读同时发生，也不能保证读请求一定就能取到新值，因为复制具有滞后性（上文的复制窗口）。
                - 如果某些副本写入成功，其他副本写入失败（磁盘空间满）且总的成功数少于w，那些成功的副本数据并不会回滚，这意味着及时写入失败，后续还是可能读到新值。

- 分布式系统的现实例子：
    - 假设老板想要处理一批文件，如果让一个人做，需要十天。但老板觉得有点慢，于是他灵机一动，想到可以找十个人来搞定这件事，然后自己把工作安排好，认为这十个人一天正好干完，于是向他的上级信誓旦旦地承诺一天搞定这件事。他把这十个人叫过来，把任务分配给了他们，他们彼此建了个微信群，约定每个小时在群里汇报自己手上的工作进度，并强调在晚上5点前需要通过邮件提交最后的结果。于是老版就去愉快的喝茶去了，但是现实却让他大跌眼镜。
        - 首先，有个同学家里信号特别差，报告进度的时候只成功报告了3个小时的，然后老板在微信里问，也收不到任何回复，最后结果也没法提交。
        - 另一个同学家的表由于长期没换电池，停在了下午四点，结果那人看了两次表都是四点，所以一点都没着急，中间还看了个电影，慢慢悠悠做完交上去了，他还以为老板会表扬他，提前了一小时交，结果实际上已经是晚上八点了。
        - 还有一个同学因为前一天没睡好，效率极低，而且也没办法再去高强度的工作了。结果到了晚上5点，只有7个人完成了自己手头上的工作。
        - 在分布式的系统中，我们会遇到各种“稀奇古怪”的故障，例如家里没信号（网络故障)，不管怎么叫都不理你，或者断断续续的理你。另外，因为每个人都是通过自己家的表看时间的，所谓的5点需要提交结果，在一定程度上旧失去了参考的绝对价值。因此，作为上面例子中的“老板”，不能那么自信的认为一个人干工作需要10天，就可以放心交给10个人，让他们一天搞定。

- 分布式系统特有的故障

    - 1.不可靠网络：一个纯的分布式系统而言，它的架构大多为Share Nothing架构，即使是存算分离这种看似的Share Storage，它的底层存储一样是需要解决Share Nothing的。

        - 问题：所谓Nothing，这里更倾向于叫Nothing but Network，网络是不同节点间共享信息的唯一途径，数据的传输主要通过以太网进行传输，这是一种异步网络，也就是网络本身并不保证发出去的数据包一定能被接到或是何时被收到。这里可能发生各种错误

            - 1.请求丢失
            - 2.请求正在某个队列中等待
            - 3.远程节点已经失效
            - 4.远程节点无法响应
            - 5.远程节点已经处理完请求，但在ack的时候丢包
            - 6.远程接收节点已经处理完请求，但回复处理很慢

        - 解决方法：TCP

        - 问题：应用层发生了下面的问题，那么网络包就会在内核的Socket Buffer中排队得不到处理，或响应得不到处理。
            - 1.应用程序GC。
            - 2.处理节点在进行重的磁盘I/O，导致CPU无法从中断中恢复从而无法处理网络请求。
            - 3.由于内存换页导致的颠簸。

            - 这些问题和网络本身的不稳定性相叠加，使得外界认为的网络不靠谱的程度更加严重。因此这些不靠谱，会极大地加重上一章中的 复制滞后性，进而带来各种各样的一致性问题。这里引申出两个问题：

        - 解决方法：需要把上面的“不确定”变成一种确定的形式，那就是利用“超时”机制。

            - 1.假设能够检测出失效，我们应该如何应对？
                - 1.负载均衡需要避免往失效的节点上发数据（服务发现模块中的健康检查功能）。
                - 2.如果在主从复制中，如果主节点失效，需要出发选举机制（Kafka中的临时节点掉线，Controller监听到变更触发新的选举，Controller本身的选举机制）。
                - 3.如果服务进程崩溃，但操作系统运行正常，可以通过脚本通知其他节点，以便新的节点来接替（Kafka的僵尸节点检测，会触发强制的临时节点掉线）。
                - 4.如果路由器已经确认目标节点不可访问，则会返回ICMP不可达（ping不通走下线）。

            - 2.如何设置超时时间是合理的？
                - 很遗憾地告诉大家，这里面实际上是个权衡的问题，短的超时时间会更快地发现故障，但同时增加了误判的风险。这里假设网络正常，那么如果端到端的ping时间为d，处理时间为r，那么基本上请求会在2d+r的时间完成。但在现实中，我们无法假设异步网络的具体延迟，实际情况可能会更复杂。因此这是一个十分靠经验的工作。

    - 2.不可靠的时钟
        - 时钟：主要用来做两件事
            - 1.描述当前的绝对时间
            - 2.描述某件事情的持续时间

        - 在DDIA中，对于这两类用途给出了两种时间
            - 一类成为墙上时钟，它们会返回当前的日期和时间
                - 例如clock_gettime(CLOCK_REALTIME) 或者System.currentTimeMills，但这类反应精确时间的API，由于时钟同步的问题，可能会出现回拨的情况。
            - 作为持续时间的测量通常采用单调时钟，例如clock_gettime(CLOCK_MONOTONIC) 或者System.nanoTime。

        - 时钟问题导致事件顺序判断异常

            ![image](./Pictures/ddbs/不可靠的时钟.avif)

            - Node1的时钟比Node3快，当两个节点在处理完本地请求准备写Node2时发生了问题，原本ClientB的写入明显晚于ClientA的写入，但最终的结果，却由于Node1的时间戳更大而丢弃了本该保留的x+=1，这样，如果我们使用LWW，一定会出现数据不符合预期的问题。

            - 由于时钟不准确，这里就引入了统计学中的置信区间的概念，也就是这个时间到底在一个什么样的范围里，一般的API是无法返回类似这样的信息的。
                - 不过，Google的TrueTime API则恰恰能够返回这种信息，其调用结果是一个区间，有了这样的API，确实就可以用来做一些对其有依赖的事情了，例如Google自家的Spanner，就是使用TrueTime实现快照隔离。

- [美团技术团队：Replication（下）：事务，一致性与共识](https://tech.meituan.com/2022/08/25/replication-in-meituan-02.html)

- 复制滞后性：如果在复制期间客户端发起读请求，可能不同的客户端读到的数据是不一样的。

    - 例子1：用户先更新，然后查看更新结果的事例

        ![image](./Pictures/ddbs/复制滞后问题.avif)

        - 例子：用户对某一条博客下做出了自己的评论，该服务中的DB采用纯的异步复制，数据写到主节点就返回评论成功，然后用户想刷新下页面看看自己的评论能引发多大的共鸣或跟帖，这是由于查询到了从节点上，所以发现刚才写的评论“不翼而飞”了

        - 如果系统能够避免出现上面这种情况，我们称实现了“写后读一致性”（读写一致性）。

    - 例子2：用户同样是在系统中写入了一条评论，该模块依旧采用了纯异步复制的方法实现

        - 此时有另一位用户来看，首先刷新页面时看到了User1234的评论，但下一次刷新，则这条评论又消失了，好像时钟出现了回拨

        ![image](./Pictures/ddbs/复制滞后问题1.avif)

        - 如果系统能够保证不会让这种情况出现，说明系统实现了“单调读”一致性（比如腾讯体育的比分和详情页）

    - 例子3：有两个写入客户端，其中Poons问了个问题，然后Cake做出了回答。

        - 从顺序上，MrsCake是看到Poons的问题之后才进行的回答，但是问题与回答恰好被划分到了数据库的两个分区（Partition）上，对于下面的Observer而言，Partition1的Leader延迟要远大于Partition2的延迟，因此从Observer上看到的是现有答案后有的问题，这显然是一个违反自然规律的事情

        ![image](./Pictures/ddbs/复制滞后问题2.avif)

        - 如果能避免这种问题出现，那么可称为系统实现了“前缀读一致性”。

    - 由于复制的滞后性，带来的一个后果就是系统只是具备了最终一致性，由于这种最终一致性，会大大的影响用户的一些使用体验。

    - 上面三个例子虽然代表了不同的一致性，但都有一个共性：多个客户端甚至是一个客户端读写多个副本时所发生的的问题。这里我们将这类一致性问题称为“内部一致性”

- 内部一致性概述

    - 内部一致性并不是分布式系统特有的问题，在多核领域又称内存一致性，是为了约定多处理器之间协作。

    - 每个CPU逻辑核心都有自己的一套独立的寄存器和L1、L2Cache，这就导致如果我们在并发编程时，每个线程如果对某个主存地址中变量进行修改，可能都是优先修改自己的缓存，并且读取变量时同样是会先读缓存。

        - 这实际上和我们在分布式中多个客户端读写多个副本的现象是类似的，只不过分布式系统中是操作粒度，而处理器则是指令粒度。

    - 分布式中的内部一致性主要分为4大类：线性一致性-->顺序一致性-->因果一致性-->处理器一致性

        - 从偏序与全序来划分，则划分为强一致性（线性一致性）与最终一致性。

        ![image](./Pictures/ddbs/4大类一致性.avif)

- 线性一致性

    - 有三个客户端同时操作主键x，这个主键在书中被称为寄存器（Register），对该寄存器存在如下几种操作：
        - 1.write(x，v) =>r表示尝试更新x的值为v，返回更新结果r。
        - 2.read(x) => v表示读取x的值，返回x的值为v。

    - 在C更新x的值时，A和B反复查询x的最新值，比较明确的结果是由于ClientA在ClientC更新x之前读取，所以第一次read(x)一定会为0，而ClientA的最后一次读取是在ClientC成功更新x的值后，因此一定会返回1。而剩下的读取，由于不确定与write(x,1)的顺序（并发），因此可能会返回0也可能返回1。

        ![image](./Pictures/ddbs/线性一致性.avif)

    - 在一个线性一致性系统中，在写操作调用到返回之前，一定有一个时间点，客户端调用read能读到新值，在读到新值之后，后续的所有读操作都应该返回新值。（将上面图中的操作做了严格的顺序，及ClientA read->ClientB read->ClientC write-ClientA read->clientB read->clientAread）

        - cas(x, v_old, v_new)=>r  及如果此时的值时v_old则更新x的值为v_new，返回更新结果。

        ![image](./Pictures/ddbs/线性一致性1.avif)

    - 每条数显代表具体事件发生的时点，线性一致性要求：如果连接上述的竖线，要求必须按照时间顺序向前推移，不能向后回拨（图中的read(x)=2就不满足线性化的要求，因为x=2在x=4的左侧）

        ![image](./Pictures/ddbs/线性一致性2.avif)

    - 什么时候需要依赖线性化？

        - 如果只是类似论坛中评论的先后顺序，或者是体育比赛页面刷新页面时的来回跳变，看上去并不会有什么致命的危害。但在某些场景中，如果系统不是线性的可能会造成更严重的后果。

        - 1.加锁&&选主：在主从复制模型下，需要有一个明确的主节点去接收所有写请求，这种选主操作一般会采用加锁实现，如果我们依赖的锁服务不支持线性化的存储，那就可能出现跳变导致“脑裂”现象的发生，这种现象是绝对不能接受的。因此针对选主场景所依赖的分布式锁服务的存储模块一定需要满足线性一致性（一般而言，元数据的存储也需要线性化存储）。

        - 2.约束与唯一性保证：这种场景也是显而易见的，比如唯一ID、主键、名称等等，如果没有这种线性化存储承诺的严格的顺序，就很容易打破唯一性约束导致很多奇怪的现象和后果。

        - 3.跨通道（系统）的时间依赖：除了同一系统中，可能服务横跨不同系统，对于某个操作对于不同系统间的时序也需要有限制，书中举了这样一个例子。

            ![image](./Pictures/ddbs/跨通道线性一致性.avif)

            - 用户上传图片，类似后端存储服务可能会根据全尺寸图片生成低像素图片，以便增加用户服务体验，但由于MQ不适合发送图片这种大的字节流，因此全尺寸图片是直接发给后端存储服务的，而截取图片则是通过MQ在后台异步执行的，这就需要2中上传的文件存储服务是个可线性化的存储。如果不是，在生成低分辨率图像时可能会找不到，或读取到半张图片，这肯定不是我们希望看到的。

    - 如何实现这样的线性化系统

        - 主从复制（部分能实现）：如果使用同步复制，那样系统确实是线性化的，但有一些极端情况可能会违反线性化，比如由于成员变更过程中的“脑裂”问题导致消费异常，或者如果我们使用异步复制故障切换时会同时违反事务特性中的持久化和内部一致性中的线性化。

        - 共识算法（线性化）：共识算法在后文会重点介绍，它与主从复制类似，但通过更严格的协商机制实现，可以在主从复制的基础上避免一些可能出现的“脑裂”等问题，可以比较安全的实现线性化存储。

        - 多主复制（不能线性化）。

        - 无主复制（可能不能线性化）：主要取决于具体Quorum的配置，对强一致的定义，下图给了一种虽然满足严格的Quorum，但依然无法满足线性化的例子。
            ![image](./Pictures/ddbs/Quorum无法实现线性一致.avif)

    - 实现线性化的代价——是时候登场了，CAP理论
        - 一旦网络断开（P），副本间一定会导致状态无法达到线性一致，这时候到底是继续提供服务但可能得到旧值（A），还是死等网络恢复保证状态的线性一致呢（C）

        - 1.捕捉因果关系：与上一次分享的内容类似，并发操作间有两种类型，可能有些操作间具有天然逻辑上的因果关系，还有些则没法确定，这里我们首先先尝试捕获那些有因果关系的操作，实现个因果一致性。这里的捕获我们实际需要存储数据库（系统）操作中的所有因果关系，我们可以使用类似版本向量的方式（上一篇中两个人并发操作购物车的示例）。

        - 2.化被动为主动——主动定义
            - 上面被动地不加任何限制的捕捉因果，会带来巨大的运行开销（内存，磁盘），这种关系虽然可以持久化到磁盘，但分析时依然需要被载入内存，这就让我们有了另一个想法，我们是否能在操作上做个标记，直接定义这样的因果关系？
            - 序列号来定义操作间的因果关系：保证A在B之前发生，那就确保A的全序ID在B之前即可，其他的并发操作顺序不做硬限制，但操作间在处理器的相对顺序不变，这样我们不但实现了因果一致性，还对这个限制进行了增强。

        - 3.Lamport时间戳

            - 上面的方式在主从复制模式下很容易实现，但如果是多主或者无主的复制模型，我们很难设计这种全局的序列号发号器

            - 书中给出了一些可能的解决方案，目的是生成唯一的序列号
                - 每个节点各自产生序列号。
                - 每个操作上带上时间戳。
                - 预先分配每个分区负责产生的序列号。

            ![image](./Pictures/ddbs/Lamport时间戳.avif)

            - 简单来说定义的就是使用逻辑变量定义了依赖关系，它给定了一个二元组<Counter, NodeId>，然后给定了一个比较方式：
                - 先比较Counter，Counter大的后发生（会承诺严格的偏序关系）。
                - 如果Counter相同，直接比较NodeId，大的定义为后发生（并发关系）。

            - 如果只有这两个比较，还不能解决上面的因果偏序被打破的问题，但是这个算法不同的是，它会把这个Node的Counter值内嵌到请求的响应体中，比如图中的A，在第二次向Node2发送更新max请求时，会返回当前的c=5，这样Client会把本地的Counter更新成5，下一次会增1这样使用Node上的Counter就维护了各个副本上变量的偏序关系，如果并发往两个Node里写就直接定义为并发行为，用NodeId定义顺序了。

        - 4.全序广播

            - 有了Lamport时间戳，我们可以实现因果一致性了，但仍然无法实现线性化，因为我们还需要让这个全序通知到所有节点，否则可能就会无法做决策。

            - 针对唯一用户名这样的场景，假设ABC同时向系统尝试注册相同的用户名，使用Lamport时间戳的做法是，在这三个并发请求中最先提交的返回成功，其他返回失败

                - 但这里面我们因为有“上帝视角”，知道ABC，但实际请求本身在发送时不知道有其他请求存在（不同请求可能被发送到了不同的节点上）这样就需要系统做这个收集工作，这就需要有个类似协调者来不断询问各个节点是否有这样的请求，如果其中一个节点在询问过程中发生故障，那系统无法放心决定每个请求具体的RSP结果。所以最好是系统将这个顺序广播到各个节点，让各个节点真的知道这个顺序，这样可以直接做决策。

            - 对于多机：实际上实现全序广播最简单的实现方式使用主从模式的复制，让所有的操作顺序让主节点定义，然后按相同的顺序广播到各个从节点。

            - 对于分布式环境：需要处理部分失效问题，也就是如果主节点故障需要处理主成员变更。

            - 对于全序广播，书中给了两条不变式：
                - 可靠发送：需要保证消息做到all-or-nothing的发送（想想上一章）。
                - 严格有序：消息需要按完全相同的顺序发给各个节点

                - 这里所谓的全序一般指的是分区内部的全序，而如果需要跨分区的全序，需要有额外的工作

        - 实现层面：可靠发送

            - 1.消息不能丢

                - 如果某些节点出现故障后需要重试，如果需要安全的重试，那么广播操作本身失败后就不能对系统本身有副作用，否则就会导致消息发送到部分节点上的问题。

            - 2.消息不能发一部分
                - 实际上我们就是需要一个能保证顺序的数据结构，因为操作是按时间序的一个Append-only结构，恰好Log能解决这个问题
                - 这里引出了另一个常会被提到的技术，复制状态机，这个概念是我在Raft的论文中看到的，假设初始值为a，如果按照相同的顺序执行操作ABCDE最后得到的一定是相同的结果。因此可以想象，全序广播最后的实现一定会用到Log这种数据结构。

            - 书中仍然举了唯一用户名的例子：可以采用线性化的CAS操作来实现，当用户创建用户名时当且仅当old值为空。实现这样的线性化CAS，直接采用全序广播+Log的方式。

                - 1.在日志中写入一条消息，表明想要注册的用户名。
                - 2.读取日志，将其广播到所有节点并等待回复 （同步复制）。
                - 3.如果表名第一次注册的回复来自当前节点，提交这条日志，并返回成功，否则如果这条回复来自其他节点，直接向客户端返回失败。

                - 而这些日志条目会以相同的顺序广播到所有节点，如果出现并发写入，就需要所有节点做决策，是否同意，以及同意哪一个节点对这个用户名的占用。以上我们就成功实现了一个对线性CAS的写入的线性一致性。然而对于读请求，由于采用异步更新日志的机制，客户端的读取可能会读到旧值，这可能需要一些额外的工作保证读取的线性化。

                    - 1.线性化的方式获取当前最新消息的位置，即确保该位置之前的所有消息都已经读取到，然后再进行读取（ZK中的sync()）。

                    - 2.在日志中加入一条消息，收到回复时真正进行读取，这样消息在日志中的位置可以确定读取发生的时间点。

                    - 3.从保持同步更新的副本上读取数据。

### 共识

- 在实现线性化系统时，实际上就有了一点点共识的苗头了，即需要多个节点对某个提议达成一致，并且一旦达成，不能被撤销。

- 在现实中很多场景的问题都可以等价为共识问题：
    - 可线性化的CAS
    - 原子事务提交
    - 全序广播
    - 分布式锁与租约
    - 成员协调
    - 唯一性约束

    - 为以上任何一个问题找到解决方案，都相当于实现了共识。

- 两阶段提交

    - Raft之类的共识算法实际上都有两阶段提交这个类似的语义

    ![image](./Pictures/ddbs/两阶段提交.avif)

    - 两阶段：有一个用于收集信息和做决策的协调者，然后经过朴素的两个阶段

        - 协调者向参与者发送准备请求询问它们是否可以提交，如果参与者回答“是”则代表这个参与者一定会承诺提交这个消息或者事务。

        - 如果协调者收到所有参与者的区确认信息，则第二阶段提交这个事务，否则如果有任意一方回答“否”则终止事务。

    - 看似非常简单的算法，平平无奇，无外乎比正常的提交多了个准备阶段，为什么说它就可以实现原子提交呢？

        - 当启动一个分布式事务时，会向协调者请求一个事务ID。

        - 应用程序在每个参与节点上执行单节点事务，并将这个ID附加到操作上，这是读写操作都是单节点完成，如果发生问题，可以安全的终止（单节点事务保证）。

        - 当应用准备提交时，协调者向所有参与者发送Prepare，如果这是有任何一个请求发生错误或超时，都会终止事务。

        - 参与者收到请求后，将事务数据写入持久化存储，并检查是否有违规等，此时出现了第一个承诺：如果参与者向协调者发送了“是”意味着该参与者一定不会再撤回事务。

        - 当协调者收到所有参与者的回复后，根据这些恢复做决策，如果收到全部赞成票，则将“提交”这个决议写入到自己本地的持久化存储，这里会出现第二个承诺：协调者一定会提交这个事务，直到成功。

        - 假设提交过程出现异常，协调者需要不停重试，直到重试成功。

    - 局限性

        - 协调者要保存状态，因为协调者在决定提交之后需要担保一定要提交事务，因此它的决策一定需要持久化。

        - 协调者是单点，那么如果协调者发生问题，并且无法恢复，系统此时完全不知道应该提交还是要回滚，就必须交由管理员来处理。

        - 两阶段提交的准备阶段需要所有参与者都投赞成票才能继续提交，这样如果参与者过多，会导致事务失败概率很大。

- 共识算法定义
    - 1.协商一致性：所有节点都接受相同的提议。
    - 2.诚实性：所有节点一旦做出决定，不能反悔，不能对一项提议不能有两次不同的决议。
    - 3.合法性：如果决定了值v，这个v一定是从某个提议中得来的。
    - 4.可终止性：节点如果不崩溃一定能达成决议。

    - 前三个特性规定了安全性（Safety），如果没有容错的限制，直接人为指定个Strong Leader，由它来充当协调者
        - 但就像2PC中的局限性一样，协调者出问题会导致系统无法继续向后执行，因此需要有额外的机制来处理这种变更（又要依赖共识）
    - 第四个特性则决定了活性（Liveness）之前的分型中说过，安全性需要优先保证，而活性的保证需要前提。

    - 如果我们用这几个特性对比2PC，实际上却是可以认为它算是个共识算法

- 共识算法与全序广播

    - 实际在最终设计算法并落地时，并不是让每一条消息去按照上面4条特性来一次共识，而是直接采用全序广播的方式

    - 全序广播承诺消息会按相同的顺序发送给各个节点，且有且仅有一次，这就相当于在做多轮共识，每一轮，节点提出他们下面要发送的消息，然后决定下一个消息的全序。

    - 使用全序广播实现共识的好处是能提供比单轮共识更高的效率（ZAB, Raft，Multi-paxos）。

- 从实现的角度看，主从复制的模式特别适用于共识算法。但有2个问题
    - 1.主节点挂了如何确定新主
    - 2.如何防止脑裂

    - 共识算法的解决方法：在共识算法中，实际上使用到了epoch来标识逻辑时间，例如Raft中的Term，Paxos中的Balletnumber，如果在选举后，有两个节点同时声称自己是主，那么拥有更新Epoch的节点当选。

        - 同样的，在主节点做决策之前，也需要判断有没有更高Epoch的节点同时在进行决策，如果有，则代表可能发生冲突（Kafka中低版本只有Controller有这个标识，在后面的版本中，数据分区同样带上了类似的标识）。
        - 此时，节点不能仅根据自己的信息来决定任何事情，它需要收集Quorum节点中收集投票，主节点将提议发给所有节点，并等待Quorum节点的返回，并且需要确认没后更高Epoch的主节点存在时，节点才会对当前提议做投票。

        - 详细看这里面涉及两轮投票，使用Quorum又是在使用所谓的重合，如果某个提议获得通过，那么投票的节点中一定参加过最近一轮主节点的选举。这可以得出，此时主节点并没有发生变化，可以安全的给这个主节点的提议投票。

- 共识算法的代价
    - 在达成一致性决议前，节点的投票是个同步复制，这会使得共识有丢消息的风险，需要在性能和线性一直间权衡（CAP）。
    - 多数共识架设了一组固定的节点集，这意味着不能随意的动态变更成员，需要深入理解系统后才能做动态成员变更（可能有的系统就把成员变更外包了）。
    - 共识对网络极度敏感，并且一般采用超时来做故障检测，可能会由于网络的抖动导致莫名的无效选主操作，甚至会让系统进入不可用状态。

- 外包共识

    - 自己来实现共识算法，但成本可能是巨大的，最好的方式可能是将这个功能外包出去，用成熟的系统来实现共识，如果实在需要自己实现，也最好是用经过验证的算法来实现，不要自己天马行空。

    - ZK和etcd等系统就提供了这样的服务，它们不仅自己通过共识实现了线性化存储，而且还对外提供共识的语义，我们可以依托这些系统来实现各种需求：
        - 1.线性化CAS
        - 2.操作全序
        - 3.故障检测
        - 4.配置变更

## 分布式查询

- 要考虑网络传输的代价

- 查询r关系的所有元组:

    - 如果有复制, 没分片:

        - 选择传输代价最小的副本

    - 如果有复制, 有分片:

        - 需要重构关系

### 分布式连接

- r1关系在S1站点, r2关系在S2站点, r3关系在S3站点. 假设在S1站点发出连接查询

- 如果没复制, 没分片:

- 简单连接:

    - 将r2, r3发送给S1

        - 代价:S1需要重建索引, 然后进行连接

    - S1将r1, 发送给S2并与r2连接, 在发送给S3进行连接, 最后将结果发送给S1

        - 代价:可能会有重复数据, 导致额外的网络传输

- 半连接:

    - r1先在S1消除与r2连接无关的元组, 再发送给S2, 从而减少网络传输

- 并行连接:

    - S1将r1, 发送给S2并与r2连接; S3将r3, 发送给S4并与r4连接, 以此类推

## Amazon Dynamo

- [Amazon Dynamo在线论文](https://www.allthingsdistributed.com/2007/10/amazons_dynamo.html)

- PA/EL的kv数据库

- 对延迟有很高的要求

- 没有ACID的I隔离性, 只提供单key的permits更新

- 系统不知道数据的值, 不像Bigtable, PNUTS, Megastore

- 一致性级别: QR, QW, S

- 协调器(coordinator)处理get, put调用

    - put:

        - 1.生成vector clock(向量时钟)作为新版本

        - 2.将新版本发送给 N highest-ranked(排名最高)的可达到的结点

        - 3.如果响应数大于QW-1: 则写入成功

        - 注意:put调用的返回, 可能在副本存储前


    - get:

        - 1.向N highest-ranked(排名最高)的可达到的结点, 请求该key的所有版本

        - 2.在结果返回之前等待QR响应

        - 3.应用会协调(reconcile)不同的版本

## PNUTS

- [PNUTS论文pdf](https://www.cs.cmu.edu/~pavlo/courses/fall2013/static/slides/pnuts.pdf)

## Zookeeper

- [腾讯技术工程：ZooKeeper 核心通识](https://cloud.tencent.com/developer/article/2181525)

- [腾讯技术工程：从0到1详解ZooKeeper的应用场景及架构](https://zhuanlan.zhihu.com/p/513804221?utm_id=0)

- [HelloGitHub：开篇：免费开源的趣讲 ZooKeeper 教程（连载）](https://baijiahao.baidu.com/s?id=1689467683287740035&wfr=spider&for=pc)

## etcd

- [阿里云开发者：学习分享｜Etcd/Raft 原理篇](https://www.163.com/dy/article/I83NV3JB0518E0HL.html)

- [腾讯技术工程：深入解读Raft算法与etcd工程实现](https://cloud.tencent.com/developer/article/2177980)

- [SRE运维进阶之路：Etcd 概述及运维实践](https://mp.weixin.qq.com/s/QcLqbktWTeH7Xxw_FdAnAA)
