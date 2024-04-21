# mysql

## 安装 MySql

- MySQL主要包含四个部分的程序，分别为：服务器程序、安装程序、实用工具程序，及客户端程序。

- 服务器程序：mysqld

    ```sh
    # 手动启动
    mysqld --user=mysql --datadir=/var/lib/mysql --socket=/tmp/mysql.sock
    ```

- 安装程序：

    - mysql_secure_installation：可以对安全性进行初始化配置
        - 可以改善MySQL服务器的安全性，包括创建root用户的密码、删除root用户的远程访问权限、删除匿名账户，以及删除“test”数据库。注意，该程序主要针对8.0之前版本的MySQL，8.0的安装包内已经包含了上述功能。

    - mysql_tzinfo_to_sql：则可以创建一个包含主机时区信息的SQL语句。

- 实用工具程序：

    - mysql_config_editor：用于管理登录路径，方便用户通过命令行客户端连接MySQL服务器。

        - 可以创建一个加密的选项文件，文件中包含用户的密码及主机的选项，默认产生的文件名称为`.mylogin.cnf`

            - 可以通过设置`MYSQL_TEST_LOGIN_FILE`环境变量的值更改该文件名称
            ```ini
            [adminuser]
            user=root
            password = mysqlroot
            host = 127.0.0.1           
            ```
        ```sh
        # 创建登录路径时，使用如下命令：
        mysql_config_editor set --login-path=login-path --user=username --password --host=hostname

        # 删除登录路径时，使用如下命令；
        mysql_config_editor remove --login-path=login-path

        # 客户端连接MySQL服务器时，使用“--login-path”选项，指定用户名即可进行连接。例如，
        mysql --login-path=adminuser
        ```

    - mysqlbinlog：用于读取和回放二进制日志中的内容。

    - mysqldumpslow：用于读取和总结慢查询日志的内容。

    - mysql_ssl_rsa_setup：用于创建TLS密钥和证书

    - ibd2sdi：用于从InnoDB表空间文件中抽取SDI（serialized dictionary information）

- 客户端程序：

    - mysql：MySQL命令行客户端

    - mysqladmin：用于监视、管理及关闭MySQL

    - mysqldump/mysqlpump：使用SQL语句执行的逻辑备份工具

    - mysqlimport：用于将文件中的数据导入数据库

    - mysqlslap：加载模拟程序

    - mysqlshow：用于显示数据库对象的元数据

    - mysqlcheck：用于检查和优化数据库的表

    - mysqlsh：MySQL的高级命令行客户端及代码编辑器

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

### 升级

- 2023年10月25日，随着MySQL 5.7.44发布，宣告5.7正式停止开发和维护。而不少企业选择把MySQL 5.7升级到8.0。

#### github升级mysql 8.0过程

