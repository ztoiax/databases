
<!-- mtoc-start -->

* [hadoop](#hadoop)
  * [HDFS](#hdfs)

<!-- mtoc-end -->

# hadoop

- 组件

    > GFS, BigTable, MapReduce是谷歌的三篇论文

    - Hbase: 可以理解为是Google BigTable 的开源版本
        > 数据模型

    - MapReduce: 可以理解为是Google MapReduce 的开源版本

        > 算法模型

    - HDFS: Google File System(GFS)的开源实现
        > 文件系统

    - ZooKeeper: Google Chubby(分布式锁)的开源实现
        > 心跳管理

## HDFS

- 结构:

    ![image](./Pictures/rdbms/hdfs.avif)

    - 一个NameNode为一个集群

    - NameNode:

        - 一个文件映射block id

        - 为每个block id映射DataNodes的副本block

    - DataNode:

        - block id映射磁盘

    - Client:

        - 从NameNode查找block的位置

        - 从DataNode访问的数据
