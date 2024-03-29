# kafka

## 主从模式

- 数据库所采用的的方式是通过快照+增量的方式实现。
    - 1.在某一个时间点产生一个一致性的快照。
    - 2.将快照拷贝到从节点。
    - 3.从节点连接到主节点请求所有快照点后发生的改变日志。
    - 4.获取到日志后，应用日志到自己的副本中，称之为追赶
    - 5.可能重复多轮a-d。

- 从节点失效——追赶式恢复
    - Kafka在运行过程中，会定期项磁盘文件中写入checkpoint，共包含两个文件
        - `recovery-point-offset-checkpoint`：记录已经写到磁盘的offset
        - `replication-offset-checkpoint`：用来记录高水位
            - 由ReplicaManager写入，下一次恢复时，Broker将读取两个文件的内容，可能有些被记录到本地磁盘上的日志没有提交，这时就会先截断（Truncate）到`replication-offset-checkpoint`对应的offset上，然后从这个offset开始从Leader副本拉取数据，直到认追上Leader，被加入到ISR集合中

- 主节点失效——节点切换

    - 1.确认主节点失效：大多数系统会采用超时来判定节点失效。一般都是采用节点间互发心跳的方式，如果发现某个节点在较长时间内无响应，则会认定为节点失效。

        - Kafka中，它是通过和Zookeeper（下文简称ZK）间的会话来保持心跳的，在启动时Kafka会在ZK上注册临时节点，此后会和ZK间维持会话，假设Kafka节点出现故障（这里指被动的掉线，不包含主动执行停服的操作），当会话心跳超时时，ZK上的临时节点会掉线，这时会有专门的组件（Controller）监听到这一信息，并认定节点失效。

    - 2.选举新的主节点：通过选举的方式（民主协商投票，通常使用共识算法），或由某个特定的组件指定某个节点作为新的节点（Kafka的Controller）。

        - 在选举或指定时，需要尽可能地让新主与原主的差距最小，这样会最小化数据丢失的风险（让所有节点都认可新的主节点是典型的共识问题）--这里所谓共识，就是让一个小组的节点就某一个议题达成一致，下一篇文章会重点进行介绍。

    - 3.重新配置系统是新的主节点生效

        - 这一阶段基本可以理解为对集群的元数据进行修改，让所有外界知道新主节点的存在（Kafka中Controller通过元数据广播实现），后续及时旧的节点启动，也需要确保它不能再认为自己是主节点，从而承担写请求。
