# mysql

## 安装 MySql

### Centos 7 安装 MySQL

- 从 CentOS 7 开始,`yum` 安装 `MySQL` 默认安装的会是 `MariaDB`

- 安装mariadb
    ```sh
    # 不要用yum命令安装。如果使用yum install -y mysql安装，是没有systemd 的unit的
    systemctl start mariadb
    Failed to start mariadb.service: Unit not found.

    # 使用dnf命令安装
    dnf install mariadb-server
    ```

- 安装mysql8
    - 整个过程需要科学上网

    ```sh
    # 下载
    wget https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm

    # 安装源
    rpm -Uvh mysql80-community-release-el7-3.noarch.rpm

    # 查看安装是否成功
    yum repolist enabled | grep "mysql.*-community.*"

    # 查看当前MySQL Yum Repository中所有MySQL版本(每个版本在不同的子仓库中)
    yum repolist all | grep mysql

    # 切换版本
    yum-config-manager --disable mysql80-community
    yum-config-manager --enable mysql57-community

    # 安装
    yum install mysql-community-server
    ```

- /etc/mysql/my.cnf
    ```sh
    [mysqld]
    # 允许MySQL监听所有网络接口
    bind-address = 0.0.0.0
    ```

<span id="docker"></span>

### [docker 安装](https://www.runoob.com/docker/docker-install-mysql.html)

```sh
# 下载镜像
docker pull mysql:latest

# 查看本地镜像
docker images

# -p端口映射
docker run -itd --name mysql-tz -p 3306:3306 -e MYSQL_ROOT_PASSWORD=YouPassword mysql

# 查看运行镜像
docker ps

#进入容器
docker exec -it mysql-tz bash

#登录 mysql
mysql -uroot -pYouPassword -h 127.0.0.1 -P3306
```

## 主从复制 (Master Slave Replication )

- 原理
    - master提交完事务后，写入binlog
    - slave连接到master，获取binlog
    - master创建dump线程，推送binglog到slave
    - slave启动一个IO线程读取同步过来的master的binlog，记录到relay log中继日志中
    - slave再开启一个sql线程读取relay log事件并在slave执行，完成同步
    - slave记录自己的binglog

    ![image](./Pictures/mysql/主从复制原理.avif)

- mysql默认的复制方式是异步的：主库把日志发送给从库后不关心从库是否已经处理，这样会产生一个问题就是假设主库挂了，从库处理失败了，这时候从库升为主库后，日志就丢失了。

- 全同步复制：主库写入binlog后强制同步日志到从库，所有的从库都执行完成后才返回给客户端，但是很显然这个方式的话性能会受到严重影响。

- 半同步复制：和全同步不同的是，半同步复制的逻辑是这样，从库写入日志成功后返回ACK确认给主库，主库收到至少一个从库的确认就认为写操作完成。

### 主从复制不会复制已经存在的数据库数据。因此需要自己导入

- 在master服务器上：导出主从复制设置的数据库

    ```sh
    # 导出

    # 进入数据库后给数据库加上一把锁,阻止对数据库进行任何的写操作
    flush tables with read lock;

    # 导出tz数据库
    mysqldump -uroot -pYouPassward tz > /root/tz.sql

    # 对数据库解锁,恢复对主数据库的操作
    unlock tables;
    ```

    ```sh
    # 复制主服务器的tz.sql备份文件
    scp -r "root@192.168.100.208:/root/tz.sql" /tmp/
    # 创建tz数据库
    mysql -uroot -p
    ```

- 在slave服务器上：恢复 tz 数据库

    ```sql
    # 先创建 tz 数据库
    create database tz;

    # 导入
    mysql -uroot -p tz < /tmp/tz.sql

    # 如果出现以下核对错误
    ERROR 1273 (HY000) at line 47: Unknown collation: 'utf8mb4_0900_ai_ci'
    # 通过修改编码修复
    sed -i 's/utf8mb4_0900_ai_ci/utf8mb4_unicode_ci/g' /tmp/tz.sql
    # 再次运行
    mysql -uroot -p tz < /tmp/tz.sql
    ```

### 主服务器配置

- `/etc/my.cnf` 文件配置

    ```sh
    [mysqld]
    server-id=129            # 默认是 1 ,这个数字必须是唯一的
    log_bin=centos7

    binlog-do-db=tz          # 同步指定库tz
    binlog-ignore-db=tzblock # 忽略指定库tzblock

    # 设置 binlog_format 格式为row（默认）。如果是STATEMENT使用 uuid()函数主从数据会不一致
    binlog_format=row

    # 设置一个 binlog 文件的最大字节。设置最大 100MB
    max_binlog_size=100M

    # 设置了 binlog 文件的有效期（单位：天）
    expire_logs_days = 7

    # 默认值为0，最不安全。只写入到文件系统缓存（page cache），由系统自行判断什么时候执行fsync磁盘，因此会丢失数据
    # 最安全的值为1。但这也是最慢的。每次都fsync到磁盘
    # 执行n 次事务提交后，才fsync到磁盘
    sync_binlog=1
    ```

- 设置远程登陆的权限
    ```sql
    # 启用slave权限
    grant PRIVILEGES SLAVE on *.* to  'root'@'%';
    # 或者启用所有权限
    grant all on *.* to  'root'@'%';

    # 刷新权限
    FLUSH PRIVILEGES;
    ```

- 重启mariadb
    ```sh
    systemctl restart mariadb
    ```

- 查看主服务状态

    ```sql
    # 日志目录 /var/lib/mysql/centos7.000001

    mysql> show master status;
    ERROR 2006 (HY000): MySQL server has gone away
    No connection. Trying to reconnect...
    Connection id:    7
    Current database: tz

    +----------------+----------+--------------+------------------+-------------------+
    | File           | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
    +----------------+----------+--------------+------------------+-------------------+
    | centos7.000001 |      156 |              |                  |                   |
    +----------------+----------+--------------+------------------+-------------------+
    1 row in set (0.02 sec)
    ```

### 从服务器配置

- `/etc/my.cnf` 文件配置

    ```sh
    [mysqld]
    server-id=128

    replicate-do-db = tz     #只同步tz库
    slave-skip-errors = all   #忽略因复制出现的所有错误
    ```

- 进入slave服务器后，配置master服务器
    ```sql
    -- 关闭同步
    stop slave;

    # 开启同步功能
    CHANGE MASTER TO
    MASTER_HOST = '192.168.100.208',
    MASTER_USER = 'root',
    MASTER_PASSWORD = 'YouPassword',
    -- 在master上执行show master status;查看MASTER_LOG_FILE、MASTER_LOG_POS
    MASTER_LOG_FILE='centos7.000001',
    MASTER_LOG_POS=156;

    -- 开启同步
    start slave;
    ```

- 查看是否成功
    ```sql
    MariaDB [tz]> show slave status\G;
    *************************** 1. row ***************************
                    Slave_IO_State: Connecting to master
                       Master_Host: 192.168.100.208
                       Master_User: root
                       Master_Port: 3306
                     Connect_Retry: 60
                   Master_Log_File: centos7.000001
               Read_Master_Log_Pos: 6501
                    Relay_Log_File: tz-pc-relay-bin.000001
                     Relay_Log_Pos: 4
             Relay_Master_Log_File: centos7.000001
                  Slave_IO_Running: Connecting
                 Slave_SQL_Running: Yes
    ```

### docker 主从复制