- GitHub也在去年把MySQL升级到了8.0。[详细的升级过程](https://github.blog/2023-12-07-upgrading-github-com-to-mysql-8-0/)

- 总结一下大致步骤

    - 1.先升级部分副本，然后将部分只读流量切上去，也会保留足够的5.7副本，以方便回滚

    - 2.如果只读流量经过8.0的验证，没问题，就调整复制拓扑为下图形式 

        ![image](./Pictures/mysql/mysql升级-github升级过程.avif)

        - 一个8.0的候选，直接接在5.7主库后面

        - 8.0的从库下游又创建两个复制链

            - 一部分是5.7的从（暂时不提供查询，用来做回滚用的）

            - 另外一部分是8.0的从，用来承担只读查询

    - 3.通过Orchestrator，执行failover将上图MySQL 8.0的从库提升为主。

        - 通过Orchestrator，执行failover将上图MySQL 8.0的从库提升为主。

        - 这个时候，拓扑变成了一个8.0的主，它下游附带了两个复制链组：

            - 一部分是5.7的从（暂时不提供查询，用来做回滚用的）。

            - 另外一部分是8.0的从，用来承担只读查询。

        - 并且Orchestrator还把5.7的主机列为故障转移的黑名单，防止发生切换的时候，又出现5.7的实例提升为主的情况。

    - 4.升级其他用于备份或者非生产的实例

    - 5.如果在8.0的版本下运行了足够长的时间（至少24小时），则把集群内5.7版本的MySQL全删除。

#### [爱可生开源社区：MySQL 5.7 升级到 8.0 可能踩的一个坑](https://mp.weixin.qq.com/s/DLf98FgoE-FbxmETzGnSZw)

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

    - [爱可生开源社区：MySQL 核心模块揭秘 | 10 期 | binlog 怎么写入日志文件？](https://mp.weixin.qq.com/s?__biz=MzU2NzgwMTg0MA==&mid=2247514251&idx=1&sn=98cf7b9fc9c0116327a0154809b92c33&chksm=fc955a14cbe2d302e3d9deb93b5919163612d8b26de98f818ad48adb4e994bea6ac85f6504aa&cur_album_id=3254180525410418690&scene=189#wechat_redirect)

- binlog日志有3种格式，可以通过`binlog_format`参数指定。

    ```sql
    show variables like 'binlog_format';
    +---------------+-------+
    | Variable_name | Value |
    +---------------+-------+
    | binlog_format | ROW   |
    +---------------+-------+
    ```

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

#### 解析binlog

- [爱可生开源社区：MySQL 核心模块揭秘 | 06 期 | 事务提交之前，binlog 写到哪里？](https://mp.weixin.qq.com/s?__biz=MzU2NzgwMTg0MA==&mid=2247513577&idx=1&sn=793b807b72016cb10b3f903720ebf49e&chksm=fc955776cbe2de60fc8f2af8219a2d282d5ffd7de37ba7c2f6d124139dafb3d57d36ea4a4384&cur_album_id=3254180525410418690&scene=189#wechat_redirect)

- 准备工作

    ```sql
    -- 创建测试表
    CREATE TABLE `t_binlog` (
      `id` int unsigned NOT NULL AUTO_INCREMENT,
      `i1` int DEFAULT '0',
      `str1` varchar(32) DEFAULT '',
      PRIMARY KEY (`id`) USING BTREE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

    -- 开启事务，插入数据
    BEGIN;

    INSERT INTO `t_binlog` (`i1`, `str1`)
    VALUES (100, 'MySQL 核心模块揭秘');

    COMMIT;

    -- 查看binlog，我这里为arch.000040
    show binary logs;
    +-------------+-----------+
    | Log_name    | File_size |
    +-------------+-----------+
    | arch.000026 | 2536245   |
    | arch.000027 | 6140778   |
    | arch.000028 | 2162      |
    | arch.000029 | 360       |
    | arch.000030 | 7724      |
    | arch.000031 | 360       |
    | arch.000032 | 13971     |
    | arch.000033 | 1314      |
    | arch.000034 | 379       |
    | arch.000035 | 417       |
    | arch.000036 | 417       |
    | arch.000037 | 417       |
    | arch.000038 | 398       |
    | arch.000039 | 360       |
    | arch.000040 | 953       |
    +-------------+-----------+
    ```

- 解析事务binlog日志

    ```sh
    # 进入binlog的目录
    cd /var/lib/mysql/

    # 解析事务产生的 binlog 日志
    mysqlbinlog  arch.000040 --base64-output=decode-rows -vv
    ```

- 解析事务 binlog 日志之后，我们可以得到 4 个 binlog event。

    - 示例 SQL 中，只有两条 SQL 会产生 binlog event：

        - BEGIN：不会产生 binlog event。
        - INSERT：产生三个 binlog event。
            - Query_log_event。
            - Table_map_log_event。
            - Write_rows_log_event。
        - COMMIT：产生 Xid_log_event。

    - 按照这些 binlog event 在 binlog 日志文件中的顺序，简化之后的内容如下：

    - 1.Query_log_event

        ```sql
        # at 657
        START TRANSACTION
        ```

    - 2.Table_map_log_event

        ```sql
        # at 800
        Table_map: `test`.`t_binlog` mapped to number 57
        ```

    - 3.Write_rows_log_event

        ```sql
        # at 855
        Write_rows: table id 57 flags: STMT_END_F
        ### INSERT INTO `test`.`t_binlog`
        ### SET
        ###   @1=1 /* INT meta=0 nullable=0 is_null=0 */
        ###   @2=100 /* INT meta=0 nullable=1 is_null=0 */
        ###   @3='MySQL 核心模块揭秘' /* VARSTRING(96) meta=96 nullable=1 is_null=0 */
        ```

    - 4.Xid_log_event

        ```sql
        Xid = 31
        COMMIT/*!*/;
        ```

##### binlog cache

- 使用 mysqlbinlog 分析 binlog 日志的时候，可以发现这么一个现象：同一个事务产生的 binlog event，在 binlog 日志文件中是连续的。

- 保证同一个事务的 binlog event 在 binlog 日志文件中的连续性，不管是 MySQL 从库回放 binlog，还是作为用户的我们，都可以很方便的定位到一个事务的 binlog 从哪里开始，到哪里结束。

- 问题：一个事务会产生多个 binlog event，很多个事务同时执行，怎么保证同一个事务产生的 binlog event 写入到 binlog 日志文件中是连续的？
- 解决方法：binlog cache

- 每个事务都有两个 binlog cache：

    - stmt_cache：改变（插入、更新、删除）不支持事务的表，产生的 binlog event，临时存放在这里。
    - trx_cache：改变（插入、更新、删除）支持事务的表，产生的 binlog event，临时存放在这里。

        - 事务执行过程中，产生的所有 binlog event，都会先写入 trx_cache。trx_cache 分为两级：

            - 第一级：内存，也称为 buffer，它的大小用 buffer_length 表示，由系统变量 binlog_cache_size 控制，默认为 32K。
            - 第二级：临时文件，位于操作系统的 tmp 目录下，文件名以 ML 开头。

        - buffer_length 加上临时文件中已经写入的 binlog 占用的字节数，也有一个上限，由系统变量 max_binlog_cache_size 控制。

##### 产生 binlog

- 如果一条 SQL 语句改变了（插入、更新、删除）表中的数据，server 层会为这条 SQL 语句产生一个包含表名和表 ID 的 Table_map_log_event。

- 每次调用存储引擎的方法写入一条记录到表中之后，server 层都会为这条记录产生 binlog。

    - 这里没有写成 binlog event，是因为记录中各字段内容都很少的时候，多条记录可以共享同一个 binlog event ，并不需要为每条记录都产生一个新的 binlog event。

        - 这个 binlog event 最多可以存放多少字节的内容，由系统变量 `binlog_row_event_max_size` 控制
            ```sql
            -- 默认为 8192 字节。
            select @@binlog_row_event_max_size
            +-----------------------------+
            | @@binlog_row_event_max_size |
            +-----------------------------+
            | 8192                        |
            +-----------------------------+
            ```

        - 如果一条记录产生的 binlog 超过了 8192 字节，它的 binlog 会独享一个 binlog event，这个 binlog event 的大小就不受系统变量 `binlog_row_event_max_size` 控制了。


- 在 binlog 日志文件中

    - 那么，第一步就要为这个事务初始化 binlog cache，包括 stmt_cache 和 trx_cache。初始化完成之后，这两个 cache 都是空的。

        - 事务执行过程中，所有 binlog event 都会先写入 trx_cache 的 buffer，buffer 大小默认为 32K。

    - 1.Query_log_event 为 BEGIN 语句的binlog event。
    - 2.Table_map_log_event 位于 SQL 语句改变表中数据产生的 binlog event 之前。
    - 3.Write_rows_log_event 是插入记录对应的 binlog event
    - 4.Xid_log_event 是 COMMIT 语句时，会产生的binlog event ，并写入 trx_cache。


- trx_cache 分为两级：内存（buffer）、临时文件。


- 写入一个 binlog event 到 trx_cache 的流程：

    - 判断 buffer 剩余空间是否足够写入这个 binlog event。
    - 如果足够，直接把 binlog event 写入 buffer，流程结束。
    - 如果不够，用 binlog event 前面的部分内容填满 buffer，然后，把 buffer 中所有内容写入临时文件，再清空 buffer，以备复用。
    - 接着判断 binlog event 剩余内容是否大于等于 4096 字节（IO_SIZE）。
    - 如果剩余内容大于等于 4096 字节，则把剩余内容前面的 N * 4096 字节写入临时文件。
    - 对于剩余内容字节数不能被 4096 整除的情况，最后还会剩下不足 4096 字节的内容，这部分内容会写入 buffer。
    - 如果剩余内容小于 4096 字节，直接把 binlog event 中剩余的所有内容都写入 buffer。

#### 二阶段提交

- [爱可生开源社区：MySQL 核心模块揭秘 | 07 期 | 二阶段提交 (1) prepare 阶段](https://mp.weixin.qq.com/s?__biz=MzU2NzgwMTg0MA==&mid=2247513770&idx=1&sn=d7cf4c9ba5acafbe33fab85219692d0b&chksm=fc955435cbe2dd2374ed1d72c332cff16f1d9c10ff8ed01f450d7fa44c4d1f3df7035f00dcef&cur_album_id=3254180525410418690&scene=189#wechat_redirect)

- 二阶段提交是一种用于保证分布式事务原子性的协议。

- 二阶段提交：

    - prepare 阶段：写binlog、redo log
    - commit 阶段：把binlog、redo log刷盘

- MySQL 把 binlog 也看作一个存储引擎，开启 binlog，SQL 语句改变（插入、更新、删除）InnoDB 表的数据，这个 SQL 语句执行过程中，就涉及到两个存储引擎。

    - 使用二阶段提交，就是为了保证2个存储引擎的数据一致性。

        - 如果没有开启 binlog，SQL 语句改变表中数据，不产生 binlog，不用保证 binlog 和表中数据的一致性，用户事务也就不需要使用二阶段提交了。

- 用户事务提交分为2种场景，如果开启了 binlog，它们都会使用二阶段提交。

    - 1.通过 BEGIN 或其它开始事务的语句，显式开始一个事务，用户手动执行 COMMIT 语句提交事务。

    - 2.没有显式开始的事务，一条 SQL 语句执行时，InnoDB 会隐式开始一个事务，SQL 语句执行完成之后，自动提交事务。

- prepare 阶段
    - binlog prepare阶段：什么也不会干
    - InnoDB prepare阶段：主要做五件事

        - 1.把分配给事务的所有 undo 段的状态从 TRX_UNDO_ACTIVE 修改为 TRX_UNDO_PREPARED

            - 进入二阶段提交的事务，都至少改变过（插入、更新、删除）一个用户表的一条记录，最少会分配 1 个 undo 段，最多会分配 4 个 undo 段。

            - 意义：如果数据库发生崩溃，重新启动后，undo 段的状态是影响事务提交还是回滚的因素之一。

        - 2.把事务 Xid 写入所有 undo 段中当前提交事务的 undo 日志组头信息。
            - InnoDB 给当前提交事务分配的每个 undo 段中，都会有一组 undo 日志属于这个事务，事务 Xid 就写入 undo 日志组的头信息。

        - 对于第 1、2 件事，如果事务改变了用户普通表的数据，修改 undo 段状态、把事务 Xid 写入 undo 日志组头信息，都会产生 redo 日志。

        - 3.把内存中的事务对象状态从 TRX_STATE_ACTIVE 修改为 TRX_STATE_PREPARED。
            - 前面修改 undo 状态，是为了事务提交完成之前，MySQL 崩溃了，下次启动时，能够从 undo 段中恢复崩溃之前的事务状态。

            - 这里修改事务对象状态，用于 MySQL 正常运行过程中，标识事务已经进入二阶段提交的 prepare 阶段。

        - 4.如果当前提交事务的隔离级别是读未提交（READ-UNCOMMITTED）或读已提交（READ-COMMITTED)，InnoDB 会释放事务给记录加的共享、排他 GAP 锁。
            - 虽然读未提交、读已提交隔离级别一般都只加普通记录锁，不加 GAP 锁，但是，外键约束检查、插入记录重复值检查这两个场景下，还是会给相应的记录加 GAP 锁。

        - 5.调用 trx_flush_logs()，处理 事务产生的 redo 日志刷盘的相关逻辑。

- 二阶段提交的 commit 阶段，分为三个子阶段。

    - 1.flush 子阶段，要干两件事：

        - 1.触发操作系统把 prepare 阶段及之前产生的 redo 日志刷盘。

            - 事务执行过程中，改变（插入、更新、删除）表中数据产生的 redo 日志、prepare 阶段修改 undo 段状态产生的 redo 日志，都会由后台线程先写入 page cache，再由操作系统把 page cache 中的 redo 日志刷盘。

            - 等待操作系统把 page cache 中的 redo 日志刷盘，这个时间存在不确定性，InnoDB 会在需要时主动触发操作系统马上把 page cache 中的 redo 日志刷盘。

        - 2.把事务执行过程中产生的 binlog 日志写入 binlog 日志文件。

            - 这个写入操作，也是先写入 page cache，至于操作系统什么时候把 page cache 中的 binlog 日志刷盘，flush 子阶段就不管了。

    - 2.sync 子阶段，根据系统变量 sync_binlog 的值决定是否要触发操作系统马上把 page cache 中的 binlog 日志刷盘。

    - 3.commit 子阶段，完成 InnoDB 的事务提交。

- 组提交与重复刷盘

    - 小事务：TP 场景，比较常见的情况是事务只改变（插入、更新、删除）表中少量数据，产生的 redo 日志、binlog 日志也比较少。

    - 以redo 日志为例，binlog 日志也有同样的问题。一个事务产生的 redo 日志少，操作系统的一个页就有可能存放多个事务产生的 redo 日志。

    - 问题：如果每个事务提交时都把自己产生的 redo 日志刷盘，共享操作系统同一个页存放 redo 日志的多个事务，就会触发操作系统把这个页多次刷盘。
        - 数据库闲的时候，把操作系统的同一个页多次刷盘，也没啥问题，反正磁盘闲着也是闲着。
        - 数据库忙的时候，假设某个时间点有 1 万个小事务要提交，每 10 个小事务共享操作系统的一个页用于存放 redo 日志，总共需要操作系统的 1000 个页。
            - 1 万个事务各自提交，就要触发操作系统把这 1000 个数据页刷盘 10000 次。


    - 解决方法：组提交。某个时间点提交的多个事务触发操作系统的同一个页重复刷盘。这样一来，1000 个数据页，只刷盘 1000 次就可以了，刷盘次数只有原来的十分之一。

        - 组提交，就是把一组事务攒到一起提交，InnoDB 使用队列把多个事务攒到一起。

        - commit 阶段的 3 个子阶段都有自己的队列，分别为 flush 队列、sync 队列、commit 队列。
            - 每个队列都会选出一个队长，负责管理这个队列，选队长的规则很简单，先到先得。

            - 对于每个队列，第一个加入该队列的用户线程就是队长，第二个及以后加入该队列的都是队员。
                - 队长要多干活：每个子阶段的队长，都会把自己和所有队员在对应子阶段要干的事全都干了。队员只需要在旁边当吃瓜群众就好。
                - 以 flush 子阶段为例
                    - 1.我们假设 flush 队列的队长为 A 队长，A 队长收编一些队员之后，它会带领这帮队员从 flush 队列挪走，并且开始给自己和所有队员干活，队员们就在一旁当吃瓜群众。
                    - 2.A 队长带领它的队员挪走之后，flush 队列就变成空队列了。
                    - 3.接下来第一个进入 flush 队列的用户线程，又成为下一组的队长，我们称它为 B 队长。
                    - 4.A 队长正在干活，还没干完呢。B 队长收编了一些队员之后，也带领这帮队员从 flush 子阶段的队列挪走，并且也要开始给自己和所有队员干活了。

                    - 如果 A 队长和 B 队长都把自己和各自队员产生的 binlog 日志写入 binlog 日志文件，相互交叉写入，那是会出乱子的。

                        - 为了避免 flush 子阶段出现两个队长同时干活导致出乱子，InnoDB 给 flush 子阶段引入了一个互斥量，名字是 LOCK_log。

                        - sync 子阶段、commit 子阶段也需要避免出现多个队长同时干活的情况，这两个子阶段也有各自的互斥量，分别是 LOCK_sync、LOCK_commit。

- [爱可生开源社区：MySQL 核心模块揭秘 | 08 期 | 二阶段提交 (2) commit 阶段](https://mp.weixin.qq.com/s?__biz=MzU2NzgwMTg0MA==&mid=2247513864&idx=1&sn=9896ca5bd7cf5d775ee9cb8c65a9ab6c&chksm=fc955597cbe2dc811614bf1d1281831d9e1cb8b04df43127aa43f25bf7f2ef94f341d5e9da20&cur_album_id=3254180525410418690&scene=189#wechat_redirect)

    - 简单总结：

        - 1.flush 子阶段，flush 队长会把自己和队员在 prepare 阶段及之前产生的 redo 日志都刷盘，把事务执行过程中产生的 binlog 日志写入 binlog 日志文件。

        - 2.sync 子阶段，如果 sync_counter + 1 大于等于系统变量 max_binlog_size 的值，sync 队长会把 binlog 日志刷盘。

        - 3.commit 子阶段，如果系统变量 binlog_order_commits 的值为 true，commit 队长会把自己和队员们的 InnoDB 事务都提交，否则，commit 队长和队员各自提交自己的 InnoDB 事务。


    - 例子：假设有 30 个事务，它们对应的用户线程编号也从 1 到 30

    - 1.flush 子阶段

        - 用户线程 16 加入 flush 队列，成为 flush 队长，并且通过申请获得 LOCK_log 互斥量。

        - flush 队长收编用户线程 17 ~ 30 作为它的队员，队员们进入 flush 队列之后，就开始等待，收到 commit 子阶段的队长发来的通知才会结束等待。

        - flush 队长开始干活之前，会带领它的队员从 flush 队列挪出来，给后面进入二阶段提交的其它事务腾出空间。

        - 从 flush 队列挪出来之后，flush 队长会触发操作系统，把截止目前产生的所有 redo 日志都刷盘。
            - 这些 redo 日志，当然就包含了它和队员们在 prepare 阶段及之前产生的所有 redo 日志了。

            - 触发 redo 日志刷盘之后，flush 队长会从它自己开始，把它和队员们产生的 binlog 日志写入 binlog 日志文件。

        - 以队长为例，写入过程是这样的：

            - 从事务对应的 trx_cache 中把 binlog 日志读出来，存放到 trx_cache 的内存 buffer 中。
                - 每次读取 4096（对应代码里的 IO_SIZE）字节的 binlog 日志，最后一次读取剩余的 binlog 日志（小于或等于 4096 字节）。

            - 把 trx_cache 内存 buffer 中的 binlog 日志写入 binlog 日志文件。


        - 队员们产生的 binlog 日志写入 binlog 日志文件的过程，和队长一样。队长把自己和所有队员产生的 binlog 日志都写入 binlog 日志文件之后，flush 子阶段的活就干完了。

            - flush 队长写完 binlog 日志之后，如果发现 binlog 日志文件的大小大于等于系统变量 max_binlog_size 的值（默认为 1G），会设置一个标志（rotate = true），表示需要切换 binlog 日志文件。后面 commit 子阶段会用到。

    - 2.sync 子阶段

        - 假设用户线程 6 ~ 15 此刻还在 sync 队列中，用户线程 6 最先进入队列，是 sync 队长，用户线程 7 ~ 15 都是队员。

        - 用户线程 16（flush 队长）带领队员们来到 sync 子阶段，发现 sync 队列中已经有先行者了。
            - 有点遗憾，用户线程 16 不能成为 sync 子阶段的队长，它和队员们都会变成 sync 子阶段的队员。
            - 此时，用户线程 6 是 sync 队长，用户线程 7 ~ 30 是队员。
            - 进入 sync 子阶段之后，用户线程 16（flush 队长）会释放它在 flush 子阶段获得的 LOCK_log 互斥量，flush 子阶段下一屇的队长就可以获得 LOCK_log 互斥量开始干活了。

        - sync 队长会申请 LOCK_sync 互斥量，获得互斥量之后，就开始准备给自己和队员们干 sync 子阶段的活了。
            - 队员们依然在一旁当吃瓜群众，等待 sync 队长给它们干活。它们会一直等待，收到 commit 子阶段的队长发来的通知才会结束等待。

        - 就在 sync 队长准备甩开膀子大干一场时，它发现前面还有一个关卡：本次组提交能不能触发操作系统把 binlog 日志刷盘。 sync 队长怎么知道自己能不能过这一关？

            - 它会查看一个计数器的值（sync_counter），如果 sync_counter + 1 大于等于系统变量 `sync_binlog` 的值，就说明自己可以过关。

                - sync_counter：

                    - sync_counter 的值从 0 开始，某一次组提交的 sync 队长没有过关，不会触发操作系统把 binlog 日志刷盘，sync_counter 就加 1。

                    - sync_counter 会一直累加，直到后续的某一次组提交，sync_counter + 1 大于等于系统变量 sync_binlog 的值，sync 队长会把 sync_counter 重置为 0，并且触发操作系统把 binlog 日志刷盘。接着又会开始一个新的轮回。

                - 如果 sync 队长不过关了：用户线程 6 作为队长的 sync 子阶段就到此结束了，它什么都不用干。

                - 如果 sync 队长过关了：

                    - sync 队长会带领队员们继续在 sync 队列中等待，以收编更多队员。这个等待过程是有期限的，满足以下两个条件之一，就结束等待：

                        - 已经等待了系统变量 binlog_group_commit_sync_delay 指定的时间（单位：微妙），默认值为 0。
                        - sync 队列中的用户线程数量（sync 队长和所有队员加在一起）达到了系统变量 binlog_group_commit_sync_no_delay_count 的值，默认值为 0。

                    - 等待结束之后，sync 队长会带领队员们从 sync 队列挪出来，给后面进入二阶段提交的其它事务腾出空间。

            - 接下来，sync 队长终于可以大干一场了，它会触发操作系统把 binlog 日志刷盘，确保它和队员们产生的 binlog 日志写入到磁盘上的 binlog 日志文件中。
                - 这样即使服务器突然异常关机，binlog 日志也不会丢失了。

            - 刷盘完成之后，用户线程 6 作为队长的 sync 子阶段，就到此结束。

    - 3.commit 子阶段

        - 假设用户线程 1 ~ 5 此刻还在 commit 队列中，用户线程 1 最先进入队列，是 commit 队长，用户线程 2 ~ 5 都是队员。

            - 用户线程 6（sync 队长）带领队员们来到 commit 子阶段，发现 commit 队列中也已经有先行者了。

            - 用户线程 6 和队员们一起，都变成了 commit 子阶段的队员。

        - 此刻，用户线程 1 是 commit 队长，用户线程 2 ~ 30 是队员。

        - 进入 commit 子阶段之后，用户线程 6（sync 队长）会释放它在 sync 子阶段获得的 LOCK_sync 互斥量，sync 子阶段下一屇的队长就可以获得 LOCK_sync 互斥量开始干活了。

        - commit 队长会申请 LOCK_commit 互斥量，获得互斥量之后，根据系统变量 binlog_order_commits 的值决定接下来的活要怎么干。

            - 值为true：commit 队长会把它和队员们的 InnoDB 事务逐个提交，然后释放 LOCK_commit 互斥量。

                - 提交 InnoDB 事务完成之后，commit 队长会通知它的队员们（用户线程 2 ~ 30）：所有活都干完了，你们都散了吧，别围观了，该干啥干啥去。

                - 队员们收到通知之后，作鸟兽散，它们的二阶段提交也都结束了。

            - 值为false：commit 队长不会帮助队员们提交 InnoDB 事务，它提交自己的 InnoDB 事务之后，就会释放 LOCK_commit 互斥量。

                - 然后，通知所有队员（用户线程 2 ~ 30）：flush 子阶段、sync 子阶段的活都干完了，你们自己去提交 InnoDB 事务。

                - 队员们收到通知之后，就各自提交自己的 InnoDB 事务，谁提交完成，谁的二阶段提交就结束了。

        - 最后，commit 队长还要处理最后一件事。

            - 如果用户线程 16（flush 队长）把 rotate 设置为 true 了，说明 binlog 日志文件已经达到了系统变量 max_binlog_size 指定的上限，需要切换 binlog 日志文件。

            - 切换指的是关闭 flush 子阶段刚写入的 binlog 日志文件，创建新的 binlog 日志文件，以供后续事务提交时写入。

            - 如果需要切换 binlog 日志文件，切换之后，还会根据系统变量 binlog_expire_logs_auto_purge、binlog_expire_logs_seconds、expire_logs_days 清理过期的 binlog 日志。

            - 处理完切换 binlog 日志文件的逻辑之后，commit 队长的工作就此结束，它的二阶段提交就完成了。

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

#### [binlog2sql](https://github.com/danfengcao/binlog2sql)

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

#### [一树一溪：Redo 日志从产生到写入日志文件](https://mp.weixin.qq.com/s/kMdD7jUaouWnHxjdmKSV4A)

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

### undo log（回滚日志）


- redo 日志只有崩溃恢复的时候才能派上用场，undo 日志不一样，它承担着多重职责，MySQL 崩溃恢复、以及正常提供服务期间，都有它的身影。

    - 职责 1：为 MVCC 服务，减少读写事务之间的相互影响，提升数据库的并发能力。
    - 职责 2：保证数据库运行过程中的数据一致性。事务回滚时，把事务中被修改的数据恢复到修改之前的状态。
    - 职责 3：保证数据库崩溃之后的数据一致性。崩溃恢复过程中，恢复没有完成提交的事务，并根据事务的状态和 binlog 日志是否写入了该事务的 xid 信息，共同决定事务是提交还是回滚。

- undo log 逻辑日志：
    - 事务未提交的时候,所有事务进行的修改都会先先记录到这个回滚日志中，并持久化到磁盘上。
    - 系统崩溃时，没 COMMIT 的事务 ，就需要借助 undo log 来进行回滚至事务开始前的状态。
    - 保存在`ibdata*`

- undo 日志序号
    - 事务每次改变（插入、更新、删除）某个表的一条记录，都会产生一条 undo 日志。这条 undo 日志中会存储它自己的序号。
    - 每个事务都维护着各自独立的 undo 日志序号，和其它事务无关。
    - InnoDB 的 savepoint 结构中会保存创建 savepoint 时事务对象的 undo_no 属性值。

### undo log的存储结构

- undo 日志需要为数据一致性和 MVCC 服务，除了要支持多事务同时写入日志，还要支持多事务同时读取日志。

    - 为了有更好的读写并发性能，它拥有与 redo 日志完全不一样的存储结构。

- 存储结构

    ![image](./Pictures/mysql/undo-log-存储结构.avif)

    - 以下的undo log组成部分，从下（被管理）往上（管理）讲

    - undo log header：一个事务可能产生多条 undo 日志，也可能只产生一条 undo 日志，不管事务产生了多少条 undo 日志，这些日志都归属于事务对应的日志组，日志组由 undo log header 负责管理。

    - undo 页：undo log header 和 undo 日志都存储于 undo 页中。

    - undo 段：为了多个事务同时写 undo 日志不相互影响，undo 日志也使用了无锁设计，InnoDB 会为每个事务分配专属的 undo 段，每个事务只会往自己专属 undo 段的 undo 页中写入日志。

        - 一个 undo 段可能会包含一个或多个 undo 页，多个 undo 页会形成 undo 页面链表。

        - inode：每个 undo 段都会关联一个 inode。undo 段本身并不具备管理 undo 页的能力，有了 inode 这个外挂之后，undo 段就可以管理段中的 undo 页了。

    - 回滚段：一个回滚段管理着 1024 个 undo 段

        - 每个回滚段的段头页中都有 1024 个小格子，用来记录 undo 段中第一个 undo 页的页号，这个小格子就叫作 undo slot。

        - 一个事务可能会需要 1 ~ 4 个 undo 段

    - undo 表空间：一个 undo 表空间最多可以支持 128 个回滚段。

        - 假设每个事务都只需要 1 个 undo 段，如果只有一个回滚段也只能支持 1024 个事务同时执行。对于拥有几十核甚至百核以上 CPU 的服务器来说，这显然会限制它们的发挥。

        - InnoDB 还能够最多支持 127 个 undo 表空间，这样算起来，所有回滚段总共能够管理的 undo 段数量是：1024 * 128 * 127 = 16646144。

- [详情请看。一树一溪：Undo 日志用什么存储结构支持无锁并发写入？](https://mp.weixin.qq.com/s/pzVMnsOPpAqxbttaTuwWnQ)

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

            - [（视频）小白debug：为什么说mysql数据库单表最大两千万？依据是啥？](https://www.bilibili.com/video/BV13s4y1N724)

##### [爱可生开源社区：第14期：数据页合并](https://mp.weixin.qq.com/s?__biz=MzU2NzgwMTg0MA==&mid=2247489731&idx=1&sn=6409bf468cf064b92f571050973cb59d&chksm=fc96fa5ccbe1734ad22601557ad09041129d66e4a422deea2f1fe7a2232e125cb8e9c839e5b5&cur_album_id=1338281900976472064&scene=189#wechat_redirect)

- MySQL InnoDB 表数据页或者二级索引页（简称数据页或者索引页）的合并与分裂对 InnoDB 表整体性能影响很大；数据页的这类操作越多，对 InnoDB 表数据写入的影响越大。

- MySQL 提供了一个数据页合并临界值`MERGE_THRESHOLD`，在某些场景下，可以人为介入，减少数据页的合并与分裂。

- 在 InnoDB 表里，每个数据页默认16K 大小，默认 MERGE_THRESHOLD 值为 50，取值范围从 1 到 50，默认值即是最大值。
    - 也就是当页面记录数占比小于 50% 时，MySQL 会把这页和相邻的页面进行合并，保证数据页的紧凑，避免太多浪费。
    - 当然，设置成最小值 1，基本上不会合并了。

- 触发临界值场景
    - 1.页 A 里本来数据占用 100%，有一部分记录被删掉后，数据占用小于 50%，刚好触发了临界值。
    - 2.页 B 里存放的记录被更新为更短的形式，比如记录值由 rpad（'我爱你们所有人' , 10000, '添加冗余字符'）变为 '我只爱你' ，这时候记录对数据页占用也小于 50%，刚好触发了临界值。

- 简述数据页的合并：
    - 页 A 在删除一些记录后，此页里剩余记录对页 A 的占用小于 MERGE_THRESHOLD 设定的值，此时刚好页 A 相邻的一个页 C，数据占用也不到 50%，这时候 MySQL 会把页 C 的记录并入页 A，之后页 C 的空间就被释放，不包含任何数据，页 C 就可用于以后新记录的写入，避免空间的浪费。

- 简述数据页的分裂：

    - 页 D 和页 E，两个页面记录占用都在 49%。那么页合并后，页 D 记录占用 98%，只剩下 2%。
    - 此时有新的插入请求过来，这条记录的主键刚好在页 D 和页 F 之间，可是页 D 和页 F 都只剩下 2% 的空间，不够插入这条记录。
    - 那怎么办？此时只能拆分页 D。建立一个新的页 I，完了把页 D 原来的记录和新插入的记录做一个排序，再按照新的顺序把页 D 填满，剩下的数据放到页 I。
    - 所以页分裂会涉及到老页数据的迁移到新建页的建立，如果页的分裂频繁，那开销很大。

- `MERGE_THRESHOLD`

    ```sql
    -- 对整张表设置 MERGE_THRESHOLD，需要把这个值放入表的 comment 中。
    -- 注意！MERGE_THRESHOLD 不能小写，必须大写！小写就会被 MySQL 当作简单的注释。
    CREATE TABLE sample1(
        id INT PRIMARY KEY, r1 INT, r2 VARCHAR(1000)
    ) COMMENT 'MERGE_THRESHOLD=40';

    -- 针对之前的表更改 MERGE_THRESHOLD 值
    ALTER TABLE t1 comment 'MERGE_THRESHOLD=40'

    -- 对单个索引列设置 MERGE_THRESHOLD 值，单个列的 MERGE_THRESHOLD 优先级比表高，也就是会覆盖掉表的设置。
    CREATE TABLE t1(
        id INT, KEY idx_id(id) COMMENT 'MERGE_THRESHOLD=40'
    );

    -- 或者先删除索引，再建立新的。
    ALTER TABLE t1 DROP key idx_id, ADD KEY idx_id(id) COMMENT 'MERGE_THRESHOLD=40';
    -- 创建索引时，设置MERGE_THRESHOLD
    CREATE INDEX idx_id ON t1(id) COMMENT 'MERGE_THRESHOLD=40';
    ```

- MERGE_THRESHOLD 设置效果评估

    - innodb_metrics 表提供了两个计数器来跟踪页合并

    ```sql
    -- 这两个计数器默认是屏蔽的，需要显式开启，
    SELECT NAME, COMMENT FROM INFORMATION_SCHEMA.INNODB_METRICS
    WHERE NAME like '%index_page_merge%';
    +-----------------------------+----------------------------------------+
    | NAME                        | COMMENT                                |
    +-----------------------------+----------------------------------------+
    | index_page_merge_attempts   | Number of index page merge attempts    |
    | index_page_merge_successful | Number of successful index page merges |
    +-----------------------------+----------------------------------------+

    -- 开启这两个计数器
    SET GLOBAL innodb_monitor_enable='index_page_merge_attempts';
    SET GLOBAL innodb_monitor_enable='index_page_merge_successful';
    ```

    - 建立两张表：MERGE_THRESHOLD 分别为默认值（50）和 20。导入同样的 5000 条记录，看看页面合并的对比。

        ```sql
        CREATE TABLE t1_max(
            id INT PRIMARY KEY, r1 INT, KEY idx_r1 (r1)
        );
        CREATE TABLE t1_min(
            id INT, PRIMARY KEY (id) COMMENT 'MERGE_THRESHOLD=20', r1 INT, KEY idx_r1 (r1)
        );
        ```

    - t1_max表性能测试
        ```sql
        -- 对比前，先清空计数器；禁止后；重置计数器。
        SET GLOBAL innodb_monitor_disable='index_page_merge_attempts';
        SET GLOBAL innodb_monitor_disable='index_page_merge_successful';
        SET GLOBAL innodb_monitor_reset_all='index_page_merge_attempts';
        SET GLOBAL innodb_monitor_reset_all='index_page_merge_successful';
        SET GLOBAL innodb_monitor_enable='index_page_merge_attempts';
        SET GLOBAL innodb_monitor_enable='index_page_merge_successful';

        -- 确认计数器为0
        SELECT name,count,max_count,avg_count  FROM INFORMATION_SCHEMA.INNODB_METRICS WHERE NAME like '%index_page_merge%';
        +-----------------------------+-------+-----------+-----------+
        | name                        | count | max_count | avg_count |
        +-----------------------------+-------+-----------+-----------+
        | index_page_merge_attempts   | 0     | <null>    | 0.0       |
        | index_page_merge_successful | 0     | <null>    | 0.0       |
        +-----------------------------+-------+-----------+-----------+

        -- 先往表 t1_max 里随机插入 5000 条记录。执行5000次INSERT INTO t1_max (id, r1) VALUE (v_counter, v_counter);
        DELIMITER $$

        CREATE PROCEDURE InsertRandomData()
        BEGIN
          DECLARE v_max INT DEFAULT 5000;
          DECLARE v_counter INT DEFAULT 1;

          WHILE v_counter <= v_max DO
            INSERT INTO t1_max (id, r1) VALUE (v_counter, v_counter);
            SET v_counter = v_counter + 1;
          END WHILE;
        END$$

        DELIMITER ;

        -- 执行
        CALL InsertRandomData();

        -- 查看行数
        SELECT COUNT(*) FROM t1_max;
        +----------+
        | COUNT(*) |
        +----------+
        | 5000     |
        +----------+

        -- 再删掉 2500 条记录
        DELETE FROM t1_max LIMIT 2500;

        -- 查看计数器结果。尝试合并 472 次，合并成功 7 次。
        SELECT name,count,max_count,avg_count  FROM INFORMATION_SCHEMA.INNODB_METRICS WHERE NAME like '%index_page_merge%';
        +-----------------------------+-------+-----------+------------+
        | name                        | count | max_count | avg_count  |
        +-----------------------------+-------+-----------+------------+
        | index_page_merge_attempts   | 2739  | 2739      | 18.5068    |
        | index_page_merge_successful | 7     | 7         |  0.0472973 |
        +-----------------------------+-------+-----------+------------+
        ```

    - t1_min表性能测试
        ```sql
        -- 清空计数器
        SET GLOBAL innodb_monitor_disable='index_page_merge_attempts';
        SET GLOBAL innodb_monitor_disable='index_page_merge_successful';
        SET GLOBAL innodb_monitor_reset_all='index_page_merge_attempts';
        SET GLOBAL innodb_monitor_reset_all='index_page_merge_successful';
        SET GLOBAL innodb_monitor_enable='index_page_merge_attempts';
        SET GLOBAL innodb_monitor_enable='index_page_merge_successful';

        -- 删除刚才存储过程
        DROP PROCEDURE InsertRandomData
        -- 往表 t1_min 里随机插入 1000 条记录。执行1000次INSERT INTO t1_min (id, r1) VALUE (v_counter, v_counter);
        DELIMITER $$

        CREATE PROCEDURE InsertRandomData()
        BEGIN
          DECLARE v_max INT DEFAULT 5000;
          DECLARE v_counter INT DEFAULT 1;

          WHILE v_counter <= v_max DO
            INSERT INTO t1_min (id, r1) VALUE (v_counter, v_counter);
            SET v_counter = v_counter + 1;
          END WHILE;
        END$$

        DELIMITER ;

        -- 执行
        CALL InsertRandomData();

        -- 再删掉 2500 条记录
        DELETE FROM t1_min LIMIT 2500;

        -- 查看计数器结果。比默认的合并次数有所减少
        SELECT name,count,max_count,avg_count  FROM INFORMATION_SCHEMA.INNODB_METRICS WHERE NAME like '%index_page_merge%';
        +-----------------------------+-------+-----------+------------+
        | name                        | count | max_count | avg_count  |
        +-----------------------------+-------+-----------+------------+
        | index_page_merge_attempts   | 1855  | 1855      | 25.0676    |
        | index_page_merge_successful | 5     | 5         |  0.0675676 |
        +-----------------------------+-------+-----------+------------+

        -- 当然，设置成最小值 1，基本上不会合并了
        ```

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

##### 事务详解

- [爱可生开源社区：第 01 期 [事务] 事务的起源：事务池和管理器的初始化](https://mp.weixin.qq.com/s?__biz=MzU2NzgwMTg0MA==&mid=2247513012&idx=1&sn=8f9c1355822d8e1865ea854da8e8c66f&chksm=fc95512bcbe2d83d6b4afad772e607600ee7fd98a8faa4364d33fb68e0763a71ce28c059a993&scene=21#wechat_redirect)

- MySQL 被设计为支持高并发，支持很多客户端同时连接到数据库，这些连接可以同时执行 SQL。

    - 如果这些 SQL 都要读写 InnoDB 表，InnoDB 会为每个连接启动一个事务，这意味着需要同时启动很多事务。

- 对于 OLTP 场景，通常情况下，事务都会很快执行完成。启动事务、执行 SQL、提交事务的整个流程只会持续很短的时间。

- 以这样一个场景为例：
    - 客户端连接到 MySQL。
    - 客户端执行 begin 语句。
    - 客户端执行一条 update 语句，按主键 ID 更新一条记录。
    - 这个步骤中，InnoDB 会在执行 update 语句之前，真正启动一个事务。
    - 客户端执行 commit 语句。
    - 客户端关闭数据库连接。InnoDB 会在这一步释放事务。

    - 在这个场景下，InnoDB 事务从启动到释放的整个生命周期，有可能只持续 1 ~ 2 毫秒（甚至更短）。

- 事务池（Pool）

    - 由于要存放事务 ID、事务状态、Undo 日志编号、事务所属的用户线程等信息，每个事务都有一个与之对应的对象，我们称之为事务对象。

    - 每个事务对象都要占用内存，如果每启动一个事务都要为事务对象分配内存，释放事务时又要释放内存，会降低数据库性能。

    - 为了避免频繁分配、释放内存对数据库性能产生影响，InnoDB 引入了事务池（Pool），用于管理事务。

- 事务池管理器（PoolManager）

    - 事务池也一样有大小限制，不能无限制的存放事务对象。数据库繁忙的时候，有很多很多事务对象，需要多个事务池来管理。

    - 事务池多了之后，又会引发另一些问题，例如： 怎么创建新的事务池？ 客户端创建了一个新的数据库连接，要获取一个新的事务对象，从哪个事务池获取？等
        - 为了解决这些问题，InnoDB 又引入了事务池管理器（PoolManager），用于管理事务池。

- MySQL 启动过程中，InnoDB 先创建事务池管理器，然后，事务池管理器创建并初始事务池。

    - 事务池的初始化，主要是为了得到一些事务对象。

    - 事务池有一个队列，用于存放已经初始化的事务对象。我们称这个队列为事务队列。

    - 创建事务池的过程中，InnoDB 会分配一块 4M 的内存用于存放事务对象。

        - 每个事务对象的大小为 992 字节，4M 内存能够存放 4194304 / 992 = 4228 个事务对象。

    - InnoDB 初始化事务池的过程中，不会初始化全部的 4228 块小内存，只会初始化最前面的 16 块小内存，得到 16 个事务对象并放入事务队列。

    - 那么，剩余的 4212 块小内存什么时候会被初始化？

        - 它们会在这种情况下被初始化：启动过程中初始化的 16 个事务对象都被取走使用了，事务队列变成空队列了。

        - 此时，需要再分配一个事务对象用于启动新事务，InnoDB 就会把剩余的 4212 块小内存全部初始化，得到 4212 个事务对象并放入事务队列。

- `BEGIN` 语句都干什么了？

    - 提交老事务

        - 例子：
            - 在 MySQL 客户端命令行（mysql）中，我们通过 BEGIN 语句开始了一个事务（事务 1），并且已经执行了一条 INSERT 语句。
            - 事务 1 还没有提交（即处于活跃状态），我们在同一个连接中又执行了 BEGIN 语句，事务 1 会发生什么？
            - 答案是：事务 1 会被提交。
            - 原因是：MySQL 不支持嵌套事务。事务 1 没有提交的情况下，又要开始一个新事务，事务 1 将无处安放，只能被动提交了。

    - 准备新事务

        - 启动事务也需要分配资源，遵循不铺张浪费的原则，BEGIN 语句执行过程中，并不会马上启动一个新事务，只会为新事务做一点点准备工作（给当前连接的线程打上 OPTION_BEGIN 标志）。

            ```c
            thd->variables.option_bits |= OPTION_BEGIN;
            ```

        - 语句 1 ~ 5 都不会马上启动新事务，只会给执行这些语句的线程打上 OPTION_BEGIN 标记，在这之后执行第一条 SQL 时，才会真正的启动事务。

                ```sql
                /* 1 */ BEGIN
                /* 2 */ BEGIN WORK
                /* 3 */ START TRANSACTION
                /* 4 */ START TRANSACTION READ WRITE
                /* 5 */ START TRANSACTION READ ONLY
                /* 6 */ START TRANSACTION WITH CONSISTENT SNAPSHOT
                /* 7 */ START TRANSACTION WITH CONSISTENT SNAPSHOT, READ WRITE
                /* 8 */ START TRANSACTION WITH CONSISTENT SNAPSHOT, READ ONLY
                ```

        - 有了 OPTION_BEGIN 标志，MySQL 就不会每次执行完一条 SQL 语句就提交事务，而是需要用户发起 commit 语句才提交事务，这样的事务就可以执行多条 SQL 了。

- 执行的第一条 SQL 语句不同，以不同身份启动：

    - 1.执行的第一条 SQL 语句是 insert：以读写事务身份启动事务。

        - 读写事务的启动过程，主要会做这几件事：
            - 为用户普通表分配回滚段，用于写 Undo 日志。
            - 分配事务 ID。
            - 把事务对象加入 trx_sys->rw_trx_list 链表。这个链表记录了所有读写事务。
                ```c
                UT_LIST_ADD_FIRST(trx_sys->rw_trx_list, trx);
                ```

    - 2.执行的第一条 SQL 语句是 select、update、delete：以读事务身份启动事务。

        - 读事务启动时，没有分配事务 ID 和回滚段，事务对象也没有加入到 trx_sys->rw_trx_list 链表。

        - 以读事务身份启动的事务，并不意味着一直都是读事务，它可以在某些时间点变成读写事务。

        - 根据执行的第一条 SQL 语句不同，读事务变成读写事务的时间点可以分为两类：

            - 1.第一条 SQL 语句是 select

                - 在 select 语句执行过程中，读事务不会变成读写事务；这条 SQL 语句执行完之后、事务提交之前，第一次执行 insert、update、delete 语句时，读事务才会变成读写事务。

                    - 如果最先碰到 insert 语句，server 层准备好要插入的记录的每个字段之后，会触发 InnoDB 执行插入操作。
                    - 如果最先碰到的是 update 或 delete 语句，则和以下的第一条 SQL 语句是 update 或 delete一样

            - 2.第一条 SQL 语句是 update 或 delete。

                - 发生变化的具体时间点，又取决于这两类 SQL 语句更新或删除记录的第一个表是什么类型。
                    - 1.如果第一个表是用户普通表，InnoDB 从表中读取一条记录之前，会给表加意向排他锁（IX）。

                        - 加意向排他锁时，如果以下三个条件成立，InnoDB 就会把这个事务变成读写事务：

                            - 事务还没有为用户普通表分配回滚段。
                            - 事务 ID 为 0，说明这个事务现在还是读事务。
                            - 事务的只读标识 trx->read_only = false，说明这个事务可以变成读写事务。

                    - 2.如果第一个表是用户临时表，因为它的可见范围只限于创建这个表的数据库连接之内，其它数据库连接中执行的事务都看不到这个表，更不能改变表中的数据，所以，update、delete 语句改变用户临时表中的数据，不需要加意向排他锁。

                        - 读事务变成读写事务的操作会延迟到 server 层触发 InnoDB 更新或删除记录之后，InnoDB 执行更新或删除操作之前。

                        - 在这个时间节点，如果以下三个条件成立，InnoDB 就会把这个事务变成读写事务：

                            - 事务已经启动了。
                            - 事务 ID 为 0，说明这个事务现在还是读事务。
                            - 事务的只读标识 trx->read_only = false，说明这个事务可以变成读写事务。


- 只读事务：是读事务的特例

    ```sql
    -- 以 start transaction 开始一个事务时，如果包含了 read only 关键字，这个事务就是一个只读事务。
    start transaction read only
    ```

    - 只读事务不能改变（插入、更新、删除）系统表、用户普通表的数据，但是能改变用户临时表的数据。

    - 改变用户临时表的数据，同样需要为事务分配事务 ID，为用户临时表分配回滚段。

    - 根据只读事务执行的第一条 SQL 语句不同，这两个操作发生的时间点也可以分为两类。
        - 1.第一条 SQL 语句是 select。
            - 具体过程等同于上面的读事务
        - 2.第一条 SQL 语句是 update 或 delete。
            - 具体过程等同于上面的读事务变成读写事务

##### 基本使用

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

##### [爱可生开源社区：MySQL 核心模块揭秘 | 13 期 | 回滚到 savepoint](https://mp.weixin.qq.com/s?__biz=MzU2NzgwMTg0MA==&mid=2247514601&idx=1&sn=4b8ff384ce70af1fc8edf983a7881ef6&chksm=fc955b76cbe2d2603f8393fe24ac674684702a054e467fe3e037a3b4b81e7c7a1593e9b81596&cur_album_id=3254180525410418690&scene=189#wechat_redirect)

- 准备工作
    ```sql
    -- 创建测试表
    CREATE TABLE `t1` (
      `id` int unsigned NOT NULL AUTO_INCREMENT,
      `i1` int DEFAULT '0',
      PRIMARY KEY (`id`) USING BTREE,
      KEY `idx_i1` (`i1`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3;

    -- 插入测试数据
    INSERT INTO `t1` (`id`, `i1`) VALUES
    (10, 101), (20, 201),
    (30, 301), (40, 401);
    ```

- savepoint示例
    ```sql
    /* 1 */ begin;
    /* 2 */ insert into t1 (id, i1) values (50, 501);
    /* 3 */ savepoint savept1;
    /* 4 */ insert into t1(id, i1) values(60, 601);
    /* 5 */ savepoint savept2;
    /* 6 */ update t1 set i1 = 100 where id = 10;
    /* 7 */ savepoint savept3;
    /* 8 */ insert into t1(id, i1) values(70, 701);
    /* 9 */ rollback to savept2;
    ```

    - 每条 SQL 前面的数字是它的编号，9 条 SQL 分别为 SQL 1、SQL 2、...、SQL 9，其中，SQL 9 是本文的主角。

        - SQL 2 插入记录 <id = 50, i1 = 501> 产生的 undo 日志编号为 0。
        - SQL 4 插入记录 <id = 60, i1 = 601> 产生的 undo 日志编号为 1。
        - SQL 6 更新记录 <id = 10> 产生的 undo 日志编号为 2。
        - SQL 8 插入记录 <id = 70, 701> 产生的 undo 日志编号为 3。

    - 每个用户线程都有一个 m_savepoints 链表，用户每创建一个 savepoint，它的对象都会追加到链表末尾。
        - 示例 SQL 中，SQL 3、5、7 分别创建了 savept1、savept2、savept3，这 3 个 savepoint 对象形成的 m_savepoints 链表如下：
        ![image](./Pictures/mysql/事务-savepoints.avif)

        - 要回滚到某个 savepoint，第 1 步就是根据名字找到它，因为它里面保存着两个重要数据：

            - 创建 savepoint 时的 binlog offset。
            - 创建 savepoint 之前，最后产生的一条 undo 日志的编号。

        - 如果遍历完 m_savepoints 链表都没有找到目标 savepoint 对象，就会报错：
            ```sql
            (1305, 'SAVEPOINT xxx does not exist')
            ```

    - binlog回滚

        - 回滚到某个 savepoint 的过程中，binlog 回滚就是把创建该 savepoint 之后执行 SQL 产生的 binlog 日志都丢弃。

        - 事务提交之前，产生的 binlog 日志都临时存放于 trx cache，而 trx cache 包含内存 buffer 和磁盘临时文件两部分。
            - 情况 1：丢弃内存 buffer 中的部分或全部 binlog 日志。
            - 情况 2：丢弃内存 buffer 中的全部 binlog 日志，同时还要丢弃磁盘临时文件中的部分或全部 binlog 日志。

    - InnoDB 回滚

        - 事务执行过程中，改变（插入、更新、删除）表中的每条数据，都会对应产生一条 undo 日志。

        - 回滚到某个 savepoint 的过程中，InnoDB 回滚，就是按照 undo 日志产生的时间，从后往前读取 undo 日志。

        - 每读取一条 undo 日志之后，解析 undo 日志，然后执行产生这条日志的操作的反向操作，也就是回滚。
            - 如果某条 undo 日志是插入操作产生的，反向操作就是删除。
            - 如果某条 undo 日志是更新操作产生的，更新操作把字段 A 的值从 101 改为 100，反向操作就是把字段 A 的值从 100 改回 101。
            - 如果某条 undo 日志是删除操作产生的，反向操作就是把记录再插回到表里。

    - 回滚到哪条 undo 日志才算完事呢？

        - savepoint 中，保存着它创建之前，最后产生的那条 undo 日志的编号，回滚到这条 undo 日志的下一条 undo 日志就完事了。

        - 以 SQL 5 为例，创建 savept2 之前，最后一条 undo 日志是插入记录 <id = 60, i1 = 601> 产生的，编号为 2。

        - SQL 9，rollback to savept2 回滚到编号为 2 的 undo 日志的下一条 undo 日志（编号为 3）就完事了。


    - 删除 savepoint

        - 执行完 binlog 和 InnoDB 的回滚操作之后，还需要删除该 savepoint 之后创建的其它 savepoint。

        - 示例 SQL 中，SQL 5 创建 savept2 之后，SQL 7 又创建了 savept3。

            - SQL 9 回滚到 savept2，执行完 binlog 和 InnoDB 的回滚操作之后，savept3 就没用了，会被删除。

            - 删除 savept3 之后，m_savepoints 链表如下图所示：

            ![image](./Pictures/mysql/事务-savepoints1.avif)

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

###### MVCC(多版本并发控制)

- [MySQL数据库联盟：一文搞懂MVCC](https://mp.weixin.qq.com/s?__biz=MzIyOTUzNjgwNg==&mid=2247485309&idx=1&sn=0521e2b452c8c444c75657e61a88c0db&chksm=e8406234df37eb22dcd9595e0bca98a76d92becf53a8e41a5e3964a1aba70317081939930740&scene=178&cur_album_id=3234198021790154762#rd)

- MVCC并非乐观锁，但是InnoDB存储引擎所实现的MVCC是乐观的，它和之前所提到的用户行为的“乐观锁”都采用的是乐观机制，属于不同的“乐观锁”手段，它们都是“乐观家族”的成员。

- MVCC的给MySQL带来的好处

    - MVCC 最大的好处是读不加锁，读写不冲突，极大地增加了 MySQL 的并发性。

    - 通过 MVCC，保证了事务 ACID 中的 I（隔离性）特性。

- MVCC只在RC和RR隔离级别下有

    - 在RU（READ UNCONNMITTED）隔离级别下，每次只要取到最新的值就行，不需要考虑多个版本，自然也不需要MVCC

    - 而在SERIALIZABLE隔离级别下，使用锁保障数据完全互相隔离，也不需要使用MVCC。

- 准备工作
    ```sql
    drop table if exists t1;

    -- 创建测试表
    CREATE TABLE `t1` (
    `id` int NOT NULL AUTO_INCREMENT,
    `a` int NOT NULL,
    `b` int NOT NULL,
    PRIMARY KEY (`id`),
    KEY `idx_c` (`a`)
    ) ENGINE=InnoDB CHARSET=utf8mb4;

    -- 插入测试数据
    insert into t1(a,b) values (1,1);
    ```

- RC和RR的对比

    - 另外需要补充的一点就是，在 RR 和 RC 隔离级别下，获取 Read View 的时机也是不一样的：

    - 在读已提交隔离级别（RC）下，同一个事务中，同样的查询语句在每次读请求发起时都会重新获得 Read View。

    - 在可重复读隔离级别（RR）下，同一个事务中，查询语句只是在第一个读请求发起时获取 Read View，而后面相同的查询语句都会使用这个 Read View。

    - 读已提交隔离级别（RC）的实验

        ```sql
        truncate table t1;
        insert into t1(a,b) values (1,1);
        ```

        |   | session1                                            | session2                                            |
        |---|-----------------------------------------------------|-----------------------------------------------------|
        | 1 | set session transaction_isolation='READ-COMMITTED'; | set session transaction_isolation='READ-COMMITTED'; |
        | 2 | select * from t1;                                   |                                                     |
        | 3 | begin;                                              |                                                     |
        | 4 | update t1 set b=3 where a=1;                        |
        | 5 |                                                     | begin;                                              |
        | 6 | select * from t1 where a=1;  结果是：1 1 3          | select * from t1 where a=1;  结果是：1 1 1          |
        | 7 | commit;                                             |                                                     |
        | 8 |                                                     | select * from t1 where a=1;  结果是：1 1 3          |
        | 9 |                                                     | commit;                                             |

        - 第 6 步中，session2 查询的结果是 session1 修改之前的记录，根据 Read View 原理，被查询行的隐藏事务 ID 就在当前活跃事务 ID 集合中。

            - 因此，这一行记录对该事物（session2 中的事务）是不可见的，可以知道 session2 查询的 a=1 这行记录实际就是来自 Undo log 中。

            - 我们看到的现象就是同一条记录在系统中存在了多个版本，这就是 MySQL 的多版本并发控制（MVCC）。

    - 可重复读隔离级别（RR）的实验

        - 第8步与RC下不同

        ```sql
        -- 默认就是RR
        select @@transaction_isolation
        +-------------------------+
        | @@transaction_isolation |
        +-------------------------+
        | REPEATABLE-READ         |
        +-------------------------+

        truncate table t1;
        insert into t1(a,b) values (1,1);
        ```

        |   | session1                                             | session2                                             |
        |---|------------------------------------------------------|------------------------------------------------------|
        | 1 | set session transaction_isolation='REPEATABLE-READ'; | set session transaction_isolation='REPEATABLE-READ'; |
        | 2 | select * from t1;                                    |                                                      |
        | 3 | begin;                                               |                                                      |
        | 4 | update t1 set b=3 where a=1;                         |
        | 5 |                                                      | begin;                                               |
        | 6 | select * from t1 where a=1;  结果是：1 1 3           | select * from t1 where a=1;  结果是：1 1 1           |
        | 7 | commit;                                              |                                                      |
        | 8 |                                                      | select * from t1 where a=1;  结果是：1 1 1           |
        | 9 |                                                      | commit;                                              |

- mvcc在不同sql语句的操作：

    - SELECT：InnoDB会根据以下两个条件检查每行记录：

        - 1.InnoDB只查找版本早于当前事务版本的数据行（行的系统版本号小于或者等于事务的系统版本号），这样可以确保事务读取到的行，要么是在事务开始之前已经存在的，要么是事务自身插入或者修改过的（结合以下INSERT、UPDATE操作理解）。

        - 2.行的删除版本要么未定义，要么大于当前事务版本号。可以确保事务读取到的行，在事务开启之前未被删除（结合以下DELETE操作理解）。

    - INSERT：InnoDB为新插入的每一行保存当前系统版本号作为行版本号。
    - DELETE：InnoDB为删除的每一行保存当前系统版本号作为行删除标识（第二个隐藏列的作用来了）。
    - UPDATE：InnoDB将更新后的列作为新的行插入数据库（并不是覆盖），并保存当前系统版本号作为该行的行版本号，同时保存当前系统版本号到原来的行作为行删除标识。

- MVCC的整体流程
    ![image](./Pictures/mysql/mvcc的整体流程.avif)

- MVCC原理总结

    - InnoDB 每一行数据都有一个隐藏的回滚指针，用于指向该行修改前的一些历史版本，这些历史版本存放在 Undo log 中。

    - 如果要执行更新操作，会将原记录放入 Undo log 中，并通过隐藏的回滚指针指向 Undo log 中的原记录。

    - 其它事务此时需要查询时，就是查询 Undo log 中这行数据的最后一个历史版本。


- 隐藏列：InnoDB ，每行记录除了我们创建的字段外，其实还包含 3 个隐藏的列

    | 隐藏列      | 说明                                                                                                             |
    |-------------|------------------------------------------------------------------------------------------------------------------|
    | DB_ROW_ID   | 隐藏的自增 ID，如果表没有主键，InnoDB 会自动以 ROW ID 产生一个聚集索引树。                                       |
    | DB_TRX_ID   | 事务 ID，记录最后一次修改该记录的事务 ID，包括insert、update、delete。                                           |
    | DB_ROLL_PTR | 回滚指针，指向这条记录的上一个版本的Undo log记录。如果记录更新了，那么Undo log包含在更新之前重建行所需要的信息。 |


- Read View（读取视图）：当一个事务需要查询这行记录时，它可能面临多个版本的选择。这时候就需要使用Read View（读取视图）来确定应该读取哪个版本的记录。

    - 大致包含以下内容：
        - trx_ids：生成Read View时，数据库系统当前活跃事务的ID集合；
        - low_limit_id：生成Read View时，系统中应该分配下一个事务的ID值；
        - up_limit_id：生成Read View时，活跃事务中最小的事务 ID；
        - creator_trx_id：创建这个Read View的事务 ID。

    - Read View如何判断行数据的哪个版本可用？

        - 某个事务，创建了 Read View，那么它的 creator_trx_id 就为这个事务的 ID
        - 假如需要访问某一行，假设这一行记录的隐藏事务 ID 为 DB_TRX_ID，那么可能出现的情况如下（DB_TRX_ID表示最后一次修改这行记录的事务ID）

            ![image](./Pictures/mysql/mvcc-read_view.avif)

    - 例子：

        ```sql
        truncate table t1;
        set session transaction_isolation='READ-COMMITTED';
        ```

        ![image](./Pictures/mysql/mvcc-read_view1.avif)

        - 在步骤1，session1里面

            - trx_ids是生成Read View时，数据库系统当前活跃事务的ID集合，当前就这个事务本身活跃，我们假设session1里的事务ID（表头里的：DB_TRX_ID就是假设的值）是1，那trx_ids也为1；
            - low_limit_id是生成Read View时，系统中应该分配下一个事务的ID值，因为现在事务ID已经到1了，下一个事务ID自然就是2；
            - up_limit_id是生成Read View时，活跃事务中最小的事务 ID，自然也是1；
            - creator_trx_id是创建这个Read View的事务 ID，也是1。

            - 所以满足条件：DB_TRX_ID=creator_trx_id，说明当前创建视图的事务是这行数据的创建者。自然这一行记录对该事务是可见的。


        - 在步骤3，session3里面

            - 当前活跃事务的ID是2（session2执行的，还未提交），那trx_ids为2；
            - 下一个事务ID，也就是low_limit_id为3；
            - 活跃事务中最小的事务 ID，自然up_limit_id是2；
            - 默认只读事务的事务ID是0，所以创建这个Read View的事务 ID，也就是creator_trx_id为0；

            - 满足条件：up_limit_id <= DB_TRX_ID < low_limit_id，并且DB_TRX_ID 也在 trx_ids 中。
            - 说明 DB_TRX_ID 还未提交，那么这一行记录对该事物是不可见的，然后再找Undo Log版本链前一个版本。找到DB_TRX_ID=1的版本，返回结果。

        - 在步骤7，session5里面

            - 当前活跃事务的ID是3（session3执行的，还未提交），那trx_ids为3；
            - 下一个事务ID，也就是low_limit_id为5（因为session4已经使用了事务ID4）；
            - 活跃事务中最小的事务 ID，自然up_limit_id是3；
            - 默认只读事务的事务ID是0，所以创建这个Read View的事务 ID，也就是creator_trx_id为0；

            - 满足条件：up_limit_id <= DB_TRX_ID < low_limit_id，并且DB_TRX_ID 不在 trx_ids 中。
            - 说明事务 DB_TRX_ID 已经提交了，那么这一行记录对该事物是可见的。

- Undo log

    - Undo Log的作用，除了用于事务回滚，还可以用在MVCC。

    - 当多个事务对同一行记录进行更新时，每个事务的修改会生成一个历史快照，这些快照被保存在数据库的Undo log（撤销日志）中。

    - 不同事务或相同事务对同一记录的修改，会导致该记录对应的Undo Log成为一条记录版本的线性表，即事务链，Undo Log的链首就是最新的旧记录，链尾就是最老的旧记录。


- mvcc实现原理

    ```sql
    -- 先清空t1表
    truncate table t1;

    -- 再写入测试数据
    insert into t1(a,b) values (1,1);
    ```

    ```sql
    -- 开启一个事务，更新表t1中的数据
    update t1 set b=3 where a=1;
    ```

    ![image](./Pictures/mysql/mvcc-实现原理.avif)

    - 结合图分析将字段b的值修改为3的步骤：

        - 1.数据库先对满足条件的行添加排他锁；
        - 2.将原记录的修改复制到Undo表空间中；
        - 3.将字段b的值修改为3，事务ID的值修改为2；
        - 4.回滚字段写入回滚指针的地址；
        - 5.提交事务释放排他锁。

    ```sql
    -- 再次更新表t1中的数据：
    update t1 set b=4 where a=3;
    ```
    ![image](./Pictures/mysql/mvcc-实现原理1.avif)

    - 结合上图分析表t1第二次更新的步骤。
        - 1.数据库先对满足条件的行添加排他锁；
        - 2.将原记录的修改复制到Undo表空间中；
        - 3.将字段b的值修改为4，事务ID的值修改为3；
        - 4.回滚字段写入回滚指针的地址；
        - 5.提交事务释放排他锁。

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

#### Change Buffer（更改缓冲区）

- [MySQL数据库联盟：一文弄懂MySQL更改缓冲区](https://mp.weixin.qq.com/s/sLfQhKQeluJz4k32E6yLWw) 

- 问题：假如有一条MySQL更新语句，它要更新的数据页不在Buffer Pool里面，那自然就会去磁盘中读取。

- 解决方法：MySQL就引入了更改缓冲区，也就是Change Buffer，可以把修改操作暂存在Change Buffer中。

    - 在后续查询访问到这个数据页的时候，将数据页读入内存，然后应用Change Buffer中之前缓存的修改操作。

- Change Buffer介绍

    ![image](./Pictures/mysql/change_buffer.avif)

    ```sql
    -- 查看Change Buffer的使用情况：
    SELECT (SELECT COUNT(*) FROM INFORMATION_SCHEMA.INNODB_BUFFER_PAGE
           WHERE PAGE_TYPE LIKE 'IBUF%') AS change_buffer_pages,
           (SELECT COUNT(*) FROM INFORMATION_SCHEMA.INNODB_BUFFER_PAGE) AS total_pages,
           (SELECT ((change_buffer_pages/total_pages)*100))
           AS change_buffer_page_percentage;
    +---------------------+-------------+-------------------------------+
    | change_buffer_pages | total_pages | change_buffer_page_percentage |
    +---------------------+-------------+-------------------------------+
    | 18                  | 8064        | 0.2232                        |
    +---------------------+-------------+-------------------------------+
    ```

    - 当二级索引（假设是非唯一的二级索引）页不在缓冲池时，它会缓存二级索引的更改（包括insert、update、delete等DML操作）。

    - 并且Change Buffer会缓存多次二级索引的更改操作，并在合适的时间写入磁盘。

    - 这里要注意的是，只是非唯一的二级索引才能用到Change Buffer，对于唯一索引，所有操作都需要判断是否违反唯一性约束。

        - 而唯一性判断，会将数据页读入到内存。所以更新操作直接在内存中进行就可以了。

- 关于Change Buffer的一些问题

    - 为什么更改缓冲区的存在可以减少随机访问I/O呢？

    - 这主要是因为二级索引数据的写入以页为基本单位，多次操作可能位于同一页面，将同一页面上的多次更改操作合并后再写入磁盘，可以将多次磁盘写入转换为一次磁盘写入。

    - Change Buffer有什么好处？

        - 当二级索引页不在缓冲池中时，缓存二级索引的变更，可以避免立即从磁盘读取受影响的索引页所需要的随机IO。

        - 当页面被其他读操作读入缓冲池时，缓存的更改可以在之后批量应用到磁盘。

- Change Buffer在什么时候合并？

    - 1.当页面被读入缓冲池时，缓冲的更改会在读取完成后合并，然后页面才可用；

    - 2.另外，通过参数innodb_io_capacity 控制，这个参数能决定每秒从buffer pool刷新到磁盘的次数，以及合并change buffer数据的次数；

    - 3.在崩溃恢复期间执行合并；

    - 4.更改缓冲区中的变更操作，不单单在内存中，也会被写入到磁盘。在实例重启后，更改缓冲区合并操作会是恢复的一部分工作。

- Change Buffer的配置

    - `innodb_change_buffering`：可以决定哪些操作会启用Change Buffer：

        | 值      | 数值 | 描述                                                                               |
        | none    | 0    | 不缓冲任何操作                                                                     |
        | inserts | 1    | 缓存插入操作                                                                       |
        | deletes | 2    | 缓存删除标记操作； 严格来说，是标记索引记录以便稍后在清除操作期间删除的写入        |
        | changes | 3    | 缓冲插入和删除标记索引记录操作                                                     |
        | purges  | 4    | 缓冲后台发生的物理删除操作                                                         |
        | all     | 5    | 默认； 也就是前面几个值的合集； 表示缓冲插入、删除标记操作和后台发生的物理删除操作 |


    - `innodb_change_buffer_max_size`：用来设置Change Buffer为Buffer Pool总大小的百分比。

        - 默认25，最大值可以设置为50。

        - 当有大量插入、更新和删除操作，应该适当增加这个值。

        - 如果Change Buffer消耗了过多的Buffer Pool的内存空间，可以降低这个值。

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

## 主从复制 (Master Slave Replication )

### 传统binlog复制模式

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

### MYSQL5.6的GTID复制模式

- [运维记事：一文带你了解MySQL中的GTID](https://mp.weixin.qq.com/s/ba2KPKDCfA9keQihf8BcRQ)

- 问题：传统的binlog复制模式存在2个问题：

    - 问题1：首次开启主从复制的步骤复杂
        - 第一次开启主从同步时，要求从库和主库是一致的。
        - 找到主库的 binlog 位点。
        - 设置从库的 binlog 位点。
        - 开启从库的复制线程。

    - 问题2：恢复主从复制的步骤复杂

        - 找到从库复制线程停止时的位点。

        - 解决复制异常的事务。无法解决时就需要手动跳过指定类型的错误，比如通过设置slave_skip_errors=1032,1062。当然这个前提条件是跳过这类错误是无损的。（1062 错误是插入数据时唯一键冲突；1032 错误是删除数据时找不到行）

- 解决问题：GTID的复制模式

    - MySQL能够通过内部机制 GTID 自动找点同步，并且通过 GTID可以保证每个主库提交的事务在集群中都有唯一的一个事务ID，强化了数据库主从的一致性和故障恢复数据的容错能力，在主库宕机发生主从切换的情况下，GTID方式可以让其他从库自动找到新主库复制的位置。

    - 而且GTID可以忽略已经执行过的事务，减少了数据发生错误的概率。

- GTID相较与传统复制的优势
    - 主从搭建更加简便，不用手动特地指定position位置。
    - 复制集群内有一个统一的标识，识别、管理上更方便。
    - 故障转移failover更容易，不用像传统复制那样需要找 log_File 和 log_Position的位置。
    - 通常情况下GTID是连续没有空洞的，更能保证数据的一致性。
    - 相对于ROW复制模式，数据安全性更高，切换更简单。
    - 比传统的复制更加安全，一个GTID在一个MySQL实例上只会执行一次，避免重复执行导致数据混乱或者主从不一致。


- GTID 使用中的限制条件

    - GTID 复制是针对事务来说的，一个事务只对应一个 GTID，好多的限制就在于此。其中主要限制如下：
    - 在一个复制组中，必须要求统一开启GTID或者是关闭GTID。
    - 开启GTID需要重启(5.7除外)
    - 不支持 `create table table_name select * from table_name`语句复制。
        - 因为会生成两个sql，一个是DDL创建表SQL，一个是insert into 插入数据的sql。由于DDL会导致自动提交，所以这个sql至少需要两个GTID，但是GTID模式下，只能给这个sql生成一个GTID )

    - 不允许在一个事务中既包含事务表（使用 InnoDB 存储引擎的表）的操作又包含非事务表（使用 MyISAM 存储引擎的表）。
    - 不支持创建或删除临时表操作，如 CREATE TEMPORARY TABLE or DROP TEMPORARY TABLE 语句操作。
    - 使用 GTID 复制从库跳过错误时，不支持执行该 sql_slave_skip_counter 参数的语法，传统复制可以使用这个命令跳过事务。

- GTID的复制原理
    - 主节点执行事务提交前会产生一个 GTID，其会随着事务一起记录到 binlog 日志中。
    - 从节点 I/O Thread 会读取主节点的 binlog 日志文件并存储在从节点的 relaylog 日志中。从节点将主节点的 GTID 这个值配置到 gtid_next 中，即下一个要读取的 GTID 值。
    - 从节点SQL线程从relay log中读取 gtid_next 中的值，然后查找自己的 binlog 日志中是否有这个 GTID。
        - 如果有这个记录：说明这个 GTID 的事务已经执行过了，就忽略掉。
        - 如果没有这个记录：从节点会从relay log中执行该GTID的事务，并记录到自己的 binlog 日志中。同时在读取执行事务前会先检查其他 session 中是否持有该 GTID，确保不被重复执行。

- GTID 指的是全局事务 ID，全称是 Global Transaction Identifier，具有如下特点：

    - GTID事务是全局唯一性的，并且一个事务对应一个GTID值。

    - 一个GTID值在同一个MySQL实例上只会执行一次。

    - GTID 由 server_uuid + tid 组成，其中：
        - server_uuid： server_uuid 是在 Mysql 首次启动过程中自动生成的一个 uuid(128位) 随机值，生成后会将该值存储到数据目录的auto.cnf文件中。
        - tid： 代表了该实例上已经提交的事务数量，并且随着事务提交单调递增，所以GTID能够保证每个MySQL实例事务的执行（不会重复执行同一个事务，并且会补全没有执行的事务）。
        ```
        # 样式
        26630fed-fe68-11ec-b051-000c29509871:1-27
        ```

#### 搭建

- 主要在 Mysql 配置文件中添加下面2条配置：

    ```ini
    # 开启 gtid 模式
    gtid_mode=on
    # 配置不允许任何事务违反 GTID 一致性,用于保证数据一致性
    enforce_gtid_consistency=on
    ```

- 从库配置同步的参数：

    - `master_auto_position` 标识主从关系使用的 GTID 协议。
        - 相比之前 Binlog 复制模式由人为指定binlog的pos位点改为了MASTER_AUTO_POSITION=1自动获取binlog的pos位点的配置，MASTER_LOG_FILE 和 MASTER_LOG_POS 参数已经不需要了。

    ```ini
    CHANGE MASTER TO
    MASTER_HOST=$host_name
    MASTER_PORT=$port
    MASTER_USER=$user_name
    MASTER_PASSWORD=$password
    master_auto_position=1
    ```

- [运维记事：MySQL基于GTID构建主从](https://mp.weixin.qq.com/s?__biz=MzU0MTgyMjA1MA==&mid=2247484087&idx=1&sn=5a4bd5dd020713c1a578f39e34e0a1aa&chksm=fb255fbacc52d6ac2ea74865fe3826848e55bff32b0d71a4c8a244e82f65a88c94d0621ee7e0&cur_album_id=2629958258165809153&scene=189#wechat_redirect)

#### GTID相关命令

- 查看GTID相关参数

    ```sql
    show variables like '%gtid%';
    +-------------------------+-----------+
    | Variable_name           | Value     |
    +-------------------------+-----------+
    | gtid_binlog_pos         | 0-1-33361 |
    | gtid_binlog_state       | 0-1-33361 |
    | gtid_cleanup_batch_size | 64        |
    | gtid_current_pos        | 0-1-33361 |
    | gtid_domain_id          | 0         |
    | gtid_ignore_duplicates  | OFF       |
    | gtid_pos_auto_engines   |           |
    | gtid_seq_no             | 0         |
    | gtid_slave_pos          |           |
    | gtid_strict_mode        | OFF       |
    | last_gtid               |           |
    | wsrep_gtid_domain_id    | 0         |
    | wsrep_gtid_mode         | OFF       |
    | wsrep_gtid_seq_no       | 0         |
    +-------------------------+-----------+
    ```

    | 参数名                           | 含义介绍                                                                                                                                                                               |
    |----------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
    | binlog_gtid_simple_recovery      | 该参数是控制当MySQL服务重启或启动时候自动寻找GTIDs的值。                                                                                                                               |
    | enforce_gtid_consistency         | 该参数是强制要求只允许复制事务安全的事务，请看上面步骤的具体限制条件。                                                                                                                 |
    | gtid_executed_compression_period | 启用GTID时，服务器会定期在mysql.gtid_executed表上执行压缩。通过设置gtid_executed_compression_period系统变量，可以控制压缩表之前允许的事务数，从而控制压缩率。设置为0时，则不进行压缩。 |
    | gtid_mode                        | 是否开启GTID模式。                                                                                                                                                                     |
    | gtid_next                        | 表示下一个要执行的GTID信息。                                                                                                                                                           |
    | gtid_owned                       | 该参数包含全局和session，全局表示所有服务器拥有GTIDs，session级别表示当前client拥有的所有GTIDs。                                                                                       |
    | gtid_purged                      | 已经purge掉的GTIDs，purged掉的GTIDs会包含到gtid_executed中。                                                                                                                           |
    | session_track_gtids              | 该参数是控制用于捕获的GTIDs和在OK PACKE返回的跟踪器。                                                                                                                                  |

- 如何判断复制方式是GTID还是pos
    ```sql
    -- 查看Auto_Position字段。0是pos 方式， 1是gtid方式。
    show slave status
    ```

- gtid变更为pos方式：

    ```sql
    change master to master_auto_position=0;
    ```

- 当前执行gtid信息

    ```sql
    SELECT @@GLOBAL.GTID_EXECUTED;
    +-------------------------------------------------------------------------------------+
    | @@GLOBAL.GTID_EXECUTED |
    +-------------------------------------------------------------------------------------+
    | 26630fed-fe68-11ec-b051-000c29509871:1-31,
    bf480f97-fe64-11ec-9b9d-000c29af7696:1-3 |
    +-------------------------------------------------------------------------------------+

    SELECT * FROM mysql.gtid_executed;
    +--------------------------------------+----------------+--------------+
    | source_uuid | interval_start | interval_end |
    +--------------------------------------+----------------+--------------+
    | 26630fed-fe68-11ec-b051-000c29509871 |             1 |           29 |
    | 26630fed-fe68-11ec-b051-000c29509871 |             30 |           30 |
    | bf480f97-fe64-11ec-9b9d-000c29af7696 |             1 |           1 |
    +--------------------------------------+----------------+--------------+
    ```

    - mysql.gtid_executed表是由MySQL服务器提供给内部使用的。它允许副本在副本上禁用二进制日志记录时使用GTIDs，并允许在二进制日志丢失时保留GTID状态。

        - RESET MASTER命令，gtid_executed表将被清除。

        - 服务意外停止的情况下，当前二进制日志文件中的gtid集不会保存在gtid_executed表。在恢复期间，这些gtid将从二进制日志文件添加到表中，以便可以继续复制。

    - 关于gtid_executed表

        - 若MySQL服务器启用了二进制日志，则表mysql.gtid_executed的更新仅在二进制rotation时发生，因为发生重启等情况依旧可以通过扫描二进制日志判断得知当前运行的GTID位置。

        - 简单来说，该表会记录当前执行的GTID在MySQL 5.6中必须配置参数log_slave_updates的最重要原因在于当slave重启后，无法得知当前slave已经运行到的GTID位置，因为变量gtid_executed是一个内存值：MySQL 5.7将gtid_executed这个值给持久化。采用的技巧与MySQL 5.6处理SQL thread保存位置的方式一样，即将GTID值持久化保存在一张InnoDB表中，并与用户事务一起进行提交，从而实现数据的一致性。触发条件：

            - 在binlog发生rotate(flush binary logs/达到max_binlog_size)或者关闭服务时，会把所有写入到binlog中的Gtid信息写入到mysql.gtid_executed表。

            - 从库：如果没有开启log_bin或者没有开启log_slave_updates，从库在应用relay-log中的每个事务会执行一个insert mysql.gtid_executed操作。

- 除了传统的查看binlog和pos值之外，GTID模式可以更直观的查看某个事务执行的情况。

    ```sql
    show slave status\G;
    ```

    | 参数名             | 含义介绍                               |
    |--------------------|----------------------------------------|
    | Retrieved_Gtid_Set | Slave节点已经接收到的Master节点的GTIDs |
    | Executed_Gtid_Set  | Slave节点已经执行的GTIDs               |
    | Auto_Position      | 自动获取position位置，显示为1          |

- gtid跳过gtid_next

    ```
    -- 备注：该操作类似于sql_slave_skip_counter，只是跳过错误，不能保证数据一致性，需要人工介入，固强烈建议从机开启read_only=1
    stop slave;
    set gtid_next='26630fed-fe68-11ec-b051-000c29509871:37'
    begin;commit;
    set gtid_next='automatic';
    start slave;
    ```

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

## 高可用

- [爱可生开源社区：第三期话题：MySQL 高可用 VS Oracle 高可用，MySQL 能否取代 Oracle 在金融行业的垄断局面？](https://mp.weixin.qq.com/s/qEOduHQw1ptVLvN2YAPv4g)

### 高可用方案

- [MySQL数据库联盟：MySQL 常用高可用方案](https://mp.weixin.qq.com/s/3ICMQUF_vQpuDm2nHi1qqw)

![image](./Pictures/mysql/高可用-高可用方案投票.avif)

- 1.主从或主主 + Keepalived

    - 主从或主主 + Keepalived 算是历史比较悠久的 MySQL 高可用方案

    - 其大致原理是：在主实例的 Keepalived 中，增加监测本机 MySQL 是否存活的脚本，如果监测 MySQL 挂了，就会重启 Keepalived，从而使 VIP 飘到从实例。

    ![image](./Pictures/mysql/高可用-Keepalived.avif)

    - 优点
        - 部署简单。
        - 只有两个节点，没有主实例宕机后选主的问题。
    - 缺点：
        - 级联复制或者一主多从在切换之后，其他从实例需要重新配置连接新主。
        - 云环境使用不了。

- 2.MHA

    - MHA（Master High Avaliable） 是一款 MySQL 开源高可用程序，MHA 在监测到主实例无响应后，可以自动将同步最靠前的 Slave 提升为 Master，然后将其他所有的 Slave 重新指向新的 Master。

    ![image](./Pictures/mysql/高可用-MHA.avif)

    - 优点
        - 可以根据需要扩展 MySQL 的节点数量。
        - 只要复制没有延迟，MHA 通常可以在几秒内实现故障切换。
        - 可以使用任何存储引擎。
    - 缺点
        - 仅监视主数据库。
        - 需要做 SSH 互信
        - 使用 Perl 开发，二次开发困难。
        - 跟不上 MySQL 新版本，最近一次发版是 2018 年。

- 3.PXC

    - PXC（Percona XtraDB Cluster）是一个完全开源的 MySQL 高可用解决方案。它将 Percona Server、Percona XtraBackup 与 Galera 库集成在一起，以实现多主复制的 MySQL 集群。

    ![image](./Pictures/mysql/高可用-PXC.avif)

    - 优点
        - 去中心：任何节点宕机，集群都可以继续运行而不会丢失任何数据。
        - 每个节点都可以写入数据并自动同步到其他节点。
        - 数据写入需要集群所有节点验证通过才会提交，保证了数据的强一致性。
    - 缺点
        - 只支持 InnoDB 引擎。
        - 木桶效应：集群吞吐量取决于性能最差的节点。
        - 增加节点时，必须从现有节点之一复制完整的数据集。

- 4.MGR/InnoDB Cluster

    - MySQL 5.7 推出了 MGR（MySQL Group Replication），与 PXC 类似，也实现了多节点数据写入和强一致性的特点。MGR 采用 GCS（Group Communication System）协议同步数据，GCS 可保证消息的原子性。

    ![image](./Pictures/mysql/高可用-MGR.avif)

    - MGR 是基于分布式一致性算法 Paxos 来实现的一套高可用解决方案，并不是主从复制。

    - MGR 最最重要的一个特点，它是多写的！MGR 的 share nothing 架构，每个实例都有自己的存储，每个节点都可以写入。

        - 数据库是一个有状态的服务，可以通过 MGR 多写的机制，可以把数据库变成一种弱状态。任何时间、任何节点都可以写，如果不能写，我就不停的尝试，总有一个节点可以写。你会发现这件事情会变得非常简单。我们以前做容灾很复杂，数据库要做切换、等待、balabalabala…… 很多事。像业务现在就可以不用关心数据库层，数据库本身就可以完成。

        - Oracle 在金融行业用的最多的一种数据架构是 Rac。Rac 也是每个节点都可写，但是对标 MGR 有些不公平。因为虽然 Rac 每个节点可写，但是下面的存储就是一个共享存储。MGR 每个节点都可写，但每份数据是 share nothing。

        - Rac 对比 MySQL 的 share nothing 其实是存在缺点的。

            - 如果共享存储出了问题就没办法了。有同学会说，下面的共享存储是几百万、几千万的设备啊！它是不会坏的，性能是很 NB 的 balabalabala…… 但不可否认的它就是个单点，就是会坏。一年不会坏两年会坏，两年不会坏三年会坏，它还是存在坏的可能性。

            - 并不是说 Rac 不好，是 share nothing 和 share everything 长远来看肯定是 share nothing 好。

    - InnoDB Cluster 由以下技术组成：
        - MySQL Shell，MySQL 的高级客户端和代码编辑器，用于管理 MGR 集群。
        - Group Replication，提供一组高可用的 MySQL 实例。
        - MySQL Router，在应用程序和集群之间提供透明的路由。当 MGR 发生切换树，自动路由到新的 MGR 主节点。

    - 优点
        - 支持多节点写入，有冲突检测机制。
        - 强一致性。
    - 缺点
        - 只支持 InnoDB 表，每张表都要有主键。
        - 最多只支持 9 个节点。

- 5.Xenon

    - Xenon 是一个使用 Raft 协议的 MySQL 高可用和复制管理工具，使用 Go 语音编写。

    ![image](./Pictures/mysql/高可用-Xenon.avif)

    - Xenon 基于 Raft 协议进行无中心化选主，并能实现秒级切换。
    - 优点
        - 不需要管理节点。
        - 无数据丢失的快速故障转移。
    - 缺点
        - 只适用于 GTID。
        - 默认情况下，Xenon 和 MySQL 跑在同一个账号下。

- 6.Orchestrator
    - Orchestrator是 Go 语音编写的 MySQL 高可用性和复制管理工具，作为服务运行并提供命令行访问、HTTP API 和 Web 界面。

    ![image](./Pictures/mysql/高可用-Orchestrator.avif)

    - 优点
        - 自动发现 MySQL 拓扑，可以拖动拓扑图进行复制关系的变更。
        - 提供命令行和 API 接口，方便运维管理。
        - 快速故障转移。
        - 多种故障等级，应对不同故障等级可配置不同处理办法。
    - 缺点
        - 相对于其他高可用组件，参数多很多。
        - 在某些场景可能出现丢数据的情况，数据补偿机制需要优化。

### MHA

- [运维记事：MySQL高可用之MHA+延迟备份搭建指导](https://mp.weixin.qq.com/s?__biz=MzU0MTgyMjA1MA==&mid=2247483800&idx=1&sn=0c2652dea2b27115e3e793f626690d7f&chksm=fb255c95cc52d5833507ccd78dd54f9b3c528c630f4d9311c0d5a27da493cddce611cea224e8&cur_album_id=2629958258165809153&scene=190#rd)

### MGR（MySQL Group Replication）

- [爱可生开源社区：第四期话题：MySQL Group Replication 能否在生产环境中大规模使用？](https://mp.weixin.qq.com/s/gYb3yE8IfiOFqkTvMYfjQA)

## 中间件

- [爱可生开源社区：第六期话题：MySQL 中间件的选择，ProxySQL、Spider、MyCAT、DBLE 怎么选？](https://mp.weixin.qq.com/s/Q7rd47eZI1A5Cq3ZfvQV2g)

- 人口问题，国外的互联网并发量远小于中国。即便是美国也才 2-3 亿人，中国 14 亿，再算算移动互联网的使用人数，绝对是中国多。所以在国外 MySQL 不做这件事情，就是因为对分布式需求没有这么强烈，但中国有！各种节日的购物情景，老外是想象不到的。

- 某个功能是 Oracle MySQL 官方的人来做，还是开源社区的人来做？

- 商业数据库思维逻辑：如果是 Oracle 的角度，在我的闭环之内，那就是你要什么我给你什么
    - 像 Oracle 这样的数据库就是希望做的大而全。但我们也看到 SQL Server 也在慢慢的拥抱开源，现在对 Hive 等大数据平台的支持做的也很好。

- 开源数据库思维逻辑：到目前为止，MySQL 官方并没有一个中间件的产品，而是由社区驱动开发了很多中间件产品。这就是开源社区和商业很大的一个不同，开源就是我做一个基础内核，通过迭代发展，不需要大而全。
    - 你会发现所有的互联网公司都有类似的中间件产品，比如阿里最早的 TDDL、网易的 DDB、京东的 shardingsphere，银行业也开发了自己的中间件产品，中信银行使用了 GoldenDB、工行使用了 DBLE，所以你会发现每个银行都会用中间件产品去做分布式数据库架构

- 我知道很多公司都在做 Oracle 到 MySQL 的转型。
    - 比如收快递行业的圆通是 Oracle 迁到了 MySQL。这些公司是比较典型的基于中间件的 MySQL 分布式架构完成去 O。

- 对于运维或者架构 DBA，希望你能掌握基于中间件做分布式架构的能力。主要的问题就是怎么分库分表。分库分表听起来很简单，无非就是 hash 和 range，但想用好分库分表是需要有些经验的。
    - 比如用分区表还是直接分表？肯定是分表。如果有项目经验就知道分区表有哪些问题。
    - 分库分表之后，有二级索引的查询该怎么办？是做索引表还是冗余数据呢？这就要根据每个业务的情况再去设计了。还有上次和虎青聊到一个非常难解决的问题：分布式事务。这些都是分布式架构中常见的问题。

- 中间件限制

    - 任何的分布式数据库限制都多，因为使用分布式数据库要有一个前提条件，90% 的查询是根据分区键访问的。

        - 如果你告诉我用户查询的维度非常多，那就用 ES 就好了。

        - 所以 MySQL 解决的是什么问题，一定要搞清楚。并不是中间件产品限制多，而是分布式数据库架构本身就多。不能把分布式数据库等同于单机数据库。

- 对于 MySQL 开发人员，你会发现每家公司几乎都会有分布式中间件的需求，那么你要去熟悉这些产品，做一些定制化的开发，那你也会很有竞争力。一方面是架构，一方面是产品本身。接下来我们看一下业界有哪些常见的中间件产品。

- ProxySQL
    - 这个产品是不支持分库分表的，只支持代理功能。将我的某条 SQL 代理到下面的节点，然后做读写分离的工作。我记得是 C++ 写的，因为它刚发布时由 Percona 推，所以 ProxySQL 火了一阵子就没声音了。
    - 如果代理只是做读写分离、负载均衡操作价值不是特别大。用 ProxySQL 做高可用效果不一定很好。我希望的架构是，计算层在上面，存储层在下面。ProxySQL 在计算层做的比较少，算不上真正的计算层。

- Mycat

    - 它早期用户量非常非常多的产品。后来 Mycat 的主程和团队都去了其他公司，甚至创业了。没有做好这件产品，有些可惜，但 Mycat 是在爱可生的 DBLE 出现之前最成熟的中间件产品。我见过非常非常多的公司把 Mycat 用于生产环境。虽然 Mycat 有很多 Bug，但对于简单查询支持得是很不错的。

    - Mycat 就做好了一件事情：分库分表。

        - 一个配置文件设置好配置规则，它就做好这一件事情用户就很多了，因为这个需求是分布式数据库架构中占 90% 的需求。真的做很多 Join、Group By、子查询，这就不是分布式数据库应该做的事情。

        - 从产品经理的角度来看，千万不要做太多，做好一件事情就够了，后面都是慢慢的迭代，通过迭代把事情越做越好越完善

            - MySQL 就是这样的。MySQL 以前我自己都说它是玩具数据库，但它好几件事情就 OK 了，InnoDB 能做好 OLTP 再支持个 MVCC就 OK 了。

    - Mycat 文档等等方面都不完善，使用上要靠大家去悟。但是如果把 Mycat 放在一家公司，不断地由 DBA 和开发人员理解、尝试、调试，是能做起来的。
        - 这也是为什么爱可生的 DBLE 能做起来的原因，就是公司有一群专业的人长期投入做这件事情就能做好。另外爱可生本身又有客户，产品通过不断地迭代打磨产品，得到很好的实践。

    - 所以现在我并不建议大家使用 Mycat，而是选择 DBLE。我本身最喜欢的就是 Mycat，现在来看爱可生接手了 Mycat 以 DBLE 这款产品的形式去做，那的确是市面上开源产品中比较优秀的，甚至是最优秀的产品。
        - 但是直接把 DBLE 拿来用，也不一定能 hold 住，这也是爱可生公司本身存在价值，可以提供优质的服务。

- Spider

    - Spider 是一个 MySQL 引擎，一个分布式存储引擎。连接 Spider，它会自动将数据路由到下面的节点。

    - 是由日本人做的，现在也不怎么开发了，在持续维护的就是腾讯互娱团队 Tspider。这个产品是做数据库内核的人做出来的，相对做 Mycat 的团队并不是做 MySQL 内核出身的。
        - 它是把分布式数据库理解成一张分区表，每个分区不在一台机器上，而是在每个 DataNode 上，更加接近分布式数据库本身的概念。很多开发人员还是理解到分库分表，打散数据而已。因为它是基于存储引擎的，所以上层所有 SQL 的解析都是由 MySQL 本身做的，对 SQL 的支持是 100%。

    - Spider 最大的缺点是，因为是存储引擎，下发到节点（数据层），返回给 Spider 再返回上面。你会发现它的链路是迂回的，所以它的性能会比较差。另外它使用的 MySQL 本身的分区机制，5.7 分区功能还是有很多性能瓶颈的，分区多性能会非常差。Spider 建议不要超过 128 个分区，超过的话性能下降非常明显。所以它没有做起来的主要原因就是性能比较差，但兼容性是最好的。

    - 在工程领域和在理论领域是完全不同的两件事，比如分布式事务理论应该用差异事务去做，但工程领域绝对不会这么去做，因为性能太差，我们可以用最终一致性实现。在工程上可以有很多的取舍，但数据库产品用很严谨的角度去实现，反而会带来很多局限性。这就是如何在工程和理论中平衡。

- 分布式中间件的产品三类：ProxySQL 一类；Mycat/DBLE/ShardingSphere 都是用 Java 开发比较完善，业界使用非常多的。三款推荐一款那就是 DBLE；还有就是基于 C++ 开发的 Spider 存储引擎，缺点就是性能不如前两类，好处就是兼容性。

- 谈谈 PolarDB？

    - PolarDB 与基于中间件的分布式数据库架构是完全不同的。它是计算与存储分离，容量可扩展，性能并不怎么可扩展。我们叫它云原生数据库，是因为在云环境中很多用户并不要求很高的性能，但他希望我的业务不要终断，可以迅速的扩缩容。
    - 为什么 PolarDB 卖的好？本质上还是 MySQL 协议，在体系内的产品。个人觉得这只是云原生数据库的样子，不一定是未来数据库的样子。

- 做 MySQL 开发如何？

    - 很好，这就是 DBA 该有的样子。一方面业务，一方面有开发能力。我经常建议传统运维 DBA 做一件事情，MHA 这样的软件用 Perl 写的，你去把它用 Python 也好 Go 也好重写一遍。或者把 mydumper 备份工具用 C++ 写的，用 Python 或 Go 重写一遍。从小的项目开始练练手吗。

### DBLE

## 备份与恢复

- [MySQL解决方案工程师：MySQL的备份](https://mp.weixin.qq.com/s?__biz=MzU1NzkwMjQ2MQ==&mid=2247486675&idx=1&sn=5e8aa7d23093409f4a25af98f7249553&chksm=fc2ff3c1cb587ad737a892c295a1a4e2f1265f34d6898e453350854e26fb61350d8439c335be&scene=21&poc_token=HJ83IWaj3Dd95Y8l8qyyc_wa_LnNKp_Mc9tvGh5W)

- 备份类型：影响应用程序与数据库的交互

    - 热备份：允许应用程序完整访问数据。

        - 备份可以在数据读取和修改期间进行，系统保留读取和修改数据的能力。在备份期间采用多版本并行控制（MVCC），会使用行锁。

    - 冷备份：不允许应用程序访问数据。

        - 备份时数据无法被用户访问，通常情况下，服务器需要进入拒绝访问模式或关机。用户在备份期间无法读取和修改任何数据。

        ```sh
        # 停服务
        mysqladmin –uroot –proot shutdown

        # 备份数据目录
        cp –r /opt/mysql newdirectory

        # 恢复
        cp –r newdirectory /opt/mysql #将备份的数据替换原目录重启数据库即可
        ```

    - 温备份：允许应用程序进行只读操作，不允许更改数据。

        - 备份时允许用户读取数据，无需完全封闭用户，但缺点是备份期间无法修改数据、可能会导致性能问题。

- 备份的方法可以分为：

    - 1.逻辑备份：MySQL的逻辑备份可以通过SQL语句、mysqldump、mydumper、XtraBackup以及MySQL5.7以后出现的mysqlpump 多线程备份，但由于mysqlpump使用的较少且不安全，不在此次讲述范围之内。

        - 优点：

            - 创建一个SQL脚本，用户可以在MySQL服务器上执行，并可以利用该脚本在不同架构的主机或服务器上重新加载数据。
                - 独立于存储引擎

            - 逻辑备份可以备份全部的数据库或其中的一个/部分数据库或表，并且可以备份本地和远程的服务器。

        - 缺点
            - 逻辑备份的速度远慢于物理备份
                - MySQL服务器必须读取表并解释表的内容，之后将其转换为磁盘文件或者发送到一个客户端程序。
            - 逻辑备份的恢复慢于物理备份的恢复
                - 原因在于恢复过程中执行的脚本包含独立的创建和插入语句，这些语句在后台创建表，并插入数据。

            - 备份语句使用的磁盘空间可能会超过实际数据使用的磁盘空间，因为通常情况下，文本数据要比二进制数据消耗更多的磁盘空间，但对于InnoDB而言，由于其在数据页中保存数据，会包含一部分未使用的空间，它所占用的磁盘空间会超过实际数据大小。

        - 通常情况下逻辑备份属于温备份，使用时有如下要求：
            - 创建备份时，要求MySQL服务器必须运行。
            - 备份期间应用程序可以执行只读操作。
            - 服务器通过读取正在备份的表的结构和内容来创建文件，然后将结构和数据转换为SQL语句或文本文件。
            - 利用InnoDB 的MVCC可以实现热备份，使用“REPEATABLE READ”隔离级别实现一致的时间点备份。

    - 2.物理备份：主要是指复制数据文件。用户可以使用标准的“tar”，“cp”等命令操作，也可以通过物理镜像、块操作，及快照文件等实现。
        - 优点：
            - 物理备份的优势在于执行备份和恢复时远超逻辑备份的速度，其快速的原因是其作为一个文件或文件系统进行复制
            - 备份文件的大小与数据文件的实际大小相同。
        - 缺点：
            - 数据恢复时，必须恢复到相同的MySQL版本和存储引擎。
            - 物理备份期间，服务器不能修改文件。InnoDB要求服务器关机，MyISAM要求只读。用户可以使用快照、MySQL复制，DRDB等方法在后台分开数据文件，以降低备份对MySQL和应用程序的影响。

        - 1.在线磁盘复制

            - 用户可以使用RAID镜像，DRDB等技术进行在线磁盘复制。这些技术提供在线或者接近在线的备份能力，可以在硬件发生故障时快速恢复数据，其缺点是因为它具有实时复制的能力，无法利用该技术处理人为或应用程序导致的数据丢失。

        - 2.基于快照的备份

            - 基于快照的备份等同于创建了一个具有时间点的数据副本，提供了一个逻辑上冻结的文件系统版本。快照无需包含具有一致性的数据库镜像，当利用快照进行恢复时，InnoDB必须执行它自身的恢复过程，以确保完整的事务。

            - 基于快照的备份使用MySQL外部的快照功能，例如，数据文件在Linux的LVM2 逻辑卷，包含一个ext4的文件系统，用户可以创建一个基于快照的备份。基于快照的备份系统适用于支持事务的存储引擎，使用“Copy-on-write”方法来确保它们几乎是瞬时完成的。“Copy-on-write”方法类似于InnoDB的UNDO日志和MVCC，当执行快照时，LVM标记随后更改的所有块，并记录这些块的快照版本

        - 3.基于MySQL复制的备份

            - MySQL支持单向的异步复制，在复制的拓扑中一台服务器作为主服务器，其余的服务器作为从服务器。备份时，主服务器作为生产环境的服务器使用，从服务器用于备份，该方法的优势是可以最大限度减小对生产环境的影响，缺点则是主从之间可能存在延迟、需要额外的服务器存放数据库的副本。

        - 4.二进制日志备份

            - 二进制日志备份记录了数据的变更，用于在上次完整备份后恢复到最新数据时使用。
            - 优点：是记录了完整的数据更改，用户可以安顺序保存应用多个二进制日志备份。
            - 缺点：是用户必须按照顺序从上一次的完整备份结束之后保存日志，恢复时间可能会很长。
            - 用户可以使用“mysqlbinlog”创建日志流，例如：
                ```sh
                mysqlbinlog --read-from-remote-server --host=server_host --raw --stop-never binlog.000101
                ```

            - 用户可以在MySQL的会话级别控制二进制日志的开启，例如：

                ```sql
                SET SQL_LOG_BIN = 1
                ```

                - 进行逻辑或物理备份时，需要刷新二进制日志进行同步，以用于备份。当需要进行增量备份时，需要复制增量部分的二进制日志。此外，二进制日志也适用于时间点恢复，用户可以识别出错的事务，并跳过该事务进行恢复。

- 备份方法对比

    ![image](./Pictures/mysql/备份方法对比.avif)

- 备份策略

    - 取决于数据记录的完整性和备份频率的要求，以及能够承受的系统宕机时长和恢复数据量的要求。

    ![image](./Pictures/mysql/备份策略.avif)

### 备份工具性能对比

| 导出             | 导入                           | 优点         | 推荐度（效率）    |
|------------------|--------------------------------|--------------|-------------------|
| mysqldump        | source xxx.sql  MySQL< xxx.sql | 原生，可远程 | ⭐⭐⭐ 数据量<10G |
| mydumper         | myloader                       | 多线程       | ⭐⭐⭐ 数据量>50G |
| SELECT OUTFILE   | LOAD  DATA                     | 最灵活       | ⭐⭐ 数据量<20G   |
| Util.dumpTables  | Util.loadDump                  | 原生，多线程 | ⭐⭐⭐ 数据量<50G |
| Util.exportTable | Util.importTable               | 原生，单线程 | ⭐ 数据量<20G     |

- SELECT OUTFILE 语句
    - 适合于单表数据的导出，不支持多表。
    - 可自定义导出部分列，导出导入速度较快，最常用。

- mysqldump：单线程
    - 1G 的备份文件，测试结果如下：
    - 使用 mysql< xxx.sql 导入，耗时 5 分钟。
    - 使用 source xxx.sql 导入，耗时 10 分钟。

- mydumper
    - 在数据量大于 50G 的场景中，更推荐 mydumper。

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

### LOAD DATA/OUTFILE 导入/导出文件

- [爱可生开源社区：技术分享 | MySQL Load Data 的多种用法](https://mp.weixin.qq.com/s/WNXRshkvC3bFcc5NDaWlrw)

```sql
-- 创建源数据表
CREATE TABLE load_data_test (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  data VARCHAR(64) DEFAULT NULL,
  ts TIMESTAMP,
  PRIMARY KEY (id)
);

INSERT INTO load_data_test VALUES
(1, 'one', '2014-08-20 18:47:00'),
(2, 'two', '2015-08-20 18:47:00'),
(3, 'three', '2016-08-20 18:47:00');

-- 将表数据输出/tmp/test文件。也是csv的格式
SELECT * INTO OUTFILE '/tmp/test'
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
  FROM load_data_test;

cat test.txt
"1","one","2014-08-20 18:47:00"
"2","two","2015-08-20 18:47:00"
"3","three","2016-08-20 18:47:00"

-- 创建导入数据的表
CREATE TABLE load_data1_test (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  data VARCHAR(64) DEFAULT NULL,
  ts TIMESTAMP,
  PRIMARY KEY (id)
);

-- 导入数据
LOAD DATA INFILE '/tmp/test'
  INTO TABLE load_data1_test
  CHARACTER SET utf8mb4
  FIELDS TERMINATED BY ','
  ENCLOSED BY '"'
  LINES TERMINATED BY '\n'
```

- 自定义导入的字段的列
    ```sql
    -- 只导入id和data字段的列
    DELETE FROM load_data1_test; -- 删除刚才导入的数据

    LOAD DATA INFILE '/tmp/test'
      INTO TABLE load_data1_test
      CHARACTER SET utf8mb4
      FIELDS TERMINATED BY ','
      ENCLOSED BY '"'
      LINES TERMINATED BY '\n'
      (@C1,@C2,@C3) -- 该部分对应test文件中3列数据
      -- 设置导入的字段与对应的列
      SET id=@C1,
          data=@C2;

    -- 查看是否只导入id和data字段的列
    SELECT * FROM load_data1_test
    +----+-------+--------+
    | id | data  | ts     |
    +----+-------+--------+
    | 1  | one   | <null> |
    | 2  | two   | <null> |
    | 3  | three | <null> |
    +----+-------+--------+
    ```

- 对导入的列，进行函数处理

    - 假设前2列的导入没有问题，第3列的数据类型与函数处理报错；那么依然会导入前2列的数据、第3列的值为`NULL`

    - `now()`： 生成当前时间数据
    - `upper()`：转换为大写
    - `lower()`：转换为小写
    - `concat(id, ',', data)` ：拼接id和data字段
    - `trim(substr(@C2,1,2))`：使用substr取前2个字符,并去除头尾空格数据
    - `if(hire_date<'1988-01-01','Y','N')`：对需要生成的值基于某一列做条件运算

    ```sql
    -- 对data字段转换为大写
    DELETE FROM load_data1_test; -- 删除刚才导入的数据

    LOAD DATA INFILE '/tmp/test'
      INTO TABLE load_data1_test
      CHARACTER SET utf8mb4
      FIELDS TERMINATED BY ','
      ENCLOSED BY '"'
      LINES TERMINATED BY '\n'
      (@C1,@C2,@C3) -- 该部分对应test文件中3列数据
      -- 设置导入的字段与对应的列
      SET id=@C1,
          data=upper(@C2); -- 转换为大写
    ```

### mysqldump 备份和恢复

- mysqldump 可以保证数据一致性且不影响业务的运行，所产生的备份，最终是要结合 binlog 进行恢复。备份的过程是先从 buffer 中找到需要备份的数据进行备份，如果 buffer 中没有，则去磁盘的数据文件中查找并调回到 buffer 里面在备份，最后形成一个可编辑的以 .sql 结尾的备份文件。

- 单线程

- 它可以执行逻辑备份，如果执行备份的对象是InnoDB存储引擎，则可以执行热备份，默认情况下，它对所有的引擎执行温备份。

- 备份的基本流程如下：
    - 1.调用 FTWRL(flush tables with read lock)，全局禁止读写
    - 2.开启快照读，获取此时的快照(仅对 innodb 表起作用)
    - 3.备份非 innodb 表数据(*.frm,*.myi,*.myd等)
    - 4.非 innodb 表备份完毕后，释放 FTWRL锁
    - 5.逐一备份 innodb 表数据
    - 6.备份完成。

- 注意事项：

    - 有删除表，建立表的语句，小心导入目标库时，删除表的语句，造成数据误删。

    - INSERT 语句没有字段名称，导入时表结构要一致。

    - 导入过程中有 `lock table write` 操作，导入过程中相关表不可写。

    - `ALTER TABLE 表 DISABLE KEYS` 此语句将禁用该表的所有非唯一索引，这可以提高插入大量数据时的性能。 对应的文件末尾有 `ALTER TABLE 表 ENABLE KEYS;` 重新构建索引


- 参数

    - --hex-blob：是 mysqldump 工具的一个选项，它的作用是将 BLOB 类型的数据导出为十六进制字符串。这对于存储二进制数据（如图片、文件等）非常有用

    - `--routines`、`--event`，`--trigger`：分别用于转储存储例程、事件调度器的事件，及触发器。

    - `--opt`选项是以下语句的简写：`--add-drop-table --add-locks --create-options --disable-keys --extended-insert --lock-tables --quick--set-charset`。它提供了一个快速的转储操作，并产生一个可以快速重新加载到MySQL服务器的转储文件。

    - 用于创建对象的选项：

        - `--no-create-db`：不写入`CREATE DATABASE`语句。
        - `--no-create-info`：不写入`CREATE DATABASE`语句。
        - `--no-data`：创建数据库和表的结构，但是不包含数据。
        - `--no-tablespaces`：不写入`CREATE LOGFILE GROUP`或`CREATE TABLESPACE`。
        - `--quick`：快速从表中查询一条记录，不使用表的缓冲集。

    - 用于删除对象的选项：

        - `--add-drop-database`：在创建数据语句之前增加`DROP DATABASE`语句。
        - `--add-drop-table`：在创建表语句之前增加`DROP TABLE`语句。

- 部分遇到的问题可以使用下面参数解决。

    | 参数                            | 说明                                                           |
    |---------------------------------|----------------------------------------------------------------|
    | --no-create-info 不包含建表语句 | （可以手动创建 create table tablename like dbname.tablename;） |
    | --skip-add-drop-database        | 不包含删库语句                                                 |
    | --skip-add-drop-table           | 不包含删表语句                                                 |
    | --skip-add-locks INSERT         | 语句前不包含 LOCK TABLES t_order_info WRITE;                   |
    | --complete-insert INSERT        | 语句中包含 列名称（新表的列有增加的时候）。                    |

- 创建一个测试数据和一个测试表

    ```sql
    -- 创建新数据库
    use china;

    -- 创建测试表
    create table tz (
        id   int (8),
        name varchar(50),
        date DATE
    );

    -- 插入测试数据
    insert into tz (id,name,date) values
    (1,'tz','2020-10-24'),
    (2,'tz','2020-10-25');
    ```

- 单表导出。保证数据一致性

    - `--master-data=2` ：在备份期间对所有表加锁 FLUSH TABLES WITH READ LOCK，并执行 SHOW MASTER STATUS 语句以获取二进制日志信息。该参数有 1 和 2 两个值
        - 如果值等于 1，就会在备份出来的文件中添加一个 CHANGE MASTER 的语句（搭建主从复制架构）
        - 如果值等于 2，就会在备份出来的文件中添加一个 CHANGE MASTER 的语句，并在语句前面添加注释符号（后期配置搭建主从架构）。
            - 如果您不需要进行主从复制，则可以考虑不使用 --master-data=2 参数。

    - `--dump-slave`： 该参数用于在从库端备份数据，在线搭建新的从库时使用。该参数也有 1 和 2 两个值。
        - 值为 1 时，也是在备份文件中添加一个 CHANGE MASTER 的语句
        - 值为 2 时，则会在 CHANGE MASTER 命令前增加注释信息。

    - `--single-transaction`：用于保证 InnoDB 备份数据时的一致性，配合可重复读 RR（repetable read）隔离级别使用，当发生事务时，读取一个事务的快照，直到备份结束时，都不会读取到事务开始之后提交的任何数据。

    - `--master-data`和`--single-transaction`：同时使用两个选项时，InnoDB无需锁表并能够保证一致性，在备份操作开始之前，取得全局锁以获得一致的二进制日志位置。当事务的隔离级别为`repeatable read`时，开启`--single-transaction`选项读取InnoDB的数据，可以获得非锁定的数据一致性。[必须有]

    ```sql
    # 备份china数据库中的tz表
    mysqldump --master-data=2 --single-transaction china tz > tz-table.sql
    ```

    - 导出的`tz-table.sql`内容如下

    ```sql
    DROP TABLE IF EXISTS `tz`;
    /*!40101 SET @saved_cs_client     = @@character_set_client */;
    /*!40101 SET character_set_client = utf8 */;
    CREATE TABLE `tz` (
      `id` int(8) DEFAULT NULL,
      `name` varchar(50) DEFAULT NULL,
      `date` date DEFAULT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

    -- 表明这些语句只有在 MySQL 版本号为 4.01.01 或者更高条件下才可以被执行。
    /*!40101 SET character_set_client = @saved_cs_client */;

    --
    -- Dumping data for table `tz`
    --

    LOCK TABLES `tz` WRITE;
    /*!40000 ALTER TABLE `tz` DISABLE KEYS */;
    INSERT INTO `tz` VALUES
    (1,'tz','2020-10-24'),
    (2,'tz','2020-10-25');
    /*!40000 ALTER TABLE `tz` ENABLE KEYS */;
    UNLOCK TABLES;
    /*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;
    ```


- 基本使用

    ```sql
    # 备份 china 数据库
    mysqldump -uroot -pYouPassward --single-transaction china > china.sql

    # 通过pv命令显示进度
    mysqldump -uroot -pYouPassward --single-transaction china | pv > china.sql

    # 复制到另一台mysql服务器
    mysqldump -uroot -pYouPassward --single-transaction orig-db | mysql -uroot -pYouPassward copy-db

    # 备份 china 数据库里的 tz 表
    mysqldump -uroot -pYouPassward --single-transaction china tz > tz-table.sql

    # where语句
    mysqldump -uroot -pYouPassward --single-transaction china tz --where="date>'2020-10-24'" > tz-table.sql

    # 备份所有数据库
    mysqldump -uroot -pYouPassward --single-transaction --all-databases > all.sql

    # -d 只备份所有数据库表结构(不包含表数据)
    mysqldump -uroot -pYouPassward --single-transaction -d --all-databases > mysqlbak-structure.sql

    # 恢复到 china 数据库
    mysql -uroot -pYouPassward china < china.sql

    # 恢复所有数据库
    mysql -uroot -pYouPassward < all.sql

    # 使用mysql客户端处理.sql文件，使用mysqlimport处理.txt文件。
    mysqlimport -uroot -pYouPassward database table.txt
    ```

### [mydumper：比mysqldump更快](https://github.com/maxbube/mydumper)

- 支持多线程导入/导出

| 参数                                            | 说明                                                                         |
|-------------------------------------------------|------------------------------------------------------------------------------|
| -B                                              | --database 要转储的数据库                                                    |
| -T                                              | --tables-list 逗号分隔的转储表列表(不会被正则表达式排除)                     |
| -o                                              | --outputdir 保存输出文件的目录                                               |
| -s                                              | --statement-size 插入语句的字节大小                                          | 默认是1000000个字节 |
| -r                                              | --rows 把表按行数切块                                                        |
| -c                                              | --compress 压缩输出文件                                                      |
| -e                                              | --build-empty-files 空表也输出文件                                           |
| -x                                              | --regex 匹配‘db.table’的正则表达式                                           |
| -i                                              | --ignore-engines 以逗号分隔的被忽略的存储引擎列表                            |
| -m                                              | --no-schemas 不转储表架构                                                    |
| -k                                              | --no-locks 不执行临时共享读锁。警告: 这会导致备份的不一致性                  |
| -l                                              | --long-query-guard 设置长查询的计时器秒数，默认是60秒                        |
| --kill-long-queries 杀死长查询 (而不是退出程序) |
| -b                                              | --binlogs 获取二进制日志文件快照并转储数据                                   |
| -D                                              | --daemon 开启守护进程模式                                                    |
| -I                                              | --snapshot-interval 每个转储快照之间的间隔时间(分钟)                         | 需要开启 --daemon   | 默认是60分钟 |
| -L                                              | --logfile 日志文件的名字，默认是stdout                                       |
| -h                                              | --host 要连接的主机                                                          |
| -u                                              | --user 有转储权限的用户名                                                    |
| -p                                              | --password 用户密码                                                          |
| -P                                              | --port 连接的TCP/IP端口                                                      |
| -S                                              | --socket 用于连接的Unix套接字文件                                            |
| -t                                              | --threads 使用的线程数，默认是4                                              |
| -C                                              | --compress-protocol 在MySQL连接上使用压缩                                    |
| -V                                              | --version 查看程序版本号                                                     |
| -v                                              | --verbose 输出信息的等级,0 = silent,1 = errors,2 = warnings,3 = info,默认是2 |

- 压缩对比

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

### [go-mydumper：比mysqldump更快](https://github.com/xelabs/go-mydumper)

### [MySQL解决方案工程师：InnoDB的物理备份方法](https://mp.weixin.qq.com/s/TkFzpIdZQ5gGF5PbSJZ-ag)

- 为了保证一致性，进行文件复制时，必须停掉MySQL服务器，因此，该方法是冷备份的方法。

- 二进制文件的物理备份具有可移植性。二进制文件可以从一台MySQL服务器直接复制到另外一台服务器，在不同架构的服务器间进行备份时非常有用。

- InnoDB：全部的表空间和日志文件可以直接复制，数据库的路径名称在源/目标服务器上必须保持一致。

- MyISAM和Archive：每个表的所有文件都可以直接复制，元数据文件需要从.sdi文件中导入。

- InnoDB的二进制文件物理备份过程

    - 1.关闭MySQL服务器（慢关机）

        - 要求`innodb_fast_shutdown=0`，默认值是1。
        - 在关机前允许InnoDB完成额外的刷新操作。
        - 关闭耗时长，但启动非常快。

    - 2.复制InnoDB全部的数据、日志，及配置文件。包括：

        - 数据文件：“ibdata”和“*.ibd”
        - 重做日志：“ib_logfile*”
        - 撤销日志：“undo_*”
        - 全部的配置文件，例如，“my.cnf”

    - 3.重新启动服务器

- 备份恢复

    - 1.停止服务器
    - 2.使用备份过程中的副本替换当前服务器全部的组件
    - 3.重启服务器

- 注意，InnoDB使用共享表空间存储表的元数据，因此需要：

    - 将共享表空间和独立表空间文件作为一组进行复制
    - 复制对应的重做日志和撤销日志

### [MySQL解决方案工程师：使用可移动表空间执行InnoDB备份](https://mp.weixin.qq.com/s/tdVSYP862XgDUZBfqjm_Kg)

- 备份InnoDB的表时，可以使用可移动表空间执行部分备份，可以备份单独的表，也可以备份具有相同业务功能的多个表。

- 当用户将希望将源服务器上的一个表复制到另外一台服务器上时，可以采用可移动表空间来实现，具体如下：

    - 1.在源服务器上执行“FLUSH TABLE ... FOR EXPORT”将表静止并创建“.cfg”元数据文件。

        ```sql
        FLUSH TABLES actor FOR EXPORT;
        ```

        ```sh
        # “.cfg”文件将会创建在数据路径下：

        C:\ProgramData\MySQL\MySQL Server 8.3\Data\sakila 的目录
        2024/03/06  15:24    <DIR>          .
        2024/03/04  13:59    <DIR>          ..
        2024/03/06  15:24             1,003 actor.cfg
        2024/01/17  10:51           131,072 actor.ibd
        ```

    - 2.将“.ibd”文件和“.cfg”文件复制到目标服务器。

    - 3.在源服务器上执行`UNLOCK TABLES`释放表上的锁。

    - 4.在目标服务器上创建一个相同结构的表，之后销毁表空间

        ```sql
        ALTER TABLE actor DISCARD TABLESPACE;
        ```

    - 5.在目标服务器上导入复制过来的表空间
        ```sql
        ALTER TABLE actor IMPORT TABLESPACE;
        ```

    - 注意，如果进行备份的表是带有分区的InnoDB表，则需要对每个分区导出元数据文件，并需要将每个分区的“.ibd”文件和“.cfg”文件执行导出、导入的操作。

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

### [MySQL解决方案工程师：MySQL的备份工具——MySQL企业版备份](https://mp.weixin.qq.com/s?__biz=MzU1NzkwMjQ2MQ==&mid=2247486683&idx=1&sn=130c6d2a4ed13e6818622fa02b367301&chksm=fc2ff3c9cb587adf8e4e46bd860203c01430db50939f6596718c3bb01cc00e6d4bf8a6bc966f&cur_album_id=2325042420926742528&scene=189#wechat_redirect)

- `mysqlbackup`命令

- 对于InnoDB存储引擎，MySQL企业版备份能够执行热备份，（备份可以在应用程序连接时运行）备份不会阻挡数据库的正常操作。

- 对于其他的存储引擎，MySQL企业版执行温备份，应用程序可以对数据库进行只读操作。

- MySQL企业版具有如下功能：
    - 增量备份
    - 差异备份
    - 单一文件备份
    - 流形式发送到其他存储或服务器
    - 备份至磁带
    - 备份至云
    - 备份加密
    - 备份压缩
    - 部分备份
    - 可传输表空间

- MySQL企业版备份

    - 备份InnoDB时：会备份InnoDB的原生文件，包括：

        - ibdata*：共享表空间文件，包含系统表空间及部分用户表的数据。
        - mysql.ibd：mysql表空间文件，包含数据路径。
        - .ibd：独立表空间文件和通用表空间文件。
        - undo_*：Undo日志表空间文件。
        - ib_logfile*：从“ib_logfile*”文件抽取的备份文件名为“ibbackup_logfile”，包括备份期间发生更改产生的Redo日志信息。

    - 备份非InnoDB时：需要MySQL中包含至少一个innoDB表，默认情况下，MySQL企业版将备份MySQL服务器数据路径下的全部文件，如果用户指定了“--only-known-file-types”选项，备份将仅包含MySQL相关的文件。

#### 备份

- 备份过程
    - 1.`mysqlbackup`开启一个MySQL服务器的连接。
    - 2.`mysqlbackup`执行一个InnoDB在线备份。（该步骤不会干扰正常的数据库处理）
    - 3.当`mysqlbackup`执行接近完成时，它将执行`LOCK INSTANCE FOR BACKUP`语句。该语句将阻挡DDL，但不会阻挡DML。
    - 4.执行`FLUSH TABLES tbl_name, ...WITH READ LOCK`锁定非InnoDB表进行备份
    - 5.备份结束，释放表和实例。

- 完整备份
    ```sh
    # “--backup_dir”选项指定存储备份文件的路径。“command”命令包括“backup”执行备份的初始部分，“backup-and-apply-log”执行备份的初始部分及第二部分，第二部分包括备份期间更改的数据内容。
    mysqlbackup --user=username --password --port=portnumber --backup_dir=backup-directory command
    ```

- 单一文件备份

    ```sh
    # 使用“backup-to-image”命令可以将备份写入一个单一文件，单一文件易于管理，并能够流式传送至其他服务器、磁带，云等。

    # “--backup-image”选项指定用于存储备份的文件路径和名称。“--backup_dir”选项指定一个临时文件夹用于存储备份的元数据。

    mysqlbackup -uuser -ppassword --backup_dir=temp-backup-dir --backup-image=image-file backup-to-image
    ```

- 单一文件操作

    - `--src-entry`：指定一个文件或路径用于抽取。
    - `--dst-entry`：指定一个路径用于从单一文件中抽取文件或路径。

    ```sql
    # 可以将备份的路径转换为单一文件，例如：
    mysqlbackup --backup_dir=backup-dir --backup-image=image-file backup-dir-to-image

    # 列出单一文件的内容：
    mysqlbackup --backup-image=image-file list-image

    # 从单一文件中抽取文件：
    mysqlbackup --backup-image=image-file --src-entry=file-to-extract --dst-entry=file-to-extract extract
    ```

- 增量备份

    - 增量备份仅备份从上一次备份结束后产生变化的数据，上一次备份可以是完整备份，也可以是一次增量备份。可以大幅提高备份速度，降低存储要求。例如：

    - `--incremental`选项表示执行一个增量备份。
    - `--incremental-base`选项用于指定上一次备份，并将上一次备份用于这次的增量备份。
    - `--incremental-base=history:last_backup`选项将使`mysqlbackup`查询上次记录在`bakupu_history`表中的`end_lsn`的值。此外，用户也可以指定`dir:directory_path`为`--incremental-base`指定包含上一次备份的路径。
    - `--start-lsn`用于替换`--incremental-base`选项，用户可以指定上一次备份中包含最高的LSN，用于此次的增量备份。

    ```sql
    mysqlbackup --user=username --password --port=portnumber --incremental --incremental-base=history:last_backup --backup_dir=incr-backup-directory backup
    ```

- 差异备份

    - 差异备份属于特殊的增量备份，与增量备份的区别是上一次的备份必须是完整备份。例如：
    - 用户也可以使用`backup-to-image`替换`backup`命令，并指定`--backup-image`选项，备份成为单一文件。

    ```sql
    mysqlbackup --user=username --password --port-portnumber --incremental --incremental-base=history:last_full_backup --backup_dir=incr-backup-directroy backup
    ```

- `validate`操作：用于校验备份的完整性，检查每个数据叶的校验和。

    ```sql
    -- 校验备份文件
    mysqlbackup --backup-image=image-file validate

    -- 校验备份文件夹
    mysqlbackup --backup-dir=backup-directory validate
    ```

- 更新操作

    - 在完整备份时，利用`apply-log`选项进行更新。

        ```sql
        mysqlbackup --backup-dir=backup-dir apply-log
        ```

    - `backup-dir`中的完整备份可以使用`apply-incremental-backup`选项更新为增量备份。

        ```sql
        mysqlbackup --incremental-backup-dir=incr-backup-dir --backup-dir=backup-dir apply-incremental-backup
        ```

#### 恢复

- 恢复过程
    - 1.关闭MySQL服务器
    - 2.删除服务器数据路径下的全部文件
    - 3.运行“mysqlbackup”从完整备份中恢复文件
    - 4.恢复增量或差异备份的数据（如果适用）
    - 5.应用备份文件后产生的二进制日志
    - 6.启动MySQL服务器

- 恢复命令

    - `copy-back`：恢复备份路径（已使用`apply-log`保证一致性）。例如，将`backup-dir`中的文件恢复到服务器的数据路径：

        ```sql
        mysqlbackup --backup-dir=backup-dir copy-backup
        ```

    - `copy-back-and-apply-log`：恢复单一文件或数据路径，并执行应用日志操作。例如，从`image-file`中恢复到服务器的数据路径，并使用`temp-backup-dir`存储临时文件：

        ```sql
        mysqlbackup --backup-dir=temp-backup-dir --backup-image=image-file copy-back-and-apply-log
        ```

- 当使用“copy-back”命令时，“mysqlbackup”将复制数据文件、日志及其他的备份文件至其原来的位置，在恢复过程中，“mysqlbackup”无法从MySQL服务器查询相关的配置信息，只能通过标准的配置文件获得相关的选项，如果用户希望恢复到不同的服务器上，需要通过“--defaults-file”选项指定一个配置文件进行。

- 恢复增量备份时，首先需要恢复一个正确的基本备份，以用于增量或差异备份，其次使用“--incremental”选项进行恢复操作。例如：

    ```sql
    mysqlbackup --incremental-backup-dir=incr-backup-dir --incremental copy-back-and-apply-log
    mysqlbackup --backup-dir=temp-backup-dir --backup-image=image-file --incremental copy-backup-and-apply-log
    ```

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


## 字符集（character set）

- [爱可生开源社区：第06期：梳理 MySQL 字符集的相关概念](https://mp.weixin.qq.com/s?__biz=MzU2NzgwMTg0MA==&mid=2247488276&idx=1&sn=f6d928c1b34b8e0030a0876d5f3cd9d3&chksm=fc96f18bcbe1789d92d75ffe8e62f9127d4a732f2aa1385b0367f6e1f698cc291334a9e249ce&cur_album_id=1338281900976472064&scene=189#wechat_redirect)

- [爱可生开源社区：第07期：有关 MySQL 字符集的 SQL 语句](https://mp.weixin.qq.com/s?__biz=MzU2NzgwMTg0MA==&mid=2247488399&idx=1&sn=54e69b700341ff150de7d2ff0dbdc8a4&chksm=fc96f110cbe17806e1072603d06b598f1390cfeb2223b06f44355076bab9f626182a3b4a23c0&cur_album_id=1338281900976472064&scene=189#wechat_redirect)

- 字符集的内容包含：字符集（character set）和排序规则（collation rule）

    - 字符集：是一套字符与一套编码的映射集合

        | 字符 | 编码 |
        |------|------|
        | A    | 0    |
        | B    | 1    |
        | ...  | ...  |

    - 排序规则：比如要比较字符 A 和 B 的大小，最简单直观的方法就是对比他们对应的编码。显然编码 0 < 1，这种规则下 A < B。

- MySQL 常用字符集

    - 1.Latin1 是 cp1252 或者 ISO-8859-1 的别名。ISO-8859-1 编码是单字节编码，向下兼容 ASCII。

        - 比如把一个 Utf8mb4 的编码或者 GBK 的编码存入 Latin1，不会有任何问题。因为 Latin1 保留了原始的字节流，这也就是 MySQL 长期以来把 Latin1 做默认字符集的原因。

        - 但是由于 Latin1 对任何字符都存放字节流，造成了字符个数的浪费。

            - 该字段中存储字符个数 UTF8 是 Latin1 的三倍！！！
            ```sql
            CHAR(10) CHARACTER SET LATIN1;
            CHAR(10) CHARACTER SET UTF8;
            ```


    - 2.GB18030是中国官方标准字符集，向前兼容 GBK、GB2312，是这两个的超集。

        - Windows 系统，默认用的就是 GB18030。

        - 若只是存储中文字符，那 GB18030 最佳。
            - 1.占用空间小，比如比 UTF8 小。
            - 2.存储的汉字根据拼音来排序，检索快。

    - 3.UTF8 是 Unicode 的编码实现，可以存储 UNICODE 编码对应的任何字符， 这也是使用最多的一种编码。最大的特点就是变长的编码方式，用 1 到 4 个字节表示一个符号，可以根据不同的符号编码字节长度。

        - 字母或数字用 1 字节，汉字用 3 字节，emoji 表情符号用 4 字节。

        - 注意！MySQL 里常说的 UTF8 是 UTF8MB3 的别名，UTF8MB3 是 UTF8MB4 的子集，UTF8MB4 才是真正的 4 字节 UTF8 字符集！

        - UTF8MB3 表示最大支持 3 个字节存储字符，UTF8MB4 表示最大 4 个字节存储字符。

        - MySQL 8.0 已经默认用 UTF8MB4 基础字符集。

- UTF8MB3 与 UTF8MB4 的互相迁移

    - 1.UTF8 到 UTF8MB4 升级

        - 这种顺序可以做到无损迁移，前者就是后者的子集。比如从 MySQL 5.7 到 MySQL 8.0 的字符集升级，这样的场景不会有任何问题。

        ```sql
        -- 表 t1 字段 a 字符集 utf8
        CREATE TABLE t1 (a VARCHAR(10) charset utf8);

        -- 表 t2 字段 a 字符集 utf8mb4.
        CREATE TABLE t2 (a VARCHAR(10) charset utf8mb4);

        -- 表 t1 插入数据
        INSERT INTO t1 VALUES ('消灭病毒，中国无敌！');

        -- 表 t1 的数据可以直接插入到 t2。
        INSERT INTO t2 SELECT * FROM t1;

        -- 查看没有问题
        SELECT * FROM  t2;
        ```

    - 2.UTF8MB4 到 UTF8 兼容

        - 这种相当于降级模式，如果 utf8mb4 包含的字符没有超出了 utf8 的范围，则可以顺序进行；否则失败。
        ```sql
        truncate t1;
        INSERT INTO t1 SELECT * FROM t2;
        -- 没有问题
        SELECT * FROM t1;

        -- 清空表 t1,t2,
        truncate t2;
        truncate t1;
        -- 插入 EMOJI 表情字符'哈哈 🍀🍎💰📱'
        INSERT INTO t2 VALUES ('哈哈🍀🍎💰📱');

        -- 这些字符不包含在 utf8mb3 中，所以插入报错。
        insert into t1 select * from t2;
        ERROR 1366 (HY000): Incorrect string value:
        ```

### 字符集相关sql语句

- 字符集系统参数

    - 客户端层、连接层、结果集层，这三层一般都是一起设置。比如 `setnames utf8;` 同时设置这三个层次的参数；

    - 服务层一定得选择好对应的编码，否则可能会造成接下来的表、字段、存储过程等默认字符集不正确，产生字符集升级。如果兼容还好，不兼容就可能出现乱码或者其他的错误。

    - 1.MySQL 服务层
        - 以下两个设置 MySQL 服务层字符集和排序规则，代表 MySQL 服务启动后，默认的字符集和排序规则。
        - `character_set_server`：服务层默认字符集编码
        - `collation_server`：服务层默认排序规则

    - 2.客户端层
        - `character_set_client`：设置客户端的字符集。
        - 对任何可以连接到 MySQL 服务端的客户端生效。

    - 3.数据库层
        - `character_set_database`：设置创建新数据库时默认的字符集
        - `collation_database`：设置创建新数据库时默认排序规则名称

    - 4.元数据层
        - 数据库名，表名，列名，用户名等。
        - `character_set_system`: MySQL 元数据默认的字符集，目前不可设置，固定为 UTF8。

    - 5.结果集层
        - `character_set_results`：设置从服务端发送数据到客户端的字符集。包括查询结果，错误信息输出等。

    - 6.连接层
        - `character_set_connection`：设置客户端发送请求到服务端，但是服务端还没有接受之前的数据编码。
        - 比如普通字符串，或者已经写好的 SQL 语句但还没有执行。
        - `collation_connection`: 连接层的排序规则。

    - 7.文件系统层
        - `character_set_filesystem`：设置语句中涉及到的文件名字字符集。
        - 比如 `load dataintotable t1'/tmp/t1.txt';` 这里代表文件名字 /tmp/t1.txt 是以何种编码被 MySQL 解析。

    ```sql
    show variables like "char%";
    +--------------------------+----------------------------+
    | Variable_name | Value |
    +--------------------------+----------------------------+
    | character_set_client     | utf8mb3                    |
    | character_set_collations |                            |
    | character_set_connection | utf8mb3                    |
    | character_set_database   | latin1                     |
    | character_set_filesystem | binary                     |
    | character_set_results    | utf8mb3                    |
    | character_set_server     | utf8mb4                    |
    | character_set_system     | utf8mb3                    |
    | character_sets_dir       | /usr/share/mysql/charsets/ |
    +--------------------------+----------------------------+

    -- 修改系统参数
    set names latin1;
    -- 修改后查看
    show variables like "char%";
    +--------------------------+----------------------------+
    | Variable_name            | Value                      |
    +--------------------------+----------------------------+
    | character_set_client     | latin1                     |
    | character_set_collations |                            |
    | character_set_connection | latin1                     |
    | character_set_database   | latin1                     |
    | character_set_filesystem | binary                     |
    | character_set_results    | latin1                     |
    | character_set_server     | utf8mb4                    |
    | character_set_system     | utf8mb3                    |
    | character_sets_dir       | /usr/share/mysql/charsets/ |
    +--------------------------+----------------------------+

    -- collate为排序规则
    set names latin1 collate latin1_bin;
    -- 改回默认值
    set names default;

    -- 修改相关系统参数
    set session character_set_results = latin1;
    set session character_set_client = latin1;
    set session character_set_connection=utf8mb4;
    set session collation_connection = latin1_bin;
    ```

- 字符集相关 sql 语句

    ```sql
    -- 查看字符集编码变量
    SHOW VARIABLES LIKE "char%";

    -- 查看表字段的字符集编码
    SHOW FULL COLUMNS FROM table_name

    -- 创建新数据库，指定字符集编码为latin1和排序规则为latin1_bin。在此数据库创建的表会继承
    CREATE DATABASE ytt_new2 default CHARACTER SET latin1 COLLATE latin1_bin;
    -- 查看字符集编码和排序规则
    use ytt_new2
    SELECT @@character_set_database,  @@collation_database;

    -- 修改表为utf8mb4字符集编码
    ALTER TABLE table_name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

    -- 修改数据库为utf8mb4字符集编码。
    -- 修改数据库字符集与排序规则后，之前基于这个库创建的各种对象，还是沿用老的字符集与排序规则。
    ALTER DATABASE your_database_name CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    ```

- sql 语句

    ```sql
    -- 字符集 utf8mb4，排序规则 utf8mb4_bin
    SELECT _utf8mb4 "北京加油❤!" COLLATE utf8mb4_bin AS result;
    +------------+
    | result     |
    +------------+
    | 北京加油❤! |
    +------------+

    -- 字符集 utf8mb4,collate 字句缺失，此时对应排序规则为utf8mb4_w0900_ai_ci
    SELECT _utf8mb4 "北京加油❤!" AS result;
    +------------+
    | result     |
    +------------+
    | 北京加油❤! |
    +------------+

    -- 字符集缺失，此时字符集按照参数 @@character_set_connection 值来指定。
    SELECT "北京加油❤!" COLLATE gb18030_chinese_ci AS result;
    (1273, "Unknown collation: 'gb18030_chinese_ci'")

    -- 查看变量 @@character_set_connection，确认其字符集不包含排序规则 gb18030_chinese_ci，所以以上语句报错。
    SELECT @@character_set_connection;
    +----------------------------+
    | @@character_set_connection |
    +----------------------------+
    | utf8mb4 |
    +----------------------------+

    -- 那给下正确的排序规则 utf8mb4_bin，执行正确。
    SELECT "北京加油❤!" COLLATE utf8mb4_bin AS result;

    -- 字符集和排序规则都不指定，此时字符串对应的字符集和排序规则和参数 @@character_set_connection 一致。
    SELECT "北京加油❤!" AS result;
    -- 那这条语句其实被 MySQL 解释为
    SELECT _utf8mb4 "北京加油❤!" COLLATE utf8mb4_0900_ai_ci AS result;
    ```

- 字符集转换函数

    - 1.convert 函数
        ```sql
        -- 转换成功
        SELECT CONVERT("北京加油❤!" using utf8mb4) ;
        +-------------------------------------+
        | CONVERT("北京加油❤!" using utf8mb4) |
        +-------------------------------------+
        | 北京加油❤!                          |
        +-------------------------------------+

        -- 转换失败，字符集编码不兼容。
        SELECT CONVERT("北京加油❤!" using latin1) ;
        +------------------------------------------+
        | convert("北京加油❤!" using latin1) |
        +------------------------------------------+
        | ?????!                                   |
        +------------------------------------------+
        ```

    - 2.charset 函数

        - 检测字符串的字符集。可以检测出当前字符串在当前 session 的字符集。
        ```sql
        SET @a="北京加油❤!";
        SELECT CHARSET(@a);
        +-------------+
        | CHARSET(@a) |
        +-------------+
        | utf8mb4 |
        +-------------+
        ```

### 乱码

- [爱可生开源社区：第09期：有关 MySQL 字符集的乱码问题](https://mp.weixin.qq.com/s?__biz=MzU2NzgwMTg0MA==&mid=2247488749&idx=1&sn=85d200be05e2be02e51141f1e08a91b7&chksm=fc96f672cbe17f6454dd2028a23c22ecb9a177add568f51f0c7c90b3934429591cd449c4dd96&cur_album_id=1338281900976472064&scene=189#wechat_redirect)

- 编码不一致导致乱码

    ```sh
    # 查看终端的字符集编码
    locale

    # 新建立一个连接，客户端这边字符集为 gb2312。
    mysql -S /var/run/mysqld/mysqld.sock --default-character-set=gb2312

    # 如果表使用utf8mb4字符集，插入数据可能会乱码、出现2条warnings
    CREATE TABLE t1(a1 VARCHAR(100)) CHARSET utf8mb4;
    INSERT INTO t1 VALUES ("病毒滚吧！");
    Query OK, 1 row affected, 2 warnings (0.01 sec)

    -- 查看waring信息
    show warnings\G
    *************************** 1. row ***************************
      Level: Warning
       Code: 1300
    Message: Invalid gb2312 character string: 'E79785'
    *************************** 2. row ***************************
      Level: Warning
       Code: 1366
    Message: Incorrect string value: '\xE7\x97\x85\xE6\xAF\x92...' for column 'a1' at row 1
    ```

    - 解决方法1：把客户端编码设置成和表编码一致或者兼容的编码
        ```sql
        truncate t1;

        -- 把客户端字符集设置为 utf8mb4
        set names utf8mb4;

        -- 数据正常写入
        insert into t1 values ("病毒滚吧！");
        ```

    - 解决方法2

        ```sql
        -- 设置 SQL_MODE 为严格事务表模式，强制避免不兼容的编码插入数据。
        set sql_mode = 'STRICT_TRANS_TABLES';
        -- 报错信息由 warnings 变为 error 拒绝插入
        insert into t1(a1) values ("病毒滚吧！");
        ERROR 1366 (HY000): Incorrect string value: '\xE7\x97\x85\xE6\xAF\x92...'
        ```

- 表里的数据可能一半编码是 utf8mb4，另外一半是 gbk。

    - 解决方法：前提是找到两种不同编码记录的分界点！

        - 比如表 t3 的记录前三条编码和后三条的编码不一致，那可以把两种数据分别导出，再导入到一张改好的表 t4 里。

    ```sql
    -- utf8mb4 的编码数据，前三条导出
    set names default;select *  from t3 limit 0,3 into outfile '/var/lib/mysql-files/tx.txt';
    -- GBK 编码的数据，后三条导出
    set names gbk;select *  from t3 limit 3,3 into outfile '/var/lib/mysql-files/ty.txt';

    -- 建立一张新表 t4，编码改为统一的 utf8mb4
    create table t4 (a1 varchar(10),a2 varchar(10)) charset utf8mb4;

    -- 分别导入两部分数据
    load data infile '/var/lib/mysql-files/tx.txt' into table t4 character set gbk;
    load data infile '/var/lib/mysql-files/ty.txt' into table t4 ;

    -- 接下来看结果，一切正常
    set names default;
    select * from t4;
    ```

- 每个字段的编码不一致，导致乱码

    - 表 c1 字段 a1,a2
        - a1 编码 gbk
        - a2 编码是 utf8mb4。

    - 解决方法：类似上一种解决方法，把数据导出来，再导进去。由于 MySQL 处理数据是按照行的方式，按照列的方式会麻烦一点

    ```sql
    -- 分别按列导出两个文件
    select a2 from c1 into outfile '/var/lib/mysql-files/c1_a2.txt';
    select a1 from c1 into outfile '/var/lib/mysql-files/c1_a1.txt';

    # 在linux上用paste命令合并这两个文件
    paste c1_a1.txt c1_a2.txt  > c1.txt

    -- 创建表c2，编码统一
    create table c2 (a1 varchar(10),a2 varchar(10)) charset utf8mb4;

    -- 导入合成后的文件到表c2
    load data infile '/var/lib/mysql-files/c1.txt' into table c2 ;

    -- 删除表c1，重命名表c2为c1。
    drop table c1;
    alter table c2 rename to c1;

    -- 显示结果正常，问题得到解决。
    select * from c1;
    ```

- latin1字符集编码存储数据

    - MYSQL 长期以来默认的编码都是 latin1，一直到发布了 8.0 才把默认字符集改为 utf8mb4。

    - 问题：字符存储的字节数不一样，比如 emoji 字符 "❤"，如果用 utf8mb4 存储，占用 3 个字节，那 varchar(12) 就能存放 12 个字符，但是换成 LATIN1，只能存 4 个字符。

        ```sql
        -- 更改数据库 ytt_new10 字符集为 LATIN1
        alter database ytt_new10 charset latin1;
        set names latin1;
        use ytt_new10;

        -- 创建表 t2，默认字符集为 LATIN1
        create table t2(a1 varchar(12));

        -- 插入emoji字符，只能插入4个字符
        insert into t2 values ('❤❤❤❤');

        -- 但是在加一个字符，插入第五个字符报错。
        insert into t2 values ('❤❤❤❤❤');
        ERROR 1406 (22001): Data too long for column 'a1' at row 1


        -- 换张表t3,字符集为utf8mb4.
        create table t3 (a1 varchar(12)) charset utf8mb4;

        -- 结果集的字符集也设置为utf8mb4.
        set names utf8mb4;

        -- 插入12个'❤'，也就是同样的表结构，存储的字符串比latin1多。
        insert into t3 values (rpad('❤',12,'❤'));

        -- 改为 utf8mb4
        set names utf8mb4;

        -- 数据显式乱码
        select * from t2;
        +--------------------------+
        | a1 |
        +--------------------------+
        | â�¤â�¤â�¤â�¤             |
        +--------------------------+
        ```

    - 解决方法1：把表 t2 的列 a1 先改为二进制类型，在改回来用 utf8mb4 的编码的字符类型
        ```sql
        -- 现改为 binary 类型
        alter table t2 modify a1 binary(12);

        -- 再改为varchar(12) utf8mb4.
        alter table t2 modify a1 varchar(12) charset utf8mb4;

        -- 数据就正常显式。
        select * from t2;

        -- 接下来，再把表的字符集改回UTF8MB4。
        alter table t2 charset utf8mb4;
        ```

    - 解决方法2：还是用最土的方法，把数据导出来，把表编码修改好，再把数据导入到表里。
        ```sql
        -- 导出表t2数据。
        select * from t2 into outfile '/var/lib/mysql-files/t2.dat';

        -- 删除表
        drop table t2;

        -- 重建表，编码为utf8mb4.
        create table t2(a1 varchar(12)) charset utf8mb4;

        set names utf8mb4;

        -- 导入之前导出来的数据
        load data infile '/var/lib/mysql-files/t2.dat' into table t2;

        -- 检索完全正常。
        select * from t2;
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

### 插入中文错误(1366, "Incorrect string value:

```sql
-- 修改表为utf8mb4字符集编码
ALTER TABLE table_name CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
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

### [MySQL 主从 AUTO_INCREMENT 不一致问题分析](https://mp.weixin.qq.com/s/iQuPMPv4gD6udQub6C0h_A)

### [knowclub：在MySQL集群中，如何从几百万个抓包中找到一个异常的包？](https://mp.weixin.qq.com/s/C04qADbcfZP9e7RQDbz-Kg)

### 崩溃

#### [一树一溪：MySQL 崩溃恢复过程分析](https://mp.weixin.qq.com/s/PV6aXtwiMLMeMUBWhZxdvw)

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

## 第三方工具

- [awesome-mysql](http://shlomi-noach.github.io/awesome-mysql/)

    - [中文版](https://github.com/jobbole/awesome-mysql-cn)


- [MySQL 常用工具选型和建议](https://zhuanlan.zhihu.com/p/86846532)

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
