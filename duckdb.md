# duckdb

- DuckDB 是一个 In-Process 的 OLAP 数据库，可以理解为 AP 版本的 SQLite，但其底层是列式存储。2019 年 SIGMOD 有一篇 Demo 论文介绍 DuckDB：[an embedded analytical database](https://arxiv.org/abs/1805.08520)

## 架构

- [韩锋频道：“小而美” 的分析库-DuckDB 初探](https://mp.weixin.qq.com/s/bcVsH_BGubEFYtiNnHa09g)

![image](./Pictures/duckdb/架构.avif)

- DuckDB 数据库可分为多个组件：

    - 1.Parser：DuckDB SQL Parser 源自 Postgres SQL Parser。

    - 2.Logical Planner：包含了两个过程 binder、plan generator。前者是解析所有引用的 schema 中的对象（如 table 或 view）的表达式，将其与列名和类型匹配。后者将 binder 生成的 AST 转换为由基本 logical query 查询运算符组成的树，就得到了一颗 type-resolved logical query plan。

    - 3.Optimizer：优化器部分，会采用多种优化手段对 logical query plan 进行优化，最终生成 physical plan。例如，其内置一组 rewrite rules 来简化 expression tree，例如执行公共子表达式消除和常量折叠。针对表关联，会使用动态规划进行 join order 的优化，针对复杂的 join graph 会 fallback 到贪心算法会消除所有的 subquery。

    - 4.Execution Engine：DuckDB 最开始采用了基于 Pull-based 的 Vector Volcano 的执行引擎，后来切换到了 Push-based 的 pipelines 执行方法。DuckDB 采用了向量化计算来来加速计算，具有内部实现的多种类型的 vector 以及向量化的 operator。另外出于可移植性原因，没有采用 JIT，因为 JIT引擎依赖于大型编译器库（例如LLVM），具有额外的传递依赖。

    - 5.Transactions：DuckDB 通过 MVCC 提供了 ACID 的特性，实现了HyPer专门针对混合OLAP / OLTP系统定制的可串行化MVCC 变种 。该变种立即 in-place 更新数据，并将先前状态存储在单独的 undo buffer 中，以供并发事务和 abort 使用。

    - 6.Persistent Storage：DuckDB 使用面向读取优化的 DataBlocks 存储布局（单个文件）。逻辑表被水平分区为 chunks of columns，并使用轻量级压缩方法压缩成 physical block 。每个块都带有每列的min/max 索引，以便快速确定它们是否与查询相关。此外，每个块还带有每列的轻量级索引，可以进一步限制扫描的值数量。

## 基本使用

- 默认情况下，DuckDB 是运行在内存数据库中，这意味着创建的任何表都存储在内存中，而不是持久化到磁盘上。
    ```sh
    # 启动数据库
    duckdb
    ```

- 可以通过启动命令行参数的方式，将 DuckDB 连接到磁盘上的持久化数据库文件。
    ```sh
    # 启动数据库
    duckdb filename.db
    ```

- 简单的crud
    ```sql
    -- 创建一张表
    create table t1(a int, b int);

    -- 查看表
    .table

    -- 查看表结构
    describe t1;

    -- 插入数据
    insert into t1 values(1,1);

    -- 修改输出格式
    .mode table

    -- 查看数据
    select * from t1;
    ```

- 导入数据：支持从CSV、JSON、Parquet、MySQL 等数据源中直接查询或导入数据。
    ```sql
    -- 读取外部数据
    select * from read_csv('tmp.csv');

    -- 加载数据到本地
    create table csv_table as select * from read_csv('tmp.csv');

    -- COPY 复制数据
    COPY csv_table FROM 'tmp.csv';
    ```

- 插件
    ```sql
    select * from duckdb_extensions();
    +------------------+--------+-----------+--------------+------------------------------------------------------------------------------------+-------------------+
    |  extension_name  | loaded | installed | install_path |                                    description                                     |      aliases      |
    +------------------+--------+-----------+--------------+------------------------------------------------------------------------------------+-------------------+
    | arrow            | false  | false     |              | A zero-copy data integration between Apache Arrow and DuckDB                       | []                |
    | autocomplete     | true   | true      | (BUILT-IN)   | Adds support for autocomplete in the shell                                         | []                |
    | aws              | false  | false     |              | Provides features that depend on the AWS SDK                                       | []                |
    | azure            | false  | false     |              | Adds a filesystem abstraction for Azure blob storage to DuckDB                     | []                |
    | excel            | true   | true      | (BUILT-IN)   | Adds support for Excel-like format strings                                         | []                |
    | fts              | true   | true      | (BUILT-IN)   | Adds support for Full-Text Search Indexes                                          | []                |
    | httpfs           | false  | false     |              | Adds support for reading and writing files over a HTTP(S) connection               | [http, https, s3] |
    | iceberg          | false  | false     |              | Adds support for Apache Iceberg                                                    | []                |
    | icu              | true   | true      | (BUILT-IN)   | Adds support for time zones and collations using the ICU library                   | []                |
    | inet             | true   |           |              | Adds support for IP-related data types and functions                               | []                |
    | jemalloc         | true   | true      | (BUILT-IN)   | Overwrites system allocator with JEMalloc                                          | []                |
    | json             | true   | true      | (BUILT-IN)   | Adds support for JSON operations                                                   | []                |
    | motherduck       | false  | false     |              | Enables motherduck integration with the system                                     | [md]              |
    | mysql_scanner    | false  | false     |              | Adds support for connecting to a MySQL database                                    | [mysql]           |
    | parquet          | true   | true      | (BUILT-IN)   | Adds support for reading and writing parquet files                                 | []                |
    | postgres_scanner | false  | false     |              | Adds support for connecting to a Postgres database                                 | [postgres]        |
    | shell            | true   |           |              |                                                                                    | []                |
    | spatial          | false  | false     |              | Geospatial extension that adds support for working with spatial data and functions | []                |
    | sqlite_scanner   | false  | false     |              | Adds support for reading and writing SQLite database files                         | [sqlite, sqlite3] |
    | substrait        | false  | false     |              | Adds support for the Substrait integration                                         | []                |
    | tpcds            | false  | false     |              | Adds TPC-DS data generation and query support                                      | []                |
    | tpch             | true   | true      | (BUILT-IN)   | Adds TPC-H data generation and query support                                       | []                |
    +------------------+--------+-----------+--------------+------------------------------------------------------------------------------------+-------------------+

    -- 安装mysql插件
    install mysql;

    -- 加载本地的 MySQL 数据库
    ATTACH 'host=localhost user=root port=3306 database=test' AS mysqldb (TYPE MYSQL);
    use mysqldb;
    show tables;

    # 查询对比
    time mysql -e "select deptno,count(*) from big_emp group by deptno" test
    time ./duckdb testdb -c "select deptno,count(*) from big_emp group by deptno"
    ```

- 参数管理

    ```sql
    select name,value from duckdb_settings();
    ┌────────────────────────────────────┬──────────────────────────────┐
    │                name                │            value             │
    │              varchar               │           varchar            │
    ├────────────────────────────────────┼──────────────────────────────┤
    │ access_mode                        │ automatic                    │
    │ allow_persistent_secrets           │ true                         │
    │ checkpoint_threshold               │ 16.0 MiB                     │
    │ debug_checkpoint_abort             │ none                         │
    │ debug_force_external               │ false                        │
    │ debug_force_no_cross_product       │ false                        │
    │ debug_asof_iejoin                  │ false                        │
    │ prefer_range_joins                 │ false                        │
    │ debug_window_mode                  │ NULL                         │
    │ default_collation                  │                              │
    │ default_order                      │ asc                          │
    │ default_null_order                 │ nulls_last                   │
    │ disabled_filesystems               │                              │
    │ disabled_optimizers                │                              │
    │ enable_external_access             │ true                         │
    │ enable_fsst_vectors                │ false                        │
    │ allow_unsigned_extensions          │ false                        │
    │ allow_unredacted_secrets           │ false                        │
    │ custom_extension_repository        │                              │
    │ autoinstall_extension_repository   │                              │
    │        ·                           │              ·               │
    │        ·                           │              ·               │
    │        ·                           │              ·               │
    │ secret_directory                   │ /root/.duckdb/stored_secrets │
    │ default_secret_storage             │ local_file                   │
    │ temp_directory                     │ duckdbtest.db.tmp            │
    │ threads                            │ 16                           │
    │ username                           │ NULL                         │
    │ arrow_large_buffer_size            │ false                        │
    │ user                               │ NULL                         │
    │ wal_autocheckpoint                 │ 16.0 MiB                     │
    │ worker_threads                     │ 16                           │
    │ allocator_flush_threshold          │ 128.0 MiB                    │
    │ duckdb_api                         │ cli                          │
    │ custom_user_agent                  │                              │
    │ partitioned_write_flush_threshold  │ 524288                       │
    │ mysql_bit1_as_boolean              │ true                         │
    │ mysql_experimental_filter_pushdown │ false                        │
    │ mysql_debug_show_queries           │ false                        │
    │ binary_as_string                   │                              │
    │ Calendar                           │ gregorian                    │
    │ mysql_tinyint1_as_boolean          │ true                         │
    │ TimeZone                           │ Asia/Shanghai                │
    ├────────────────────────────────────┴──────────────────────────────┤
    │ 77 rows (40 shown)                                      2 columns │
    └───────────────────────────────────────────────────────────────────┘

    -- 修改参数
    set threads=10;

    -- 查看单个参数
    SELECT current_setting('threads') AS threads;
    ┌─────────┐
    │ threads │
    │  int64  │
    ├─────────┤
    │      10 │
    └─────────┘
    ```

- Pragma 扩展。PRAGMA 语句是DuckDB从SQLite中采用的SQL扩展。
    - PRAGMA命令可能会改变数据库引擎的内部状态，并可能影响引擎的后续执行或行为。
    ```sql
    -- 数据库信息
    PRAGMA database_list;
    ┌───────┬────────────┬───────────────┐
    │  seq  │    name    │     file      │
    │ int64 │  varchar   │    varchar    │
    ├───────┼────────────┼───────────────┤
    │  1080 │ duckdbtest │ duckdbtest.db │
    └───────┴────────────┴───────────────┘

    -- 数据库信息（大小）
    CALL pragma_database_size();
    ┌───────────────┬───────────────┬────────────┬───┬──────────┬──────────────┬──────────────┐
    │ database_name │ database_size │ block_size │ … │ wal_size │ memory_usage │ memory_limit │
    │    varchar    │    varchar    │   int64    │   │ varchar  │   varchar    │   varchar    │
    ├───────────────┼───────────────┼────────────┼───┼──────────┼──────────────┼──────────────┤
    │ duckdbtest    │ 256.0 KiB     │     262144 │ … │ 0 bytes  │ 256.0 KiB    │ 9.9 GiB      │
    ├───────────────┴───────────────┴────────────┴───┴──────────┴──────────────┴──────────────┤
    │ 1 rows                                                              9 columns (6 shown) │
    └─────────────────────────────────────────────────────────────────────────────────────────┘

    -- 查看所有的表
    PRAGMA show_tables;
    ┌─────────┐
    │  name   │
    │ varchar │
    ├─────────┤
    │ t1      │
    │ t2      │
    └─────────┘

    -- 所有表的详细信息
    PRAGMA show_tables_expanded;
    ┌────────────┬─────────┬─────────┬──────────────┬────────────────────┬───────────┐
    │  database  │ schema  │  name   │ column_names │    column_types    │ temporary │
    │  varchar   │ varchar │ varchar │  varchar[]   │     varchar[]      │  boolean  │
    ├────────────┼─────────┼─────────┼──────────────┼────────────────────┼───────────┤
    │ duckdbtest │ main    │ t1      │ [a, b]       │ [INTEGER, INTEGER] │ false     │
    │ duckdbtest │ main    │ t2      │ [a, b]       │ [INTEGER, INTEGER] │ false     │
    └────────────┴─────────┴─────────┴──────────────┴────────────────────┴───────────┘

    -- 表结构
    PRAGMA table_info('t1');
    ┌───────┬─────────┬─────────┬─────────┬────────────┬─────────┐
    │  cid  │  name   │  type   │ notnull │ dflt_value │   pk    │
    │ int32 │ varchar │ varchar │ boolean │  varchar   │ boolean │
    ├───────┼─────────┼─────────┼─────────┼────────────┼─────────┤
    │     0 │ a       │ INTEGER │ false   │            │ false   │
    │     1 │ b       │ INTEGER │ false   │            │ false   │
    └───────┴─────────┴─────────┴─────────┴────────────┴─────────┘

    -- 函数信息
    PRAGMA functions;

    -- 版本与平台
    PRAGMA version;
    ┌─────────────────┬────────────┐
    │ library_version │ source_id  │
    │     varchar     │  varchar   │
    ├─────────────────┼────────────┤
    │ v0.10.1         │ 4a89d97db8 │
    └─────────────────┴────────────┘

    -- Profiling
    PRAGMA enable_profiling;
    SET profiling_mode = 'detailed';
    SET enable_profiling = 'query_tree';    --logical query plan:
    SET enable_profiling = 'query_tree_optimizer';    --physical query plan:
    PRAGMA disable_profiling;

    -- Optimizer
    PRAGMA disable_optimizer;
    PRAGMA enable_optimizer;

    -- Storage Info
    PRAGMA storage_info('t1');
    ┌──────────────┬─────────────┬───────────┬───┬──────────┬──────────────┬──────────────┐
    │ row_group_id │ column_name │ column_id │ … │ block_id │ block_offset │ segment_info │
    │    int64     │   varchar   │   int64   │   │  int64   │    int64     │   varchar    │
    ├──────────────┼─────────────┼───────────┼───┼──────────┼──────────────┼──────────────┤
    │            0 │ a           │         0 │ … │       -1 │            0 │              │
    │            0 │ a           │         0 │ … │       -1 │            0 │              │
    │            0 │ b           │         1 │ … │       -1 │            0 │              │
    │            0 │ b           │         1 │ … │       -1 │            0 │              │
    ├──────────────┴─────────────┴───────────┴───┴──────────┴──────────────┴──────────────┤
    │ 4 rows                                                         15 columns (6 shown) │
    └─────────────────────────────────────────────────────────────────────────────────────┘
    ```

- 性能调优
    ```sql
    -- 查看执行计划
    explain select deptno,count(*) from big_emp group by deptno;
    ```

# reference

- [《DuckDB 实战》（DuckDB in Action）](https://motherduck.com/duckdb-book-brief/)

- [ DuckDB 的官方文档](https://duckdb.org/duckdb-docs.pdf)

# 第三方工具

- [awesome-duckdb](https://github.com/davidgasquez/awesome-duckdb)
