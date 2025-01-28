
<!-- mtoc-start -->

* [mysql-sql语句](#mysql-sql语句)
  * [基本命令](#基本命令)
    * [连接数据库](#连接数据库)
    * [简单 SQL 命令](#简单-sql-命令)
    * [DBA 常用命令](#dba-常用命令)
    * [其他命令](#其他命令)
    * [MySQL数据库联盟：五种不输入密码登录MySQL的方法，你知道几种？](#mysql数据库联盟五种不输入密码登录mysql的方法你知道几种)
    * [如何正确地关闭 MySQL 数据库？99%的 DBA 都是错的！](#如何正确地关闭-mysql-数据库99的-dba-都是错的)
  * [下载数据库进行 SQL 语句 学习](#下载数据库进行-sql-语句-学习)
  * [DQL (Data Query Language) 数据查询语言](#dql-data-query-language-数据查询语言)
    * [SELECT](#select)
      * [where: 行(元组)条件判断](#where-行元组条件判断)
      * [Order by (排序)](#order-by-排序)
      * [regexp (正则表达式)](#regexp-正则表达式)
      * [Group by (分组)](#group-by-分组)
        * [WITH ROLLUP（汇总）](#with-rollup汇总)
        * [dbaplus社群：MySQL 中的 distinct 和 group by 哪个效率更高？太刁钻了！](#dbaplus社群mysql-中的-distinct-和-group-by-哪个效率更高太刁钻了)
          * [结论](#结论)
      * [子查询](#子查询)
        * [IN, NOT IN](#in-not-in)
        * [标量子查询](#标量子查询)
        * [关量子查询](#关量子查询)
        * [with(临时表)](#with临时表)
      * [集合操作](#集合操作)
        * [UNION(并操作)](#union并操作)
        * [EXCEPT(差操作)](#except差操作)
        * [INTERSECT(交操作)](#intersect交操作)
      * [聚和函数(aggregation)](#聚和函数aggregation)
        * [基本聚和函数](#基本聚和函数)
        * [加密函数](#加密函数)
        * [rank(): 排名](#rank-排名)
        * [分窗](#分窗)
      * [自定义变量](#自定义变量)
    * [JOIN(关联查询): 改变表关系](#join关联查询-改变表关系)
      * [INNER JOIN(内连接)](#inner-join内连接)
        * [STRAIGHT_JOIN](#straight_join)
      * [LEFT JOIN(左连接)](#left-join左连接)
      * [RIGHT JOIN(左连接)](#right-join左连接)
      * [CROSS JOIN（笛卡尔连接）](#cross-join笛卡尔连接)
      * [FULL OUTER JOIN(全连接)](#full-outer-join全连接)
      * [JOIN算法的explain解析](#join算法的explain解析)
        * [优化JOIN查询](#优化join查询)
  * [DML (Data Manipulation Language) 数据操作语言](#dml-data-manipulation-language-数据操作语言)
    * [CREATE(创建)](#create创建)
      * [数据类型](#数据类型)
        * [dbaplus社群：MySQL中Varchar(50)和varchar(500)有什么区别？](#dbaplus社群mysql中varchar50和varchar500有什么区别)
        * [爱可生开源社区：技术分享 | MySQL VARCHAR 最佳长度评估实践](#爱可生开源社区技术分享--mysql-varchar-最佳长度评估实践)
        * [爱可生开源社区：技术分享 | MySQL 隐式转换必知必会](#爱可生开源社区技术分享--mysql-隐式转换必知必会)
          * [数据类型的隐式转换](#数据类型的隐式转换)
          * [字符集的隐式转换](#字符集的隐式转换)
        * [存储过程中的字符集转换](#存储过程中的字符集转换)
      * [基本使用](#基本使用)
      * [压缩表](#压缩表)
        * [压缩表性能监测](#压缩表性能监测)
      * [TEMPORARY临时表](#temporary临时表)
      * [FOREIGN KEY(外键)](#foreign-key外键)
        * [FOREIGN 增删改，修改权限](#foreign-增删改修改权限)
        * [爱可生开源社区：第05期：外键到底能不能用？](#爱可生开源社区第05期外键到底能不能用)
    * [Insert（插入）](#insert插入)
      * [INSERT... SELECT... 插入其他表的数据](#insert-select-插入其他表的数据)
      * [INSERT ... ON DUPLICATE KEY UPDATE ...](#insert--on-duplicate-key-update-)
    * [REPLACE（如果数据已经存在，则会先删除，再插入新的数据）](#replace如果数据已经存在则会先删除再插入新的数据)
    * [UPDATE（修改）](#update修改)
      * [case语句，在UPDATE多条语句时，可以按顺序执行，避免出错](#case语句在update多条语句时可以按顺序执行避免出错)
    * [Delete and TRUNCATE and Drop (删除)](#delete-and-truncate-and-drop-删除)
      * [删除重复的数据](#删除重复的数据)
    * [表设计](#表设计)
      * [范式设计](#范式设计)
      * [反范式设计](#反范式设计)
      * [大表处理](#大表处理)
        * [垂直拆分](#垂直拆分)
        * [水平拆分](#水平拆分)
        * [分区表](#分区表)
          * [爱可生开源社区：第37期：适当的使用 MySQL 原生表分区](#爱可生开源社区第37期适当的使用-mysql-原生表分区)
          * [爱可生开源社区：第38期：MySQL 时间类分区具体实现](#爱可生开源社区第38期mysql-时间类分区具体实现)
          * [爱可生开源社区：第39期：MySQL 时间类分区写 SQL 注意事项](#爱可生开源社区第39期mysql-时间类分区写-sql-注意事项)
          * [爱可生开源社区：第40期：MySQL 分区表案例分享](#爱可生开源社区第40期mysql-分区表案例分享)
          * [爱可生开源社区：第41期：MySQL 哈希分区表](#爱可生开源社区第41期mysql-哈希分区表)
          * [爱可生开源社区：第42期：MySQL 是否有必要多列分区](#爱可生开源社区第42期mysql-是否有必要多列分区)
  * [DDL (Data Definition Language) 数据定义语言](#ddl-data-definition-language-数据定义语言)
    * [VIEW (视图)](#view-视图)
    * [Function and Stored Procedure (函数 和 存储过程)](#function-and-stored-procedure-函数-和-存储过程)
      * [Stored Procedure (存储过程)](#stored-procedure-存储过程)
        * [trigger（触发器）](#trigger触发器)
          * [实例：下单减库存](#实例下单减库存)
      * [Function（函数）](#function函数)
        * [内置函数](#内置函数)
        * [自定义函数](#自定义函数)
    * [ALTER（修改表的列字段、存储引擎等）](#alter修改表的列字段存储引擎等)
      * [ALTER优化](#alter优化)
  * [INDEX(索引)](#index索引)
    * [SQL语法](#sql语法)
    * [索引长度限制](#索引长度限制)
    * [EXPLAIN](#explain)
      * [select_type各种值的解释](#select_type各种值的解释)
      * [type各种值的解释](#type各种值的解释)
      * [Extra各种值的解释](#extra各种值的解释)
      * [爱可生开源社区：技术分享 | explain format=json 详解](#爱可生开源社区技术分享--explain-formatjson-详解)
      * [对比有无索引的执行计划](#对比有无索引的执行计划)
    * [索引的分类](#索引的分类)
      * [按数据结构分类](#按数据结构分类)
        * [例子：先创建一张商品表，id 为主键](#例子先创建一张商品表id-为主键)
        * [为什么 MySQL InnoDB  选择 B+tree 作为索引的数据结构？](#为什么-mysql-innodb--选择-btree-作为索引的数据结构)
        * [HASH INDEX（哈希索引）](#hash-index哈希索引)
          * [自适应哈希(adaptive hash index)](#自适应哈希adaptive-hash-index)
        * [空间索引（R-Tree 索引）](#空间索引r-tree-索引)
      * [按字段特性分类](#按字段特性分类)
      * [按字段个数分类](#按字段个数分类)
        * [联合索引（二级索引）匹配](#联合索引二级索引匹配)
        * [索引下推（Using index condition）](#索引下推using-index-condition)
    * [索引优化](#索引优化)
      * [主键设计原则](#主键设计原则)
      * [前缀索引](#前缀索引)
      * [覆盖索引](#覆盖索引)
      * [防止索引失效](#防止索引失效)
  * [DCL (Data Control Language) 数据控制语言](#dcl-data-control-language-数据控制语言)
    * [帮助文档](#帮助文档)
    * [GRANT 用户权限设置](#grant-用户权限设置)
      * [爱可生开源社区：技术分享 | MySQL 授权表运维注意事项](#爱可生开源社区技术分享--mysql-授权表运维注意事项)
      * [设置权限允许远程的ip连接mysql](#设置权限允许远程的ip连接mysql)
    * [varibles（变量）](#varibles变量)
      * [sql_mode](#sql_mode)
  * [TCL（Transaction Control Language）事务](#tcltransaction-control-language事务)
    * [autocommit（自动提交）](#autocommit自动提交)
  * [规范和优化](#规范和优化)
    * [设计规范](#设计规范)
      * [安全规范](#安全规范)
      * [基础规范](#基础规范)
      * [命名规范](#命名规范)
      * [库设计规范](#库设计规范)
      * [表设计规范](#表设计规范)
      * [字段设计规范](#字段设计规范)
      * [索引设计规范](#索引设计规范)
      * [行为规范](#行为规范)
      * [流程规范](#流程规范)
    * [sql语句优化](#sql语句优化)
      * [一条查询语句的执行过程](#一条查询语句的执行过程)
      * [select优化](#select优化)
        * [dbaplus社群：MySQL用limit语句性能暴跌，怎么救？](#dbaplus社群mysql用limit语句性能暴跌怎么救)
      * [索引优化](#索引优化-1)
      * [group by 语句优化](#group-by-语句优化)
        * [无索引情况](#无索引情况)
        * [有索引的情况](#有索引的情况)
      * [增删改语句优化](#增删改语句优化)
      * [慢查询优化](#慢查询优化)
        * [mysqldumpslow：慢查询工具](#mysqldumpslow慢查询工具)
        * [pt-query-digest(percona-toolkit)：慢查询工具](#pt-query-digestpercona-toolkit慢查询工具)
      * [MySQL数据库联盟：如何通过ChatGPT优化MySQL的SQL语句](#mysql数据库联盟如何通过chatgpt优化mysql的sql语句)
      * [MySQL数据库联盟：全网最全MySQL Prompt](#mysql数据库联盟全网最全mysql-prompt)
      * [第三方优化工具](#第三方优化工具)
        * [MySQLTuner-perl：性能诊断工具，主要检查参数设置的合理性包括日志文件、存储引擎、安全建议及性能分析。针对潜在的问题，给出改进的建议。是mysql优化的好帮手。](#mysqltuner-perl性能诊断工具主要检查参数设置的合理性包括日志文件存储引擎安全建议及性能分析针对潜在的问题给出改进的建议是mysql优化的好帮手)
        * [tuning-primer.sh](#tuning-primersh)
        * [美团SQL优化工具SQLAdvisor](#美团sql优化工具sqladvisor)

<!-- mtoc-end -->

# mysql-sql语句

## 基本命令

### 连接数据库

| 参数 | 内容                 |
| ---- | -------------------- |
| -u   | 用户                 |
| -p   | 密码                 |
| -S   | 使用 socks 进行连接  |
| -h   | 连接指定 ip 的数据库 |
| -e   | 执行 shell 命令      |
| -P   | 连接端口             |

```sh

# 首先要连接进数据库
mysql -uroot
# 或者
mysql -uroot -pYouPassword

# -h 连接192.168.100.208主机的数据库
mysql -uroot -pYouPassword -h192.168.100.208 -P3306

# -S 使用socket连接(mysql不仅监听3306端口,还监听mysql.sock)
mysql -uroot -pYouPassword -S/tmp/mysql.sock

# -e 可以执行 sql 命令(这里是show databases;)
mysql -uroot -pYouPassword -e "show databases"
```

[如需,连接远程 server 的数据库 (可跳转至用户权限设置)](#user)

### 简单 SQL 命令

在 `linux` 终端输入的命令是 `shell` 命令

而 `SQL` 命令指进入数据库里的命令

- **注意:** SQL 命令后面要加 `;`

- SQL 命令**大小写不敏感** `CREATE` 或 `create` 都可以

- 而表(table)是要**区分大小写**的

```sql
-- 创建名为 tz 的数据库
create database tz;

-- 查看数据库
show databases;

-- 使用tz数据库
use tz;

-- 查看tz数据库里的表
show tables;

-- 查看 information_scema 数据库里的表
show tables from information_schema;

-- 查看数据库状态
show status;

-- 查看上一次查询成本(单位:数据页)
show status like 'Last_query_cost'

-- 插入次数;
show status like "com_insert%";

-- 删除次数;
show status like "com_delete%";

-- 查询次数;
show status like "com_select%";

-- 服务器运行时间
show status like "uptime";

-- 连接次数
show status like 'connections';

-- 插入次数;
show status like "com_insert%";

-- 删除次数;
show status like "com_delete%";

-- 查询次数;
show status like "com_select%";

-- 服务器运行时间
show status like "uptime";

-- 连接次数
show status like 'connections';

-- 查看数据库队列
show processlist;

-- 查看数据库保存目录
show variables like 'data%';

-- SQL FUNCTION
-- 查看当前使用哪个数据库
select database();

-- 查看当前登录用户
select user();

-- 查看数据库版本
select version();
```

### DBA 常用命令

- 1.连接MySQL数据库

    ```sql
    mysql -uroot -p'password'
    mysql -uroot -p'password' -h 127.0.0.1 -P 3306
    mysql -uroot -p'password' -S /path/to/mysql.sock
    ```

- 2.查看当前数据库中的会话状态
    ```sql
    show processlist;
    +----+------+-----------+------+---------+------+----------+------------------+----------+
    | Id | User | Host      | db   | Command | Time | State    | Info             | Progress |
    +----+------+-----------+------+---------+------+----------+------------------+----------+
    | 7  | root | localhost | test | Query   | 0    | starting | show processlist | 0.0      |
    +----+------+-----------+------+---------+------+----------+------------------+----------+
    ```

- 3.查看当前数据库中的活动会话（排除掉空闲Sleep状态的会话）
    ```sql
    select * from information_schema.processlist where command <> 'Sleep';
    +----+------+-----------+------+---------+------+----------------------+-----------------------------------------------------------------------+---------+-------+-----------+----------+-------------+-----------------+---------------+-----------+----------+-----------------------------------------------------------------------+------+
    | ID | USER | HOST      | DB   | COMMAND | TIME | STATE                | INFO                                                                  | TIME_MS | STAGE | MAX_STAGE | PROGRESS | MEMORY_USED | MAX_MEMORY_USED | EXAMINED_ROWS | SENT_ROWS | QUERY_ID | INFO_BINARY                                                           | TID  |
    +----+------+-----------+------+---------+------+----------------------+-----------------------------------------------------------------------+---------+-------+-----------+----------+-------------+-----------------+---------------+-----------+----------+-----------------------------------------------------------------------+------+
    | 7  | root | localhost | test | Query   | 0    | Filling schema table | select * from information_schema.processlist where command <> 'Sleep' | 1.258   | 0     | 0         | 0.000    | 146888      | 1042648         | 0             | 0         | 47       | select * from information_schema.processlist where command <> 'Sleep' | 7172 |
    +----+------+-----------+------+---------+------+----------------------+-----------------------------------------------------------------------+---------+-------+-----------+----------+-------------+-----------------+---------------+-----------+----------+-----------------------------------------------------------------------+------+

    -- 8.0以后版本建议使用performance_schema:
    select * from performance_schema.processlist where command <> 'Sleep';

    -- 排除掉自己的会话连接
    select * from information_schema.processlist where command <> 'Sleep' and id <> connection_id();

    -- 也可以通过其他条件来排查掉自己不想要的会话信息：如user in  或者 db in ,host等查询条件来过滤。
    ```

- 4.查看数据库的总大小

    ```sql
    -- 数据库总大小
    select round(sum(data_length+index_length)/1024/1024/1024,2) as 'DBSIZE_GB' from information_schema.tables;
    +-----------+
    | DBSIZE_GB |
    +-----------+
    | 0.15      |
    +-----------+

    -- 查看数据库中各个库的大小合计
    select table_schema,round(sum(data_length+index_length)/1024/1024/1024,3) as 'SIZE_GB' from information_schema.tables where table_schema not in ('sys','mysql','information_schema','performance_schema') group by table_schema ;
    +--------------+---------+
    | table_schema | SIZE_GB |
    +--------------+---------+
    | china        | 0.149   |
    | test         | 0.001   |
    | ytt_new2     | 0.000   |
    +--------------+---------+
    ```

- 查看数据库中的TOP 30大表信息
    ```sql
    select table_schema,table_name,round((data_length+index_length)/1024/1024,2) as 'SIZE_MB',table_rows,engine from information_schema.tables where table_schema not in ('sys','mysql','information_schema','performance_schema') order by 3 desc limit 30 ;
    +--------------+-----------------+---------+------------+--------+
    | table_schema | table_name      | SIZE_MB | table_rows | engine |
    +--------------+-----------------+---------+------------+--------+
    | china        | cnarea_2019     | 152.72  | 779079     | InnoDB |
    | test         | t1_min          | 0.16    | 2500       | InnoDB |
    | test         | t1_max          | 0.16    | 2500       | InnoDB |
    | test         | t1              | 0.09    | 1000       | InnoDB |
    | test         | foo             | 0.06    | 1000       | InnoDB |
    | test         | new             | 0.05    | 0          | InnoDB |
    ```

- 7.查看表和索引的统计信息：
    ```sql
    -- 表统计信息：
    select * from mysql.innodb_table_stats where database_name='db_name' and table_name='table_name';

    -- 索引统计信息：
    select * from mysql.innodb_index_stats where database_name='' and table_name='' and index_name='idx_name';
    ```

- 8.查询锁等待时持续间大于20秒的SQL信息
    ```sql
     SELECT trx_mysql_thread_id AS PROCESSLIST_ID,
           NOW(),
           TRX_STARTED,
           TO_SECONDS(now())-TO_SECONDS(trx_started) AS TRX_LAST_TIME ,
           USER,
           HOST,
           DB,
           TRX_QUERY
    FROM INFORMATION_SCHEMA.INNODB_TRX trx
    JOIN sys.innodb_lock_waits lw ON trx.trx_mysql_thread_id=lw.waiting_pid
    JOIN INFORMATION_SCHEMA.processlist pcl ON trx.trx_mysql_thread_id=pcl.id
    WHERE trx_mysql_thread_id != connection_id()
      AND TO_SECONDS(now())-TO_SECONDS(trx_started) >= 20 ;
    ```

- 9.查询MySQL锁等待表的详细信息
    ```sql
    -- sys库锁等待表：
    select * from sys.innodb_lock_waits\G
    ```

- 10.查询长事务SQL
    ```sql
    -- 长事务（包含未关闭的事务）
    SELECT thr.processlist_id AS mysql_thread_id,
           concat(PROCESSLIST_USER,'@',PROCESSLIST_HOST) User,
           Command,
           FORMAT_PICO_TIME(trx.timer_wait) AS trx_duration,
           current_statement as `latest_statement`
      FROM performance_schema.events_transactions_current trx
      INNER JOIN performance_schema.threads thr USING (thread_id)
      LEFT JOIN sys.processlist p ON p.thd_id=thread_id
     WHERE thr.processlist_id IS NOT NULL
       AND PROCESSLIST_USER IS NOT NULL
       AND trx.state = 'ACTIVE'
     GROUP BY thread_id, timer_wait
     ORDER BY TIMER_WAIT DESC LIMIT 10;
    ```

- 11.查看当前DDL执行的进度
    ```sql
    use performance_schema;

    select * from setup_instruments where name like 'stage/innodb/alter%';
    +------------------------------------------------------+---------+-------+
    | NAME                                                 | ENABLED | TIMED |
    +------------------------------------------------------+---------+-------+
    | stage/innodb/alter table (end)                       | YES     | YES   |
    | stage/innodb/alter table (insert)                    | YES     | YES   |
    | stage/innodb/alter table (log apply index)           | YES     | YES   |
    | stage/innodb/alter table (log apply table)           | YES     | YES   |
    | stage/innodb/alter table (merge sort)                | YES     | YES   |
    | stage/innodb/alter table (read PK and internal sort) | YES     | YES   |
    +------------------------------------------------------+---------+-------+

    -- 如果上面查询结果为NO，则需要做如下配置：
    update set_instrucments set enabled = 'YES' where name like 'stage/innodb/alter%';
    update set_consumers set enabled = 'YES' where name like '%stages%';

    select * from setup_consumers where name like '%stages%';
    +----------------------------+---------+
    | NAME                       | ENABLED |
    +----------------------------+---------+
    | events_stages_current      | NO      |
    | events_stages_history      | NO      |
    | events_stages_history_long | NO      |
    +----------------------------+---------+

    -- 查询DDL执行的进度：
    select stmt.sql_text,
           stage.event_name,
           concat(work_completed, '/', work_estimated) as progress,
           concat(round(100 * work_completed / work_estimated, 2), ' %') as processing_pct,
           sys.format_time(stage.timer_wait) as time_costs,
           concat(round((stage.timer_end - stmt.timer_start) / 1e12 *
                        (work_estimated - work_completed) / work_completed,
                        2),
                  ' s') as remaining_seconds
      from performance_schema.events_stages_current     stage,
           performance_schema.events_statements_current stmt
     where stage.thread_id = stmt.thread_id
       and stage.nesting_event_id = stmt.event_id\G
    ```

- 12.执行次数最多的TOP 10 SQL
    ```sql
    SELECT
        SCHEMA_NAME,
        DIGEST_TEXT,
        COUNT_STAR,
        FIRST_SEEN,
        LAST_SEEN
    FROM
        performance_schema.events_statements_summary_by_digest
    ORDER BY
        COUNT_STAR DESC
    LIMIT 10;
    ```

- 13.平均响应时间最长的TOP 10 SQL
    ```sql
    SELECT
        SCHEMA_NAME,
        DIGEST_TEXT,
        AVG_TIMER_WAIT,
        COUNT_STAR
    FROM
        performance_schema.events_statements_summary_by_digest
    ORDER BY
        AVG_TIMER_WAIT DESC
    LIMIT 10;
    ```

- 14.排序次数最多的TOP 10 SQL
    ```sql
    SELECT
        SCHEMA_NAME,
        DIGEST_TEXT,
        SUM_SORT_ROWS
    FROM
        performance_schema.events_statements_summary_by_digest
    ORDER BY
        SUM_SORT_ROWS DESC
    LIMIT 10;
    ```

- 15.扫描记录数最多的 TOP 10 SQL
    ```sql
    SELECT
        SCHEMA_NAME,
        DIGEST_TEXT,
        SUM_ROWS_EXAMINED
    FROM
        performance_schema.events_statements_summary_by_digest
    ORDER BY
        SUM_ROWS_EXAMINED DESC
    LIMIT 10;
    ```

- 16.使用临时表最多的TOP 10 SQL
    ```sql
    SELECT
        SCHEMA_NAME,
        DIGEST_TEXT,
        SUM_CREATED_TMP_TABLES,
        SUM_CREATED_TMP_DISK_TABLES
    FROM
        performance_schema.events_statements_summary_by_digest
    ORDER BY
        SUM_CREATED_TMP_TABLES DESC
    LIMIT 10;
    ```

- 17.查询从未使用过的索引
    ```sql
    -- 从未使用过的索引：未使用索引建议直接删除，多余索引如不使用会影响增删改性能，且索引占用磁盘空间。
    select * from schema_unused_indexes where object_schema not in ('performance_schema');
    (1146, "Table 'performance_schema.schema_unused_indexes' doesn't exist")
    ```

- 18.查询冗余索引
    ```sql
    -- 冗余索引建议删除
    SELECT
        a.TABLE_SCHEMA,
        a.TABLE_NAME,
        a.INDEX_NAME,
        GROUP_CONCAT(a.COLUMN_NAME ORDER BY a.SEQ_IN_INDEX) AS index_columns,
        b.INDEX_NAME AS redundant_index_name,
        GROUP_CONCAT(b.COLUMN_NAME ORDER BY b.SEQ_IN_INDEX) AS redundant_index_columns
    FROM
        information_schema.STATISTICS a
    JOIN
        information_schema.STATISTICS b
    ON
        a.TABLE_SCHEMA = b.TABLE_SCHEMA
        AND a.TABLE_NAME = b.TABLE_NAME
        AND a.INDEX_NAME < b.INDEX_NAME
        AND a.SEQ_IN_INDEX = b.SEQ_IN_INDEX
        AND a.COLUMN_NAME = b.COLUMN_NAME
    GROUP BY
        a.TABLE_SCHEMA,
        a.TABLE_NAME,
        a.INDEX_NAME,
        b.INDEX_NAME
    HAVING
        COUNT(*) = COUNT(b.COLUMN_NAME) - 1;
    ```
- 19.查询数据库中没有主键的表
    ```sql
    SELECT A.table_schema, A.table_name
      FROM information_schema.tables AS A
           LEFT JOIN (SELECT table_schema, table_name FROM information_schema.statistics WHERE index_name = 'PRIMARY') AS B
		    ON A.table_schema = B.table_schema AND A.table_name = B.table_name
	       WHERE A.table_schema NOT IN ('information_schema' , 'mysql','performance_schema', 'sys')
	       AND A.table_type='BASE TABLE'
	       AND B.table_name IS NULL;
    ```

- 20.查询非InnoDB表
    ```sql
    SELECT table_schema,table_name,engine FROM information_schema.tables where table_schema not in ('mysql','sys','information_schema','performance_schema') and engine!='InnoDB';
    ```

- 21.查询从库状态信息（主从状态，延迟）
    ```sql
    show slave status\G
    ```

- 22.查看慢日志信息：是否开启及慢日志的位置
    ```sql
    show global variables like 'slow%';
    +---------------------+-------------------------------+
    | Variable_name       | Value                         |
    +---------------------+-------------------------------+
    | slow_launch_time    | 2                             |
    | slow_query_log      | ON                            |
    | slow_query_log_file | /var/log/mysql/mysql-slow.log |
    +---------------------+-------------------------------+
    ```

### 其他命令

```sh
# 关闭mysql服务
mysqladmin -uroot -pYouPassword shutdown

# 安全模式启动
mysqld_safe --defaults-file=/etc/my.cnf &
```

### [MySQL数据库联盟：五种不输入密码登录MySQL的方法，你知道几种？](https://mp.weixin.qq.com/s/RJr5AmmwDMWF64b4f47Mbg)

### 如何正确地关闭 MySQL 数据库？99%的 DBA 都是错的！

- [InsideMySQL：如何正确地关闭 MySQL 数据库？99%的 DBA 都是错的！](https://mp.weixin.qq.com/s?__biz=MjM5MjIxNDA4NA==&mid=2649743926&idx=1&sn=e79bfb7c2ef814f2652e52fae92d7218&chksm=beb2ff1d89c5760bc98611ee8a6aafe26a4dc1f5cff4e121a98ba1fcde4eabc54a6d276783b0&cur_album_id=1501021509451055104&scene=190#rd)

- 生产环境，正确关闭 MySQL 数据库的方法有且仅有：

    ```sh
    kill -9 `pidof mysqld`
    ```

- 以下3条都是同样的命令，也就是所谓的关闭 MySQL 数据库的命令，只是形式略有不同。

    ```sh
    mysqladmin shutdown
    service mysqld stop # （或类似命令）
    kill `pidof mysqld` # 不考虑mysqld_safe
    ```

    - 这题的底层逻辑是如果在生产环境，MySQL 数据库肯定都是有主从复制的架构，而且大概率是半同步的复制架构。
    - 这时问题就来了，上述1、2、3正常关闭的 MySQL 命令，会导致 Master 节点不等待半同步 Slave 节点是否收到二进制日志的 ACK 回包，而选择直接停止数据库服务，从而可能导致主从数据不一致！！！

- 因此，从数据库规范角度看，为避免线上数据一致性问题，DBA 关闭数据库使用的命令有且仅有：

    ```sh
    kill -9 `pidof mysqld`
    ```

    - 有同学会说，kill -9 是强制关闭命令，只适用于无法正常关闭数据库的场景，一般并不推荐使用。
        - 的确，kill -9 会立即关闭数据库，脏页没有在关闭时刷新，重启数据库后需要通过重做日志恢复到最新的数据。
        - 然而，kill -9 命令并不会导致 Master 节点少数据，也不会导致 Slave 节点少数据。
        - 因此，它才是最安全和正确的命令。
        - 对数据库而言，数据一致性与可靠性高于一切。

## 下载数据库进行 SQL 语句 学习

```sql
# 连接数据库后,创建china数据库
create database china;
```

```sh
# 下载2019年中国地区表,一共有 783562 条数据
git clone https://github.com/kakuilan/china_area_mysql.git
# 如果网速太慢,使用这条国内通道
git clone https://gitee.com/qfzya/china_area_mysql.git

# 导入表到 china 库
cd china_area_mysql
mysql -uroot -pYouPassward china < cnarea20191031.sql
```

## DQL (Data Query Language) 数据查询语言

- DQL用于从数据库中检索信息，而不进行任何数据更改。

### SELECT

**语法:**

> ```sql
> SELECT 列名称 FROM 表名称
> ```

- 语句顺序为: `FROM` -> `WHERE` -> `SELECT`

---

```sql
-- 连接数据库后,进入 china 数据库
use china;

-- 查看表 cnarea_2019 的字段(列)
desc cnarea_2019

-- 将 cnarea_2019 表改名为 ca ,方便输入
alter table cnarea_2019 rename ca;
-- 改回来
alter table ca rename cnarea_2019;

-- 从表 cnarea_2019 选取所有列(*表示所有列)
select *
from cnarea_2019;

-- 如果刚才将表改成 ca 名,就是以下命令
select *
from ca;

-- 从表 cnarea_2019 选取 name 列
select name
from cnarea_2019;

-- 从表 cnarea_2019 选取 name 和 id 列
select id,name
from cnarea_2019;

-- distinct 过滤重复的数据
select distinct level
from cnarea_2019;

-- limit 只显示前2行
select *
from cnarea_2019
limit 2;

-- limit 选取所有列,但只显示100到70000行
select * from cnarea_2019
limit 100,70000;

-- LEFT() 选取name列, 但只显示前2字符
SELECT LEFT(name, 2)
FROM cnarea_2019

-- RIGHT() 选取name列, 但只显示后3字符
SELECT RIGHT(name, 3)
FROM cnarea_2019
```

#### where: 行(元组)条件判断

**语法:**

> ```sql
> SELECT 列名称 FROM 表名称 WHERE 列名称 条件
> ```

---


```sql
-- 结尾处加入 \G 以列的方式显示
select * from cnarea_2019
where id=1\G;

MariaDB [china]> select * from cnarea_2019 where id=1\G;
*************************** 1. row ***************************
         id: 1
      level: 0
parent_code: 0
  area_code: 110000000000
   zip_code: 000000
  city_code:
       name: 北京市
 short_name: 北京
merger_name: 北京
     pinyin: BeiJing
        lng: 116.407526
        lat: 39.904030
```

```sql
-- 选取 id 小于10的数据
select * from cnarea_2019
where id < 10;

-- 选取 10<=id<=30 的数据
select * from cnarea_2019
where id<=30 and id>=10;

-- 选取 id 等于10 和 id等于20 的数据
select * from cnarea_2019
where id in (10,20);

-- 选取 not null(非空) 和 id 小于 10 的数据
select * from ca
where id is not null
and id < 10;

-- 选取 50行到55行的数据
SELECT * FROM cnarea_2019
WHERE id BETWEEN 50 AND 55;
```

#### Order by (排序)

**语法:**

> ```sql
> SELECT 列名称 FROM 表名称 ORDER BY 列名称
> # or
> SELECT 列名称 FROM 表名称 WHERE 列名称 条件 ORDER BY 列名称
> ```

---

```sql
-- 以 level 字段进行排序
select * from cnarea_2019
order by level;

-- 选取 id<=10 ,以 level 字段进行排序
select * from cnarea_2019
where id<=10
order by level;

-- desc 降序
select * from cnarea_2019
where id<=10
order by level desc;

-- level 降序,再以 id 顺序显示
select * from cnarea_2019
where id<=10
order by level desc,
id ASC;
```

#### regexp (正则表达式)

```sql
-- 选取以 '广州' 开头的 name 字段
select name from cnarea_2019
where name regexp '^广州';

-- 选取包含 '广州' 的name 字段
select name from cnarea_2019
where name regexp '.*广州';
```

#### Group by (分组)

- 创建表people, people1

```sql
-- 创建表people
create table people(
    `id` int (8) auto_increment,
    `name` varchar(50),
    `salary` varchar(50),
    primary key (`id`)
);

-- 插入数据
INSERT INTO people (name, salary) VALUES
('a1','1000'),
('a2','2000'),
('a3','3000'),
('b1','1000'),
('b2','2000'),
('b3','3000'),
('c1','1000'),
('c2','2000'),
('c3','3000');

-- 创建表people1
CREATE TABLE people1(
    `id` int (8) AUTO_INCREMENT,
    `name` varchar(50),
    `salary` varchar(50),
    primary key (`id`)
);

-- 插入数据
INSERT INTO people1 (name, salary) VALUES
('c1','1000'),
('c2','2000'),
('c3','3000'),
('d', 3000),
(null,'3000'),
('d', null),
(null, null);


-- 统计salary(工资)大于1000的人数
SELECT salary, COUNT(salary) FROM people
GROUP BY salary
HAVING salary > 1000;
+--------+---------------+
| salary | COUNT(salary) |
+--------+---------------+
| 2000   | 3             |
| 3000   | 3             |
+--------+---------------+

-- 统计salary为1000的人数
SELECT COUNT(name) FROM people
WHERE salary = 1000;
+-------------+
| COUNT(name) |
+-------------+
| 3           |
+-------------+

-- LEFT() 选取name列, 但只显示前1字符。统计以开头为a、b、c作为类别的工资
SELECT LEFT(name,1) ,SUM(salary) FROM people
GROUP BY LEFT(name, 1)
```

##### WITH ROLLUP（汇总）

```sql
CREATE TABLE sales(
    `id` int (8) AUTO_INCREMENT,
    `name` varchar(50),
    `color` varchar(50),
    `quantitty` int (8),
    primary key (`id`)
);

-- 插入数据
INSERT INTO sales (name, color, quantitty) VALUES
('shirt', 'black', 10),
('shirt', 'white', 8),
('shirt', 'red', 1),
('dress', 'black', 9),
('dress', 'white', 10),
('dress', 'red', 5),
('skirt', 'black', 1),
('skirt', 'white', 5),
('skirt', 'red', 5);

-- name
SELECT name, SUM(quantitty) FROM sales
GROUP BY name
+-------+----------------+
| name  | SUM(quantitty) |
+-------+----------------+
| dress | 24             |
| shirt | 19             |
| skirt | 11             |
+-------+----------------+
-- 使用 WITH ROLLUP 汇总
SELECT name, SUM(quantitty) FROM sales
GROUP BY name
WITH ROLLUP
+--------+----------------+
| name   | SUM(quantitty) |
+--------+----------------+
| dress  | 24             |
| shirt  | 19             |
| skirt  | 11             |
| <null> | 54             |
+--------+----------------+

-- color
SELECT color, SUM(quantitty) FROM sales
GROUP BY color
+-------+----------------+
| color | sum(quantitty) |
+-------+----------------+
| black | 20             |
| red   | 11             |
| white | 23             |
+-------+----------------+
-- 使用 WITH ROLLUP 汇总
SELECT color, SUM(quantitty) FROM sales
GROUP BY color
WITH ROLLUP
+--------+----------------+
| color  | SUM(quantitty) |
+--------+----------------+
| black  | 20             |
| red    | 11             |
| white  | 23             |
| <null> | 54             |
+--------+----------------+

-- 不使用WITH ROLLUP 统计每个颜色的销售数量,以及总量
SELECT name, color, SUM(quantitty) FROM sales
GROUP BY color, name

+-------+-------+----------------+
| name  | color | SUM(quantitty) |
+-------+-------+----------------+
| dress | black | 9              |
| shirt | black | 10             |
| skirt | black | 1              |
| dress | red   | 5              |
| shirt | red   | 1              |
| skirt | red   | 5              |
| dress | white | 10             |
| shirt | white | 8              |
| skirt | white | 5              |
+-------+-------+----------------+

-- WITH ROLLUP 统计每个颜色的销售数量,以及总量
SELECT name, color, SUM(quantitty) FROM sales
GROUP BY color, name
WITH ROLLUP

+--------+--------+----------------+
| name   | color  | SUM(quantitty) |
+--------+--------+----------------+
| dress  | black  | 9              |
| shirt  | black  | 10             |
| skirt  | black  | 1              |
| <null> | black  | 20             |
| dress  | red    | 5              |
| shirt  | red    | 1              |
| skirt  | red    | 5              |
| <null> | red    | 11             |
| dress  | white  | 10             |
| shirt  | white  | 8              |
| skirt  | white  | 5              |
| <null> | white  | 23             |
| <null> | <null> | 54             |
+--------+--------+----------------+

-- name 统计每个品类的销售数量, 以及总量
SELECT name, color, SUM(quantitty) FROM sales
GROUP BY name, color
WITH ROLLUP

+--------+--------+----------------+
| name   | color  | SUM(quantitty) |
+--------+--------+----------------+
| dress  | black  | 9              |
| dress  | red    | 5              |
| dress  | white  | 10             |
| dress  | <null> | 24             |
| shirt  | black  | 10             |
| shirt  | red    | 1              |
| shirt  | white  | 8              |
| shirt  | <null> | 19             |
| skirt  | black  | 1              |
| skirt  | red    | 5              |
| skirt  | white  | 5              |
| skirt  | <null> | 11             |
| <null> | <null> | 54             |
+--------+--------+----------------+

-- LEFT() 选取name列, 但只显示前1字符。统计以开头为a、b、c为类别的工资，并以此计算总工资
SELECT LEFT(name, 1) ,SUM(salary) FROM people
GROUP BY LEFT(name, 1)
WITH ROLLUP
+---------------+-------------+
| LEFT(name, 1) | SUM(salary) |
+---------------+-------------+
| a             |  6000.0     |
| b             |  6000.0     |
| c             |  6000.0     |
| <null>        | 18000.0     |
+---------------+-------------+

-- LEFT() 选取name列, 但只显示前1字符。统计以开头为a、b、c的工资，并以此计算总工资
SELECT name ,SUM(salary) FROM people
GROUP BY LEFT(name, 1),salary
WITH ROLLUP
+------+-------------+
| name | SUM(salary) |
+------+-------------+
| a1   |  1000.0     |
| a2   |  2000.0     |
| a3   |  3000.0     |
| a3   |  6000.0     |
| b1   |  1000.0     |
| b2   |  2000.0     |
| b3   |  3000.0     |
| b3   |  6000.0     |
| c1   |  1000.0     |
| c2   |  2000.0     |
| c3   |  3000.0     |
| c3   |  6000.0     |
| c3   | 18000.0     |
+------+-------------+
```

##### [dbaplus社群：MySQL 中的 distinct 和 group by 哪个效率更高？太刁钻了！](https://mp.weixin.qq.com/s/bgDseZM45UagxrLnnZrvwg)


- `distinct`的使用

    > `DISTINCT` 关键词用于返回唯一不同的值。放在查询语句中的第一个字段前使用，且作用于主句所有列。

    - `distinct`单列去重

        - 语法：

            ```sql
            SELECT DISTINCT columns FROM table_name WHERE where_conditions;
            ```

        - 如果列具有NULL值，并且对该列使用`DISTINCT`子句，MySQL将保留一个`NULL`值，并删除其它的`NULL`值，因为`DISTINCT`子句将所有`NULL`值视为相同的值。

            ```sql
            select distinct age from student;
            +------+
            | age  |
            +------+
            |   10 |
            |   12 |
            |   11 |
            | NULL |
            +------+
            4 rows in set (0.01 sec)
            ```

    - `distinct`多列去重

        - 语法：

            ```sql
            SELECT DISTINCT column1,column2 FROM table_name WHERE where_conditions;
            ```

        - `distinct`多列的去重，则是根据指定的去重的列信息来进行，即**只有所有指定的列信息都相同**，才会被认为是重复的信息。

            ```sql
            mysql> select distinct sex,age from student;
            +--------+------+
            | sex    | age  |
            +--------+------+
            | male   |   10 |
            | female |   12 |
            | male   |   11 |
            | male   | NULL |
            | female | 11 |
            +--------+------+
            5 rows in set (0.02 sec)
            ```

- `group by`的使用

    > 对于基础去重来说，group by的使用和distinct类似:

    - 单列去重

        - 语法：

            ```sql
            SELECT columns FROM table_name WHERE where_conditions GROUP BY columns;
            ```

        - 执行：

            ```sql
            mysql> select age from student group by age;
            +------+
            | age  |
            +------+
            |   10 |
            |   12 |
            |   11 |
            | NULL |
            +------+
            4 rows in set (0.02 sec)
            ```

    - 多列去重


        - 语法：

            ```sql
            SELECT columns FROM table_name WHERE where_conditions GROUP BY columns;
            ```


        - 执行：

            ```sql
            mysql> select sex,age from student group by sex,age;
            +--------+------+
            | sex    | age  |
            +--------+------+
            | male   |   10 |
            | female |   12 |
            | male   |   11 |
            | male   | NULL |
            | female |   11 |
            +--------+------+
            5 rows in set (0.03 sec)
            ```

        - 区别示例

            - 两者的语法区别在于，`group by`可以进行单列去重，`group by`的原理是先对结果进行分组排序，然后返回每组中的第一条数据。且是根据`group by`的后接字段进行去重的。

            - 例如：

                ```sql
                mysql> select sex,age from student group by sex;
                +--------+-----+
                | sex    | age |
                +--------+-----+
                | male   |  10 |
                | female |  12 |
                +--------+-----+
                2 rows in set (0.03 sec)
                ```


- `distinct`和`group by`原理

    - 在大多数例子中，`DISTINCT`可以被看作是特殊的`GROUP BY`，它们的实现都基于分组操作，且都可以通过松散索引扫描、紧凑索引扫描(关于索引扫描的内容会在其他文章中详细介绍，就不在此细致介绍了)来实现。

    - `DISTINCT`和`GROUP BY`都是可以使用索引进行扫描搜索的。

        - 例如以下两条sql（只单单看表格最后extra的内容），我们对这两条sql进行分析，可以看到，在extra中，这两条sql都使用了紧凑索引扫描`Using index for group-by`。

            - 所以，在一般情况下，对于相同语义的`DISTINCT`和`GROUP BY`语句，我们可以对其使用相同的索引优化手段来进行优化。

            ```sql
            -- group by例子
            mysql> explain select int1_index from test_distinct_groupby group by int1_index;
            +----+-------------+-----------------------+------------+-------+---------------+---------+---------+------+------+----------+--------------------------+
            | id | select_type | table                 | partitions | type  | possible_keys | key     | key_len | ref  | rows | filtered | Extra                    |
            +----+-------------+-----------------------+------------+-------+---------------+---------+---------+------+------+----------+--------------------------+
            |  1 | SIMPLE      | test_distinct_groupby | NULL       | range | index_1       | index_1 | 5       | NULL |  955 |   100.00 | Using index for group-by |
            +----+-------------+-----------------------+------------+-------+---------------+---------+---------+------+------+----------+--------------------------+
            1 row in set (0.05 sec)
            ```

            ```sql
            -- distinct例子
            mysql> explain select distinct int1_index from test_distinct_groupby;
            +----+-------------+-----------------------+------------+-------+---------------+---------+---------+------+------+----------+--------------------------+
            | id | select_type | table                 | partitions | type  | possible_keys | key     | key_len | ref  | rows | filtered | Extra                    |
            +----+-------------+-----------------------+------------+-------+---------------+---------+---------+------+------+----------+--------------------------+
            |  1 | SIMPLE      | test_distinct_groupby | NULL       | range | index_1       | index_1 | 5       | NULL |  955 |   100.00 | Using index for group-by |
            +----+-------------+-----------------------+------------+-------+---------------+---------+---------+------+------+----------+--------------------------+
            1 row in set (0.05 sec)
            ```

- 隐式排序

    - 但对于`GROUP BY`来说，在MYSQL8.0之前，默认会依据字段进行隐式排序。

        - 可以看到，下面这条sql语句在使用了临时表的同时，还进行了filesort。

            ```sql
            mysql> explain select int6_bigger_random from test_distinct_groupby GROUP BY int6_bigger_random;
            +----+-------------+-----------------------+------------+------+---------------+------+---------+------+-------+----------+---------------------------------+
            | id | select_type | table                 | partitions | type | possible_keys | key  | key_len | ref  | rows  | filtered | Extra                           |
            +----+-------------+-----------------------+------------+------+---------------+------+---------+------+-------+----------+---------------------------------+
            |  1 | SIMPLE      | test_distinct_groupby | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 97402 |   100.00 | Using temporary; Using filesort |
            +----+-------------+-----------------------+------------+------+---------------+------+---------+------+-------+----------+---------------------------------+
            1 row in set (0.04 sec)
            ```

    - 所以，在Mysql8.0之前,Group by会默认根据作用字段（Group by的后接字段）对结果进行排序。在能利用索引的情况下，Group by不需要额外进行排序操作；但当无法利用索引排序时，Mysql优化器就不得不选择通过使用临时表然后再排序的方式来实现GROUP BY了。

        - 且当结果集的大小超出系统设置临时表大小时，Mysql会将临时表数据copy到磁盘上面再进行操作，语句的执行效率会变得极低。这也是Mysql选择将此操作（隐式排序）弃用的原因。

###### 结论

- 在语义相同，有索引的情况下：

    - `group by`和`distinct`都能使用索引，效率相同。因为`group by`和`distinct`近乎等价，`distinct`可以被看做是特殊的`group by`。

- 在语义相同，无索引的情况下：

    - `distinct`效率高于`group by`。原因是`distinct` 和 `group by`都会进行分组操作，但`group by`在Mysql8.0之前会进行隐式排序，导致触发filesort，sql执行效率低下。

- 但从Mysql8.0开始，Mysql就删除了隐式排序，所以，此时在语义相同，无索引的情况下，`group by`和`distinct`的执行效率也是近乎等价的。

- 推荐`group by`的原因

    - `group by`语义更为清晰
    - `group by`可对数据进行更为复杂的一些处理
    - 相比于`distinct`来说，`group by`的语义明确。且由于`distinct`关键字会对所有字段生效，在进行复合业务处理时，`group by`的使用灵活性更高，`group by`能根据分组情况，对数据进行更为复杂的处理，例如通过having对数据进行过滤，或通过聚合函数对数据进行运算。

#### 子查询

##### IN, NOT IN

- `()`: 表示集合

- `IN`: 判断在集合中的字段

- `NOT IN`: 判断不在集合中的字段

```sql
-- IN
SELECT * FROM people
WHERE salary IN (1000, 3000);

-- NOT IN
SELECT * FROM people
WHERE salary NOT IN (1000, 3000);

-- 子查询1000工资的人
SELECT name FROM people
WHERE name IN
    (SELECT name FROM people
    WHERE salary = 1000);
-- 等同于以上
SELECT name FROM people
WHERE name IN ('a1', 'b1', 'c1');

+------+
| name |
+------+
| a1   |
| b1   |
| c1   |
+------+
```

##### 标量子查询

> 可以出现在 `SELECT`, `HAVING`, `WHERE`

```sql
-- 注意：不能超过1个字段，我这里为count(*)
SELECT id, name,
    (SELECT count(*) FROM people1)
    AS count_people1
FROM people

+----+------+---------------+
| id | name | count_people1 |
+----+------+---------------+
| 1  | a1   | 7             |
| 2  | a2   | 7             |
| 3  | a3   | 7             |
| 4  | b1   | 7             |
| 5  | b2   | 7             |
| 6  | b3   | 7             |
| 7  | c1   | 7             |
| 8  | c2   | 7             |
| 9  | c3   | 7             |
+----+------+---------------+

-- 超过1个字段报错
SELECT id, name,
    (SELECT count(*) FROM people1)
    AS count_people1
FROM people
(1241, 'Operand should contain 1 column(s)')

-- 查询时，使用REPLACE() 将name字段中带有c的字符，改为d字符。
SELECT id,
    REPLACE(name, 'c', 'd')
    AS name
FROM people
+----+------+
| id | name |
+----+------+
| 1  | a1   |
| 2  | a2   |
| 3  | a3   |
| 4  | b1   |
| 5  | b2   |
| 6  | b3   |
| 7  | d1   |
| 8  | d2   |
| 9  | d3   |
+----+------+
-- 查询时，使用REPLACE() 并不会修改实际数据
SELECT id,name FROM people
+----+------+
| id | name |
+----+------+
| 1  | a1   |
| 2  | a2   |
| 3  | a3   |
| 4  | b1   |
| 5  | b2   |
| 6  | b3   |
| 7  | c1   |
| 8  | c2   |
| 9  | c3   |
+----+------+
```

##### 关量子查询

```sql
-- IN()函数子查询
SELECT * FROM people WHERE id IN
(SELECT id FROM people1
WHERE id > 5);

-- 使用关联子查询代替以上IN函数子查询.结果一样, 效率更高
SELECT * FROM people WHERE EXISTS
(SELECT * FROM people1
WHERE id > 5
AND people.id = people1.id);

+----+------+--------+
| id | name | salary |
+----+------+--------+
| 6  | b3   | 3000   |
| 7  | c1   | 1000   |
+----+------+--------+
```

##### with(临时表)

```sql
-- 创建临时表p
WITH p (name, salary) AS
    (SELECT name, salary FROM people)
SELECT * FROM p;

-- with 实现people, people1的内连接
WITH p (id, name) AS
    (SELECT id, name FROM people),
    p1 (id, name) AS
    (SELECT id, name FROM people1)
SELECT * FROM p, p1
    WHERE p.id = p1.id;

-- 等同于以上
SELECT p.id, p.name, p1.id, p1.name
FROM people as p
INNER JOIN people1 as p1
ON p.id = p1.id;

+----+------+----+--------+
| id | name | id | name   |
+----+------+----+--------+
| 1  | a1   | 1  | c1     |
| 2  | a2   | 2  | c2     |
| 3  | a3   | 3  | c3     |
| 4  | b1   | 4  | d      |
| 5  | b2   | 5  | <null> |
| 6  | b3   | 6  | d      |
| 7  | c1   | 7  | <null> |
+----+------+----+--------+
```

#### 集合操作

> 默认去除重复行

##### UNION(并操作)

```sql
SELECT name FROM people
UNION
SELECT name FROM people1

+--------+
| name   |
+--------+
| a1     |
| a2     |
| a3     |
| b1     |
| b2     |
| b3     |
| c1     |
| c2     |
| c3     |
| d      |
| <null> |
+--------+

-- UNION ALL保留重复行
SELECT name FROM people
UNION ALL
SELECT name FROM people1
```

##### EXCEPT(差操作)

> 从左边的集合去除右边的集合

```sql
-- people表去除people1表的重复行

SELECT name FROM people
EXCEPT
SELECT name FROM people1

+------+
| name |
+------+
| a1   |
| a2   |
| a3   |
| b1   |
| b2   |
| b3   |
+------+
```

##### INTERSECT(交操作)

```sql
SELECT name FROM people
INTERSECT
SELECT name FROM people1

+------+
| name |
+------+
| c1   |
| c2   |
| c3   |
+------+
```

#### 聚和函数(aggregation)

**语法**

> ```sql
> SELECT function(列名称) FROM 表名称
> ```

##### 基本聚和函数

| 聚集函数             | 操作                  |
|----------------------|-----------------------|
| MAX()                | 最大值                |
| MIN()                | 最小值                |
| SUM()                | 总值                  |
| AVG()                | 平均值                |
| COUNT(1)             | 总行数,等同于COUNT(*) |
| COUNT(DISTINCT name) | 总行数,去除重复行       |

```sql
-- MAX(), MIN()
SELECT MAX(id),MIN(level) as max
FROM cnarea_2019;

-- 选取 level 的平均值和 id 的总值
SELECT SUM(id),AVG(level)
from cnarea_2019;

-- 查看总行数
SELECT COUNT(1) as name from cnarea_2019;

-- 统计 level 的个数
SELECT COUNT(DISTINCT level) as totals from cnarea_2019;

-- 通过标量子查询，查询salary大于salary平均数
SELECT * FROM people WHERE salary >
(SELECT avg(salary) FROM people);
-- 又或者使用自定义变量
SET @avg_people := (SELECT AVG(salary) FROM people);
SELECT * FROM people
WHERE salary > @avg_people;
```

- `count()`：统计不为 `NULL` 的记录有多少个

    - [小林coding：哪种 count 性能最好？](https://xiaolincoding.com/mysql/index/count.html#%E5%93%AA%E7%A7%8D-count-%E6%80%A7%E8%83%BD%E6%9C%80%E5%A5%BD)

    - 结论：性能排行`count(*) = count(1) > count(主键字段) > count(字段)`。
        - 如果要执行 `count(1)`、 `count(*)`、 `count(主键字段)` 时，尽量在数据表上建立二级索引，这样优化器会自动采用 `key_len` 最小的二级索引进行扫描，相比于扫描主键索引效率会高一些。
            - 再来，就是不要使用 `count(字段)` 来统计记录个数，因为它的效率是最差的，会采用全表扫描的方式来统计。如果你非要统计表中该字段不为 NULL 的记录个数，建议给这个字段建立一个二级索引。

    - `count(*)` 执行过程：其实等于 `count(0)`：也就是说，当你使用 count(*) 时，MySQL 会将 * 参数转化为参数 0 来处理。
        - `count(*)` 执行过程跟 `count(1)` 执行过程基本一样的，性能没有什么差异。

    - `count(1)`执行过程：不是字段，所以不需要读取记录中的字段值。参数 1 很明显并不是 NULL，因此 server 层每从 InnoDB 读取到一条记录，就将 count 变量加 1。
        - `count(1)` 相比 `count(主键字段)`（比如`count(id)`） 少一个步骤，就是不需要读取记录中的字段值，所以通常会说 `count(1)` 执行效率会比 `count(主键字段)` 高一点。

    - `count()`的执行过程：

        - 在通过 count 函数统计有多少个记录时，MySQL 的 server 层会维护一个名叫 count 的变量。 server 层会循环向 InnoDB 读取一条记录，如果 count 函数指定的参数不为 NULL，那么就会将变量 count 加 1，直到符合查询的全部记录被读完，就退出循环。最后将 count 变量的值发送给客户端。 

            - InnoDB 是通过 B+ 树来保存记录的，根据索引的类型又分为聚簇索引和二级索引，它们区别在于，聚簇索引的叶子节点存放的是实际数据，而二级索引的叶子节点存放的是主键值，而不是实际数据。

        - 1.如果表里`只有主键索引`，没有二级索引时：那么，InnoDB 循环遍历聚簇索引，将读取到的记录返回给 server 层，然后读取记录中的 id 值，就会 id 值判断是否为 NULL，如果不为 NULL，就将 count 变量加 1。

        - 2.如果表里`有二级索引`时，InnoDB 循环遍历的对象就不是聚簇索引，而是二级索引。
            - 这是因为相同数量的二级索引记录可以比聚簇索引记录占用更少的存储空间，所以二级索引树比聚簇索引树小，这样遍历二级索引的 I/O 成本比遍历聚簇索引的 I/O 成本小，因此「优化器」优先选择的是二级索引。 #

            ```sql
            -- key字段里的idx_c1是二级索引
            show index from t
            +-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+
            | Table | Non_unique | Key_name | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Ignored |
            +-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+
            | t     | 0          | PRIMARY  | 1            | id          | A         | 64376       | <null>   | <null> |      | BTREE      |         |               | NO      |
            | t     | 1          | idx_c1   | 1            | c1          | A         | 1           | <null>   | <null> |      | BTREE      |         |               | NO      |
            +-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+

            explain select count(id) from t;
            +----+-------------+-------+-------+---------------+--------+---------+--------+-------+-------------+
            | id | select_type | table | type  | possible_keys | key    | key_len | ref    | rows  | Extra       |
            +----+-------------+-------+-------+---------------+--------+---------+--------+-------+-------------+
            | 1  | SIMPLE      | t     | index | <null>        | idx_c1 | 256     | <null> | 64376 | Using index |
            +----+-------------+-------+-------+---------------+--------+---------+--------+-------+-------------+
            ```

        - 3.如果表里没有索引，全表扫描。可以看到type字段是all

            ```sql
            explain select count(c2) from t;
            +----+-------------+-------+------+---------------+--------+---------+--------+-------+-------+
            | id | select_type | table | type | possible_keys | key    | key_len | ref    | rows  | Extra |
            +----+-------------+-------+------+---------------+--------+---------+--------+-------+-------+
            | 1  | SIMPLE      | t     | ALL  | <null>        | <null> | <null>  | <null> | 64376 |       |
            +----+-------------+-------+------+---------------+--------+---------+--------+-------+-------+
            ```

##### 加密函数

```sql
select md5('123');
+----------------------------------+
| md5(123)                         |
+----------------------------------+
| 202cb962ac59075b964b07152d234b70 |
+----------------------------------+

-- 保留两位小数
select format(111.111,2);
+-------------------+
| format(111.111,2) |
+-------------------+
| 111.11            |
+-------------------+

-- 加锁函数
select get_lock('lockname',10);
select is_free_lock('lockname');
select release_lock('lockname');
select is_free_lock('lockname');
```

##### rank(): 排名

- `rank() OVER (ORDER BY salary)`

- `rank() OVER (ORDER BY salary nulls last)`

```sql
SELECT name, salary,
rank() OVER (ORDER BY salary DESC) AS salary_rank
FROM people

+------+--------+-------------+
| name | salary | salary_rank |
+------+--------+-------------+
| c3   | 3000   | 1           |
| b3   | 3000   | 1           |
| a3   | 3000   | 1           |
| c2   | 2000   | 4           |
| b2   | 2000   | 4           |
| a2   | 2000   | 4           |
| a1   | 1000   | 7           |
| c1   | 1000   | 7           |
| b1   | 1000   | 7           |
+------+--------+-------------+


SELECT name, salary, (1 + (SELECT COUNT(*)
                      FROM people1 AS B
                      WHERE B.salary > A.salary)) AS salary_rank
FROM people as A
ORDER BY salary_rank
+------+--------+-------------+
| name | salary | salary_rank |
+------+--------+-------------+
| a3   | 3000   | 1           |
| b3   | 3000   | 1           |
| c3   | 3000   | 1           |
| a2   | 2000   | 4           |
| b2   | 2000   | 4           |
| c2   | 2000   | 4           |
| a1   | 1000   | 5           |
| b1   | 1000   | 5           |
| c1   | 1000   | 5           |
+------+--------+-------------+

-- rank()对相等的值, 赋予相等的排名. 加上name字段让排名不相等

SELECT name, salary,
rank() OVER (ORDER BY salary, name desc) AS salary_rank
FROM people

+------+--------+-------------+
| name | salary | salary_rank |
+------+--------+-------------+
| c1   | 1000   | 1           |
| b1   | 1000   | 2           |
| a1   | 1000   | 3           |
| c2   | 2000   | 4           |
| b2   | 2000   | 5           |
| a2   | 2000   | 6           |
| c3   | 3000   | 7           |
| b3   | 3000   | 8           |
| a3   | 3000   | 9           |
+------+--------+-------------+
```

##### 分窗

- `SUM(score) OVER (ORDER BY score)`
- `AVG(score) OVER (ORDER BY score)`

```sql
CREATE TABLE class(
    `id` int (8) AUTO_INCREMENT,
    `score` int (8),
    `year`  int (8),
    primary key (`id`)
);

-- 插入数据
INSERT INTO class (score, year) VALUES
(90, 2013),
(80, 2012),
(70, 2011),
(60, 2010),
(50, 2009),
(40, 2008),
(30, 2007),
(20, 2006),
(10, 2005);

SELECT score, year,
SUM(score) OVER (order by score) AS score_sum
FROM class;
-- 累加. 9代表最大计算9行, 如果有第10行,则只会计算2到10行
SELECT score, year,
SUM(score) OVER (order by score rows 9 preceding) AS score_sum
FROM class;
-- or使用unbounded
SELECT score, year,
SUM(score) OVER (order by score rows unbounded preceding) AS score_sum
FROM class;

+-------+------+-----------+
| score | year | score_sum |
+-------+------+-----------+
| 10    | 2005 | 10        |
| 20    | 2006 | 30        |
| 30    | 2007 | 60        |
| 40    | 2008 | 100       |
| 50    | 2009 | 150       |
| 60    | 2010 | 210       |
| 70    | 2011 | 280       |
| 80    | 2012 | 360       |
| 90    | 2013 | 450       |
+-------+------+-----------+

-- 平均数
SELECT score, year,
AVG(score) OVER (order by score rows 9 preceding) AS score_avg
FROM class;

+-------+------+------------+
| score | year | score_avg  |
+-------+------+------------+
| 10    | 2005 | 10.0000    |
| 20    | 2006 | 15.0000    |
| 30    | 2007 | 20.0000    |
| 40    | 2008 | 25.0000    |
| 50    | 2009 | 35.0000    |
| 60    | 2010 | 45.0000    |
| 70    | 2011 | 55.0000    |
| 80    | 2012 | 65.0000    |
| 90    | 2013 | 75.0000    |
+-------+------+------------+

-- following 显示2行之后的值
SELECT score, year,
SUM(score) OVER (order by score rows between 9 preceding and 2 following) AS score_sum
FROM class;

+-------+------+-----------+
| score | year | score_sum |
+-------+------+-----------+
| 10    | 2005 | 60        |
| 20    | 2006 | 100       |
| 30    | 2007 | 150       |
| 40    | 2008 | 210       |
| 50    | 2009 | 280       |
| 60    | 2010 | 360       |
| 70    | 2011 | 450       |
| 80    | 2012 | 450       |
| 90    | 2013 | 450       |
+-------+------+-----------+

-- FIELD() 指定score列值, 不进行ORDER BY。这里是90,70不排序
SELECT * FROM class
ORDER BY FIELD (score, 90, 70)

+----+-------+------+
| id | score | year |
+----+-------+------+
| 2  | 80    | 2012 |
| 4  | 60    | 2010 |
| 5  | 50    | 2009 |
| 6  | 40    | 2008 |
| 7  | 30    | 2007 |
| 8  | 20    | 2006 |
| 9  | 10    | 2005 |
| 1  | 90    | 2013 |
| 3  | 70    | 2011 |
+----+-------+------+
```

#### 自定义变量

- 自定义变量几乎可以在任何表达式上使用

    - 不能在常量的地方使用, 如LIMIT, 表名, 列名
    ```sql
    -- 定义变量
    SET @a = "我是傻傻的小月亮！！！！";
    -- 插入
    insert into t4 values (@a);
    ```

    ```sql
    -- 定义变量
    SET @avg_people := (SELECT AVG(salary) FROM people);

    -- 在查询中使用变量
    SELECT * FROM people
    WHERE salary > @avg_people;
    ```

- 避免重复查询刚更新的数据:

    ```sql
    UPDATE index_test SET date = NOW()
    WHERE last_name = '王';
    SELECT * FROM index_test;

    -- 将修改的值定义为变量. 虽然依然是2次查询, 但第2次无需访问数据表, 因此更快
    UPDATE index_test SET date = NOW()
    WHERE last_name = '王'
    AND @now :=NOW();
    SELECT @now;
    ```

- SELECT 和 WHERE 子句是在不同阶段执行的, 因此变量也不一样

    ```sql
    SET @rownum = 0;
    SELECT *, @rownum := @rownum + 1 FROM people
    WHERE @rownum <= 1;

    +----+------+--------+------------------------+
    | id | name | salary | @rownum := @rownum + 1 |
    +----+------+--------+------------------------+
    | 1  | a1   | 1000   | 1                      |
    | 2  | a2   | 2000   | 2                      |
    +----+------+--------+------------------------+

    SET @rownum = 0;
    SELECT *, @rownum FROM people
    WHERE (@rownum := @rownum + 1) <= 1;

    +----+------+--------+---------+
    | id | name | salary | @rownum |
    +----+------+--------+---------+
    | 1  | a1   | 1000   | 1       |
    +----+------+--------+---------+
    ```

### JOIN(关联查询): 改变表关系

**语法:**

> ```sql
> SELECT 列名称
> FROM 表名称1
> INNER JOIN 表名称2
> ON 表名称1.列名称=表名称2.列名称
> ```

---

```sql
-- 创建表j
CREATE TABLE j(
    id   int (8),
    name varchar(50) NOT NULL UNIQUE,
    date DATE
);

-- 插入数据
insert into j (id,name,date) values
(1,'tz1','2020-10-24'),
(10,'tz2','2020-10-24'),
(100,'tz3','2020-10-24');

-- 查看结果
select * from j;
+-----+------+------------+
| id  | name | date       |
+-----+------+------------+
| 1   | tz1  | 2020-10-24 |
| 10  | tz2  | 2020-10-24 |
| 100 | tz3  | 2020-10-24 |
+-----+------+------------+
```

#### INNER JOIN(内连接)

- people表

```sql
-- INNER JOIN
SELECT * FROM people INNER JOIN people1
ON people.id = people1.id;
-- JOIN
SELECT * FROM people JOIN people1
ON people.id = people1.id;
-- or
SELECT * FROM people, people1
WHERE people.id = people1.id;

+----+------+--------+----+--------+--------+
| id | name | salary | id | name   | salary |
+----+------+--------+----+--------+--------+
| 1  | a1   | 1000   | 1  | c1     | 1000   |
| 2  | a2   | 2000   | 2  | c2     | 2000   |
| 3  | a3   | 3000   | 3  | c3     | 3000   |
| 4  | b1   | 1000   | 4  | d      | 3000   |
| 5  | b2   | 2000   | 5  | <null> | 3000   |
| 6  | b3   | 3000   | 6  | d      | <null> |
| 7  | c1   | 1000   | 7  | <null> | <null> |
+----+------+--------+----+--------+--------+
```

- cnarea_2019表

```sql
-- 选取 j 表的 id,name,date 字段以及 cnarea_2019 表的 name 字段
select j.id,j.date,cnarea_2019.name
from j,cnarea_2019
where cnarea_2019.id=j.id;

-- 或者
select j.id,j.name,j.date,cnarea_2019.name
from j inner join  cnarea_2019
on cnarea_2019.id=j.id;

+------+------+------------+--------------------------+
| id   | name | date       | name                     |
+------+------+------------+--------------------------+
|    1 | tz1  | 2020-10-24 | 北京市                   |
|   10 | tz2  | 2020-10-24 | 黄图岗社区居委会         |
|  100 | tz3  | 2020-10-24 | 安德路社区居委会         |
+------+------+------------+--------------------------+
```

##### STRAIGHT_JOIN

- 和 `inner join` 语法,结果相同,只是左表总是在右表之前读取

- 因为 `Nest Loop Join` 的算法,用更小的数据表驱动更大数据表,**更快**.

```sql
-- 先读取 j 再读取 cnarea_2019 或者说 驱动表是j 被驱动表是cnarea_2019.
-- 因为 j 表的数据更小所以更快
select j.id,j.name,j.date,cnarea_2019.name
from j straight_join cnarea_2019
on j.id=cnarea_2019.id;
```

#### LEFT JOIN(左连接)

```sql
-- 左连接,以左表(j)id 字段个数进行选取.所以结果与inner join一样
select j.id,j.name,j.date,cnarea_2019.name
from j left join  cnarea_2019
on cnarea_2019.id=j.id;

+------+------+------------+--------------------------+
| id   | name | date       | name                     |
+------+------+------------+--------------------------+
|    1 | tz1  | 2020-10-24 | 北京市                   |
|   10 | tz2  | 2020-10-24 | 黄图岗社区居委会         |
|  100 | tz3  | 2020-10-24 | 安德路社区居委会         |
+------+------+------------+--------------------------+

-- 插入一条高于 cnarea_2019表id最大值 的数据
insert into j (id,name,date) value
(10000000,'tz一百万','2020-10-24');

-- 再次左连接,因为 cnarea_2019 没有id 10000000(一百万)的数据,所以这里显示为 null

select j.id,j.name,j.date,cnarea_2019.name
from j left join cnarea_2019
on j.id = cnarea_2019.id;

+----------+-------------+------------+--------------------------+
| id       | name        | date       | name                     |
+----------+-------------+------------+--------------------------+
|        1 | tz1         | 2020-10-24 | 北京市                   |
|       10 | tz2         | 2020-10-24 | 黄图岗社区居委会         |
|      100 | tz3         | 2020-10-24 | 安德路社区居委会         |
| 10000000 | tz一百万    | 2020-10-24 | NULL                     |
+----------+-------------+------------+--------------------------+
```

#### RIGHT JOIN(左连接)

```sql
-- 右连接,以右表(cnarea_2019)id字段个数进行选取.左表id没有的数据为null.因为cnarea_2019表数据量太多这里limit 10

select j.id,j.date,cnarea_2019.name,cnarea_2019.pinyin
from j right join cnarea_2019
on j.id=cnarea_2019.id
limit 10;

+------+------------+--------------------------+-------------+
| id   | date       | name                     | pinyin      |
+------+------------+--------------------------+-------------+
|    1 | 2020-10-24 | 北京市                   | BeiJing     |
|   10 | 2020-10-24 | 黄图岗社区居委会         | HuangTuGang |
|  100 | 2020-10-24 | 安德路社区居委会         | AnDeLu      |
| NULL | NULL       | 直辖区                   | BeiJing     |
| NULL | NULL       | 东城区                   | DongCheng   |
| NULL | NULL       | 东华门街道               | DongHuaMen  |
| NULL | NULL       | 多福巷社区居委会         | DuoFuXiang  |
| NULL | NULL       | 银闸社区居委会           | YinZha      |
| NULL | NULL       | 东厂社区居委会           | DongChang   |
| NULL | NULL       | 智德社区居委会           | ZhiDe       |
+------+------------+--------------------------+-------------+
```

#### CROSS JOIN（笛卡尔连接）

- 如果不提供额外条件，则通过将表 A 的每一行与表 B 中的所有行相乘得到结果集。

- 您认为什么时候需要这种 JOIN？例如，假设您的任务是查找产品和颜色的所有可能组合。

```sql
SELECT
   columns
FROM
  tableA
CROSS JOIN tableB;
```

#### FULL OUTER JOIN(全连接)

- mysql不支持 full outer

- 组合 LEFT OUTER JOIN 和 RIGHT OUTER JOIN 以获得与 FULL OUTER JOIN 相同的效果

```sql
SELECT
   *
FROM
  tableA
LEFT JOIN tableB
   ON tableA.id = tableB.id
UNION
SELECT
   *
FROM
  tableA
RIGHT JOIN tableB
    ON tableA.id = tableB.id
```

```sql
SELECT * FROM new LEFT JOIN cnarea_2019 ON new.id = cnarea_2019.id

UNION

SELECT * FROM new RIGHT JOIN cnarea_2019 ON new.id =cnarea_2019.id;
```

#### JOIN算法的explain解析

- [MySQL数据库联盟：一文弄懂Join语句优化](https://mp.weixin.qq.com/s?__biz=MzIyOTUzNjgwNg==&mid=2247485271&idx=1&sn=0de170f3b2ff995e9bab915c342fd9ee&chksm=e840621edf37eb08faf8897eba5a4db97d87f1ce9e33a1fe49545ed7932310daba79babb3eac&scene=178&cur_album_id=3234198021790154762#rd)

| Join算法                    | 解释                                                                                                                                                                                                                                                               |
|-----------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Simple Nested-Loop Join算法 | 遍历驱动表中的每一行，每一行再到被驱动表中全表扫描，如果满足关联条件，则返回结果                                                                                                                                                                                   |
| Index Nested-Loop Join算法  | 遍历驱动表中的每一行，都通过索引找到被驱动表中关联的记录，如果满足关联条件，则返回结果                                                                                                                                                                             |
| Block Nested-Loop Join算法  | 把驱动表的数据读入到 join_buffer 中，把被驱动表每一行取出来跟 join_buffer 中的数据做对比，如果满足 join 条件，则返回结果                                                                                                                                           |
| Hash Join算法               | 将驱动表的数据加载到内存中构建哈希表，然后逐行读取被驱动表的数据，并通过哈希函数将连接条件的列的值映射为哈希值，查找匹配的哈希值，最后返回匹配的结果给客户端，跟Block Nested-Loop Join算法类似，但是不需要将被驱动表的数据块写入内存或磁盘，更少的IO以及更节省资源 |
| Batched Key Access算法      | 将驱动表中相关列放入 join_buffer 中批量将关联字段的值发送到 Multi-Range Read(MRR) 接口 MRR 通过接收到的值，根据其对应的主键 ID 进行排序，然后再进行数据的读取和操作 返回结果给客户端                                                                               |

- 准备工作

    ```sql
    -- 创建测试表t1。只创建a字段的索引，b字段没有索引，方便当下作性能对比。
    drop table if exists t1;

    CREATE TABLE `t1` (
     `id` int NOT NULL auto_increment,
      `a` int DEFAULT NULL,
      `b` int DEFAULT NULL,
      `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
      `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
      PRIMARY KEY (`id`),
      KEY `idx_a` (`a`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

    -- 创建存储过程。插入10000行数据
    delimiter $$
    create procedure insert_t1()
    begin
      declare i int;
      set i=1;
      while(i<=10000)do
        insert into t1(a,b) values(i, i);
        set i=i+1;
      end while;
    end$$
    delimiter ;

    -- 调用存储过程
    call insert_t1();

    -- 创建测试表t2
    drop table if exists t2;
    create table t2 like t1;
    insert into t2 select * from t1 limit 100;

    -- 结果
    select count(*) from t1;
    +----------+
    | count(*) |
    +----------+
    | 10000    |
    +----------+

    select count(*) from t2;
    +----------+
    | count(*) |
    +----------+
    | 100      |
    +----------+
    ```

- 1.Simple Nested-Loop Join算法

    ![image](./Pictures/mysql/join-Simple_Nested-Loop_Join算法.avif)

    - 循环驱动表中的每一行

    - 再到被驱动表找到满足关联条件的记录

    - 因为关联字段没索引，所以在被驱动表里的查询需要全表扫描

    - 这种方法逻辑简单，但是效率很差

        - 比如驱动表数据量是 m，被驱动表数据量是 n，则扫描行数为 m * n

    - 当然，好在，MySQL也没有采用这种算法，即使关联字段没索引，也会采用Block Nested-Loop Join或者Hash Join，等下会细说。

- 2.Index Nested-Loop Join算法：关联字段有索引，就会采用Index Nested-Loop Join算法（一般简写成：NLJ）

    ![image](./Pictures/mysql/join-Index_Nested-Loop_Join算法.avif)

    - 一次一行循环地从第一张表（称为驱动表）中读取行，在这行数据中取到关联字段，根据关联字段在另一张表（被驱动表）里，通过索引匹配，取出满足条件的行，然后取出两张表的结果合集。

        ```sql
        -- 表 t1 和表 t2 中的 a 字段都有索引
        explain select * from t1 inner join t2 on t1.a = t2.a;
        +----+-------------+-------+------+---------------+--------+---------+-----------+------+-------------+
        | id | select_type | table | type | possible_keys | key | key_len | ref | rows | Extra |
        +----+-------------+-------+------+---------------+--------+---------+-----------+------+-------------+
        | 1  | SIMPLE      | t2    | ALL  | idx_a         | <null> | <null>  | <null>    | 100  | Using where |
        | 1  | SIMPLE      | t1    | ref  | idx_a         | idx_a  | 5       | test.t2.a | 1    |             |
        +----+-------------+-------+------+---------------+--------+---------+-----------+------+-------------+
        ```

        - 从执行计划中可以看到这些信息：

            - 驱动表是 t2，被驱动表是 t1。原因是：explain 分析 join 语句时，在第一行的就是驱动表；选择 t2 做驱动表的原因：如果没固定连接方式（比如没加 straight_join）,`优化器会优先选择小表做驱动表。所以使用 inner join 时，前面的表并不一定就是驱动表`。

            - 使用了Index Nested-Loop Join算法。一般 join 语句中，如果执行计划 Extra 中未出现 `Using join buffer （***）`；则表示使用的 join 算法是 Index Nested-Loop Join算法。

- 3.Block Nested-Loop Join算法：如果被驱动表的关联字段没索引，在MySQL 8.0.20版本之前，就会使用 Block Nested-Loop Join(简称：BNL)

    ![image](./Pictures/mysql/join-Block_Nested-Loop_Join算法.avif)

    - Block Nested-Loop Join(BNL) 算法的思想是：把驱动表的数据读入到 join_buffer 中，然后扫描被驱动表，把被驱动表每一行取出来跟 join_buffer 中的数据做对比，如果满足 join 条件，则返回结果给客户端。

    ```sql
    -- 表 t1 和表 t2 中的 b 字段都没有索引
    explain select * from t1 inner join t2 on t1.b = t2.b;
    +----+-------------+-------+------+---------------+--------+---------+--------+------+-------------------------------------------------+
    | id | select_type | table | type | possible_keys | key    | key_len | ref    | rows | Extra                                           |
    +----+-------------+-------+------+---------------+--------+---------+--------+------+-------------------------------------------------+
    | 1  | SIMPLE      | t2    | ALL  | <null>        | <null> | <null>  | <null> | 100  |                                                 |
    | 1  | SIMPLE      | t1    | ALL  | <null>        | <null> | <null>  | <null> | 1000 | Using where; Using join buffer (flat, BNL join) |
    +----+-------------+-------+------+---------------+--------+---------+--------+------+-------------------------------------------------+
    ```

    - 在 MySQL 5.7 版本下的执行计划如下：
        - 在 Extra 发现 `Using join buffer (Block Nested Loop)`，这个就说明该关联查询使用的是 BNL 算法。

    - 在 MySQL 8.0.25 版本下的执行计划如下：
        - 在 Extra 发现 `Using join buffer (hash join)`，因为前面提到，从 MySQL 8.0.20 开始，Hash Join替换了BNL。

- 4.Hash Join算法：从 MySQL 8.0.20 开始，MySQL 不再使用 Block Nested-Loop Join 算法，并且在以前使用 Block Nested-Loop Join 算法的所有情况下都使用 Hash Join 优化。

    ![image](./Pictures/mysql/join-Hash_Join算法.avif)

    - 核心思想是将驱动表的数据加载到内存中构建哈希表

    - 然后逐行读取被驱动表的数据，并通过哈希函数将连接条件的列的值映射为哈希值，去之前构建的Hash表查找匹配的记录

    - 一旦在Hash表中找到匹配的记录，对这些记录进行一一比较，得出最终的Join结果

    - 跟Block Nested-Loop Join算法类似，但是不需要将被驱动表的数据块写入内存或磁盘，更少的IO以及更节省资源

- 5.Batched Key Access算法

    - 在学了 NLJ 和 BNL 算法后，你是否有个疑问，如果把 NLJ 与 BNL 两种算法的一些优秀的思想结合，是否可行呢？

        - NLJ 的关键思想是：被驱动表的关联字段有索引。

        - BNL 的关键思想是：把驱动表的数据批量提交一部分放到 join_buffer 中。

        - 从 MySQL 5.6 开始，确实出现了这种集 NLJ 和 BNL 两种算法优点于一体的新算法：Batched Key Access(BKA)。

    ![image](./Pictures/mysql/join-Batched_Key_Access算法.avif)

    - 其原理是：

        - 将驱动表中相关列批量放入 join_buffer 中
        - 批量将关联字段的值发送到 Multi-Range Read(MRR) 接口
        - MRR 通过接收到的值，根据其对应的主键 ID 进行排序，然后再进行数据的读取和操作
        - 返回结果给客户端。

    - MRR

        - 当表很大并且没有存储在缓存中时，使用辅助索引上的范围扫描读取行可能导致对表有很多随机访问。
        - 而 Multi-Range Read 优化的设计思路是：查询辅助索引时，对查询结果先按照主键进行排序，并按照主键排序后的顺序，进行顺序查找，从而减少随机访问磁盘的次数。
        - 使用 MRR 时，explain 输出的 Extra 列显示的是 Using MRR。

    - 控制MRR的参数

        - optimizer_switch 中 mrr_cost_based 参数的值会影响 MRR。

            - 如果 mrr_cost_based=on，表示优化器尝试在使用和不使用 MRR 之间进行基于成本的选择。
            - 如果 mrr_cost_based=off，表示一直使用 MRR。

        - 更多 MRR 信息请参考官方手册：https://dev.mysql.com/doc/refman/8.0/en/mrr-optimization.html。

    ```sql
    explain select * from t1 inner join t2 on t1.a = t2.a;
    +----+-------------+-------+------+---------------+--------+---------+-----------+------+-------------+
    | id | select_type | table | type | possible_keys | key | key_len | ref | rows | Extra |
    +----+-------------+-------+------+---------------+--------+---------+-----------+------+-------------+
    | 1  | SIMPLE      | t2    | ALL  | idx_a         | <null> | <null>  | <null>    | 100  | Using where |
    | 1  | SIMPLE      | t1    | ref  | idx_a         | idx_a  | 5       | test.t2.a | 1    |             |
    +----+-------------+-------+------+---------------+--------+---------+-----------+------+-------------+

    -- 开启bka算法。mrr=on 开启 mrr；mrr_cost_based=off 不需要优化器基于成本考虑使用还是不使用 MRR，也就是一直使用 MRR；batched_key_access=on 开启 BKA
    set optimizer_switch='mrr=on,mrr_cost_based=off,batched_key_access=on';

    -- 再次运行。在 Extra 字段中发现有 Using join buffer (Batched Key Access)，表示确实变成了 BKA 算法。
    explain select * from t1 inner join t2 on t1.a = t2.a;
    ```

##### 优化JOIN查询

- 怎样优化关联查询？关联字段添加索引

- 通过上面的内容，我们知道了 BNL、NLJ 和 BKA 的原理，因此让 BNL（Block Nested-Loop Join）或者Hash Join变成 NLJ （Index Nested-Loop Join）或者 BKA（Batched Key Access），可以提高 join 的效率。

- 对比不同join算法的查询时间

    ```sql
    -- Block Nested-Loop Join 算法 的例子：需要0.016秒
    select * from t1 join t2 on t1.b= t2.b;
    Time: 0.016s

    -- Index Nested-Loop Join算法 的例子：需要0.012秒
    select * from t1 join t2 on t1.a= t2.a;
    Time: 0.012s
    ```

- 对比不同join算法的explain执行计划

    ```sql
    explain select * from t1 join t2 on t1.b= t2.b;
    +----+-------------+-------+------+---------------+--------+---------+--------+------+-------------------------------------------------+
    | id | select_type | table | type | possible_keys | key | key_len | ref | rows | Extra |
    +----+-------------+-------+------+---------------+--------+---------+--------+------+-------------------------------------------------+
    | 1  | SIMPLE      | t2    | ALL  | <null>        | <null> | <null>  | <null> | 100  |                                                 |
    | 1  | SIMPLE      | t1    | ALL  | <null>        | <null> | <null>  | <null> | 1000 | Using where; Using join buffer (flat, BNL join) |
    +----+-------------+-------+------+---------------+--------+---------+--------+------+-------------------------------------------------+

    explain select * from t1 join t2 on t1.a= t2.a;
    +----+-------------+-------+------+---------------+--------+---------+-----------+------+-------------+
    | id | select_type | table | type | possible_keys | key    | key_len | ref       | rows | Extra       |
    +----+-------------+-------+------+---------------+--------+---------+-----------+------+-------------+
    | 1  | SIMPLE      | t2    | ALL  | idx_a         | <null> | <null>  | <null>    | 100  | Using where |
    | 1  | SIMPLE      | t1    | ref  | idx_a         | idx_a  | 5       | test.t2.a | 1    |             |
    +----+-------------+-------+------+---------------+--------+---------+-----------+------+-------------+
    ```

    - 前者扫描的行数是 100 和 1000；后者是100 和 1。
    - 结论：
        - 对比执行时间和执行计划，再结合在本节开始讲解的两种算法的执行流程，很明显 Index Nested-Loop Join 效率更高。

        - 因此建议在被驱动表的关联字段上添加索引，让 BNL或者Hash Join变成 NLJ 或者 BKA ，可明显优化关联查询。

- 优化建议：选择小表作为驱动表。

    - 如果是普通的join语句，一般不需要我们去处理，优化器默认也会选择小表做为驱动表。

    - 从上面几种Join算法，也能看出来，驱动表需要全表扫描，再存放在内存中

    - 如果小表是驱动表，那遍历的行也会更少。

    - 大小表做驱动表执行计划的对比：
        ```sql
        -- 使用 straight_join 可以固定连接方式，让前面的表为驱动表。

        -- 以 t2 为驱动表的 SQL
        select * from t2 straight_join t1 on t2.a = t1.a;
        Time: 0.012s
        -- 以 t1 为驱动表的 SQL：
        select * from t1 straight_join t2 on t1.a = t2.a;
        Time: 0.013s
        ```

        ```sql
        -- 明显前者扫描的行数少（注意关注 explain 结果的 rows 列），所以建议小表驱动大表。
        -- 当然，如果是普通的join语句，优化器默认也会选择小表做为驱动表。
        explain select * from t2 straight_join t1 on t2.a = t1.a;
        +----+-------------+-------+------+---------------+--------+---------+-----------+------+-------------+
        | id | select_type | table | type | possible_keys | key    | key_len | ref       | rows | Extra       |
        +----+-------------+-------+------+---------------+--------+---------+-----------+------+-------------+
        | 1  | SIMPLE      | t2    | ALL  | idx_a         | <null> | <null>  | <null>    | 100  | Using where |
        | 1  | SIMPLE      | t1    | ref  | idx_a         | idx_a  | 5       | test.t2.a | 1    |             |
        +----+-------------+-------+------+---------------+--------+---------+-----------+------+-------------+

        explain select * from t1 straight_join t2 on t1.a = t2.a;
        +----+-------------+-------+------+---------------+--------+---------+-----------+------+-------------+
        | id | select_type | table | type | possible_keys | key    | key_len | ref       | rows | Extra       |
        +----+-------------+-------+------+---------------+--------+---------+-----------+------+-------------+
        | 1  | SIMPLE      | t1    | ALL  | idx_a         | <null> | <null>  | <null>    | 1000 | Using where |
        | 1  | SIMPLE      | t2    | ref  | idx_a         | idx_a  | 5       | test.t1.a | 1    |             |
        +----+-------------+-------+------+---------------+--------+---------+-----------+------+-------------+
        ```


## DML (Data Manipulation Language) 数据操作语言

- `INSERT`：向表中插入新的数据行。

- `UPDATE`：修改表中已存在的数据。

- `DELETE`：从表中删除指定的数据行。

- DML主要用于执行对数据库中数据的操作，例如添加、修改和删除记录等操作，操作的对象是记录。常见的DML语句包括：

### CREATE(创建)

**语法:**

> ```sql
> CREATE TABLE 表名称
> # 注意:列属性可添加和不添加,并且不区分大小写
> (
>   列名称1 数据类型 列属性,
>   列名称2 数据类型 列属性,
>   列名称3 数据类型 列属性,
> ....
> )
> ```

#### 数据类型

![image](./Pictures/mysql/MySQL-Data-Types.avif)

- 不同的存储引擎,有不同的实现

- mysql不支持自定义数据类型

- 最好指定为`NOT NULL`, 除非真需要存储 `NULL`

- 选择存储最小的数据类型

- INT(整数):

    | 类型      | 位数 |
    |-----------|------|
    | TINYINT   | 8位  |
    | SMALLINT  | 16位 |
    | MEDIUMINT | 24位 |
    | INT       | 32位 |
    | BIGINT    | 64位 |

    - 宽度 `INT(1)` 和 `INT(20)` 的存储和计算是一样的

    - 整型比字符串的 CPU 操作更低

    - 建议选择最小的类型，当然了对其他类型也适用。

    - 使用整数保存ip地址

        - ipv4通过`INET_ATON()`, `INET_NTOA()` 函数进行转换. `IS_IPV4()`判断是否为ipv4地址

        - ipv6通过`INET6_ATON()`, `INET6_NTOA()` 函数进行转换. `IS_IPV6()`判断是否为ipv6地址

        ```sql
        CREATE TABLE ipv4_test(
            ipv4 TINYINT UNSIGNED
        );

        INSERT INTO ipv4_test VALUES
        (INET_ATON('192.168.1.1'));

        SELECT INET_NTOA(ipv4) FROM ipv4_test;

        SELECT IS_IPV4(ipv4) FROM ipv4_test;
        ```

- FLOAT(浮点):

    | 类型    | 位数     |
    |---------|----------|
    | FLOAT   | 32位     |
    | DOUBLE  | 64位     |
    | DECIMAL | 存储格式 |

    - `FLOAT` 和 `DOUBLE` 并不精确, 在财务数据里像0.01的值, 并不能精确表示

    - 使用定点数`DECIMAL(m, d)` m为总位数(范围:1到65位), d为小数点右边的位数

        - 计算时会转换为`DOUBLE` 类型

            ```sql
            CREATE TABLE decimal_test(
                data DECIMAL(6, 4) NOT NULL
            );

            INSERT INTO decimal_test VALUES
            (0.9999);
            ```

        - 超过d的位数, 会四舍五入.以下为`0.0600`

            ```sql
            INSERT INTO decimal_test VALUES
            (0.059999);

            SELECT * FROM decimal_test
            +--------+
            | data   |
            +--------+
            | 0.9999 |
            | 0.0600 |
            +--------+
            ```

- DATE、TIME、YEAR、TIMEMESTAMP、DATETIME(日期时间)

    | 类型      | 大小(字节) | 范围                                       | 格式       | 用途             |
    |-----------|------------|--------------------------------------------|------------|------------------|
    | DATE      | 3          | 1000-01-01到9999-12-31                     | YYYY-MM-DD | 日期值           |
    | TIME      | 3          | -838:59:59到838:59:59                      | HH:MM:SS   | 时间值或持续时间 |
    | YEAR      | 1          | 1901到2155                                 | YYYY       | 年份值           |
    | DATETIME  | 8          | 1000-01-01 00:00:00 到 9999-12-31 23:59:59 | YYYY-MM-DD | HH:MM:SS         | 混合日期和时间值         |
    | TIMESTAMP | 4          | 1970-01-01 00:00:01 到 2038-01-19 03:14:07 | YYYYMMDD   | HHMMSS           | 混合日期和时间值，时间戳 |

    - 如果要用来表示年月日，通常用DATE 来表示。
    - 如果要用来表示年月日时分秒，通常用DATETIME 表示。
    - 如果只用来表示时分秒，通常用TIME 来表示。
    - 如果只是表示年份，可以用YEAR 来表示。

        ```sql
        CREATE TABLE time_test(
            c1 DATE,
            c2 TIME,
            c3 YEAR,
            c4 TIMESTAMP,
            c5 DATETIME
        );

        INSERT INTO time_test VALUES
        (date('2021-7-3 13:40:30'), time('2021-7-3 13:40:30'), year('2021-7-3 13:40:30'), '2021-7-3 13:40:30', '2021-7-3 13:40:30'),
        (date(NOW()), time(NOW()), year(NOW()), NOW(), NOW());

        SELECT * FROM time_test
        +------------+----------+------+---------------------+---------------------+
        | c1 | c2 | c3 | c4 | c5 |
        +------------+----------+------+---------------------+---------------------+
        | 2021-07-03 | 13:40:30 | 2021 | 2021-07-03 13:40:30 | 2021-07-03 13:40:30 |
        | 2024-04-09 | 16:55:22 | 2024 | 2024-04-09 16:55:22 | 2024-04-09 16:55:22 |
        +------------+----------+------+---------------------+---------------------+
        ```

    - TIMESTAMP类型如果超过unix时间就会报错

        ```sql
        INSERT INTO time_test(c4) VALUES
        ('2038-7-3 13:40:30');
        (1292, "Incorrect datetime value: '2038-7-3 13:40:30' for column `test`.`time_test`.`c4` at row 1")
        ```

- BIT(位):

    - BIT(1): 一个位; 最大BIT(64): 64个位

    - BIT()的存储需要最小整数类型

        - BIT(17) 需要存储在24个位的MEDIUMINT类型

    - 如果此字段加上索引，MySQL 不会自己做类型转换，只能用二进制来过滤。

    - 插入57的二进制数, 由于57的ASCII码为字符9, 因此显示为字符9

        ```sql
        CREATE TABLE bit_test(
            b bit(8)
        );

        INSERT INTO bit_test VALUES
        (b'00111001');

        -- 二进制和十进制方式显示
        SELECT b, b+0 FROM bit_test
        +---+-----+
        | b | b+0 |
        +---+-----+
        | 9 | 57  |
        +---+-----+
        ```

    - 一般用来存储状态类的信息。比如，性别，真假等。
        - 对于 bit(8) 如果单纯存放 1 位，左边以 0 填充 00000001。

        ```sql
        -- 创建表 c1, 字段性别定义一个比特位。
        CREATE TABLE c1(gender bit(1));
        INSERT INTO c1 VALUES (b'0');
        INSERT INTO c1 VALUES (b'1');

        -- 直接显示为二进制
        select *  from c1;
        +--------+
        | gender |
        +--------+
        | 0x00   |
        | 0x01   |
        +--------+

        -- 以十进制方式显示
        SELECT gender+0 'f1' FROM c1;
        +----+
        | f1 |
        +----+
        | 0 |
        | 1 |
        +----+

        -- 也可以用类型显示转换
        SELECT cast(gender as unsigned) 'f1' FROM c1;
        +----+
        | f1 |
        +----+
        | 0  |
        | 1  |
        +----+

        -- 过滤数据也一样，二进制或者直接十进制都行。
        SELECT conv(gender,16,10) as gender
            FROM c1 WHERE gender = b'1';
        +--------+
        | gender |
        +--------+
        | 1      |
        +--------+

        SELECT conv(gender,16,10) as gender
           FROM c1 WHERE gender = '1';
        +--------+
        | gender |
        +--------+
        | 1      |
        +--------+
        ```

    - 如果用来存储状态类的信息, 可以使用`char(0)`类型, 值为`NULL`, `''`(长度为0的空字符串)

        ```sql
        CREATE TABLE c2(
            gender CHAR(0)
        );

        -- ''为空字符串
        INSERT INTO c2 VALUES
        (''),
        (NULL);

        -- 把 c1 的数据全部导入 c2。
        INSERT INTO c2 SELECT if(gender = 0,'',null) FROM c1;

        -- 插入的和从c1导入的一样
        SELECT * FROM c2
        +--------+
        | gender |
        +--------+
        |        |
        | <null> |
        |        |
        | <null> |
        +--------+
        ```

    - 插入大量相同数据，对比两张表的磁盘占用差不多。

        ```
        ls -sihl
        总用量 1.9G
        4085684 933M -rw-r----- 1 mysql mysql 932M 12月 11 10:16 c1.ibd
        4082686 917M -rw-r----- 1 mysql mysql 916M 12月 11 10:22 c2.ibd
        ```

- EMUM(枚举)：适合提前规划好了所有已经知道的值，且未来最好不要加新值的情形

    - 枚举类型有以下特性：
        - 1.最大占用 2 Byte。
        - 2.最大支持 65535 个不同元素。
        - 3.MySQL 后台存储以下标的方式，也就是 tinyint 或者 smallint 的方式，下标从 1 开始。
        - 4.排序时按照下标排序，而不是按照里面元素的数据类型。所以这点要格外注意。

    - emum实际存储的是整数, 而不是字符串, 因此查询需要进行字符串转换, 有额外开销

        - 与varchar连接varchar相比: emum连接emum要快很多, 而emum连接varchar要慢很多

    - emum添加或删除字符串需要执行`ALTER TABLE` 操作。[快速ALTER TABLE](#alter_frm)

    ```sql
    CREATE TABLE emum_test(
        emum_col ENUM('xiaomi', 'huawei', 'meizu')
    );

    INSERT INTO emum_test(emum_col) VALUES
        ('huawei'),
        ('meizu'),
        ('xiaomi');

    SELECT emum_col FROM emum_test;
    +----------+
    | emum_col |
    +----------+
    | huawei   |
    | meizu    |
    | xiaomi   |
    +----------+

    SELECT emum_col + 0 FROM emum_test;
    +--------------+
    | emum_col + 0 |
    +--------------+
    | 2            |
    | 3            |
    | 1            |
    +--------------+
    ```

- 集合类型SET:

    - 集合类型 SET 和枚举类似，也是得提前知道有多少个元素

    - SET 有以下特点：
        - 1.最大占用 8 Byte，int64。
        - 2.内部以二进制位的方式存储，对应的下标如果以十进制来看，就分别为 1,2,4,8，...，pow(2,63)。
        - 3.最大支持 64 个不同的元素，重复元素的插入，取出来直接去重。
        - 4.元素之间可以组合插入，比如下标为 1 和 2 的可以一起插入，直接插入 3 即可。

    - set添加或删除字符串需要执行`ALTER TABLE` 操作。[快速ALTER TABLE](#alter_frm)

        ```sql
        CREATE TABLE set_test(
            acl SET('READ', 'WRITE', 'DELETE')
        );

        -- 注意:中间不能有空格'READ, WRITE'
        INSERT INTO set_test VALUES
        ('READ,WRITE'),
        ('WRITE,DELETE');

        -- FIND_IN_SET() 查找带有'WRITE'行
        SELECT * FROM set_test
        WHERE FIND_IN_SET('WRITE',acl)
        +--------------+
        | acl          |
        +--------------+
        | READ,WRITE   |
        | WRITE,DELETE |
        +--------------+
        ```

    - 使用整数存储

        ```sql
        SET @READ   := 1<<0,
            @WRITE  := 1<<1,
            @DELETE := 1<<2;

        CREATE TABLE set_int_test(
            acl TINYINT DEFAULT 0
        );

        INSERT INTO set_int_test VALUES
        (@READ + @WRITE),
        (@WRITE + @DELETE);

        SELECT * FROM set_int_test;
        +-----+
        | acl |
        +-----+
        | 3   |
        | 6   |
        +-----+

        SELECT * FROM set_int_test WHERE acl & @READ;
        +-----+
        | acl |
        +-----+
        | 3   |
        +-----+
        ```

- 字符串:

    - `VARCHAR`:

      - 可变长度,需要额外记录长度

        - 当长度 <= 255 时,需要 1 个字节来记录长度

        - 当长度 > 255 时,需要 2 个字节来记录长度

        - `varchar(1)`,需要 2 个字节

        - `varchar(256)`,需要 258 个字节

        - 如果update字符串, 页不能容纳update后的大小, innodb就会分裂页

    - `CHAR`:

        - 定长字符串,不容易产生碎片

        - 适合存储 MD5 这些定长值

        ```sql
        CREATE TABLE char_test(
            char_col CHAR(10),
            varchar_col VARCHAR(10)
        );

        INSERT INTO char_test(char_col, varchar_col) VALUES
            ('string', 'string');

        -- 两个类型占用的字节数一样
        SELECT 'char_col' AS 'column list',
           char_length(char_col) '  as characters',
           length(char_col) ' as bytes'
           FROM char_test
        UNION all
           SELECT 'varchar_col',
           char_length(varchar_col) as ' characters',
           length(varchar_col) as ' bytes'
           FROM char_test;
        +-------------+---------------+----------+
        | column list | as characters | as bytes |
        +-------------+---------------+----------+
        | char_col    | 6             | 6        |
        | varchar_col | 6             | 6        |
        +-------------+---------------+----------+

        -- 由于最多只能10个字符串；插入11个字符的字符串，会报错
        INSERT INTO char_test(char_col, varchar_col) VALUES
            ('01234567899', '01234567899');
        (1406, "Data too long for column 'char_col' at row 1")
        ```

        - `CONCAT()`函数连接字符串, 以下命令为连接单引号''

            ```sql
            SELECT CONCAT("'", char_col, varchar_col, "'")
            FROM char_test;
            ```

            ![image](./Pictures/mysql/char_test.avif)


    - `BINARY`, `VARBINARY` 对应了 `CHAR` 和 `VARCHAR` 的二进制存储，相关的特性都一样。不同的有以下几点
        - `BINARY(10)`、`VARBINARY(10)` 代表的不是字符个数，而是字节数。
        - 行结束符不一样。`CHAR` 的行结束符是 \0，`BINARY` 的行结束符是 0x00。
        - 由于是二进制存储，所以字符编码以及排序规则这类就直接无效了。

            ```sql
            SET @a = "我是傻傻的小月亮!!!!";
            CREATE TABLE t6 (c1 BINARY(28), c2 VARBINARY(28));
            INSERT INTO t6 VALUES (@a,@a);

            select * from t6
            +----------------------+----------------------+
            | c1 | c2 |
            +----------------------+----------------------+
            | 我是傻傻的小月亮!!!! | 我是傻傻的小月亮!!!! |
            +----------------------+----------------------+
            ```

        - 使用`BINARY(16)`保存uuid

            - 通过`UNHEX()`, `HEX()` 函数进行转换

            ```sql
            CREATE TABLE uuid_test(
                uuid BINARY(16)
            );

            INSERT INTO uuid_test VALUES
            (UNHEX('FDFE0000000000005A55CAFFFEFA9089'));

            SELECT HEX(uuid) FROM uuid_test;
            +----------------------------------+
            | HEX(uuid)                        |
            +----------------------------------+
            | FDFE0000000000005A55CAFFFEFA9089 |
            +----------------------------------+
            ```

    - `TEXT(字符串),` `BLOB(二进制字符串)`:

        - TEXT 存储以明文存储，有对应的字符集和校验规则；BLOB 则以二进制存储，没有字符集和排序规则，用于图片, 视频存储

        - TEXT使用两个字节存储字符串大小

        - 一个字符大小为一个字节

            | TEXT类型   | BLOB类型   | 大小                   | 说明                  |
            |------------|------------|------------------------|-----------------------|
            | TINYTEXT   | TINYBLOB   | 255字节                | 外加1字节保存总字节数 |
            | TEXT       | BLOB       | 65536字节(64K)         | 外加2字节保存总字节数 |
            | MEDIUMTEXT | MEDIUMBLOB | 16,777,215字节(16M)    | 外加3字节保存总字节数 |
            | LONGTEXT   | LONGBLOB   | 4,294,967,295 字节(4G) | 外加4字节保存总字节数 |

        - 尽量避免使用TEXT, BLOB类型

        - 不能把全部字符用作索引, 只能索引字符的部分前缀

        ```sql
        CREATE TABLE c1 (f1 tinytext, f2 tinyblob);

        -- 插入测试数据
        INSERT INTO c1 VALUES
            ('a','a'),('b','b'),('B','B'),('d','d'),('F','F'),('你','你'),('我','我'),('是吧','是吧');

        -- f1,f2 字段各自排序的结果都不一致。f1 是按照不区分大小写的校验规则，f2 直接二进制检验
        SELECT * FROM c1 ORDER BY f1
        +------+------+
        | f1 | f2 |
        +------+------+
        | a    | a    |
        | b    | b    |
        | B    | B    |
        | d    | d    |
        | F    | F    |
        | 你   | 你   |
        | 我   | 我   |
        | 是吧 | 是吧 |
        +------+------+

        SELECT * FROM c1 ORDER BY f2
        +------+------+
        | f1   | f2   |
        +------+------+
        | B    | B    |
        | F    | F    |
        | a    | a    |
        | b    | b    |
        | d    | d    |
        | 你   | 你   |
        | 我   | 我   |
        | 是吧 | 是吧 |
        +------+------+
        ```

        - text 其实也能存储 JSON ，但是没有 JSON 类型的格式校验以及内部提供的众多函数。
        ```sql
        -- 插入的变量
        SET @a='{"a":1,"b":2,"c":3,"d":4}';
        SET @b="{'a':1,'b':2,'c':3,'d':4}";

        -- 创建json测试表
        CREATE TABLE json_test (str1 JSON, str2 LONGTEXT);

        -- 给 str1 插入 @a 成功，@b 失败；str2 任何字符都能插入。
        INSERT INTO json_test VALUES (@a,@a);
        INSERT INTO json_test VALUES (@b,@b);
        (4025, 'CONSTRAINT `json_test.str1` failed for `test`.`json_test`')
        INSERT INTO json_test VALUES (@a,@b);

        -- 查看插入的数据
        SELECT * FROM json_test
        +---------------------------+---------------------------+
        | str1                      | str2                      |
        +---------------------------+---------------------------+
        | {"a":1,"b":2,"c":3,"d":4} | {"a":1,"b":2,"c":3,"d":4} |
        | {"a":1,"b":2,"c":3,"d":4} | {'a':1,'b':2,'c':3,'d':4} |
        +---------------------------+---------------------------+

        -- json_extract()函数进行检索变量，对 @b 来说，可能比较麻烦，但是换成 @a 就容易多了。
        SELECT json_extract(@a,'$.a') as 'a';
        ```

- Vector向量类型：

    > mysql 9.0支持

    - vector类型具有一些限制，例如，无法将其与其他类型的数据进行比较，可以将其与vector类型的数据进行等值比较，但无法进行其他的比较。vector列无法作为任何键使用。

    - vector值可以用于 BIT_LENGTH()、CHAR_LENGTH()、HEX()、 LENGTH()，及 TO_BASE64()函数，其他的字符串相关函数无法使用vector值作为参数。

        - 此外，vector值还可以用于 AES_ENCRYPT()、 COMPRESS()、MD5()、SHA1()，及SHA2()加密函数，及COALESCE()、IFNULL()、 NULLIF()，和IF()。

    - vector值无法作为聚合函数或窗口函数的参数使用，也无法进行下列操作或函数的参数使用：

        - 数值函数和运算符
        - 时间函数
        - 全文检索功能
        - XML函数
        - 位函数，AND和OR
        - JSON函数

    - Vector函数：伴随着vector类型的推出，9.0同时推出了三个函数与之配合，分别是：

        - `STRING_TO_VECTOR(string)`：与`TO_VECTOR()`相同，将字符串表示为VECTOR列的二进制值。
            ```sql
            SELECT STRING_TO_VECTOR("[3.14,2024,18]");
            +------------------------------------------------------------------------+
            | STRING_TO_VECTOR("[3.14,2024,18]")                                     |
            +------------------------------------------------------------------------+
            | 0xC3F548400000FD4400009041                                             |
            +------------------------------------------------------------------------+
            1 row in set (0.00 sec)
            ```

        - `VECTOR_TO_STRING()`：与`FROM_VECTOR()`相同，所具有的功能与TO_VECTOR()相反。例如，

            ```sql
            SELECT VECTOR_TO_STRING(0xC3F548400000FD4400009041);
            +----------------------------------------------+
            | VECTOR_TO_STRING(0xC3F548400000FD4400009041) |
            +----------------------------------------------+
            | [3.14000e+00,2.02400e+03,1.80000e+01]        |
            +----------------------------------------------+
            1 row in set (0.00 sec)
            ```

        - VECTOR_DIM(vector)：返回该向量包含的条目数量。例如，

            ```sql
            SELECT VECTOR_DIM(0xC3F548400000FD4400009041);
            +----------------------------------------+
            | VECTOR_DIM(0xC3F548400000FD4400009041) |
            +----------------------------------------+
            |                                      3 |
            +----------------------------------------+
            1 row in set (0.00 sec)
            ```

    ```sql
    create table t_vector (id int, c_v vector);

    insert into t_vector values(1,to_vector('[1,1]'));
    insert t_vector select 2,to_vector('[2,2]');

    select * from t_vector;
    +------+--------------------+
    | id   | c_v                |
    +------+--------------------+
    |    1 | 0x0000803F0000803F |
    |    2 | 0x0000004000000040 |
    +------+--------------------+

    select id,from_vector(c_v) from t_vector;
    +------+---------------------------+
    | id   | from_vector(c_v)          |
    +------+---------------------------+
    |    1 | [1.00000e+00,1.00000e+00] |
    |    2 | [2.00000e+00,2.00000e+00] |
    +------+---------------------------+

    select id,vector_dim(c_v) from t_vector;
    +------+-----------------+
    | id   | VECTOR_DIM(c_v) |
    +------+-----------------+
    |    1 |               2 |
    |    2 |               2 |
    +------+-----------------+
    ```

##### [dbaplus社群：MySQL中Varchar(50)和varchar(500)有什么区别？](https://mp.weixin.qq.com/s/02D5sHTsYDPw-r6W3SJEgg)

- 测试省略...

- 结论
    - 1.两张表在占用空间上确实是一样的，并无差别

    - 2.通过索引覆盖查询性能差别不大

    - 3.索引范围查询性能基本相同, 增加了order By后开始有一定性能差别；

    - 4.全表扫描无排序情况下,两者性能无差异,在全表有排序的情况下, 两种性能差异巨大；

        - 至此，我们不难发现，当我们最该字段进行排序操作的时候，Mysql会根据该字段的设计的长度进行内存预估，如果设计过大的可变长度，会导致内存预估的值超出sort_buffer_size的大小，导致mysql采用磁盘临时文件排序,最终影响查询性能。

##### [爱可生开源社区：技术分享 | MySQL VARCHAR 最佳长度评估实践](https://mp.weixin.qq.com/s/gTc1nMez3_pYTl0dZbLl6A)

- 问题：对一个 VARCHAR 类型的字段进行长度扩容。为什么从 VARCHAR(20) 调整为 VARCHAR(50) 就比较快，但是从  VARCHAR(50) 调整为 VARCHAR(100) 就需要执行很久呢？

- 实验对比。省略...

- 由于 `UTF8MB4` 为四字节编码字符集：即一个字节长度可存储 63.75（255/4）个字符
    - 所以当我们将 VARCHAR(63) 修改为 VARCHAR(64) 时，需要增加一个字节去进行数据的存储，就要通过建立临时表的方式去完成本次长度扩容，故需要花费大量时间。

- 由于 `UTF8` 为三字节编码字符集：即一个字节可存储 85（255/3=85）个字符。

| 字符长度修改 | UTF8(MB3)                                  | UTF8MB4                                      |
|--------------|--------------------------------------------|----------------------------------------------|
| 20->50       | online ddl (inplace)                       | online ddl (inplace)                         |
| 50->100      | online ddl (copy)                          | online ddl (copy)                            |
| X->Y         | 当Y*3<256 时，inplace；当X*3>=256，inplace | 当 Y*4<256 时，inplace；当 X*4>=256，inplace |
| 备注         | 一个字符最大占用 3 个字节                  | 一个字符最大占用 4 个字节                    |

- 使用 UTF8MB4 举例：

    - 对于字段的最大字节长度在 256 字符内变化 (即 x*4<256 且 Y*4<256)，online ddl 走 inplace 模式，效率高。
    - 对于字段的最大字节长度在 256 字符外变化 (即 x*4>=256 且 Y*4>=256) ，online ddl 走 inplace 模式，效率高。
    - 否则，online ddl 走 copy 模式，效率低.
    - UTF8(MB3) 同理。


- 为避免由于后期字段长度扩容，online ddl 走效率低的 copy 模式，建议：

    - 对于 UTF8(MB3) 字符类型：
        - 字符个数小于 50 个，建议设置为 VARCHAR(50) 或更小的字符长度。
        - 字符个数接近 84（256/3=83.33）个，建议设置为 VARCHAR(84)  或更大的字符长度。
    - 对于 UTF8MB4 字符类型：
        - 字符个数小于 50 个，建议设置为 VARCHAR(50)，或更小的字符长度。
        - 字符个数接近 64（256/4=64）个，建议设置为 VARCHAR(64) 或更大的字符长度。

##### [爱可生开源社区：技术分享 | MySQL 隐式转换必知必会](https://mp.weixin.qq.com/s/VzbRxNlcfOsBdoMtRHu6lw)

- 隐式类型转换导致SQL索引失效，性能极差，进而影响影响集群负载和业务的情况。

- 常见的 SQL 产生隐式转换的场景有：
    - 1.数据类型的隐式转换
    - 2.字符集的隐式转换

        > 说明：字符集是针对字符类型数据的编码规则，对于数值类型则不需要进行转换字符集。

        - 其中，特别是在表连接场景和存储过程中的字符集转换很容易被忽略。

###### 数据类型的隐式转换

- 创建测试表：
    ```sql
    t1 表字段 a 为 VARCHAR 类型，t2 表字段 a 为 INT 类型。
    CREATE TABLE `t1` (
      `id` int(11) NOT NULL,
      `a` varchar(20) DEFAULT NULL,
      `b` varchar(20) DEFAULT NULL,
      PRIMARY KEY (`id`),
      KEY `a` (`a`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8

    CREATE TABLE `t2` (
      `id` int(11) NOT NULL,
      `a` int(11) DEFAULT NULL,
      `b` varchar(20) DEFAULT NULL,
      PRIMARY KEY (`id`),
      KEY `a` (`a`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8
    ```

- 单表示例：

    - 有以下两种类型的转换：

        - 1.字段类型为字符串，参数为整型时：会导致索引失效
        - 2.字段类型为整型，参数为字符串时：不会导致索引失效

        - 这是因为在字符串与数字进行比较时，MySQL 会将字符串类型转换为数字进行比较，因此当字段类型为字符串时，会在字段上加函数，而导致索引失效。

    ```sql
    -- 字段类型为varchar，传参为整数，无法走到索引
    explain select * from t1 where a=1000;
    +----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------------+
    | id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows   | filtered | Extra       |
    +----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------------+
    |  1 | SIMPLE      | t1    | NULL       | ALL  | a             | NULL | NULL    | NULL | 498892 |    10.00 | Using where |
    +----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-------------+

    -- 字段类型为int，传参为字符串，可以走到索引
    explain select * from t2 where a='1000';
    +----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+-------+
    | id | select_type | table | partitions | type | possible_keys | key  | key_len | ref   | rows | filtered | Extra |
    +----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+-------+
    |  1 | SIMPLE      | t2    | NULL       | ref  | a             | a    | 5       | const |    1 |   100.00 | NULL  |
    +----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+-------+
    ```

- 为什么不能将数字转换为字符串进行比较呢?
    - 字符串的比较是逐个比较字符串的大小，直到找到不同的字符，这样的比较结果和数字的比较结果是不同的。
    ```sql
    select '100' > '99'
    ```

- 表连接中的数据类型转换

    - 当两个表的连接字段类型不一致时会导致隐式转换（MySQL 内部增加 cast() 函数），无法走到连接字段索引，进而可能无法使用最优的表连接顺序。

    - 原本作为被驱动表的表由于无法使用到索引，而可能作为驱动表。

    ```sql
    -- t2 表作为驱动表，但由于数据类型不同，实际上执行的 SQL 是：select * from t1 join t2 on cast(t1.a as unsigned)=t2.a where t2.id<1000
    explain select * from t1 join t2 on t1.a=t2.a where t2.id<1000;
    +----+-------------+-------+------------+------+---------------+------+---------+------------+--------+----------+-----------------------+
    | id | select_type | table | partitions | type | possible_keys | key  | key_len | ref        | rows   | filtered | Extra                 |
    +----+-------------+-------+------------+------+---------------+------+---------+------------+--------+----------+-----------------------+
    |  1 | SIMPLE      | t1    | NULL       | ALL  | a             | NULL | NULL    | NULL       | 498892 |   100.00 | Using where           |
    |  1 | SIMPLE      | t2    | NULL       | ref  | PRIMARY,a     | a    | 5       | test1.t1.a |      1 |     5.00 | Using index condition |
    +----+-------------+-------+------------+------+---------------+------+---------+------------+--------+----------+-----------------------+

    show warnings;
    +---------+------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Level   | Code | Message                                                                                                                                                                                                                                                                                    |
    +---------+------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Warning | 1739 | Cannot use ref access on index 'a' due to type or collation conversion on field 'a'                                                                                                                                                                                                        |
    | Note    | 1003 | /* select#1 */ select `test1`.`t1`.`id` AS `id`,`test1`.`t1`.`a` AS `a`,`test1`.`t1`.`b` AS `b`,`test1`.`t2`.`id` AS `id`,`test1`.`t2`.`a` AS `a`,`test1`.`t2`.`b` AS `b` from `test1`.`t1` join `test1`.`t2` where ((`test1`.`t2`.`id` < 1000) and (`test1`.`t1`.`a` = `test1`.`t2`.`a`)) |
    +---------+------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

    -- t1 作为被驱动表，则没有办法走到 t1.a 的索引，因此选择 t1 表作为驱动表
    ```

###### 字符集的隐式转换

- 当参数字符集和字段字符集不同时，无法直接进行比较，而需要进行字符集转换，则可能需要在转换字段上加 convert() 函数来转换字符集，导致索引失效。

- 创建测试数据库、表
    ```sql
    CREATE DATABASE `test` /*!40100 DEFAULT CHARACTER SET utf8mb4 */

    CREATE TABLE `t1` (
      `id` int(11) NOT NULL,
      `a` varchar(20) DEFAULT NULL,
      `b` varchar(20) DEFAULT NULL,
      PRIMARY KEY (`id`),
      KEY `a` (`a`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8

    CREATE TABLE `t2` (
      `id` int(11) NOT NULL,
      `a` varchar(20) DEFAULT NULL,
      `b` varchar(20) DEFAULT NULL,
      PRIMARY KEY (`id`),
      KEY `a` (`a`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    ```

- 单表示例

    ```sql
    -- 正常执行时，匹配字段的字符集（没有单独指定时继承表的字符集）
    explain select * from t1 where a='1000';
    +----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+-------+
    | id | select_type | table | partitions | type | possible_keys | key  | key_len | ref   | rows | filtered | Extra |
    +----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+-------+
    |  1 | SIMPLE      | t1    | NULL       | ref  | a             | a    | 63      | const |    1 |   100.00 | NULL  |
    +----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+-------+

    -- 将参数转换不同的字符集，无法走到索引，而是全表扫描
    explain select * from t1 where a=convert('1000' using utf8mb4);
    +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
    | id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra       |
    +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+
    |  1 | SIMPLE      | t1    | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 2000 |   100.00 | Using where |
    +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------------+


    -- show warnings可以看到优化器进行了转换，在t1.a上加了convert函数，从而无法走到索引
    show warnings;
    +-------+------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Level | Code | Message                                                                                                                                                                                               |
    +-------+------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Note  | 1003 | /* select#1 */ select `test`.`t1`.`id` AS `id`,`test`.`t1`.`a` AS `a`,`test`.`t1`.`b` AS `b` from `test`.`t1` where (convert(`test`.`t1`.`a` using utf8mb4) = <cache>(convert('1000' using utf8mb4))) |
    +-------+------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    ```

    - MySQL 内部会优先将低级的字符集转换为更高级的字符集，例如将 UTF8 转换为 UTF8MB4。

    - 在前面的示例中，convert() 函数加在 t1.a 上，而下面这个示例，convert() 函数加在参数上，而非 t2.a 字段上，这种情况则没有导致性能变差：

        ```sql
        CREATE TABLE `t2` (
          `id` int(11) NOT NULL,
          `a` varchar(20) DEFAULT NULL,
          `b` varchar(20) DEFAULT NULL,
          PRIMARY KEY (`id`),
          KEY `a` (`a`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4

        explain select * from t2 where a=convert('1000' using utf8);
        +----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+-------+
        | id | select_type | table | partitions | type | possible_keys | key  | key_len | ref   | rows | filtered | Extra |
        +----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+-------+
        |  1 | SIMPLE      | t2    | NULL       | ref  | a             | a    | 83      | const |    1 |   100.00 | NULL  |
        +----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+-------+

        show warnings;
        +-------+------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
        | Level | Code | Message                                                                                                                                                                                   |
        +-------+------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
        | Note  | 1003 | /* select#1 */ select `test`.`t2`.`id` AS `id`,`test`.`t2`.`a` AS `a`,`test`.`t2`.`b` AS `b` from `test`.`t2` where (`test`.`t2`.`a` = convert(convert('1000' using utf8) using utf8mb4)) |
        +-------+------+-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
        ```

- 表连接中的字符集转换

    - 当两个表的连接字段字符集不一致时会导致隐式转换（MySQL 内部增加 convert() 函数），无法走到连接字段索引，进而可能无法使用最优的表连接顺序。

    - 原本作为被驱动表的表由于无法使用到索引，而可能作为驱动表。

    - 示例：

        - 正常情况下，MySQL 会优先小结果集的表作为驱动表，在本例中即为 t2 为驱动表，t1 为被驱动表。
        - 但是由于字符集不同，实际上执行的 SQL 为 show warnings 看到的，对 t1.a 字段加了 convert() 函数进行转换字符集，则无法走到 t1.a 字段的索引而不得不改变连接顺序。

        ```sql
        explain select * from t1 left join t2 on t1.a=t2.a where t2.id<1000;
        +----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-----------------------+
        | id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows   | filtered | Extra                 |
        +----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-----------------------+
        |  1 | SIMPLE      | t1    | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 498649 |   100.00 | NULL                  |
        |  1 | SIMPLE      | t2    | NULL       | ref  | PRIMARY,a     | a    | 83      | func |      1 |     4.79 | Using index condition |
        +----+-------------+-------+------------+------+---------------+------+---------+------+--------+----------+-----------------------+

        show warnings;
        +-------+------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
        | Level | Code | Message                                                                                                                                                                                                                                                                                                |
        +-------+------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
        | Note  | 1003 | /* select#1 */ select `test`.`t1`.`id` AS `id`,`test`.`t1`.`a` AS `a`,`test`.`t1`.`b` AS `b`,`test`.`t2`.`id` AS `id`,`test`.`t2`.`a` AS `a`,`test`.`t2`.`b` AS `b` from `test`.`t1` join `test`.`t2` where ((`test`.`t2`.`id` < 1000) and (convert(`test`.`t1`.`a` using utf8mb4) = `test`.`t2`.`a`)) |
        +-------+------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+




        -- 在下面示例中，虽然也发生了类型转换，但是效率并没有变差，因为原本最优的连接顺序就是t1作为驱动表
        explain select * from t1 left join t2 on t1.a=t2.a where t1.id<1000;
        +----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
        | id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref  | rows | filtered | Extra       |
        +----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+
        |  1 | SIMPLE      | t1    | NULL       | range | PRIMARY       | PRIMARY | 4       | NULL |  999 |   100.00 | Using where |
        |  1 | SIMPLE      | t2    | NULL       | ref   | a             | a       | 83      | func |    1 |   100.00 | Using where |
        +----+-------------+-------+------------+-------+---------------+---------+---------+------+------+----------+-------------+

        show warnings;
        +-------+------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
        | Level | Code | Message                                                                                                                                                                                                                                                                                                   |
        +-------+------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
        | Note  | 1003 | /* select#1 */ select `test`.`t1`.`id` AS `id`,`test`.`t1`.`a` AS `a`,`test`.`t1`.`b` AS `b`,`test`.`t2`.`id` AS `id`,`test`.`t2`.`a` AS `a`,`test`.`t2`.`b` AS `b` from `test`.`t1` left join `test`.`t2` on((convert(`test`.`t1`.`a` using utf8mb4) = `test`.`t2`.`a`)) where (`test`.`t1`.`id` < 1000) |
        +-------+------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
        ```

##### 存储过程中的字符集转换

- 这也是比较容易忽略的一种场景，问题的发现是在生产环境存储过程中根据主键更新，但却需要执行 10s+。

- 存储过程中变量的字符集默认继承自 database 的字符集（也可以在创建时指定），当表字段字符集和 database 的字符集不一样时，就会出现类似前面的隐式字符集类型转换。

- 示例：

    - database 的字符集是 UTF8MB4
    - character_set_client 和 collation_connection 是创建存储过程时会话的 character_set_client 和 collation_connection 的值
    - 经测试存储过程中的变量的字符集是和数据库级别的字符集一致

    ```sql
    -- 存储过程信息：Database Collation: utf8mb4_general_ci
    show create procedure update_data\G
    *************************** 1. row ***************************
               Procedure: update_data
                sql_mode: ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION
        Create Procedure: CREATE DEFINER=`root`@`%` PROCEDURE `update_data`()
    begin
      declare j int;
      declare n varchar(100);
       select charset(n);
      set j=1;
      while(j<=2000)do
    set n = cast(j as char);
    select 1,now();
        update t1 set b=concat(b,'1') where a=n;
    select 2,now();
    select sleep(1);
        set j=j+1;
      end while;
    end
    character_set_client: utf8mb4
    collation_connection: utf8mb4_general_ci
      Database Collation: utf8mb4_general_ci

    -- 如下，在执行存储过程后，看到打印的变量n的字符集是utf8mb4
    call update_data();
    +------------+
    | charset(n) |
    +------------+
    | utf8mb4    |
    +------------+
    ```

- 根据索引字段 a 更新的语句实际上是变成了下面这样，走的是全表扫描（type:index，key：primary）。

    ```sql
    explain update t1 set b=concat(b,'1') where a=convert('1000' using utf8mb4);
    +----+-------------+-------+------------+-------+---------------+---------+---------+------+--------+----------+-------------+
    | id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref  | rows   | filtered | Extra       |
    +----+-------------+-------+------------+-------+---------------+---------+---------+------+--------+----------+-------------+
    |  1 | UPDATE      | t1    | NULL       | index | NULL          | PRIMARY | 4       | NULL | 498649 |   100.00 | Using where |
    +----+-------------+-------+------------+-------+---------------+---------+---------+------+--------+----------+-------------+

    -- 而正常情况下，执行计划为：
    explain update t1 set b=concat(b,'1') where a='1000';
    +----+-------------+-------+------------+-------+---------------+------+---------+-------+------+----------+-------------+
    | id | select_type | table | partitions | type  | possible_keys | key  | key_len | ref   | rows | filtered | Extra       |
    +----+-------------+-------+------------+-------+---------------+------+---------+-------+------+----------+-------------+
    |  1 | UPDATE      | t1    | NULL       | range | a             | a    | 63      | const |    1 |   100.00 | Using where |
    +----+-------------+-------+------------+-------+---------------+------+---------+-------+------+----------+-------------+
    ```

- 更新时间也由 0.00sec 变为 0.60sec，在表数据量很大的情况下，全表扫描将会对生产产生较大影响。

    ```sql
    update t1 set b=concat(b,'1') where a='1000';
    Query OK, 1 row affected (0.00 sec)
    Rows matched: 1  Changed: 1  Warnings: 0

    update t1 set b=concat(b,'1') where a=convert('1000' using utf8mb4);
    Query OK, 1 row affected (0.60 sec)
    Rows matched: 1  Changed: 1  Warnings: 0
    ```

#### 基本使用

```sql
-- 创建 new 数据库设置 id 为主键,不能为空,自动增量
CREATE TABLE new(
    `id` int (8) AUTO_INCREMENT COMMENT '自增主键ID', -- AUTO_INCREMENT 自动增量(每条新记录递增 1) # int(8)不影响int本身支持的大小，依然可以插入最大值4294967295(2^32-1) # COMMENT注释
    `name` varchar(50) NOT NULL UNIQUE,     -- NOT NULL 设置不能为空 # UNIQUE 设置唯一性索引 # varchar(50)最多50个字符，超过就报错
    `date` DATE DEFAULT '2020-10-24',       -- DEFAULT 设置默认值
    INDEX date(date),                       -- INDEX 创建索引
    PRIMARY KEY (`id`),                     -- 设置主健为 id 字段(列)
    CHECK (name in ('tz', 'tz1', 'tz2'))    -- CHECK 设置name必须满足in内的集合
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin COMMENT '测试表'; -- 字符集编码为 utf8mb4，排序规则为utf8mb4_bin。不推荐显示设置，因为默认会继承数据库的字符集编码和排序规则。COMMENT为注释
```

- `NULL` / `NOT NULL`

    - 对于包含 NULL 列的求 COUNT 值也不准确

        - 当然了不仅仅是 COUNT，除了 NULL 相关的函数，大部分对 NULL 处理都不友好。

        ```sql
        -- t1 和 t2 的记录数是一样的，但是t1的字段 r1 包含了 NULL，这导致结果忽略了这些值。
        select count(r1) as rc from t1;
        +-------+
        | rc    |
        +-------+
        | 16384 |
        +-------+
        select count(r1) as rc from t2;
        +-------+
        | rc    |
        +-------+
        | 32768 |
        +-------+

        -- 正确的方法是用 NULL 相关函数处理
        select count(ifnull(r1,'')) as rc from t1;
        +-------+
        | rc    |
        +-------+
        | 32768 |
        +-------+
        -- 或者是直接用 COUNT(*) 包含了所有可能的值
        select count(*) as rc from t1;
        +-------+
        | rc    |
        +-------+
        | 32768 |
        +-------+
        ```

    - 对包含 NULL 列建立索引，比不包含的 NULL 的字段，要多占用一个 BIT 位来存储。

- `UNIQUE` 唯一性索引
  > - 列(字段) 内的数据不能出现重复

    - PRIMARY KEY ( `列名称` ) 设置主键
      > - 和 UNIQUE(唯一性索引) 一样.列(字段) 内的数据不能出现重复
      >
      > - 主键一定是唯一性索引,唯一性索引并不一定就是主键.
      >
      > - 主键列不允许空值,而唯一性索引列允许空值.

- `CHECK`约束：列字段的值必须满足条件

    ```sql
    CREATE TABLE check_test
    (
        r1 int CHECK (r1 > 10),
        r2 int CHECK (r2 > 0),
        r3 int CHECK (r3 < 100),
        CHECK (r1 <> 0),
        CHECK (r1 <> r2),
        CHECK (r1 > r3)
    );

    -- 插入成功
    insert into check_test values (20,10,10);

    -- 插入失败。r1没有大于10
    insert into check_test values (10,10,10);
    (4025, 'CONSTRAINT `check_test.r1` failed for `test`.`check_test`')
    -- 插入失败。r2没有大于0
    insert into check_test values (20,-10,10);
    (4025, 'CONSTRAINT `check_test.r2` failed for `test`.`check_test`')
    -- 插入失败。r1没有大于r3
    insert into check_test values (20,10,30);
    (4025, 'CONSTRAINT `CONSTRAINT_3` failed for `test`.`check_test`')
    ```

- 查看表的相关命令

    ```sql
    -- desc 查看 new 表里的字段
    desc new;
    +-------+-------------+------+-----+------------+----------------+
    | Field | Type        | Null | Key | Default    | Extra          |
    +-------+-------------+------+-----+------------+----------------+
    | id   | int(8)      | NO  | PRI | <null>     | auto_increment |
    | name | varchar(50) | NO  | UNI | <null>     |                |
    | date | date        | YES | MUL | 2020-10-24 |                |
    +-------+-------------+------+-----+------------+----------------+

    -- 查看 new 表详细信息
    show create table new\G;
    ***************************[ 1. row ]***************************
    Table        | new
    Create Table | CREATE TABLE `new` (
      `id` int(8) NOT NULL AUTO_INCREMENT,
      `name` varchar(50) NOT NULL,
      `date` date DEFAULT '2020-10-24',
      PRIMARY KEY (`id`),
      UNIQUE KEY `name` (`name`),
      KEY `date` (`date`),
      CONSTRAINT `CONSTRAINT_1` CHECK (`name` in ('tz','tz1','tz2'))
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4

    -- 修改 new表id字段 的初始值为100
    ALTER TABLE new AUTO_INCREMENT=100;

    -- 查看表索引。只有date不是唯一性索引
    show index from new
    +-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+
    | Table | Non_unique | Key_name | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Ignored |
    +-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+
    | new   | 0          | PRIMARY  | 1            | id          | A         | 0           | <null>   | <null> |      | BTREE      |         |               | NO      |
    | new   | 0          | name     | 1            | name        | A         | 0           | <null>   | <null> |      | BTREE      |         |               | NO      |
    | new   | 1          | date     | 1            | date        | A         | 0           | <null>   | <null> | YES  | BTREE      |         |               | NO      |
    +-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+
    ```

- 表的克隆

    - `CREATE table_name1 AS SELECT`：
        - 数据会复制过来，但主键、自动递增和索引丢失。

    - `CREATE table_name1 LIKE table_name`
        - 表结构可完整的复制过来，但没有数据。

        ```sql
        -- 创建测试表
        CREATE TABLE test_like (
            id int
        );

        -- like命令可以创建表结构一样的表。数据不会复制
        CREATE TABLE test_like1 LIKE test_like;
        ```

#### 压缩表

- [爱可生开源社区：第11期：压缩表](https://mp.weixin.qq.com/s?__biz=MzU2NzgwMTg0MA==&mid=2247489135&idx=1&sn=ae7b36d8ce2d2d37f65e53bde1865acb&chksm=fc96f4f0cbe17de62d4c69c05df761129e7b2861ef784bafbc3202ebc365d2b131bf551f80be&cur_album_id=1338281900976472064&scene=189#wechat_redirect)

- 如果你熟悉列式数据库，那对这个概念一定不陌生。以下都是有压缩能力非常强的数据库产品。
    - 基于 PostgreSQL 的列式数据库 Greenplum
    - 早期基于 MySQL 的列式数据库 inforbright
    - Percona 的产品 tokudb

- 为什么要用压缩表？

    - 情景一：磁盘大小为 1T，不算其他的空间占用，只能存放 10 张 100G 大小的表。如果这些表以一定的比率压缩后，比如每张表从 100G 压缩到 10G，那同样的磁盘可以存放 100 张表，表的容量是原来的 10 倍。

    - 情景二：默认 MySQL 页大小 16K，而 OS 文件系统一般块大小为 4K，所以在 MySQL 在刷脏页的过程中，有一定的概率出现页没写全而导致数据坏掉的情形。
        - 比如 16K 的页写了 12K，剩下 4K 没写成功，导致 MySQL 页数据损坏。这个时候就算通过 Redo Log 也恢复不了，因为几乎有所有的关系数据库采用的 Redo Log 都记录了数据页的偏移量，此时就算通过 Redo Log 恢复后，数据也是错误的。
        - 所以 MySQL 在刷脏数据之前，会把这部分数据先写入共享表空间里的 `DOUBLE WRITE BUFFER` 区域来避免这种异常。
        - 此时如果 MySQL 采用压缩表，并且每张表页大小和磁盘块大小一致，比如也是 4K，那 `DOUBLE WRITE BUFFER` 就可以不需要，这部分开销就可以规避掉了。

- 压缩表
    - 优点：节省磁盘 IO，减少网络 IO
    - 缺点：写入（INSERT,UPDATE,DELETE）比普通表要消耗更多的 CPU 资源
        - 写入涉及到解压数据，更新数据，再压缩数据，比普通表多了解压和再压缩两个步骤，压缩和解压缩需要消耗一定的 CPU 资源。所以需要选择一个比较优化的压缩算法。

- 压缩表适用场景

    - 1.SELECT 业务
        - 这类操作不需要对压缩页进行解压，所以非常适合使用压缩表。

    - 2.INSERT 业务
        - 这类操作需要重新对二级索引数据页解压和以及重新压缩，不过 MySQL 对这部分操作放入 change buffer，所以频率相对来说不是很高。

    - 3.DELETE 业务
        - 由于 MySQL 对删除的操作是直接写标记位，然后等待定期的 PURGE 线程清理，这块也适合用压缩表。

    - 4.UPDATE 业务
        - 由于压缩表一般都是对字符串类的数据，比如 TEXT,VARCHAR 等压缩，所以针对这块的数据做更新，很容易就把更改日志（上篇介绍过）打满，继而造成频繁的解压和压缩操作。

    - 总的来说压缩表适合于读密集、只读、或者极少量更新的业务场景。

- 压缩表的限制
    - 1.系统表空间不支持；
    - 2.通用表空间不能混合存储压缩表以及原始表；
    - 3.`row_format=compressed`，这种方式容易混淆成针对行的压缩，其实是针对表和相关索引的压缩。这点和其他列式存储引擎的表完全不一样；
    - 4.临时表不支持。

- 压缩表对 B-tree 页面的影响
    - 1.每个 B-tree 页压缩表至少保存一条记录
        - 这一点相比普通表页来说，相对灵活些，比如普通表每个页至少保留两条记录。

    - 2.更改日志（modification log）

        - MySQL 为每个压缩页里设置一个 16K 大小的更改日志，用来解决对压缩表进行写入时的一系列问题。
            - 比如，页分裂或者不必要的解压和重新压缩等。

        - 每个页面会预留空一部分空余空间来保存压缩页需要修改的行。这样做的好处是不用每次都对整个页进行解压、再更新、再压缩等步骤，节省开销。那这些行的更新放在更改日志里，当更改日志满了，就进行一次数据压缩。对应参数为：innodb_compression_pad_pct_max（默认 50，代表 50%）。如果重新压缩时失败了，那就需要进行相关页的分裂与合并，直到重新压缩成功。

            - 例子：假设压缩页 1 里保存了 10 条记录，可能每分钟要轮流更新一行记录，那如果每分钟都对整个页进行解压，更新，再压缩，对 CPU 开销很大，此时可以把这些更新的行放到更改日志里，等更改日志满了，再一次性重新压缩这些记录。

- 压缩表对 InnoDB Buffer Pool 的影响

    - 每个压缩页在 InnoDB Buffer Pool 里存放的是压缩页和非压缩并存的形式。
        - 例子：读取一张压缩表的一行记录，如果 Buffer Pool 里没有，就需要回表找到包含这行记录的压缩页（1k,2k,4k,8k)，放入 Buffer Pool，同时放入包含这行的非压缩页（16K）
    - 如果 Buffer Pool 满了，把原始页面踢出，保留压缩页
    - 极端情形，Buffer Pool 里两者都不包含。


- InnoDB 压缩表和 MyISAM 压缩表不同是针对页的压缩。InnoDB 不仅压缩了数据，也压缩了索引。

    ```sql
    -- 查看压缩算法
    SHOW VARIABLES LIKE "innodb_compression_algorithm";
    +------------------------------+-------+
    | Variable_name                | Value |
    +------------------------------+-------+
    | innodb_compression_algorithm | zlib  |
    +------------------------------+-------+

    -- 查看压缩等级
    SHOW VARIABLES LIKE 'innodb_compression_level';
    +--------------------------+-------+
    | Variable_name            | Value |
    +--------------------------+-------+
    | innodb_compression_level | 6     |
    +--------------------------+-------+

    SHOW GLOBAL STATUS WHERE Variable_name IN (
       'Innodb_have_lz4',
       'Innodb_have_lzo',
       'Innodb_have_lzma',
       'Innodb_have_bzip2',
       'Innodb_have_snappy'
    );
    +--------------------+-------+
    | Variable_name      | Value |
    +--------------------+-------+
    | Innodb_have_lz4    | ON    |
    | Innodb_have_lzo    | OFF   |
    | Innodb_have_lzma   | ON    |
    | Innodb_have_bzip2  | ON    |
    | Innodb_have_snappy | OFF   |
    +--------------------+-------+
    ```

- `ROW_FORMAT`创建表时启用数据压缩

    - 在某些情况下，压缩率会很低（例如，数据太随机且太独特）。在这种情况下，您应该禁用压缩，因为它只会导致额外的 CPU 负载。

    ```sql
    -- 以压缩形式存储数据，并在读取时自动解压缩
    CREATE TABLE compressed_test (
        id int DEFAULT NULL,  msg text
    )ENGINE=InnoDB ROW_FORMAT=COMPRESSED
    ```

    ```sql
    root@ytt-pc:/var/lib/mysql/3304/ytt# ls -sihl
    总用量 22M
    3539514 22M -rw-r----- 1 mysql mysql 21M 3月 30 22:26 t1.ibd

    -- 更改表行格式为 compressed
    alter table t1 row_format=compressed;

    # 数据文件大小为 10M。压缩率大约为 50%
    root@ytt-pc:/var/lib/mysql/3304/ytt# ls -sihl
    总用量 11M
    3539513 11M -rw-r----- 1 mysql mysql 10M 3月 30 22:27 t1.ibd
    ```

- `KEY_BLOCK_SIZE`：设置页大小

    - InnoDB 页大小分别为 1K、2K、4K、8K、16K、32K、64K。默认为 16K。32K 和 64K 不支持压缩。

    ```sql
    // KEY_BLOCK_SIZE创建表时使用选项配置压缩页面（“块”）大小
    CREATE TABLE `test_2` (
        `id` int DEFAULT NULL,  `msg` text
    ) ENGINE=InnoDB KEY_BLOCK_SIZE=4
    ```

    - 比较多个值KEY_BLOCK_SIZE以了解它如何影响我们的表压缩效率：
        ![image](./Pictures/mysql/create启用数据压缩1.avif)

##### 压缩表性能监测

- [爱可生开源社区：第12期：压缩表性能监测](https://mp.weixin.qq.com/s?__biz=MzU2NzgwMTg0MA==&mid=2247489404&idx=1&sn=98ff9102292ec1aca4a2302a76775b0e&chksm=fc96f5e3cbe17cf55cad5fe5d048cc6400c22c6233f95cdf8f93ab4332c70810ecefe741e28d&cur_album_id=1338281900976472064&scene=189#wechat_redirect)

- 对压缩表的监控

    - 保存在 Information_schema 内以 INNODB_CMP 开头的字典表。通过这些表可以监控到压缩表是否健康，是否需要调整压缩页，或者说是否适合用压缩表等。

    - 这些表为内存表，也就是 memory 引擎。对这些表的检索必须具有 process 权限。

    ```sql
    show tables from information_schema  like '%CMP%';
    ```

    - 1.INNODB_CMP/INNODB_CMP_RESET表
        - InnoDB 压缩表的磁盘访问相关数据，其中 INNODB_CMP 和 INNODB_CMP_RESET 表结构相同
        - 不同的是 INNODB_CMP 代表压缩表历史访问数据，INNODB_CMP_RESET 用来重置压缩表历史数据。
        - 要监控一小时内的压缩表访问数据，可以执行下面的简单步骤：
            - 1.先采集 INNODB_CMP 相关数据；
            - 2.过一小时再次采集表 INNODB_CMP 相关数据；
            - 3.完后立刻访问 INNODB_CMP_RESET 表；
            - 4.初始化表 INNODB_CMP。

        ```sql
        -- 查看表结构
        -- 注意：这两个值的比率（compress_ops_ok/compress_ops）是最直观的数据，可以判断压缩表的健康与否；正常情况下，比率为 0 或者 1 或接近于 1；如果比率长时间不正常，就得考虑压缩表的页大小是否合适或者说压缩表是否应该在这种场景下使用。
        desc information_schema.innodb_cmp;
        +-----------------+---------+------+-----+---------+-------+
        | Field           | Type    | Null | Key | Default | Extra |
        +-----------------+---------+------+-----+---------+-------+
        | page_size       | int(5)  | NO   |     | <null>  |       |
        | compress_ops    | int(11) | NO   |     | <null>  |       |
        | compress_ops_ok | int(11) | NO   |     | <null>  |       |
        | compress_time   | int(11) | NO   |     | <null>  |       |
        | uncompress_ops  | int(11) | NO   |     | <null>  |       |
        | uncompress_time | int(11) | NO   |     | <null>  |       |
        +-----------------+---------+------+-----+---------+-------+
        ```

        - 相关字段含义为：
        ![image](./Pictures/mysql/压缩表-innodb_cmp表结构.avif)

    - 2.INNODB_CMPMEM /INNODB_CMPMEM_RESET

        - 这两张表代表在 innodb_buffer_pool 里的压缩表相关访问数据，INNODB_CMPMEM 代表历史数据；INNODB_CMPMEM_RESET 代表当前瞬时数据，只要访问一次，INNODB_CMPMEM 表即被重置。

        ```sql
        desc information_schema.innodb_cmpmem;
        +----------------------+------------+------+-----+---------+-------+
        | Field                | Type       | Null | Key | Default | Extra |
        +----------------------+------------+------+-----+---------+-------+
        | page_size            | int(5)     | NO   |     | <null>  |       |
        | buffer_pool_instance | int(11)    | NO   |     | <null>  |       |
        | pages_used           | int(11)    | NO   |     | <null>  |       |
        | pages_free           | int(11)    | NO   |     | <null>  |       |
        | relocation_ops       | bigint(21) | NO   |     | <null>  |       |
        | relocation_time      | int(11)    | NO   |     | <null>  |       |
        +----------------------+------------+------+-----+---------+-------+
        ```

        - 相关字段含义为：
        ![image](./Pictures/mysql/压缩表-innodb_cmpmem表结构.avif)

    - 3.INNODB_CMP_PER_INDEX/INNODB_CMP_PER_INDEX_RESET表

        - 这两张表代表对压缩表主键、二级索引的检索相关数据，不带 _RESET 为历史数据，带 _RESET 为瞬时数据。和前两类表不一样，这类表是针对索引的操作记录数据，开销很大

        ```sql
        -- 默认不开启
        select @@innodb_cmp_per_index_enabled;
        -- 开启
        set persist innodb_cmp_per_index_enabled = 1;

        desc information_schema.innodb_cmp_per_index;
        +-----------------+-------------+------+-----+---------+-------+
        | Field           | Type        | Null | Key | Default | Extra |
        +-----------------+-------------+------+-----+---------+-------+
        | database_name   | varchar(64) | NO   |     | <null>  |       |
        | table_name      | varchar(64) | NO   |     | <null>  |       |
        | index_name      | varchar(64) | NO   |     | <null>  |       |
        | compress_ops    | int(11)     | NO   |     | <null>  |       |
        | compress_ops_ok | int(11)     | NO   |     | <null>  |       |
        | compress_time   | int(11)     | NO   |     | <null>  |       |
        | uncompress_ops  | int(11)     | NO   |     | <null>  |       |
        | uncompress_time | int(11)     | NO   |     | <null>  |       |
        +-----------------+-------------+------+-----+---------+-------+
        ```

        - 相关字段含义为：
        ![image](./Pictures/mysql/压缩表-innodb_cmp-per_index表结构.avif)

- 压缩表监测的实际用例

    - 这篇主要介绍压缩表在各个场景下的简单监测，可以总结为：压缩表只适合应用在读密集型应用，或者少量删除或者更新的场景，其他的场景不建议用压缩表。

    - 使用单表空间建立两张表：
        - t1 ：未压缩表
        - t2 ：page 为 4K 的压缩表

    ```sql
    -- 创建测试表
    CREATE TABLE t1(
        id INT, r1 TEXT,r2 TEXT,PRIMARY KEY (id)
    ) ROW_FORMAT=DYNAMIC;

    CREATE TABLE t2(
        id INT, r1 TEXT,r2 TEXT,PRIMARY KEY (id)
    ) KEY_BLOCK_SIZE=4;
    ```

    ```sh
    # 插入一部分数据后，对应的磁盘大小
    root@ytt-pc:/var/lib/mysql/3305/ytt# ls -shil
    总用量 2.0G
    3949029 1.6G -rw-r----- 1 mysql mysql 1.6G 3月 31 21:18 t1.ibd
    3946045 405M -rw-r----- 1 mysql mysql 404M 3月 31 21:42 t2.ibd
    ```

    - 1.查询速度对比：压缩表单独查询时优势明显。

        ```sql
        select count(*) from t1;
        1 row in set (4.02 sec)

        select count(*) from t2;
        1 row in set (2.69 sec)


        select * from t1 where id = 100;
        2 rows in set (6.82 sec)

        select * from t1 where id = 100;
        2 rows in set (3.60 sec)
        ```

    - 2.删除数据

        - 重启 MySQL 实例，对压缩表 t2 进行删除与更新操作；或者清空表 INNODB_CMP 和 INNODB_CMP_PER_INDEX，也就是执行对应后缀为 `_RESET` 的表。

            ```sql
            -- 从表 t2 删除一条记录
            delete from t2 where id = 999999;
            ```

        - 对应的 compress_ops/compress_ops_ok 为 0

        - 表 INNODB_CMP_PER_INDEX 无数据，因为没有重建索引。可以看出 DELETE 操作对于压缩表很适合。

            ```sql
            use information_schema

            select * from innodb_cmp where page_size=4096\G
            *************************** 1. row ***************************
            page_size: 4096
            compress_ops: 0
            compress_ops_ok: 0
            compress_time: 0
            uncompress_ops: 0
            uncompress_time: 0
            1 row in set (0.00 sec)

            select * from innodb_cmp_per_index;
            Empty set (0.00 sec)
            ```
    - 3.更新少量数据

        - 同样执行对应 `_RESET` 后缀表清空数据

            ```sql
            update t2 set r1 = '200' where id = 200;
            ```

        - 查看对应的监测表数据，compress_ops_ok/compress_ops 为 1，也很健康。
            ```sql
            use information_schema

            select * from innodb_cmp where page_size=4096\G
            *************************** 1. row ***************************
            page_size: 4096
            compress_ops: 2
            compress_ops_ok: 2
            compress_time: 0
            uncompress_ops: 0
            uncompress_time: 0
            1 row in set (0.01 sec)

            select * from innodb_cmp_per_index\G
            *************************** 1. row ***************************
            database_name: ytt
            table_name: t2
            index_name: PRIMARY
            compress_ops: 2
            compress_ops_ok: 2
            compress_time: 0
            uncompress_ops: 0
            uncompress_time: 0
            1 row in set (0.00 sec)
            ```

    - 4.更新大量数据

        - 照例执行后缀 `_RESET` 的表，清空两张表。

            ```sql
            update t2 set r1 = '20000' where 1;
            ```

        - 查看对应监测表的数据，compress_ops_ok/compress_ops 比率很低，失败的操作占了一半。结果表明大量更新应该规避压缩表。

            ```sql
            use information_schema

            select * from innodb_cmp where page_size=4096\G
            *************************** 1. row ***************************
            page_size: 4096
            compress_ops: 48789
            compress_ops_ok: 6251
            compress_time: 4
            uncompress_ops: 21269
            uncompress_time: 0
            1 row in set (0.01 sec)

            select * from innodb_cmp_per_index\G
            *************************** 1. row ***************************
            database_name: ytt
            table_name: t2
            index_name: PRIMARY
            compress_ops: 48789
            compress_ops_ok: 6251
            compress_time: 4
            uncompress_ops: 21269
            uncompress_time: 0
            1 row in set (0.00 sec)
            ```

#### TEMPORARY临时表

- 临时表特点：
    - 临时表创建完成之后，只有当前连接可见，其他连接是看不到的，具有连接隔离性；
    - 临时表在当前连接结束之后，会被自动删除

- 可以利用这些特点，用临时表来存储 SQL 查询的中间结果。

- 存储方式不同，临时表也可分为
    - 内存临时表
    - 磁盘临时表

    - 对于同一条查询，内存中的临时表执行时间不到 10 毫秒，而磁盘上的表却用掉了 210 毫秒。
    - 因为数据完全在内存中，所以，一旦断电，数据就消失了，无法找回。不过临时表只保存中间结果，所以还是可以用的。

```sql
-- CREATE TEMPORARY 创建临时表。存储引擎是 InnoDB，并且把表存放在磁盘上。
CREATE TEMPORARY TABLE demo.mytransdisk(
    itemnumber int,
    groupnumber int,
    branchnumber int
);

-- ENGINE = MEMORY 创建内存临时表
CREATE TEMPORARY TABLE demo.mytrans(
    itemnumber int,
    groupnumber int,
    branchnumber int
) ENGINE = MEMORY;
```

#### [FOREIGN KEY(外键)](https://www.mysqltutorial.org/mysql-foreign-key/)

- 外键的设计初衷是为了在数据库端保证对逻辑上相关联的表数据在操作上的一致性与完整性。

- 外键在大部分企业写的开发规范里会直接规避掉！外键有优缺点，也并不是说每种场景都不适用，完全没有必要一刀切。

    - 优点：

        - 1.精简关联数据，减少数据冗余。

            - 避免后期对大量冗余处理的额外运维操作。

        - 2.降低应用代码复杂性，减少了额外的异常处理

            - 相关数据管理全由数据库端处理。

        - 3.增加文档的可读性

            - 特别是在表设计开始，绘制 ER 图的时候，逻辑简单明了，可读性非常强。

    - 缺点：

        - 1.性能压力

            - 外键一般会存在级联功能，级联更新，级联删除等等。在海量数据场景，造成很大的性能压力。比如插入一条新记录，如果插入记录的表有 10 个外键，那势必要对关联的 10 张表逐一检查插入的记录是否合理，延误了正常插入的记录时间。并且父表的更新会连带子表加上相关的锁。

        - 2.其他功能的灵活性不佳

            - 比如，表结构的更新等。

- 使用外键的条件

    - 1.父表和子表必须使用相同的存储引擎
        - MySQL 外键仅有 InnoDB 和 NDB 两种引擎支持

    - 2.外键必须要有索引
        - 子表创建后, 父表的外键索引不能删除

    - 3.外键和引用键中的对应列必须具有相似的数据类型.整数类型的大小和符号必须相同.字符串类型的长度不必相同.

- 外键的sql语句

    ```sql
    -- delete 和 update都设置为CASCADE级联
    CREATE TABLE foreign_test(
        `date` date,
        FOREIGN KEY (date) REFERENCES new(date)
             ON DELETE CASCADE
             ON UPDATE CASCADE
    );

    -- delete设置为CASCADE级联，update设置为NO ACTION
    CREATE TABLE foreign_test(
        `date` date,
        FOREIGN KEY (date) REFERENCES new(date)
             ON DELETE CASCADE
             ON UPDATE NO ACTION
    );
    ```

    - `CASCADE`: 级联，子表跟随父表更新外键值
    - `NO ACTION`: **默认**，不允许对父表外键对应值进行操作

##### FOREIGN 增删改，修改权限

- 创建 a,b 两表：a表为父表（基础表）、b表为子表（外键表）

    ```sql
    -- 创建a表
    CREATE TABLE a(
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL
    ) ENGINE=INNODB;

    -- 创建b表，设置外键a_id。这里先不设置CASCADE级联权限
    CREATE TABLE b(
        id INT AUTO_INCREMENT PRIMARY KEY,
        a_id INT NOT NULL,
        CONSTRAINT fk_a
        FOREIGN KEY (a_id)
        REFERENCES a(id)
    ) ENGINE=INNODB;

    -- 在创建b表时，如果没有指定 CONSTRAINT，系统会自动生成(我这里为 b_ibfk_1):
    CREATE TABLE b(
        id INT AUTO_INCREMENT PRIMARY KEY,
        a_id INT NOT NULL,
        FOREIGN KEY (a_id)
        REFERENCES a(id)
    ) ENGINE=INNODB;

    -- 查看CONSTRAINT
    show create table b\G;
    *************************** 1. row ***************************
           Table: b
    Create Table: CREATE TABLE `b` (
      `id` int(11) DEFAULT NULL,
      `a_id` int(11) DEFAULT NULL,
      KEY `a_id_index` (`a_id`),
      CONSTRAINT `b_ibfk_1` FOREIGN KEY (`a_id`) REFERENCES `a` (`id`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
    1 row in set (0.000 sec)
    ```

    ```sql
    -- 插入a 表 id 为1
    INSERT INTO a (id,name) VALUE
    (1,'in a');

    -- 插入b 表 外键a_id 必须和刚才插入 a 表的 id 值一样
    INSERT INTO b (id,a_id) VALUE
    (10,1);
    ```

- b 表:无法对 外键`a_id` 进行增删改

    - `INSERT` b表的值，如果在a表没有的相对应的值会报错。
        ```sql
        -- 因为a表没有id为2的数据，所以报错
        INSERT INTO b (id,a_id) VALUE
        (20,2);
        ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails (`china`.`b`, CONSTRAINT `b_ibfk_1` FOREIGN KEY (`a_id`) REFERENCES `a` (`id`))
        ```

    - `UPDATE` b 表的 外键a_id 值
        ```sql
        UPDATE b
        SET a_id = 2
        WHERE id = 10;
        (1452, 'Cannot add or update a child row: a foreign key constraint fails (`test`.`b`, CONSTRAINT `fk_a` FOREIGN KEY (`a_id`) REFERENCES `a` (`id`))')
        ```

- a 表:

    - `UPDATE` a 表的值，会因为没有权限失败

        ```sql
        UPDATE a SET id = 2
        WHERE id = 1;
        ERROR 1451 (23000): Cannot delete or update a parent row: a foreign key constraint fails (`china`.`b`, CONSTRAINT `fk_a` FOREIGN KEY (`a_id`) REFERENCES `a` (`id`))
        ```

    - 解决方法1：`DELETE` b表对应的值后，可以对a表修改成功

        ```sql
        -- DELETE b表的值
        DELETE FROM b
        WHERE id =10;

        -- 再次更新a表的值，成功。
        UPDATE a SET id = 2
        WHERE id = 1;
        ```

    - 解决方法2：设置`CASCADE`权限

        ```sql
        -- 删除外键
        ALTER TABLE b DROP FOREIGN KEY fk_a;

        -- 重新添加外键，设置CASCADE权限
        ALTER TABLE b
            ADD CONSTRAINT a_id
            FOREIGN KEY (a_id)
            REFERENCES a (id)
            ON UPDATE CASCADE
            ON DELETE CASCADE;

        -- 重新UPDATE a 表的值。成功修改
        UPDATE a
        SET id = 2
        WHERE id = 1;

        -- 查看结果。不管是a表、b表都是一样的值
        SELECT * FROM a;
        SELECT * FROM b;
        ```

        ![image](./Pictures/mysql/foreign2.avif)

    - 删除 a 表 刚才的数据:

        ```sql
        DELETE FROM a
        WHERE id = 2;

        -- 查看结果。a表的数据删除后，b表对应的数据也会删除:
        select * from b;
        +----+------+
        | id | a_id |
        +----+------+
        +----+------+
        ```

##### [爱可生开源社区：第05期：外键到底能不能用？](https://mp.weixin.qq.com/s?__biz=MzU2NzgwMTg0MA==&mid=2247488091&idx=1&sn=0fa197c6ff30bbcc66c56f1363c4c2ce&chksm=fc96f0c4cbe179d2913e4091b402708b2b1167e431919f31b5a1da89fa0971d07db65ec90762&cur_album_id=1338281900976472064&scene=189#wechat_redirect)

### Insert（插入）

**语法**

> ```sql
> INSERT INTO 表名称 (列1, 列2,...) VALUES (值1, 值2,....)
> ```

```sql
-- 插入一条数据
insert into new (name,date) values
('tz','2020-10-24');

-- 插入多条数据
insert into new (name,date) values
('tz1','2020-10-24'),
('tz2','2020-10-24'),
('tz3','2020-10-24');

-- 查看
select * from new;

-- 可以看到 id 字段自动增量
select * from new;
+-----+------+------------+
| id  | name | date       |
+-----+------+------------+
| 100 | tz   | 2020-10-24 |
| 102 | tz1  | 2020-10-24 |
| 103 | tz2  | 2020-10-24 |
| 104 | tz3  | 2020-10-24 |
+-----+------+------------+
```

#### INSERT... SELECT... 插入其他表的数据

- 要避免使用此语句。如果select的表是innodb类型的，不论insert的表是什么类型的表，都会对select的表的纪录进行锁定。

- 把 cnarea_2019 表里的字段,导入进 newcn 表.
  **语法:**
  > ```sql
  > INSERT INTO 新表名称 (列1, 列2,...) SELECT (列1, 列2,....) FROM 旧表名称;
  > ```

```sql
-- 创建名为 newcn 数据库
create table newcn (
    id int(4) unique auto_increment,
    name varchar(50)
);

-- 导入 1 条数据
insert into newcn (id,name)
select id,name from cnarea_2019
where id=1;

-- 可多次导入
insert into newcn (id,name)
select id,name from cnarea_2019
where id >= 2 and id <=10 ;

-- 查看结果
select * from newcn;
+------+--------------------------+
| id   | name                     |
+------+--------------------------+
| 1  | 北京市           |
| 2  | 直辖区           |
| 3  | 东城区           |
| 4  | 东华门街道       |
| 5  | 多福巷社区居委会 |
| 6  | 银闸社区居委会   |
| 7  | 东厂社区居委会   |
| 8  | 智德社区居委会   |
| 9  | 南池子社区居委会 |
| 10 | 黄图岗社区居委会 |
+------+--------------------------+

-- 插入包含 广州 的数据
insert into newcn (id,name)
select id,name from cnarea_2019
where name regexp '广州.*';
```

#### [INSERT ... ON DUPLICATE KEY UPDATE ...](https://dev.mysql.com/doc/refman/8.0/en/insert-on-duplicate.html)

```sql
CREATE TABLE duplicate_test (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  a INT UNIQUE, -- 唯一性
  PRIMARY KEY (id)
);

INSERT INTO duplicate_test(a) VALUES
(1),
(2);

+----+---+
| id | a |
+----+---+
| 1  | 1 |
| 2  | 2 |
+----+---+
```

```sql
-- 由于a字段设置了唯一索引, 因此会报错
INSERT INTO duplicate_test(a) VALUES
(1);

-- ON DUPLICATE KEY UPDATE, 如果字段是UNIQUE, 并且已经值已经存在, 则修改
INSERT INTO duplicate_test (a) VALUES (1)
  ON DUPLICATE KEY UPDATE a=a+2;

+----+---+
| id | a |
+----+---+
| 2  | 2 |
| 1  | 3 |
+----+---+

-- 如果修改后的值也已经存在, 则会报错
INSERT INTO duplicate_test (a) VALUES (1)
  ON DUPLICATE KEY UPDATE a=a+1;
```

### REPLACE（如果数据已经存在，则会先删除，再插入新的数据）

- 如果插入的数据不存在，则REPLACE和INSERT相同。

```sql
CREATE TABLE replace_test (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  data VARCHAR(64) DEFAULT NULL,
  ts TIMESTAMP,
  PRIMARY KEY (id)
);

-- 初始插入.使用REPLACE也一样
INSERT INTO replace_test
VALUES (1, 'Old', '2014-08-20 18:47:00');

-- 此语句会报错
INSERT INTO replace_test
VALUES (1, 'New', '2014-08-20 18:47:42');

-- 使用REPLACE成功修改
REPLACE INTO replace_test
VALUES (1, 'New', '2014-08-20 18:47:42');
```

### UPDATE（修改）

- update 语句的简化执行流程如下：
    - server 层要求 InnoDB 从表中读取一条记录。
    - InnoDB 返回记录之后，server 层判断这条记录是否匹配 where 条件。
    - 如果匹配，用 update 语句 set 子句中指定的各字段值，替换 InnoDB 返回记录的对应字段值。
    - 替换字段值得到完整记录之后，server 层触发 InnoDB 更新记录。

**语法:**

> ```sql
> UPDATE 表名称 SET 列名称 = 新值 WHERE 列名称 = 某值
> ```

```sql
-- 修改 id=1 的 city_code 字段为111
update cnarea_2019
set city_code=111
where id=1;

-- 对每个 id-3 填回刚才删除的 id1,2,3
update cnarea_2019
set id=(id-3)
where id>2;

-- 对小于level平均值进行加1
update cnarea_2019
set level=(level+1)
where level<=(select avg(level) from cnarea_2019);

-- 把 广州 修改为 北京,replace() 修改列的某一部分值
update cnarea_2019
set name=replace(name,'广州','北京')
where name regexp '广州.*';

-- 把以 北京 和 深圳 开头的数据,修改为 广州
update cnarea_2019
set name=replace(name,'深圳','广州'),
name=replace(name,'北京','广州')
where name regexp '^深圳' or name regexp '^北京';
```

#### case语句，在UPDATE多条语句时，可以按顺序执行，避免出错

```sql
-- 工资只有1000的人, 升2倍
UPDATE people
set salary = salary * 2
WHERE salary = 1000

-- 工资只有2000的人, 升1.5倍
UPDATE people
set salary = salary * 1.5
WHERE salary = 2000

-- 工资大于2000的人, 升1.2倍
UPDATE people
set salary = salary * 1.2
WHERE salary > 2000

-- 注意:以上顺序不能倒转
-- 使用case语句避免顺序倒转
UPDATE people
SET salary = case
    when salary = 1000 then salary * 2
    when salary = 2000 then salary * 1.5
    else salary * 1.2
    end
```

### Delete and TRUNCATE and Drop (删除)

- TRUNCATE：清空表中的所有数据但保留表结构（与DELETE不同，不记录每条记录的删除操作，效率更高且不触发相关删除触发器）。

| 操作     | DROP                                             | TRUNCATE     | DELETE                        |
|----------|--------------------------------------------------|--------------|-------------------------------|
| 删除内容 | 删除整张表数据，表结构以及表的索引、约束和触发器 | 删除全部数据 | 删除部分数据（可带where条件） |
| 语句类型 | DDL                                              | DDL          | DML                           |
| 效率     | 最高                                             | 较高         | 较低                          |
| 回滚     | 无法回滚                                         | 无法回滚     | 可以回滚                      |
| 自增值   | -                                                | 重置         | 不重置                        |

- delete 语句的简化执行流程如下：

    - server 层要求 InnoDB 从表中读取一条记录。
    - InnoDB 返回记录之后，server 层判断这条记录是否匹配 where 条件。
    - 如果匹配，server 层触发 InnoDB 删除记录。

**语法:**

> ```sql
> # 删除特定的值
> DELETE FROM 表名称 WHERE 列名称 = 值;
> ```

```sql
-- 删除 id1
delete from cnarea_2019
where id=1;
-- 删除 id2和4
delete from cnarea_2019
where id in (2,4);

-- 查看结果
select level, count(*) as totals from cnarea_2019
group by level;

-- 删除表的所有数据，但不会删除表本身
delete from cnarea_2019;

-- 删除表的所有数据，但不会删除表本身(无法回退)
truncate table cnarea_2019;

-- 这两者的区别简单理解就是 drop 语句删除表之后,可以通过日志进行回复,而 truncate 删除表之后永远恢复不了,所以,一般不使用 truncate 进行表的删除.
```

**语法:**

> ```sql
> # 删除数据库,表,函数,存储过程
> DROP 类型 名称;
> # 或者 先判断是否存在后,再删除
> DROP 类型 if exists 名称;
> ```

| 类型      |
| --------- |
| TABLE     |
| DATABASE  |
| FUNCTION  |
| PROCEDURE |

```sql
-- 删除 cnarea_2019 表
drop table cnarea_2019;

-- 先判断 cnarea_2019 表是否存在,如存在则删除
drop table if exists cnarea_2019;

-- 删除 china 数据库
drop database china;

-- 先判断 chinaa 数据库是否存在,如存在则删除
drop table if exists china;

-- 删除后,可以这样恢复数据库
create database china;
mysql -uroot -pYouPassward china < china_area_mysql.sql
```

#### 删除重复的数据

```sql
-- 创建表
create table clone (
    `id` int (8),
    `name` varchar(50),
    `date` DATE
);

-- 插入数据
insert into clone (id,name,date) values
(1,'tz','2020-10-24'),
(2,'tz','2020-10-24'),
(2,'tz','2020-10-24'),
(2,'tz1','2020-10-24'),
(2,'tz1','2020-10-24');

-- 通过 ALTER IGNORE 加入 主健(PRIMARY KEY) 删除重复的数据
ALTER IGNORE TABLE clone
ADD PRIMARY KEY (id, name);
-- 或者 ALTER IGNORE 加入 唯一性索引(UNIQUE)
ALTER IGNORE TABLE clone
ADD UNIQUE KEY (id, name);

select * from clone;
+----+------+------------+
| id | name | date       |
+----+------+------------+
|  1 | tz   | 2020-10-24 |
|  2 | tz   | 2020-10-24 |
|  2 | tz1  | 2020-10-24 |
+----+------+------------+

-- 成功后可以删除 (这是主健)
alter table ca drop primary key;

-- 成功后可以删除 (这是unique)
alter table clone drop index id;
alter table clone drop index name;
```

### 表设计

#### 范式设计

- [爱可生开源社区：第33期：MySQL 表标准化设计](https://mp.weixin.qq.com/s/vPMUEBcCflK7St-HXbmAAA)

#### 反范式设计

- [爱可生开源社区：第34期：MySQL 表冗余设计](https://mp.weixin.qq.com/s/NBYAYu5Tg7_OtqGqueya7A)

#### 大表处理

- 水平拆分和垂直拆分有些不一样
    - 垂直拆分最小单元是字段：与业务有很强的关联性，具体业务对应具体的拆分数据
    - 水平拆分最小单元是数据行：与具体业务关系不大，业务关联可以是拆分后的单张表数据，也可以是拆分前的全局数据。
        - 简单来说，水平拆分对应用透明，应用逻辑在数据拆分后不需要大动。

##### 垂直拆分

- [爱可生开源社区：第35期：MySQL 数据垂直拆分](https://mp.weixin.qq.com/s/s4KhCwK_7GL7CUL603LvjQ)

##### 水平拆分

- [爱可生开源社区：第36期：MySQL 原生水平拆表](https://mp.weixin.qq.com/s/UFIylhiLvRbniTUpD4qT7Q)

##### 分区表

- 问题：
    - 1.单张表数据量太大，每天会产生 10W 条记录，一年就是 3650W 条记录，
    - 2.对这张表的查询 95% 都是在某一天或者几天内，过滤区间最大不超过一个月。比如在2019年3月1日、2019年4 月20 日或者是2019年5月1日和2019年5月5日这个时间段内。偶尔会涉及到跨月、跨年查询，但是频率很低。
    - 3.记录保留10年。也就是单表3.6亿条记录，单表太大，不便于管理，后期如果单表损坏，修复也难。
    - 4.单表查询性能很差，对历史数据删除性能也很差。

- 解决方法：分区表
    - 1.查询过滤的数据范围相对比较集中，不是那么分散；要同时考虑过期数据清理性能问题。
    - 2.考虑把表拆分为10张新表，一张是当前表，剩余9张是历史归档表；当前表存放最近两年的数据，每到年底迁移老旧数据到历史表进行归档，并且对过期历史数据进行清理。
    - 3.考虑对部分过滤场景使用 MySQL 分区表，非常适合 95% 的查询；可以使用分区置换功能把数据移到历史表。
    - 4.分区表带来几个好处：一是查询性能提升；二是管理方便，过期数据直接快速清理；三是对应用透明，暂时不需要应用改代码。

```sql
CREATE TABLE sales (
    sale_id INT,
    sale_date DATE,
    amount DECIMAL(10, 2)
) PARTITION BY RANGE (YEAR(sale_date)) (
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN MAXVALUE
);

INSERT INTO sales (sale_id, sale_date, amount) VALUES
(1, '2022-01-01', 100.50),
(2, '2022-02-15', 200.75),
(3, '2022-03-20', 150.00),
(4, '2023-04-10', 300.20),
(5, '2023-05-05', 250.80),
(6, '2023-06-12', 180.30),
(7, '2023-07-08', 220.40),
(8, '2024-08-23', 270.60),
(9, '2024-09-17', 320.90),
(10, '2024-10-05', 280.75);
```

###### [爱可生开源社区：第37期：适当的使用 MySQL 原生表分区](https://mp.weixin.qq.com/s/W0qTSI9CwejFKHnCByap0g)

###### [爱可生开源社区：第38期：MySQL 时间类分区具体实现](https://mp.weixin.qq.com/s/AD1F_W50dkEbkmonyt0OWw)

###### [爱可生开源社区：第39期：MySQL 时间类分区写 SQL 注意事项](https://mp.weixin.qq.com/s/2uCHl_Hs95-IlNApMZ-2XA)

###### [爱可生开源社区：第40期：MySQL 分区表案例分享](https://mp.weixin.qq.com/s/_Wn_SvPurNdEE8xNuANEtA)

###### [爱可生开源社区：第41期：MySQL 哈希分区表](https://mp.weixin.qq.com/s/hLSlXZjx1e02cSvx0z2tDA)

###### [爱可生开源社区：第42期：MySQL 是否有必要多列分区](https://mp.weixin.qq.com/s/tYVHXgLAhQqofI8D-LxOHQ)

## DDL (Data Definition Language) 数据定义语言

- `CREATE`：创建新的表、视图、索引等。

- `ALTER`：修改数据库表结构或其属性，比如增加、修改或删除列。

- `DROP`：删除表、视图、索引等数据库对象。

- `TRUNCATE`：清空表中的所有数据但保留表结构（与DELETE不同，不记录每条记录的删除操作，效率更高且不触发相关删除触发器）。

- DDL用于创建、修改或删除数据库的结构对象，比如表、视图、索引、序列、存储过程等。

### VIEW (视图)

- [深入解析 MySQL 视图 VIEW](https://www.cnblogs.com/geaozhang/p/6792369.html)

- 视图(view)是一种虚拟存在的表,是一个逻辑表,本身并不包含数据.作为一个 select 语句保存在数据字典中的.

- 性能:从数据库视图查询数据可能会很慢,特别是如果视图是基于其他视图创建的.

- 基表:用来创建视图的表叫做基表

    - 修改视图数据, 基表也会修改(视图没有指定的基表列字段为`null`)

    - 修改基表数据, 视图也会修改

**语法:**

> ```sql
> CREATE VIEW 视图名 (字段名) AS SELECT '值1' UNION SELECT '值2'...;
> # 基表视图
> CREATE VIEW 视图名 AS SELECT 字段名 FROM 表名...;
> ```

```sql
# 查看当前数据下的视图
show full tables
where table_type = 'view';

# 创建视图
create view v (day)
as select '1' union select '2';

# 查看视图
select * from v;
+-----+
| day |
+-----+
| 1   |
| 2   |
+-----+
# 删除视图
drop view v;

# 以 clone表 为基表,创建视图名为 v
create view v as
select * from clone;

# 查看视图信息
show create view v\G;

# 嵌套 v视图 名为 vv,并且 id <= 2
create view vv as select * from v
where id <= 2;

# 此时如果把 id 改为 3.注意这里 v 视图 和 clone 表的数据也会被更改
update vv
set id = 3
where id = 1;

# 因为 vv视图有where id <= 2的限制, 所以不满足条件的值不显示
select * from vv;
+----+------+------------+
| id | name | date |
+----+------+------------+
|  2 | tz   | 2020-10-24 |
|  2 | tz1  | 2020-10-24 |
+----+------+------------+

# 对vv视图修改的值,在v视图的也被修改
select * from v;
+----+------+------------+
| id | name | date       |
+----+------+------------+
|  3 | tz   | 2020-10-24 |
|  2 | tz   | 2020-10-24 |
|  2 | tz1  | 2020-10-24 |
+----+------+------------+

# 和刚才的 vv视图 一样 这次 vvv视图 加入with check option;
create view vvv as select * from v
where id <= 2
with check option;

# 此时对不满足条件的值,进行修改会报错
update vvv set id = 3 where id = 2;
ERROR 1369 (44000): CHECK OPTION failed `china`.`vvv`
```

可以看到 视图信息 多数为空 (**NULL**)

```sql
show table status like '名称'\G;
```

![image](./Pictures/mysql/view.avif)
![image](./Pictures/mysql/view1.avif)

### Function and Stored Procedure (函数 和 存储过程)

- [Difference between stored procedure and function in MySQL](https://medium.com/@singh.umesh30/difference-between-stored-procedure-and-function-in-mysql-52f845d70b05)

- **区别:**

    | Procedure                | Function                  |
    | ------------------------ | ------------------------- |
    | 可以执行函数             | 不能执行存储过程          |
    | 不能在 select 语句下执行 | 只能在 select 语句下执行  |
    | 支持 Transactions(事务)  | 不支持 Transactions(事务) |
    | 可以不有返回值           | 必须要有返回值            |
    | 能返回多个值             | 只能返回一个值            |

#### Stored Procedure (存储过程)

**语法:**

> ```sql
> delimiter #
> create procedure 过程名([IN 参数名 数据类型,OUT 参数名 数据类型... ])
>
> begin
>
> sql语句;
>
> end;
> delimiter ;
> ```

- delimiter 是分隔符 默认是: `;`

- 注意：procedure 是和数据库相关链接的,如果数据库被删除,procedure 也会被删除

- 基本使用
    ```sql
    -- 如果只有只有一条指令可以省略begin和end
    create procedure my_pro1()
    ```

    ```sql
    DELIMITER #

    CREATE PROCEDURE hello (IN s VARCHAR(50))
    BEGIN
       SELECT CONCAT('Hello, ', s, '!');
    END #

    DELIMITER ;

    # 执行
    call hello('World');
    +---------------------------+
    | CONCAT('Hello, ', s, '!') |
    +---------------------------+
    | Hello, World!             |
    +---------------------------+

    # 查看所有存储过程
    show procedure status;

    # 查看 hello 存储过程
    show create procedure hello\G;
    ```

- 创建等下测试用的表:

    ```sql
    drop table if exists foo;

    create table foo (
        id int unique auto_increment,
        val int not null default 0
    );

    # 插入一些数据
    insert into foo (val) values (1);
    insert into foo (val) values (2);
    insert into foo (val) values (3);
    insert into foo (val) values (4);
    insert into foo (val) values (5);

    # 查看结果
    select * from foo;
    ```

    ![image](./Pictures/mysql/procedure.avif)

- 创建存储过程：通过while循环前5行，将foo表的val字段的值，更新为传递的参数

    ```sql
    # 检测过程是否存在,如存在则删除
    drop procedure if exists zero;

    # 过程体要包含在delimiter里
    delimiter #
    -- 创建 zero 过程
    -- INT表示：传递的变量为int类型的v
    -- OUT表示：返回的变量为int类型的n
    CREATE PROCEDURE zero(IN v INT,OUT n INT)
    BEGIN

    -- 变量i 代表 id 字段的值
    DECLARE i int DEFAULT 1;
    -- 变量s 代表循环次数
    DECLARE s int DEFAULT 6;

        WHILE i < s DO
        -- 把 val 字段的值设置为 参数v
        UPDATE foo SET val = v WHERE ID = i;
        SET i = i + 1;
        END WHILE;
        -- 设置返回变量 n 的值为 i
        SET N = I;

    END #
    delimiter ;

    # 设置 传递参数v 为0
    set @v = 0;
    # 执行 zero 过程
    call zero(@v,@n);
    # 查看 返回参数n 的值
    select @n;

    # 查看过程结果
    select * from foo;
    ```

    ![image](./Pictures/mysql/procedure1.avif)

- 创建存储过程：通过while循环1000次，将foo表的val字段插入随机数:

    ```sql
    drop procedure if exists foo_rand;

    delimiter #
    CREATE PROCEDURE foo_rand()
    BEGIN

    -- 通过设置变量，循环次数1000次
    DECLARE v_max int unsigned DEFAULT 1000;
    DECLARE v_counter int unsigned DEFAULT 0;

    -- 删除foo表的数据
      truncate table foo;
      start transaction;

    -- 循环
      while v_counter < v_max do
      -- 插入随机数据
        insert into foo (val) values ( floor(rand() * 65535) );
        set v_counter=v_counter+1;
      end while;
      commit;
    end #

    delimiter ;

    # 执行 foo_rand存储过程
    call foo_rand();

    # 查看结果
    select * from foo order by id;
    ```

    ![image](./Pictures/mysql/procedure2.avif)

##### trigger（触发器）

- [Coding Big Tree：MySQL数据库（32）：触发器 trigger](https://mp.weixin.qq.com/s/dGh45w_mCBXHIMFSXbCPZg)

- 触发器是一种特殊类型的存储过程，触发器通过事件进行触发而被执行

- 触发器 trigger 和js事件类似

- 作用：

    - 1.写入数据表前，强制检验或转换数据（保证数据安全）
    - 2.触发器发生错误时，异动的结果会被撤销（事务安全）
    - 3.部分数据库管理系统可以针对数据定义语言DDL使用触发器，称为DDL触发器
    - 4.可以依照特定的情况，替换异动的指令 instead of（mysql不支持）

- 优点

    - 1.触发器可通过数据库中的相关表实现级联更改（如果一张表的数据改变，可以利用触发器实现对其他表的操作，用户不知道）
    - 2.保证数据安全，进行安全校验

- 缺点

    - 1.对触发器过分依赖，势必影响数据库的结构，同时增加了维护的复杂度
    - 2.造成数据在程序层面不可控
    - 3.触发器越多会导致 memory/sql/sp_head::main_mem_root 占用的内存越大，存储过程所使用的内存也会越大。
        - MySQL 中不推荐使用大量的触发器以及复杂的存储过程。

- 创建触发器

    ```sql
    -- ON 表 FOR EACH ROW 触发器绑定表中所有行，没一行发生指定改变的时候，就会触发触发器
    CREATE TRIGGER 触发器名字 触发时机 触发事件 ON 表 FOR EACH ROW
    BEGIN

    END
    ```

    - 触发时机
        - `BEFORE`: 数据发生改变前的状态
        - `AFTER`: 数据已经发生改变后的状态


    - 触发事件

        - mysql中触发器针对的目标是数据发生改变，对应的操作只有写操作（增删改）

        - `INERT`：插入操作
        - `UPDATE`：更新操作
        - `DELETE`：删除操作

    - 注意事项

        - 一张表中，每一个触发时机绑定的触发事件对应的触发器类型只能有一个

        - 一张表表中只能有一个对应的after insert 触发器

        ```sql
        -- 最多只能有6个触发器
        BEFORE INSERT
        AFTER INSERT

        BEFORE UPDATE
        AFTER UPDATE

        BEFORE DELETE
        AFTER DELETE
        ```

###### 实例：下单减库存

- 有两张表，一张是商品表，一张是订单表（保留商品ID）每次订单生成，商品表中对应的库存就应该发生变化

- 创建两张表

    ```sql
    CREATE TABLE my_item(
        id INT PRIMARY KEY AUTO_INCREMENT,
        name VARCHAR(20) NOT NULL,
        count INT NOT NULL DEFAULT 0
    ) COMMENT '商品表';

    CREATE TABLE my_order(
        id INT PRIMARY KEY AUTO_INCREMENT,
        item_id INT NOT NULL,
        count INT NOT NULL DEFAULT 1
    ) COMMENT '订单表';

    -- 插入测试数据
    INSERT my_item (name, count) VALUES
        ('手机', 100),('电脑', 100), ('包包', 100);

    -- 查看
    SELECT * FROM my_item;
    +----+------+-------+
    | id | name | count |
    +----+------+-------+
    | 1  | 手机 | 100   |
    | 2  | 电脑 | 100   |
    | 3  | 包包 | 100   |
    +----+------+-------+

    SELECT * FROM my_order;
    +----+---------+-------+
    | id | item_id | count |
    +----+---------+-------+
    +----+---------+-------+
    ```

- 创建触发器

    - 如果订单表发生数据插入，对应的商品就应该减少库存

    ```sql
    DELIMITER $$

    CREATE TRIGGER after_insert_order_trigger AFTER INSERT ON my_order FOR EACH ROW
    BEGIN
        -- 更新商品库存。通过new关键字获取新数据的id 和数量
        UPDATE my_item SET count = count - new.count WHERE id = new.item_id;
    END
    $$
    DELIMITER ;
    ```

    ```sql
    -- 查看所有触发器
    show triggers\G

    -- 查看触发器创建语句
    show create trigger after_insert_order_trigger;
    ```

- 触发触发器

    ```sql
    -- 测试1
    insert into my_order (item_id, count) values(1, 1);

    select * from my_order;
    +----+---------+-------+
    | id | item_id | count |
    +----+---------+-------+
    |  1 |       1 |     1 |
    +----+---------+-------+

    -- 手机库存成功减1
    select * from my_item;
    +----+------+-------+
    | id | name | count |
    +----+------+-------+
    | 1  | 手机 | 99    |
    | 2  | 电脑 | 100   |
    | 3  | 包包 | 100   |
    +----+------+-------+

    -- 测试2
    insert into my_order (item_id, count) values(2, 3);

    select * from my_order;
    +----+---------+-------+
    | id | item_id | count |
    +----+---------+-------+
    | 1  | 1       | 1     |
    | 2  | 2       | 3     |
    +----+---------+-------+

    select * from my_item;
    +----+------+-------+
    | id | name | count |
    +----+------+-------+
    | 1  | 手机 | 99    |
    | 2  | 电脑 | 97    |
    | 3  | 包包 | 100   |
    +----+------+-------+
    ```

- 如果库存数量没有商品订单多怎么办？

    ```sql
    -- 删除触发器
    DROP TRIGGER after_insert_order_trigger;

    -- 新增判断库存触发器
    DELIMITER $$

    CREATE TRIGGER after_insert_order_trigger AFTER INSERT ON my_order FOR EACH ROW
    BEGIN
        -- 查询库存
        select count from my_item where id = new.item_id into @count;

        -- 判断
        if new.count > @count then
            -- 中断操作，暴力抛出异常
            insert into xxx values ('xxx');

        end if;

        -- 更新商品库存。通过new关键字获取新数据的id 和数量
        UPDATE my_item SET count = count - new.count WHERE id = new.item_id;
    END
    $$
    DELIMITER ;

    -- 测试
    insert into my_order (item_id, count) values(3, 101);
    (1146, "Table 'test.xxx' doesn't exist")

    select * from my_order
    +----+---------+-------+
    | id | item_id | count |
    +----+---------+-------+
    | 1  | 1       | 1     |
    | 2  | 2       | 3     |
    +----+---------+-------+

    select * from my_item
    +----+------+-------+
    | id | name | count |
    +----+------+-------+
    | 1  | 手机 | 99    |
    | 2  | 电脑 | 97    |
    | 3  | 包包 | 100   |
    +----+------+-------+
    ```


#### Function（函数）

- [Coding Big Tree：MySQL数据库（30）：内置函数和自定义函数 function](https://mp.weixin.qq.com/s?__biz=MjM5MDIyNjg2OA==&mid=2447911439&idx=1&sn=9741db95f4c0ead000de37187e419455&chksm=b2548ad4852303c235075996d1267e23dc2d2f556cb56e0a816f9abfcccd85b5af3eb4a02d7d&scene=178&cur_album_id=2371394211721216001#rd)

**语法:**

> ```sql
> select 函数名(参数列表);
> ```

- 函数分为两类：系统函数和自定义函数

##### 内置函数

- 字符串函数

    | 函数名                             | 说明                                                     |
    |------------------------------------|----------------------------------------------------------|
    | char_length                        | 判断字符串的字符数                                       |
    | length                             | 判断字符串的字节数，与字符集有关                         |
    | concat                             | 连接字符串                                               |
    | insrt                              | 检查字符是否在目标字符串中，存在返回其位置，不存在返回 0 |
    | lcase                              | 全部小写                                                 |
    | ltrim                              | 消除左边的空格                                           |
    | left(str, length)                  | 左侧开始截取字符串，直到指定位置                         |
    | right(str, length)                 | 右侧开始截取字符串，直到指定位置                         |
    | mid                                | 从中间指定位置开始截取，如果不指定截取长度，直接到最后   |
    | substring(str, index, [length])    | 从指定位置开始，指定截取长度                             |
    | substring_index(str, delim, count) | 按照关键字截取                                           |

    ```sql
    select char_length('你好中国'); // 4
    select length('你好中国'); // 12
    select length('hello'); // 5
    select char_length('hello'); // 5

    select concat('你好', '中国'); // 你好中国

    -- 下标从 1 开始
    select instr('你好中国', '中国'); // 3
    select instr('你好中国', '我'); // 0

    select lcase('aBcd'); // abcd
    select left('aBcd', 2); // aB
    select right('abcdef', 2); // ef
    select substring('abcdef', 2, 3); // bcd
    select substring('abcdef', -2, 3); // ef

    select ltrim(' abc d '); // abc d
    select mid('你好中国', 3); // 中国

    select substring_index('www.baidu.com', '.', 2); // www.baidu
    select substring_index('www.baidu.com', '.', -2); // baidu.com
    ```

- 时间函数

    | 函数名                                | 说明                                                     |
    |---------------------------------------|----------------------------------------------------------|
    | now()                                 | 返回当前时间，日期 时间                                  |
    | curdate()                             | 当前日期                                                 |
    | curtime()                             | 当前时间                                                 |
    | datediff()                            | 判断两个日期之间的天数之差，日期使用字符串格式（用引号） |
    | date_add(日期,interval 时间数字 type) | 时间增加（type:                                          |
    | unix_timestamp()                      | 获取时间戳                                               |
    | from_unixtime()                       | 将指定时间戳转换成对应的日期时间格式                     |

    ```sql
    select now(); // 2022-04-10 22:05:38
    select curdate(); // 2022-04-10
    select curtime(); // 22:05:51

    select datediff('2022-01-09', '2022-01-01'); // 8
    select date_add('2000-10-01', interval 10 day); // 2000-10-11
    select unix_timestamp(); // 1649599799
    select from_unixtime(1649599799); // 2022-04-10 22:09:59
    ```

- 数学函数

    | 函数名  | 说明        |
    |---------|-------------|
    | abs     | 绝对值      |
    | ceiling | 向上取整    |
    | floor   | 向下取整    |
    | pow     | 指数        |
    | rand    | 随机数(0-1) |
    | round   | 四舍五入    |

    ```sql
    select abs(-1); // 1
    select ceiling(1.1); // 2
    select floor(1.9); // 1
    select pow(2, 4); // 16
    select rand(); // 0.2616088308967732
    select round(1.5); // 2
    ```

- 其他函数

    | 函数名     | 说明                        |
    |------------|-----------------------------|
    | md5()      | MD5                         |
    | version()  | 版本号                      |
    | database() | 显示当前所在数据库          |
    | uuid()     | 生成一个唯一标识符,全局唯一 |

    ```sql
    select md5('abc'); // 900150983cd24fb0d6963f7d28e17f72
    select version(); // 8.0.16
    select database(); // mydatabase
    select uuid(); // c44a06a2-b8d8-11ec-a53c-504259f9d746
    ```

##### 自定义函数

**语法:**

如果只有一条语句，可以省略begin 和 end

> ```sql
> delimiter $$;
>
> create function 函数名(形参) returns 返回值类型
> begin
>     -- 函数体
>     return 返回值数据;
> end
>
> 语句结束符
>
> -- 将语句结束符修改回来
> delimiter ;

- 注意事项
    - 1.自定义函数属于用户级别，只有当前客户端对应的数据库中可以使用
    - 2.可以在不同数据库下看到函数，但是不可以调用
    - 3.自定义函数通常是为了将多行代码集合到一起解决一个重复性的问题

- 基本使用

    ```sql
    -- 自定义hello函数
    CREATE FUNCTION hello (s VARCHAR(50))
       RETURNS VARCHAR(50) DETERMINISTIC
       RETURN CONCAT('Hello, ',s,'!');

    -- 执行
    select hello('world');
    +----------------+
    | hello('world') |
    +----------------+
    | Hello, world!  |
    +----------------+
    select hello(name) from ca limit 1;

    -- 查看所有自定义函数
    show function status;

    -- 查看 hello 函数
    show create function hello\G;

    -- 删除函数
    drop function hello;
    ```

    ```sql
    -- 自定义foo函数
    DELIMITER $$

    CREATE FUNCTION foo() RETURNS INT
    DETERMINISTIC
    BEGIN
        RETURN 10;
    END$$

    DELIMITER ;

    -- 测试
    select foo()
    +-------+
    | foo() |
    +-------+
    | 10    |
    ```

- 创建一个自动求和的函数

    ```sql
    DELIMITER $$

    CREATE FUNCTION my_sum(end_value INT) RETURNS INT
    DETERMINISTIC
    BEGIN
        -- 声明局部变量
        DECLARE res INT DEFAULT 0;
        DECLARE i INT DEFAULT 0;

        -- 循环处理
        mywhile: WHILE i <= end_value DO
            -- 修改变量，累加
            SET res = res + i;

            -- mysql中没有++
            SET i = i + 1;

        END WHILE;

        -- 返回值
        RETURN res;
    END$$

    DELIMITER ;
    ```

    ```sql
    select my_sum(10);
    +------------+
    | my_sum(10) |
    +------------+
    | 55         |
    +------------+
    ```

### ALTER（修改表的列字段、存储引擎等）

**语法:**

> ```sql
> ALTER TABLE table_name
> 动作 column_name 内容
> ```

| 动作   | 内容             |
| ------ | ---------------- |
| ADD    | 添加列           |
| DROP   | 删除列           |
| RENAME | 修改表名         |
| CHANGE | 修改列名         |
| MODIFY | 修改列的数据类型 |
| ENGINE | 修改存储引擎     |

```sql
-- 重命名表
ALTER TABLE cnarea_2019 RENAME ca;

-- 将列 name 改名为 mingzi ,类型改为 char(50)
ALTER TABLE ca change name mingzi char(50);

-- 删除 id 列
ALTER TABLE ca DROP id;

-- 添加 id 列
ALTER TABLE ca ADD id INT FIRST;

-- 重命名 id 列为 number(bigint类型)
ALTER TABLE ca CHANGE id number BIGINT;

-- 修改 city_code 列,为 char(50) 类型
ALTER TABLE ca MODIFY city_code char(50);
-- 或者
ALTER TABLE ca CHANGE city_code city_code char(50);

-- 修改 ca 表 id 列默认值1000
ALTER TABLE ca MODIFY id BIGINT NOT NULL DEFAULT 1000;
-- 或者
ALTER TABLE ca ALTER id SET DEFAULT 1000;

-- 添加主键,确保该主键默认不为空(NOT NULL)
ALTER TABLE ca MODIFY id INT NOT NULL;
ALTER TABLE ca ADD PRIMARY KEY (id);

-- 删除主键
ALTER TABLE ca DROP PRIMARY KEY;

-- 删除唯一性索引(unique)的 id 字段
ALTER TABLE ca DROP index id;

-- 修改 ca 表的存储引擎
ALTER TABLE ca ENGINE = MYISAM;
```

#### ALTER优化

- mysql大部分修改表结构的操作是:新建一个空表, 将旧表数据插入新表, 再删除旧表

- 所有`MODIFY COLUMN` 都会导致表的重建

    ```sql
    ALTER TABLE table_name
    MODIFY COLUMN col INT DEFAULT 5
    ```

    - 使用`ALTER COLUMN`代替, 此命令直接修改frm文件, 而不是重建表

    ```sql
    ALTER TABLE table_name
    ALTER COLUMN col SET DEFAULT 5
    ```

<span id="alter_frm"></span>
- 手动修改frm文件, 避免重建表

    - **注意:此方法不受官方支持, 要自己承担风险, 执行前请先备份好数据**

    - 此方法适用于:

        - 移除(不是添加) `AUTO_INCREMENT`

        - 增加, 移除, 修改EMUM, SET类型

    ![image](./Pictures/mysql/alter_frm.avif)
    ```sql
    -- 创建新表
    CREATE TABLE emum_test_new LIKE emum_test;

    -- 修改表结构
    ALTER TABLE emum_test_new
    MODIFY COLUMN emum_col ENUM('xiaomi','huawei','meizu','oppo', 'vivo') DEFAULT 'meizu';

    -- 关闭所有正在使用的表
    flush tables with read lock;
    ```

    ```sh
    # 进入表所在的数据库目录
    cd /var/lib/mysql/database_name

    # 交换新表和旧表
    mv emum_test.frm emum_test_tmp.frm
    mv emum_test_new.frm emum_test.frm
    mv emum_test_tmp.frm emum_test_new.frm
    ```

    ```sql
    -- 释放锁
    UNLOCK TABLES;

    -- 查看表结构是否更改
    DESC emum_test

    -- 查看数据
    SELECT * FROM emum_test
    ```
    ![image](./Pictures/mysql/alter_frm1.avif)

## INDEX(索引)

- 当你想查阅书中某个知识的内容，你会选择一页一页的找呢？还是在书的目录去找呢？
    - 那换到数据库中，索引的定义就是帮助存储引擎快速获取数据的一种数据结构，形象的说就是`索引`是数据的目录。

- 索引和数据位于存储引擎

- 索引

    - 优点:提升查询速度。可以减少随机 IO,索引能过滤出越少的数据,则从磁盘中读入的数据也就越少

    - 缺点：
        - 需要占用物理空间，数量越大，占用空间越大；
        - 创建索引和维护索引要耗费时间，这种时间随着数据量的增加而增大；
        - 会降低表的增删改的效率，因为每次增删改索引，B+ 树为了维护索引有序性，都需要进行动态维护。

        - 所以，索引不是万能钥匙，它也是根据场景来使用的。
            - 限制每张表上的索引数量,建议单张表索引不超过 5 个

            - 禁止给表中的每一列都建立单独的索引

            - 对于非常小的表全表扫描, 比索引更有效

- 什么时候适用索引？
    - 字段有唯一性限制的，比如商品编码；
    - 经常用于 `WHERE` 查询条件的字段，这样能够提高整个表的查询速度，如果查询条件不是一个字段，可以建立联合索引。
    - 经常用于 `GROUP BY` 和 `ORDER BY` 的字段，这样在查询的时候就不需要再去做一次排序了，因为我们都已经知道了建立索引之后在 B+Tree 中的记录都是排序好的。

- 什么时候不需要创建索引？
    - `WHERE` 条件，`GROUP BY`，`ORDER BY` 里用不到的字段，索引的价值是快速定位，如果起不到定位的字段通常是不需要创建索引的，因为索引是会占用物理空间的。

    - 字段中存在大量重复数据，不需要创建索引，比如性别字段，只有男女，如果数据库表中，男女的记录分布均匀，那么无论搜索哪个值都可能得到一半的数据。在这些情况下，还不如不要索引，因为 MySQL 还有一个查询优化器，查询优化器发现某个值出现在表的数据行中的百分比很高的时候，它一般会忽略索引，进行全表扫描。

    - 表数据太少的时候，不需要创建索引；

    - 经常更新的字段不用创建索引，比如不要对电商项目的用户余额建立索引，因为索引字段频繁修改，由于要维护 B+Tree的有序性，那么就需要频繁的重建索引，这个过程是会影响数据库性能的。

### SQL语法

> ```sql
> CREATE INDEX 索引名
> ON 表名 (列1, 列2,...)
> -- 降序
> CREATE INDEX 索引名
> ON 表名 (列1, 列2,... DESC)
>
> ALTER table 表名
> ADD INDEX 索引名(列1, 列2);
> ```

- 创建主键
    ```sql
    -- 表中不包含主键，创建一个主键：
    ALTER TABLE tablename ADD PRIMARY KEY (col1, col2);

    -- 替换一个已存在的主键：
    ALTER TABLE tabelname DROP PRIMARY KEY, ADD PRIMARY KEY (col1, col2);
    ```

- 增加一个唯一键：
    ```sql
    ALTER TABLE tablename ADD UNIQUE (col3);
    CREATE UNIQUE INDEX index2 ON tablename(col4);
    ```

- 增加一个顺序索引：
    ```sql
    ALTER TABLE tablename ADD INDEX (col5);

    -- 顺序
    CREATE INDEX index3 ON tablename (col6);
    -- 降序
    CREATE INDEX index3 ON ca (col6 desc);
    ```

- 增加一个函数索引：
    ```sql
    ALTER TABLE tablename ADD INDEX ((func(col7)));
    CREATE INDEX index4 ON tablename ((func(col8)));
    ```

- 删除索引
    ```sql
    ALTER TABLE table DROP PRIMARY KEY;
    ALTER TABLE tabel DROP INDEX indexname;
    DORP INDEX indexname ON table;
    ```

```sql
-- 显示索引
SHOW INDEX FROM table;

-- 查看索引的元数据
SHOW CREATE TABLE table\G

-- 优化表数据和索引数据
OPTIMIZE TABLE table
```

### 索引长度限制

- [小许code：遇到个MySQL索引长度限制的问题](https://mp.weixin.qq.com/s/wA_6F3nqsB-3I8iDglwxrQ)

```sql
Specified key was too long; max key length is 767 bytes
-- 需要添加索引的字段的长度太长,超过了767字节
```

![image](./Pictures/mysql/index-索引长度限制.avif)

- MyISAM
    - 单列索引：最大长度不能超过 1000 bytes，否则会报警，但是创建成功，最终创建的是前缀索引（取前333个字符）。
    - 联合索引：索引长度和不能超过 1000 bytes，否则会报错，创建失败

- InnoDB
    - 单列索引：超过 767 bytes的，给出warning，最终索引创建成功，取前缀索引（取前 255 字符）
    - 联合索引：各列长度不超过 767 字节 ，如果有超过 767 bytes 的，则给出报警，索引最后创建成功，但是对于超过 767 字节的列取前缀索引，与索引列顺序无关，总和不得超过 3072 ，否则失败，无法创建

- 不同mysql版本

    - MySQL5.5 版本：引入了 `innodb_large_prefix`，用来禁用大型前缀索引，以便与不支持大索引键前缀的早期版本的 InnoDB 兼容

        - 开启 `innodb_large_prefix` 可以使单索引的长度限制达到 3072 字节（但是联合索引总长度限制还是 3072 字节），禁用时单索引的长度限制为 767 字节

    - MySQL5.7： MySQL5.5版本与MySQL5.6 版本，`innodb_large_prefix` 是默认关闭的，在 MySQL5.7 及以上版本则默认开启

    - MySQL8.0 版本：`innodb_large_prefix` 已被移除，从版本 8.0 开始，索引长度限制由行格式决定

        - 若行格式为 `DYNAMIC` 或 `COMPRESSED` 时，限制值为 3072，而行格式 `REDUNDANT` 或 `COMPACT` 时，限制值为 767。

            - MySQL在5.7及以上版本在InnoDB引擎中默认行格式是 `DYNAMIC`，所以限制长度为3072字节。

- 字符集对索引长度影响

    ![image](./Pictures/mysql/index-字符集对索引长度影响.avif)

    - `UTF8MB4` 为四字节编码字符集；`UTF8` 为三字节编码字符集：
        - 在`UTF8`编码下varchar(255)是255 * 3 = 765字节：765 * 4 = 3060，因此最多`4`个varchar(255)字段就快超过综合3072了
        - 在`UTF8MB4`编码下varchar(255)是255 * 3 = 765字节：765 * 3 = 3060，因此最多`3`个varchar(255)字段就快超过综合3072了

- 解决方案

    - 1.将varchar(255)字段改成更小的字符长度类型
    - 2.如果是MySQL5.5版本与MySQL5.6 版本，可以启用innodb_large_prefix参数,来使得单个索引字段的长度突破767
    - 3.这种大字段类型可以考虑前缀索引

### EXPLAIN

- [MySQL数据库联盟：一文搞懂MySQL执行计划](https://mp.weixin.qq.com/s?__biz=MzIyOTUzNjgwNg==&mid=2247485161&idx=1&sn=8952815f9fae79edfcb6da57ecf60c38&chksm=e84063a0df37eab6b035f2c59284fe48b79272327f6bf02efeecd2f9ff63e9353123fff11bda&cur_album_id=3234198021790154762&scene=190#rd)

- [爱可生开源社区：技术分享 | EXPLAIN 执行计划详解（1）](https://mp.weixin.qq.com/s/DHCXwMdGTGrftHELBgGonA)

- ChatGPT并不能完全正确的优化，或者ChatGPT优化的SQL，需要我们再去校验，这个时候就需要用到执行计划的基本功了。

- 我们重点关注的点如下：
- 1.使用全表扫描，性能最差，即`type=ALL`
- 2.扫描行数过多，即rows>阈值
- 3.查询时使用了排序操作，也比较耗时，即Extra包含`Using filesort`
- 4.索引类型为index，代表全盘扫描了索引的数据，Extra信息为Using where，代表要搜索的列没有被索引覆盖，需要回表，性能较差。
- 以上几点都可能造成SQL性能的劣化，是我们需要额外关注的高风险sql。

```sql
EXPLAIN SELECT * FROM t1 WHERE b=100;
-- 等同于上
desc SELECT * FROM t1 WHERE b=100;
+----+-------------+-------+------+---------------+-------+---------+-------+------+-------+
| id | select_type | table | type | possible_keys | key   | key_len | ref   | rows | Extra |
+----+-------------+-------+------+---------------+-------+---------+-------+------+-------+
| 1  | SIMPLE      | t1    | ref  | idx_b         | idx_b | 5       | const | 1    |       |
+----+-------------+-------+------+---------------+-------+---------+-------+------+-------+
```

- 加粗的列为需要重点关注的项。

| 列名            | 解释                                                                                                      |
|-----------------|-----------------------------------------------------------------------------------------------------------|
| id              | 查询编号                                                                                                  |
| **select_type** | 查询类型：显示本行是简单还是复杂查询                                                                      |
| table           | 涉及到的表                                                                                                |
| partitions      | 匹配的分区：查询将匹配记录所在的分区。仅当使用 partition 关键字时才显示该列。对于非分区表，该值为 NULL。 |
| **type**        | 本次查询的表连接类型                                                                                      |
| possible_keys   | 值并不是越多越好，可能使用的索引越多，查询优化器计算查询成本时就得花费更长时间，所以如果可以的话，尽量删除那些用不到的索引。                                                                                            |
| **key**         | 实际选择的索引                                                                                            |
| **key_len**     | 被选择的索引长度：如果键是 NULL，则长度为 NULL。使用的索引的长度。在不损失精确性的情况下，长度越短越好 。|
| ref             | 与索引比较的列                                                                                            |
| **rows**        | 执行计划的 rows 列就代表预计需要扫描的行数；如果使用索引来执行查询时，执行计划的 rows 列就代表预计扫描的索引记录行数。对InnoDB来说，这个值是估值，并不一定准确                                              |
| filtered        | 按条件筛选的行的百分比                                                                                    |
| **Extra**       | 附加信息                                                                                                  |

- `id`：查询语句中每出现一个 SELECT 关键字，MySQL 就会为它分配一个唯一的 id 值。
    - 2个`id`值一样的情况：优化器对子查询做了 semi-join 优化时，和关联查询一样两个查询的 id 是一样的：
        ```sql
        explain select * from t1 where a in (select b from t2 where t2.b=100);
        +----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+--------------------------------------------------------------------+
        | id | select_type | table | partitions | type | possible_keys | key  | key_len | ref   | rows | filtered | Extra                                                              |
        +----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+--------------------------------------------------------------------+
        |  1 | SIMPLE      | t1    | NULL       | ref  | a             | a    | 5       | const |    1 |   100.00 | NULL                                                               |
        |  1 | SIMPLE      | t2    | NULL       | ALL  | NULL          | NULL | NULL    | NULL  |    1 |   100.00 | Using where; FirstMatch(t1); Using join buffer (Block Nested Loop) |
        +----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+--------------------------------------------------------------------+
        ```

    - `id`值为 `NULL`：这是因为 union 结果是要去重的，内部创建了一个 <union1,2> 名字的临时表，把查询 1 和查询 2 的结果集都合并到这个临时表中，利用唯一键进行去重，这种情况下查询 id 就为 NULL。
        ```sql
        explain select * from t1 union select * from t2;
        +----+--------------+------------+------------+------+---------------+------+---------+------+------+----------+-----------------+
        | id | select_type  | table      | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra           |
        +----+--------------+------------+------------+------+---------------+------+---------+------+------+----------+-----------------+
        |  1 | PRIMARY      | t1         | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 1000 |   100.00 | NULL            |
        |  2 | UNION        | t2         | NULL       | ALL  | NULL          | NULL | NULL    | NULL |    1 |   100.00 | NULL            |
        | NULL | UNION RESULT | <union1,2> | NULL       | ALL  | NULL          | NULL | NULL    | NULL | NULL |     NULL | Using temporary |
        +----+--------------+------------+------------+------+---------------+------+---------+------+------+----------+-----------------+
        ```



- `filtered`

    - 对于单表查询来说：
        - 如果是全表扫描，filtered 值代表满足 where 条件的行数占表总行数的百分比；
        - 如果是使用索引来执行查询，filtered 值代表从索引上取得数据后，满足其他过滤条件的数据行数的占比。

    - 从 a 索引上取得 99 行数据，优化器估算认为这 99 行数据中有 33.33% 满足 b > 100 这个条件。对于单表查询来说，这个意义不大。

        ```sql
        explain select * from t1 where a<100 and b > 100;
        +----+-------------+-------+------------+-------+---------------+------+---------+------+------+----------+------------------------------------+
        | id | select_type | table | partitions | type  | possible_keys | key  | key_len | ref  | rows | filtered | Extra                              |
        +----+-------------+-------+------------+-------+---------------+------+---------+------+------+----------+------------------------------------+
        |  1 | SIMPLE      | t1    | NULL       | range | a             | a    | 5       | NULL |   99 |    33.33 | Using index condition; Using where |
        +----+-------------+-------+------------+-------+---------------+------+---------+------+------+----------+------------------------------------+
        ```

    - 对于关联查询来说，驱动表的 rows*(filtered/100) 代表优化器认为的扇出，对于关联查询的成本估算有很大的影响。

        - 从执行计划中可以看出来，查询优化器打算把 s1 当作驱动表，s2 当作被驱动表。我们可以看到驱动表 s1 表的执行计划的 rows 列为 9688， filtered 列为 10.00，这意味着驱动表 s1 的扇出值就是 9688 × 10.00% = 968.8，这说明还要对被驱动表执行大约 968 次查询。
        ```sql
        EXPLAIN SELECT * FROM s1 INNER JOIN s2 ON s1.key1 = s2.key1 WHERE s1.common_field = 'a';
        +----+-------------+-------+------------+------+---------------+----------+---------+-------------------+------+----------+-------------+
        | id | select_type | table | partitions | type | possible_keys | key      | key_len | ref               | rows | filtered | Extra       |
        +----+-------------+-------+------------+------+---------------+----------+---------+-------------------+------+----------+-------------+
        |  1 | SIMPLE      | s1    | NULL       | ALL  | idx_key1      | NULL     | NULL    | NULL              | 9688 |    10.00 | Using where |
        |  1 | SIMPLE      | s2    | NULL       | ref  | idx_key1      | idx_key1 | 303     | xiaohaizi.s1.key1 |    1 |   100.00 | NULL        |
        +----+-------------+-------+------------+------+---------------+----------+---------+-------------------+------+----------+-------------+
        ```

#### select_type各种值的解释

| select_type 的值     | 解释                                                        |
|----------------------|-------------------------------------------------------------|
| SIMPLE               | 简单查询(不使用关联查询或子查询)                            |
| PRIMARY              | 如果包含关联查询或者子查询，则最外层的查询部分标记为primary |
| UNION                | 联合查询中第二个及后面的查询                                |
| DEPENDENT UNION      | 满足依赖外部的关联查询中第二个及以后的查询                  |
| UNION RESULT         | 联合查询的结果                                              |
| SUBQUERY             | 子查询中的第一个查询                                        |
| DEPENDENT SUBQUERY   | 子查询中的第一个查询，并且依赖外部查询                      |
| DERIVED              | 用到派生表的查询                                            |
| MATERIALIZED         | 被物化的子查询                                              |
| UNCACHEABLE SUBQUERY | 一个子查询的结果不能被缓存，必须重新评估外层查询的每一行    |
| UNCACHEABLE UNION    | 关联查询第二个或后面的语句属于不可缓存的子查询              |


- 1.SIMPLE

- 查询语句中**不包含 UNION 或者子查询**的查询都算作是 SIMPLE 类型，比方说下边这个单表查询的 select_type 的值就是 SIMPLE：

    ```sql
    explain select * from t1 where b=1 order by a;
    +----+-------------+-------+------------+------+---------------+-------+---------+-------+------+----------+---------------------------------------+
    | id | select_type | table | partitions | type | possible_keys | key   | key_len | ref   | rows | filtered | Extra                                 |
    +----+-------------+-------+------------+------+---------------+-------+---------+-------+------+----------+---------------------------------------+
    |  1 | SIMPLE      | t1    | NULL       | ref  | idx_b         | idx_b | 5       | const |    1 |   100.00 | Using index condition; Using filesort |
    +----+-------------+-------+------------+------+---------------+-------+---------+-------+------+----------+---------------------------------------+
    ```

- 关联查询也是 SIMPLE 类型：

    ```sql
    explain select * from t1 join t2 on t1.a=t2.a;
    +----+-------------+-------+------------+------+---------------+------+---------+-----------+------+----------+-------------+
    | id | select_type | table | partitions | type | possible_keys | key  | key_len | ref       | rows | filtered | Extra       |
    +----+-------------+-------+------------+------+---------------+------+---------+-----------+------+----------+-------------+
    |  1 | SIMPLE      | t2    | NULL       | ALL  | a             | NULL | NULL    | NULL      |    1 |   100.00 | Using where |
    |  1 | SIMPLE      | t1    | NULL       | ref  | a             | a    | 5       | hucq.t2.a |    1 |   100.00 | NULL        |
    +----+-------------+-------+------------+------+---------------+------+---------+-----------+------+----------+-------------+
    ```

- 2.PRIMARY

- 对于**包含 union 或者子查询**的大查询来说，它是由几个小查询组成的，其中最左边的那个查询的 select_type 值就是 PRIMARY，比如：

```sql
explain select * from t1 union select * from t2;
+----+--------------+------------+------------+------+---------------+------+---------+------+------+----------+-----------------+
| id | select_type  | table      | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra           |
+----+--------------+------------+------------+------+---------------+------+---------+------+------+----------+-----------------+
|  1 | PRIMARY      | t1         | NULL       | ALL  | NULL          | NULL | NULL    | NULL | 1000 |   100.00 | NULL            |
|  2 | UNION        | t2         | NULL       | ALL  | NULL          | NULL | NULL    | NULL |    1 |   100.00 | NULL            |
| NULL | UNION RESULT | <union1,2> | NULL       | ALL  | NULL          | NULL | NULL    | NULL | NULL |     NULL | Using temporary |
+----+--------------+------------+------------+------+---------------+------+---------+------+------+----------+-----------------+
```

- 3.UNION：位于 union 或者 union all 查询中第二个及其以后的查询被标记为 UNION，第一个被标记为 primary ，可以对比上一个例子的效果。

- 4.UNION RESULT：MySQL 选择使用临时表来完成 UNION 查询的去重工作，针对该临时表的查询的 select_type 就是 UNION RESULT，跟上一个例子一样。

- 5.SUBQUERY

- 当子查询不能被优化成 semi-join，但可以用 materialization 来优化，显示为 SUBQUERY，表示这是一个不相关子查询，子查询只需要执行一遍（因为结果被物化成临时表了），举例：

```sql
explain SELECT * FROM t1 WHERE t1.a IN (SELECT t2.b FROM t2 WHERE id < 10);
+----+-------------+-------+-------+---------+------+------+-------------+
| id | select_type | table | type  | key     | ref  | rows | Extra       |
+----+-------------+-------+-------+---------+------+------+-------------+
|  1 | PRIMARY     | t1    | ALL   | NULL    | NULL |  100 | Using where |
|  2 | SUBQUERY    | t2    | range | PRIMARY | NULL |    9 | Using where |
+----+-------------+-------+-------+---------+------+------+-------------+
```

- 6.DEPENDENT SUBQUERY

- 当子查询不能被优化成 semi-join，并且是一个相关子查询（或者非相关子查询关闭 materialization 优化策略时），会被优化器转化成 exists 相关子查询来进行查询，显示为 DEPENDENT SUBQUERY，表示这是一个相关子查询，会根据外查询结果执行多次。举例：

```sql
SELECT * FROM t1 WHERE t1.a IN (SELECT t2.b FROM t2 WHERE id < 10);
+----+--------------------+-------+-------+---------+------+----------+-------------+
| id | select_type        | table | type  | key     | rows | filtered | Extra       |
+----+--------------------+-------+-------+---------+------+----------+-------------+
|  1 | PRIMARY            | t1    | ALL   | NULL    |  100 |   100.00 | Using where |
|  2 | DEPENDENT SUBQUERY | t2    | range | PRIMARY |    9 |    10.00 | Using where |
+----+--------------------+-------+-------+---------+------+----------+-------------+
```

- 7.MATERIALIZED

- 当子查询被优化成 semi-join 执行，并且 semi-join 用的是 Materialize 策略，这个子查询对应显示就是 MATERIALIZED，然后用子查询结果物化后的临时表与另一张表进行关联查询。举例：

```sql
SELECT * FROM t1 WHERE t1.a IN (SELECT t2.b FROM t2 WHERE id < 10);
+----+--------------+-------------+-------+---------+---------------+------+-------------+
| id | select_type  | table       | type  | key     | ref           | rows | Extra       |
+----+--------------+-------------+-------+---------+---------------+------+-------------+
|  1 | SIMPLE       | <subquery2> | ALL   | NULL    | NULL          | NULL | Using where |
|  1 | SIMPLE       | t1          | ref   | a       | <subquery2>.b |    1 | NULL        |
|  2 | MATERIALIZED | t2          | range | PRIMARY | NULL          |    9 | Using where |
+----+--------------+-------------+-------+---------+---------------+------+-------------+
```

- 8.DERIVED

- 对于无法使用 derived_merge 优化的派生子查询，优化器会采用物化的方式执行的包含派生表的子查询，该派生表对应的子查询的 select_type 就是 DERIVED，举例：

```sql
explain select * from t1 join (select distinct a from t2) as derived_t2 on t1.a=derived_t2.a;
+----+-------------+------------+------------+-------+---------------+-------------+---------+----------------+------+----------+-------------+
| id | select_type | table      | partitions | type  | possible_keys | key         | key_len | ref            | rows | filtered | Extra       |
+----+-------------+------------+------------+-------+---------------+-------------+---------+----------------+------+----------+-------------+
|  1 | PRIMARY     | t1         | NULL       | ALL   | a             | NULL        | NULL    | NULL           |  100 |   100.00 | Using where |
|  1 | PRIMARY     | <derived2> | NULL       | ref   | <auto_key0>   | <auto_key0> | 5       | join_test.t1.a |   10 |   100.00 | Using index |
|  2 | DERIVED     | t2         | NULL       | index | a             | a           | 5       | NULL           | 1000 |   100.00 | Using index |
+----+-------------+------------+------------+-------+---------------+-------------+---------+----------------+------+----------+-------------+
```

#### type各种值的解释

- 查询性能从上到下依次是最好到最差。

| type的值        | 解释                                                                       |
|-----------------|----------------------------------------------------------------------------|
| system          | 查询对象表只有一行数据且只能用于 MyISAM 和 Memory 引擎的表，这是最好的情况 |
| const           | 基于主键或唯一索引查询，最多返回一条结果                                   |
| eq_ref          | 表连接时基于主键或非 NULL 的唯一索引完成扫描                               |
| ref             | 基于普通索引的等值查询，或者表间等值连接                                   |
| fulltext        | 全文检索                                                                   |
| ref_or_null     | 表连接类型是 ref，但进行扫描的索引列中可能包含 NULL 值                     |
| index_merge     | 利用多个索引                                                               |
| unique_subquery | 子查询中使用唯一索引                                                       |
| index_subquery  | 子查询中使用普通索引                                                       |
| range           | 利用索引进行范围查询                                                       |
| index           | 覆盖索引扫描，可以简单描述为没有过滤条件的索引扫描；更进一步，如果从索引角度来讲，就是全表扫了。|
| ALL             | 全表扫描                                                                   |


- 1.system：

- 当表中只有一条记录并且该表使用的存储引擎的统计数据是精确的，比如 MyISAM、Memory，那么对该表的访问方法就是 system：

    ```sql
    explain select * from t_myisam;
    +----+-------------+----------+------------+--------+---------------+------+---------+------+------+----------+-------+
    | id | select_type | table    | partitions | type   | possible_keys | key  | key_len | ref  | rows | filtered | Extra |
    +----+-------------+----------+------------+--------+---------------+------+---------+------+------+----------+-------+
    |  1 | SIMPLE      | t_myisam | NULL       | system | NULL          | NULL | NULL    | NULL |    1 |   100.00 | NULL  |
    +----+-------------+----------+------------+--------+---------------+------+---------+------+------+----------+-------+
    ```

- InnoDB 表即使只有一行，也不是 system，而是 ALL：

    ```sql
    explain select * from t5;                                                                                                                               +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------+
    | id | select_type | table | partitions | type | possible_keys | key  | key_len | ref  | rows | filtered | Extra |
    +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------+
    |  1 | SIMPLE      | t5    | NULL       | ALL  | NULL          | NULL | NULL    | NULL |    1 |   100.00 | NULL  |
    +----+-------------+-------+------------+------+---------------+------+---------+------+------+----------+-------+
    ```

- 2.const：根据主键或者唯一二级索引列与单个常数进行等值匹配时（不能有多个条件用 or 连接，这属于范围查询），对单表的访问方法就是 const，举例：

```sql
explain select * from t1 where id=100;
+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
| id | select_type | table | partitions | type  | possible_keys | key     | key_len | ref   | rows | filtered | Extra |
+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | t1    | NULL       | const | PRIMARY       | PRIMARY | 4       | const |    1 |   100.00 | NULL  |
+----+-------------+-------+------------+-------+---------------+---------+---------+-------+------+----------+-------+
```

- 3.eq_ref

- 在连接查询时，如果被驱动表是通过主键或者唯一二级索引列等值匹配的方式进行访问的（如果该主键或者唯一二级索引是联合索引的话，所有的索引列都必须进行等值比较），则对该被驱动表的访问方法就是 eq_ref，举例：

```sql
explain select * from t1 join t2 on t1.id=t2.id where t1.a<50;
+----+-------------+-------+------------+--------+---------------+---------+---------+------------+------+----------+-------------+
| id | select_type | table | partitions | type   | possible_keys | key     | key_len | ref        | rows | filtered | Extra       |
+----+-------------+-------+------------+--------+---------------+---------+---------+------------+------+----------+-------------+
|  1 | SIMPLE      | t2    | NULL       | ALL    | PRIMARY       | NULL    | NULL    | NULL       |    1 |   100.00 | NULL        |
|  1 | SIMPLE      | t1    | NULL       | eq_ref | PRIMARY,a     | PRIMARY | 4       | hucq.t2.id |    1 |     5.00 | Using where |
+----+-------------+-------+------------+--------+---------------+---------+---------+------------+------+----------+-------------+
```

- 4.ref

- 当通过普通的二级索引列与常量进行等值匹配时，那么对该表的访问方法就是 ref，即使匹配到的值可能是多行，举例：

```sql
explain select * from t11 where a=100;
+----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+-------+
| id | select_type | table | partitions | type | possible_keys | key  | key_len | ref   | rows | filtered | Extra |
+----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+-------+
|  1 | SIMPLE      | t11   | NULL       | ref  | a             | a    | 5       | const |  500 |   100.00 | NULL  |
+----+-------------+-------+------------+------+---------------+------+---------+-------+------+----------+-------+
```

- 5.ref_or_null

- 当对普通二级索引进行等值匹配查询，该索引列的值也可以是 NULL 值时，那么对该表的访问方法就可能是 ref_or_null，举例：

```sql
explain select * from t11 where a=100 or a is null;
+----+-------------+-------+------------+-------------+---------------+------+---------+-------+------+----------+-----------------------+
| id | select_type | table | partitions | type        | possible_keys | key  | key_len | ref   | rows | filtered | Extra                 |
+----+-------------+-------+------------+-------------+---------------+------+---------+-------+------+----------+-----------------------+
|  1 | SIMPLE      | t11   | NULL       | ref_or_null | a             | a    | 5       | const |  501 |   100.00 | Using index condition |
+----+-------------+-------+------------+-------------+---------------+------+---------+-------+------+----------+-----------------------+
```

- 6.index_merge

- 一般情况下对于某个表的查询只能使用到一个索引，在某些场景下可以使用 Intersection、Union、Sort-Union 这三种索引合并的方式来执行查询，此时就显示为 index_merge，举例：

```sql
explain select * from t1 where a<50 or b=50;
+----+-------------+-------+------------+-------------+---------------+---------+---------+------+------+----------+----------------------------------------+
| id | select_type | table | partitions | type        | possible_keys | key     | key_len | ref  | rows | filtered | Extra                                  |
+----+-------------+-------+------------+-------------+---------------+---------+---------+------+------+----------+----------------------------------------+
|  1 | SIMPLE      | t1    | NULL       | index_merge | a,idx_b       | a,idx_b | 5,5     | NULL |   50 |   100.00 | Using sort_union(a,idx_b); Using where |
+----+-------------+-------+------------+-------------+---------------+---------+---------+------+------+----------+----------------------------------------+
```

- 7.unique_subquery

- 对一些包含 in 子查询的查询语句中，如果优化器无法使用 semi-join 或物化进行优化，最终将子查询转换为 EXISTS 子查询，而且子查询可以使用到主键或者唯一键进行等值匹配的话，那么该子查询执行计划的type列的值就是 unique_subquery。举例：

```sql
explain select * from t1 where a in(select id from t2 where t1.a=t2.a) or b=100;
+----+--------------------+-------+------------+-----------------+---------------+---------+---------+------+------+----------+-------------+
| id | select_type        | table | partitions | type            | possible_keys | key     | key_len | ref  | rows | filtered | Extra       |
+----+--------------------+-------+------------+-----------------+---------------+---------+---------+------+------+----------+-------------+
|  1 | PRIMARY            | t1    | NULL       | ALL             | idx_b         | NULL    | NULL    | NULL | 1000 |   100.00 | Using where |
|  2 | DEPENDENT SUBQUERY | t2    | NULL       | unique_subquery | PRIMARY,a     | PRIMARY | 4       | func |    1 |   100.00 | Using where |
+----+--------------------+-------+------------+-----------------+---------------+---------+---------+------+------+----------+-------------+
```

- 8.range

- 如果使用索引获取某些范围区间的记录，那么就可能使用到 range 访问方法。举例：

```sql
explain select * from t1 where a<50 and a>20;
+----+-------------+-------+------------+-------+---------------+------+---------+------+------+----------+-----------------------+
| id | select_type | table | partitions | type  | possible_keys | key  | key_len | ref  | rows | filtered | Extra                 |
+----+-------------+-------+------------+-------+---------------+------+---------+------+------+----------+-----------------------+
|  1 | SIMPLE      | t1    | NULL       | range | a             | a    | 5       | NULL |   29 |   100.00 | Using index condition |
+----+-------------+-------+------------+-------+---------------+------+---------+------+------+----------+-----------------------+

explain select * from t1 where a in(1,2,3);
+----+-------------+-------+------------+-------+---------------+------+---------+------+------+----------+-----------------------+
| id | select_type | table | partitions | type  | possible_keys | key  | key_len | ref  | rows | filtered | Extra                 |
+----+-------------+-------+------------+-------+---------------+------+---------+------+------+----------+-----------------------+
|  1 | SIMPLE      | t1    | NULL       | range | a             | a    | 5       | NULL |    3 |   100.00 | Using index condition |
+----+-------------+-------+------------+-------+---------------+------+---------+------+------+----------+-----------------------+
```

- 9.index

- 需要扫描全部的索引记录时，该表的访问方法就是 index，成本很高。举例：

```sql
EXPLAIN SELECT key_part1 FROM s1 WHERE key_part3 = 'a';
+----+-------------+-------+------------+-------+---------------+--------------+---------+------+------+----------+--------------------------+
| id | select_type | table | partitions | type  | possible_keys | key          | key_len | ref  | rows | filtered | Extra                    |
+----+-------------+-------+------------+-------+---------------+--------------+---------+------+------+----------+--------------------------+
|  1 | SIMPLE      | s1    | NULL       | index | NULL          | idx_key_part | 909     | NULL | 9688 |    10.00 | Using where; Using index |
+----+-------------+-------+------------+-------+---------------+--------------+---------+------+------+----------+--------------------------+
```

possible_keys 和 key
在 EXPLAIN 语句输出的执行计划中，possible_keys 列表示在某个查询语句中，对某个表执行单表查询时可能用到的索引有哪些，key 列表示实际用到的索引有哪些。

有些时候使用到的索引未必在 passible_keys 中，上面 type 为 index 的示例中，passible_keys 显示为 NULL，但实际 key 显示是使用到索引的。possible_keys 列中的值并不是越多越好，可能使用的索引越多，查询优化器计算查询成本时就得花费更长时间，所以如果可以的话，尽量删除那些用不到的索引。


- key_len各种字段类型对应的长度

- explain 中的 key_len 列用于表示这次查询中，所选择的索引长度有多少字节，常用于判断联合索引有多少列被选择了。下表总结了常用字段类型的 key_len：

| 列类型                    | KEY_LEN                                                                   | 备注                                             |
|---------------------------|---------------------------------------------------------------------------|--------------------------------------------------|
| int                       | key_len = 4+1                                                             | int 为 4 bytes，允许为 NULL，加 1 byte           |
| int                       | not null key_len = 4                                                      | 不允许为 NULL                                    |
| bigint                    | key_len=8+1                                                               | bigint 为 8 bytes，允许为 NULL 加 1 byte         |
| bigint not null           | key_len=8                                                                 | bigint 为 8 bytes                                |
| char(30) utf8             | key_len=30*3+1                                                            | char(n)为：n * 3 ，允许为 NULL 加 1 byte         |
| char(30) not null utf8    | key_len=30*3                                                              | 不允许为 NULL                                    |
| varchar(30) not null utf8 | key_len=30*3+2                                                            | utf8 每个字符为 3 bytes，变长数据类型,加 2 bytes |
| varchar(30)               | utf8                                                                      | key_len=30*3+2+1                                 | utf8 每个字符为 3 bytes，允许为 NULL,加 1 byte,变长数据类型，加 2 bytes |
| datetime                  | key_len=8+1 (MySQL 5.6.4之前的版本)；key_len=5+1(MySQL 5.6.4及之后的版本) | 允许为 NULL，加 1 byte                           |

#### Extra各种值的解释

- [爱可生开源社区：技术分享 | EXPLAIN 执行计划详解（2）--Extra](https://mp.weixin.qq.com/s/Ihl6GG5MQzU1NkqCOScm9A)

- [爱可生开源社区：第 49 期：根据 EXPLAIN EXTRA 栏提示进行优化（一）](https://mp.weixin.qq.com/s/lc-9QNmI00nJ1Z9OAw_lJw)

- [爱可生开源社区：第 50 期：根据 EXPLAIN EXTRA 栏提示进行优化（二）](https://mp.weixin.qq.com/s/U9JDFEpfxdMN-nul49ggaA)

| Extra                         | 常见的值                                                                 | 解释                                                                          | 例子 |
|-------------------------------|--------------------------------------------------------------------------|-------------------------------------------------------------------------------|------|
| Using filesort                | 将用外部排序而不是索引排序，数据较小时从内存排序，否则需要在磁盘完成排序 | explain select * from t1 order by create_time;                                |
| Using temporary               | 需要创建一个临时表来存储结构，通常发生对没有索引的列进行 GROUP BY 时     | explain select * from t1 group by create_time;                                |
| Using where                   | 使用 where 语句来处理结果                                                | explain select * from t1 where create_time='2019-06-18 14:38:24';             |
| Using index                   |查询的字段都包含在使用的索引中；where 子句使用的字段也都包含在使用的索引中。                                                             | explain select a from t1 where a=111;                                         |
| Impossible WHERE              | 对 where 子句判断的结果总是 false 而不能选择任何数据                     | explain select * from t1 where 1<0;                                           |
| Using join buffer (hash join) | 关联查询中，被驱动表的关联字段没索引                                     | explain select * from t1 straight_join t2 on (t1.create_time=t2.create_time); |
| Using index condition         | 先条件过滤索引，再查数据                                                 | explain select * from t1 where a >900 and a like '%9';                        |
| Select tables optimized away  | 使用某些聚合函数（比如 max、min）来访问存在索引的某个字段是              | explain select max(a) from t1;                                                |
| ......                        |                                                                          |                                                                               |

- `Using index`

    - 这条提示信息是最为常见的，表示这条 SQL 可以不用回表，只需要扫描现存索引结构即可拿到所需记录；需要对索引中的记录按照索引顺序进行扫描。执行计划的 extra 会显示为 `Using index`：

    - 查询的字段都包含在使用的索引中；
        - 所以单从数据库角度来讲，很多公司里定制的开发规范都强调在写 SQL 时，只需拿必要字段而不推荐写 `SELECT *` 也是很有道理的。
    - `where` 子句使用的字段也都包含在使用的索引中。

    - 例子：有组合索引：`idx_a (first_name,last_name,birth_date)`

        ```sql
        explain select first_name,last_name,birth_date from employees where \
        first_name='Mayuri' and last_name like 'Alpay' and birth_date > '1968-01-01'\G
        *************************** 1. row ***************************
                   id: 1
          select_type: SIMPLE
                table: employees
           partitions: NULL
                 type: range
        possible_keys: idx_a
                  key: idx_a
              key_len: 127
                  ref: NULL
                 rows: 1
             filtered: 100.00
                Extra: Using where; Using index
        ```

- `Backward index scan`：这条提示信息代表此条 SQL 可以走索引，不过没有按照索引顺序扫描，而是反向扫描；一般来讲，这个提示信息发生在需要倒序扫描索引记录的业务。
    ```sql
    desc select  r1 from t1 where 1 order by r1 desc\G
    *************************** 1. row ***************************
               id: 1
      select_type: SIMPLE
            table: t1
       partitions: NULL
             type: index
    possible_keys: NULL
              key: idx_r1
          key_len: 5
              ref: NULL
             rows: 101745
         filtered: 100.00
            Extra: Backward index scan; Using index
    1 row in set, 1 warning (0.00 sec)
    ```

    - 解决方法：针对这条 SQL 来讲，如果可以的话，需要单独创建一个倒序索引：
        ```sql
        alter table t1 add key idx_r1_desc(r1 desc);
        ```

- `Using index condition`：查询数据时如果使用 index condition down 索引条件下推就会出现

    - 使用二级索引查找数据时，where 条件中属于索引一部分但无法使用索引的条件（比如 `like '%abc'` 左侧字符不确定），MySQL 也会把这部分判断条件下推到存储引擎层，筛选之后再进行回表，这样回表时需要查找的数据就更少。

    - 索引条件下推的特点：

        - 下推的条件涉及的字段一定要是使用到的二级索引的一部分，因为二级索引索引存储了这些字段的值，才能进行筛选，所以叫做“索引条件下推”；
        - 大幅减小回表时的随机 I/O 开销。因为索引条件下推可以在查找完二级索引后利用条件筛选，减小结果集，减小接下来回表的次数，而回表做的是随机 I/O（开销大），所以能够节省大量的 I/O 开销；
        - 大幅减小了存储引擎层到 MySQL 服务层的传输开销。条件下推给了存储引擎层，提前进行筛选，这样返回给 MySQL 服务层的数据就变少了；
        - 剩下的不能用到索引的 where 条件还是在 MySQL 服务层生效。

    - 总的来说，只要是用到 `index filter`，就会发生索引条件下推。但不一定出现 `Using index condition` 就一定发生了索引条件下推。

    - 例子：有一个组合索引：`idx_a (first_name,last_name,birth_date)`

        - 查询的 where 子句中 `first_name='Mayuri'` 条件可以使用到二级索引 idx_a，而 `last_name like '%Alpay'` 条件最左的字符不固定所以不能使用二级索引。索引下推的执行过程是：
        - 通过二级索引 idx_a 查找满足 `first_name='Mayuri'` 条件的记录；
        - MySQL 把条件 `last_name like '%Alpay'` 下推到 InnoDB 层，对上一步的结果进行筛选（因为 last_name 是索引 idx_a 的一部分，所以可以直接筛选，否则不行）；
        - 取出上一步结果中的主键值，进行回表。

        ```sql
        explain select * from employees where first_name='Mayuri' and last_name like '%Alpay'\G
        *************************** 1. row ***************************
                   id: 1
          select_type: SIMPLE
                table: employees
           partitions: NULL
                 type: ref
        possible_keys: idx_a
                  key: idx_a
              key_len: 58
                  ref: const
                 rows: 230
             filtered: 11.11
                Extra: Using index condition
        ```

    - 例子：有一个组合索引：`idx_a (first_name,last_name,birth_date)`

        - 在索引树上 `first_name > 'Mayuri'` 的数据行，对于 last_name 的值来说是无序的。所以搜索索引树时，只能用 `first_name > 'Mayuri'` 来找出数据，然后再把 `last_name = 'Alpay'` 这个条件下推到 innodb 层筛选数据。

        - `select * from employees where first_name > 'Mayuri' and last_name = 'Alpay';`

    - 例子：有一个组合索引：`idx_a (first_name,last_name,birth_date)`

        - 虽然这里显示了 `Using index condition`，但实际上是不需要做索引条件下推的，因为索引的第一个字段固定，对于 last_name 字段值来说也是有序的。这属于一个 “bug”，特地考古找到了丁奇老师回复的一条评论：

        ```sql
        explain select * from employees where  first_name='Mayuri' and last_name > 'Alpay'\G
        *************************** 1. row ***************************
                   id: 1
          select_type: SIMPLE
                table: employees
           partitions: NULL
                 type: range
        possible_keys: idx_a
                  key: idx_a
              key_len: 124
                  ref: NULL
                 rows: 226
             filtered: 100.00
                Extra: Using index condition
        ```

- `Using where`

    - 就是前面说的 MySQL 服务层可以把属于索引的一部分但又无法使用索引的条件下推到存储引擎层，而其他条件还是得在 MySQL 服务层应用来过滤存储引擎层返回的数据。当出现这的情况，执行计划的 extra 字段就会出现 "Using where"，它可以和 "Using index" 一起出现，也可以和 "Using index condition" 一起出现。

    - 全表扫描的时候，MySQL 服务层应用 where 条件过滤数据

        ```sql
         explain select emp_no,first_name,last_name from employees where hire_date = '1959-12-06'\G
        *************************** 1. row ***************************
                   id: 1
          select_type: SIMPLE
                table: employees
           partitions: NULL
                 type: ALL
        possible_keys: NULL
                  key: NULL
              key_len: NULL
                  ref: NULL
                 rows: 299454
             filtered: 10.00
                Extra: Using where
        ```

    - 使用索引访问数据，但是 where 子句中有除了该索引包含的字段之外的条件时。
        ```sql
        explain select emp_no,first_name,last_name from employees where first_name='Mayuri' and hire_date = '1959-12-06'\G
        *************************** 1. row ***************************
                   id: 1
          select_type: SIMPLE
                table: employees
           partitions: NULL
                 type: ref
        possible_keys: idx_a
                  key: idx_a
              key_len: 58
                  ref: const
                 rows: 230
             filtered: 10.00
                Extra: Using where
        ```

    - 使用索引访问数据，并达到索引覆盖，但是 where 子句中有属于索引一部分但无法使用索引的条件（比如 like '%abc' 左侧字符不确定）条件时：
        ```sql
        explain select first_name,last_name,birth_date from employees where  first_name='Mayuri' and last_name like '%Alpay'\G
        *************************** 1. row ***************************
                   id: 1
          select_type: SIMPLE
                table: employees
           partitions: NULL
                 type: ref
        possible_keys: idx_a
                  key: idx_a
              key_len: 58
                  ref: const
                 rows: 230
             filtered: 11.11
                Extra: Using where; Using index
        ```

    - 使用索引访问数据，并且使用索引条件下推，并且 where 子句中有除了该索引包含的字段之外的条件时
        ```sql
        explain select * from employees where  first_name='Mayuri' and last_name like '%Alpay' and hire_date>'1969-01-01'\G
        *************************** 1. row ***************************
                   id: 1
          select_type: SIMPLE
                table: employees
           partitions: NULL
                 type: ref
        possible_keys: idx_a
                  key: idx_a
              key_len: 58
                  ref: const
                 rows: 230
             filtered: 3.70
                Extra: Using index condition; Using where
        ```

- `Select tables optimized away`：以最优的方式来得到结果，不需要访问实体表。

    - SQL 不需要实际执行即可拿到结果，也就是说 SQL 在被优化器交给执行器之前就可以拿到结果，不需要实际执行

    - 1.返回结果最多只能有一行。
    - 2.这一行必须从一个确定的结果集中获取。
    ```sql
    desc select min(r2),max(r3) from t1 \G
    *************************** 1. row ***************************
               id: 1
      select_type: SIMPLE
            table: t1
       partitions: NULL
             type: ALL
    possible_keys: NULL
              key: NULL
          key_len: NULL
              ref: NULL
             rows: 101745
         filtered: 100.00
            Extra: NULL
    ```

    ```sql
    -- 对于以上这条 SQL ，检索表 t1 字段 r2 的最小值以及字段 r3 的最大值，需要全表扫，加个索引后，执行计划就变为如下：
    alter table t1 add key idx_r2(r2), add key idx_r3(r3);

    desc select min(r2),max(r3) from t1 \G
    *************************** 1. row ***************************
               id: 1
      select_type: SIMPLE
            table: NULL
       partitions: NULL
             type: NULL
    possible_keys: NULL
              key: NULL
          key_len: NULL
              ref: NULL
             rows: NULL
         filtered: NULL
            Extra: Select tables optimized away
    ```

    ```sql
    desc select min(r2) from t1 where r2 = 1\G
    *************************** 1. row ***************************
               id: 1
      select_type: SIMPLE
            table: NULL
       partitions: NULL
             type: NULL
    possible_keys: NULL
              key: NULL
          key_len: NULL
              ref: NULL
             rows: NULL
         filtered: NULL
            Extra: Select tables optimized away
    ```

- `Zero limit`：这个表示 SQL 语句使用了 `LIMIT 0` 子句。检查语句合法性的需求，可以给语句后面加 `LIMIT 0`

    ```sql
    SELECT * FROM t1 WHERE b=100 limit 0
    +----+---+---+-------------+-------------+
    | id | a | b | create_time | update_time |
    +----+---+---+-------------+-------------+
    +----+---+---+-------------+-------------+

    EXPLAIN SELECT * FROM t1 WHERE b=100 limit 0
    +----+-------------+--------+--------+---------------+--------+---------+--------+--------+------------+
    | id | select_type | table  | type   | possible_keys | key    | key_len | ref    | rows   | Extra      |
    +----+-------------+--------+--------+---------------+--------+---------+--------+--------+------------+
    | 1  | SIMPLE      | <null> | <null> | <null>        | <null> | <null>  | <null> | <null> | Zero limit |
    +----+-------------+--------+--------+---------------+--------+---------+--------+--------+------------+
    ```
#### [爱可生开源社区：技术分享 | explain format=json 详解](https://mp.weixin.qq.com/s/enVUxwZrkw40XAtV_EeU2A)

#### 对比有无索引的执行计划

- 准备工作

```sql
-- 创建测试表
CREATE TABLE `t1` (
 `id` int NOT NULL auto_increment,
  `a` int DEFAULT NULL,
  `b` int DEFAULT NULL,
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '记录创建时间',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '记录更新时间',
  PRIMARY KEY (`id`),
  KEY `idx_a` (`a`),
  KEY `idx_b` (`b`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建存储过程。插入1000行数据
delimiter $$
create procedure insert_t1()
begin
  declare i int;
  set i=1;
  while(i<=1000)do
    insert into t1(a,b) values(i, i);
    set i=i+1;
  end while;
end$$
delimiter ;

-- 调用存储过程
call insert_t1();

-- 查看t1表
select count(*) from t1;
+----------+
| count(*) |
+----------+
| 1000     |
+----------+

-- 查看索引
show index from t1;
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+
| Table | Non_unique | Key_name | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Ignored |
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+
| t1    | 0          | PRIMARY  | 1            | id          | A         | 1000        | <null>   | <null> |      | BTREE      |         |               | NO      |
| t1    | 1          | idx_a    | 1            | a           | A         | 1000        | <null>   | <null> | YES  | BTREE      |         |               | NO      |
| t1    | 1          | idx_b    | 1            | b           | A         | 1000        | <null>   | <null> | YES  | BTREE      |         |               | NO      |
+-------+------------+----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+
```

- 对比有无索引的执行计划

- 条件字段是主键的执行计划

    ```sql
    explain select * from t1 where id=100;
    +----+-------------+-------+-------+---------------+---------+---------+-------+------+-------+
    | id | select_type | table | type  | possible_keys | key     | key_len | ref   | rows | Extra |
    +----+-------------+-------+-------+---------------+---------+---------+-------+------+-------+
    | 1  | SIMPLE      | t1    | const | PRIMARY       | PRIMARY | 4       | const | 1    |       |
    +----+-------------+-------+-------+---------------+---------+---------+-------+------+-------+
    ```

    - `type`是`const`：表示基于主键或唯一索引的查询
    - `key` 是`PRIMARY`：表示走了主键索引
    - `row` 表示扫描的行数：只扫描了一行。

- 条件字段有索引的执行计划

    ```sql
    explain select * from t1 where b=100;
    +----+-------------+-------+------+---------------+-------+---------+-------+------+-------+
    | id | select_type | table | type | possible_keys | key | key_len | ref | rows | Extra |
    +----+-------------+-------+------+---------------+-------+---------+-------+------+-------+
    | 1  | SIMPLE      | t1    | ref  | idx_b         | idx_b | 5       | const | 1    |       |
    +----+-------------+-------+------+---------------+-------+---------+-------+------+-------+
    ```

    - `type`是`ref`：表示基于普通索引的等值查询，或者表间等值连接
    - `key`：走了索引的。
    - `rows`：发现只扫描了1行

- 条件字段没索引的执行计划

    ```sql
    -- 删除b字段上的索引
    alter table t1 drop index idx_b;
    -- 再来看刚才这条语句的执行计划
    explain select * from t1 where b=100;
    +----+-------------+-------+------+---------------+--------+---------+--------+------+-------------+
    | id | select_type | table | type | possible_keys | key    | key_len | ref    | rows | Extra       |
    +----+-------------+-------+------+---------------+--------+---------+--------+------+-------------+
    | 1  | SIMPLE      | t1    | ALL  | <null>        | <null> | <null>  | <null> | 1000 | Using where |
    +----+-------------+-------+------+---------------+--------+---------+--------+------+-------------+
    ```

    - `type`是`ALL`：全表扫描。
    - `key`是`NULL`：没走索引。
    - `rows`这里其实是扫描了很多行：这里是估值，所以不一定准确。

- 获取正在执行语句的执行计划

- 这个通常用来分析正在执行的问题SQL。

```sql
-- 执行一条慢查询
select *,sleep(100) from t1 limit 1;

-- 在另外一次窗口查看当前连接
show processlist;
+----+------+-----------+--------+---------+------+------------+-------------------------------------+----------+
| Id | User | Host | db | Command | Time | State | Info | Progress |
+----+------+-----------+--------+---------+------+------------+-------------------------------------+----------+
| 4  | root | localhost | martin | Query   | 16   | User sleep | select *,sleep(100) from t1 limit 1 | 0.0      |
| 9  | root | localhost | martin | Query   | 0    | starting   | show processlist                    | 0.0      |
+----+------+-----------+--------+---------+------+------------+-------------------------------------+----------+

-- 再来查询给定连接的执行计划
EXPLAIN FOR CONNECTION 4;
+----+-------------+-------+------+---------------+--------+---------+--------+------+-------+
| id | select_type | table | type | possible_keys | key    | key_len | ref    | rows | Extra |
+----+-------------+-------+------+---------------+--------+---------+--------+------+-------+
| 1 | SIMPLE | t1 | ALL | <null> | <null> | <null> | <null> | 1000 |  |
+----+-------------+-------+------+---------------+--------+---------+--------+------+-------+
```

- 从MySQL 8.0.16开始，可以输出树状执行计划，并且能返回预估成本和预估的返回行数

```sql
explain format=tree select * from t1 where a=100;
```

- `cost`表示预估成本信息；
- `rows`表示预估扫描行数。


- 从MySQL 8.0.18开始，引入了EXPLAIN ANALYZE

- 使用这个，会执行SQL，并返回有关执行成本，返回行数，执行时间，循环次数等信息

```sql
explain analyze select * from t1 where a=100;
```

- `cost` 表示预估的成本信息
- `rows` 前面的表示预估值，后面的表示实际返回的行数
- `actual time` 第一个值是获取第一行的实际时间，第二个值获取所有行的时间，如果循环了多次就是平均时间，单位毫秒
- `loops` 循环次数

### 索引的分类

- [小林coding：什么是索引？](https://xiaolincoding.com/mysql/index/index_interview.html#%E4%BB%80%E4%B9%88%E6%98%AF%E7%B4%A2%E5%BC%95)

- 4个角度来分类索引。 
    - 数据结构：B+tree索引、Hash索引、Full-text索引。 
    - 物理存储：聚簇索引（主键索引）、二级索引（辅助索引）。 
    - 字段特性：主键索引、唯一索引、普通索引、前缀索引。
    - 字段个数：单列索引、联合索引。

- MySQL 中的索引可以分为以下几种类型：

    - 平衡树 (B-Tree) 索引 — 最常用的索引类型。此索引类型可以与使用 =、>、>=、<、<= 和 BETWEEN 关键字的搜索查询一起使用，也可以与 LIKE 查询一起使用。

    - 空间（R-Tree）索引——可以与 MySQL 几何数据类型一起使用来索引地理对象。

    - 哈希索引——通常仅用于使用 = 或 <=> 搜索运算符的查询。非常快，但只能在使用 MEMORY 存储引擎时使用。

    - 覆盖索引——覆盖完成查询所需的所有列的索引。

    - 聚集索引——此类索引存储行数据。通常PRIMARY KEY是 s 或，如果它们不存在，则为UNIQUE索引。

    - 多列（复合）索引——在多列上创建的索引。

    - 前缀索引——这样的索引只允许你索引列的前缀。由于此类索引不会索引列的完整值，因此它们经常用于节省空间。

#### 按数据结构分类

- [爱可生开源社区：第16期：索引设计（MySQL 的索引结构）](https://mp.weixin.qq.com/s?__biz=MzU2NzgwMTg0MA==&mid=2247490190&idx=1&sn=3e2a4e161017edb33ba36cdf10537d5d&chksm=fc96f811cbe17107deba66301b2788c2c32026249135dead9ce66b06355a4d863128ed068c59&cur_album_id=1338281900976472064&scene=189#wechat_redirect)

![image](./Pictures/mysql/index_存储引擎支持的数据结构索引.avif)

- 聚集索引（Clustered Index）：是指关系表记录的物理顺序与索引的逻辑顺序相同。由于一张表只能按照一种物理顺序存放，一张表最多也只能存在一个聚集索引。与非聚集索引相比，聚集索引有着更快的检索速度。

- 非聚集索引（Secondary Index）：指的是非叶子节点按照索引的键值顺序存放，叶子节点存放索引键值以及对应的主键键值。
    - MySQL 里除了 INNODB 表主键外，其他的都是二级索引。
        - MYISAM，memory 等引擎的表索引都是非聚集索引。简单点说，就是索引与行数据分开存储。一张表可以有多个二级索引。

- 创建的主键索引和二级索引**默认使用的是 B+Tree 索引**。

- 在创建表时，InnoDB 存储引擎会根据不同的场景选择不同的列作为索引：

    - 1.如果有主键：默认会使用主键作为`聚簇索引`（Clusered Index）的索引键（key）；
    - 2.如果没有主键：就选择第一个不包含 NULL 值的唯一列作为`聚簇索引`的索引键（key）；

    - 在上面两个都没有的情况下：InnoDB 会生成一个名为GEN_CLUST_INDEX 包含id值的隐藏列(`隐藏聚簇索引`)


    - 如果`聚簇索引`的值是非顺序的. 如`UUID`, 则会导致索引的插入完全随机:

        - 顺序的主键:每一条记录都存储在上一条记录的后面

            - 顺序写入会造成锁的竞争, 可通过variable [`innodb autoinc_lock_mode`](https://dev.mysql.com/doc/refman/8.0/en/innodb-auto-increment-handling.html)设置锁的并发度

                - 只能在auto-increment的索引上使用

                - 如果没有relication复制, 设置2

                    - 最大并发度, 但副本的auto-increment值未必不一致

                    - mysql 8.0:默认为2

                - 如果有relication复制, 设置0, 1

                    - mariadb 10.5.11-1:默认为1

        - 非顺序的主键:

            - 乱序写入, 有可能会在中间的页写入:

                - 写入的页可能已被移除缓存, 这需要从磁盘加载到内存, 会导致大量的随机io

                - 页分裂(page split):如果写入的页已满, 就会分裂成两个页

            - 可以使用以下命令优化表数据和索引数据, 避免随机io
                ```sql
                OPTIMIZE TABLE table_name
                ```


    - 其它索引都属于`辅助索引`（Secondary Index），也被称为二级索引或非聚簇索引。

- MYISAM 存储引擎表：

    - MYISAM 表是典型的数据与索引分离存储，主键和二级索引没有本质区别。比如在 MYISAM 表里主键、唯一索引是一样的，没有本质区别。

    - 假设表 t1 为 MYISAM 引擎，列为 ID，姓名，性别，年龄，手机号码。其中 ID 为主键，年龄为二级索引。记录如下：
        ![image](./Pictures/mysql/index_MYISAM存储引擎.avif)

    - 对应的两个 B+ 树索引如下图所示

        - 1.主键字段索引树：
            - 是一个 3 阶的 B+ 树，非叶子节点按照主键的值排序存储，叶子节点同样按照主键的值排序存储，并且包含指向磁盘上的物理数据行指针。
            ![image](./Pictures/mysql/index_MYISAM存储引擎1.avif)

        - 2.年龄字段索引树：
            - 同样是一个 3 阶的 B+ 树，非叶子节点按照年龄字段的值顺序存储，叶子节点保存年龄字段的值以及指向磁盘上的物理数据行指针。
            ![image](./Pictures/mysql/index_MYISAM存储引擎2.avif)

    - 从上面两张图可以看出，MYISAM 表的索引存储方式最大的缺点没有按照物理数据行顺序存储，这样无论对主键的检索还是对二级索引的检索都需要进行二次排序。

        ```sql
        -- 以下 SQL 1 默认没有排序，乱序输出；需要按照 ID 顺序输出，就得用 SQL 2，显式加 ORDER BY 。

        -- SQL 1
        SELECT * FROM t1;
        +-------+----------+--------+------+--------------+
        | id    | username | gender | age  | phone_number |
        +-------+----------+--------+------+--------------+
        | 10001 | 小花     | 女     |   18 | 18501877098  |
        | 10005 | 小李     | 女     |   21 | 15827654555  |
        | 10006 | 小白     | 男     |   38 | 19929933000  |
        | 10009 | 小何     | 男     |   35 | 19012378676  |
        | 10002 | 小王     | 男     |   20 | 17760500293  |
        | 10003 | 小赵     | 女     |   29 | 13581386000  |
        | 10004 | 小青     | 女     |   25 | 13456712000  |
        | 10007 | 小米     | 男     |   23 | 19800092354  |
        | 10008 | 小徐     | 女     |   22 | 18953209331  |
        +-------+----------+--------+------+--------------+

        -- SQL 2
        SELECT * FROM t1 ORDER BY id;
        +-------+----------+--------+------+--------------+
        | id    | username | gender | age  | phone_number |
        +-------+----------+--------+------+--------------+
        | 10001 | 小花     | 女     |   18 | 18501877098  |
        | 10002 | 小王     | 男     |   20 | 17760500293  |
        | 10003 | 小赵     | 女     |   29 | 13581386000  |
        | 10004 | 小青     | 女     |   25 | 13456712000  |
        | 10005 | 小李     | 女     |   21 | 15827654555  |
        | 10006 | 小白     | 男     |   38 | 19929933000  |
        | 10007 | 小米     | 男     |   23 | 19800092354  |
        | 10008 | 小徐     | 女     |   22 | 18953209331  |
        | 10009 | 小何     | 男     |   35 | 19012378676  |
        +-------+----------+--------+------+--------------+
        ```

- INNODB 存储引擎表：

    - INNODB 表本身是索引组织表，也就是说索引就是数据。下图表T1的数据行以聚簇索引的方式展示，非叶子节点保存了主键的值，叶子节点保存了主键的值以及对应的数据行，并且每个页有分别指向前后两页的指针。

    - INNODB 表不同于 MYISAM，INNODB 表有自己的数据页管理，默认 16KB。MYISAM 表数据的管理依赖文件系统，比如文件系统一般默认 4KB，MYISAM 的块大小也是 4KB，MYISAM 表的没有自己的一套崩溃恢复机制，全部依赖于文件系统。
        ![image](./Pictures/mysql/index_INNODB存储引擎.avif)

    - INNODB 表这样设计的优点有两个：

        - 1.数据按照主键顺序存储。主键的顺序也就是记录行的物理顺序，相比指向数据行指针的存放方式，避免了再次排序。我们知道，排序消耗最大。现在表 t1 的直接拿出来就是按照主键 ID 排序。
           ```sql
           SELECT * FROM t1;
           +-------+----------+--------+------+--------------+
           | id    | username | gender | age  | phone_number |
           +-------+----------+--------+------+--------------+
           | 10001 | 小花     | 女     |   18 | 18501877098  |
           | 10002 | 小王     | 男     |   20 | 17760500293  |
           | 10003 | 小赵     | 女     |   29 | 13581386000  |
           | 10004 | 小青     | 女     |   25 | 13456712000  |
           | 10005 | 小李     | 女     |   21 | 15827654555  |
           | 10006 | 小白     | 男     |   38 | 19929933000  |
           | 10007 | 小米     | 男     |   23 | 19800092354  |
           | 10008 | 小徐     | 女     |   22 | 18953209331  |
           | 10009 | 小何     | 男     |   35 | 19012378676  |
           +-------+----------+--------+------+--------------+
           ```

        - 2.两个叶子节点分别含有指向前后两个节点的指针，这样在插入新行或者进行页分裂时，只需要移动对应的指针即可。

    - INNODB 表的二级索引

        ![image](./Pictures/mysql/index_INNODB存储引擎1.avif)

        - INNODB 二级索引的非叶子节点保存索引的字段值，上图索引为表 t1 的字段 age。叶子节点含有索引字段值和对应的主键值。

            - 优点：当出现数据行移动或者数据页分裂时，避免二级索引不必要的维护工作。当数据需要更新的时候，二级索引不需要重建，只需要修改聚簇索引即可。

            - 缺点：
                - 1.二级索引由于同时保存了主键值，体积会变大。特别是主键设计不合理的时候，比如用 UUID 做主键。

                - 2.对二级索引的检索需要检索两次索引树。
                    - 第一次通过检索二级索引叶子节点，找到过滤行对应的主键值；
                    - 第二次通过这个主键的值去聚簇索引中查找对应的行。

                    ```sql
                    -- 如下 SQL 语句，检索年龄为 23 的行记录：
                    SELECT * FROM t1 WHERE age = 23;
                    -- 会拆分成以下两个 SQL 语句：
                    -- 1.先通过索引字段 age 找到对应的主键值：10005.
                    SELECT id FROM t1 WHERE age=23;
                    -- 2.再去聚簇索引上根据主键 ID = 10005 检索到需要的数据行，如果表第一次读取，就需要回表。
                    SELECT * FROM t1 WHERE id = 10005;
                    ```

##### 例子：先创建一张商品表，id 为主键

```sql
CREATE TABLE `product`  (
`id` int(11) NOT NULL,
`product_no` varchar(20)  DEFAULT NULL,
`name` varchar(255) DEFAULT NULL,
`price` decimal(10, 2) DEFAULT NULL,
PRIMARY KEY (`id`) USING BTREE
) CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;
```

- 商品表里，有这些行数据：
    ![image](./Pictures/mysql/index_存储引擎支持的数据结构索引-例子.avif)

- 二级索引的 B+Tree长的样子
    - 实际上是双向链表
    - 其中非叶子的 key 值是 product_no（图中橙色部分），叶子节点存储的数据是主键值（图中绿色部分）。
    ![image](./Pictures/mysql/index_B+树.avif)

    - B+Tree 是一种多叉树：
        - 叶子节点才存放数据，非叶子节点只存放索引
        - 每个节点里的数据是按主键顺序存放的。
        - 每一层父节点的索引值都会出现在下层子节点的索引值中，因此在叶子节点中，包括了所有的索引值信息，并且每一个叶子节点都有两个指针，分别指向下一个叶子节点和上一个叶子节点，形成一个双向链表。

    - 例子

        ```sql
        select * from product where product_no = '0002';
        ```

        - 会先检二级索引中的 B+Tree 的索引值（商品编码，product_no），找到对应的叶子节点，然后获取主键值，然后再通过主键索引中的 B+Tree 树查询到对应的叶子节点，然后获取整行数据。这个过程叫「回表」，也就是说要查两个 B+Tree 才能查到数据。

        ![image](./Pictures/mysql/index_B+树-回表.avif)

##### 为什么 MySQL InnoDB  选择 B+tree 作为索引的数据结构？

- 1.B+Tree vs B Tree
    - B+Tree 只在叶子节点存储数据，而 B 树 的非叶子节点也要存储数据，所以 B+Tree 的单个节点的数据量更小，在相同的磁盘 I/O 次数下，就能查询更多的节点。 
        - 另外，B+Tree 叶子节点采用的是双链表连接，适合 MySQL 中常见的基于范围的顺序查找，而 B 树无法做到这一点。

- 2.B+Tree vs 二叉树
    - 对于有 N 个叶子节点的 B+Tree，其搜索复杂度为O(logdN)，其中 d 表示节点允许的最大子节点个数为 d 个。
    - 在实际的应用当中， d 值是大于100的，这样就保证了，即使数据达到千万级别时，B+Tree 的高度依然维持在 3-4 层左右，也就是说一次数据查询操作只需要做 3-4 次的磁盘 I/O 操作就能查询到目标数据。 
        - 而二叉树的每个父节点的儿子节点个数只能是 2 个，意味着其搜索复杂度为 O(logN)，这已经比 B+Tree 高出不少，因此二叉树检索到目标数据所经历的磁盘 I/O 次数要更多。

- 3.B+Tree vs Hash
    - Hash 在做等值查询的时候效率贼快，搜索复杂度为 O(1)。
        - 但是 Hash 表不适合做范围查询，它更适合做等值的查询，这也是 B+Tree 索引要比 Hash 表索引有着更广泛的适用场景的原因。

##### HASH INDEX（哈希索引）

- 只有所有列全匹配才有效:

  - 假设索引为`key(last_name, first_name, date)`, 那么查询时如果只有`last_name`, 则无法使用索引

- 仅适用于 MEMORY 存储引擎。

- 支持比较查询`=, IN(), <=>`.注意<>和<=>是不同操作

  - 不支持范围查询`where price > 100`

- hash index只包含哈希值, 行指针, 不存储字段值

- hash冲突很多的话, 需要遍历链表, 更高的操作代价

- 创建索引
    ```sql
    -- USING HASH查询末尾的选项
    CREATE INDEX idx_name ON demo_table (demo_column) USING HASH;
    ```

- 假设索引为`key(last_name)`. hash函数f(), 返回以下值:

    ```
    f('Jobs') = 2333
    f('王') = 6666
    ```

    | slot(桶) | value(值)     |
    |----------|---------------|
    | 2333     | 指向第1行指针 |
    | 6666     | 指向第2行指针 |

    - 假设查询last_name为'Jobs':
        ```sql
        SELECT * FROM index_test
        WHERE last_name = 'Jobs'
        ```

        - 1.先计算Jobs的hash

        - 2.查找hash对应的桶2333, 找到指向第1行指针

        - 3.判断第1行指针是否为Jobs, 防止hash冲突

###### 自适应哈希(adaptive hash index)

- innodb的一个特殊功能, 但某些索引值操作比较频繁时, 会在内存中基于B+树之上创建hash索引

- 如果存储引擎不支持自适应哈希, 也可以自己模拟:

    - 创建一个在B+树上的伪哈希索引. 依然是在B+树上查询, 但使用hash代替值查询:
        ```sql
        CREATE table hash_test (
            id INT UNSIGNED NOT NULL AUTO_INCREMENT,
            url varchar(255) NOT NULL,
            url_crc INT UNSIGNED NOT NULL DEFAULT 0, --哈希为int类型
            PRIMARY KEY(id)
        );
        ```
    - 创建INSERT, UPDATE的触发器, 使用`CRC32()`函数:

        - 注意:不要使用SHA1(), MD5(), 这类hash是强加密函数, 生成非常长字符串, 会浪费大量空间, 比较时也慢

        ```sql
        DELIMITER //

        CREATE TRIGGER hash_test_crc_in BEFORE INSERT ON hash_test FOR EACH ROW BEGIN SET NEW.url_crc=crc32(NEW.url);
        END;
        //

        CREATE TRIGGER hash_test_crc_up BEFORE UPDATE ON hash_test FOR EACH ROW BEGIN SET NEW.url_crc=crc32(NEW.url);
        END;
        //

        DELIMITER ;
        ```

    - 测试:
        ```sql
        INSERT INTO hash_test(url) VALUES
        ('http://www.mysql.com');

        INSERT INTO hash_test(url) VALUES
        ('http://www.mariadb.com');

        SELECT * FROM hash_test
        ```
        ![image](./Pictures/mysql/hash_test.avif)

    - 防止hash值冲突, 需要加上`AND url = `:
        ```sql
        SELECT * FROM hash_test
        WHERE url_crc = CRC32('http://www.mysql.com')
        AND url = 'http://www.mysql.com'
        ```

    - `CRC32()`是32位的, 可以自定义一个64位hash函数:
        ```sql
        SELECT CONV(RIGHT(MD5('http://www.mysql.com/'), 16), 16, 10) AS HASH64
        ```

##### 空间索引（R-Tree 索引）

- 用于访问空间（地理）对象——要使用这些索引，你必须使用 MySQL 提供的 GIS 函数：其中一些函数包括`MBRContains`、`MBRCovers`或`MBREquals`

- 创建索引

    ```sql
    -- 需要SPATIAL关键字
    CREATE SPATIAL INDEX spatial_idx ON demo_table (demo_column);
    ALTER TABLE demo_table ADD SPATIAL INDEX(spatial_idx);
    ```

- 使用此类索引的查询示例：

    ```sql
    -- 在使用类似variable_1或variable_2任何容量的变量之前，你应该首先定义它们（该WKT value参数表示代表几何对象的众所周知的文本格式值）：
    SET @variable_1 = ST_GeomFromText('WKT value');

    -- 查询示例
    SELECT MBRContains(@variable_1, @variable_2);
    SELECT MBRWithin(@variable_2, @variable_1);
    ```


#### 按字段特性分类

- 1.主键索引：就是建立在主键字段上的索引，通常在创建表的时候一起创建，一张表最多只有一个主键索引，索引列的值不允许有空值。

    - 在创建表时，创建主键索引的方式如下：

        ```sql
        CREATE TABLE table_name  (
        ....
        PRIMARY KEY (index_column_1) USING BTREE
        );
        ```

- 2.唯一索引：建立在 UNIQUE 字段上的索引，一张表可以有多个唯一索引，索引列的值必须唯一，但是允许有空值。

    - 在创建表时，创建主键索引的方式如下：
        ```sql
        CREATE TABLE table_name  (
        ....
        UNIQUE KEY(index_column_1,index_column_2,...) 
        );
        ```

    - 建表后，如果要创建唯一索引，可以使用这面这条命令：

        ```sql
        CREATE UNIQUE INDEX index_name
        ON table_name(index_column_1,index_column_2,...); 
        ```

- 3.普通索引：普通索引就是建立在普通字段上的索引，既不要求字段为主键，也不要求字段为 UNIQUE。

    - 在创建表时，创建普通索引的方式如下：

        ```sql
        CREATE TABLE table_name  (
        ....
        INDEX(index_column_1,index_column_2,...) 
        );
        ```

    - 建表后，如果要创建普通索引，可以使用这面这条命令：

        ```sql
        CREATE INDEX index_name
        ON table_name(index_column_1,index_column_2,...); 
        ```

- 4.前缀索引
    - 前缀索引是指对字符类型字段的前几个字符建立的索引，而不是在整个字段上建立的索引，前缀索引可以建立在字段类型为 char、 varchar、binary、varbinary 的列上。
    - 使用前缀索引的目的是为了减少索引占用的存储空间，提升查询效率。

    - 在创建表时，创建前缀索引的方式如下：

        ```sql
        CREATE TABLE table_name(
        column_list,
        INDEX(column_name(length))
        ); 
        ```

    - 建表后，如果要创建前缀索引，可以使用这面这条命令：

        ```sql
        CREATE INDEX index_name
        ON table_name(column_name(length)); 
        ```

#### 按字段个数分类

建立在单列上的索引称为单列索引，比如主键索引；
建立在多列上的索引称为联合索引（二级索引）；

- 联合索引

    - 商品表中的 product_no 和 name 字段组合成联合索引(product_no, name)，创建联合索引的方式如下：

        ```sql
        CREATE INDEX index_product_no_name ON product(product_no, name);
        ```

    - 联合索引`(product_no, name)` 的 B+Tree 示意图如下（图中叶子节点之间实际上是双向链表）。

        ![image](./Pictures/mysql/index_联合索引.avif)

        - 联合索引的非叶子节点用两个字段的值作为  B+Tree 的 key 值。当在联合索引查询数据时先按 product_no 字段比较，在 product_no 相同的情况下再按 name 字段比较。

        - 也就是说，联合索引查询的 B+Tree 是先按 product_no 进行排序，然后再 product_no 相同的情况再按 name 字段排序。

        - 因此，使用联合索引时，存在**最左匹配原则**，也就是按照最左优先的方式进行索引的匹配。在使用联合索引进行查询的时候，如果不遵循「最左匹配原则」，联合索引会失效，这样就无法利用到索引快速查询的特性了。

- 索引区分度：建立联合索引时的字段顺序，对索引效率也有很大影响。越靠前的字段被用于索引过滤的概率越高，实际开发工作中建立联合索引时，要把区分度大的字段排在前面，这样区分度大的字段越有可能被更多的 SQL 使用到。

    - 区分度就是某个字段 column 不同值的个数「除以」表的总行数，计算公式如下：`区分度 = dinstinct(coolumn) / count(*)`

    - 例子：
       - 性别的区分度就很小，不适合建立索引或不适合排在联合索引列的靠前的位置
       - UUID 这类字段就比较适合做索引或排在联合索引列的靠前的位置。

    - 因为如果索引的区分度很小，假设字段的值分布均匀，那么无论搜索哪个值都可能得到一半的数据。在这些情况下，还不如不要索引，因为 MySQL 还有一个查询优化器，查询优化器发现某个值出现在表的数据行中的百分比（惯用的百分比界线是"30%"）很高的时候，它一般会忽略索引，进行全表扫描。

##### 联合索引（二级索引）匹配

- 创建了一个 (a, b, c) 联合索引

    - 如果查询条件符合最左匹配原则，就可以匹配上联合索引：

        - `where a=1`
        - `where a=1 and b=2 and c=3`
        - `where a=1 and b=2`
        - 需要注意的是，因为有查询优化器，所以 a 字段在 where 子句的顺序并不重要。

    - 如果查询条件不符合最左匹配原则，联合索引失效：
        - `where b=2`
        - `where c=3`
        - `where b=2 and c=3` 

        - 这些查询条件之所以会失效，是因为(a, b, c) 联合索引，是先按 a 排序，在 a 相同的情况再按 b 排序，在 b 相同的情况再按 c 排序。所以，b 和 c 是全局无序，局部相对有序的，这样在没有遵循最左匹配原则的情况下，是无法利用到索引的。

    - 重复索引:如果有索引(a, b, c), 就没有必要再创建(a)索引, 如发现重复索引可以立即删除

- 创建测试表

    ```sql
    CREATE table index_test (
        last_name varchar(50),
        first_name varchar(50),
        date DATE
    );

    INSERT INTO index_test VALUES
    ('Jobs', 'Steve', '1955-2-24'),
    ('王', '小二', '2021-7-10');

    -- 创建联合索引
    ALTER TABLE index_test
    ADD KEY(last_name, first_name, date);

    -- 查看表的所有索引
    show index from index_test
    +------------+------------+-----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+
    | Table      | Non_unique | Key_name  | Seq_in_index | Column_name | Collation | Cardinality | Sub_part | Packed | Null | Index_type | Comment | Index_comment | Ignored |
    +------------+------------+-----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+
    | index_test | 1          | last_name | 1            | last_name   | A         | 2           | <null>   | <null> | YES  | BTREE      |         |               | NO      |
    | index_test | 1          | last_name | 2            | first_name  | A         | 2           | <null>   | <null> | YES  | BTREE      |         |               | NO      |
    | index_test | 1          | last_name | 3            | date        | A         | 2           | <null>   | <null> | YES  | BTREE      |         |               | NO      |
    +------------+------------+-----------+--------------+-------------+-----------+-------------+----------+--------+------+------------+---------+---------------+---------+
    ```

- 最左匹配:

    - 1.只匹配第一列`last_name`
        ```sql
        EXPLAIN SELECT * FROM index_test
        WHERE last_name='Jobs'
        +----+-------------+------------+------+---------------+-----------+---------+-------+------+--------------------------+
        | id | select_type | table      | type | possible_keys | key       | key_len | ref   | rows | Extra                    |
        +----+-------------+------------+------+---------------+-----------+---------+-------+------+--------------------------+
        | 1  | SIMPLE      | index_test | ref  | last_name     | last_name | 203     | const | 1    | Using where; Using index |
        +----+-------------+------------+------+---------------+-----------+---------+-------+------+--------------------------+
        ```

    - 2.只匹配`last_name`前缀以`J`开头的
        ```sql
        EXPLAIN SELECT * FROM index_test
        WHERE last_name LIKE 'J%'
        +----+-------------+------------+-------+---------------+-----------+---------+--------+------+--------------------------+
        | id | select_type | table      | type  | possible_keys | key       | key_len | ref    | rows | Extra                    |
        +----+-------------+------------+-------+---------------+-----------+---------+--------+------+--------------------------+
        | 1  | SIMPLE      | index_test | range | last_name     | last_name | 203     | <null> | 1    | Using where; Using index |
        +----+-------------+------------+-------+---------------+-----------+---------+--------+------+--------------------------+
        ```

    - 3.按顺序从左到右匹配如:`(last_name, first_name)`, `(last_name, first_name, date)`

        ```sql
        EXPLAIN SELECT * FROM index_test
        WHERE last_name='Jobs'
        AND first_name = 'Steve'
        AND date = '1955-2-24'
        +----+-------------+------------+------+---------------+-----------+---------+-------------------+------+--------------------------+
        | id | select_type | table      | type | possible_keys | key       | key_len | ref               | rows | Extra                    |
        +----+-------------+------------+------+---------------+-----------+---------+-------------------+------+--------------------------+
        | 1  | SIMPLE      | index_test | ref  | last_name     | last_name | 410     | const,const,const | 1    | Using where; Using index |
        +----+-------------+------------+------+---------------+-----------+---------+-------------------+------+--------------------------+
        ```

        - **不能**跨过中间的列进行匹配如:`(last_name, date)`

            ```sql
            -- ??可以
            EXPLAIN SELECT * FROM index_test
            WHERE date = '1955-2-24'
            AND last_name='Jobs'
            +----+-------------+------------+------+---------------+-----------+---------+-------+------+--------------------------+
            | id | select_type | table      | type | possible_keys | key       | key_len | ref   | rows | Extra                    |
            +----+-------------+------------+------+---------------+-----------+---------+-------+------+--------------------------+
            | 1  | SIMPLE      | index_test | ref  | last_name     | last_name | 203     | const | 1    | Using where; Using index |
            +----+-------------+------------+------+---------------+-----------+---------+-------+------+--------------------------+
            ```

- 范围匹配:

    - 范围查询的字段可以用到联合索引，但是在范围查询字段的后面的字段无法用到联合索引

        - 尽可能使用`IN()` 代替范围查询, `IN()` 是多个等值查询依然可以使用索引

    - 联合索引`(a, b)`哪一个字段用到了联合索引的 B+Tree？

        ```sql
        explain select * from t_table where a > 1 and b = 2
        ```

        - 答案：只有 a 字段用到了联合索引进行索引查询，而 b 字段并没有使用到联合索引
            - 执行计划中 key_len 知道这一点，在使用联合索引进行查询的时候，通过 key_len 我们可以知道优化器具体使用了多少个字段的搜索条件来形成扫描区间的边界条件。
                - 举例个例子 a 和 b 都是 int 类型且不为 NULL 的字段，那么 Q1 这条查询语句执行计划如下，可以看到 key_len 为 4 字节（如果字段允许为 NULL，就在字段类型占用的字节数上加 1，也就是 5 字节），说明只有 a 字段用到了联合索引进行索引查询，而且可以看到，即使 b 字段没用到联合索引，key 为 idx_a_b，说明  Q1 查询语句使用了 idx_a_b 联合索引。

    - 联合索引`(a, b)`哪一个字段用到了联合索引的 B+Tree？
        ```sql
        explain select * from t_table where a >= 1 and b = 2，
        ```
        - 答案：这条查询语句 a 和 b 字段都用到了联合索引进行索引查询
            - 对于符合 a = 1 的二级索引记录的范围里，b 字段的值是「有序」的
            - 我们也可以在执行计划中的 key_len 知道这一点。执行计划如下，可以看到 key_len 为 8 字节，说明优化器使用了 2 个字段的查询条件来形成扫描区间的边界条件，也就是  a 和 b 字段都用到了联合索引进行索引查询。

    - 联合索引`(a, b)`哪一个字段用到了联合索引的 B+Tree？
        ```sql
        SELECT * FROM t_table WHERE a BETWEEN 2 AND 8 AND b = 2
        ```
        - 答案：这条查询语句 a 和 b 字段都用到了联合索引进行索引查询
            - `a BETWEEN 2 AND 8` 的意思是查询 a 字段的值在 2 和 8 之间的记录。不同的数据库对 BETWEEN ... AND 处理方式是有差异的。在 MySQL 中，BETWEEN 包含了 value1 和 value2 边界值，类似于 >= and =<。而有的数据库则不包含 value1 和 value2 边界值（类似于 > and <）。
            - 虽然 a 字段使用了 BETWEEN 进行范围查询，但是联合索引的最左匹配原则并没有在遇到 a 字段的范围查询（ BETWEEN）后就停止匹配了，b 字段还是可以用到了联合索引的。
            - 我们也可以在执行计划中的 key_len 知道这一点。执行计划如下，可以看到 key_len 为 8 字节，说明优化器使用了 2 个字段的查询条件来形成扫描区间的边界条件，也就是  a 和 b 字段都用到了联合索引进行索引查询。

    - 联合索引`(name, age)`哪一个字段用到了联合索引的 B+Tree？

        ```sql
        SELECT * FROM t_user WHERE name like 'j%' and age = 22
        ```
    - 答案：这条查询语句 name 和 age 字段都用到了联合索引进行索引查询
        - 由于联合索引（二级索引）是先按照 name 字段的值排序的，所以前缀为 ‘j’ 的 name 字段的二级索引记录都是相邻的， 于是在进行索引扫描的时候，可以定位到符合前缀为 ‘j’ 的 name 字段的第一条记录，然后沿着记录所在的链表向后扫描，直到某条记录的 name 前缀不为 ‘j’  为止。

            ![image](./Pictures/mysql/index_联合索引-范围查询.avif)

        - 虽然在符合前缀为 ‘j’ 的 name 字段的二级索引记录的范围里，age 字段的值是「无序」的，但是对于符合 name = j 的二级索引记录的范围里，age字段的值是「有序」的（因为对于联合索引，是先按照 name 字段的值排序，然后在 name 字段的值相同的情况下，再按照 age 字段的值进行排序）。
            - 于是，在确定需要扫描的二级索引的范围时，当二级索引记录的 name 字段值为 ‘j’ 时，可以通过 age = 22 条件减少需要扫描的二级索引记录范围（age 字段可以利用联合索引进行索引查询的意思）。也就是说，从符合 name = 'j' and age = 22 条件的第一条记录时开始扫描，而不需要从第一个 name 为 j 的记录开始扫描 。如下图的右边：
            ![image](./Pictures/mysql/index_联合索引-范围查询1.avif)

        - 我们也可以在执行计划中的 key_len 知道这一点。本次例子中：
            - name 字段的类型是 varchar(30) 且不为 NULL，数据库表使用了 utf8mb4 字符集，一个字符集为 utf8mb4 的字符是 4 个字节，因此 name 字段的实际数据最多占用的存储空间长度是 120 字节（30 x 4），然后因为 name 是变长类型的字段，需要再加 2 字节（用于存储该字段实际数据的长度值），也就是 name 的 key_len 为 122。
            - age 字段的类型是 int 且不为 NULL，key_len 为 4。

- 排序匹配:

    - 1.和上面例子一样适用于最左匹配和范围匹配原则:

        ```sql
        EXPLAIN SELECT last_name FROM index_test
        ORDER BY last_name, first_name, date;
        +----+-------------+------------+-------+---------------+-----------+---------+--------+------+-------------+
        | id | select_type | table      | type  | possible_keys | key       | key_len | ref    | rows | Extra       |
        +----+-------------+------------+-------+---------------+-----------+---------+--------+------+-------------+
        | 1  | SIMPLE      | index_test | index | <null>        | last_name | 410     | <null> | 2    | Using index |
        +----+-------------+------------+-------+---------------+-----------+---------+--------+------+-------------+
        ```

        - 列的顺序可以从where子句开始:
            ```sql
            EXPLAIN SELECT last_name FROM index_test
            WHERE last_name = 'Jobs'
            ORDER BY first_name, date;

            +----+-------------+------------+------+---------------+-----------+---------+-------+------+--------------------------+
            | id | select_type | table      | type | possible_keys | key       | key_len | ref   | rows | Extra                    |
            +----+-------------+------------+------+---------------+-----------+---------+-------+------+--------------------------+
            | 1  | SIMPLE      | index_test | ref  | last_name     | last_name | 203     | const | 1    | Using where; Using index |
            +----+-------------+------------+------+---------------+-----------+---------+-------+------+--------------------------+
            ```

    - 2.降序`desc`, 依然能使用索引:
        ```sql
        EXPLAIN SELECT last_name from index_test
        ORDER BY last_name DESC, first_name DESC, date DESC;
        +----+-------------+------------+-------+---------------+-----------+---------+--------+------+-------------+
        | id | select_type | table      | type  | possible_keys | key       | key_len | ref    | rows | Extra       |
        +----+-------------+------------+-------+---------------+-----------+---------+--------+------+-------------+
        | 1  | SIMPLE      | index_test | index | <null>        | last_name | 410     | <null> | 2    | Using index |
        +----+-------------+------------+-------+---------------+-----------+---------+--------+------+-------------+
        ```

        - 但如果有两种不同排序方向, 则不能使用索引:

            - Extra字段为`Using filesort`:表示不能使用索引, 需要自己排序, 数据量小则会在内存, 大则会在磁盘
                - 排序是成本很高的操作, 尽量避免对大量数据排序

            ```sql
            EXPLAIN SELECT last_name FROM index_test
            ORDER BY last_name ASC, first_name ASC, date DESC\G;
            -- 两条语句一样
            EXPLAIN SELECT last_name FROM index_test
            ORDER BY last_name, first_name, date DESC\G;

            ***************************[ 1. row ]***************************
            id            | 1
            select_type   | SIMPLE
            table         | index_test
            type          | index
            possible_keys | <null>
            key           | last_name
            key_len       | 410
            ref           | <null>
            rows          | 2
            Extra         | Using index; Using filesort
            ```


##### 索引下推（Using index condition）

- 现在我们知道，对于联合索引`(a, b)`，在执行 `select * from table where a > 1 and b = 2` 语句的时候，只有 a 字段能用到索引，那在联合索引的 B+Tree 找到第一个满足条件的主键值（ID 为 2）后，还需要判断其他条件是否满足（看 b 是否等于 2），那是在联合索引里判断？还是回主键索引去判断呢？

    - 在 MySQL 5.6 之前，只能从 ID2 （主键值）开始一个个回表，到「主键索引」上找出数据行，再对比 b 字段值。

    - 而 MySQL 5.6 引入的索引下推优化（index condition pushdown)， 可以在联合索引遍历过程中，对联合索引中包含的字段先做判断，直接过滤掉不满足条件的记录，减少回表次数。

- 当你的查询语句的`explain`执行计划里，出现了  `Extra` 为 `Using index condition`，那么说明使用了索引下推的优化。

### 索引优化

- 几种常见优化索引的方法：
    - 主键索引最好是自增的
    - 前缀索引优化
    - 覆盖索引优化
    - 索引最好设置为 `NOT NULL`
    - 防止索引失效

- 前缀索引优化：

    - 优点：使用前缀索引是为了减小索引字段大小，可以增加一个索引页中存储的索引值，有效提高索引的查询速度。在一些大字符串的字段作为索引时，使用前缀索引可以帮助我们减小索引项的大小。

    - 缺点：
        - order by 就无法使用前缀索引；
        - 无法把前缀索引用作覆盖索引；

- 覆盖索引优化

    - 覆盖索引是指 SQL 中 query 的所有字段，在索引 B+Tree  的叶子节点上都能找得到的那些索引，从二级索引中查询得到记录，而**不需要通过聚簇索引查询获得**，可以避免回表的操作。

    - 假设我们只需要查询商品的名称、价格，有什么方式可以避免回表呢？
        - 我们可以建立一个联合索引，即「商品ID、名称、价格」作为一个联合索引。如果索引中存在这些数据，查询将不会再次检索主键索引，从而避免回表。

    - 所以，使用覆盖索引的好处就是，不需要查询出包含整行记录的所有信息，也就减少了大量的 I/O 操作。

- 索引最好设置为 `NOT NULL`
    - 1.索引列存在 NULL 就会导致优化器在做索引选择的时候更加复杂，更加难以优化，因为可为 NULL 的列会使索引、索引统计和值比较都更复杂，比如进行索引统计时，count 会省略值为NULL 的行。
    - 2.NULL 值是一个没意义的值，但是它会占用物理空间，所以会带来的存储空间的问题，因为 InnoDB 存储记录的时候，如果表中存在允许为 NULL 的字段，那么行格式  (opens new window)中至少会用 1 字节空间存储 NULL 值列表，如下图的紫色部分：

#### 主键设计原则

- 表的主键指的针对一张表中的一列或者多列，其结果必须能标识表中每行记录的唯一性。InnoDB 表是索引组织表，主键既是数据也是索引。

- 主键的设计原则
    - 1.对空间占用要小
        - 主键占用空间越小，每个索引页里存放的键值越多，这样一次性放入内存的数据也就越多。
    - 2.最好是有一定的排序属性
        - 如 INT32 类型来做主键，数值有严格的排序，那新记录的插入只要往原先数据页后面添加新记录或者在数据页后新增空页来填充记录即可，这样有严格排序的主键写入速度也会非常快。
    - 3.数据类型为整型
        - 数据类型早就已经讲过，按照前两点的需求，最理想的当然是选择整数类型，比如 int32 unsigned。数据顺序增长，要么是数据库自己生成，要么是业务自动生成。

- 与业务无关的属性做主键

    - 1.自增字段做主键
        - 这是 MySQL 最推荐的方式。一般用 INT32 可以满足大部分场景，单库单表可以最大保存 42 亿行记录；含有自增字段的新增记录会顺序添加到当前索引节点的后续位置直到数据页写满为止，再写新页。这样会极大程度的减少数据页的随机 IO。

    - 用自增字段做主键可能需要注意两个问题：

        - 1.MySQL 原生自增键拆分
            - 如果随着数据后期增长，有拆库拆表预期，可以考虑用 INT64
            - MySQL 原生支持拆库拆表的自增主键，通过自增步长与起始值来确定。最少要有 2 个 MySQL 节点，每个节点自增步长为 2，假设 server_id 分别为 1，2，那自增起始值也可以是 1，2。

            - 假设下面是第 1 个 MySQL 节点
            ```sql
            -- 设置步长
            set @@auto_increment_increment=2;
            -- 设置自增起始值
            set @@auto_increment_offset=1;

            -- 插入3行
            insert into tmp values(null),(null),(null);
            select * from tmp;
            +----+
            | id |
            +----+
            |  1 |
            |  3 |
            |  5 |
            +----+

            -- 但是这块 MySQL 并不能保证其他的值不冲突，比如插入一条节点 2 的值，也能成功插入，MySQL 默认对这块没有什么约束，最好是数据入库前就校验好。
            INSERT INTO tmp VALUES(2);
            SELECT * FROM tmp;
            +----+
            | id |
            +----+
            |  1 |
            |  2 |
            |  3 |
            |  5 |
            +----+
            ```

        - 2.MySQL 自增键合并

            - 这个问题一般牵扯到老的系统改造升级，比如多个分部老系统数据要向新系统合并，那之前每个分部的自增主键不能简单的合并，可能会有主键冲突。

            - 例子：假设武汉市每个区都有自己的医保数据，并且以前每个区都是自己独立设计的数据库，现在医保要升级为全市统一，以市为单位设计新的数据库模型。

                ```sql
                -- 武昌的数据如下，对应表 n1，
                SELECT  * FROM n1;
                +----+
                | id |
                +----+
                |  1 |
                |  2 |
                |  3 |
                +----+

                -- 汉阳的数据如下，对应表 n2，
                SELECT * FROM n2;
                +----+
                | id |
                +----+
                |  1 |
                |  2 |
                |  3 |
                +----+
                ```

            - 由于之前两个区数据库设计的人都没有考虑以后合并的事情，所以每个区的表都有自己独立的自增主键，

                - 考虑这样建立一张汇总表 n3，有新的自增 ID，并且设计导入老系统的 ID。

                ```sql
                CREATE TABLE n3 (id int auto_increment primary key, old_id int);

                INSERT INTO n3 (old_id) SELECT * FROM n1 UNION ALL SELECT * FROM n2;

                SELECT * FROM n3;
                +----+--------+
                | id | old_id |
                +----+--------+
                |  1 |      1 |
                |  2 |      2 |
                |  3 |      3 |
                |  4 |      1 |
                |  5 |      2 |
                |  6 |      3 |
                +----+--------+
                ```

            - 这样进行汇总， 应用代码可能不太确定怎么连接老的数据，这张表缺少一个 old_id 到原始表名的映射。

                - 那基于原始表 ID 与原始表名的映射关系建立一个多值索引。
                ```sql
                CREATE TABLE n4(old_id int, old_name varchar(64),primary key(old_id,old_name));
                INSERT INTO n4 SELECT id ,'n1' FROM n1 UNION ALL SELECT id,'n2' FROM n2;

                SELECT * FROM n4;
                +--------+----------+
                | old_id | old_name |
                +--------+----------+
                |      1 | n1       |
                |      1 | n2       |
                |      2 | n1       |
                |      2 | n2       |
                |      3 | n1       |
                |      3 | n2       |
                +--------+----------+
                ```

            - 最终表结构，结合前面两张表 n3 和 n4，建立一个包含新的自增字段主键，原来表 ID，原来表名的新表：
            ```sql
            CREATE TABLE n5(
                id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
                old_id INT,
                old_name VARCHAR(64),
                UNIQUE KEY udx_old_id_old_name (old_id,old_name)
            );
            ```

    - 2.UUID 做主键

        - UUID 和自增主键一样，能保证主键的唯一性。但是天生无序、随机产生、占用空间大。

        - 函数 uuid_to_bin：mysql8.0新增的函数，把 UUID 字符串变为 16 个字节的二进制串。

            ```sql
            CREATE TABLE t_binary(id VARBINARY(16) PRIMARY KEY,r1 INT, KEY idx_r1(r1));

            INSERT INTO t_binary VALUES
            (uuid_to_bin(uuid()),1),(uuid_to_bin(uuid()),2);

            SELECT * FROM t_binary;
            +------------------------------------+------+
            | id                                 | r1   |
            +------------------------------------+------+
            | 0x412234A77DEF11EA9AF9080027C52750 |    1 |
            | 0x412236E27DEF11EA9AF9080027C52750 |    2 |
            +------------------------------------+------+
            ```

        - 函数 `uuid_short`：用来生成类似 UUID 的全局 ID，结果为 INT64。

            - 具体计算方式如下：`(server_id & 255) << 56 + (server_startup_time_in_seconds << 24) + incremented_variable++;`
                - server_id & 255：占 1 个字节；
                - server_startup_time_in_seconds：占 4 个字节；
                - incremented_variable: 占 3 个字节。

            - 如果满足以下条件，那这个值就必定是唯一的
                - 1.server_id 唯一并且对函数 uuid_short() 的调用次数不超过每秒 16777216 次，也就是 2^24。所以一般情况下，uuid_short 函数能保证结果唯一。
                - 2.uuid_short 函数生成的 ID 只需一个轻量级的 mutex 来保护，这点比自增 ID 需要的 auto-inc 表锁更省资源，生成结果肯定更加快速。

            - 如果每秒调用次数少于 16777216，推荐用 uuid_short，而非自增 ID。

            ```sql
            CREATE TABLE t_uuid_short  (id BIGINT UNSIGNED PRIMARY KEY,r1 INT, KEY idx_r1(r1));

            INSERT INTO t_uuid_short VALUES
            (uuid_short(),1),(uuid_short(),2)

            SELECT * FROM t_uuid_short
            +--------------------+----+
            | id                 | r1 |
            +--------------------+----+
            | 100796680487567360 | 1  |
            | 100796680487567361 | 2  |
            +--------------------+----+
            ```

#### 前缀索引

- 有时，你可能会遇到需要索引长列的情况，从而使索引变得非常大。在这些情况下，你还可以索引列的前几个字符，而不是索引整个值——这样的索引称为前缀索引。

- 对于过长的值, 可以建立前缀索引

    - 一个数据表的 x_name 值都是类似 23213223.434323.4543.4543.34324.可以只取前7位`alter table table1 add key (x_name(7))`

- 无法使用`ORDER BY`, `GROUP BY`, 以及覆盖查询

- 后缀索引(suffix index):像电子邮件这类值比较有效. 但mysql不支持后缀, 可以把字符串反转后, 再建立前缀索引

- 索引选择性:不重复的索引值,和表总数的比例. 唯一性索引的选择性是1, 性能最好

- 假设要建立cnarea_2019表的name列索引:

    - 查看选择性:
    ```sql
    SELECT COUNT(DISTINCT name) / COUNT(*) FROM cnarea_2019;

    +---------------------------------+
    | COUNT(DISTINCT name) / COUNT(*) |
    +---------------------------------+
    | 0.6138 |
    +---------------------------------+
    ```

    - 查看不同前缀长度的选择性
    ```sql
    SELECT
    COUNT(DISTINCT LEFT(name, 4)) / COUNT(*) AS sel3,
    COUNT(DISTINCT LEFT(name, 4)) / COUNT(*) AS sel4,
    COUNT(DISTINCT LEFT(name, 5)) / COUNT(*) AS sel5,
    COUNT(DISTINCT LEFT(name, 6)) / COUNT(*) AS sel6,
    COUNT(DISTINCT LEFT(name, 7)) / COUNT(*) AS sel7,
    COUNT(DISTINCT LEFT(name, 8)) / COUNT(*) AS sel8,
    COUNT(DISTINCT LEFT(name, 9)) / COUNT(*) AS sel9,
    COUNT(DISTINCT LEFT(name, 10)) / COUNT(*) AS sel10,
    COUNT(DISTINCT LEFT(name, 11)) / COUNT(*) AS sel11,
    COUNT(DISTINCT LEFT(name, 12)) / COUNT(*) AS sel12
    FROM cnarea_2019;

    +--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
    | sel3 | sel4 | sel5 | sel6 | sel7 | sel8 | sel9 | sel10 | sel11 | sel12 |
    +--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
    | 0.5271 | 0.5271 | 0.5662 | 0.5866 | 0.5981 | 0.6057 | 0.6095 | 0.6119 | 0.6128 | 0.6133 |
    +--------+--------+--------+--------+--------+--------+--------+--------+--------+--------+
    ```

    - 查看当前缀为8时, 最频繁出现的次数
    ```sql
    SELECT COUNT(*) AS cnt, LEFT(name, 8) FROM cnarea_2019
    GROUP BY name
    ORDER BY cnt DESC
    LIMIT 10;

    +-----+---------------+
    | cnt | LEFT(name, 8) |
    +-----+---------------+
    | 358 | 和平村委会 |
    | 333 | 张庄村委会 |
    | 328 | 团结村委会 |
    | 321 | 王庄村委会 |
    | 305 | 太平村委会 |
    | 281 | 市辖区     |
    | 274 | 胜利村委会 |
    | 265 | 新民村委会 |
    | 264 | 新庄村委会 |
    | 261 | 红星村委会 |
    +-----+---------------+
    ```

    - 到达8后选择性的提升已经很小了, 因此建立长度为8的索引

        ```sql
        ALTER TABLE cnarea_2019 ADD KEY (name(8));
        ```



#### 覆盖索引

- 覆盖索引:索引包含查询所需的字段值

    - 能提升性能, 无需回表

        - 如果索引不能覆盖查询所有列, 需要每扫描一条索引记录后, 回表查询对应的行, 基本是随机io

    - 因此必须存储字段值, 想hash, 空间, 全文索引都不能存储字段值

- 通过`EXPLAIN`命令Extra字段为`Using index` 就是覆盖索引:

    - 注意:type字段的`index` , 说明使用了索引扫描排序.[跳转至type字段说明](#explain-type)

    ```sql
    CREATE table index1_test (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(10)
    );

    INSERT INTO index1_test(name) VALUES ('one'), ('two');

    EXPLAIN SELECT id FROM index1_test\G;
    ***************************[ 1. row ]***************************
    id            | 1
    select_type   | SIMPLE
    table         | index1_test
    type          | index
    possible_keys | <null>
    key           | PRIMARY
    key_len       | 4
    ref           | <null>
    rows          | 2
    Extra         | Using index
    ```

- 通过`EXPLAIN`命令Extra字段为`Using where`表示没有使用索引:

    ```sql
    EXPLAIN SELECT name FROM index1_test
    WHERE name = 'one'\G;
    ***************************[ 1. row ]***************************
    id            | 1
    select_type   | SIMPLE
    table         | index1_test
    type          | ALL
    possible_keys | <null>
    key           | <null>
    key_len       | <null>
    ref           | <null>
    rows          | 2
    Extra         | Using where
    ```

    - 通过子查询查找id, 即第一阶段使用覆盖索引.这叫作延迟关联(deferred join)
        ```sql
        SELECT * FROM index1_test
        JOIN (SELECT id FROM index1_test) as id
        ON (index1_test.id = id.id);

        ***************************[ 1. row ]***************************
        id            | 1
        select_type   | SIMPLE
        table         | index1_test
        type          | index
        possible_keys | PRIMARY
        key           | PRIMARY
        key_len       | 4
        ref           | <null>
        rows          | 2
        Extra         | Using index
        ***************************[ 2. row ]***************************
        id            | 1
        select_type   | SIMPLE
        table         | index1_test
        type          | ALL
        possible_keys | PRIMARY
        key           | <null>
        key_len       | <null>
        ref           | <null>
        rows          | 2
        Extra         | Using where; Using join buffer (flat, BNL join)
        ```

    - 创建二级索引后在查询:
        ```sql
        ALTER TABLE index1_test ADD INDEX name(name);

        EXPLAIN SELECT name FROM index1_test
        WHERE name = 'one'\G;
        ***************************[ 1. row ]***************************
        id            | 1
        select_type   | SIMPLE
        table         | index1_test
        type          | ref
        possible_keys | name
        key           | name
        key_len       | 43
        ref           | const
        rows          | 1
        Extra         | Using where; Using index
        ```

        ```sql
        MariaDB root@(none):china> explain select id from index1_test order by name,id
        +----+-------------+-------------+-------+---------------+------+---------+--------+------+-------------+
        | id | select_type | table       | type  | possible_keys | key  | key_len | ref    | rows | Extra       |
        +----+-------------+-------------+-------+---------------+------+---------+--------+------+-------------+
        | 1  | SIMPLE      | index1_test | index | <null>        | name | 43      | <null> | 2    | Using index |
        +----+-------------+-------------+-------+---------------+------+---------+--------+------+-------------+

        1 row in set
        Time: 0.005s
        MariaDB root@(none):china> explain select id from index1_test order by id,name
        +----+-------------+-------------+-------+---------------+------+---------+--------+------+-----------------------------+
        | id | select_type | table | type | possible_keys | key | key_len | ref | rows | Extra
                      |
        +----+-------------+-------------+-------+---------------+------+---------+--------+------+-----------------------------+
        | 1  | SIMPLE      | index1_test | index | <null>        | name | 43      | <null> | 2    | Using index; Using filesort |
        +----+-------------+-------------+-------+---------------+------+---------+--------+------+-----------------------------+

        ```

#### 防止索引失效

- 这里简单说一下，发生索引失效的情况：

    - 1.当我们使用左或者左右模糊匹配的时候，也就是 `like %xx` 或者 `like %xx%`这两种方式都会造成索引失效；

        ```sql
        -- name 字段为二级索引
        select * from t_user where name like '%林';
        ```

        - 因为索引 B+ 树是按照「索引值」有序排列存储的，只能根据前缀进行比较。

    - 2.当我们在查询条件中对索引列做了`计算`、`函数`、`类型转换`，这些情况下都会造成索引失效；

        - `函数`：对索引字段使用函数，就会导致索引失效。

            ```sql
            -- name 为二级索引
            select * from t_user where length(name)=6;
            ```

            - 因为索引保存的是索引字段的原始值，而不是经过函数计算后的值，自然就没办法走索引了。

            - 不过，从 MySQL 8.0 开始，索引特性增加了函数索引，即可以针对函数计算后的值建立一个索引，也就是说该索引的值是函数计算后的值，所以就可以通过扫描索引来查询数据。
            - 例子：我通过下面这条语句，对 `length(name)` 的计算结果建立一个名为 `idx_name_length` 的索引。

                ```sql
                alter table t_user add key idx_name_length ((length(name)));
                ```

        - `计算`：在查询条件中对索引进行`表达式计算`，也是无法走索引的。

            ```sql
            explain select * from t_user where id + 1 = 10;
            ```

            - 因为索引保存的是索引字段的原始值，而不是 id + 1 表达式计算后的值，所以无法走索引，只能通过把索引字段的取值都取出来，然后依次进行表达式的计算来进行条件判断，因此采用的就是全表扫描的方式。

        - `隐式转换`：如果索引字段是字符串类型，但是在条件查询中，输入的参数是整型的话。
            - 1.MySQL 的数据类型转换规则：字符串和数字比较的时候，会自动把字符串转为数字，然后再进行比较

                ```sql
                -- phone数据类型为varchar
                select * from t_user where phone = 1300000001;
                ```

                - phone 字段为字符串，会自动把字符串转为数字，所以这条语句相当于：

                    - CAST 函数是作用在了 phone 字段，而 phone 字段是索引，也就是对索引使用了函数！而前面我们也说了，**对索引使用函数是会导致索引失效的**

                    ```sql
                    select * from t_user where CAST(phone AS signed int) = 1300000001;
                    ```

            - 2.但是如果索引字段是整型类型，查询条件中的输入参数即使字符串，是**不会导致索引失效**，还是可以走索引扫描。

                ```sql
                -- id类型为int
                explain select * from t_user where id = '1';
                ```

                - 这时因为字符串部分是输入参数，也就需要将字符串转为数字，所以这条语句相当于：

                    - 可以看到，索引字段并没有用任何函数，CAST 函数是用在了输入参数，因此是可以走索引扫描的。

                    ```sql
                    select * from t_user where id = CAST("1" AS signed int);
                    ```

    - 3.联合索引要能正确使用需要遵循最左匹配原则，也就是按照最左优先的方式进行索引的匹配，否则就会导致索引失效。

    - 4.在 `WHERE` 子句中，如果在 `OR` 前的条件列是索引列，而在 `OR` 后的条件列不是索引列，那么索引会失效。

        ```sql
        -- id 是主键，age 是普通列，从执行计划的结果看，是走了全表扫描。
        select * from t_user where id = 1 or age = 18;
        ```

        - 解决办法：将 age 字段设置为索引即可
            - 可以看到 type=index merge， index merge 的意思就是对 id 和 age 分别进行了扫描，然后将这两个结果集进行了合并，这样做的好处就是避免了全表扫描。

## DCL (Data Control Language) 数据控制语言

- `GRANT`：授权用户或其他角色访问数据库对象或执行特定操作的权限。

- `REVOKE`：撤销之前通过GRANT语句赋予的权限。

- 在一些数据库管理系统中，事务控制相关的命令（如COMMIT提交事务、ROLLBACK回滚事务）也归入DCL范畴，但在其他地方这些可能被归为TCL（Transaction Control Language）的一部分。

- DCL用来授予或撤销用户对数据库对象的访问权限以及其他特权，以及管理事务处理中的各种控制指令。主要包含以下类型的语句：


### 帮助文档

```sql
# 按照层次查询
? contents;
? Account Management
# 数据类型
? Data Types
? VARCHAR
? SHOW
```

### GRANT 用户权限设置

> ```sql
> -- 创建用户
> CREATE USER 'username'@'host' IDENTIFIED BY 'password';
>
> -- 授权
> GRANT privileges ON databasename.tablename TO 'username'@'host'
>
> -- 撤销权限
> REVOKE privileges ON databasename.tablename FROM 'username'@'host'
> ```

- 用户
    ```sql
    -- 查看所有用户
    SELECT user,host FROM mysql.user;

    -- 详细查看所有用户
    SELECT DISTINCT CONCAT('User: ''',user,'''@''',host,''';')
    AS query FROM mysql.user;

    -- 创建用户名为tz的用户，并设置密码
    create user 'tz'@'127.0.0.1'
    identified by 'YouPassword';
    -- 创建用户名为tz的用户，密码为空
    create user 'tz'@'127.0.0.1';
    -- 创建用户名为tz的用户，密码为空，并且运行所有ip地址
    create user 'tz'@'%';

    -- 修改后。需要刷新
    FLUSH PRIVILEGES;

    -- 删除用户
    DROP USER 'tz'@'127.0.0.1' identified by '12345678';
    DROP USER 'tz'@'127.0.0.1';

    -- 当前用户修改密码的命令
    SET PASSWORD = PASSWORD("NewPassword");

    -- 修改密码
    SET PASSWORD FOR 'tz'@'127.0.0.1' = PASSWORD('NewPassword');
    ```

- GRANT (授权)
    ```sql
    -- 设置只能 select china.cnarea_2019
    GRANT SELECT ON china.cnarea_2019 TO 'tz'@'127.0.0.1' IDENTIFIED BY 'YourPassword';

    -- 修改权限后。需要刷新权限
    FLUSH PRIVILEGES;

    -- 查看tz用户的权限。注意127.0.0.1和localhost是不同的
    SHOW GRANTS FOR 'tz'@'127.0.0.1';
    SHOW GRANTS FOR 'tz'@'localhost';

    -- 添加 insert 和 china所有表的权限
    grant select,insert on china.* to 'tz'@'127.0.0.1' identified by "YouPassword";

    -- 添加所有数据库和表的权限。这样做会有风险，具体看下面的MySQL 授权表运维注意事项
    grant all PRIVILEGES on *.* to 'tz'@'127.0.0.1' identified by "YouPassword";
    -- 或者。2条命令等价
    grant all on *.* to 'tz'@'127.0.0.1' identified by "YouPassword";

    -- 允许tz 用户授权于别的用户
    grant all on *.* to 'tz'@'127.0.0.1' with grant option identified by "YouPassword";
    ```

- revoke (撤销):
    ```sql
    revoke all privileges on *.* from 'tz'@'127.0.0.1';
    revoke grant option on *.* from 'tz'@'127.0.0.1';

    +-----------------------------------------------------------+
    | Grants for tz@127.0.0.1                                   |
    +-----------------------------------------------------------+
    | GRANT USAGE ON *.* TO `tz`@`127.0.0.1`                    |
    | GRANT SELECT, INSERT ON `china`.* TO `tz`@`127.0.0.1`     |
    | GRANT SELECT ON `china`.`cnarea_2019` TO `tz`@`127.0.0.1` |
    +-----------------------------------------------------------+

    revoke select, insert on china.* from 'tz'@'127.0.0.1';

    +-----------------------------------------------------------+
    | Grants for tz@127.0.0.1                                   |
    +-----------------------------------------------------------+
    | GRANT USAGE ON *.* TO `tz`@`127.0.0.1`                    |
    | GRANT SELECT ON `china`.`cnarea_2019` TO `tz`@`127.0.0.1` |
    +-----------------------------------------------------------+

    revoke select on china.cnarea_2019 from 'tz'@'127.0.0.1';

    +----------------------------------------+
    | Grants for tz@127.0.0.1                |
    +----------------------------------------+
    | GRANT USAGE ON *.* TO `tz`@`127.0.0.1` |
    +----------------------------------------+

    -- 刷新权限
    FLUSH PRIVILEGES;

    -- 删除用户
    drop user 'tz'@'127.0.0.1';
    ```

<span id="user"></span>

#### [爱可生开源社区：技术分享 | MySQL 授权表运维注意事项](https://mp.weixin.qq.com/s/gqD_2AlH8fifDKmTduqenQ)

- 我们在做权限授权时需要给到应用用户增删改查权限，比如下面的授权语句。这样的好处是当实例创建多个业务库时，无需再次给新的业务库授权，该权限默认对所有库有增删改查权限，主打一个方便
    - 但实际这种授权方式会带来较大的权限风险，甚至导致数据库被攻击破坏。

    ```sql
    create user 'app'@'%' identified by 'app';
    grant select,update,delete,insert on *.* to 'app'@'%';
    ```

- 我们基于以上的授权来做一个业务用户 提权（自己给自己增加额外的权限）操作

    - 场景1：管理用户触发 `flush privileges` 刷新内存授权表触发提权。

        - app 用户给自己提权。这里 `update` 成功了，但由于缺少 reload 或 super 权限，导致刷新到内存中失败了。
            ```sql
            update mysql.user set Select_priv='Y',Insert_priv='Y',Update_priv='Y',Delete_priv='Y',Create_priv='Y',Drop_priv='Y',Reload_priv='Y',Shutdown_priv='Y',Process_priv='Y',File_priv='Y',Grant_priv='Y',References_priv='Y',Index_priv='Y',Alter_priv='Y',Show_db_priv='Y',Super_priv='Y',Lock_tables_priv='Y' where user='app' and host='%';
            Query OK, 1 row affected (0.01 sec)
            Rows matched: 1  Changed: 1  Warnings: 0

            flush privileges;
            ERROR 1227 (42000): Access denied; you need (at least one of) the RELOAD privilege(s) for this operation
            ```

        - 某天 root 用户做了个 flush privileges 操作
            ```sql
            flush privileges;
            Query OK, 0 rows affected (0.00 sec)
            ```

        - app 用户重新登录数据库查看自己的权限，提权成功。
            ```sql
            show grants\G
            *************************** 1. row ***************************
            Grants for app@%: GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, SHUTDOWN, PROCESS, FILE, REFERENCES, INDEX, ALTER, SHOW DATABASES, SUPER, LOCK TABLES ON . TO app@% WITH GRANT OPTION
            1 row in set (0.00 sec)
            ```

    - 场景2：重启数据库重新加载授权表到内存触发提权。

        - app 用户给自己提权，这里 `update` 成功了，但由于缺少 reload 或 super 权限，导致刷新到内存中失败了
            ```sql
            update mysql.user set Select_priv='Y',Insert_priv='Y',Update_priv='Y',Delete_priv='Y',Create_priv='Y',Drop_priv='Y',Reload_priv='Y',Shutdown_priv='Y',Process_priv='Y',File_priv='Y',Grant_priv='Y',References_priv='Y',Index_priv='Y',Alter_priv='Y',Show_db_priv='Y',Super_priv='Y',Lock_tables_priv='Y' where user='app' and host='%';
            Query OK, 1 row affected (0.01 sec)
            Rows matched: 1  Changed: 1  Warnings: 0
            ```

            ```sql
            flush privileges;
            ERROR 1227 (42000): Access denied; you need (at least one of) the RELOAD privilege(s) for this operation
            ```

        - 重启数据库
            ```sql
            restart;
            Query OK, 0 rows affected (0.00 sec)
            ```

        - app 用户重新登录数据库查看自己的权限，提权成功。
            ```sql
            show grants\G
            *************************** 1. row ***************************
            Grants for app@%: GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, RELOAD, SHUTDOWN, PROCESS, FILE, REFERENCES, INDEX, ALTER, SHOW DATABASES, SUPER, LOCK TABLES ON . TO app@% WITH GRANT OPTION
            1 row in set (0.00 sec)
            ```

- 场景总结

    - 给普通用户授予 MySQL 鉴权相关表的权限均会带来风险
        - 备注：鉴权表除了 `user` 表，还包括 `db`、`columns_priv`、`tables_priv`、`procs_priv`、proxies_priv 表。
            - 即使只对鉴权表授予只读权限，如 `user` 表，也会被获取到 `authentication_string` 字段的密文串，通过其他方式做密码库匹配破解。

    - 曾经遇到过一个场景，普通用户仅有 `user` 的查询权限，其通过查询该表信息发现 root@localhost 用户密码为空，于是直接用 root 用户访问数据库，类似于进行了提权操作。

- 规避方式
    - 不要对非管理员用户授予任何鉴权表的访问权限，即使是只读权限。
    授权遵循最小权限原则。
    - MySQL 8.0 增加了回收部分权限的参数 `partial_revokes`，可单独将 mysql 库的权限回收。示例如下

    ```sql
    -- 创建app用户并授予所有数据库增删改查权限
    create user 'app'@'%' identified by 'app';
    grant select,update,delete,insert on *.* to 'app'@'%';

    -- 开启部分权限回收的参数
    set global partial_revokes=on;

    -- 单独回收app用户对mysql库的权限
    revoke select,update,delete,insert on mysql.* from 'app'@'%';

    -- 查看当前app用户的授权信息
    -- 这里的权限是以交集的形式存在，必须两者都满足
    show grants for app;
    +-------------------------------------------------------------------+
    | Grants for app@%                                                  |
    +-------------------------------------------------------------------+
    | GRANT SELECT, INSERT, UPDATE, DELETE ON *.* TO `app`@`%`          |
    | REVOKE SELECT, INSERT, UPDATE, DELETE ON `mysql`.* FROM `app`@`%` |
    +-------------------------------------------------------------------+

    -- 以app用户登录数据库访问mysql.user表，报错无权限
    mysql> select user,host from mysql.user;
    ERROR 1142 (42000): SELECT command denied to user 'app'@'127.0.0.1' for table 'user'
    ```
#### 设置权限允许远程的ip连接mysql

**语法:**

> ```sql
> GRANT PRIVILEGES ON 数据库名.表名 TO '用户名'@'IP地址' IDENTIFIED BY 'YouPassword' WITH GRANT OPTION;
> ```

```sql

-- 允许root从'192.168.100.208'主机china库下的所有表(WITH GRANT OPTION表示有修改权限的权限)
grant all PRIVILEGES on china.* to
'root'@'192.168.100.208'
identified by 'YouPassword'
WITH GRANT OPTION;

-- 允许root从'192.168.100.208'主机china库下的cnarea_2019表
grant all PRIVILEGES on china.cnarea_2019 to
'root'@'%'
identified by 'YouPassword'
WITH GRANT OPTION;

-- 允许所有用户连接所有库下的所有表(%:表示通配符)
grant all PRIVILEGES on *.* to
'root'@'%' identified by 'YouPassword'
WITH GRANT OPTION;

-- 刷新权限
FLUSH PRIVILEGES;
```

```sh
# 记得在服务器里关闭防火墙
iptables -F

# 连接远程数据库(我这里是192.168.100.208)
mysql -u root -p 'YouPassword' -h 192.168.100.208
```

### varibles（变量）

- 注意`variables` 的修改,永久保存要写入`/etc/my.cnf`
  [详细配置说明](https://github.com/jaywcjlove/mysql-tutorial/blob/master/chapter2/2.6.md#%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6%E5%86%85%E5%AE%B9)

```sql
-- 查看配置(变量)
show variables;

-- 查看指定变量
show variables like 'max_connections';
-- 或者
select @@max_connections

-- 查看字段前面包含max_connect的配置(通配符%)
show variables like 'max_connect%';
+--------------------+-------+
| Variable_name      | Value |
+--------------------+-------+
| max_connect_errors | 100   |
| max_connections    | 151   |
+--------------------+-------+

-- 设置自定义变量(重启后失效)
set @val = 1;
-- 查看刚才的变量
select @val;

-- 修改会话变量,该值将在会话内保持有效(重启后失效)
set session sql_mode = 'TRADITIONAL';

-- 通过 select 查看
select @@session.sql_mode;
-- 或者
show variables like 'sql_mode';

-- 修改全局变量, 仅影响更改后连接的客户端的相应会话值.(重启后失效)
set global max_connect_errors=1000;

-- 通过 select 查看
select @@global.max_connect_errors;
-- 或者
show variables like 'max_connect_errors';

-- 永久保存,要写入/etc/my.cnf
echo "max_connect_errors=1000" >> /etc/my.cnf
```

#### sql_mode

- [技术分享 | 深入理解 MySQL 中的 SQL_MODE](https://mp.weixin.qq.com/s/8xeMxmPjcLOEw0ER80hJ-A)

## TCL（Transaction Control Language）事务

- TCL是事务控制语言，主要用来控制事务。例如：BEGIN、COMMIT、ROLLBACK等语句。

- MYSQL事务分为

    - 1.隐式事务
        - 比如insert、update、delete语句，事务的开启、提交或回滚由mysql内部自动控制的，事务自动开启、提交或回滚。
        - 因此一条SQL没有begin开启事务和Commit提交事务，也能自己提交事务

    - 2.显示事务

        - 显式事务是指在应用程序中明确指定事务的开始和结束，使用BEGIN、COMMIT和ROLLBACK语句来控制事务的执行，语法如下：

            ```sql
            BEGIN;
            -- SQL statements
            COMMIT;
           ```

    - `autocommit`为`ON`表示隐式事务开启了自动提交
        ```sql
        show variables like 'autocommit'
        +---------------+-------+
        | Variable_name | Value |
        +---------------+-------+
        | autocommit    | ON    |
        +---------------+-------+
        ```

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
-- 创建数据库
create table tz (
    id int (8),
    name varchar(50),
    date DATE
);

-- 声明一个名叫 abc 的事务保存点
savepoint abc;

-- 插入数据
insert into tz (id,name,date) values
(1,'tz','2020-10-24');

-- 回滚到 abc 事务保存点
rollback to abc;
```

### autocommit（自动提交）

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

## 规范和优化

### 设计规范

- [阿里云开发者：技术同学必会的MySQL设计规约，都是惨痛的教训](https://mp.weixin.qq.com/s/XC8e5iuQtfsrEOERffEZ-Q)

#### 安全规范

- 先介绍的是安全规范，因为安全无小事，很多公司都曾经因为自己的数据泄露导致用户的惨痛损失，所以将安全规范放到了第一位。

- 【强制】禁止在数据库中存储明文密码，需把密码加密后存储
    - 说明：对于加密操作建议由公司的中间件团队基于如mybatis的扩展，提供统一的加密算法及密钥管理，避免每个业务线单独开发一套，同时也与具体的业务进行了解耦
- 【强制】禁止在数据库中明文存储用户敏感信息，如手机号等
    - 说明：对于手机号建议公司搭建统一的手机号查询服务，避免在每个业务线单独存储
- 【强制】禁止开发直接给业务同学导出或者查询涉及到用户敏感信息的数据，如需要需上级领导审批
- 【强制】涉及到导出数据功能的操作，如包含敏感字段都需加密或脱敏
- 【强制】跟数据库交互涉及的敏感数据操作都需有审计日志，必要时要做告警
- 【强制】对连接数据库的IP需设置白名单功能，杜绝非法IP接入
- 【强制】对重要sql（如订单信息的查询）的访问频率或次数要做历史趋势监控，及时发现异常行为
- 【推荐】线上连接数据库的用户名、密码建议定期进行更换

#### 基础规范

-【推荐】尽量不在数据库做运算，复杂运算需移到业务应用里完成
-【推荐】拒绝大sql语句、拒绝大事务、拒绝大批量，可转化到业务端完成
    - 说明：大批量操作可能会造成严重的主从延迟，binlog日志为row格式会产生大量的日志
-【推荐】避免使用存储过程、触发器、函数等，容易造成业务逻辑与DB耦合
    - 说明：数据库擅长存储与索引、要解放数据库CPU，将计算转移到服务层、也具备更好的扩展性
-【强制】数据表、数据字段必须加入中文注释
    - 说明：后续维护的同学看到后才清楚表是干什么用的
-【强制】不在数据库中存储图片、文件等大数据
    - 说明：大文件和图片需要储在文件系统
-【推荐】对于程序连接数据库账号，遵循权限最小原则
-【推荐】数据库设计时，需要问下自己是否对以后的扩展性进行了考虑
-【推荐】利用 pt-query-digest 定期分析slow query log并进行优化
-【推荐】使用内网域名而不是ip连接数据库
-【推荐】如果数据量或数据增长在前期规划时就较大，那么在设计评审时就应加入分表策略
-【推荐】要求所有研发SQL关键字全部是小写，每个词只允许有一个空格

#### 命名规范

- 【强制】库名、表名、字段名要小写，下划线风格，不超过32个字符，必须见名知意，建议使用名词而不是动词，词义与业务、产品线等相关联，禁止拼音英文混用
- 【强制】普通索引命名格式：idx_表名_索引字段名（如果以首个字段名为索引有多个，可以加上第二个字段名，太长可以考虑缩写），唯一索引命名格式：uk_表名_索引字段名（索引名必须全部小写，长度太长可以利用缩写），主键索引命名：pk_ 字段名
- 【强制】库名、表名、字段名禁止使用MySQL保留字
- 【强制】临时库表名必须以tmp为前缀，并以日期为后缀
- 【强制】备份库表必须以bak为前缀，并以日期为后缀
- 【推荐】用HASH进行散表，表名后缀使用16进制数，下标从0开始
- 【推荐】按日期时间分表需符合YYYY[MM][DD][HH]格式
- 【推荐】散表如果使用md5（或者类似的hash算法）进行散表，表名后缀使用16进制，比如user_ff
- 【推荐】使用CRC32求余（或者类似的算术算法）进行散表，表名后缀使用数字，数字必须从0开始并等宽，比如散100张表，后缀从00-99
- 【推荐】使用时间散表，表名后缀必须使用特定格式，比如按日散表user_20110209、按月散表user_201102
- 【强制】表达是与否概念的字段，使用 is _ xxx 的方式进行命名

#### 库设计规范

- 【推荐】数据库使用InnoDB存储引擎
    - 说明：支持事务、行级锁、并发性能更好、CPU及内存缓存页优化使得资源利用率更高
- 【推荐】数据库和表的字符集统一使用UTF8
    - 说明：utf8号称万国码，其无需转码、无乱码风险且节省空间。若是有字段需要存储emoji表情之类的，则将表或字段设置成utf8mb4，utf8mb4向下兼容utf8。
- 【推荐】不同业务，使用不同的数据库，避免互相影响
- 【强制】所有线上业务库均必须搭建MHA高可用架构，避免单点问题

#### 表设计规范

-【推荐】建表规范示例
    ```sql
    CREATE TABLE `student_info` (
    `id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '主键',
    `stu_name` varchar(10) NOT NULL DEFAULT '' COMMENT '姓名',
    `stu_score` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '总分',
    `stu_num` int(11) NOT NULL COMMENT '学号',
    `gmt_create` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
    `gmt_modified` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
    `status` tinyint(4) DEFAULT '1' COMMENT '1代表记录有效，0代表记录无效',
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_student_info_stu_num` (`stu_num`) USING BTREE,
    KEY `idx_student_info_stu_name` (`stu_name`) USING BTREE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='学生信息表';
    ```
- 【强制】禁止使用外键，如果有外键完整性约束，需要应用程序控制

- 【强制】每个Innodb 表必须有一个主键
    - 说明：Innodb 是一种索引组织表，其数据存储的逻辑顺序和索引的顺序是相同的。每张表可以有多个索引，但表的存储顺序只能有一种，Innodb 是按照主键索引的顺序来组织表的，因此不要使用更新频繁的列如UUID、MD5、HASH和字符串列作为主键，这些列无法保证数据的顺序增长，主键建议使用自增ID 值。
- 【推荐】单表列数目最好小于50
- 【强制】禁止使用分区表
    - 说明：分区表在物理上表现为多个文件，在逻辑上表现为一个表，谨慎选择分区键，跨分区查询效率可能更低，建议采用物理分表的方式管理大数据
- 【推荐】拆分大字段和访问频率低的字段，分离冷热数据
- 【推荐】采用合适的分库分表策略，例如千库十表、十库百表等（建议表大小控制在2G）
- 【推荐】单表不超过50个int字段；不超过20个char字段，不超过2个text字段
- 【推荐】表默认设置创建时间戳和更改时间戳字段
- 【推荐】日志类型的表可以考虑按创建时间水平切割，定期归档历史数据
- 【强制】禁止使用order by rand()
    - 说明：order by rand()会为表增加一个伪列，然后用rand()函数为每一行数据计算出rand()值，基于该行排序，这通常都会生成磁盘上的临时表，因此效率非常低。
- 【参考】可以结合使用hash、range、lookup table进行散表
- 【推荐】每张表数据量建议控制在500w以下，超过500w可以使用历史数据归档或分库分表来实现（500万行并不是MySQL数据库的限制。过大对于修改表结构，备份，恢复都会有很大问题。MySQL没有对存储有限制，取决于存储设置和文件系统）
- 【强制】禁止在表中建立预留字段
    - 说明：预留字段的命名很难做到见名识义，预留字段无法确认存储的数据类型，所以无法选择合适的类型；对预留字段类型的修改，会对表进行锁定

#### 字段设计规范

- 【强制】必须把字段定义为NOT NULL并且提供默认值
    - 说明：NULL字段很难查询优化，NULL字段的索引需要额外空间，NULL字段的复合索引无效
- 【强制】禁止使用ENUM，可使用TINYINT代替
- 【强制】禁止使用TEXT、BLOB类型(如果表的记录数在万级以下可以考虑)
- 【强制】必须使用varchar(20)存储手机号
- 【强制】禁止使用小数存储国币、使用“分”作为单位，这样数据库里就是整数了
- 【强制】用DECIMAL代替FLOAT和DOUBLE存储精确浮点数
- 【推荐】使用UNSIGNED存储非负整数
    - 说明：同样的字节数，存储的数值范围更大
- 【推荐】建议使用INT UNSIGNED存储IPV4
    - 说明：用UNSINGED INT存储IP地址占用4字节，CHAR(15)则占用15字节。另外，计算机处理整数类型比字符串类型快。使用INT UNSIGNED而不是CHAR(15)来存储IPV4地址，通过MySQL函数inet_ntoa和inet_aton来进行转化。IPv6地址目前没有转化函数，需要使用DECIMAL或两个BIGINT来存储。例如:
SELECT INET_ATON('192.168.172.3'); 3232279555 SELECT INET_NTOA(3232279555); 192.168.172.3
- 【推荐】字段长度尽量按实际需要进行分配，不要随意分配一个很大的容量
- 【推荐】核心表字段数量尽可能地少，有大字段要考虑拆分
- 【推荐】适当考虑一些反范式的表设计，增加冗余字段，减少JOIN
- 【推荐】资金字段考虑统一*100处理成整型，避免使用decimal浮点类型存储
- 【推荐】使用VARBINARY存储大小写敏感的变长字符串或二进制内容
    - 说明：VARBINARY默认区分大小写，没有字符集概念，速度快
- 【参考】INT类型固定占用4字节存储
    - 说明：INT(4)仅代表显示字符宽度为4位，不代表存储长度。数值类型括号后面的数字只是表示宽度而跟存储范围没有关系，比如INT(3)默认显示3位，空格补齐，超出时正常显示，Python、Java客户端等不具备这个功能
- 【参考】区分使用DATETIME和TIMESTAMP
    - 说明：存储年使用YEAR类型、存储日期使用DATE类型、存储时间(精确到秒)建议使用TIMESTAMP类型。
    - DATETIME和TIMESTAMP都是精确到秒，优先选择TIMESTAMP，因为TIMESTAMP只有4个字节，而DATETIME8个字节，同时TIMESTAMP具有自动赋值以及⾃自动更新的特性。
    - 补充：如何使用TIMESTAMP的自动赋值属性?
    - 自动初始化，而且自动更新：column1 TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATECURRENT_TIMESTAMP 只是自动初始化：column1 TIMESTAMP DEFAULT CURRENT_TIMESTAMP 自动更新，初始化的值为0：column1 TIMESTAMP DEFAULT 0 ON UPDATE CURRENT_TIMESTAMP 初始化的值为0：column1 TIMESTAMP DEFAULT 0
- 【推荐】将大字段、访问频率低的字段拆分到单独的表中存储，分离冷热数据
    - 说明：有利于有效利用缓存，防⽌读入无用的冷数据，较少磁盘IO，同时保证热数据常驻内存提⾼高缓存命中率
- 【参考】VARCHAR(N)，N表示的是字符数不是字节数，比如VARCHAR(255)，可以最大可存储255个汉字，需要根据实际的宽度来选择N
- 【参考】VARCHAR(N)，N尽可能小，因为MySQL一个表中所有的VARCHAR字段最大长度是65535个字节，进行排序和创建临时表一类的内存操作时，会使用N的长度申请内存
- 【推荐】VARCHAR(N)，N>5000时，使用BLOB类型
- 【推荐】使用短数据类型，比如取值范围为0~80时，使用TINYINT UNSIGNED
- 【强制】存储状态，性别等，用TINYINT
- 【强制】所有存储相同数据的列名和列类型必须一致（在多个表中的字段如user_id，它们类型必须一致）
- 【推荐】优先选择符合存储需要的最小数据类型
- 【推荐】如果存储的字符串长度几乎相等，使用 char 定长字符串类型

#### 索引设计规范

- 【推荐】单表索引建议控制在5个以内
    - 说明：索引可以增加查询效率，但同样也会降低插入和更新的效率，甚至有些情况下会降低查询效率，所以不是越多越好
- 【强制】禁止在更新十分频繁，区分度不高的属性上建立索引
- 【强制】建立组合索引必须把区分度高的字段放在前面
- 【推荐】对字符串使用索引，如果字符串定义长度超过128的，可以考虑前缀索引
- 【强制】表必须有主键，并且是auto_increment及not null的，根据表的实际情况定义无符号的tinyint,smallint,int,bigint
- 【强制】禁止更新频繁的列作为主键
- 【强制】禁止字符串列作为主键
- 【强制】禁止UUID MD5 HASH这些作为主键(数值太离散了)
- 【推荐】默认使用非空的唯一键作为主键
- 【推荐】主键建议选择自增或发号器
- 【推荐】核心SQL优先考虑覆盖索引
- 【参考】避免冗余和重复索引
- 【参考】索引要综合评估数据密度和分布以及考虑查询和更新比例
- 【强制】不在索引列进行数学运算和函数运算
- 【推荐】研发要经常使用explain，如果发现索引选择性差，必须要学会使用hint
- 【推荐】能使用唯一索引就要使用唯一索引，提高查询效率
- 【推荐】多条字段重复的语句，要修改语句条件字段的顺序，为其建立一条联合索引，减少索引数量
- 【强制】索引字段要保证不为NULL，考虑default value进去。NULL也是占空间，而且NULL非常影响索引的查询效率
- 【强制】新建的唯一索引不能和主键重复
- 【推荐】尽量不使用外键、外键用来保护参照完整性，可在业务端实现
    - 说明：避免对父表和子表的操作会相互影响，降低可用性
- 【强制】字符串不应做主键
- 【强制】表必须有无符号int型自增主键，对应表中id字段
    - 说明：必须得有主键的原因：采用RBR模式复制，无主键的表删除，会导致备库夯住 ；使用自增的原因：
数据写入可以提高插入性能，避免page分裂，减少表碎片
- 【推荐】对长度过长的VARCHAR字段建立索引时，添加crc32或者MD5 Hash字段，对Hash字段建立索引
    - 说明：下面的表增加一列url_crc32，然后对url_crc32建立索引，减少索引字段的长度，提高效率
    - CREATE TABLE url(   ...   url VARCHAR(255) NOT NULL DEFAULT 0,   url_crc32 INT UNSIGNED NOT NULL DEFAULT 0,   ...   index idx_url(url_crc32) ）
- 【推荐】WHERE条件中的非等值条件（IN、BETWEEN、<、<=、>、>=）会导致后面的条件使用不了索引
- 【推荐】索引字段的顺序需要考虑字段值去重之后的个数，个数多的放在前面
- 【推荐】ORDER BY，GROUP BY，DISTINCT的字段需要添加在索引的后面
- 【参考】合理创建联合索引（避免冗余），如(a,b,c) 相当于 (a) 、(a,b) 、(a,b,c)
- 【推荐】复合索引中的字段数建议不超过5个
- 【强制】不在选择性低的列上建立索引，例如"性别", "状态"， "类型"
- 【推荐】对于单独条件如果走不了索引，可以使用force –index强制指定索引
- 【强制】禁止给表中的每一列都建立单独的索引
- 【推荐】在varchar字段上建立索引时，必须指定索引长度，没必要对全字段建立索引，根据实际文本区分度决定索引长度即可

#### 行为规范

- 【强制】程序连接不同的数据库要使用不同的账号
- 【强制】禁止使用应用程序配置文件内的帐号手工访问线上数据库
- 【强制】禁止非DBA对线上数据库进行写操作，修改线上数据需要提交工单，由DBA执行，提交的SQL语句必须经过测试
- 【强制】禁止在线上做数据库压力测试
- 【强制】禁止从测试、开发环境直连线上数据库
- 【强制】禁止在主库进行后台统计操作，避免影响业务，可以在离线从库上执行后台统计﻿

#### 流程规范

- 【强制】所有的建表操作需要提前告知该表涉及的查询sql
- 【强制】所有的建表需要确定建立哪些索引后才可以建表上线
- 【强制】所有的改表结构、加索引操作都需要将涉及到所改表的查询sql发出来告知DBA等相关人员
- 【强制】在建新表加字段之前，要求至少要提前3天邮件出来，给dba们评估、优化和审核的时间
- 【强制】批量导入、导出数据需要DBA进行审查，并在执行过程中观察服务
- 【强制】禁止有super权限的应用程序账号存在
- 【强制】推广活动或上线新功能必须提前通知DBA进行流量评估
- 【强制】不在业务高峰期批量更新、查询数据库
- 【强制】隔离线上线下环境（开发测试程序禁止访问线上数据库）
- 【强制】在对大表做表结构变更时，如修改字段属性会造成锁表，并会造成从库延迟，从而影响线上业务，必须在凌晨后业务低峰期执行，另统一用工具pt-online-schema-change避免锁表且降低延迟执行时间
- 【强制】核心业务数据库变更需在凌晨执行
- 【推荐】汇总库开启Audit审计日志功能，出现问题时方可追溯
- 【强制】给业务方开权限时，密码要用MD5加密，至少16位。权限如没有特殊要求，均为select查询权限，并做库表级限制
- 【推荐】如果出现业务部门人为误操作导致数据丢失，需要恢复数据，请在第一时间通知DBA，并提供准确时间，误操作语句等重要线索。
- 【强制】批量更新数据，如update,delete 操作，需要DBA进行审查，并在执行过程中观察服务
- 【强制】业务部门程序出现bug等影响数据库服务的问题，请及时通知DBA便于维护服务稳定
- 【强制】线上数据库的变更操作必须提供对应的回滚方案
- 【强制】批量清洗数据，需要开发和DBA共同进行审查，应避开业务高峰期时段执行，并在执行过程中观察服务状态
- 【强制】数据订正如删除和修改记录时，要先 select ，确认无误才能执行更新语句，避免出现误删除

### sql语句优化

- 把查询看作是一个任务, 它由多个子任务构成, 优化方法如下:

    - 1.优化子任务的响应时间

    - 2.减少子任务数量

    - 拆分复杂SQL为多个小SQL，避免大事务

- 查询慢的原因往往是访问的数据太多:

    - 1.查询了不需要的数据:

        - 查询大量的数据, 但只使用少量的数据

    - 2.使用了语句`SELECT *` 查询了所有列, 特别是连接多个表还查询所有列

#### 一条查询语句的执行过程

![image](./Pictures/mysql/一条sql查询语句的执行过程.avif)

- 1.通过连接器，客户端与MySQL服务器建立连接，并完成身份认证和权限验证过程。在此过程中，客户端需要提供用户名和密码以证明其合法性，服务器则会对这些信息进行核对。

    - 之后client发送`查询`给server

        - mysql的client/server协议是**半双工**, 要么server 发送 client, 要么client 发送 server

            - client 发送一个数据包给 server

            - server 返回多个数据包给 client

                - server会将查询结果缓存至内存, 全部数据包返回客户端后, 才释放

            - `max_allowed_packet` 变量可设置数据包大小

- 2.检查是否开启`查询缓存`（Query Cache）： 如果命中返回结果给client, 否则进入下一个阶段
    - 查询缓存：
        - MySQL 服务层可以将一些查询的结果缓存起来，尤其是频繁执行的查询。如果客户端请求的查询已经存在于缓存中，MySQL 可以直接从缓存中返回结果，而无需重新执行查询。
        - 但是缓存在生产环境一般是不开启的，除非经常有SQL一模一样的查询。缓存严格要求2次SQL请求要完全一样。
            - SQL语句，连接的数据库，协议版本，字符集等因素不一样，都会导致缓存失效。
        - 从8.0版本开始，MySQL不在使用缓存。

- 3.进入`解析器`，之后进入`预处理器`

    - 解析器：是 SQL 查询执行的第一步，它的主要职责是将用户发送的 SQL 语句解析成数据库能够理解和处理的内部结构。这个过程包括以下几个子阶段：

        - `词法分析`：解析器首先对 SQL 语句进行词法分析。词法分析的任务是将 SQL 语句拆分成一系列有意义的“单词”或“标记”（Tokens），例如：表名，列名，操作符，关键字等。这个阶段的输出是一个由标记组成的列表，为后续的语法分析提供基础。

        - `语法分析`：语法分析的任务是根据 SQL 语法规则将标记组合成一个层次化的结构，通常是 `解析树`（Parse Tree） 或 `抽象语法树`（Abstract Syntax Tree）。
            - `解析树`：每个节点代表了 SQL 语句的一个语法结构单元。
            - 在这一阶段，MySQL 会检查 SQL 语句的语法是否正确，并生成语法树。如果 SQL 语法不正确，解析器会报错并拒绝执行。

    - 预处理器：

        - `语义分析`：语义分析主要是检查 SQL 语句中的每个对象是否符合数据库的实际情况。
            - 如表名、字段名是否存在
            - 用户是否对相关表和列拥有执行权限（如 SELECT, INSERT, UPDATE 等）。
            - 数据类型是否匹配等。

- 4.进入`优化器`

    - 逻辑优化：主要目的是通过调整 SQL 语句的结构来提高查询效率。

        - 1.`消除冗余的子查询`：将某些子查询转换为连接或合并查询。
        - 2.`重写查询`：

            - `IN()`函数代替`OR`子句:
                - `IN()`的时间复杂度是O(log n);
                - `OR`的时间复杂度是O(n)
            - `OR` 条件转换为 `UNION` 操作。
        - 3.`查询合并`：将多个查询合并成一个查询。
        - 4.`移除不必要的操作`：例如消除不需要的 `ORDER BY` 或 `DISTINCT`。

    - 物理优化：优化器根据数据库的具体执行引擎、索引、统计信息等做出的决策。这个阶段会根据优化器评估的成本模型选择合适的执行计划。具体的优化措施包括：

        - 1.选择合适的连接方式：比如选择 Nested Loop Join、Hash Join 或 Sort Merge Join。

            - 例子：重新排序连接表的顺序
        - 2.选择索引：通过选择合适的索引来加速数据访问。
        - 3.选择合适的排序方式：通过使用索引扫描或临时表来避免全表扫描。

    - 优化器会使用基于成本的模型（Cost-Based Optimization）来评估每种查询执行计划的成本，选择成本最低的执行计划。其核心是通过计算不同执行计划的资源消耗（如 CPU 时间、I/O 操作等），并选出最优的执行策略。

        > 简单来说就是：优化器会预测并选择成本最低的执行计划

        - 需要向存储引擎获取统计信息

        - 动态优化:根据查询上下文, where的条件值等

            - 静态优化:不依赖查询上下文

        - 有很多原因会导致优化器选择错误的执行计划

        - 不要自以为比优化器聪明


- 5.执行器：根据优化器生成的执行计划来实际执行 SQL 查询。查询执行的最后环节，直接与 MySQL 的存储引擎进行交互。

    - 执行器从`Buffer Pool`中获取数据页的数据，如果数据页没有，需要从磁盘中进行加载。

    - 执行器的主要工作包括：
        - 表扫描：根据查询条件决定是否使用索引、是否全表扫描。
        - 连接操作：根据优化器选择的连接方式（如嵌套循环连接、哈希连接等）执行表之间的数据合并。
        - 排序和聚合：执行查询中的 `ORDER BY`、`GROUP BY` 等操作。
        - 数据返回：查询结果被返回给用户，修改操作则会提交事务。

    - 执行器还需要**管理事务**的提交和回滚操作，确保数据的一致性和持久性。
        - 这些操作会与 MySQL 的日志系统（`Undo Log`、`Redo Log`、`Binlog`） 密切交互，确保事务的 ACID 属性。

    - `last_query_cost` 变量表示上一次查询大概需要随机页查找.这里为10个数据页

        ```sql
        SHOW STATUS LIKE 'last_query_cost';
        +-----------------+-----------+
        | Variable_name   | Value     |
        +-----------------+-----------+
        | Last_query_cost | 10.499000 |
        +-----------------+-----------+
        ```

- 6.存储引擎负责实际的数据存储和检索工作，根据执行器的请求，读取或写入数据。

- 7.如果开启了查询缓存（Query Cache）且查询结果能够命中缓存，查询结果会从缓存中直接返回。而如果没有开启Query Cache或缓存没有命中，MySQL会直接返回查询结果。


#### select优化

- [knowclub：SQL语句优化的 14个最佳实践](https://mp.weixin.qq.com/s/mwD1k973wIPaydgSdDnZAw)

- 避免使用select *

    - 在实际的业务场景中，也许我们真的只需要用到其中的一两个列。

    - `select *`的问题：
        - 检查了很多数据，它浪费了数据库资源，例如内存或CPU。
        - 在通过网络IO传输数据的过程中，也会增加数据传输的时间。
        - 不会使用覆盖索引，并且会有大量的返回表操作，导致查询SQL的性能低下。

    ```sql
    // 正确示例。查询SQL语句时，只检查需要用到的列，多余的列根本不需要检查。
    select name, age from user where id = 1;
    ```

- 将union替换为 union all

    - 重新排序的过程需要遍历、排序和比较，比较耗时，也消耗较多的CPU资源。
    - 除非有一些特殊场景，比如 after union all，结果集中出现重复数据，业务场景中不允许出现重复数据，union可以使用。

    ```sql
    // 错误示例
    (select * from user where id=1)
    union
    (select * from user where id=2);

    // 正确示例
    (select * from user where id=1)
    union all
    (select * from user where id=2);
    ```

- 小表、大表的联合查询

    - `in`适用于左边的大表和右边小表。
    - `exists`适用于左边的小表和右边的大表。

    ```sql
    // 这可以使用in关键字来实现：
    select * from order
    where user_id in (select id from user where status=1)

    // 这也可以使用exists关键字来实现：
    select * from order
    where exists (select 1 from user where order.user_id = user.id and status=1)
    ```

- 使用limit

    - 先查询所有数据，有点浪费资源。那么，如何优化呢？使用limit 1只返回用户下单时间最短的数据。
    ```sql
    select id, create_date from order where user_id=123 order by create_date asc limit 1;
    ```

    - 在删除或修改数据时，为防止误操作，导致删除或修改不相关的数据，limit也可以在SQL语句的末尾加上。这样即使操作错误，比如id错误，也不会影响太多数据。
    ```sql
    update order set status=0,edit_time=now(3) where id>=100 and id<200 limit 100;
    ```

- 不要在in关键字中使用过多的值。
    ```sql
    // 错误示例。如果我们不做任何限制，查询语句可能一次查询到很多数据，很容易导致接口超时。
    select id,name from category where id in (1,2,3...100000000);
    // 正确示例
    select id,name from category where id in (1,2,3...100) limit 500;
    ```

- 增量查询
    - 通过远程接口查询数据，然后将其同步到另一个数据库。
    - 如果你直接获取所有数据，则同步它。虽然这样很方便，但也带来了一个很大的问题，就是如果数据很多，查询性能会很差。
    ```sql
    // 错误示例
    select * from user;

    // 按照id和时间的升序，每次只同步一批数据，而这批数据只有100条记录。每次同步完成后，保存这100条数据中最大的id和时间，以供下一批数据同步时使用。
    select * from user
    where id>#{lastId} and create_time >= #{lastCreateTime}
    limit 100;
    ```

- 高效的分页

    ```sql
    // 错误示例。MySQL会查找1,000,020条数据，然后丢弃前1,000,000条数据，只检查最后20条数据，这样很浪费资源。
    select id,name,age
    from user limit 1000000,20;

    // 正确示例
    select id,name,age
    from user where id > 1000000 limit 20;
    // 正确示例。还可以使用它between来优化分页。between 应该在唯一索引上进行分页，否则会出现每页大小不一致的情况。
    select id,name,age
    from user where id between 1000000 and 1000020;
    ```

- 尽量避免使用子查询，可以把子查询优化为join操作（子查询的结果集无法使用索引，子查询会产生`临时表`操作，如果子查询数据量大会影响效率，消耗过多的CPU及IO资源）

    - 从两个以上的表中查询数据，一般有两种实现方式：子查询和连接查询。

    ```sql
    -- 子查询。缺点是MySQL在执行子查询时，需要创建临时表。查询完成后，需要删除这些临时表，有一些额外的性能消耗。
    select * from order
    where user_id in (select id from user where status=1)

    -- 连接查询
    select o.* from order o
    inner join user u on o.user_id = u.id
    where u.status=1
    ```

- 不推荐使用join（关联查询）的原因：

    - 1.DB承担的业务压力大，能减少负担就减少。当表处于百万级别后，join导致性能下降；
    - 2.分布式的分库分表。这种时候是不建议跨库join的。目前mysql的分布式中间件，跨库join表现不良。
    - 3.修改表的schema，单表查询的修改比较容易，join写的sql语句要修改，不容易发现，成本比较大，当系统比较大时，不好维护。

    - 解决方法：
        - 查询id集的时候，使用`IN()`代替关联查询：可以让MySQL按照ID顺序进行查询，这可能比随机的关联要更高效。
        - 子查询:在业务层，单表查询出数据后，作为条件给下一个单表查询。通过调整参数max_allowed_packet ，可以修改一条sql的最大值。建议在业务上做好处理，限制一次查询出来的结果集是能接受的。

- 连接表不宜过多

    - 超过三个表禁止 join。（需要 join 的字段，数据类型必须绝对一致；多表关联查询时，保证被关联的字段需要有索引。即使双表 join 也要注意表索引、SQL 性能。）

    ```sql
    // 错误示例
    select a.name,b.name.c.name,d.name
    from a
    inner join b on a.id = b.a_id
    inner join c on c.b_id = b.id
    inner join d on d.c_id = c.id
    inner join e on e.d_id = d.id
    inner join f on f.e_id = e.id
    inner join g on g.f_id = f.id

    // 正确示例
    select a.name,b.name.c.name,a.d_name
    from a
    inner join b on a.id = b.a_id
    inner join c on c.b_id = b.id
    ```

- left join和inner join
    - inner join：MySQL会自动选择两张表中的小表来驱动大表，所以性能上不会出现太多问题。
    - left jointo：会默认使用 left join 关键字来驱动右边的表。要使用左边的小表，右边的大表。


- group by

    ```sql
    // 错误示例。这种写法性能较差。它首先根据用户id对所有订单进行分组，然后过滤用户id大于等于200的用户。
    select user_id,user_name from order
    group by user_id
    with user_id <= 200;

    // 正确示例。分组前使用where条件过滤掉多余的数据，这样分组时效率会更高
    select user_id,user_name from order
    where user_id <= 200
    group by user_id
    ```

- or条件

    - 对于 or 子句，如果要利用索引，则or 之间的每个条件列都必须用到索引；如果没有索引，则应该考虑增加索引。
    - sql中使用到OR的改写为用IN()  (or的效率没有in的效率高)

- COUNT()函数优化

    - 统计表中记录数时使用COUNT(*)，而不是COUNT(primary_key)和COUNT(1)
        - 说明：count( * ) 会统计值为 NULL 的行，而 count( 列名 ) 不会统计此列为 NULL 值的行

    - 查询大量的数据, 但只使用少量的数据:

        ```sql
        -- 共扫描9行, 只获取2行
        SELECT COUNT(*) FROM people
        WHERE ID > 7;

        -- 优化:通过总行数减去多数行
        SELECT (SELECT COUNT(*) FROM people) - COUNT(*) FROM people
        WHERE ID <= 7;
        ```

    - 使用`EXPLAIN` 获取扫描行数的近似值, 并不是所有业务都需要精确的COUNT()值, 如谷歌的搜索结果:

        ```sql
        EXPLAIN SELECT COUNT(*) FROM people\G;
        ```

    - 使用COUNT()代替SUM():
        ```sql
        SELECT SUM(salary = 1000),
        SUM(salary = 2000) FROM people;

        -- 使用COUNT()代替SUM()
        SELECT COUNT(salary = 1000 or null),
        COUNT(salary = 2000 or null) FROM people;
        ```

- 延迟关联

    - 通过子查询查找覆盖索引的字段. 这叫作延迟关联(deferred join)

    - `LIMIT 50, 5`:需要查询55条记录, 但只返回最后5条, 前50条被抛弃
        ```sql
        SELECT * FROM cnarea_2019 LIMIT 50, 5;

        -- 延迟关联进行优化
        SELECT * FROM cnarea_2019
        INNER JOIN
        (SELECT id FROM cnarea_2019 LIMIT 50, 5)
        as lim USING(id);
        ```

- 禁止在WHERE条件的属性上使用函数或者表达式

- 禁止负向查询，以及%开头的模糊查询

- 应用程序必须捕获SQL异常，并有相应处理

- 事务要简单，整个事务的时间长度不要太长

- 避免在数据库中进行数学运算或者函数运算(MySQL不擅长数学运算和逻辑判断，也容易将业务逻辑和DB耦合在一起)

- 获取大量数据时，建议分批次获取数据，每次获取数据少于2000条，结果集应小于1M

- 注意使用性能分析工具 Sql explain  / showprofile  /   mysqlsla

- 能不用NOT IN就不用NOT IN，坑太多了，会把空和NULL给查出来

- 禁止跨库查询（为数据迁移和分库分表留出余地，降低耦合度，降低风险）

- 在代码中写分页查询逻辑时，若 count 为 0 应直接返回，避免执行后面的分页语句

- 使用 ISNULL()来判断是否为 NULL 值

##### [dbaplus社群：MySQL用limit语句性能暴跌，怎么救？](https://mp.weixin.qq.com/s/V4vzIbB8DdIaYhePuisMlA)

- 下面的语句表示从 test 表中查询 val 等于4的记录，并返回第300001到第300005条记录：

    ```sql
    select * from test where val=4 limit 300000,5;
    ```

    - 这样的语句看起来很简单，但是在实际使用中，会影响性能

        - 因为 Limit 会导致 MySQL扫描过多的数据记录或者索引记录，而且大部分扫描到的记录都是无用的。

- 省略索引介绍...

- 非聚簇索引为例：

    - 假设我们有一张表 test 
        - 它有两个字段 id 和 val ，其中 id 是主键，val 是非唯一非聚簇索引。
        - 表中有 500 万条数据，val 的值从 1 到 10 随机分布。

    - 我们执行以下语句：

        ```sql
        select * from test where val=4 limit 300000,5;
        ```

        - 首先，MySQL会选择 val 索引作为执行计划，因为它可以缩小查询范围。然后，MySQL会从 val 索引的根节点开始查找，沿着 B+ 树向下搜索，直到找到第一个 val 等于 4 的叶子节点。接着，MySQL会沿着叶子节点的指针向右移动，扫描所有 val 等于 4 的叶子节点，并记录它们对应的 id 值和数据记录地址。

        - 由于我们要返回第 300001 到第 300005 条记录，所以 MySQL必须扫描至少 300005 个叶子节点，才能确定哪些是我们需要的。这就导致了大量的随机 I/O 操作，在磁盘上读取索引页。

        - 接下来，MySQL还要根据叶子节点指向的数据记录地址，去访问数据页，获取查询所需的所有字段。由于我们要返回所有字段（select *），所以 MySQL必须访问至少 300005 次数据页，才能获取到完整的数据记录。这又导致了大量的随机 I/O 操作，在磁盘上读取数据页。

        - 最后，MySQL还要对扫描到的数据记录进行排序和过滤，抛弃前面 300000 条无用的记录，只保留后面 5 条有用的记录。这就导致了大量的 CPU 和内存消耗，在内存中进行排序和过滤。

        - 综上所述，MySQL在执行这条语句时，需要做以下操作：
            - 扫描至少 300005 个索引页
            - 访问至少 300005 次数据页
            - 排序和过滤至少 300005 条数据记录

        - 这些操作都是非常耗时和耗资源的。为了返回 5 条有用的记录，MySQL不得不扫描和访问大量的无用的记录。这就是 Limit 会影响性能的原因。

- 优化问题：

    - 1.使用索引覆盖扫描。

        - 如果我们只需要查询部分字段，而不是所有字段，我们可以尝试使用索引覆盖扫描，也就是让查询所需的所有字段都在索引中，这样就不需要再访问数据页，减少了随机 I/O 操作。例如，如果我们只需要查询 id 和 val 字段，我们可以执行以下语句：

        - 这样，MySQL只需要扫描索引页，而不需要访问数据页，提高了查询效率。

        ```sql
        select id,val from test where val=4 limit 300000,5;
        ```

    - 2.使用子查询。

        - 如果我们不能使用索引覆盖扫描，或者查询字段较多，我们可以尝试使用子查询，也就是先用一个子查询找出我们需要的记录的 id 值，然后再用一个主查询根据 id 值获取其他字段。例如，我们可以执行以下语句：

        - 这样，MySQL先执行子查询，在 val 索引上进行范围扫描，并返回 5 个 id 值。然后，MySQL再执行主查询，在 id 索引上进行点查找，并返回所有字段。这样，MySQL只需要扫描 5 个数据页，而不是 300005 个数据页，提高了查询效率。

        ```sql
        select * from test where id in (select id from test where val=4 limit 300000,5);
        ```

    - 3.使用分区表。

        - 如果我们的表非常大，或者数据分布不均匀，我们可以尝试使用分区表，也就是将一张大表分成多个小表，并按照某个字段或者范围进行划分。这样，MySQL可以根据条件只访问部分分区表，而不是整张表，减少了扫描和访问的数据量。例如，如果我们按照 val 字段将 test 表分成 10 个分区表（test_1 到 test_10），每个分区表只存储 val 等于某个值的记录，我们可以执行以下语句：

        ```sql
        select * from test_4 limit 300000,5;
        ```

        - 这样，MySQL只需要访问 test_4 这个分区表，而不需要访问其他分区表，提高了查询效率。

#### 索引优化

- SQL 性能优化的目标：至少要达到 range 级别，要求是 ref 级别，如果可以是 consts最好

- 避免不走索引的各种场景

    - 在下面的SQL语句中的WHERE子句不使用索引：

        - 1.条件中有or，且or左右列并非全部由索引 Select col1 from table where key1=1 or no_key=2
        - 2.like查询以%开头
        - 3.where条件仅包含复合索引非前置列
            ```sql
            -- 索引包含key_part1，key_part2，key_part3三列，但SQL语句没有包含索引前置列。
            Select col1 from table where key_part2=1 and key_part3=2
            ```

        - 4.隐式类型转换造成不使用索引
            ```sql
            -- 由于索引对列类型为varchar，但给定的值为数值，涉及隐式类型转换，造成不能正确走索引。
            Select col1 from table where key_varchar=123;
            ```

- 避免对索引字段进行计算

    - 避免对索引字段进行任何计算操作，对索引字段的计划操作会让索引的作用失效，令数据库选择其他的较为低效率的访问路径。

- 避免对索引字段进行是否NULL值判断

    - 避免使用索引列值是否可为空的索引，如果索引列值可以是空值，在SQL语句中那些要返回NULL值的操作，将不会用到索引。

- 避免对索引字段不等于符号

    - 使用索引列作为条件进行查询时，需要避免使用<>或者!=等判断条件。如确实业务需要，使用到不等于符号，需要在重新评估索引建立，避免在此字段上建立索引，改由查询条件中其他索引字段代替。

- 限制索引的数量
    - 索引可以显着提高查询SQL的性能，但索引的数量并不是越多越好。
    - 因为在表中添加新数据时，需要同时为其创建索引，并且索引需要额外的存储空间和一定的性能消耗。
    - 单个表的索引数尽量控制在5以内，单个索引的字段数不要超过5个。MySQL用来保存索引的B+树的结构，B+树索引在插入、更新和删除操作时需要更新。如果索引太多，会消耗很多额外的性能。

    - 那么，高并发系统如何优化索引数量呢？

        - 如果可以建立联合索引，不建立单一索引，可以删除无用的单一索引。将部分查询功能迁移到其他类型的数据库，如Elastic Seach、HBase等，只需要在业务表中建立几个关键索引即可。

#### group by 语句优化

- [技术分享 | MySQL 生产环境 GROUP BY 优化实践](https://mp.weixin.qq.com/s/0H24lqZ9IxNMG5R_q62DyQ)

- 一个生产环境上 GROUP BY 语句 的优化案例。

    - SQL 优化前：执行时间 3s
        ```sql
        SELECT taskUniqueId,
            max(reportTime) AS reportTime
        FROM task_log_info
        WHERE reportTime > '2024-04-07'
        GROUP BY  taskUniqueId
        ```

    - SQL 优化后：执行时间 30ms！
        ```sql
        SELECT a.taskUniqueId,
                reportTime
        FROM task_log_info a
        JOIN
            (SELECT taskUniqueId,
                max(id) AS id
            FROM task_log_info
            GROUP BY  taskUniqueId ) tmp
            ON a.id=tmp.id
                AND reportTime>='2024-04-07'
        ```

    - 注意：id 和 reporttime 字段值具有相关性的情况才可以这样修改。

    - 两条 SQL 的 GROUP BY 使用了同一个索引，但是效率却相差很多，这到底是为什么呢？

    - 结论：`Loose Index Scan`（松散索引扫描） 相对于 `Tight Index Scan`（紧凑索引扫描）， 在一些情况下可以大大减少扫描的行数。
        - 使用 `Loose Index Scan` 时，`Extra: Using index for group-by`。

- 对于 GROUP BY 在使用索引上的优化，分为两种情况讨论：

    - 表上无索引。执行时，会生成临时表进行分组。可以通过索引来优化，来避免使用临时表。
    - 表上有索引。 GROUP BY 语句有几种扫描算法：
        - 松散索引扫描（Loose Index Scan）
        - 紧凑索引扫描（Tight Index Scan）
        - 两种算法结合

```sql
-- 创建表。4个字段，但只有前3个字段有索引
CREATE TABLE t2 (
  id INT AUTO_INCREMENT,
  c1 CHAR(64) NOT NULL,
  c2 CHAR(64) NOT NULL,
  c3 CHAR(64) NOT NULL,
  c4 CHAR(64) NOT NULL,
  PRIMARY KEY(id),
  KEY c1_c2_c3_idx (c1,c2,c3)
) ENGINE=INNODB;

-- 插入数据
INSERT INTO t2 VALUES
(null,'a','b','a','a'), (null,'a','b','a','a'),
(null,'a','c','a','a'), (null,'a','c','a','a'),
(null,'a','d','b','b'), (null,'a','b','b','b'),
(null,'d','b','c','c'), (null,'e','b','c','c'),
(null,'f','c','d','d'), (null,'k','c','d','d'),
(null,'y','d','y','y'), (null,'f','b','f','y'),
(null,'a','b','a','a'), (null,'a','b','a','a'),
(null,'a','c','a','a'), (null,'a','c','a','a'),
(null,'a','d','b','b'), (null,'a','b','b','b'),
(null,'d','b','c','c'), (null,'e','b','c','c'),
(null,'f','c','d','d'), (null,'k','c','d','d'),
(null,'y','d','y','y'), (null,'f','b','f','y');

-- 收集统计信息，否则可能影响测试
ANALYZE TABLE t2;
```

##### 无索引情况

- 不使用索引的 `GROUP BY`

    - `Extra: Using temporary`：可以看到这里使用到了临时表。

    ```sql
    -- c4字段没有索引
    explain select c4,count(*) from t2 group by c4 order by null;
    +----+-------------+-------+------+---------------+--------+---------+--------+------+-----------------+
    | id | select_type | table | type | possible_keys | key    | key_len | ref    | rows | Extra           |
    +----+-------------+-------+------+---------------+--------+---------+--------+------+-----------------+
    | 1  | SIMPLE      | t2    | ALL  | <null>        | <null> | <null>  | <null> | 24   | Using temporary |
    +----+-------------+-------+------+---------------+--------+---------+--------+------+-----------------+

    explain select c4,count(*) from t2 group by c4;
    +----+-------------+-------+------+---------------+--------+---------+--------+------+---------------------------------+
    | id | select_type | table | type | possible_keys | key    | key_len | ref    | rows | Extra                           |
    +----+-------------+-------+------+---------------+--------+---------+--------+------+---------------------------------+
    | 1  | SIMPLE      | t2    | ALL  | <null>        | <null> | <null>  | <null> | 24   | Using temporary; Using filesort |
    +----+-------------+-------+------+---------------+--------+---------+--------+------+---------------------------------+
    ```

- 使用索引的 `GROUP BY`

    - `Extra: Using index & type: index`：表示全索引扫描。这种情况下，如果表数据量很大，还是会比较耗时的。

    ```sql
    -- c1字段有索引。这里为紧凑索引扫描（Tight Index Scan）
    explain select c1,count(*) from t2 group by c1;
    +----+-------------+-------+-------+---------------+--------------+---------+--------+------+-------------+
    | id | select_type | table | type  | possible_keys | key          | key_len | ref    | rows | Extra       |
    +----+-------------+-------+-------+---------------+--------------+---------+--------+------+-------------+
    | 1  | SIMPLE      | t2    | index | <null>        | c1_c2_c3_idx | 192     | <null> | 24   | Using index |
    +----+-------------+-------+-------+---------------+--------------+---------+--------+------+-------------+
    ```

##### 有索引的情况

- 有索引并正常使用的情况，索引的访问有多种算法：

    - 1.松散索引扫描（Loose Index Scan）：
        - `Extra: Using index for group-by`：不需要扫描所有的索引记录，根据分组前缀（GROUY BY 的字段）跳跃扫描部分

    - 2.紧凑索引扫描（Tight Index Scan）：
        - `Extra: Using index`：需要扫描范围或全部的索引记录

    - 3.两种算法结合使用

- 1.松散索引扫描（Loose Index Scan）：
    ```sql
    -- 松散索引扫描（Loose Index Scan）：
    explain SELECT c1,MIN(c2) FROM t2 GROUP BY c1;
    +----+-------------+-------+-------+---------------+--------------+---------+--------+------+--------------------------+
    | id | select_type | table | type  | possible_keys | key          | key_len | ref    | rows | Extra                    |
    +----+-------------+-------+-------+---------------+--------------+---------+--------+------+--------------------------+
    | 1  | SIMPLE      | t2    | range | <null>        | c1_c2_c3_idx | 64      | <null> | 7    | Using index for group-by |
    +----+-------------+-------+-------+---------------+--------------+---------+--------+------+--------------------------+

    SELECT c1,MIN(c2),COUNT(*) FROM t2 GROUP BY c1;
    +----+---------+----------+
    | c1 | MIN(c2) | COUNT(*) |
    +----+---------+----------+
    | a  | b       | 12       |
    | d  | b       | 2        |
    | e  | b       | 2        |
    | f  | b       | 4        |
    | k  | c       | 2        |
    | y  | d       | 2        |
    +----+---------+----------+
    ```

    - 跳跃扫描部分索引，而不需要扫描全部。
    ![image](./Pictures/mysql/group_by-松散索引扫描.avif)

    - 使用场景
        - 1.当需要获取每个分组的某条记录，而非对全部记录做聚合运算时可能会用到，比如：
            - 最小值或最大值：`MIN()`、`MAX()`
            - 统计类：`COUNT(distinct)`、`SUM(distinct)`、`AVG(distinct)`

            - 注意：如果 SQL 语句中既有 1-2 个 `min`、`max`，也有 1-3 个 `count(distinct)`、`sum(distinct)`、`avg(distinct)` 时，无法用到 Loose index；两组分别出现的时候才可能会用到。

        - 2.`distinct` 可以转换为 `GROUP BY` 进行处理。

        - 使用到 Loose Index Scan 其他必要条件：

            - 查询基于一个表。
            - GROUP BY 的字段满足索引的最左匹配原则。
            - 聚合函数使用的列，必须包含在索引上；且使用多个聚合函数时，必须使用相同的字段，且 GROUP BY 字段+聚合函数字段也必须满足最左匹配原则。
            - 索引中字段必须是全字段索引，而不能是前缀索引，例如 INDEX(c1(10))

            - 以上条件结合索引的结构就很好理解了。

        - 另外，在选择是否使用 Loose Index Scan 时，也会受到 SQL、统计信息、成本等因素的影响。

        ```sql
        -- 场景 1
        -- MIN()、MAX()
        SELECT c1,MIN(c2),MAX(c2) FROM t2 GROUP BY c1;
        SELECT c1,c2,MAX(c3),MIN(c3)  FROM t2 WHERE c2 > 'k' GROUP BY c1, c2;
        SELECT c1,c2,MAX(c3),MIN(c3)  FROM t2 WHERE c3 > 'k' GROUP BY c1, c2;
        SELECT c1,c2,c3,MAX(id) FROM t2  GROUP BY c1,c2,c3;
        SELECT c1, c2 FROM t2 WHERE c3 = 'd' GROUP BY c1, c2;

        -- 以下几种情况在当前数据量和数据分布下没有用到，和成本计算有关，结合后文成本对比的章节改变数据量和数据分布测试出来
        SELECT c1,c2,MAX(c3),MIN(c3)  FROM t2 WHERE c1>='k' and c2 > 'f' GROUP BY c1, c2;
        SELECT DISTINCT c1, c2 FROM t2 where c1>'k';
        SELECT c1,c2,count(distinct c3) FROM t2 where c1>='k' and c2>'k' GROUP BY c1,c2;

        -- count(distinct)、sum(distinct)、avg(distinct)
        SELECT c1,count(distinct c2,c3) FROM t2 GROUP BY c1;
        SELECT c1,c2,sum(distinct c3) FROM t2 GROUP BY c1,c2;
        SELECT c1,c2,sum(distinct c3) FROM t2 where c2>'k' GROUP BY c1,c2;

        -- 场景 2
        SELECT DISTINCT c1, c2 FROM t2;

        -- 无法使用到 Loose Index Scan
        SELECT c1,count(distinct c2,c3),sum(distinct c2) FROM t2 GROUP BY c1;
        ```

- 2.紧凑索引扫描（Tight Index Scan）：

    ```sql
    -- 紧凑索引扫描（Tight Index Scan）：
    explain SELECT c1,COUNT(*) FROM t2 GROUP BY c1;
    +----+-------------+-------+-------+---------------+--------------+---------+--------+------+-------------+
    | id | select_type | table | type  | possible_keys | key          | key_len | ref    | rows | Extra       |
    +----+-------------+-------+-------+---------------+--------------+---------+--------+------+-------------+
    | 1  | SIMPLE      | t2    | index | <null>        | c1_c2_c3_idx | 192     | <null> | 24   | Using index |
    +----+-------------+-------+-------+---------------+--------------+---------+--------+------+-------------+
    ```
    ![image](./Pictures/mysql/group_by-紧凑索引扫描.avif)

    - 对于无法使用到 Loose Index Scan 的一些 GROUP BY，在满足索引最左匹配原则情况下可能会用到 Tight Index Scan。

    - 该种方式实际上是范围索引扫描或全部索引扫描，数据量大的情况下性能仍然可能会比较差，但是相比无索引还是可以避免使用临时表和全表扫描，在某些情况下有一定的优化作用。

- 3.两种算法结合

    - 对于统计类 AVG(DISTINCT) 即 SUM|COUNT|AVG(distinct)，可能会出现使用松散索引扫描（Loose Index Scan）成本大于紧凑索引扫描（Tight Index Scan）的情况。

    - 两种方式在引擎层主要包含的成本：

        - 1.`Loose Index Scan`
            - 读取分组的第一条记录，得到分组前缀
            - 根据分组前缀读取分组的第一条或最后一条记录返回给 SERVER 层
        - 2.`Tight Index Scan`
            - 从 ENGINE 层读取数据，返回给 SERVER 层
            - SERVER 层判断是否符合 WHERE 条件的记录，并根据聚合函数进行处理
        - 可以看到，对于 ENGINE 层的访问，`Loose Index Scan` 的成本有可能会高于 `Tight Index Scan`，且在 MySQL 中，引擎层读取数据页的成本常数是 1，SERVER 层判断一条记录的成本常数是 0.2。

        - 至于 MIN/MAX 为什么不会出现 Loose Index Scan 成本 > Tight Index Scan 成本，我理解只有到组内值都是唯一的情况下才会出现吧？那这样也没有必要去分组求最值了。

        - 在某些情况下，Loose Index Scan 的成本会高于 Tight Index Scan，比如：

            - 当分组较多，但组内的记录数并不多或唯一值较高的情况，对于每一个分组，都需要扫描两次，能跳过的记录数很少的情况。即 Loose Index Scan 在分组字段的选择性相对不太高，组内的数据量相对较多的情况更适用。

    - `Extra: Using index for group-by (scanning)`：该方式可以理解为 Loose Index Scan 的扩展或两种方式的结合（索引顺序扫描的同时进行去重）。

        ![image](./Pictures/mysql/group_by-两种算法结合.avif)

        ```sql
        explain select count(distinct c1,c2) from t2;
        +----+-------------+-------+-------+---------------+--------------+---------+--------+------+-------------------------------------+
        | id | select_type | table | type  | possible_keys | key          | key_len | ref    | rows | Extra                               |
        +----+-------------+-------+-------+---------------+--------------+---------+--------+------+-------------------------------------+
        | 1  | SIMPLE      | t2    | range | <null>        | c1_c2_c3_idx | 128     | <null> | 13   | Using index for group-by (scanning) |
        +----+-------------+-------+-------+---------------+--------------+---------+--------+------+-------------------------------------+
        ```

#### 增删改语句优化

- 大批量插入数据

    - 方法一：
        ```sql
        insert into tablename values(1,2);
        insert into tablename values(1,3);
        insert into tablename values(1,4);
        ```

    - 方法二：
        ```sql
        insert into tablename values(1,2),(1,3),(1,4);
        ```

    - 选择后一种方法的原因有二。

        - 减少SQL语句解析的操作， MySQL没有类似Oracle的share pool，采用方法二，只需要解析一次就能进行数据的插入操作；

        - SQL语句较短，可以减少网络传输的IO。


- 避免使用insert..select..语句
    - 如果select的表是innodb类型的，不论insert的表是什么类型的表，都会对select的表的纪录进行锁定。
        - Oracle并不存在类似的问题，所以在Oracle的应用中insert...select...操作非常常见。

- 删除全表中记录时，使用truncate代替delete
    - 使用delete语句的操作会被记录到undo块中，删除记录也记录binlog，当确认需要删除全表时，会产生很大量的binlog并占用大量的undo数据块，此时既没有很好的效率也占用了大量的资源。
    - 使用truncate操作有其极少的资源占用与极快的时间。

- 禁止单条SQL语句同时更新多个表

- INSERT语句使用batch提交（INSERT INTO tableVALUES(),(),()……），values的个数不应过多

- 尽量不要使用物理删除（即直接删除，如果要删除的话提前做好备份），而是使用逻辑删除，使用字段delete_flag做逻辑删除，类型为tinyint，0表示未删除，1表示已删除

#### 慢查询优化

- 慢查询日志记录以下3个指标:

    - 1.响应时间(最重要的指标, 查询优化实际指减少查询的响应时间):

        - 排队时间:等待某些资源的时间, 如等待io, 等待锁...

        - 服务时间:真正花费的时间

    - 2.扫描行数

        <span id="#explain-type"></span>
        - 访问类型(`EXPLAIN` 的`type` 字段):访问类型决定了访问的快慢和访问的行数

            - 以下`type`的排列顺序为, 从慢到快, 从行数多到少:

                - ALL(全表)-> index(索引)-> range(范围)-> ref(唯一性索引)-> const(常数:单个值)

    - 3.返回行数

        - `EXPLAIN` 的`Extra` 字段为`Using where`时:表示从返回的数据过滤不匹配的记录


- [慢SQL的治理经验](https://mp.weixin.qq.com/s/fqIOUT1YcUuLIL95IVPD_Q)

- 淘宝避免慢查询的sql规范：

    - [Druid SQL Parser](https://github.com/alibaba/druid/wiki/SQL-Parser)是阿里巴巴的开源项目，Druid SQL Parser进行SQL解析，可以将SQL语句解析为语法树，可以解析SQL的各个部分，如SELECT语句、FROM语、WHERE语句等，并且可以方便获取SQL语句的结构信息，如表名、列名、操作符等。通过分析SQL，可以轻松判断SQL是否符合规约。


    - 1.【强制】不要使用count(列名)或count(常量)来替代count(*)，count(*)就是SQL92定义的标准统计行数的语法，跟数据库无关，跟NULL和非NULL无关。

    - 2.【强制】count(distinct col) 计算该列除NULL之外的不重复数量。注意 count(distinct col1, col2) 如果其中一列全为NULL，那么即使另一列有不同的值，也返回为0。

    - 3.【强制】当某一列的值全是NULL时，count(col)的返回结果为0，但sum(col)的返回结果为NULL，因此使用sum()时需注意NPE问题。

    - 4.【强制】使用ISNULL()来判断是否为NULL值。

    - 5.【强制】对于数据库中表记录的查询和变更，只要涉及多个表，都需要在列名前加表的别名（或表名）进行限定。

    - 6.【强制】在代码中写分页查询逻辑时，若count为0应直接返回，避免执行后面的分页语句。

    - 7.【强制】不得使用外键与级联，一切外键概念必须在应用层解决。

    - 8.【强制】禁止使用存储过程，存储过程难以调试和扩展，更没有移植性。

    - 9.【强制】IDB数据订正（特别是删除或修改记录操作）时，要先select，避免出现误删除，确认无误才能提交执行。

- 对于慢SQL的定义，执行超过1s的SQL为慢SQL。

- 慢SQL由于执行时间长，会导致：

    - 1.系统的响应时间延迟，影响用户体验
    - 2.资源占用增加，增高了系统的负载，其他请求响应时间也可能会收到影响。
    - 3.慢SQL占用数据库连接的时间长,如果有大量慢SQL查询同时执行，可能会导致数据库连接池的连接被全部占用，导致数据连接池打满、缓冲区溢出等问题，使数据库无法响应其他请求。
    - 4.还有可能造成锁竞争增加、数据不一致等问题

- 产生的原因：
    - 1.缺乏索引/索引未生效，导致数据库全表扫描，会产生大量的IO消耗，产生慢SQL。
    - 2.单表数据量太大，会导致加索引的效果不够明显。
    - 3.SQL语句书写不当，例如join或者子查询过多、in元素过多、limit深分页问题、order by导致文件排序、group by使用临时表等。
    - 4.数据库在刷“脏页”，redo log写满了，导致所有系统更新被堵住，无法写入了。
    - 5.执行SQL的时候，遇到表锁或者行锁，只能等待锁被释放，导致了慢SQL。

- 发现慢SQL：

    - 1.超过1s的为真实存在的慢SQL：通过阿里巴巴开发[TDDL中间件](https://github.com/alibaba/tb_tddl)连接数据库，TDDL会将慢SQL日志统一记录到机器的tddl-slow.log文件中。

    - 2.除了执行时长超过1s的慢SQL之外，我们还额外关注了未来可能劣化的慢SQL：基于JVM Sandbox进行SQL流水记录的采集

        - JVMSandbox完成数据采集后，通过发送metaq消息的方式，与系统进行对话。对于不同种类的采集消息，我们通过不同的字段加以匹配，最终可以获得每一条SQL流水对应的SQL文本、执行时长、sql参数、db名称、ip端口、sql_mapper资源文件等全部信息，具体如图所示：

        - 以上可以采集到应用的全部SQL，量级是很大的。我们采用了Blink创建时间窗口，进行数据聚合，实时数据处理，减少回流的在线数据量

        ![image](./Pictures/mysql/慢查询优化-JVMSandbox方法.avif)

- 如何推动治理慢SQL：发现-追踪-治理机制。

    - 慢SQL治理中涵盖了生产环境、开发环境的慢SQL，区别在于：生产环境中为已经上线的存量慢SQL，开发环境中为新引入的慢SQL，对开发环境引入的慢SQL，修复代价要小于生产环境。

    - 存量慢SQL治理：

        - 存量慢SQL治理的难点在于，历史遗留下的慢SQL可能量级很大，所以要区分慢SQL治理的优先级。我们制定了健康分机制，对SQL分批分级治理。

            - 健康分主要受SQL的执行次数、扫描行数、执行时长影响。
            - 另外根据应用中包含慢SQL的数量、平均SQL执行数据等，给应用打出健康分。
            - 再根据部门维度汇总，根据应用等级、应用健康分情况等，计算出部门维度的健康分。

            ![image](./Pictures/mysql/慢查询优化-淘宝的健康分机制.avif)

        - 高危慢SQL，会建立Issue持续追踪，Issue存在超期时间，超期后会影响团队健康分。另外，提供应用维度、部门维度的整体慢SQL风险大盘以及排名，针对重点业务、慢SQL高发团队等，进行集中的推进治理。

    - 增量慢SQL治理：

        - 我们希望增量慢SQL能在上线前得到解决，即分支内不要引入慢SQL或者风险SQL

        - 我们建立了开发环境下增量慢SQL发现机制，并建立发布前卡点能力。

            ![image](./Pictures/mysql/慢查询优化-淘宝的增量慢SQL机制.avif)

        - 增量慢SQL的修复代价是小于存量慢SQL的，因此这里我们添加了分支定位的能力。同一应用存在多个同学共同开发的情况，有效的分支定位，可以准确指派慢SQL引入人，实现快速推动治理。

        - 以git上代码改动为切入点，完成了引入慢SQL的sql_map与修改人之间的关系映射，大致逻辑如下

            - 1.监听应用部署消息
            - 2.获取应用信息，拿到git地址
            - 3.将本次部署分支与master分支做分支diff
            - 4.解析sql_map文件，获取本次修改的sql内容
            - 5.记录被修改sql_id与分支的对应关系
            - 6.根据sql_id查询对应分支

            - 这样就可以精准匹配到增量SQL的引入分支，从而指派到开发者，实现了定向问题指派和追踪，并且可以方便完成分支发布前的管控能力。如果存在增量慢SQL，分支发布，合并到master之前，会触发卡点，需要问题解决才能发布。

- 开启慢查询

    - 慢查询日志开销很低, 不需要担心额外的开销, 但会消耗磁盘空间

    ```sh
    [mysqld]
    slow_query_log = ON
    slow_query_log_file = /var/log/mysql/mysql-slow.log  # 指定慢查询日志文件路径（Linux）
    long_query_time = 1  # 设置慢查询的时长为1秒
    ```

- 查看慢查询相关配置:

    ```sql
    show variables like "%slow%";

    show status like "%slow%";
    ```

##### mysqldumpslow：慢查询工具

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

##### [pt-query-digest(percona-toolkit)：慢查询工具](https://www.percona.com/doc/percona-toolkit/LATEST/pt-query-digest.html)

- pt-query-digest 主要功能是从日志、进程列表和tcpdump分析MySQL查询。
    - 与mysqldumpshow工具相比，py-query_digest 工具的分析结果更具体，更完善。

```sh
pt-query-digest /var/log/mysql/mysql_slow.log

# 直接分析慢查询文件
pt-query-digest /var/lib/mysql/slowtest-slow.log > slow_report.log

# 分析最近12小时内的查询
pt-query-digest --since=12h /var/lib/mysql/slowtest-slow.log > slow_report2.log

# 分析指定时间范围内的查询
pt-query-digest /var/lib/mysql/slowtest-slow.log --since '2017-01-07 09:30:00' --until '2017-01-07 10:00:00'> > slow_report3.log


# 分析指含有select语句的慢查询
pt-query-digest --filter '$event->{fingerprint} =~ m/^select/i' /var/lib/mysql/slowtest-slow.log> slow_report4.log

# 针对某个用户的慢查询
pt-query-digest --filter '($event->{user} || "") =~ m/^root/i' /var/lib/mysql/slowtest-slow.log> slow_report5.log

# 查询所有所有的全表扫描或full join的慢查询
pt-query-digest --filter '(($event->{Full_scan} || "") eq "yes") ||(($event->{Full_join} || "") eq "yes")' /var/lib/mysql/slowtest-slow.log> slow_report6.log
```


- 报告分析

    | 第一部分   | 总体统计结果                                                          |
    |------------|-----------------------------------------------------------------------|
    | Time range | 查询执行的时间范围询                                                  |
    | unique     | 唯一查询数量，即对查询条件进行参数化以后，总共有多少个不同的查询询    |
    | total      | 总计询                                                                |
    | min        | 最小询                                                                |
    | max        | 最大询                                                                |
    | avg        | 平均询                                                                |
    | 95%        | 把所有值从小到大排列，位置位于95%的那个数，这个数一般最具有参考价值询 |
    | median     | 中位数，把所有值从小到大排列，位置位于中间那个数询                    |

    | 第二部分 | 查询分组统计结果                                           |
    |----------|------------------------------------------------------------|
    | Rank     | 所有语句的排名，默认按查询时间降序排列，通过--order-by指定 |
    | Response | 总的响应时间                                               |
    | calls    | 执行次数，即本次分析总共有多少条这种类型的查询语句         |
    | V/M      | 响应时间Variance-to-mean的比率                             |

    | 第三部分                | 每一种查询的详细统计结果         |
    |-------------------------|----------------------------------|
    | ID                      | 查询的ID号，和上图的Query ID对应 |
    | Databases               | 数据库名                         |
    | Users                   | 各个用户执行的次数（占比）       |
    | Query_time distribution | 查询时间分布, 长短体现区间占比。 |
    | Tables                  | 查询中涉及到的表                 |
    | Explain                 | SQL语句                          |

#### [MySQL数据库联盟：如何通过ChatGPT优化MySQL的SQL语句](https://mp.weixin.qq.com/s?__biz=MzIyOTUzNjgwNg==&mid=2247484892&idx=1&sn=6207963a72bddf9e6c5fa70a57297a64&chksm=e8406095df37e98399b5e2f5347478f6e09061e3c0679e0231e117d0b8c88b1e32d61e622c7f&scene=21#wechat_redirect)

#### [MySQL数据库联盟：全网最全MySQL Prompt](https://mp.weixin.qq.com/s?__biz=MzIyOTUzNjgwNg==&mid=2247485114&idx=1&sn=9b09f028e20605ab9d1c561ac8303c7c&chksm=e84063f3df37eae564e6944793d124b28563101600e4727bc4158dff685cc959e54c6951267f&scene=178&cur_album_id=2861367280583032837#rd)

#### 第三方优化工具

##### [MySQLTuner-perl：性能诊断工具，主要检查参数设置的合理性包括日志文件、存储引擎、安全建议及性能分析。针对潜在的问题，给出改进的建议。是mysql优化的好帮手。](https://github.com/major/MySQLTuner-perl)

```sh
./mysqltuner.pl --socket /var/lib/mysql/mysql.sock
```

##### [tuning-primer.sh](https://github.com/BMDan/tuning-primer.sh)

- 针于mysql的整体进行一个体检，对潜在的问题，给出优化的建议。

##### [美团SQL优化工具SQLAdvisor](https://github.com/Meituan-Dianping/SQLAdvisor)
