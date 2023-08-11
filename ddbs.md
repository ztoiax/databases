# DDBS(分布式数据库)

- [Distributed Systems 3rd edition (2017)](https://www.distributed-systems.net/index.php/books/ds3/)

- 半结构化存储(semi-structure storage systems): 兼顾`Consistency`(一致性)和`Availability`(可用性)

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

    - Availability(可用性)：每个请求都会收到一个(非错误)响应,但不保证它包含最新的写入

    - Partition tolerance(分区容错)：节点之间的网络丢包或延迟, 不影响系统运行

- 在网络分区存在的情况下, 没有一个分布式系统, 能确保没有网络故障

    - 在网络没有故障的情况下, 能同时满足`Consistency`和`Availability`

    - 在网络存在故障的情况下, 必须在`Consistency`和`Availability`之间做出选择(PC|PA)

        - AP: 则不能保证message是最新, 系统返回错误或超时(DNS)

        - CP: 节点如有错误, 部分数据可能会丢失

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

## 分布式并发控制

### 单一锁管理器

- 只有某个站点有锁管理器, 所有封锁, 解锁都在这个站点处理

- 1.事务给数据项需要加锁时, 向锁管理器发出请求

- 2.锁管理器决定决定是否立即授予:

    - 立即授予:返回消息给锁请求站点

    - 不立即授予:延迟等待授予为止

### 分布式锁管理器

- 每个站点一个局部锁管理器, 处理本个站点的封锁, 解锁:

    - 1.事务给数据项需要加锁时, 向该数据项的站点的锁管理器发出请求

    - 2.锁管理器决定决定是否立即授予:

        - 立即授予:返回消息给锁请求站点

        - 不立即授予:延迟等待授予为止

- 优点:

    - 提高了锁管理器的瓶颈

- 缺点:

    - 死锁处理复杂:

        ![image](./Pictures/ddbs/wait-for-graphs.avif)

        - 每个站点维护一个局部等待图(local wait-for graph)

            - 如果局部等待图存在环, 则有死锁

        - 某个站点维护一个全局等待图(global wait-for graph)

            - 如果局部等待图不存在环, 但全局等待图存在环, 则也有死锁

            - 周期性地检测局部等待图, 然后更新全局等待图

            - 发现死锁时, 选择一个牺牲者回滚后, 通知所有站点对该事务回滚

        - 假环(false cycle)

            ![image](./Pictures/ddbs/wait-for-graphs1.avif)

            - 1.S1站点, T2释放, T1占用: T1->T2

            - 2.S2站点, T2被T3占用: T2->T3

            - 3.如果S2在S1之前执行, 则可能出现T1->T2->T3假环

## 可用性

- 假设站点S1与S2不能通信, 那么可能是S2发生故障, 也可能是链路故障

- 发生故障时, 最好立即中止事务, 因为事务可能持有其他站点的锁

    - 如果站点是特殊服务器(全局死锁检测器, 并发协调器...), 那么选举新的服务器

- 解决方法:

    - 基于多数的方法(版本控制):

        - 如果数据被复制到多个站点, 事务需要获取一半以上的站点的锁, 才算成功

        - 写, 读操作需要检测所有已经加锁的副本, 并从中读取最高的版本号

    - 读一个, 写所有:

        - 任何副本都可以读取

## 一致性协议

- [awesome-consensus: 一致性算法列表](https://github.com/dgryski/awesome-consensus)

- [腾讯技术工程: 分布式之系统底层原理](https://mp.weixin.qq.com/s?sub=&__biz=MjM5ODYwMjI2MA==&mid=2649756192&idx=1&sn=b3cca59cf43b15a0f15cef97dbb26f0b&chksm=becc815b89bb084dde98d92356e7f0a67ffa7ee2f64d0104d74e5709733e3d560f161a40ab7a&scene=19&subscene=10000&clicktime=1624521004&enterid=1624521004&ascene=0&devicetype=android-30&version=2800063d&nettype=WIFI&abtest_cookie=AAACAA%3D%3D&lang=zh_CN&exportkey=Ax%2FGPgyBCBMZ%2FKC9WGPpRSs%3D&pass_ticket=YZNCdN21ca7%2BXyA%2BktOjD%2FoxrX%2F6Zuc6h0zU71gwRLYcW7tQd7hPplXykEybT2RR&wx_header=1)
### Paxos
??
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

    - leader: 与client通信, 所有对系统的更改都需要经过leader, 一个网络分区一个leader

        - 一般是协调器(coordinator), 与paxos不同的是, 在raft是一种优化

    - follower: leader外的其他结点

    - Candidate: follower选举leader时的状态

- 基于日志的协议:

    - 每个结点维护日志的副本

        - 日志副本可能存在暂时不一致的状态, 之后会恢复一致

- leader选举流程:

    - 1.一开始全是follower, 其中一些follower结点, 变为candidate

        - 如果leader故障, 并且`election timeout`超时后, follower变为candidate. `election timeout`大概在150ms - 300ms

    - 3.candidate发送投票请求给其他follower, 说投我为leader

    - 4.candidate如果收到大多数follower的响应: 则变为leader

        - 如果出现split vote(有两个candidate), 并且得票一样: 则回到第一步重新选举

    - 5.leader定期(heartbeat timeout)发送`Append Entries` 消息给follower

    - 6.follower响应并返回`Append Entries`消息

        - 如果follower超时(heartbeat timeout)收不到消息, 则leader故障了, 回到第一步重新选举. follower 强制复制 leader 的日志

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

## 异构数据库

- 在数据库上加一层软件层, 被称为多数据库系统或者中间件

- 查询:

    - 查询优化只能在局部完成

    - 数据库无法与另一个的数据库通信

    - 数据库的数据类型可能不被另一个的数据库支持, 需要类型转换

        - 通过包装器将全局模式的查询翻译成局部模式的查询, 并将结果翻译全局模式

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
