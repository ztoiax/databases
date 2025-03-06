---
id: postgresql
aliases: []
tags: []
---


<!-- mtoc-start -->

* [postgresql](#postgresql)
  * [安装](#安装)
    * [集成PostgreSQL Docker镜像，已集成热门插件和工具](#集成postgresql-docker镜像已集成热门插件和工具)
  * [插件](#插件)
    * [pgpdf：pdf文件数据类型](#pgpdfpdf文件数据类型)
    * [DuckDB](#duckdb)
    * [nextgres：允许MySQL应用程序在PostgreSQL上无缝运行，无需任何代码更改](#nextgres允许mysql应用程序在postgresql上无缝运行无需任何代码更改)
  * [OLAP](#olap)
  * [隔离级别](#隔离级别)
  * [备份](#备份)
    * [Pg_dump：官方提供的逻辑备份工具](#pg_dump官方提供的逻辑备份工具)
    * [PgBackrest：物理备份工具](#pgbackrest物理备份工具)
    * [Barman：物理备份工具](#barman物理备份工具)
    * [pgbackweb：自动化备份](#pgbackweb自动化备份)
  * [sql优化工具](#sql优化工具)
    * [Pgbadger](#pgbadger)
  * [第三方工具](#第三方工具)
* [reference](#reference)

<!-- mtoc-end -->

# postgresql

## 安装

- [archlinux安装](https://www.netarky.com/programming/arch_linux/Arch_Linux_PostgreSQL_database_setup.html)

- [IT 邦德： 避坑！手把手教你7种安装PG16的手艺](https://mp.weixin.qq.com/s/QxnABtyPlmEMuvopmzNcVQ)

### 集成PostgreSQL Docker镜像，已集成热门插件和工具

```sh
# 拉取镜像, 第一次拉取一次即可. 或者需要的时候执行, 将更新到最新镜像版本.
docker pull registry.cn-hangzhou.aliyuncs.com/digoal/opensource_database:pg14_with_exts_arm64

# 启动容器
docker run -d -it -P --cap-add=SYS_PTRACE --cap-add SYS_ADMIN --privileged=true --name pg --shm-size=1g registry.cn-hangzhou.aliyuncs.com/digoal/opensource_database:pg14_with_exts_arm64

##### 如果你想学习备份恢复、修改参数等需要重启数据库实例的case, 换个启动参数, 使用参数--entrypoint将容器根进程换成bash更好. 如下:
docker run -d -it -P --cap-add=SYS_PTRACE --cap-add SYS_ADMIN --privileged=true --name pg --shm-size=1g --entrypoint /bin/bash registry.cn-hangzhou.aliyuncs.com/digoal/opensource_database:pg14_with_exts_arm64
##### 以上启动方式需要进入容器后手工启动数据库实例: su - postgres; pg_ctl start;

# 进入容器
docker exec -ti pg bash

# 连接数据库
psql
```

## 插件

![image](./Pictures/postgresql/插件-生态.avif)

![image](./Pictures/postgresql/插件-clickhouse性能对比.avif)

- [非法加冯：技术极简主义：一切皆用Postgres](https://mp.weixin.qq.com/s?__biz=MzU5ODAyNTM5Ng==&mid=2247486931&idx=1&sn=91dbe43bb6d26c760c532f4aa8d6e3cb&chksm=fe4b3808c93cb11e00194655a49bf7aa0d4d05a61a9b06ffcc57017c633de17066443ec62b6d&scene=21#wechat_redirect)

- [PostgreSQL 扩展插件生态列表](https://pigsty.cc/ext/)

- [apache age：图数据库，可以使用图模型查询](https://age.apache.org/)

- [FerretDB](https://github.com/FerretDB/FerretDB)
    - 底层采用 PostgreSQL 作为存储引擎，用 Go 语言实现了 MongoDB 协议

### [pgpdf：pdf文件数据类型](https://github.com/Florents-Tselai/pgpdf)

- [非法加冯：如何在数据库中直接检索PDF](https://mp.weixin.qq.com/s/ELgsSi29ZyzPtXgdrwt42A)

### DuckDB

- 就像做在线业务时，首选数据库是 PostgreSQL 一样，如今做分析时的 “默认之王” 就是 DuckDB。以前大家可能还会说用 Pandas，但现在几乎一开口就是“DuckDB 走起”。这货特别轻便，所以很多人想把它塞进那些本身对 OLAP 支持不是特别好的数据库。今年，我们就看到四款把 DuckDB 集成到 Postgres 的扩展相继亮相。

    - 第一枪是 2024 年 5 月，Crunchy Data 宣布做了个专有扩展，把 Postgres 重定向到 DuckDB 来处理 OLAP 查询。随后他们又搞了个更厉害的版本，利用 DuckDB 的空间扩展 来加速 PostGIS 查询。

    - 2024 年 6 月，ParadeDB发布了一个开源扩展（pg_analytics），用 Postgres 的 FDW API 去调用 DuckDB。在此之前，他们用的是 DataFusion（pg_lakehouse），后来改用 DuckDB。

    - 8 月，官方版的 DuckDB-for-Postgres 出炉了（pg_duckdb），托管在 DuckDB Labs 的 GitHub 下，算是名正言顺的 DuckDB 官方插件。原本宣传说这是 MotherDuck、Hydra、Microsoft 和 Neon 联合开发，结果后来据说 Microsoft 和 Neon 因为开发管理问题被“踢出去”了，就跟 阿拉伯王子 离开 NWA 一样。现在只剩 MotherDuck 和 Hydra 继续干。

    - 11 月又来一个 pg_mooncake 插件（博文），这次是 Mooncake Labs 出品。它跟前面三个不太一样，是可以通过 Postgres 把数据写进 Iceberg 表里，还支持事务。

### nextgres：允许MySQL应用程序在PostgreSQL上无缝运行，无需任何代码更改

## OLAP

- 现在 PostgreSQL 生态的一个主要遗憾是，缺少一个足够好的列式存储分析插件来做 OLAP 分析。

    - 然而， ParadeDB 和 DuckDB 的出现改变了这一点！

    - ParadeDB 提供的 PG 原生扩展 pg_analytics 实现了第二梯队（x10）的性能水准，与第一梯队只有 3～4 倍的性能差距。相对于其他功能上的收益，这种程度的性能差距通常是可以接受的 —— ACID，新鲜性与实时性，无需 ETL、额外学习成本、维护独立的新服务，更别提它还提供了 ElasticSearch 质量的全文检索能力。
    - 而 DuckDB 则专注于 OLAP ，将分析性能这件事做到了极致（x3.2） —— 略过第一名 Umbra 这种学术研究型闭源数据库，DuckDB 也许是 OLAP 实战性能最快的数据库了。它并不是 PG 的扩展插件，但它是一个嵌入式文件数据库，而 DuckDB FDW 以及 pg_quack 这样的 PG 生态项目，能让 PostgreSQL 充分利用 DuckDB 带来的完整分析性能红利！

## 隔离级别

- [AustinDatabases：PostgreSQL 为什么也不建议 RR隔离级别，MySQL别笑](https://mp.weixin.qq.com/s/X51JO1-eg1cPPs91pTCfIA)

## 备份

### Pg_dump：官方提供的逻辑备份工具

- Pg_dump 是 PostgreSQL 官方提供的逻辑备份工具，主要用于导出数据库的结构和数据，生成可执行的 SQL 脚本或压缩格式文件。其特点包括灵活的备份对象控制、跨版本兼容、丰富的格式输出以及简单易用。他的备份原理是，备份表结构通过查询 `pg_catalog` 系统表（如 `pg_class`、`pg_attribute`），获取数据库对象定义；备份数据是通过对每张表执行 `COPY TO` 或 `SELECT` 语句，将数据转换为 `INSERT` 语句或二进制数据，认启用事务快照，确保备份期间数据一致性块。

- Pg_dump 优点是简单易用、灵活性高、是PostgreSQL 轻量级备份的最佳选择。缺点是只有全量备份，没有增量备份，且备份表结构时会锁定元数据，恢复使速度相对物理备份较慢。

### [PgBackrest：物理备份工具](https://github.com/pgbackrest/pgbackrest)

- pgBackRest 是一款主要用于PostgreSQL  开源物理备份工具，支持全量、增量、差异等备份。备份的数据一致性是通过数据库的 WAL机制来保证备份的一致性。在进行全量备份时，PgBackRest 会锁定数据库以获取一个一致的状态快照，并在此期间复制所有数据文件。同时，它也会归档这期间内生成的所有 WAL 日志，从而确保备份数据的一致性。

- pgBackrest 优点是备份和恢复效率高、数据一致性有保证，以及有丰富的参数支持多种备份方式和对象。缺点是配置和使用相对逻辑备份复杂一些，无法进行跨版本备份，需要注意版本兼容性。综合来看，其是大型 PostgreSQL 数据库的备份和恢复首选工具。

### [Barman：物理备份工具](https://github.com/EnterpriseDB/barman)

- Barman 最初是由 2ndQuadrant 公司开发并开源的一款用于 PostgreSQL 数据库物理备份工具，目前由EnterpriseDB 开发和维护。他支持支持全量、增量等备份。全量备份是借助 `pg_basebackup` 工具进实现。`pg_basebackup` 是 PostgreSQL 自带的工具，能完整备份所有文件，包括数据文件、配置文件等；增量备份基于 WAL 日志实现。 在完成全量备份后，会持续归档 WAL 日志文件，从而实现增量数据的恢复。

- Barman的优点是备份恢复效率较高，支持多种备份方式，如增量备份、时间点恢复等，能满足高可用性和灾备需求。此外，还支持 SSH 安全通信，数据传输安全，还提供备份验证功能，确保备份文件的可用性和完整；缺点是配置相对复杂，具有一定学习能力。另外，由于全量或者增量备份时，没有基于数据库block 级别去扫描文件或者日志，性能相对pgBackrest 较弱。

### [pgbackweb：自动化备份](https://github.com/eduardolat/pgbackweb)

## sql优化工具

### [Pgbadger](https://github.com/darold/pgbadger)

- pgbadger 是一款强大的 PostgreSQL  数据库日志分析开源工具，是管理、优化以及准确高效的pg 日志分析的产品。他通过快速解析PostgreSQL的日志文件，生成详尽的统计报告，帮助DBA和开发者深入理解数据库的运行状况，快速定位性能瓶颈。主要功能包括 PostGreSQL 的日志解析、详细报告生成、丰富的展现方式以及强大的分析处理速度。

- pgbadger 的主要优点有使用简单、分析性能高、展示样式丰富，以及活跃的社区。缺点是只针对PostgreSQL 数据库，对于某些非常复杂的查询或者涉及大量表关联的情况，其提供的优化建议可能不够深入或直接。

## 第三方工具

- [pgassistant：优化性能](https://github.com/nexsol-technologies/pgassistant)

- 客户端

    - [rainfrog：tui支持类似 Vim 的快捷键、关键字高亮和历史记录等人性化功能。](https://github.com/achristmascarl/rainfrog)

    - [PgAdmin：官方gui](https://github.com/pgadmin-org/pgadmin4)

        - pgAdmin 是 PostgreSQL 官方提供的图形化工具，主要支持 PostgreSQL 数据库链接管理。他的主要功能包括PostgreSQL 数据库对象的创建与管理、SQL查询编辑和执行、备份恢复、用户权限设置以及性能监控等。目前，最新版本是 pgAdmin 4。

        - PgAdmin 的优点是对 PostgreSQL 的高度兼容性和深度集成，提供了丰富的图形化工具来简化复杂的数据库管理任务，并且拥有详细的文档和活跃的社区支持。缺点是只对PostgreSQL  数据库友好。

    - [pgmanage：gui](https://github.com/commandprompt/pgmanage)

# reference

- [PostgreSQL码农集散地：总算摸到门了！PostgreSQL及国产开源数据库学习进阶之路。](https://mp.weixin.qq.com/s/RCg5tdn1i7yBl2ZZy-ZaIw)
