# RDBMS (关系性数据库)

## 基本理论

- 结构化存储(structured storage systems): 强调`Consistency`(一致性)

  - SQL语句并不区分大小写

  - 关系模型在逻辑层和视图层描述数据,不必关注数据存储的底层细节

    - 元组指 行

    - 属性指 列

    - 关系指 表

      - 关系是元组(行)的集合,但和元组的排列顺序没关

    - 关系模式:由属性(列)组成,数据库的逻辑设计

    - 关系实例:数据库的数据值

      - 关系模式不会发生变化,而关系实例会随时间变化
- 查询

  - 过程化语言

    - 以计算为操作的结果

    - 从单个关系中(id),选出满足一定条件的特殊元组(> 10)

      ```sql
      select * from cnarea_2019
      where id > 100
      ```

    - 从单个关系中,选出特定的属性(id)

      ```sql
      select id from cnarea_2019
      ```

    - 两种计算:id > 100,选出 id,name 属性

      ```sql
      select id,name from cnarea_2019
      where id > 100
      ```

    - 连接合并多个关系的元组

  - 非过程化语言

## 范式

- 完全范式化和完全反范式化在实际应用中很少用到, 实际上两者经常混用

- 范式化:

    - 优点:很少甚至没有重复数据

    - 缺点:表之间连接的代价

    - 假设有两张表:

        - 用户表, 用户发送信息的表.只有付费用户可以查询最近的10条信息

        - 则需要连接两张表, 查询用户表有哪些付费用户, 再查询用户发送信息

        - 如果付费的用户很少, 查询的效率会很低

        - 如果采用反范式化, 只有一张表, 建立索引后查询会非常高效