[docker 安装 mysql 教程](#docker)

启动两个 mysql:

```sh
docker run -itd --name mysql-tz -p 3306:3306 -e MYSQL_ROOT_PASSWORD=YouPassword mysql

docker run -itd --name mysql-slave -p 3307:3306 -e MYSQL_ROOT_PASSWORD=YouPassword mysql
```

进入 docker 修改 `my.cnf` 配置文件

```sh
docker exec -it mysql-tz /bin/bash
echo "server-id=1" >> /etc/mysql/my.cnf
echo "log-bin=bin.log" >> /etc/mysql/my.cnf
echo "bind-address=0.0.0.0" >> /etc/mysql/my.cnf

docker exec -it mysql-slave /bin/bash
echo "server-id=2" >> /etc/mysql/my.cnf
echo "log-bin=bin.log" >> /etc/mysql/my.cnf

退出docker后,重启mysql
docker container restart mysql-slave
docker container restart mysql-tz
```

进入 master(主服务器) 创建 backup 用户,并添加权限:

```sql
mysql -uroot -pYouPassword -h 127.0.0.1 -P3306

create user 'backup'@'%' identified by 'YouPassword';
GRANT replication slave ON *.* TO 'backup'@'%';
FLUSH PRIVILEGES;
```

查看 master 的 ip:

```sh
sudo docker exec -it mysql-tz cat '/etc/hosts'
```

我这里为 `172.17.0.2`

![image](./Pictures/mysql/docker-replication.avif)

开启 **slave**:

```sql
# MASTER_HOST 填刚才查询的ip

mysql -uroot -pYouPassword -h 127.0.0.1 -P3307
CHANGE MASTER TO
MASTER_HOST = '172.17.0.2',
MASTER_USER = 'backup',
MASTER_PASSWORD = 'YouPassword';
start slave;
```

docker 主从复制测试:

- 左为 3307 从服务器
- 右为 3306 主服务器

在主服务器**新建数据库 tz,hello 表**,并插入 1 条数据.可以看到从服务器可以 select hello 表;在主服务器删除 tz 数据库,从服务器也跟着删除.

![image](./Pictures/mysql/docker-replication.gif)

## 日志

| 日志类型   | 日志说明                               |
|------------|----------------------------------------|
| 错误日志   | Mysql本身的错误日志                    |
| 查询日志   | 查询语句日志                           |
| 慢查询日志 | 慢查询语句，查询耗时续配署             |
| 事务日志   | 记录事物执行过程，用于故障恢复         |
| binlog二进制日志 | 记录所有语句执行记录，用于数据同步等   |
| 中继日志   | 线程读取别人的二进制日志存到本地的日志 |

![image](./Pictures/mysql/logs.avif)

### 普通日志

- 默认情况下，MYSQL 中不启用日志文件。所有错误都会显示在 `syslog (/var/log/syslog)` 中。

| 日志类型          | 记录内容                                                       |
|-------------------|----------------------------------------------------------------|
| error log         | 它包含有关服务器运行时发生的错误的信息(也包括服务器启动和停止) |
| general query log | 记录(连接、断开连接、查询)                                     |
| Slow Query log    | 慢查询日志                                                     |

- 查看日志大小, 保存路径

```sql
show variables like '%log%file%';
```

修改`/etc/mysql/my.cnf` 配置文件下启用日志

- 开启 error log:

    ```sh
    [mysqld_safe]
    log_error=/var/log/mysql/mysql_error.log

    [mysqld]
    log_error=/var/log/mysql/mysql_error.log
    ```

- 开启 general query log:

    ```sh
    general_log_file = /var/log/mysql/mysql_general.log
    general_log = 1
    ```

- 开启 Slow Query log:

    ```sh
    slow_query_log_file = /var/log/mysql/mysql_slow.log
    slow_query_log = 1

    # 超过两秒, 可以设置0秒捕捉所有查询
    long_query_time = 2
    log-queries-not-using_indexes
    ```

    ```sh
    # 创建文件
    mkdir /var/log/mysql

    touch /var/log/mysql/mysql_error.log
    touch /var/log/mysql/mysql_general.log
    touch /var/log/mysql/mysql_slow.log

    # 授予权限
    chown mysql:mysql /var/log/mysql/mysql_error.log
    chown mysql:mysql /var/log/mysql/mysql_general.log
    chown mysql:mysql /var/log/mysql/mysql_slow.log

    # 重启 mysql
    systemctl restart mysqld
    ```

- 在运行时启用日志:

    ```sh
    SET GLOBAL general_log = 'ON';
    SET GLOBAL slow_query_log = 'ON';
    ```

### binlog (二进制日志)

MySQL 8.0 中的二进制日志格式与以前的 MySQL 版本不同

- binlog是逻辑日志，记录内容是语句的原始逻辑，类似于“给 ID=2 这一行的 c 字段加 1”，属于MySQL Server层。

    - 不管用什么存储引擎，只要发生了表数据更新，都会产生binlog日志。

    - 只记录对数据库更改的所有操作，不包括 `select`，`show` 等这类操作不修改数据的语句

- redo log它是物理日志，记录内容是“在某个数据页上做了什么修改”，属于InnoDB存储引擎。

    ![image](./Pictures/mysql/binlog_and_redolog.avif)

- binlog的作用：MySQL数据库的数据备份、主备、主主、主从都离不开binlog，需要依靠binlog来同步数据，保证数据一致性。
    ![image](./Pictures/mysql/binlog作用.avif)

- 启用了binlog的服务器会使性能稍微降低

- 写入机制：

    - 事务执行过程中，先把日志写到binlog cache，事务提交的时候，再把binlog cache写到binlog文件中。

    - 因为一个事务的binlog不能被拆开，无论这个事务多大，也要确保一次性写入，所以系统会给每个线程分配一个块内存作为binlog cache

    - 我们可以通过binlog_cache_size参数控制单个线程 binlog cache 大小，如果存储内容超过了这个参数，就要暂存到磁盘（Swap）。

        ![image](./Pictures/mysql/binlog写入机制.avif)

        - 上图的 `write`，是指把日志写入到文件系统的 page cache，并没有把数据持久化到磁盘，所以速度比较快

        - 上图的 `fsync`，才是将数据持久化到磁盘的操作

        - 由参数`sync_binlog`控制，默认是0。
            - 为0的时候，表示每次提交事务都只write，由系统自行判断什么时候执行fsync。
            - 为了安全起见，可以设置为1，表示每次提交事务都会执行fsync，就如同binlog 日志刷盘流程一样。

- binlog日志有3种格式，可以通过`binlog_format`参数指定。

    - statement：记录的内容是SQL语句原文`update T set update_time=now() where id=1`
        ![image](./Pictures/mysql/binlog-statement.avif)

        - 问题：同步数据时，会执行记录的SQL语句，update_time=now()这里会获取当前系统时间，直接执行会导致与原库的数据不一致。

        - 解决方法：我们需要指定为row：

    - row（通常会设置此值）：记录的内容不再是简单的SQL语句了，还包含操作的具体数据
        - 记录的内容看不到详细信息，要通过mysqlbinlog工具解析出来。
        ![image](./Pictures/mysql/binlog-row.avif)

        - update_time=now()变成了具体的时间update_time=1627112756247，条件后面的@1、@2、@3 都是该行数据第 1 个~3 个字段的原始值（假设这张表只有 3 个字段）。

            - 缺点：需要更大的容量来记录，比较占用空间，恢复与同步时会更消耗IO资源，影响执行速度。

    - mixed：前两者的混合。判断这条SQL语句是否可能引起数据不一致，如果是，就用row格式，否则就用statement格式。

#### 配置

开启 `binary` 日志:

```ini
[mysqld]
datadir = /var/lib/mysql/

##### binlog #####
# 可以通过show master status;查看
log-bin=arch
log-bin-index=arch.index

# 主从复制要设置的复制的数据库
# binlog-do-db=test          # 同步指定库tz
# binlog-ignore-db=tzblock   # 忽略指定库tzblock

# 设置 binlog_format 格式为row（默认）。如果是STATEMENT使用 uuid()函数主从数据会不一致
binlog_format=row

# 设置一个 binlog 文件的最大字节。设置最大 100MB
max_binlog_size=100M

# 设置了 binlog 文件的有效期（单位：天）
expire_logs_days = 7

# 默认值为0，最不安全。只写入到文件系统缓存（page cache），由系统自行判断什么时候执行fsync磁盘，因此会丢失数据
# 最安全的值为1。但这也是最慢的。每次都fsync到磁盘
# 执行n 次事务提交后，才fsync到磁盘
sync_binlog=1
```

![image](./Pictures/mysql/binlog.avif)

```sql
# 我这里是 row 格式
show variables like 'binlog_format';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| binlog_format | ROW   |
+---------------+-------+
```

随着时间的推移日志文件会越来越多，可以设置日志有效期，自动清理

```sql
# 我这里是 0 (表示永不会清理)
show variables like 'expire_logs_days';
+------------------+-------+
| Variable_name    | Value |
+------------------+-------+
| expire_logs_days | 0     |
+------------------+-------+
```

#### 基本命令
```sql
# 查看二进制日志
show binary logs;

# 创建新的二进制文件
flush logs;

# 查看第一个日志(缺点:没有时间显示)
show binlog events;

# 查看指定日志
show binlog events in 'LogName';

# 删除所有二进制日志
reset master;

# 删除日志centos7.000022前的日志
pugre master logs to 'centos7.000022';

# 删除某一天前的日志
pugre master logs before '2020-10-25 00:00:00'

# 删除10天前的日志
pugre master logs before current_date - interval 1 day;
```

#### mysqlbinlog 日志分析

```sh
mysqlbinlog /var/lib/mysql/bin.000001
```

##### [--flashback 还原被添加、删除、修改的数据](https://mariadb.com/kb/en/flashback/)

日志格式必须设置为:

- binlog_format=ROW
- binlog_row_image=FULL

创建测试表,并插入数据:

```sql
drop table if exists test;

CREATE TABLE test(
    id int (8),
    name varchar(50),
    date DATE
);

insert into test (id,name,date) values
(1,'tz1','2020-10-24'),
(10,'tz2','2020-10-24'),
(100,'tz3','2020-10-24');

commit;
```

有两种闪回还原的方法:

- 通过 `pos` 还原:

```sql
# 记下日志名 和 pos 等下还原需要:

# 查看日志名,我这里为(bin.000016)
show master status;
+------------+----------+--------------+------------------+
| File       | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+------------+----------+--------------+------------------+
| bin.000016 |     9074 |              |                  |
+------------+----------+--------------+------------------+

# 查看日志,找到删除修改数据前提交的pos(如下图:我这里是7144)
show binlog events in 'bin.000016'\G;
```

![image](./Pictures/mysql/mysqlbinlog.avif)

- 通过 `start-datetime` 还原:

```sql
# 记下删除修改数据前最后一次的时间

# 查看时间
select current_timestamp();
+---------------------+
| current_timestamp() |
+---------------------+
| 2020-11-19 16:50:19 |
+---------------------+
```

- 先删除,修改,添加数据。方便后面还原

```sql
delete from test
where id = 1;

update test
set id = 20
where id = 10;

insert into test (id,name,date) values
(1000,'tz4','2020-10-24');

commit;

select * from test;
```

通过 `--start-position` 进行还原:

```sh
mysqlbinlog /var/lib/mysql/bin.000016 -vv -d china -T test \
   --start-position="7144" --flashback > /tmp/flashback.sql

sudo mysql -uroot -p china < /tmp/flashback.sql
```

![image](./Pictures/mysql/mysqlbinlog.gif)

通过 `--start-datetime` 进行还原:

```sh
mysqlbinlog /var/lib/mysql/bin.000016 -vv -d china -T test \
   --start-datetime="2020-11-19 16:50:19" --flashback > /tmp/flashback.sql

sudo mysql -uroot -p china < /tmp/flashback.sql
```

![image](./Pictures/mysql/mysqlbinlog1.gif)

#### [canal](https://github.com/alibaba/canal)

- canal 模拟 slave 的方式，获取 binlog 日志数据. binlog 设置为 row 模式以后，不仅能获取到执行的每一个增删改的脚本，同时还能获取到修改前和修改后的数据.

- 支持高性能,实时数据同步

- 支持 docker

[canal 安装](https://github.com/alibaba/canal/wiki/QuickStart) 目前不支持 jdk 高版本

[canal 运维工具安装](https://github.com/alibaba/canal/wiki/Canal-Admin-QuickStart)

### redo log (重做日志)

- redo log是InnoDB存储引擎独有的

    - 先将事务的变更写入redo log，并且保证redo log持久化到磁盘上，才能认为事务提交成功。这样即使在数据库发生故障时，也能够根据redo log来恢复未写入数据文件的数据，确保已经提交的事务不会丢失。

- 为什么不直接把修改后的数据页刷盘，还有redo log什么事？

    - 问题：
        - 数据页大小是16KB，刷盘比较耗时，可能就修改了数据页里的几Byte数据，有必要把完整的数据页刷盘吗？
        - 而且数据页刷盘是随机写，因为一个数据页对应的位置可能在硬盘文件的随机位置，所以性能是很差。

    - 如果是写redo log，一行记录可能就占几十Byte，只包含表空间号、数据页号、磁盘文件偏移 量、更新值，再加上是顺序写，所以刷盘速度很快。

- 写入机制：

    ![image](./Pictures/mysql/redo-log.avif)

    - MySQL中数据是以页为单位，你查询一条记录，会从硬盘把一页的数据加载出来，加载出来的数据叫数据页，会放入到Buffer Pool中。
    - 后续的查询都是先从Buffer Pool中找，没有命中再去硬盘加载，减少硬盘IO开销，提升性能。
    - 更新表数据的时候，也是如此，发现Buffer Pool里存在要更新的数据，就直接在Buffer Pool里更新。
    - 然后会把“在某个数据页上做了什么修改”记录到重做日志缓存（redo log buffer）里，接着刷盘到redo log文件里。

        - 每条 redo 记录由“表空间号+数据页号+偏移量+修改数据长度+具体修改的数据”组成

        - 理想情况，事务一提交就会进行刷盘操作，但实际上，刷盘的时机是根据策略来进行的。

        - InnoDB存储引擎有一个后台线程，每隔1秒，就会把redo log buffer中的内容写到文件系统缓存（page cache），然后调用fsync刷盘。

            - 一个没有提交事务的redo log记录，也可能会后台线程刷盘。

            ![image](./Pictures/mysql/redo-log后台线程刷盘.avif)

        - 另外，redo log的刷盘策略提供了`innodb_flush_log_at_trx_commit`参数，它支持三种策略：

            - `0`:表示每次事务提交时不进行刷盘操作
                - 为0时，如果MySQL挂了或宕机可能会有1秒数据的丢失。
                ![image](./Pictures/mysql/redo-log刷盘策略值为0.avif)

            - `1`（默认值）:表示每次事务提交时都将进行刷盘操作
                - 为1时， 只要事务提交成功，redo log记录就一定在硬盘里，不会有任何数据丢失。
                - 如果事务执行期间MySQL挂了或宕机，这部分日志丢了，但是事务并没有提交，所以日志丢了也不会有损失。
                ![image](./Pictures/mysql/redo-log刷盘策略值为1.avif)

            - `2`:表示每次事务提交时都只把 redo log buffer 内容写入 page cache
                - 为2时， 只要事务提交成功，redo log buffer中的内容只写入文件系统缓存（page cache）。
                - 如果仅仅只是MySQL挂了不会有任何数据丢失，但是宕机可能会有1秒数据的丢失。
                ![image](./Pictures/mysql/redo-log刷盘策略值为2.avif)

            ```sql
            show variables like 'innodb_flush_log_at_trx_commit'
            +--------------------------------+-------+
            | Variable_name                  | Value |
            +--------------------------------+-------+
            | innodb_flush_log_at_trx_commit | 1     |
            +--------------------------------+-------+
            ```

- 日志文件组

    - 硬盘上存储的redo log日志文件不只一个，而是以一个日志文件组的形式出现的，每个的redo日志文件大小都是一样的。

        - redo log 以 **块(block)** 为单位进行存储的,每个块的大小为 **512** Bytes
        - redo log 文件的组合大小 = (`innodb_log_file_size` \* `innodb_log_files_in_group`)
        - 例子：可以配置为一组4个文件，每个文件的大小是1GB，整个redo log日志文件组可以记录4G的内容。

        ```sql
        # redo log文件大小
        show variables like 'innodb_log_file_size';
        +----------------------+-----------+
        | Variable_name        | Value     |
        +----------------------+-----------+
        | innodb_log_file_size | 100663296 |
        +----------------------+-----------+

        # redo log文件数量
        show variables like 'innodb_log_files_in_group';
        +---------------------------+-------+
        | Variable_name             | Value |
        +---------------------------+-------+
        | innodb_log_files_in_group | 1     |
        ```

    - 日志文件组采用的是环形数组形式，从头开始写，写到末尾又回到头循环写

        ![image](./Pictures/mysql/redo-log日志文件组.avif)

        - 有两个重要的属性
            - write pos是当前记录的位置，一边写一边后移
            - checkpoint（刷脏）是当前要擦除的位置，也是往后推移

        - 每次刷盘redo log记录到日志文件组中，write pos位置就会后移更新。
        - 每次MySQL加载日志文件组恢复数据时，会清空加载过的redo log记录，并把checkpoint后移更新。
        - write pos和checkpoint之间的还空着的部分可以用来写入新的redo log记录。
            ![image](./Pictures/mysql/redo-log日志文件组1.avif)

        - 如果write pos追上checkpoint，表示日志文件组满了，这时候不能再写入新的redo log记录，MySQL得停下来，清空一些记录，把checkpoint推进一下。
            ![image](./Pictures/mysql/redo-log日志文件组2.avif)

### binlog和redo log

- binlog是逻辑日志，记录内容是语句的原始逻辑，类似于“给 ID=2 这一行的 c 字段加 1”，属于MySQL Server层。

    - 不管用什么存储引擎，只要发生了表数据更新，都会产生binlog日志。

    - 只记录对数据库更改的所有操作，不包括 `select`，`show` 等这类操作不修改数据的语句

- redo log它是物理日志，记录内容是“在某个数据页上做了什么修改”，属于InnoDB存储引擎。

    ![image](./Pictures/mysql/binlog_and_redolog.avif)

- 虽然它们都属于持久化的保证，但是则重点不同。

    - 在执行更新语句过程，会记录redo log与binlog两块日志，以基本的事务为单位，redo log在事务执行过程中可以不断写入，而binlog只有在提交事务时才写入，所以redo log与binlog的写入时机不一样。

    ![image](./Pictures/mysql/binlog_and_redolog1.avif)

- redo log与binlog两份日志之间的逻辑不一致，会出现什么问题？

    - 假设执行过程中写完redo log日志后，binlog日志写期间发生了异常，会出现什么情况呢？

        ![image](./Pictures/mysql/binlog_and_redolog2.avif)
        ![image](./Pictures/mysql/binlog_and_redolog3.avif)

    - 解决方法：两阶段提交——将redo log的写入拆成了两个步骤prepare和commit，这就是两阶段提交。
        ![image](./Pictures/mysql/binlog_and_redolog4.avif)

        - 使用两阶段提交后，写入binlog时发生异常也不会有影响，因为MySQL根据redo log日志恢复数据时，发现redo log还处于prepare阶段，并且没有对应binlog日志，就会回滚该事务。
        ![image](./Pictures/mysql/binlog_and_redolog5.avif)

### undo log回滚日志）

- 保证事务的原子性（ACID的A）：要么全部成功，要么全部失败，不可能出现部分成功的情况。

- undo log 逻辑日志：
    - 事务未提交的时候,所有事务进行的修改都会先先记录到这个回滚日志中，并持久化到磁盘上。
    - 系统崩溃时，没 COMMIT 的事务 ，就需要借助 undo log 来进行回滚至事务开始前的状态。
    - 保存在`ibdata*`

## 性能优化

- 如果无法测量就无法优化, 测量需要分析大量的数据, 大多数系统无法完整的测量, 而且测量的结果也可能是错误的

- 判断是服务器问题还是查询问题:

    - 如果是每一条查询都变慢, 则可能是服务器问题

    - 如果是只有某条查询变慢, 则可能是查询问题

### profile 记录查询响应时间

```sql
# 开启profile
set profile = 1

# 查看所有查询的响应时间
show profiles

# 查看上一次查询每个步骤的响应时间
show profile
```

### 记录计数器

```sh
# 查看线程状态, 如果注意是否有大量的freeing item
mysql -e 'show processlist\G' | grep -i "state:" | sort | uniq -c | sort -rn
```

### [pt-query-digest(percona-toolkit)](https://www.percona.com/doc/percona-toolkit/LATEST/pt-query-digest.html)

```sh
pt-query-digest /var/log/mysql/mysql_slow.log
```

### mysqldumpslow

```sh
# 取出使用最多的10条慢查询
mysqldumpslow -s c -t 10 /var/log/mysql/mysql_slow.log

# 取出查询时间最慢的3条慢查询
mysqldumpslow -s t -t 3 /var/log/mysql/mysql_slow.log

# 得到按照时间排序的前10条里面含有左连接的查询语句
mysqldumpslow -s t -t 10 -g “left join” /var/log/mysql/mysql_slow.log

# 按照扫描行数最多的
mysqldumpslow -s r -t 10 -g 'left join' /var/log/mysqld/mysql_slow.log
```

### [mysqlsla](https://github.com/daniel-nichter/hackmysql.com/tree/master/mysqlsla)

mysqlsla 来自于 hackmysql.com，此网站的软件 2015 就不再维护了

```sh
# Usege

mysqlsla --log-type slow /var/log/mysql/mysql_slow.log
mysqlsla --log-type general /var/log/mysql/mysql_general.log
mysqlsla --log-type error /var/log/mysql/mysql_error.log
```

### informantion_schema数据库

- row_format(行格式)是 `redundant` ,存储在 `ibdata1`, `ibdata2` 文件

- 记录 `innodb` 核心的对象信息,比如表、索引、字段等

```sql
# 查看innoddb字典
use information_schema;
show tables like '%INNODB_SYS%';
+------------------------------+
| Tables_in_information_schema |
+------------------------------+
| INNODB_SYS_DATAFILES         |
| INNODB_SYS_TABLESTATS        |
| INNODB_SYS_FIELDS            |
| INNODB_SYS_FOREIGN_COLS      |
| INNODB_SYS_FOREIGN           |
| INNODB_SYS_TABLES            |
| INNODB_SYS_COLUMNS           |
| INNODB_SYS_TABLESPACES       |
| INNODB_SYS_VIRTUAL           |
| INNODB_SYS_INDEXES           |
| INNODB_SYS_SEMAPHORE_WAITS   |
+------------------------------+
```

- 查看使用 innodb 存储的表:

    ```sql
    select * from INNODB_SYS_TABLES;
    ```

    ![image](./Pictures/mysql/dictionary3.avif)

**InnoDB Buffer Pool** 储数据和索引,减少磁盘 I/O,是一种特殊的 mitpoint LRU 算法
[查看 INNODB_BUFFER 表](https://mariadb.com/kb/en/information-schema-innodb_buffer_pool_stats-table/)

```sql
select * from INNODB_BUFFER
# 或者 隔几秒就会有变化
show global status like '%buffer%';

# innodb 页是16k

# 一共 8057页
POOL_SIZE: 8057

# 空闲页
FREE_BUFFERS: 6024

# 已使用页
DATABASE_PAGES: 2033
```

![image](./Pictures/mysql/dictionary5.avif)

**innodb_buffer_pool_size** 越大,初始化时间就越长

```sql
show variables like 'innodb%buffer%';
```

![image](./Pictures/mysql/dictionary6.avif)

### performance_schema数据库

- [knowclub：使用performance schema来更加容易的监控MySQL](https://mp.weixin.qq.com/s?__biz=Mzk0OTI3MDg5MA==&mid=2247486646&idx=1&sn=82c4cb4bc32a44c6751f8f9241ddf9e0&chksm=c35bacb3f42c25a50c9f0e1fc1c1307cbe5fd0550e1e1c3909b4704a8aeb3120ea57cea3fa8c&scene=178&cur_album_id=2555489356258705411#rd)

- performance_schema通过监视server的事件来实现监视server内部运行情况

    - “事件”就是server内部活动中所做的任何事情以及对应的时间消耗，利用这些信息来判断server中的相关资源消耗在了哪里？可以是函数调用、操作系统的等待、SQL语句执行的阶段（如sql语句执行过程中的parsing 或 sorting阶段）或者整个SQL语句与SQL语句集合。

    - 事件的采集可以方便的提供server中的相关存储引擎对磁盘文件、表I/O、表锁等资源的同步调用信息。

- performance_schema的表中的数据不会持久化存储在磁盘中，而是保存在内存中，一旦服务器重启，这些数据会丢失（包括配置表在内的整个performance_schema下的所有数据）


- 使用性能模式诊断问题

    - 以下示例提供了一种可用于分析可重复问题的方法，例如调查性能瓶颈。首先，您应该有一个可重复的用例，其中性能被认为“太慢”并且需要优化，并且您应该启用所有检测（根本没有预过滤）。

    - 1.使用性能模式表，分析性能问题的根本原因。此分析在很大程度上依赖于后过滤。

    - 2.对于排除的问题区域，禁用相应的工具。例如，如果分析表明问题与特定存储引擎中的文件 I/O 无关，则禁用该引擎的文件 I/O 工具。然后截断历史和摘要表以删除以前收集的事件。

    - 3.重复步骤 1 中的过程。

        - 在每次迭代中，Performance Schema 输出，尤其是 events_waits_history_long表格，包含越来越少的由无关紧要的仪器引起的“噪音”，并且鉴于该表格具有固定大小，包含越来越多与手头问题分析相关的数据。

        - 在每次迭代中，随着“信噪比”的提高 ，调查应该越来越接近问题的根本原因 ，从而使分析更加容易。

    - 4.一旦确定了性能瓶颈的根本原因，就采取适当的纠正措施，例如：

        - 调整服务器参数（缓存大小、内存等）。
        - 通过不同的方式编写查询来调整查询，
        - 调整数据库架构（表、索引等）。
        - 调整代码（这仅适用于存储引擎或服务器开发人员）。

    - 5.从第 1 步重新开始，查看更改对性能的影响。

- 对于调查性能瓶颈或死锁极为重要`mutex_instances.LOCKED_BY_THREAD_ID`。 `rwlock_instances.WRITE_LOCKED_BY_THREAD_ID`这是通过 Performance Schema 检测实现的，如下所示：

    - 1.假设线程 1 在等待互斥锁时卡住了。

    - 2.您可以确定线程正在等待什么：
        ```sql
        SELECT * FROM performance_schema.events_waits_current
        WHERE THREAD_ID = thread_1;
        ```

        - 假设查询结果标识线程正在等待在 中找到的互斥量 events_waits_current.OBJECT_INSTANCE_BEGINA。

    - 3.您可以确定哪个线程持有互斥量 A：
        ```sql
        SELECT * FROM performance_schema.mutex_instances
        WHERE OBJECT_INSTANCE_BEGIN = mutex_A;
        ```

        - 假设查询结果标识它是持有互斥量 A 的线程 2，如中所见 mutex_instances.LOCKED_BY_THREAD_ID。

    - 4.你可以看到线程 2 在做什么：
        ```sql
        SELECT * FROM performance_schema.events_waits_current
        WHERE THREAD_ID = thread_2;
        ```

- performance_schema数据库开启

    - `/etc/my.cnf`配置文件，开启performance_schema
    ```
    [mysqld]
    performance_schema=ON
    ```

    ```sql
    // 在mysql的5.7版本中默认开启。我是MariaDB默认关闭
    SHOW VARIABLES LIKE 'performance_schema';
    +--------------------+-------+
    | Variable_name | Value |
    +--------------------+-------+
    | performance_schema | ON    |
    +--------------------+-------+

    // 切换数据库
    use performance_schema;

    // 查看表
    show tables;

    // 查看表结构
    show create table setup_consumers;
    ```

- performance_schema表的分类

    ```sql
    //语句事件记录表，这些表记录了语句事件信息，当前语句事件表events_statements_current、历史语句事件表events_statements_history和长语句历史事件表events_statements_history_long、以及聚合后的摘要表summary，其中，summary表还可以根据帐号(account)，主机(host)，程序(program)，线程(thread)，用户(user)和全局(global)再进行细分)
    show tables like '%statement%';

    //等待事件记录表，与语句事件类型的相关记录表类似：
    show tables like '%wait%';

    //阶段事件记录表，记录语句执行的阶段事件的表
    show tables like '%stage%';

    //事务事件记录表，记录事务相关的事件的表
    show tables like '%transaction%';

    //监控文件系统层调用的表
    show tables like '%file%';

    //监视内存使用的表
    show tables like '%memory%';

    //动态对performance_schema进行配置的配置表
    show tables like '%setup%';
    ```

- 2个概念：
    - instruments: 生产者，用于采集mysql中各种各样的操作产生的事件信息，对应配置表中的配置项我们可以称为监控采集配置项。
    - consumers:消费者，对应的消费者表用于存储来自instruments采集的数据，对应配置表中的配置项我们可以称为消费存储配置项。
    ```sql
    //默认不会收集所有的事件，可能你需要检测的事件并没有打开，需要进行设置，可以使用如下两个语句打开对应的instruments和consumers（行计数可能会因MySQL版本而异)。

    //打开等待事件的采集器配置项开关，需要修改setup_instruments配置表中对应的采集器配置项
    UPDATE setup_instruments SET ENABLED = 'YES', TIMED = 'YES'where name like 'wait%';

    //打开等待事件的保存表配置开关，修改setup_consumers配置表中对应的配置项
    UPDATE setup_consumers SET ENABLED = 'YES'where name like '%wait%';

    //当配置完成之后可以查看当前server正在做什么，可以通过查询events_waits_current表来得知，该表中每个线程只包含一行数据，用于显示每个线程的最新监视事件
    select * from events_waits_current\G
    *************************** 1. row ***************************
                THREAD_ID: 11
                 EVENT_ID: 570
             END_EVENT_ID: 570
               EVENT_NAME: wait/synch/mutex/innodb/buf_dblwr_mutex
                   SOURCE:
              TIMER_START: 4508505105239280
                TIMER_END: 4508505105270160
               TIMER_WAIT: 30880
                    SPINS: NULL
            OBJECT_SCHEMA: NULL
              OBJECT_NAME: NULL
               INDEX_NAME: NULL
              OBJECT_TYPE: NULL
    OBJECT_INSTANCE_BEGIN: 67918392
         NESTING_EVENT_ID: NULL
       NESTING_EVENT_TYPE: NULL
                OPERATION: lock
          NUMBER_OF_BYTES: NULL
                    FLAGS: NULL
    /*该信息表示线程id为11的线程正在等待buf_dblwr_mutex锁，等待事件为30880
    属性说明：
     id:事件来自哪个线程，事件编号是多少
     event_name:表示检测到的具体的内容
     source:表示这个检测代码在哪个源文件中以及行号
     timer_start:表示该事件的开始时间
     timer_end:表示该事件的结束时间
     timer_wait:表示该事件总的花费时间
    注意：_current表中每个线程只保留一条记录，一旦线程完成工作，该表中不会再记录该线程的事件信息
    */
    ```

- 一些表
    ```sql
    //_history表中记录每个线程应该执行完成的事件信息，但每个线程的事件信息只会记录10条，再多就会被覆盖，*_history_long表中记录所有线程的事件信息，但总记录数量是10000，超过就会被覆盖掉
    select thread_id,event_id,event_name,timer_wait from events_waits_history order by thread_id limit 21;

    // summary表提供所有事件的汇总信息，该组中的表以不同的方式汇总事件数据（如：按用户，按主机，按线程等等）。例如：要查看哪些instruments占用最多的时间，可以通过对events_waits_summary_global_by_event_name表的COUNT_STAR或SUM_TIMER_WAIT列进行查询（这两列是对事件的记录数执行COUNT（*）、事件记录的TIMER_WAIT列执行SUM（TIMER_WAIT）统计而来）
    SELECT EVENT_NAME,COUNT_STAR FROM events_waits_summary_global_by_event_name  ORDER BY COUNT_STAR DESC LIMIT 10;


    //instance表记录了哪些类型的对象会被检测。这些对象在被server使用时，在该表中将会产生一条事件记录，例如，file_instances表列出了文件I/O操作及其关联文件名
    select * from file_instances limit 20;
    ```

- 重要配置表
    ```sql
    /*
    performance_timers表中记录了server中有哪些可用的事件计时器
    字段解释：
     timer_name:表示可用计时器名称，CYCLE是基于CPU周期计数器的定时器
     timer_frequency:表示每秒钟对应的计时器单位的数量,CYCLE计时器的换算值与CPU的频率相关、
     timer_resolution:计时器精度值，表示在每个计时器被调用时额外增加的值
     timer_overhead:表示在使用定时器获取事件时开销的最小周期值
    */
    select * from performance_timers;

    /*
    setup_timers表中记录当前使用的事件计时器信息
    字段解释：
     name:计时器类型，对应某个事件类别
     timer_name:计时器类型名称
    */
    select * from setup_timers;

    /*
    setup_consumers表中列出了consumers可配置列表项
    字段解释：
     NAME：consumers配置名称
     ENABLED：consumers是否启用，有效值为YES或NO，此列可以使用UPDATE语句修改。
    */
    select * from setup_consumers;

    /*
    setup_instruments 表列出了instruments 列表配置项，即代表了哪些事件支持被收集：
    字段解释：
     NAME：instruments名称，instruments名称可能具有多个部分并形成层次结构
     ENABLED：instrumetns是否启用，有效值为YES或NO，此列可以使用UPDATE语句修改。如果设置为NO，则这个instruments不会被执行，不会产生任何的事件信息
     TIMED：instruments是否收集时间信息，有效值为YES或NO，此列可以使用UPDATE语句修改，如果设置为NO，则这个instruments不会收集时间信息
    */
    SELECT * FROM setup_instruments;

    /*
    setup_actors表的初始内容是匹配任何用户和主机，因此对于所有前台线程，默认情况下启用监视和历史事件收集功能
    字段解释：
     HOST：与grant语句类似的主机名，一个具体的字符串名字，或使用“％”表示“任何主机”
     USER：一个具体的字符串名称，或使用“％”表示“任何用户”
     ROLE：当前未使用，MySQL 8.0中才启用角色功能
     ENABLED：是否启用与HOST，USER，ROLE匹配的前台线程的监控功能，有效值为：YES或NO
     HISTORY：是否启用与HOST， USER，ROLE匹配的前台线程的历史事件记录功能，有效值为：YES或NO
    */
    SELECT * FROM setup_actors;

    /*
    setup_objects表控制performance_schema是否监视特定对象。默认情况下，此表的最大行数为100行。
    字段解释：
     OBJECT_TYPE：instruments类型，有效值为：“EVENT”（事件调度器事件）、“FUNCTION”（存储函数）、“PROCEDURE”（存储过程）、“TABLE”（基表）、“TRIGGER”（触发器），TABLE对象类型的配置会影响表I/O事件（wait/io/table/sql/handler instrument）和表锁事件（wait/lock/table/sql/handler instrument）的收集
     OBJECT_SCHEMA：某个监视类型对象涵盖的数据库名称，一个字符串名称，或“％”(表示“任何数据库”)
     OBJECT_NAME：某个监视类型对象涵盖的表名，一个字符串名称，或“％”(表示“任何数据库内的对象”)
     ENABLED：是否开启对某个类型对象的监视功能，有效值为：YES或NO。此列可以修改
     TIMED：是否开启对某个类型对象的时间收集功能，有效值为：YES或NO，此列可以修改
    */
    SELECT * FROM setup_objects;

    /*
    threads表对于每个server线程生成一行包含线程相关的信息，
    字段解释：
     THREAD_ID：线程的唯一标识符（ID）
     NAME：与server中的线程检测代码相关联的名称(注意，这里不是instruments名称)
     TYPE：线程类型，有效值为：FOREGROUND、BACKGROUND。分别表示前台线程和后台线程
     PROCESSLIST_ID：对应INFORMATION_SCHEMA.PROCESSLIST表中的ID列。
     PROCESSLIST_USER：与前台线程相关联的用户名，对于后台线程为NULL。
     PROCESSLIST_HOST：与前台线程关联的客户端的主机名，对于后台线程为NULL。
     PROCESSLIST_DB：线程的默认数据库，如果没有，则为NULL。
     PROCESSLIST_COMMAND：对于前台线程，该值代表着当前客户端正在执行的command类型，如果是sleep则表示当前会话处于空闲状态
     PROCESSLIST_TIME：当前线程已处于当前线程状态的持续时间（秒）
     PROCESSLIST_STATE：表示线程正在做什么事情。
     PROCESSLIST_INFO：线程正在执行的语句，如果没有执行任何语句，则为NULL。
     PARENT_THREAD_ID：如果这个线程是一个子线程（由另一个线程生成），那么该字段显示其父线程ID
     ROLE：暂未使用
     INSTRUMENTED：线程执行的事件是否被检测。有效值：YES、NO 
     HISTORY：是否记录线程的历史事件。有效值：YES、NO * 
     THREAD_OS_ID：由操作系统层定义的线程或任务标识符（ID）：
    */
    select * from threads
    ```

- performance_schema实践操作
    ```sql
    //1、哪类的SQL执行最多？
    SELECT DIGEST_TEXT,COUNT_STAR,FIRST_SEEN,LAST_SEEN FROM events_statements_summary_by_digest ORDER BY COUNT_STAR DESC
    //2、哪类SQL的平均响应时间最多？
    SELECT DIGEST_TEXT,AVG_TIMER_WAIT FROM events_statements_summary_by_digest ORDER BY COUNT_STAR DESC
    //3、哪类SQL排序记录数最多？
    SELECT DIGEST_TEXT,SUM_SORT_ROWS FROM events_statements_summary_by_digest ORDER BY COUNT_STAR DESC
    //4、哪类SQL扫描记录数最多？
    SELECT DIGEST_TEXT,SUM_ROWS_EXAMINED FROM events_statements_summary_by_digest ORDER BY COUNT_STAR DESC
    //5、哪类SQL使用临时表最多？
    SELECT DIGEST_TEXT,SUM_CREATED_TMP_TABLES,SUM_CREATED_TMP_DISK_TABLES FROM events_statements_summary_by_digest ORDER BY COUNT_STAR DESC
    //6、哪类SQL返回结果集最多？
    SELECT DIGEST_TEXT,SUM_ROWS_SENT FROM events_statements_summary_by_digest ORDER BY COUNT_STAR DESC
    //7、哪个表物理IO最多？
    SELECT file_name,event_name,SUM_NUMBER_OF_BYTES_READ,SUM_NUMBER_OF_BYTES_WRITE FROM file_summary_by_instance ORDER BY SUM_NUMBER_OF_BYTES_READ + SUM_NUMBER_OF_BYTES_WRITE DESC
    //8、哪个表逻辑IO最多？
    SELECT object_name,COUNT_READ,COUNT_WRITE,COUNT_FETCH,SUM_TIMER_WAIT FROM table_io_waits_summary_by_table ORDER BY sum_timer_wait DESC
    //9、哪个索引访问最多？
    SELECT OBJECT_NAME,INDEX_NAME,COUNT_FETCH,COUNT_INSERT,COUNT_UPDATE,COUNT_DELETE FROM table_io_waits_summary_by_index_usage ORDER BY SUM_TIMER_WAIT DESC
    //10、哪个索引从来没有用过？
    SELECT OBJECT_SCHEMA,OBJECT_NAME,INDEX_NAME FROM table_io_waits_summary_by_index_usage WHERE INDEX_NAME IS NOT NULL AND COUNT_STAR = 0 AND OBJECT_SCHEMA <> 'mysql' ORDER BY OBJECT_SCHEMA,OBJECT_NAME;
    //11、哪个等待事件消耗时间最多？
    SELECT EVENT_NAME,COUNT_STAR,SUM_TIMER_WAIT,AVG_TIMER_WAIT FROM events_waits_summary_global_by_event_name WHERE event_name != 'idle' ORDER BY SUM_TIMER_WAIT DESC
    //12-1、剖析某条SQL的执行情况，包括statement信息，stege信息，wait信息
    SELECT EVENT_ID,sql_text FROM events_statements_history WHERE sql_text LIKE '%count(*)%';
    //12-2、查看每个阶段的时间消耗
    SELECT event_id,EVENT_NAME,SOURCE,TIMER_END - TIMER_START FROM events_stages_history_long WHERE NESTING_EVENT_ID = 1553;
    //12-3、查看每个阶段的锁等待情况
    SELECT event_id,event_name,source,timer_wait,object_name,index_name,operation,nesting_event_id FROM events_waits_history_longWHERE nesting_event_id = 1553;
    ```

## Storage Engine (存储引擎)

- [『浅入浅出』MySQL 和 InnoDB](https://draveness.me/mysql-innodb/)

- mysql的存储引擎架构是分离的, 类似插件式的架构

修改默认存储引擎 `engine`:

> ```sh
> [mysqld]
> default_storage_engine=INNODB
> ```

- MyIsam: 速度更快,因为 MyISAM 内部维护了一个计数器,可以直接调取,使用 b+树索引

  > 表锁(对表的锁)
  >
  > 不支持事务
  >
  > 缓冲池只缓存索引文件,不缓冲数据文件
  >
  > 由 MYD 和 MYI 文件组成,MYD 用来存放数据文件,MYI 用来存放索引文件

- InnoDB: 事务更好,使用 b+树索引

  > 行锁(对行的锁),表锁(对表的锁)
  >
  > 支持事务
  >
  > 自动灾难恢复

```sql
# 查看支持的存储引擎
show engines;

# 查看目前使用的存储引擎
show variables like 'storage_engine';

# 查看 cnarea_2019表 的存储引擎
show create table cnarea_2019\G;

# 修改ca表的存储引擎为MYISAM
ALTER TABLE cnarea_2019 ENGINE = MYISAM;
```

### 表空间

- [爱可生开源社区：第10期：选择合适的表空间](https://mp.weixin.qq.com/s/D-pc8yYD9AJVkk8t9_mXzA)

- MySQL 表空间可分为
    - 共享表空间
        - 系统表空间
        - 通用表空间
    - 单表空间


- 三种表空间如何销毁：
    - 系统表空间无法销毁，除非把里面的内容全部剥离出来；
    - 单表空间如果表被删掉了，表空间也就自动销毁；或者是表被移植到其他表空间，单表空间也自动销毁。
    - 通用表空间需要引用他的表全部删掉或者移植到其他表空间，才可以被成功删除。
        ```sql
        # 删除表空间 ts2 失败
        mysql> drop tablespace ts2;
        ERROR 3120 (HY000): Tablespace `ts2` is not empty.
        mysql> show errors;
        +-------+------+--------------------------------+
        | Level | Code | Message |
        +-------+------+--------------------------------+
        | Error | 3120 | Tablespace `ts2` is not empty. |
        +-------+------+--------------------------------+
        1 row in set (0.00 sec)

        # 查看数据字典表来进一步查看表空间 ts2 被哪些表引用了

        mysql> select regexp_replace(a.name,'/.+','') dbname,regexp_replace(a.name,'.+/','') tablename from innodb_tables a, innodb_tablespaces b where a.space = b.space and b.name= 'ts2';
        +--------+-----------+
        | dbname | tablename |
        +--------+-----------+
        | ytt | t4 |
        +--------+-----------+
        1 row in set (0.00 sec)

        # 删除对应的表或者转到其他的表空间。
        mysql> alter table t4 tablespace innodb_file_per_table;
        Query OK, 0 rows affected (0.10 sec)
        Records: 0 Duplicates: 0 Warnings: 0

        # 删除表空间 ts2。
        mysql> drop tablespace ts2;
        Query OK, 0 rows affected (0.02 sec)
        ```

#### 系统表空间：mysql目录下的ibdata1的文件，可以保存一张或者多张表。

- 有些啥内容？double writer buffer、 change buffer、数据字典（MySQL 8.0 之前）、表数据、表索引。

- my.cnf配置文件修改：默认为 1 个，可以有多个
    ```
    innodb_data_file_path=ibdata1:200M;ibdata2:200M:autoextend:max:800M

    # 系统表空间不仅可以是文件系统组成的文件，也可以是非文件系统组成的磁盘块，比如裸设备，定义也很简单
    innodb_data_file_path=/dev/nvme0n1p1:3Gnewraw;/dev/nvme0n1p2:2Gnewraw
    ```

- 那 MySQL 为什么现在主流版本默认都不是系统表空间？

    - 系统表空间有三个最大的缺点：

    - 1.即使它包含的表都被删掉，这部分空间也不会自动释放。

        ```sql
        # 表 t1
        mysql> create table t1(id int, r1 char(36)) tablespace innodb_system;
        Query OK, 0 rows affected (0.03 sec)

        # ibdata1 初始大小为 12M
        mysql> \! ls -sihl ibdata1
        923275 12M -rw-r----- 1 mysql mysql 12M 3月  18 15:32 ibdata1

        # ... 插入一部分数据
        # ...
        mysql> select count(*) from t1;
        +----------+
        | count(*) |
        +----------+
        |   262144 |
        +----------+
        1 row in set (0.10 sec)

        # ibdata1 增长到 76M
        mysql> \! ls -sihl ibdata1
        923275 76M -rw-r----- 1 mysql mysql 76M 3月  18 15:34 ibdata1

        # 删除这张表
        mysql> drop table t1;
        Query OK, 0 rows affected (0.02 sec)

        # 空间并没有释放
        mysql> \! ls -sihl ibdata1
        923275 76M -rw-r----- 1 mysql mysql 76M 3月  18 15:39 ibdata1
        ```

    - 如何才能释放 ibdata1 呢?这个比较麻烦，而且严重影响服务可用性，大致几个步骤：
        - 1. 用 mysqldump 导出所有表数据；
        - 2. 关闭 MySQL 服务；
        - 3. 设置 ibdata1 为默认大小；
        - 4. source 重新导入数据。

    - 2：扩容时，单表分离速度慢。

        - 系统表空间在无限制增大导致磁盘满需要扩容时，无法快速的把表从系统表空间里分离出来，必须得经过停服务；改配置；扩容；重新导入数据；启服务等步骤方才可行。

    - 3：多张表的数据写入顺序写。

        - 对多张表的写入数据依然是顺序写，这就致使 MySQL 发布了单表空间来解决这两个问题。

#### 单表空间：innodb的ibd文件

- 单表空间不同于系统表空间，每个表空间和表是一一对应的关系，每张表都有自己的表空间。具体在磁盘上表现为后缀为 .ibd 的文件。

- 单表空间除了解决之前说的系统表空间的几个缺点外，还有其他的优点
    - 1.truncate table 操作比其他的任何表空间都快；
    - 2.可以把不同的表按照使用场景指定在不同的磁盘目录；
        ```sql
        // 比如日志表放在慢点的磁盘，把需要经常随机读的表放在 SSD 上等。
        mysql> create table ytt_dedicated (id int) data directory = '/var/lib/mysql-files';
        ```

    - 3.可以用 optimize table 来收缩或者重建经常增删改查的表。

        - `optimize table`命令过程：建立和原来表一样的表结构和数据文件，把真实数据复制到临时文件，再删掉原始表定义和数据文件，最后把临时文件的名字改为和原始表一样的。

        ```
        # 表 t1 optimize table之前的大小 324M
        ls -sihl
        总用量 325M
        934068 4.0K -rw-r----- 1 mysql mysql   67 3月   6 23:01 db.opt
        917593  12K -rw-r----- 1 mysql mysql 8.5K 3月  18 16:35 t1.frm
        918181 325M -rw-r----- 1 mysql mysql 324M 3月  18 16:38 t1.ibd

        # 重建表
        mysql> optimize table t1;

        # 重建期间抓取到的结果：如愿以偿看到 # 开头的临时表定义和数据文件。
        ls -sihl
        总用量 409M
        934068 4.0K -rw-r----- 1 mysql mysql 67 3月 6 23:01 db.opt
        917100 12K -rw-r----- 1 mysql mysql 8.5K 3月 18 16:38 '#sql-1791_7.frm'
        917107 85M -rw-r----- 1 mysql mysql 84M 3月 18 16:39 '#sql-ib51-975102565.ibd'
        917593 12K -rw-r----- 1 mysql mysql 8.5K 3月 18 16:35 t1.frm
        918181 325M -rw-r----- 1 mysql mysql 324M 3月 18 16:38 t1.ibd

        # 重建完成，表 t1 实际占用空间 84M
        ls -sihl
        总用量 85M
        934068 4.0K -rw-r----- 1 mysql mysql   67 3月   6 23:01 db.opt
        917100  12K -rw-r----- 1 mysql mysql 8.5K 3月  18 16:38 t1.frm
        917107  85M -rw-r----- 1 mysql mysql  84M 3月  18 16:39 t1.ibd
        ```

    - 4.可以自由移植单表
        - 并不需要移植整个数据库，可以把单独的表在各个实例之间灵活移植。
        - 例子：把 ytt.t1 的数据移植到 ytt2.t1 里。
        ```sql
        create database ytt2;
        use ytt2
        create table t1 like ytt.t1;

        // 进行表数据移植。
        alter table t1 discard tablespace;

        root@ytt-pc:/data/ytt/mysql/data/ytt# cp -rfp /tmp/t1.ibd ../ytt2/

        alter table t1 import tablespace;

        // 确认下数据是否一致。
        select (select count(*) from ytt.t1) 'ytt.t1',(select count(*) from ytt2.t1) 'ytt2.t1';
        +---------+---------+
        | ytt.t1 | ytt2.t1 |
        +---------+---------+
        | 2097152 | 2097152 |
        +---------+---------+
        1 row in set (1.69 sec)
        ```

    - 5.单表空间的表可以使用 MySQL 的新特性：比如表压缩，大对象更优化的磁盘存储等。
    - 6.可以更好的管理和监控单个表的状态：比如在 OS 层可以看到表的大小。
    - 7.可以解除 InnoDB 系统表空间的大小限制：InnoDB 一个表空间最大支持 64TB 数据（针对 16KB 的页大小）。如果是系统表空间，整个实例都被这个限制，单表空间则是针对单个表有 64TB 大小限制。

- 单表空间的缺点
    - 1.当多张表被大量的增删改后，表空间会有一定的膨胀
    - 2.相比系统表空间，打开表需要的文件描述符增多，浪费更多的内存。

##### ibd文件内部

- ibd文件：

    - segment (包括段)
    - extent (区)
    - page (页)

    ![image](./Pictures/mysql/innodb3.avif)


    - 这个数据文件被划分成很多的数据页（页号来标识），每个数据页大小是16K。
        ![image](./Pictures/mysql/innodb-ibd.avif)

    - ibd文件内部结构
        ![image](./Pictures/mysql/innodb-ibd1.avif)

    - 数据页需要读写，写入到一半的过程中可能会发生了意外断电等情况，所以为了保证数据页的准确性，还引入了校验码；
    - 同时为了在数据页搜索数据提高效率，数据页内部还生成了页目录；
    - 除了上述所说的，数据页内剩下的空间就用来存放实际的数据；

- 数据页和数据页之间是以B+树的形式进行关联

    ![image](./Pictures/mysql/innodb-ibd2.avif)

    - 叶子节点的数据页存放的是实际存储的数据，非叶子节点存放的是索引内容。

    - B+树的每一层代表一次磁盘 IO。
        - 例子：寻找 ID=5 的记录，从顶部非叶子节点开始查找，由于 ID=5 大于1并且小于7，故应该往左边寻找，来到页号为6的数据页，由于5大于4，故应该往右边寻找，来到页号为105的数据页，找到 ID=5 的记录，完成查询。这个过程中查询了三个数据页，如果这三个数据页都没有加载到内存，那么就需要经历三次磁盘 IO 查询。

    - MySQL 一棵 B+ 树可以存放多少行数据？

        - 假设：
            - 非叶子节点内指向其他数据页的指针数量为 X（即非叶子节点的最大子节点数为 X）
            - 每个叶子节点可以存储的行记录数为 Y
            - B+树的高度为 N（即  B+树的层数）

        - 公式：

            - 对于一个高度为 N 的 B+树，顶层（根节点）有一个非叶子节点，那么第二层就有X个节点，第三层就有 X 的2次方个节点，第四层就有 X 的三次方个节点，以此类推，第 N 层（即叶子节点所在的第 N 层）就有 X 的 N-1 次方个节点；
            - 在 B+ 树中，所有的记录都存储在叶子节点中，假设每个叶子节点都可以存储的行记录数为 Y；
            - 那么 B+ 树可以存储的数据总量为叶子节点总数乘以每个叶子节点存储的记录数
                - 即：M=（X 的 N-1 次方）乘以 Y；

        - 代入计算：

            - 一个数据页大小16K，扣除页号、前后指针、页目录，校验码等信息，实际可以存储数据的大约为15K，假设主键ID为bigint型，那么主键 ID 占用8个 byte，页号占用4个 byte，则 X=15*1024/(8 + 4) 等于1280；
            - 一个数据页实际可以存储数据的空间大小，大约为15K，假设一条行记录占用的空间大小为1K，那么一个数据页就可以存储15条行记录，即 Y=15；
            - 假设 B+树是两层的：则 N=2，即 M=1280的（2-1）次方 * 15 ≈ 2w ；
            - 假设 B+树是三层的：则 N=3，即 M=1280的2次方 * 15 ≈ 2.5 kw；
                - 这个2.5kw，就是我们常说的单表建议最大行数2kw的由来。毕竟再加一层，数据就大得有点离谱了。三层数据页对应最多3次磁盘IO，也比较合理。
            - 假设 B+树是四层的：则 N=4，即 M=1280的3次方 * 15 ≈ 300亿

        - 综上所述，我们建议单表数据量大小在两千万。当然这个数据是根据每条行记录的大小为 1K 的时候估算而来的，而实际情况中可能并不是这个值，所以这个建议值两千万只是一个建议，而非一个标准。

#### 通用表空间

- 通用表空间先是出现在 MySQL Cluster 里，也就是 NDB 引擎。从 MySQL 5.7 引入到 InnoDB 引擎。

- 通用表空间和系统表空间一样，也是共享表空间。每个表空间可以包含一张或者多张表，也就是说通用表空间和表之间是一对多的关系。

- 通用表空间其实是介于系统表空间和单表空间之间的一种折中的方案。

    - 和系统表空间类似，不会自动收缩磁盘空间；
    - 和系统表空间类似，可以重命名表空间名字；
    - 和单表空间类似，可以很方便把表空间文件定义在 MySQL 数据目录之外；
    - 比单表空间占用更少的文件描述符，但是又不能像单表空间那样移植表空间。

```sql
create tablespace ts1 add datafile '/var/lib/mysql-files/ts1.ibd' engine innodb;
create table t1(id int,r1 datetime) tablespace ts1;
create table t2(id int,r1 datetime) tablespace ts1;
create table t3(id int,r1 datetime) tablespace ts1;
```

#### 切换各种表空间

- 要注意切换时间点，毕竟切换涉及到数据的迁移，类似 copy 文件对系统的影响。

```sql
// 表 t1 随时切换各种表空间
alter table t1 tablespace innodb_file_per_table;
alter table t1 tablespace innodb_system;
alter table t1 tablespace ts1;
```

### MyISAM

- MyISAM引擎是5.1版本之前的默认引擎

- 在 Mysql 保存目录下:

    | 文件拓展名 | 说明                     |
    |------------|--------------------------|
    | frm        | 表格式(innodb也有此文件) |
    | MYD        | 数据文件                 |
    | MYI        | 索引文件                 |

    ![image](./Pictures/mysql/myisam.avif)

- 不支持事务
- 不支持外键
- 不支持行锁：在执行查询语句(SELECT、UPDATE、DELETE、INSERT 等)前,会自动给涉及的表加读锁,这个过程并不需要用户干预

- 默认情况下,写锁比读锁具有更高的优先级:当一个锁释放时,这个锁会优先给写锁队列中等候的获取锁请求,然后再给读锁队列中等候的获取锁请求.

    - 这也正是 MyISAM 表不太适合于有大量更新操作和查询操作应用的原因,因为,大量的更新操作会造成查询操作很难获得读锁,从而可能永远阻塞.

- 测试在循环 50 次 select 的过程中,MYISAM 的表的写入情况

    ```sql
    # 创建存储过程,循环50次select

    delimiter #
    create procedure scn()
    begin
    declare i int default 1;
    declare s int default 50;

    while  i < s do
        select * from cnarea_2019;
        set i = i + 1;
    end while;

    end #
    delimiter ;

    # 执行scn
    call scn();
    ```

    打开另一个客户端,对 MyISAM 表修改数据:

    ```sql
    show processlist;

    update cnarea_2019
    set name='test-lock'
    where id <11;

    select name from cnarea_2019
    where id < 11;
    ```

    - 左边:修改数据的客户端
    - 右边:执行 call scn();

    左边在等待右边的锁,可以看到我停止 **scn()**后,立马修改成功

    ![image](./Pictures/mysql/myisam_lock.gif)


- 测试在循环 50 次 select 的过程中,innodb 的表的写入情况

    ```sql
    # 把 cnarea_2019表 改为innodb 引擎
    alter table cnarea_2019 rename cnarea_2019_innodb;
    alter table cnarea_2019_innodb engine = innodb;
    ```

    ```sql
    `u`# 创建存储过程,循环50次select
    delimiter #
    create procedure scn2()
    begin
    declare i int default 1;
    declare s int default 50;

    while  i < s do
        select * from cnarea_2019_innodb;
        set i = i + 1;
    end while;

    end #
    delimiter ;

    # 执行scn2
    call scn2();
    ```

    打开另一个客户端,对 innodb 表修改数据:

    ```sql
    update cnarea_2019_innodb
    set name='test-lock'
    where id < 11;

    select name from cnarea_2019_innodb
    where id < 11;
    ```

    - 左边:修改数据的客户端
    - 右边:执行 call scn2();

    修改数据后左边**commit**,右边也**commit**后,数据同步

    ![image](./Pictures/mysql/innodb_lock.gif)

### [InnoDB](https://dev.mysql.com/doc/refman/8.0/en/innodb-storage-engine.html)

注意:在 MariaDB 10.3.7 以上的版本,InnoDB 版本不再与 MySQL 发布版本相关联
[InnoDB and XtraDB](https://mariadb.com/kb/en/innodb/)

- 每一张表，在 Mysql 保存目录下保存2个文件：

    - frm：表格式
    - ibd：（innodb 数据文件，又叫表空间文件）: 索引和数据文件

    ![image](./Pictures/mysql/innodb1.avif)
    ![image](./Pictures/mysql/innodb.avif)

- 行格式:

    - Compact

    - Redundant

    ![image](./Pictures/mysql/innodb2.avif)

#### TRANSACTION (事务)

| 事务sql语句   | 操作           |
| ------------- | -------------- |
| BEGIN         | 开始一个事务   |
| ROLLBACK      | 事务回滚       |
| COMMIT        | 事务确认       |

```sql
# 创建表tz
create table tz (
    id int (8),
    name varchar(50),
    date DATE
);

# 开始事务
begin;

# 插入数据
insert into tz (id,name,date) values
(1,'tz','2020-10-24');

# 回滚到开始事务之前(rollback 和 commit 只能选一个)
rollback;
# 如果出现waring,表示该表的存储引擎不支持事务(不是innodb)
Query OK, 0 rows affected, 1 warning (0.00 sec)

# 如果不回滚,使用commit确认这次事务的修改
commit;
```

如果有两个会话,一个开启了事务,修改了数据.另一个会话同步数据要执行 `flush table 表名`

```sql
# 把 clone表 存放在缓冲区里的修改操作写入磁盘
flush table clone
```

![image](./Pictures/mysql/flush.avif)

`flush table clone`后, `select` 数据同步
![image](./Pictures/mysql/flush1.avif)

---

- `SAVEPOINT savepoint_name;` 声明一个事务保存点
- `ROLLBACK TO savepoint_name;` 回滚到事务保存点,但不会终止该事务
- `RELEASE SAVEPOINT savepoint_name;` // 删除指定保留点

```sql
# 创建数据库
create table tz (
    id int (8),
    name varchar(50),
    date DATE
);

# 声明一个名叫 abc 的事务保存点
savepoint abc;

# 插入数据
insert into tz (id,name,date) values
(1,'tz','2020-10-24');

# 回滚到 abc 事务保存点
rollback to abc;
```

##### autocommit（自动提交）

`autocommit = 1` 对表的所有修改将立即生效

`autocommit = 0` 则必须使用 COMMIT 来提交事务,或使用 ROLLBACK 来回滚撤销事务

- 1.如果 InnoDB 表有大量的修改操作,应设置 `autocommit = 0` 因为 `ROLLBACK` 操作会浪费大量的 I/O

    ```ini
    [mysqld]
    autocommit = 0
    ```

    - **注意:**

        - 不要长时间打开事务会话,适当的时候要执行 COMMIT(完成更改)或 ROLLBACK(回滚撤消更改)
        - ROLLBACK 这是一个相对昂贵的操作 请避免对大量行进行更改,然后回滚这些更改.

- 2.如果只是查询表,没有大量的修改,应设置 `autocommit = 1`

##### [事务隔离性](https://mariadb.com/kb/en/set-transaction/)

- mysql默认隔离性为REPEATABLE READ（可重复读）

- 基本命令

    ```sql
    -- 查看当前会话的隔离级别
    SHOW VARIABLES LIKE 'transaction_isolation';
    -- 查看全局的隔离级别
    SHOW GLOBAL VARIABLES LIKE 'transaction_isolation';
    -- 查看当前会话和全局的隔离级别
    SELECT @@GLOBAL.tx_isolation, @@tx_isolation;

    -- 设置当前会话的隔离级别。设置为READ COMMITTED（已提交读）
    SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

    -- 设置全局的隔离级别。设置为REPEATABLE READ（可重复读）
    SET GLOBAL TRANSACTION ISOLATION LEVEL REPEATABLE READ;
    ```

- 创建测试表，并插入数据:

    ```sql
    drop table if exists test;

    CREATE TABLE test(
        id int (8),
        name varchar(50),
        date DATE
    );

    insert into test (id,name,date) values
    (1,'tz1','2020-10-24'),
    (10,'tz2','2020-10-24'),
    (100,'tz3','2020-10-24');

    commit;
    ```

###### read uncommitted(未提交读)，也叫dirty read (脏读)

> 事务A能读到事务B修改了但未提交的数据

- 开启事务 a:

    ```sql
    # 设置事务a read uncommitted
    set session transaction isolation level read uncommitted;
    begin;
    select * from test;
    ```

- 开启事务 b,并修改数据,不需要提交:

    ```sql
    begin;
    select *from test;

    update test
    set id = 20
    where id = 10;
    ```

- 事务 a 就能读取到b未提交修改的数据:

    ```sql
    select * from test;
    ```

    - 右边为事务 a
    - 左边为事务 b
    ![image](./Pictures/mysql/uncommitted.gif)

- 注意:如果事务 b,没有 `commit` 就退出.那么事务 b 的修改将失效

    ![image](./Pictures/mysql/uncommitted1.gif)

###### read committed(已提交读) , phantom read (幻读):

> 事务A只能读到事务B修改并提交的数据

- 开启事务 a:

    ```sql
    # 设置事务a read committed
    set session transaction isolation level read committed;

    # 开启事务
    begin;
    select * from test;
    ```

- 开启事务 b,并修改数据后,提交:

    ```sql
    begin;
    select *from test;

    update test
    set id = 20
    where id = 10;

    # 区别于 read uncommitted
    commit;
    ```

- 事务 a 就能读取:

    ```sql
    select * from test;
    ```

    - 右边为事务 a
    - 左边为事务 b
    ![image](./Pictures/mysql/committed.gif)

###### MVCC(多版本并发控制)：解决幻读问题

- MVCC并非乐观锁，但是InnoDB存储引擎所实现的MVCC是乐观的，它和之前所提到的用户行为的“乐观锁”都采用的是乐观机制，属于不同的“乐观锁”手段，它们都是“乐观家族”的成员。

- InnoDB 中的 RC 和 RR 隔离事务是基于多版本并发控制（MVVC）实现高性能事务。

- InnoDB的MVCC，是通过在每行记录后保存两个隐藏的列来实现的（用户不可见）。
    - 一个列保存行创建的时间
    - 一个列保存行过期（删除）的时间，这里所说的时间并不是传统意义上的时间，而是系统版本号

- mvcc在不同sql语句的操作：

    - SELECT：InnoDB会根据以下两个条件检查每行记录：

        - 1.InnoDB只查找版本早于当前事务版本的数据行（行的系统版本号小于或者等于事务的系统版本号），这样可以确保事务读取到的行，要么是在事务开始之前已经存在的，要么是事务自身插入或者修改过的（结合以下INSERT、UPDATE操作理解）。

        - 2.行的删除版本要么未定义，要么大于当前事务版本号。可以确保事务读取到的行，在事务开启之前未被删除（结合以下DELETE操作理解）。

    - INSERT：InnoDB为新插入的每一行保存当前系统版本号作为行版本号。
    - DELETE：InnoDB为删除的每一行保存当前系统版本号作为行删除标识（第二个隐藏列的作用来了）。
    - UPDATE：InnoDB将更新后的列作为新的行插入数据库（并不是覆盖），并保存当前系统版本号作为该行的行版本号，同时保存当前系统版本号到原来的行作为行删除标识。

##### 结合业务场景，使用不同的事务隔离

- 隔离级别越高，并发性能就越低。

- 其实 MySQL 的并发事务调优和 Java 的多线程编程调优非常类似，都是可以通过减小锁粒度和减少锁的持有时间进行调优。在 MySQL 的并发事务调优中，我们尽量在可以使用低事务隔离级别的业务场景中，避免使用高事务隔离级别。

    - 在功能业务开发时，开发人员往往会为了追求开发速度，习惯使用默认的参数设置来实现业务功能。例如，在 service 方法中，你可能习惯默认使用 transaction，很少再手动变更事务隔离级别。但要知道，transaction 默认是 RR 事务隔离级别，在某些业务场景下，可能并不合适。因此，我们还是要结合具体的业务场景，进行考虑。

- 那换到业务场景中，我们如何判断用哪种隔离级别更合适呢？我们可以通过两个简单的业务来说下其中的选择方法。

    - 1.我们在修改用户最后登录时间的业务场景中，这里对查询用户的登录时间没有特别严格的准确性要求，而修改用户登录信息只有用户自己登录时才会修改，不存在一个事务提交的信息被覆盖的可能。所以我们允许该业务使用最低隔离级别。

    - 2.而如果是账户中的余额或积分的消费，就存在多个客户端同时消费一个账户的情况，此时我们应该选择 RR 级别来保证一旦有一个客户端在对账户进行消费，其他客户端就不可能对该账户同时进行消费了。

- 是否遇到过以下 SQL 异常呢？在抢购系统的日志中，在活动区间，我们经常可以看到这种异常日志：`MySQLQueryInterruptedException: Query execution was interrupted`

    - 由于在抢购提交订单中开启了事务，在高并发时对一条记录进行更新的情况下，当多个事务同时对一条记录进行更新时，极端情况下，一个更新操作进去排队系统后，可能会一直拿不到锁，最后因超时被系统打断踢出。

    - 在两种不同的执行顺序下，其结果都是一样的，但在事务性能方面却不一样：

        | 执行顺序1                    | 执行顺序2                    |
        |------------------------------|------------------------------|
        | 1.开启事务                   | 1.开启事务                   |
        | 2.查询库存、判断库存是否满足 | 2.查询库存、判断库存是否满足 |
        | 3.新建订单                   | 3.扣除库存                   |
        | 4.扣除库存                   | 4.新建订单                   |
        | 5.提交或回滚                 | 5.提交或回滚                 |

        - 这是因为，虽然这些操作在同一个事务，但锁的申请在不同时间，只有当其他操作都执行完，才会释放所有锁。因为扣除库存是更新操作，属于行锁，这将会影响到其他操作该数据的事务，所以我们应该尽量避免长时间地持有该锁，尽快释放该锁。

        - 又因为先新建订单和先扣除库存都不会影响业务，所以我们可以将扣除库存操作放到最后，也就是使用执行顺序 1，以此尽量减小锁的持有时间。

#### 锁

- Mysql 锁分为**共享锁**和**排他锁**,也叫做 **读锁** 和 **写锁**:

    - 写锁: 是排他的,它会阻塞其他的写锁和读锁.从颗粒度来区分,可以分为 **表锁** 和 **行锁** 两种.

    - 表锁: 会锁定整张表并且阻塞其他用户对该表的所有读写操作,比如 alter 修改表结构的时候会锁表.

> Innodb 默认使用的是行锁.而行锁是基于索引的,因此要想加上行锁,在加锁时必须命中索引,否则将使用表锁.

- **行锁分为:**

    - Pessimistic Locking(悲观锁): 具有**排他性**,数据处理过程中,数据处于锁定状态

    - Optimistic Locking(乐观锁): 记录 commit 的版本号(version),对数据修改会改变 version,通过对比 **修改前后 的 version 是否一致**来确定是哪个事务的 commit

- 行锁的具体实现算法有三种：
    - 1.record lock：专门对索引项加锁
    - 2.gap lock：是对索引项之间的间隙加锁
    - 3.next-key lock：则是前面两种的组合，对索引项以其之间的间隙加锁。

    - 只在可重复读或以上隔离级别下的特定操作才会取得 gap lock 或 next-key lock，在 Select 、Update 和 Delete 时，除了基于唯一索引的查询之外，其他索引查询时都会获取 gap lock 或 next-key lock，即锁住其扫描的范围。

[详情](https://zhuanlan.zhihu.com/p/222958908)

> ```sql
> # 加锁
> LOCK TABLES 表1 WRITE, 表2 READ, ...;
>
> # 排他锁(写锁)
> LOCK TABLES 表1 WRITE;
>
> # 共享锁(读锁)
> LOCK TABLES 表1 READ;
> ```

> ```sql
> # 解锁
> UNLOCK TABLES;
> ```

> ```sql
> # 通过队列查看是否有 lock
> show processlist;
> ```

- 创建一个表进行实验:

    ```sql
    CREATE TABLE locking(
        id int (8) NOT NULL UNIQUE,
        name varchar(50),
        date DATE
    );

    insert into locking (id,name,date) values
    (1,'tz1','2020-10-24'),
    (10,'tz2','2020-10-24'),
    (100,'tz3','2020-10-24');
    ```

##### 共享锁（表锁）：只能加入读取锁

- 事务 a 对表 locking 加入共享锁:

    ```sql
    begin;
    select * from locking
    lock in share mode;
    ```

- 事务 b 也能对表 locking 加入共享锁:

    ```sql
    begin;
    select * from locking
    lock in share mode;

    update locking set id = 20 where id = 10;

    # 加入非读取锁(悲观锁) 或者 使用update语句,会阻塞
    select * from locking
    for update;
    ```

    ![image](./Pictures/mysql/innodb_lock6.gif)

##### 排他锁（表锁）和悲观锁（行锁）：不能加入其他锁

- 实验1：排他锁（表锁）

    ```sql
    # 事务a 在select 最后 加入 for update 排他锁,锁整个表
    begin;
    select * from locking
    for update;

    # 事务b 执行update时 或者 加入其他锁,会阻塞
    begin;
    update locking
    set id = 1
    where id = 2;

    # 事务a commit后,事务b update id = 1 执行成功
    commit;
    ```

    ![image](./Pictures/mysql/innodb_lock1.gif)

- 实验2：悲观锁（行锁）

    ```sql
    # 事务a 加入where 从句,只锁对应的行(我这里是id = 1)
    select * from locking
    where id = 1
    for update;

    # 事务b 对 update 不同的行 成功执行
    update locking
    set id = 10
    where id = 20;

    # 事务b update id = 1时,会阻塞
    update locking
    set id = 2
    where id = 1;

    # 事务a commit后,事务b update id = 1 执行成功
    commit;
    ```

    ![image](./Pictures/mysql/innodb_lock2.gif)

##### 乐观锁（行锁）：版本号

修改包含:update,delete

- 事务 a: 修改数据为 2

    ```sql
    begin;
    select * from locking;

    update locking
    set id = 2
    where id = 1;

    commit;
    select * from locking;
    ```

- 事务 b: 修改数据为 3

    ```sql
    begin
    select * from locking;

    update locking
    set id = 3
    where id = 1;

    commit;
    ```

最后结果 **2**.

因为事务 a 比事务 b 先 commit,此时版本号改变,所以当事务 b 要 commit 时的版本号 与 事务 b 开始时的版本号不一致,提交失败.

![image](./Pictures/mysql/innodb_lock5.gif)

##### 事务a 和 事务b 插入相同的数据

- **事务 a** 先于 **事务 b** 插入.那么**事务 b** 会被阻塞,当**事务 a** `commit` 后：

    - 如果有唯一性索引或者主健那么 **事务 b** 会插入失败(幻读)

    - 如果没有,那么将会出现相同的两条数据

- 实验1：**有唯一性索引或者主健:**

    ```sql
    # 事务a 和 事务 b 插入同样的数据
    insert into locking (id,name,date) value
    (1000,'tz4','2020-10-24');
    ```

    ![image](./Pictures/mysql/innodb_lock3.gif)

- 实验2：**没有索引:**

    ```sql
    # 删除唯一性索引
    alter table locking
    drop index id;

    # 事务a 和 事务 b 插入同样的数据
    insert into locking (id,name,date) value
    (1000,'tz4','2020-10-24');
    ```

    ![image](./Pictures/mysql/innodb_lock4.gif)

##### 死锁

- 死锁

    ![image](./Pictures/mysql/innodb_lock.avif)

    事务 A 在等待事务 B 释放 id=2 的行锁

    事务 B 在等待事务 A 释放 id=1 的行锁

    互相等待对方的资源释放,就进入了死锁状态

- 当出现死锁以后,有两种策略:

    - 1:进入等待,直到超时.超时时间参数 `innodb_lock_wait_timeout`

    - 2:发起死锁检测,发现死锁后,主动回滚死锁链条中的某一个事务,让其他事务得以继续执行.将参数 `innodb_deadlock_detect` 设置为 `on`.但是它有额外负担的.每当一个事务被锁的时候,就要看看它所依赖的线程有没有被别人锁住,如此循环,最后判断是否出现了循环等待,也就是死锁

### frm文件解析利器mysqlfrm

- 可以解析innodb和Myisam的.frm文件，转换为CREATE TABLE语句

- 安装
```sh
yum install -y mysql-utilities
```

- 使用
```sh
# 将.frm文件转换为CREATE TABLE语句
mysqlfrm --diagnostic /var/lib/mysql/mysql/columns_priv.frm

# --server 连接远程mysql
mysqlfrm --diagnostic --server=root:123456@192.168.77.128:3306 /var/lib/mysql/trail/trail_tab.frm

# 分析一个目录下的全部.frm文件生成建表语句
mysqlfrm --diagnostic /var/lib/mysql/my_db/bk/ >createtb.sql
# 可以看到一共生成了 124 个建表语句。
grep "^CREATE TABLE" createtb.sql |wc -l
124
```

## my.cnf配置文件

- 调整 InnoDB 配置，提高 Mysql 服务器
    ```
    # 将缓冲池大小设置为服务器上可用 RAM 的 80%（例如，在 16G RAM 服务器上）：
    # 当您重新启动具有大型缓冲池和数据库本身大量数据的 Mysql 服务器时，请准备好稍等片刻。
    innodb_buffer_pool_size = 12G

    # 当 InnoDB 表中的数据发生变化时，Mysql 会先将变化写入缓冲池。之后，它将更改操作（以低级格式）记录到日志文件（所谓的“重做日志”）
    # 如果这些日志文件很小，Mysql 必须直接对数据文件进行大量写入磁盘。因此，将日志文件设置为大（如果可能，与缓冲池一样大）
    # 警告。当您更改innodb_log_file_size选项时，您必须在重新启动服务器时删除旧的日志文件：rm /var/lib/mysql/ib_logfile*
    innodb_log_file_size = 12G

    # 大型事务将迫使 Mysql 将大量数据写入日志文件。为了节省资源，Mysql 会先将数据写入日志缓冲区：
    # 如果日志缓冲区小于事务影响，Mysql 将不得不等到它将所有内容写入磁盘。如果您有一次插入/更新/删除多行的查询，请增加日志缓冲区：
    innodb_log_buffer_size = 128M

    # 数据刷新到磁盘的频率
    # 默认值1：将在每次事务后将数据刷新到磁盘。
    # 设置值0：将要求 Mysql 每秒将数据刷新到磁盘。这将显着提高写入性能。但要小心。这可能导致系统崩溃时丢失最多 1 秒的事务。因此，在更改此选项之前，请绝对复制您的 Mysql 服务器以获得可靠性：
    innodb_flush_log_at_trx_commit = 0

    # 不仅是刷新周期，刷新的方法也会影响Mysql的性能。
    # O_DSYNC在将数据写入磁盘时，使用选项将跳过双重缓存：
    innodb_flush_method = O_DSYNC
    ```

## 备份与恢复

- 备份工具可以分为：

    - 1.物理备份：直接包含了数据库的数据文件，适用于大数据量，需要快速恢复的数据库。

    - 2.逻辑备份：包含的是一系列文本文件，其中是代表数据库中数据结构和内容的SQL语句，适用于较小数据量或是跨版本的数据库备份恢复。

### mysqldump 备份和恢复

- 先创建一个数据表

```sql
use china;
create table tz (
    id   int (8),
    name varchar(50),
    date DATE
);

insert into tz (id,name,date) values
(1,'tz','2020-10-24');
```

- 1.使用 `mysqlimport` 导入(不推荐)

  > 因为 `mysqlimport` 是把数据**导入新增**进去表里,而非恢复

```sql
# 导出tz表. 注意:路径要加''
SELECT * FROM tz INTO OUTFILE '/tmp/tz.txt';

# 删除表和表的数据
drop table tz;

# 导入前要创建一个新的表
create table tz (
    id int (8),
    name varchar(50),
    date DATE
);
```

回到终端使用 `mysqlimport` 进行数据导入:

```sh
mysqlimport china /tmp/tz.txt
```

- 2.使用 `mysqldump` 备份

```sql
# 备份 china 数据库

mysqldump -uroot -pYouPassward china > china.sql

# 备份 china 数据库里的 tz 表

mysqldump -uroot -pYouPassward china tz > tz-tables.sql

# 备份所有数据库

mysqldump -uroot -pYouPassward --all-databases > all.sql

# -d 只备份所有数据库表结构(不包含表数据)

mysqldump -uroot -pYouPassward -d --all-databases > mysqlbak-structure.sql

# 恢复到 china 数据库

mysql -uroot -pYouPassward china < china.sql

# 恢复所有数据库

mysql -uroot -pYouPassward < all.sql
```

### [mydumper：比 MySQL 自带的 mysqldump 快很多](https://github.com/maxbube/mydumper)

- [详细参数](https://linux.cn/article-5330-1.html)

```sh
# 带压缩备份--compress(gz)
mydumper \
--database=china \
--user=root \
--password=YouPassword \
--outputdir=/tmp/china.sql \
--rows=500000 \
--compress \
--build-empty-files \
--threads=10 \
--compress-protocol
```

![image](./Pictures/mysql/du.avif)

```sh
# 不带压缩备份,最后再用7z压缩
mydumper \
--database=china \
--user=root \
--password=YouPassword \
--outputdir=/tmp/china.sql \
--rows=500000 \
--build-empty-files \
--threads=10 \
--compress-protocol
```

![image](./Pictures/mysql/du1.avif)

```sh
# 恢复
myloader \
--database=china \
--directory=/tmp/china.sql \
--queries-per-transaction=50000 \
--threads=10 \
--compress-protocol \
--verbose=3
```


### XtraBackup 热备份

- [爱可生开源社区：图解MySQL | [原理解析] XtraBackup全量备份还原](https://zhuanlan.zhihu.com/p/73632725)
- [爱可生开源社区：图解MySQL | [原理解析] XtraBackup增量备份还原](https://mp.weixin.qq.com/s?__biz=MzU2NzgwMTg0MA==&mid=2247484425&idx=1&sn=a3c70d67676af1c8290b089887d8e4d3&chksm=fc96e696cbe16f80120fbebd0749362fa5501e7a33dbb34ab71c4a5947c57c28dd8496850c6b&scene=21#wechat_redirect)
- [爱可生开源社区：图解MySQL|[原理解析]XtraBackup备份恢复时为什么要加apply-log-only参数](https://zhuanlan.zhihu.com/p/84716636)

- XtraBackup：属于物理备份
    - 在备份时复制所有MySQL的数据文件以及一些事务日志信息
    - 在还原时将复制的数据文件放回至MySQL数据目录，并应用日志保证数据一致。

- Xtrabackup的优点：
    - 1.备份速度快，物理备份可靠
    - 2.备份过程不会打断正在执行的事务
    - 3.能够基于压缩等功能节约磁盘空间和流量
    - 4.自动备份校验
    - 5.还原速度快
    - 6.可以流传将备份传输到另外一台机器上
    - 7.在不增加服务器负载的情况备份数据

- XtraBackup备份原理：

    - 全量备份的过程：

        ![image](./Pictures/mysql/XtraBackup全量备份.avif)

        - 1.首先开启一个后台检测进程，复制已有的redo log，然后监听redo log变化，一旦发现redo中有新的日志写入，立刻将日志记入后台日志文件xtrabackup_log中。

        - 2.之后复制innodb的数据文件和系统表空间文件ibdata1

            - 为什么要先复制redo log，而不是直接开始复制数据文件？因为XtraBackup是基于InnoDB的crash recovery机制进行工作的。由于是热备操作，在备份过程中可能有持续的数据写入，直接复制出来的数据文件可能有缺失或被修改的页，而redo log记录了InnoDB引擎的所有事务日志

        - 3.执行flush tables with read lock操作（加锁：全局读锁）
            - 非事务引擎数据文件较多时，全局读锁的时间会较长。
            - 加锁：全局读锁的作用？在加锁期间，没有新数据写入，XtraBackup会复制此时的binlog位置信息，frm表结构，MyISAM等非事务表。

        - 4.复制.frm，MYI，MYD，等文件
        - 5.获取binlog点位信息等元数据
        - 6.最后会发出unlock tables
        - 7.停止xtrabackup_log。

    - 恢复的过程：
        - 1.模拟MySQL进行recover，将redo log回放到数据文件中
        - 2.等到recover完成
        - 3.重建redo log，为启动数据库做准备
        - 4.将数据文件复制回MySQL数据目录
        - 5.恢复完成

    - 增量备份：只针对增量备份过程中的”增量”进行处理，主要是相对innodb而言，对myisam和其他存储引擎而言，它仍然是全量备份。

        - 如何识别InnoDB的哪些数据是增量的？
            - 数据文件中的数据页都有LSN号，LSN可以看做是数据页的变更时间戳。那么通过这个时间戳，就可以识别数据页在全量备份后是否修改过

        - 如果一个数据页原本不是增量范围内的，在增量备份的过程中，数据页更新了，那么增量备份是否会涵盖这个数据页？ 与全量备份中的解决方案相同：通过恢复时回放redo log，解决数据新旧不一致的问题。

    - 增量恢复：

        ![image](./Pictures/mysql/XtraBackup增量恢复.avif)

        - 1.先还原一个全量备份到临时目录
        - 2.开始还原增量备份，将增量备份中的增量的数据文件，覆盖到临时目录中。
        - 3.将增量备份中的redo log，回放到临时目录中。
        - 4.将其他文件覆盖到临时目录中。
        - 5.增备还原完成。
        - 6.重建redo log，为启动数据库做准备。
        - 7.将临时目录中的文件，拷贝到MySQL的数据目录中。

- XtraBackup：能对innodb和xtradb存储引擎进行热备份。也能对MyISAM存储引擎进行备份，只不过对于MyISAM的备份需要加表锁，会阻塞写操作。

- 有2个工具
    - `xtrabackup`：只能备份innodb和xtradb存储引擎数据表
    - `innobackupex`：是通过perl脚本对xtrabackup进行封装和功能扩展，除了能备份innodb和xtradb存储引擎的数据表外，还可以备份MyISAM数据表和frm文件。
        - 由于MyISAM不支持事务，在对MyISAM表备份之前，需要对全库进行加读锁，阻塞写操作。如果在从库进行的话，还会影响主从同步，从而造成延迟。
        - 备份时是根据配置文件`my.cnf`获取备份文件的信息

#### 安装

```sh
rpm -ivh
yum install -y percona-xtrabackup
```

### 导出不同文件格式

```sh
# \G格式导出数据
mysql -uroot -p --vertical --execute="select * from cnarea_2019;" china > /tmp/cnarea_2019.html

# html
mysql -uroot -p --html --execute="select * from cnarea_2019;" china > /tmp/cnarea_2019.html

# xml
mysql -uroot -p --xml --execute="select * from cnarea_2019;" china > /tmp/cnarea_2019.html
```

```sql
# csv
SELECT * FROM cnarea_2019 INTO OUTFILE '/tmp/cnarea_2019.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n';
```

## 常见错误

- 日志目录`/var/lib/mysql`

### 登录错误
#### ERROR 1046 (28000)

```sh
mysql -uroot -p
ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)
```

- 修复

```sh
# 在[mysqld]后添加skip-grant-tables(登录时跳过权限检查)
echo "skip-grant-tables" >> /etc/my.cnf
```

```sql
# 连接数据库
mysql -uroot -p
use mysql;

# 刷新权限
flush privileges;

# 修改密码(8以下的版本)
update mysql.user set password=PASSWORD('newpassword') where User='root';
# 修改密码(8以上的版本)
alter user 'root'@'localhost' identified by 'newpassword';
```

- 修改密码成功后

```sh
# 删除刚才添加skip-grant-tables
sed -i '/skip-grant-tables/d' /etc/my.cnf

# 重新连接
mysql -uroot -p
```

#### ERROR 1819 (HY000)： 密码不满足策略安全

```sql
mysql> alter user 'root'@'localhost' identified by 'newpassword';
ERROR 1819 (HY000): Your password does not satisfy the current policy requirements
```

- 修复

```sql
# 查看密码策略
SHOW VARIABLES LIKE 'validate_password%';

mysql> SHOW VARIABLES LIKE 'validate_password%';
+--------------------------------------+--------+
| Variable_name                        | Value  |
+--------------------------------------+--------+
| validate_password.check_user_name    | ON     |
| validate_password.dictionary_file    |        |
| validate_password.length             | 8      |
| validate_password.mixed_case_count   | 1      |
| validate_password.number_count       | 1      |
| validate_password.policy             | MEDIUM |
| validate_password.special_char_count | 1      |
+--------------------------------------+--------+

# 设置策略为LOW
set global validate_password.policy='LOW';

# 密码修改成功
mysql> alter user 'root'@'localhost' identified by 'newpassword';
Query OK, 0 rows affected (0.52 sec)
```

### ERROR 2013 (HY000): Lost connection to MySQL server during query(导致无法 stop slave;)

**修复:**

```sql
[mysqld]
skip-name-resolve
```

### ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (111)(连接不了数据库)

- `systemctl restart mysql` 重启配置没问题
- `ps aux | grep mysql` 进程存在
- 内存不足

### ERROR 1075 (42000): Incorrect table definition; there can be only one auto column and it must be defined

```sql
# 要先删除 auto_incrment 属性,才能删除主健(我这里的主健是 id 字段)
alter table test modify id int(10);
alter table test drop primary key;
```

### 启动错误

```sh
● mariadb.service - MariaDB 10.5.8 database server
     Loaded: loaded (/usr/lib/systemd/system/mariadb.service; enabled; vendor preset: disabled)
     Active: failed (Result: exit-code) since Sun 2020-11-29 10:05:15 CST; 10min ago
       Docs: man:mariadbd(8)
             https://mariadb.com/kb/en/library/systemd/
    Process: 11236 ExecStartPre=/bin/sh -c systemctl unset-environment _WSREP_START_POSITION (code=exited, status=0/SUCCESS)
    Process: 11237 ExecStartPre=/bin/sh -c [ ! -e /usr/bin/galera_recovery ] && VAR= ||   VAR=`cd /usr/bin/..; /usr/bin/galera_recovery`; [ $? -eq 0 ]   && systemctl set-environment _WSREP_START_POSITION=$VAR || exit 1 (code=exited, status=0/SUCCESS)
    Process: 11246 ExecStart=/usr/bin/mariadbd $MYSQLD_OPTS $_WSREP_NEW_CLUSTER $_WSREP_START_POSITION (code=exited, status=1/FAILURE)
   Main PID: 11246 (code=exited, status=1/FAILURE)
     Status: "MariaDB server is down"
```

解决:

```sh
# 先删除目录
mv /var/lib/mysql /tmp
# 初始化
mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
```

### 表损坏

- INNODB一般不会损坏, 不存在什么查询会导致表损坏

    - 1.硬件问题(内存, 硬盘)

    - 2.使用 `rsync` 命令备份

```sql
-- 检测表是否损坏.注意并不是所有存储引擎都支持该命令
CHECK TABLE table_name;

-- 修复表
REPAIR TABLE table_name;

-- 也可以使用ALTER TABLE重建表
ALTER TABLE table_name ENGINE=INNODB;
```

### [knowclub：在MySQL集群中，如何从几百万个抓包中找到一个异常的包？](https://mp.weixin.qq.com/s/C04qADbcfZP9e7RQDbz-Kg)

## 极限值测试

看看一个表最多是不是 1017 列:

```sh
# 通过脚本快速生成1017.sql
echo 'drop table if exists test_1017;' > /tmp/1017.sql

echo 'CREATE TABLE test_1017(' >> /tmp/1017.sql

for i in $(seq 1 1016);do
    echo "id_$i int," >> /tmp/1017.sql
done
echo "id_1017 int" >> /tmp/1017.sql

echo ");" >> /tmp/1017.sql

# 执行
sudo mysql -uroot -pYouPassword YouDatabase < /tmp/1017.sql
```

![image](./Pictures/mysql/1017.avif)

改为 1018:

```sh
# 通过脚本快速生成1018.sql
echo 'drop table if exists test_1018;' > /tmp/1018.sql

echo 'CREATE TABLE test_1018(' >> /tmp/1018.sql

for i in $(seq 1 1017);do
    echo "id_$i int," >> /tmp/1018.sql
done
echo "id_1018 int" >> /tmp/1018.sql

echo ");" >> /tmp/1018.sql

# 执行
sudo mysql -uroot -pYouPassword YouDatabase < /tmp/1018.sql
```

![image](./Pictures/mysql/1018.avif)

## benchmark(基准测试)

- 测试原则:

    - 基准测试应该运行足够长的时间(8 - 12小时), 因为系统可能需要3, 4个小时的io预热, 如果没有时间去完成, 那么已经花费的时间都是浪费

    - 测试结果保证可重复:每次测试都重启系统, 以及对测试的磁盘分区进行格式化, 数据的碎片度会导致测试结果不能重复

    - 不能用cpu密集性的标准去测试io密集性的应用

- 测试指标:

    - 并发度:是一个测试属性, 而不是一个测试结果. 在并发度增加时需要观察**吞吐量**, **响应时间**

        - 注意:web站点有50000个用户同时访问时, mysql可能只有10 - 15个访问

- 通过md5(), sha1()函数快速测试(不能用作基准测试):

    ```sql
    set @input := 'hello world';
    select benchmark(10000, MD5(@input));
    select benchmark(10000, SHA1(@input));
    ```

- 在性能下跌时可以使用以下命令:

    ```sql
    show engine innodb status\G;

    # 查看线程状态
    show full processlist;
    ```

### [sysbench](https://github.com/akopytov/sysbench)

- 优点:

    - sysbench的io测试与innodb的io非常相识

    - 支持lua语言

- cpu测试:

    ```sql
    sysbench --test=cpu --cpu-max-prime=20000 run
    ```

- io测试:

    | mode(测试模式) | 测试内容 |
    |----------------|----------|
    | seqwr          | 顺序写入 |
    | seqrewr        | 顺序重写 |
    | seqrd          | 顺序读取 |
    | rndrd          | 随机写入 |
    | rndwr          | 随机读取 |
    | rndrw          | 随机读写 |

    ```sql
    # 生成数据文件, 注意文件必须比内存大
    sysbench --test=fileio --file-total-size=100G prepare

    # rndrw:随机读写io测试
    sysbench --test=fileio --file-total-size=100G prepare --file-test-mode=rndrw/ --init-rng=on --max-time=300 --max-requests=0

    # 删除数据文件
    sysbench --test=fileio --file-total-size=100G cleanup
    ```

## 高效强大的 mysql 软件

- [awesome-mysql](http://shlomi-noach.github.io/awesome-mysql/)

    - [中文版](https://github.com/jobbole/awesome-mysql-cn)


- [MySQL 常用工具选型和建议](https://zhuanlan.zhihu.com/p/86846532)

### gui管理工具

- MySQL Workbench：这是 Oracle 公司开发的一款免费的 MySQL 集成环境。MySQL Workbench 提供了数据建模、SQL开发、数据库管理、用户管理、备份等功能，并支持导入和导出数据，以及与其他数据库进行交互。MySQL Workbench 面向数据库架构师、开发人员和 DBA。 MySQL Workbench 可在 Windows、Linux 和 Mac OS X 上使用。

- HeidiSQL：HeidiSQL 是免费软件，其目标是易于学习。“Heidi”可让您查看和编辑运行数据库系统 MariaDB、MySQL、Microsoft SQL、PostgreSQL 和 SQLite 的数据和结构。

- phpMyAdmin：phpMyAdmin 是一个用 PHP 编写的免费软件工具，旨在通过 Web 处理 MySQL 的管理。 phpMyAdmin 支持 MySQL 和 MariaDB 上的各种操作。 常用的操作（管理数据库、表、列、关系、索引、用户、权限等）可以通过用户界面执行，同时您仍然可以直接执行任何 SQL 语句。

- Navicat for MySQL：Navicat for MySQL 是管理和开发 MySQL 或 MariaDB 的理想解决方案。它是一套单一的应用程序，能同时连接 MySQL 和 MariaDB 数据库，并与 OceanBase 数据库及 Amazon RDS、Amazon Aurora、Oracle Cloud、Microsoft Azure、阿里云、腾讯云和华为云等云数据库兼容。这套全面的前端工具为数据库管理、开发和维护提供了一款直观而强大的图形界面。

- DBeaver：DBeaver 是一个通用的数据库管理和开发工具，支持包括 MySQL 在内的几乎所有的数据库产品。它基于 Java 开发，可以运行在 Windows、Linux、macOS 等各种操作系统上。

- DataGrip：DataGrip 是一个多引擎数据库环境，使用者无需切换多种数据库工具，即可轻松管理 MySQL 等数据库。DataGrip 支持智能代码补全、实时分析和快速修复特性，並集成了版本控制。

- SQL Developer：這是一款由 Oracle 公司开发的集成开发环境（IDE），它专为数据库管理和开发而设计。这款工具提供了从数据库设计、建模、开发到维护的一站式服务，使得开发者能够在一个统一的界面中完成所有的数据库相关工作。Oracle SQL Developer 是基於 Java 開發的，不僅可以連接到 Oracle 数据库，也可以连接到选定的第三方（非 Oracle）数据库、查看元数据和数据，以及将这些数据库迁移到 Oracle。

### [mycli](https://github.com/dbcli/mycli)

- 更友好的 mysql 命令行
- 目前发现不能,修改和查看用户权限

```sql
mysql root@localhost:(none)> SELECT DISTINCT CONCAT('User: ''',user,'''@''',host,''';') AS query FROM mysq
                          -> l.user;
(1142, "SELECT command denied to user 'root'@'localhost' for table 'user'")
```

![image](./Pictures/mysql/mycli.avif)

### [mitzasql](https://github.com/vladbalmos/mitzasql)

- 一个使用`vim`快捷键的 `mysql-tui`

![image](./Pictures/mysql/mysql-tui.avif)
![image](./Pictures/mysql/mysql-tui1.avif)

### [binlog2sql](https://github.com/danfengcao/binlog2sql)

```sql
drop table if exists test;

CREATE TABLE test(
    id int (8),
    name varchar(50),
    date DATE
);

insert into test (id,name,date) values
(1,'tz1','2020-10-24'),
(10,'tz2','2020-10-24'),
(100,'tz3','2020-10-24');

commit;

select current_timestamp();
+---------------------+
| current_timestamp() |
+---------------------+
| 2020-11-19 01:59:05 |
+---------------------+

delete from test
where id = 1;

update test
set id = 20
where id = 10;

insert into test (id,name,date) values
(1000,'tz4','2020-10-24');

commit;

select * from test;

show master status;
+------------+----------+--------------+------------------+
| File       | Position | Binlog_Do_DB | Binlog_Ignore_DB |
+------------+----------+--------------+------------------+
| bin.000014 |     6337 |              |                  |
+------------+----------+--------------+------------------+

select current_timestamp();
+---------------------+
| current_timestamp() |
+---------------------+
| 2020-11-19 01:59:34 |
+---------------------+
```

```sh
mysqlbinlog --no-defaults -v --start-datetime="2020-11-19 01:59:05" --stop-datetime="2020-11-19 01:59:34" /var/lib/mysql/bin.000014 --result-file=/tmp/result.sql

python binlog2sql/binlog2sql.py -uroot -p -dtest --start-file='bin.000014' --start-datetime="2020-11-19 01:59:05" --stop-datetime="2020-11-19 01:59:34" > /tmp/tmp.log

python binlog2sql/binlog2sql.py -uroot -p -dtest --flashback --start-file='bin.000014' --start-datetime="2020-11-19 01:59:05" --stop-datetime="2020-11-19 01:59:34" > /tmp/tmp.log
# 失败
```

### [percona-toolkit 运维监控工具](https://www.percona.com/doc/percona-toolkit/LATEST/index.html)

[percona-toolkit 工具的使用](https://www.cnblogs.com/chenpingzhao/p/4850420.html)

```sh
pt-query-digest /var/log/mysql/mysql_slow.log

pt-query-digest               \
    --group-by fingerprint    \
    --order-by Query_time:sum \
    --limit 10                \
    /var/log/mysql/mysql_slow.log
```

> centos7 安装:
>
> ```sh
> # 安装依赖
> yum install perl-DBI perl-DBD-MySQL perl-Time-HiRes perl-IO-Socket-SSL
> # 需要科学上网
> wget https://www.percona.com/downloads/percona-toolkit/3.2.1/binary/redhat/7/x86_64/percona-toolkit-3.2.1-1.el7.x86_64.rpm
> ```

```sh
# 分析slow log
pt-query-digest  --type=slowlog /var/log/mysql/mysql_slow.log > /tmp/pt_slow.log
cat /tmp/pt_slow.log

# 分析general log
pt-query-digest  --type=genlog /var/log/mysql/mysql_general.log > /tmp/pt_general.log
cat /tmp/pt_general.log
```

### [innotop](https://github.com/innotop/innotop)

- [MySQL 监控-innotop](https://www.jianshu.com/p/b8508fe10b8e)

这是在用 `mysqlslap` 进行压力测试下的监控

![image](./Pictures/mysql/innotop.avif)
![image](./Pictures/mysql/mysqlslap.avif)

### [dbatool](https://github.com/xiepaup/dbatools)

监控以及查询工具

![image](./Pictures/mysql/dbatools.avif)

### undrop-for-innodb(\*数据恢复)

安装
[MySQL · 数据恢复 · undrop-for-innodb](http://mysql.taobao.org/monthly/2017/11/01/)
[undrop-for-innodb 实测(一)-- 表结构恢复](https://yq.aliyun.com/articles/684377)

```sh
git clone https://github.com/twindb/undrop-for-innodb.git
cd undrop-for-innodb
sudo make install
```

```sh
# 注意:目前还是在undrop-for-innodb
# 生成pages-ibdata1目录,目录下按照每个页为一个文件
stream_parser -f /var/lib/mysql/ibdata1
mkdir -p dumps/default

sudo mysql -uroot -p -e "create database dictionary"
sudo mysql -uroot -p dictionary < dictionary/*.sql

sudo ./sys_parser -uroot -p -d dictionary sakila/actor
```

### [osqueryi](https://github.com/osquery/osquery)

### [mytop](https://github.com/jzawodn/mytop)

### [MyRocks:lsm存储引擎](http://myrocks.io/docs/getting-started/)
