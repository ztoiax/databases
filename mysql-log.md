# 日志

| 日志类型   | 日志说明                               |
|------------|----------------------------------------|
| 错误日志   | Mysql本身的错误日志                    |
| 查询日志   | 查询语句日志                           |
| 慢查询日志 | 慢查询语句，查询耗时续配署             |
| 事务日志   | 记录事物执行过程，用于故障恢复         |
| binlog二进制日志 | 记录所有语句执行记录，用于数据同步等   |
| 中继日志   | 线程读取别人的二进制日志存到本地的日志 |

![image](./Pictures/mysql/logs.avif)

## 普通日志

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

## BINLOG (二进制日志)

MySQL 8.0 中的二进制日志格式与以前的 MySQL 版本不同

Binlog 是逻辑日记，只记录对数据库更改的所有操作，不包括 `select`，`show` 等这类操作不修改数据的语句

启用了二进制日志记录的服务器会使性能稍微降低

BINLOG 主要有两个作用：

- 主从复制，主服务器要发送 binlog 给从服务器

- 某些数据恢复操作需要使用 binlog 日志

[再深入一点|binlog 和 relay-log 到底长啥样？](https://zhuanlan.zhihu.com/p/232806417)

开启 `binary` 日志:

```sh
[mysqld]
datadir = /var/lib/mysql/
log-bin=bin.log
log-bin-index=bin-log.index
max_binlog_size=100M
# 日志格式默认是row
binlog_format=row

# 此参数表示只记录指定数据库的二进制日志
binlog_do_db

# 此参数表示不记录指定的数据库的二进制日志
binlog_ignore_db

# n 次事务提交后，将执行一次 fsync 之类的磁盘同步指令,同时将 Binlog 文件缓存刷新到磁盘。最安全的值为 sync_binlog=1（默认值），但这也是最慢的。

sync_binlog=n
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

### mysqlbinlog 日志分析

```sh
mysqlbinlog /var/lib/mysql/bin.000001
```

## [canal](https://github.com/alibaba/canal)

- canal 模拟 slave 的方式，获取 binlog 日志数据. binlog 设置为 row 模式以后，不仅能获取到执行的每一个增删改的脚本，同时还能获取到修改前和修改后的数据.

- 支持高性能,实时数据同步

- 支持 docker

[canal 安装](https://github.com/alibaba/canal/wiki/QuickStart) 目前不支持 jdk 高版本

[canal 运维工具安装](https://github.com/alibaba/canal/wiki/Canal-Admin-QuickStart)

# 性能优化

- 如果无法测量就无法优化, 测量需要分析大量的数据, 大多数系统无法完整的测量, 而且测量的结果也可能是错误的

- 判断是服务器问题还是查询问题:

    - 如果是每一条查询都变慢, 则可能是服务器问题

    - 如果是只有某条查询变慢, 则可能是查询问题

## profile 记录查询响应时间

```sql
# 开启profile
set profile = 1

# 查看所有查询的响应时间
show profiles

# 查看上一次查询每个步骤的响应时间
show profile
```

## 记录计数器

```sh
# 查看线程状态, 如果注意是否有大量的freeing item
mysql -e 'show processlist\G' | grep -i "state:" | sort | uniq -c | sort -rn
```

## 慢查询优化

- 设置0秒.记录所有查询:

    - 慢查询日志开销很低, 不需要担心额外的开销, 但会消耗磁盘空间

    ```sh
    [mysqld]
    long_query_time = 0
    ```

- 查看慢查询相关配置:

    ```sql
    show variables like "%slow%";

    show status like "%slow%";
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
# reference

- [How and When To Enable MySQL Logs](https://www.pontikis.net/blog/how-and-when-to-enable-mysql-logs)
- [MySQL Server Logs](https://dev.mysql.com/doc/refman/5.7/en/server-logs.html)
- [从运维角度浅谈 MySQL 数据库优化](https://linux.cn/article-5613-weibo.html)
- [PHP 性能分析（三）: 性能调优实战](https://linux.cn/article-6462-1.html)
- [MySQL 日志分析神器之 mysqlsla](https://developer.aliyun.com/article/59260?spm=a2c6h.14164896.0.0.4b98353bhStc1B)
- [详解 慢查询 之 mysqldumpslow](https://zhuanlan.zhihu.com/p/106405711)
- [几年了，作为一个码农终于把 MySQL 日记看懂了！](https://zhuanlan.zhihu.com/p/267143540)
- [再深入一点|binlog 和 relay-log 到底长啥样？](https://zhuanlan.zhihu.com/p/232806417)