- 反范式化:

    - 优点:数据都在一张表, 没有连接

    - 缺点:重复数据

    - 缓存表:

        - 通过触发器更新缓存值

        - 有时需要定期重建表, 以此减少碎片

        - 由于MyISAM存储引擎有索引压缩的功能: 因此缓存表可以使用MyISAM, 从而减少磁盘空间

        - 假设需要过去24小时的数据, 可以每小时建一张缓存表

    - 物化视图:

        - mysql原生不支持物化视图, 可以使用[Flexviews第三方工具](https://github.com/greenlion/swanhart-tools)

        - 不需要查询原始数据, 因此比缓存表效率更高

## index(索引)

- 搜索码:查找记录的属性(列)或者属性集

- clustering index(聚簇索引或primary index主索引): 搜索码按指定顺序排序, 并且在同一结构下保存索引和数据行的物理位置

- no clustering index(非聚簇索引或secondary index二级索引): 搜索码**不**按顺序排序,叶结点保存的不是数据行的物理位置, 而是行指针, 因此需要2次查找:

    - 1.获取数据行在二级索引的行指针

    - 2.再从聚簇索引找数据行对应的物理位置

    - innodb使用主键值代替行指针:

        - 优点:移动行时无需更新这个指针

- 无论任何形式的索引, 面对插入和删除操作, 都需要更新

- dense index(稀疏索引): 按顺序存储部分搜索码, 因此**只有clustering index才能使用dense index**

   - 插入和删除

       - 如果是按顺序出现的第一个搜索码: 按顺序插入或删除

       - 否则: 不操作

    ![image](./Pictures/rdbms/dense_index.avif)
    ![image](./Pictures/rdbms/dense_index1.avif)

- sparse index(稠密索引): 每个搜索码都有一个索引项,每条索引项都是指针, 因此**no clustering index必须是sparse index**

    - 插入:

        - 如果没有搜索码: 找到合适的位置插入

        - 如果有相同的搜索码: 则在索引项增加指向该记录的指针

    - 删除:

        - 如果指向相同搜索码的第一条记录指针: 删除这条记录, 更新索引项指向下一条记录

    ![image](./Pictures/rdbms/sparse_index.avif)

- mulitilevel index (多级索引): 两极或以上的索引. 在很大的原始索引上构造一层dense index的外层索引

    - 10000个块的索引, 二分搜索需要14次(log2(b)), 平均每次10毫秒读取一块, 那么需要140毫秒

    - 利用多级索引: 10000个块需要10000个索引项, 也就是100个块, 大大减少磁盘IO

### B+树(平衡树)

- B树只允许搜索码出现一次

- B树有时不需要达到叶结点就能获取值

- B树的删除更加复杂, 有可能在非叶结点

- B+树胖和矮, 而二叉树高和瘦

    - 结点大小一般等同于磁盘块大小4KB

    - 假设搜索码=32B, n=100, 搜索码的值N = 100万, 一次查询只需要访问4个结点**(log[n/2] N)**

    - 平衡二叉树则是**(log2 N)**: 需要访问20个结点

- 叶结点:最多 `n-1` 个值, 最少 `(n-1)/2` 个值. 假设 n=4 叶结点最少包含2个, 最多3个值. 叶结点采用链表按顺序相连

- nonleaf node(非叶结点):最多 `n` 个指针, 最少 `n/2` 个指针. 形成对叶结点的多级稀疏索引, 不同于多索引顺序文件, 结点的指针数也叫**扇出**

- 插入和删除有可能会导致**分裂**, **合并**

    - 假设搜索码没有重复值, 最坏情况的删除复杂度是**log[n/2] N**

    - 随着树中不断的插入和删除, 会丧失IO的顺序性, 因此为了恢复顺序性需要重建索引

- 字符串索引的prefix compression(前缀压缩)技术: 非叶结点不需要存储完整的值, 只需存储前缀

    - 假设silberschatz的子树silas, silver. 只需存储前缀sil, 而不是存储silberschatz

- 对于不唯一搜索码, B+树会存储多次

### hash散列函数

> 理想的散列函数均匀的分布到所有的桶里, 使每个桶具有相同的记录

- 桶: 存储一条或多条记录, 桶大小一般等同于磁盘块

- 假设以工资为搜索码, 在1000-3000的记录的桶, 比 3000-6000的记录的桶多, 分布不均匀

- 桶溢出:

    - close addressing(闭地址): 假设3000-6000桶已经满了, 新插入的记录会添加到新桶里,以此类推. 3000-6000的桶与溢出桶使用链表连接在一起

    ![image](./Pictures/rdbms/bucket_overflows.avif)
    - open addressing(开地址): 假设3000-6000桶已经满了, 新插入的记录会添加到其它桶里. 删除操作很麻烦, 所以一般应用于只做查找, 插入的编译器符号表

- 动态散列: 通过桶的分裂, 合并适应数据库大小的变化. 性能不会随着数据库的增长而降低

- 维护一个中间层: 桶地址表

### 顺序索引与散列索引对比

- 此查询: 散列更优
```sql
SELECT A1, A2...An
FROM r
WHERE Ai = c
```

    - 顺序索引: 与关系r的Ai个数的对数成正比
    - 散列索引: 一个和数据库大小无关的常数

- 范围查询: 顺序更优
```sql
SELECT A1, A2...An
FROM r
WHERE Ai < c2 and Ai > c1
```

    - 顺序索引: 一旦找到c1就可以按顺序读取直到c2
    - 散列索引: 值是随机分布到不同的桶

### lsm(Log Structured Merge)

- lsm树

    ![image](./Pictures/rdbms/lsm.avif)

    - 先insert在内存中的L0树

    - L0树满了, 将L1树的记录与L0树合并, 再移动到L1树

        - Li -> Li+1以此类推

    - delete:标记删除的数据项, 返回时屏蔽标记的数据项, 合并时在删除数据项

    - 优点:

        - 顺序IO, 没有随机IO

        - 不修改已经存在的文件,因此不需要加锁

    - 缺点:

        - 查询可能会读取多个树

            - L0找不到就去L1找,以此类推

#### 阶梯式合并索引(Stepped Merge Index)

    ![image](./Pictures/rdbms/stepped-merge-index.avif)

    - 每层k个树

        - 一层中的k个树都满了, 就合并到下一层

    - 优点:

        - 减少写的开销

    - 缺点:

        - 查询需要读取更多的树

            - 优化:通过Bloom Filter(布隆过滤器), 快速判断数据是否在树里
    - update操作使用delete+insert

![image](./Pictures/rdbms/lsm.avif)

### Buffer Tree

![image](./Pictures/rdbms/buffer-tree.avif)

- 对B+树的优化

    - 为每个B+树结点, 都有buffer存储inserts

    - buffer满了, 就移动到低结点

### 位图索引

- 多码索引

- 位图索引很小, 大概是整个关系的1%

- 位图索引删除记录的代价很大, 一般在末尾添加新的记录

    - existence bitmap(存在位图): 通过位图中的1位, 当值为0时表示不存在

- 此查询: 计算A2, A1两个位图的交(与门), 如果有多条记录满足此条件, 则需要扫描整个关系
```sql
SELECT A1, A2...An
FROM r
WHERE A2 = c2 and A1 = c1
```

![image](./Pictures/rdbms/bigmap.avif)

## TRANSACTION (事务)

- ACID

    - Atomic(原子性): 事务是不可分割的最小单位. 要么成功, 要么失败

        - 事务T对账号A,账号B进行操作,假设故障发生在A之后,B之前.故障修复后便会出现不一致的状态, 这就需要通过日志进行回滚(恢复系统)

    - Consistent(一致性): 事务必须确保将数据库从一个有效状态更改为另一个有效状态

        - 同一个数据不能有不同的值

        - 当事务开启后每一条修改数据库的语句, 会使数据库不一致, 因此事务提交或回滚时, 必须保持数据库一致性

    - Isolation(隔离性): 多个事务并发执行时, 需要通过可串行化(并发控制), 实现相互隔离

        - 使用 `INSERT`  `UPDATE` 等语句修改同一数据时, 其中一个事务必须等待另一个事务执行完成后执行

    - Durable(持久性): 事务一旦提交, 对数据修改不会丢失

- Cascading rollback(级联回滚)

    - T10回滚; 由于T11依赖于T10,因此T11也必须回滚; 而T12依赖于T11,因此T12也必须回滚

        ![image](./Pictures/rdbms/rollback.avif)

#### 并发控制(隔离性等级的实现)

| 隔离性等级                | 内容                                                                                                                                                                 |
|---------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 可串行化(serializable)    | 保证事务调度的结果与没有并发的调度结果一致                                                                                                                           |
| 可重复读(repeatable read) | 只允许读取已提交的的数据, 而且一个事务两次读却一个数据期间, 其他事务不得更新该数据.但该事务不要求与其他事务可串行化.例如:一个事务可能查找到一个已提交事务插入的数据 |
| 已提交读(read committed) , phantom read (幻读) | 只允许读取已提交的的数据, 但不要求可重复读. |
| 未提交读(read uncommmitted)                    | 允许读却未提交的数据.隔离性最低             |
| 以上隔离性等级都不允许**脏读(dirty write)**    | 数据不能被未提交或中止的事务写入            |

- 大部分数据库默认等级为**已提交读**

##### 锁

- 共享锁(shared-mode lock):
    - 可读但不能写

- 排他锁(exclusive-mode lock):

    - 可读可写

- 相容锁与不相容锁:

    - 事务A给数据项Q加A锁后, 事务B也能给数据Q加B锁.那么A锁和B锁是**相容的**,反之则不相容

    - 不相容的锁需要等待锁的释放

    - 共享锁与共享锁相容, 与排他锁不相容

- 并发控制器:

    - 事务需要对数据项Q申请锁时, 事务会将请求发送给并发控制器, 事务只有在并发控制器授予锁后才能进行下一步操作.

    - 如果Q已经有一个A锁, 而事务申请的B锁与A锁不相容, 则并发控制器要等待A锁释放后才会授予B锁

- 死锁(deadlock):

    - 当死锁发生后必须回滚两个事务中的一个

        ![image](./Pictures/rdbms/deadlock.avif)

        - 1.T3有B的排他锁

        - 2.T4有A的共享锁, 并打算申请B的共享锁,从而等待T3释放B锁

        - 3.T3打算申请A的排他锁, 从而等待T4释放A锁

        - 4.T3等待T4, T4等待T3.两个事务互相等待对方,导致死锁

    - 死锁预防:

        - 锁超时(lock timeout):

            - 事务申请的锁等待一定时间之后, 就回滚

            - 然而很难判断应该定多长时间

        - 抢占(preempted)

            - 通过timestamp(时间戳)控制抢占

            - 假设timestamp的分配为T1:5, T2:10, T3:15. 并且事务T2, T3申请的锁, 被T1锁持有
                - wait-die(非抢占机制):T2等待, T3回滚

                - wound-wait(抢占机制):T1回滚, T2授予, T3等待

    - 死锁检测:

        ![image](./Pictures/rdbms/deadlock_detection.avif)

        - 使用等待图(wait-for graph)结构, 有环则存在死锁

        - 为了解除死锁, 需要选择一个事务进行回滚, 应遵循最小代价, 然而最小代价很难衡量

            - 彻底回滚:中止事务

            - 部分回滚:需要维护正在运行事务的额外信息, 即锁的申请,授予记录

- 饿死(starved):

    - 流程:

        - 1.事务T1在数据项Q持有共享锁, 而T2对Q申请排他锁,等待T1的释放

        - 2.同时T3, T4对Q申请共享锁,由于锁是相容的因此直接授予

        - 3.导致T2总是得不到排他锁的授予.也就是饿死

    - 解决办法:

        - 增加并发控制器授予锁的条件:一个事务的申请, 不能被其后事务的申请阻塞. 即T3不能先于T2

###### 严格两阶段封锁协议(strict two-pyhase locking protocol):

- 1.增长阶段(growing phase): 事务可以获得锁, 但不能释放锁

- 2.缩减阶段(shrink phase):  事务可以释放锁, 但不能获得新锁

- 最初,事务处于增长阶段, 获得锁; 一旦事务释放锁, 就进入缩减阶段,不能再申请锁

- 不能保证死锁

- 排他锁必须在提交后释放, 防止其他事务的读取. 从而避免级联回滚, 这也是严格两阶段封锁协议里的严格

- 锁转换:

    - 升级:共享锁转换为排他锁

    - 降级:排他锁转换为共享锁

- 锁管理器(lock manager):

    ![image](./Pictures/rdbms/protocol_two-pyhase.avif)

    - 对当前已加锁的数据项维护的一个链表

    - 5个数据项I4, I7, I23, I44, I912.采用溢出链, 即锁表的每个数据项都维护一个链表

        - 事务T23持有I912, I7的锁, 并等待I4

    - 使用数据项名称为索引的散列结构来查找链表中的数据项

    - 这个算法保证了无饿死

    - 算法流程:

        - 锁管理器收到加锁请求时: 如果对应的数据项Q的链表存在, 则在末尾添加一个记录; 否则,就新建Q的链表

        - 锁管理器收到解锁请求时: 删除对应的数据项Q链表记录, 然后检查并处理Q后面的记录

###### 图的协议

![image](./Pictures/rdbms/protocol_tree.avif)

- 只能使用排他锁

- 由于采用树形结构, 每个数据项最多加一次锁, 加锁需要持有数据项的父锁

- 优点:

    - 不会产生死锁

- 缺点:

    - 对数据项J加锁, 就需要对A, B, D, H数据项加锁.导致额外的开销, 并发度降低

###### 多粒度机制(granularity)

- 多粒度机制:

    - 当事务需要访问整个数据库, 如果需要对每个数据项都加锁, 则很费时.应该是直接对整个数据库加锁

    - 当事务需要少量数据项, 则对其数据项加锁

- 树结构: database -> area -> file -> record
    ![image](./Pictures/rdbms/protocol_granularity.avif)

- 加锁是自上而下的, 释放是自下而上的

- 当事务对Fa文件加锁时, 则会对Fa**显式**(explicit lock)加锁, 以及对其后面的结点即ra1, ra2...记录进行**隐式**(implicit lock)加锁

- 在事务对Fa结点显式加锁, 需要对该结点的所有父结点, 加上**意向锁**.这样其他事务就不必搜索整棵树, 就能判断结点有无加锁

- 意向锁的相容性

    ![image](./Pictures/rdbms/intention_lock.avif)

    - 共享意向锁(inention-shared(IS) mode):子结点只能加共享锁

    - 排他意向锁(inention-exclusive(IX) mode):子结点只能加共享锁或排他锁

    - 共享排他意向锁(shared and inention-exclusive(SIX) mode):子结点只能加排他锁

- T1, T3, T4事务为读取操作, 因此可以并发执行. T1, T2 可以并发执行, 但不能与T3并发执行

    - T1读文件Fa记录ra2, 那么需要对数据库, 区域A, Fa加IS锁. 最后给ra2加S锁

    - T2修改文件Fa记录ra9, 那么需要对数据库, 区域A, Fa加IX锁. 最后给ra9加X锁

    - T3读文件Fa所有记录, 那么需要对数据库, 区域A加IS锁. 最后给Fa加S锁

    - T4读整个数据库, 那么直接对数据库加S锁

##### 时间戳排序协议(timestamp-orderind protocol)

- timestamp(时间戳)

    - 系统时间作为timestamp

    - 逻辑计数器作为timestamp

- 为每个数据项分配一个timestamp, 维护读写两个timestamp

    - W-timestamp(Q):成功执行wirte(Q)的事务

    - R-timestamp(Q):成功执行read(Q)的事务

- 事务T发起read(Q):

    - TS(T) < W-timestamp(Q):拒绝read, 回滚T

    - TS(T) >= W-timestamp(Q):执行read

- 事务T发起write(Q):

    - TS(T) < R-timestamp(Q):拒绝write, 回滚T

    - TS(T) < W-timestamp(Q):拒绝write, 回滚T

    - 其他情况:执行write

- Thomas写规则:

    ![image](./Pictures/rdbms/thomas.avif)

    - 流程:

        - T27的read(Q)执行成功

        - T28的write(Q)执行成功

        - T27的write(Q), 由于TS(T27) < W-timestamp, 因此拒绝write, T27回滚

        - 最终导致T27的read(Q)也回滚了

    - 添加Thomas规则,让T27只拒绝write:

        - TS(T) < W-timestamp(Q):表示T已经过时了, 因此拒绝write, 但不回滚T

- 优点:

    - 不产生死锁

- 缺点:

    - 存在长事务饿死

    - 该协议是悲观的, 因为检测到冲突就会等待或回滚

##### 有效性检测协议(validation protocol)

- 该协议适合大部分事务是只读的情况

- 3个timesatmp:

    - start(T):事务T的开始时间

    - validation(T):事务T完成读阶段的时间

    - finish(T):事务T完成写阶段的时间

- 事务T根据是只读还是更新, 按2或3个阶段执行:

    - 读阶段: 数据项保存在事务T的局部变量中, write操作在局部变量进行

    - 有效性检测阶段: 以下两个条件必须满足其一. 如不满足, 则中止事务

        - finish(T2) < start(T1): T1在T2之前完成, 可串行性得到保证

        - start(T1) < finish(T2) < Validation(T1): T2的写阶段在T1的有效性检测阶段之前完成

    - 写阶段: 将事务T的写操作局部变量写入到数据库

- 优点:

    - 不存在级联回滚

- 缺点:

    - 存在长事务饿死

##### 多版本时间戳排序协议(multivesion timestamp-ordering scheme)

- 时间戳排序协议的扩展

    - Content:Qk版本的值

    - W-timestamp(Q):创建Q版本的事务

    - R-timestamp(Q):成功执行read(Q)的事务

- 事务T发起read(Q):

    - TS(T) < R-timestamp(Q): 读取Q版本的值

    - TS(T) > R-timestamp(Q): R-timestamp(Q)就会更新

- 事务T发起write(Q):

    - TS(T) < R-timestamp(Q):回滚

    - TS(T) > R-timestamp(Q):创建Q的新版本, 将W-timestamp(Q),R-timestamp(Q)初始化为TS(T)

    - TS(T) = W-timestamp(Q):写入Q

- 优点:

    - 读请求从不等待和失败

- 缺点

    - 事务冲突只能回滚, 而不是等待

##### 多版本两阶段封锁协议(multivesion two-phase locking protocol)

- 每个数据项都有一个逻辑计数器的timestamp

- 只读事务:遵循多版本时间戳排序协议

    - 读取ts-counter的值作为该事务的版本

    - 事务T发起read(Q):

        - 只读取Q版本的值

- 更新事务:

    - 更新事务T发起read(Q):

        - 对Q加上共享锁, 然后读取Q的最新版本值

    - 更新事务T发起write(Q):

        - 对Q加上排他锁, 并创建新的版本

- 优点:

    - 只读事务不必等待加锁

##### 快照隔离(Snapshot Isolation)

- 两种方法:

    - 在多版本两阶段封锁协议的基础上:

        - 对只读事务快照, 读取在快照上执行

        - 更新(读写)事务不变

        - 缺点:

            - 系统难以分辨事务是否为只读

    - 对所有事务都进行快照

        - 读取在快照上执行

        - 写入冲突时, 先提交事务赢, 后提交的事务进行回滚

- 优点:

    - 只读事务不必等待加锁

- 缺点:

    - 斜写(skew write):非可串行化

        ![image](./Pictures/rdbms/skew_write.avif)

        - 通过主键可以避免, 数据库会在快照之外检查主键冲突, 回滚其中一方

##### 谓词读(幻读 phantom)

- T1执行:
    ```sql
    select count(*) from instructor
    where dept_name = 'physics'
    ```

- T2执行:
    ```sql
    insert into instructor values
    ('11111', 'James', 'physics', 100000)
    ```
    - 或者
    ```sql
    update instructor
    set dept_name = 'physics'
    where name = 'Wu'
    ```

- T1和T2虽然没有访问共同元组, 但相互冲突

- 解决方法:

    - 1.

        - 禁止其他事务创建和更新`dept_name = 'physics'`的元组

        - 索引封锁:以B+树为例, 修改或读取必然需要访问对应的physics叶结点, 因此封锁叶节点可以避免谓词冲突

    - 2.谓词锁:对`dept_name = 'physics'`加上**谓词锁**. 如果插入,更新,删除操作满足谓词,则需要等待

        - 相比与方法1,代价很大,因此在实践中不常见

##### 索引并发

- 索引非串行并发:事务在两次索引查询期间,索引结构发生变化, 只要能返回正确的元组, 是可接受的

- 两者方法:

    - 蟹行协议(crabbing protocol):

        - 在根结点加上共享锁, 再对子结点获取共享锁, 释放父结点的锁, 反反复复直至叶结点. 如果是插入和删除就需要对叶结点加上排他锁

            - 如果B+树出现合并或分裂有可能会出现死锁, 则需要从树根重新搜索

    - B-link树:

        - 如果出现合并或分裂, 导致指针错误, 则会向该结点的右兄弟结点查找

## 日志(恢复系统)

- 更新日志记录(update log record):
    ![image](./Pictures/rdbms/log_record.avif)

    | 日志记录             | 内容                               |
    |----------------------|------------------------------------|
    | `<T0, A, 1000, 950>` | 表示数据项A的旧值是1000, 新值是950 |
    | `<T start>`          | 事务T开始                          |
    | `<T commit>`         | 事务T提交                          |
    | `<T abort>`          | 事务T中止                          |


- 系统故障后:

    - redo(T):重做事务T

        - 日志包含:`<T start>`, `<T commit>`或`<T abort>`记录时, 就会对事务T进行重做.注意:`<T abort>`也需要重做

        - 重做:将事务T更新过所有数据项的值设置成**新值**

    - undo(T):撤销事务T

        - 日志包含:`<T start>` 就会对事务T进行撤销

        - 撤销:将事务T更新过所有数据项的值设置成**旧值**

        - redo-only日志:将撤销的操作记录到特殊redo-only日志
            - 记录格式:`<T 数据项 旧值>`

    - `<checkpoint L>`:检测点记录

        - 系统崩溃后需要搜索整个日志, 因此在日志加入`<checkpoint L>`记录, 表示`<checkpoint L>`之前的记录已经写入数据库了.redo, undo只需执行之后的记录

<span id="undo-list"></span>
- undo-list(撤销列表)流程:

    - 1.从最后一个`<checkpoint L>` 记录后扫描日志

        - 2.发现`<Ti start>`记录时, 就把Ti添加到undo-list

        - 3.发现`<Ti commit>`或`<Ti abort>`记录时, 就把Ti从undo-list去掉

    - 4.扫描完后.开始撤销阶段,从尾部开始反向扫描日志进行回滚

        - 5.发现`<Tj start>`记录时, 就往日志写入`<Tj abort>`记录, 并把Tj从undo-list去掉

        - 6.一旦undo-list变为空表, 则撤销阶段结束

    - 假设系统崩溃在`<T0 abort>`

        ![image](./Pictures/rdbms/log_check.avif)

        - 1.undo-list初始发现T0, T1时, 就添加到表里

        - 2.当发现`<T1 commit>`, 把T1从表里去除

        - 3.当发现`<T2 start>`, 就添加到表里

        - 4.当发现`<T0 abort>`, 把T0从表里去除

        - 5.扫描结束, 此时表里只剩下T2. 开始撤销阶段, 从尾部开始反向

        - 6.把T2恢复为旧值也就是`<T2 A 500>`记录

        - 7.当发现`<T2 start>`, 就把`<T2 about>`记录添加到日志, 并把T2从列表去掉

        - 8.undo-list为空,撤销阶段结束

- 日志缓冲区:

    - 一条日志记录比磁盘块要小得多, 则日志在磁盘上会大的多.因此最好一次写入多条记录,在此之前写入日志缓冲区

    - WAL(先写日志):为了保证原子性, 事务T提交写入磁盘之前, 必须先将日志写入磁盘

    - 闩锁(latch):事务T写入磁盘前, 需要获取数据项对应的块的排他锁

        - 这个锁与并发控制的锁无关, 不需要两阶段的可串行化

- 模糊检查点(fuzzy checkpointing):

    - 如果`<checkpoint L>`的时间很长, 那么事务就会中断很久

    - 模糊检查点:`<checkpoint L>`记录写入日志后, 缓冲区才开始写入硬盘.写入完成后,加上`<last_checkpoint>`记录

### 逻辑日志

- 逻辑操作:操作时获取低级别锁,完成后释放. 插入和删除是这一类例子

- 逻辑日志只用于撤销,不用于重做:

    - `<T, O, operation-begin>`: 逻辑undo在修改索引的操作之前添加的日志记录

    - `<T, O, operation-end>`: 操作结束

    - `<T, O, operation-abort>`: 逻辑回滚扫描不到`<T, O, operation-end>`时, 就会减少或添加对应的值, 而不是恢复旧值, 然后添加`<T, O, operation-abort>`记录

- 逻辑回滚:

    - 例子1:

        ![image](./Pictures/rdbms/log_logical-undo.avif)

        - 1.数据项C通过添加一个值进行回滚, 对应`<T0, C, 400, 500>`记录

        - 2.数据项B是物理回滚, 对应`<T0, B, 2000>`记录

        - 3.而T1对数据项C的更新得以保留

    - 例子2:

        - 系统崩溃在`<T2, C, 400, 300>`:

        ![image](./Pictures/rdbms/log_logical-undo1.avif)

        - 1.undo-list包含T1,T2

        - 2.撤销阶段, 使用物理日志对T2的05进行撤销, 对应`<T2, C, 400>`记录,并记录到redo-only日志

        - 3.当发现`<T2 start>`, 就把`<T2 about>`记录添加到日志, 并把T2从undo-list列表去掉

        - 4.当发现`<T1, O4, operation-end, (C + 300)>`, 通过添加一个值进行逻辑undo, 对应`<T1, C, 400, 700>`记录, 然后添加`<T1, 04, operation-abort>`记录

        - 5.当发现`<T1, O4, operation-begin>`, 使用物理日志对T2的05进行撤销, 对应`<T1, B, 2050>`记录,并记录redo-only日志.并把T1从undo-list列表去掉

### ARIES: 目前最新的恢复技术

- 使用LSN(日志顺序号)标识日志记录

    - 恢复独立性:页能独立恢复

- 支持物理逻辑操作:有逻辑, 物理页

- 多日志:当一个日志达到限度, 就会拆分, 每个文件有个文件号

- ARIES数据结构:

    ![image](./Pictures/rdbms/aries_structures.avif)

    - 脏页表(dirtypage table):

        - PageLSN(页日志顺序号): 每一个更新操作, 将更新页的LSN记录到PageLSN

        - RecLSN:记录未写入磁盘的LSN

- ARIES恢复流程:

    - PrevLSN:当前日志记录中, 指向同一事务的前一条日志记录的LSN

    - checkpoint log record(检测点日志记录):包含脏页表

    - CLR(补偿日志记录):类似redo-only日志, 回滚产生的日志记录

        - UndoNextLSN:指向下一个undo的日志LSN

    - 恢复流程中的3个阶段:

        - 分析阶段:

            - 1.找到最后的`<checkpoint log record>`读取其脏页表, 将RedoLSN设置为RecLSN中的最小值

            - 2.然后正向扫描类似[undo-list](#undo-list)

        - 重做阶段:

            - 从RedoLSN开始正向扫描, 如果不在脏页表或LSN小于RecLSN, 就跳过

        - 撤销阶段:

            - 对undo-list列表进行撤销, 并设置CLR的UndoNextLSN为PrevLSN

    - 系统崩溃在LSN 7571:

        ![image](./Pictures/rdbms/aries_structures.avif)

        - 1.分析阶段从`<checkpoint log record>`的LSN开始, 也就是LSN 7568

        - 2.分析阶段完成后:RedoLSN为7564, undo-list列表包含事务T145

        - 3.重做阶段从7564开始, 由于小于`<checkpoint log record>`的7568, 因此不会将修改过的页面写入磁盘

        - 4.撤销阶段需要回滚T145, 因此从7567开始反向扫描至7563

## JOIN(关联查询): 改变表关系

- [数据库表连接的简单解释](http://www.ruanyifeng.com/blog/2019/01/table-join.html?utm_source=tuicool&utm_medium=referral)

- [图解 SQL 里的各种 JOIN](https://zhuanlan.zhihu.com/p/29234064)

- [MySQL 的 join 功能弱爆了？](https://zhuanlan.zhihu.com/p/286581170)

### 基本概念

从两个或更多的表中获取结果.[图解 SQL 里的各种 JOIN](https://zhuanlan.zhihu.com/p/29234064)

- 只返回两张表匹配的记录,这叫内连接(inner join)
- 返回匹配的记录,以及表 A 多余的记录,这叫左连接(left join)
- 返回匹配的记录,以及表 B 多余的记录,这叫右连接(right join)
- 返回匹配的记录,以及表 A 和表 B 各自的多余记录,这叫全连接(full join)

![image](./Pictures/rdbms/join.avif)

![image](./Pictures/rdbms/join1.avif)

### join的实现

Nested-Loop Join(嵌套循环连接)

- Nested-Loop Join 区分驱动表和被驱动表,先访问驱动表,筛选出结果集,然后将这个结果集作为循环的基础,访问被驱动表过滤出需要的数据

- 被驱动表(内层表)只需一次磁盘搜索

#### SNLJ(简单嵌套循环):

- 驱动表的结果集作为循环基础数据: 从结果集取出一条条数据(图中的R1, R2...)与被驱动表(图中的S1, S2)一一匹配(Sn次), 然后合并数据

- 对于表r的每一条记录, 需要对表s作完整的搜索. 代价很大

![image](./Pictures/rdbms/join_SNLJ.avif)


#### 代价分析

- 假设合并student和takes两个表

    | 行数和磁盘数    | 数量  |
    |-----------------|-------|
    | student行数     | 5000  |
    | student磁盘块数 | 100   |
    | takes行数       | 10000 |
    | takes磁盘块数   | 400   |

    - Nr: r表的行数
    - Ns: s表的行数
    - Br: r表的磁盘块数
    - Bs: s表的磁盘块数

- 最好的情况: 内存能容纳两个表

    - (Br + Bs)块的传输次数 + 两次磁盘搜索

    - `students磁盘块 + takes磁盘块 + 两次磁盘搜索` = `100 + 400 + 两次磁盘搜索`

- 最坏的情况: 内存只能容纳一个数据块

    - (Nr * Bs + Br)块的传输次数 + (Nr + Br)磁盘搜索次数

    - 假设student是外层循环, takes是内层循环:

        - `students行数 * takes磁盘块 + students行数 + students磁盘块` = `5000 * 400 + 5000 + 100`

    - 假设takes是外层循环, student是内层循环:

        - `10000 * 100 + 10000 + 400`

    - 两者对比: 假设块传输0.1毫秒, 磁盘搜索4毫秒

        - student为外层:2000100块传输 + 5100磁盘搜索

            - 200010 + 20400 = 220410

        - takes为外层:1000400块传输 + 10400磁盘搜索

            - 块的传输少了, 但磁盘搜索多了

            - 100040 + 41600 = 141640

        - takes虽然记录和块更多, 但作为外层更优

#### block nested-loop(块嵌套循环):

- MySQL

    - 加入了join buffer: 缓存 join 需要的字段, 降低了循环的次数,也就是被驱动表的扫描次数

    - MySQL 默认 buffer 大小 256K,如果有 n 个 join 操作,会生成 n-1 个 join buffer

![image](./Pictures/rdbms/join_BNLJ.avif)

#### 代价分析

- 内层表的每一块与外层表的每一块形成一对

    - 块中的行与另一个块中的行形成行对

- 最好的情况: 和简单循环一样 `100 + 400 + 两次磁盘搜索`

- 最坏的情况: 内外层表的每一块都只需读取一次

    - (Br * Bs + Br)块传输 + (2br)磁盘搜索

    - 100 * 400 + 100 + 2 * 100

    - 40100次块传输 + 200次磁盘搜索

    - 对比简单嵌套: 假设块传输0.1毫秒, 磁盘搜索4毫秒

        - 4010 + 800 = 4810毫秒

        - 比简单嵌套优

#### INLJ(索引嵌套循环):

- 一般行数少的作驱动表(外层表)

![image](./Pictures/rdbms/join_INLJ.avif)

#### 代价分析

- 最坏的情况: 内存只能容纳一个数据块

    - 假设student是外层循环, takes是内层循环:

       - (Hs + 1): 假设每个结点为20个索引, takes有10000行, 那么高度为4, 存储数据还需要一次磁盘访问, 因此是(4 + 1)

       - Br + Nr * (Hs + 1) = 100 + 5000 * 5

       - 25100次磁盘搜索和块传输

    - 对比简单嵌套和块嵌套: 假设块传输0.1毫秒, 磁盘搜索4毫秒

        - 2510 + 100400 = 102910

        - 比简单嵌套优, 但比块嵌套差

            - 除非student表上的某一列行数显著减少, 那么可以比块嵌套更优

#### merge join(归并连接)

- 先排序, 再为每个表分配一个指向第一行的指针, 指针会遍历整个表

![image](./Pictures/rdbms/join_merge.avif)

#### 代价分析

- 最好的情况已排序, 并且分配Bb(缓存块). 1Bb大小为1.6M = 400块:

    - (Br + Bs)块传输 + ([Br / Bb] + [Bs / Bb])磁盘搜索

    - 100 + 400 + 2

- 最坏的情况没有排序, 内存只能容纳3块

    - takes表:

        - 400 * (2 * [log3-1 (400 / 3)] + 1) = 6800次块传输

        - 400 * (2 * (400 / 3) + 400 * (2 * 8 -1)) + 400 = 6668次磁盘搜索

    - students表:

        - 100 * (2 * [log3-1 (100 / 3)] + 1) = 1300次块传输

        - 100 * (2 * (100 / 3) + 100 * (2 * 8 -1)) + 100 = 1264次磁盘搜索

    - 一共9100次块传输, 8932次磁盘搜索

- 假设分配1个Bb(缓存块)

    - 一共1640次磁盘搜索

- 假设分配5个Bb(缓存块)

    - 一共2500次块传输, 251次磁盘搜索

- 混合归并:
    - 假设1个表已排序, 另一个表没有排序, 但连接列有B+树的辅助索引

    - 可以把已排序的表与使用B+树辅助索引进行归并

#### hash join(散列连接)

- 表r与表s的连接条件必然会有**相同的值**

    - 假设相同的值为i, 则比较ri, si的散列值

![image](./Pictures/rdbms/join_hash.avif)

## HTAP(Hybrid transaction/analytical processing) 混合事务 / 分析处理

- [What is HTAP?](https://en.pingcap.com/blog/how-we-build-an-htap-database-that-simplifies-your-data-platform)

- OLTP(Online Transactional Processing) 在线事务处理

    - 强调快速查询, 更可能是**行数据库**, 每次修改不超过几行, 以事务/s衡量效率
    - 一般用于交易服务, 如mysql

- OLAP(Online Analytical Processing) 在线分析处理

    - 强调响应时间, 更可能是**列数据库**, 事务较少, 查询复杂通常涉及aggregating(聚合)历史数据

    - 一般用于数据挖掘, 如hadoop

- OLTP数据库保存数据, 并定期提取数据; 再使用OLAP数据库进行分析, 导出报告或者写回OLTP数据库

    - 这一过程复杂漫长, 延迟高

- 而HTAP数据库便是兼容两者, 不需要在一个数据库里执行事务, 另一个数据库里分析

    ![image](./Pictures/database_concept/htap.avif)

### 列存储

![image](./Pictures/rdbms/column.avif)

- 优点:

    - 读取性能更高:

        - 例子:查询过去1年的price(价格)

            - 行存储需要读取过去1年的所有行, 然后聚合price字段

            - 列存储只需读取price字段

    - 压缩性能更高:

        - 相识的数据存储在一起, 压缩性能更高

- 缺点:

    - 更新性能低

        - 更新一行, 需要更新每一列

