# mongodb

## 基本概念

- 文档（document）：是mongodb的基本单元，类似于关系数据库的行。

    - 概念上与javascript中的对象非常相近，可以被认为是json格式在基础上加上一些拓展类型

    - `{ greeting : "Hello, world!" }`：这个文档包含一个键为`greeting`，对应的值为`Hello, world!`

    - 命名：
        - 每个文档都有一个特殊的键`_id`
        - 严格区分大小写
        - 文档不能包含重复的键
        - 键不能含有`\0`（空字符）

- 集合（collection）：类似于关系数据库的表

    - 为什么要有集合？因为将不同类型的文档保存在同一个集合是一个噩梦。将相同类型的文档放入同一个集合可以实现数据的局部性。

        - 获取集合列表比文档的列表要快

            - 例子：从一个只包含博客文章的集合中查询，比从包含博客文章、又包含作者数据的集合中进行查询，有更少磁盘查询次数

        - 更高效的索引：按每个集合来定义，将单一类型的文档放入集合，可以更高效的对集合进行索引

    - 命名：
        - 不能以`system.`开头。因为这个前缀是内部保留。
            - 例子：`system.users`集合是保存着数据库的用户；`system.namespaces`集合是保存数据库所有集合的信息
        - 不能是空字符串`""`
        - 不能含有`\0`（空字符）。因为这个字符表示集合的结束
        - 不能含有`$`。因为某些系统生成的集合会包含`$`，除非你是要访问这些集合
        - `.`表示子集合。例子`blog.posts`

- 一个mongodb实例有多个独立的数据库（database），一个数据库有0个或多个集合。

    - 一个推荐的做法是：将单个应用程序的所有数据存储在同一个数据库

    - 命名：
        - 严格区分大小写
        - 长度限制为64字节
        - 不能是空字符串`""`
        - 不能含有`/` `\` `.` `"` `*` `<` `>` `:` `|` `?` `$` `\0（空字符）`

## 如何部署mongodb

- 使用RAID10
    - 不要使用RAID5，它非常非常慢

- `WiredTiger`存储引擎支持多线程。
    - 如果在速度和核心数选择：选择速度。——mongodb更擅长在单个处理器上利用更多周期，而不是增加并行度

- mongodb通常不使用交换空间。极端情况下`WiredTiger`存储引擎会使用一些交换空间

- 内存如果过度分配，mongodb获取的内存实际并不存在，则无法很好的工作
    ```sh
    # 禁止内存过度分配
    echo 2 > /proc/sys/vm/overcommit_memory
    ```

- 虚拟机的神秘内存：虚拟层有时无法正确处理内存分配
    - 100GB RAM的虚拟机，但允许访问的只有60GB
    - 相反的情况：20GB RAM的虚拟机，但100GB数据都能放入其中

- 虚拟机IO问题：可能与其他租户共享一个产品，每个人都有可能竞争磁盘IO

- 关闭NUMA

    - 如果mongodb以NUMA运行，性能降低时，会打印警告信息

    - 问题例子：cpu1内存满了，cpu1需要淘汰本地的内存数据，但此时cpu2的内存还没有满。这会导致mongodb运行速度变慢

    - 关闭numa启动mongodb，需要执行以下2个步骤

    - 1.关闭`/proc/sys/vm/zone_reclaim_mode` ：当某个 Node 内存不足时，系统可以从其他 Node 寻找空闲内存，也可以从本地内存中回收内存。
        ```sh
        # 关闭
        echo 0 > /proc/sys/vm/zone_reclaim_mode
        ```

    - 2.以numactl启动mongodb实例
        ```sh
        # --interleave=all内存分配是应该尽量均匀地分布在各个节点上，启动mongodb
        numactl --interleave=all mongod --config ~/mongodb/mongodb.conf
        ```

- 关闭大内存页（THP）（默认开启）：THP会导致更多的磁盘IO。如果数据不能放在内存，磁盘刷新时需要写入几MB而不是几KB

    - 虽说THP是为了数据库而开发的功能。但mongodb的顺序访问比关系数据库要少的多

    ```sh
    # 关闭THP
    echo never > /sys/kernel/mm/transparent_hugepage/enabled
    echo never > /sys/kernel/mm/transparent_hugepage/defrag
    ```

- 选择磁盘调度算法：

    - 没有调度算法（NOOP）：不对文件系统和应用程序的 I/O 做任何处理

        - 应用场景：
            - 1.虚拟机 I/O 中，此时磁盘 I/O 调度算法交由物理机系统负责。
            - 2.SSD。SSD不存在机械磁盘中的局部问题

    - 优先级调度算法（DEADLINE）：在CFS的基础上分为读、写两个FIFO队列
        - 最适合磁盘密集型的数据库
        - 应用场景：非虚拟机的物理机

- 关闭文件系统的访问时间追踪
    - mongodb使用的数据文件流量非常大，关闭时间追踪可以提升性能
    ```
    # 默认为relatime，修改为noatime。需要重新启动才能生效
    /dev/sda1 /data xfs rw,noatime 1 2
    ```

- 修改限制

    - 1.进程运行创建线程数的限制

        - mongodb每接受一个连接，就会创建一个线程。

            - 如果有3000个连接，就会有3000个线程

        - 客户端随着流量的增加动态的创建子进程
            - 假设有20个应用程序服务器，每个应用程序服务器可以创建100个子进程，而每个子进程又可以创建10个连接到mongodb的线程。20 * 100 * 10 = 20000个连接

        ```sh
        # 查看最大线程数
        cat /proc/sys/kernel/threads-max
        # 设置最大线程数
        ulimit -u 1024
        ```

    - 2.进程允许打开文件描述符数的限制

        - 每个传入和传出的连接都需要文件描述符

        ```sh
        # 修改打开的文件描述符数量（默认为1024）
        ulimit -n 20000
        ```

- 时间同步：1秒之内最安全
    - 使用ntp保持时间同步


### 安全事项
```sh
# 应该严格限制外部对mongodb的访问。指定监听端口
mongod --bing_ip

# 禁止执行javascript代码
mongod --noscripting

# 默认数据传输不加密。启用加密。需要创建密钥
mongod --tlsMode
```

## mongosh

- mongosh是一个功能齐全的javascript解释器，并且包含了一些扩展语法（语法糖）

### 基本命令

- 开启mongodb实例
    ```sh
    mongod --port 27017 --dbpath ~/mongodb
    ```

- 配置文件开启mongodb实例

    - `~/mongodb/mongodb.conf`配置文件

        ```
        dbpath=/home/tz/mongodb/
        port=27017
        # 目录为dbpath下
        logpath=log.log
        ```

    - 配置文件开启实例
        ```sh
        mongod --config ~/mongodb/mongodb.conf &
        ```

- 连接数据库
```sh
# 连接服务器
mongosh 127.0.0.1:27017
# 等同于上条命令，默认连接本地的27017端口
mongosh

# 不连接任何服务器
mongosh --nodb
# 在上面命令的基础上，连接服务器
conn = new Mongo("127.0.0.1:27017")
db = conn.getDB("mydb")
```

- help帮助
```mongodb
// 查看帮助
help

// 查看数据库级别的帮助
db.help()

// 查看集合级别的帮助
db.foo.help()

// 查看函数的说明
db.currentOp().help()

// 函数如果不加()，可以输出javascript的代码
db.movies.updateOne
```

- 基本使用
```mongodb
// 查看当前数据库
db

// 选择要使用的数据库
use dbname

// 查看当前数据库集合
db.movies

// 删除当前整个数据库
use test
db.dropDatabase()
```

- 关闭mongod

    ```mongodb
    // 关闭mongod
    db.shutdownServer()
    // 强制关闭mongod
    db.adminCommand({"shutdown": 1, "force": true})
    ```
    - `db.adminCommand({"shutdown": 1, "force": true})`和`SIGINT`或`SIGTERM`信号。都是可以实现安全关闭。但如果是副本集可能会有未复制的同步数据
    ```sh
    # 在终端前台运行，按Ctrl-C相当于发送SIGINT信号

    # 假设mongod的pid为10014
    kill -2 10024 # SIGINT
    kill 10024 # SIGTERM
    ```

### 执行javascript脚本

```sh
# 执行javascript脚本
mongosh script1 script2

# 不输出任何信息执行脚本
mongosh --quiet script1 script2

# 执行远程服务器foo数据库的脚本
mongosh 192.168.1.111:30000/foo script1

# 在实例里加载脚本
load("script1")
```

- shell辅助函数对应的javascript函数

| 辅助函数         | 等价函数                |
|------------------|-------------------------|
| use video        | db.getSisterDB("video") |
| show dbs         | db.getMongo().getDBs()  |
| show collections | db.getCollectionNames() |

```mongodb
// 要获取verions集合，使用db.verions没用，因为这是一个内部的方法。这种情况可以使用js函数代替
db.getCollection("version")
```

- 一个初始化的行用函数
```js
// defineConnectTo.js
// 连接数据库并设置db变量

var connectTo = function(port, dbname) {
  if (!port) {
    port = 27017;
  }

  if (!dbname) {
    dbname = "test";
  }

  db = connect("localhost:"+port+"/"+dbname);
  return db;
}
```
```mongodb
// 加载js脚本
load("~/mongodb/defineConnectTo.js")
// 查看是否存在connectTo函数
typeof connectTo
```

- 主目录下`.mongorcsh.js`文件：保存需要频繁加载的javascript脚本。会在启动shell时自动运行

    ```js
    print("this is .mongorcsh.js")
    ```

    - 可以实现禁止某些“危险”的shell辅助函数。使用`no`选项进行重写取消定义

        ```js
        var no = function() {
            print("Not on my watch.")
        }

        // 禁止删除数据库
        db.dropDatabase = DB.prototype.dropDatabase = no;

        // 禁止删除集合
        DBCollection.prototype.drop = no;

        // 禁止删除单个索引
        DBCollection.prototype.dropIndex = no;

        // 禁止删除多个索引
        DBCollection.prototype.dropIndexes = no;
        ```

    - 设置编辑器
        ```js
        // 设置编辑器
        EDITOR="usr/bin/nvim"
        ```

    - 定制shell prompt
        ```js
        // 当前时间显示
        prompt = function() {
            return (new Date()) + "> "
        }
        ```

### 数据类型

```mongodb
// 空值
{ "key": null }

// 布尔
{ "key": true }

// 浮点：默认使用64位浮点
{ "key": 3.14 }
{ "key": 3 }

// 整数
{ "key": NumberInt("3") }
{ "key": NumberLong("3") }

// 字符串：使用utf-8
{ "key": "hello" }

// 日期：要使用new调用才会返回Date对象。
{ "key": new Date() }

// 正则表达式：与javascript相同
{ "key": /hello/i }

// 数组
{ "key": [ "a", "b", "c" ] }

// 内嵌文档：不需要像关系型数据库那样创建2个表
{ "key": { "key1": "value" } }

// 二进制数据：不能通过shell进行操作，一般存储非utf-8的字符串

// javascript代码
{ "key": function(){ /* */ } }
```

- ObjectID：一个12字节的ID，提供秒粒度的的唯一标识

    - mongodb分布式使用ObjectID而不是自动递增主键。——跨多个服务器同步自动递增主键，既困难又耗时

    ```mongodb
    { "key": ObjectId() }
    ```

### CRUD（创建、读取、更新、删除）

#### 插入

- 插入校验：
    - 如果不存在`_id`则会自动添加
    - 所有文档必须小于16MB
        - GridFS提供存储大于16MB的BSON文档
        ```mongodb
        // 查看二进制json（bson）的大小，单位：字节
        bsonsize(db.movies.findOne())
        ```

- `insertOne()`插入单个文档。会为文档自动添加`_id`键

    ```mongodb
    movie = { "title": "hello",
    "director" : "joe",
    "year" : "2023"
    }

    // insertOne函数：将一个文档添加到集合中
    db.movies.insertOne(movie)
    ```

- `insertMany()`插入多个文档。

    - 单词批量插入的文档不能超过48MB。一些驱动程序会将超过48MB，拆分多个48MB插入

    - 如果要从如mysql进行导入，可以使用像`mongoimport`的命令行工具，而不是使用`insertMany()`批量导入。

    ```mongodb
    db.movies.insertMany([
        {"title": "abc"},
        {"title": "abc1"},
        {"title": "abc2"},
    ])
    ```

    - 如果插入时某个文档发生错误。`ordered`键决定是否继续插入
        - true时（默认）：有序插入，表示出错后的文档不插入
        - false时：无序插入，表示不管是否出错，尝试插入所有文档

        ```mongodb
        // ordered为true时
        // 由于有两个_id键相同会导致出错，而ordered默认为true，所以不会插入出错之后的文档。
        db.movies.insertMany([
            {"_id": 0, "title": "abc"},
            {"_id": 1, "title": "abc1"},
            {"_id": 1, "title": "abc2"},
            {"_id": 2, "title": "abc3"},
        ])

        db.movies.find()
        [ { _id: 0, title: 'abc' }, { _id: 1, title: 'abc1' } ]
        ```

        ```mongodb
        // ordered为false时
        db.movies.insertMany(
            [
                {"_id": 0, "title": "abc"},
                {"_id": 1, "title": "abc1"},
                {"_id": 1, "title": "abc2"},
                {"_id": 2, "title": "abc3"},
            ],
            {"ordered": false}
        )

        db.movies.find()
        [
          { _id: 0, title: 'abc' },
          { _id: 1, title: 'abc1' },
          { _id: 2, title: 'abc3' }
        ]
        ```

#### 删除

- 会永久删除文档

- mongodb3.0以前为`remove()`；3.0以后引入`deleteOne()`、`deleteMany()`

- `deleteOne()`：删除满足条件的第一个文档
    - 文档的顺序取决于：
        - 插入时的顺序
        - 是否指定索引
        - 对文档进行了哪些更新（对于某些存储引擎来说）

    ```mongodb
    db.movies.deleteOne({ title: "abc" })
    ```

- `deleteMany()`：删除与过滤条件匹配的所有文档

    ```mongodb
    // {}表示删除所有文档
    db.movies.deleteMany({})

    // 与上面一样。但drop()操作更快
    db.movies.drop()
    ```

#### 更新

- 更新时原子操作。如果有两个更新同时发生：先到达的会先被执行

- `updateOne()`、`updateMany()`、`replaceOne()`都是接受至少2个参数：第一个为查询要更新文档的限定条件，第二个为描述更新的文档

- `replaceOne()`：新文档完全替换匹配的文档。

    - 对于大规模迁移场景非常有用

    ```mongodb
    // 插入测试文档
    db.users.insertOne(
        {"name": "joe", "friends": 32, "enemies": 2}
    )

    // 把friends和enemies两个字段，移动到relationships子文档中，并把name字段改为username
    var joe = db.users.findOne({"name": "joe"})
    joe.relationships = {"friends": joe.friends, "enemies": joe.enemies}
    joe.username = joe.name
    delete joe.name
    delete joe.friends
    delete joe.enemies
    db.users.replaceOne({"name": "joe",}, joe)

    // 更新后的结果
    db.users.findOne()
    {
      _id: ObjectId("6556e7fa0344e8a4b4a1b7b4"),
      relationships: { friends: 32, enemies: 2 },
      username: 'joe'
    }
    ```

    - 匹配多个文档时，`_id`值不一样会报错
    ```mongodb
    // 插入测试文档
    db.people.insertOne({"name": "joe", "age": 65})
    db.people.insertOne({"name": "joe", "age": 20})
    db.people.insertOne({"name": "joe", "age": 49})

    // 第二个joe今天生日，age + 1
    joe = db.people.findOne({"name": "joe", "age": 20})
    joe.age++

    // 报错。因为第一个满足条件的65岁joe的_id值不一样
    db.people.replaceOne({"name": "joe"}, joe)
    MongoServerError: After applying the update, the (immutable) field '_id' was found to have been altered to _id: ObjectId('6556faca178fe558a4489ca9')

    // 需要指定唯一的键，例如_id键
    db.people.replaceOne({"_id": ObjectId("6556faca178fe558a4489ca9")}, joe)
    ```

- `updateMany()`：更新多个文档
    ```mongodb
    // 插入测试文档
    db.users.insertMany([
        {"brithday": "11/17/2023"},
        {"brithday": "11/17/2023"},
        {"brithday": "11/17/2023"},
    ])

    // 给每个文档插入一个gift字段
    db.users.updateMany(
        {"brithday": "11/17/2023"},
        {"$set": {"gift": "Happy Birthday!"}}
    )
    ```

- `findOneAndUpdate()`：返回匹配结果并进行更新

    - 假设：有一个集合，包含一定顺序运行的进程

        ```mongodb
        {
            "_id": ObjectId(),
            "status": "state",
            "priority": N
        }
        ```

        - status是字符串值为`READY`、`RUNNING`、`DONE`。需要找到状态为`READY`的优先级最高的任务，运行相应的进程函数，最后将状态更新为`DONE`

        ```mongodb
        var cursor = db.process.find({"status": "READY"});
        ps = cursor.sort({"priority": -1}).limit(1).next();
        db.processes.updateOne({"_id": ps._id}, {"$set": {"status": "RUNNING"}});
        do_something(ps);
        db.processes.updateOne({"_id": ps._id}, {"$set": {"status": "DONE"}});
        ```

    - 问题：有2个线程运行，线程A读取了文档；线程B在线程A把状态更新为`RUNNING`之前读取到同一个文档，则两个线程同时运行

    - 解决方法：`findOneAndUpdate()`

    ```mongodb
    db.processes.findOneAndUpdate(
        {"status": "READY"},
        {"$set": {"status": "RUNNING"}},
        {"sort": {"priority": -1}}
    )
    ```

##### 更新运算符

- `$inc`：增加和减少值。如果不存在，则创建该字段

    - 只能用于整型、长整型、双精度浮点型。不能说null、布尔、字符串

    ```mongodb
    // 插入测试文档
    db.people.insertOne({"name": "jack", "money": 10})
    // 加1
    db.people.updateOne({"name": "jack"}, {"$inc": {"money": 1}})
    // 加20
    db.people.updateOne({"name": "jack"}, {"$inc": {"money": 20}})
    // 减20
    db.people.updateOne({"name": "jack"}, {"$inc": {"money": -20}})

    // 新增age字段
    db.people.updateOne({"name": "jack"}, {"$inc": {"age": 20}})
    ```

- `$set`：设置一个字段值，如果不存在，则创建该字段。可以修改键的类型
- `$unset`：删除键

    ```mongodb
    // 插入测试文档
    db.people.insertOne({"name": "Trump"})
    // $set修饰符，新增skill字段
    db.people.updateOne({ "name": "Trump" }, { $set : { "skill": "mongodb" }})
    // $set修饰符，修改skill字段
    db.people.updateOne({ "name": "Trump" }, { $set : { "skill": "redis" }})
    // $set修饰符，修改为数组类型
    db.people.updateOne({ "name": "Trump" }, { $set : { "skill": [ "mongodb", "redis" ]}})

    // $unset，删除skill键
    db.people.updateOne({ "name": "Trump" }, { $unset : { "skill": 1}})
    ```

    - `$set`修饰符，新增内嵌文档
    ```mongodb
    // 插入测试文档
    db.blog.posts.insertOne({
        "title": "A Blog Post",
        "author":{
            "name": "joe",
            "email": "joe@example.com",
        }
    })

    // joe改为joe schmoe
    db.blog.posts.updateOne({"author.name": "joe"}, {"$set": {"author.name": "joe schmoe"}})
    ```

##### 数组运算符

- `$push`：将元素添加至数组末尾。如果不存在则创建新数组

    ```mongodb
    // 插入测试文档
    db.blog.posts.insertOne({"title": "A Blog Post1"})

    // joe插入一条评论
    db.blog.posts.updateOne(
        {"title": "A Blog Post1"},
        {"$push": {"comments": { "name":"joe", "content": "hello"}}}
    )

    // jack插入一条评论
    db.blog.posts.updateOne(
        {"title": "A Blog Post1"},
        {"$push": {"comments": { "name":"jack", "content": "hello, world"}}}
    )
    ```

- `$each`：一次操作添加多个值
- `$slice`：限制长度
- `sort`：排序

    ```mongodb
    // 插入测试文档
    db.blog.posts.insertOne({"title": "A Blog Post2"})

    // $push多个值
    db.blog.posts.updateOne(
        {"title": "A Blog Post2"},
        {"$push": {"hourly": {"$each" : [1, 2]}}}
    )

    // 再次$push多个值
    db.blog.posts.updateOne(
        {"title": "A Blog Post2"},
        {"$push": {"hourly": {"$each" : [3, 4]}}}
    )

    // $slice设置如果大于10，则保留最后10个元素
    db.blog.posts.updateOne(
        {"title": "A Blog Post2"},
        {"$push": {"hourly": {"$each" : [5, 6, 7, 8, 9, 10, 11],
        "$slice": -10}}}
    )

    // 查看结果
    db.blog.posts.find()
    [
      {
        _id: ObjectId("65570959178fe558a4489cb8"),
        title: 'A Blog Post2',
        hourly: [
          2, 3, 4,  5,  6,
          7, 8, 9, 10, 11
        ]
      }
    ]

    // 在$slice截断前先$sort排序
    db.blog.posts.drop()
    db.blog.posts.insertOne({"title": "A Blog Post2"})

    // 保留前10个。实际运行并不是这样??
    db.blog.posts.updateOne(
        {"title": "A Blog Post2"},
        {"$push": {"hourly": {"$each" : [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
        "$slice": -10,
        "$sort": {"hourly": 1},
        }}}
    )
    db.blog.posts.find()
    ```

- `$ne`：值不存在才添加
- `$addToSet`：值不存在才添加。可以代替`$ne`和`$push`

    ```mongodb
    // 插入测试数据
    db.people.insertOne({"name": "tz", "skill": [ "redis", "mysql"] })

    // $ne结合$push
    db.people.updateOne(
        {"name": "tz", "skill": { "$ne" : "mongodb" }},
        {"$push": {"skill": "mongodb"}}
    )

    // $addToSet代替$ne和$push
    db.people.updateOne(
        {"name": "tz"},
        {"$addToSet": {"skill": "hbase"}}
    )

    // $ne与$push结合$each一起使用，插入多个值
    db.people.updateOne(
        {"name": "tz", "skill": { "$ne" : "hbase" }},
        {"$push": {"skill": {"$each": ["hbase", "linux", "nginx"]}}}
    )

    // $addToSet结合$each一起使用，插入多个值
    db.people.updateOne(
        {"name": "tz"},
        {"$addToSet": {"skill": {"$each": ["hbase", "linux", "nginx"]}}}
    )
    ```

- `$pop`：从任意一端删除元素

    ```mongodb
    // 插入测试文档
    db.lists.insertOne({"_id": 1, "todo": ["a", "b", "c", "d"]})

    // 删除最后一个元素
    db.lists.updateOne({"_id": 1}, {"$pop": {"todo": 1}})

    // 删除第一个元素
    db.lists.updateOne({"_id": 1}, {"$pop": {"todo": -1}})
    ```

- `$pull`：删除匹配指定条件的元素。
    ```mongodb
    // 插入测试文档
    db.lists.insertOne({"_id": 2, "todo": ["a", "b", "c", "d"]})

    // 删除元素b
    db.lists.updateOne({}, {"$pull": {"todo": "b"}})
    ```

- `$`定位运算符
- `arrayFilters`
    ```mongodb
    // 插入测试文档
    db.blog.posts.insertOne({
        "connect": "hello",
        "comments": [
            {"comment": "good post", "author": "john", "votes": 0},
            {"comment": "i thought it was too short", "author": "claire", "votes": 3},
            {"comment": "free watch", "author": "alice", "votes": -5},
            {"comment": "vacaton getaways", "author": "lynn", "votes": -7},
        ]
    })

    // 使用$定位运算符，增加第一条评论的投票vote数
    db.blog.posts.updateOne({"comments.author": "john"}, {"$inc": {"comments.$.auther": 1}})

    // 使用$定位运算符，修改lynn为jim
    db.blog.posts.updateOne({"comments.author": "lynn"}, {"$set": {"comments.$.auther": "jim"}})

    // arrayFilters将评论votes值小于或等于-5的文档，添加一个名为"hidden"的字段，并设置true
    // 命令代码没看懂??
    db.blog.posts.updateOne(
        {_id: ObjectId("65571920178fe558a4489cd3")},
        {"$set": {"comments.$.[elem].hidden": true}},
        {"arrayFilters":[{"elem.votes": { $lte: -5 }}]}
    )
    ```

##### upsert

- 记录网页的访问次数

    ```js
    // 检查这个页面是否有一个文档
    blog = db.analytics.({url: "/blog"})

    // 如果有，访问次数+1
    if (blog) {
        blog.pageviews++;
        db.analytics.save(blog);
    }
    // 否则，创建一个新文档
    else {
        db.analytics.insertOne({url: "/blog", pageviews: 1})
    }
    ```

    - 问题：每次有人访问页面，先对数据库进行查询，然后选择更更新或插入。如果多个进程同时运行，会出现竞争，1个url会有多个文档被插入

    - 解决方法：`upsert`：先查询，匹配则正常更新，没有匹配则新建文档。作为`updateOne()`、`updateMany()`的第三个参数。

    ```mongodb
    // 由于不存在文档，会自动新建
    db.analytics.updateOne({"url": "/blog"}, {"$inc": {"pageviews": 1}}, {"upsert": true})

    // 由于不存在文档，会自动新建rep值25的文档，并递增3，最终为28
    db.users.updateOne({"rep": 25}, {"$inc": {"rep": 3}}, {"upsert": true})
    // 再次运行上一条命令会，再次创建rep值25的文档，并递增3
    ```


- `$setOnInsert`：就算再次执行也不会对其进行更新。

    ```mongodb
    - 对于不使用ObjectId的集合来说非常有用
    // $setOnInsert运算符，就算再次执行也不会对其进行更新。
    db.users.updateOne({}, {"$setOnInsert": {"createAt": new Date()}}, {"upsert": true})
    db.users.updateOne({}, {"$setOnInsert": {"createAt": new Date()}}, {"upsert": true})
    db.users.findOne()
    ```

#### 查询

##### 基本查询

```mongodb
// 只查看一个文档
db.users.findOne()

// 查看整个集合，{}代表匹配集合所有内容
db.users.find({})
// 等同于上一条命令，如果没有输入，默认为{}
db.users.find()

db.users.find().pretty()

// 查询age值为27的所有文档
db.users.find({"age": 27})

// 查询多个键-值对。条件1 AND 条件2 AND...AND条件N
db.users.find({ "name": "tz", "age": 27})

// 通过第二个参数，只返回name和age的键。即使有的文档没有name和age键，但_id键依然会被返回
db.users.find({}, { "name": 1, "age": 1})

// 除了name和age的键外都返回。有name的age键的文档的_id键依然会被返回
db.users.find({}, { "name": 0, "age": 0})

// 将_id键剔除，只返回有name和age的键的文档
db.users.find({}, { "name": 1, "age": 1, "_id": 0})
```

- 比较运算符：

    - `$lt`（<）、`$lte`（<=）、 `$gt`（>）、 `$gte`（>=）

    - `$eq`：等于某值
    - `$ne`：不等于某值

    ```mongosh
    // 查询age大于等于18岁，小于等于60岁
    db.users.find({"age": {"$gte": 18, "$lte": 60}})

    // 查询2023年11月18号前注册的用户
    start = new Date("11/18/2023")
    db.users.find({"registered": {"$lt": start}})

    // 查询用户名不是joe的用户
    db.users.find({"name": {"$ne": "joe"}})
    ```

- or查询：
    - `$in`：匹配一个键的多个值
    - `$nin`：反向匹配一个键的多个值
    - `$or`：匹配多个键

    ```mongodb
    // $in。抽奖活动的中奖号码是725、542、390
    db.raffle.find("ticket": {"$in": [725, 542, 390]}})

    // $in可以指定不同类型。匹配user_id为12345以及joe的文档
    db.users.find("user_id": {"$in":[12345, "joe"]})

    // $nin匹配满足条件以外的文档
    db.raffle.find("ticket": {"$nin": [725, 542, 390]}})
    ```

    ```monogodb
    // $or匹配多个键
    db.raffle.find({"$or": {"ticket": 725}, {"winner": true}})

    // $or匹配多个键，$in匹配多个值
    db.raffle.find({"$or": {"$in": "ticket": [725, 542, 390]}, {"winner": true}})
    ```

- `$not`：匹配条件以外
- `$mod`：将查询的值，除以第一个值，如果余数等于第二个值，则匹配成功
    ```mongodb
    // $mod。返回id_num为1, 6, 11, 16的值
    db.users.find({"id_num": {"$mod": [5, 1]}})

    // $not结合$mod。返回id_num为2, 3, 4, 5, 7, 8, 9, 10, 12的值
    db.users.find({"id_num": {"$not" : {"$mod": [5, 1]}}})
    ```

- `null`：除了匹配null值外，还会匹配不存在
- `$exists`：确认键已存在

    ```mongodb
    // 插入测试文档
    db.c.insertMany([
        {"y": null},
        {"y": 1},
        {"y": 2},
    ])

    // 查询y为null
    db.c.find({"y": null})
    [ { _id: ObjectId("6558270ca9bfee369da333fc"), y: null } ]

    // null除了匹配null值外，还会匹配不存在
    db.c.find({"z": null})
    [
      { _id: ObjectId("6558270ca9bfee369da333fc"), y: null },
      { _id: ObjectId("6558270ca9bfee369da333fd"), y: 1 },
      { _id: ObjectId("6558270ca9bfee369da333fe"), y: 2 }
    ]

    // 仅匹配值为null的文档，$eq检测值是否为null，$exists确认键是否存在
    db.c.find({"z": {"$eq": null, "$exists": true}})
    ```

- `$regex`：正则表达式
    - 兼容perl的正则表达式（PCRE）
    - 查询之前，最后先在javascript上检查语法
    - 索引不能用于不区分大小写`/joe/i`
    - 索引能用于前缀表达式`/^joe/`

    ```mongodb
    // 插入测试文档
    db.users.insertMany([
        {"name": "joe"},
        {"name": "Joe"},
        {"name": "JOe"},
        {"name": "JOE"},
        {"name": "joey"},
    ])

    // i不区分大小写。匹配joe, Joe, JOe, JOE, joey
    db.users.find({"name": {"$regex": /joe/i}})
    // 等同于上
    db.users.find({"name": /joe/i})

    // ?匹配joe和joey
    db.users.find({"name": /joey?/})

    // ^匹配开头为joe
    db.users.find({"name": /^joe/})

    // 正则表达式可以插入文档
    db.regex.insertOne({"joe": /^joe/})

    db.regex.findOne()
    { _id: ObjectId("65582b70a9bfee369da33408"), joe: /^joe/ }

    // 将存储的正则表达式，作为变量进行查询
    regex_joe=db.regex.findOne()
    db.users.find({"name": regex_joe.joe})
    ```


- `$where`：可以在查询中执行javascript代码
    - 为了安全起见，应该严格限制，禁止终端用户随意使用`$where`
    - 比常规查询要慢得多。
        - 每个文档必须从bson转换为javascript对象，然后通过`$where`表达式运行
        - 无法使用索引
        - 结论：因此没有其他方法进行查询时，再使用`$where`

    - 可以选进行其他查询进行过滤后，再使用`$where`
        - mongodb3.6：新增`$expr`运算符，可以使用聚合表达式

    ```mongodb
    // 插入测试文档
    db.food.insertOne({"apple": 1, "banana": 6, "peach": 3})
    db.food.insertOne({"apple": 8, "spinach": 4, "watermelon": 4})

    db.food.find({"$where": function() {
        for (var current in this) {
            for (var other in this) {
                if (current != other && this[current] == this[other]){
                    return true;
                }
            }
        }
        return false;
    }})
    // 返回
    {
        _id: ObjectId("6558647f7750de4edeba88e5"),
        apple: 8,
        spinach: 4,
        watermelon: 4
    }
    ```

- `limit()`：限制结果数量。
- `skip()`：跳过结果数量。相当于反向的`limit()`
    - 跳过小量文档还可以，但结果非常多的情况下`skip()`会非常慢。——因为要先找到被跳过的数据，在丢弃这些数据。
    - 大多数数据库会在索引保存更多的元数据以处理`skip()`，但mongodb目前还不支持。
- `sort()`：排序，1为升序（从小到大），-1为降序（从大到小）

    | 混合类型的默认排序                         |
    |--------------------------------------------|
    | 最小值                                     |
    | null                                       |
    | 数字（整型、长整型、双精度浮点型、小数型） |
    | 字符串                                     |
    | 对象/文档                                  |
    | 数组                                       |
    | 二进制数据                                 |
    | 对象ID                                     |
    | 布尔型                                     |
    | 日期                                       |
    | 时间戳                                     |
    | 正则表达式                                 |
    | 最大值                                     |

    ```mongodb
    // limit()。只返回前3个文档
    db.c.find().limit(3)

    // skip()。跳过前3个文档
    db.c.find().skip(3)

    // sort()。name升序，age降序
    db.c.find().sort({"name": 1, "age": -1})

    // 以上3个函数结合使用
    db.stock.find({"desc": "mp3"}).limit(50).sort({"price": -1})
    // skip()跳过大量数据，会非常慢
    db.stock.find({"desc": "mp3"}).limit(50).skip(50).sort({"price": -1})
    ```

    - 使用分页方法代替`skip()`

        ```mongodb
        var page1 = db.foo.find().sort({"date": -1}).limit(100)
        var latest = null;

        // 显示第1页
        while (page1.hasNext()) {
            latest = page1.next();
            display(latest);
        }

        // 获取下1页
        var page2 = db.foo.find({"date": {"$lt": latest.date}});
        page2.sort({"date": -1}).limit(100);
        ```

    - 查询一个随机文档

        ```mongodb
        // 错误示范：使用skip()实现
        var total = db.foo.count()
        var random = Math.floor(Math.random() * total)
        db.foo.find().skip(random).limit(1)
        ```

        ```mongodb
        // 诀窍是每次插入文档，添加一个额外的随机键，可以使用Math.random()函数（0-1之间的小数）
        db.people.insertOne({"name": "joe", "random": Math.random()})
        db.people.insertOne({"name": "john", "random": Math.random()})
        db.people.insertOne({"name": "jim", "random": Math.random()})

        // 生成一个随机数，作为查询条件
        var random = Math.random()
        result = db.people.findOne({"random": {"$lte": random}})

        // 这种方式可以用于任意复杂查询，只需确保一个包含随机键的索引。
        // 如果要在某地区，随机查询一个水管工，可以在profession, state, random上创建索引
        db.people.ensureIndex({"profession": 1, "state": 1, "random": 1})
        ```

##### 查询数组

- `$all`：匹配多个值。顺序无关紧要

- `$size`：指定长度

    - 不能与`$gt`一起使用

    ```mongodb
    // 插入测试文档
    db.food.insertMany([
        {"_id": 1, "fruit": ["apple", "banana", "peach"]},
        {"_id": 2, "fruit": ["apple", "kumquat", "orange"]},
        {"_id": 3, "fruit": ["cherry", "banana", "apple"]},
    ])

    // 匹配包含banana的数组
    db.food.find({"fruit": "banana"})
    [
      { _id: 1, fruit: [ 'apple', 'banana', 'peach' ] },
      { _id: 3, fruit: [ 'cherry', 'banana', 'apple' ] }
    ]

    // 精确匹配整个数组
    db.food.find({"fruit": [ 'apple', 'banana', 'peach' ]})

    // $all。匹配包含apple和banana的数组。顺序无关紧要
    db.food.find({"fruit": {"$all": ["apple", "banana"]}})
    [
      { _id: 1, fruit: [ 'apple', 'banana', 'peach' ] },
      { _id: 3, fruit: [ 'cherry', 'banana', 'apple' ] }
    ]

    // 查询数组中第1个元素是apple的
    db.food.find({"fruit.0": "apple"})

    // 查询数组中第3个元素是apple的
    db.food.find({"fruit.2": "apple"})

    // 查询长度为3的数组
    db.food.find({"fruit": {"$size": 3}})

    // 由于$size不能与$gt一起使用。可以将另辟蹊径，设置size字段，每次push就+1
    db.food.updateMany({}, {"$set": {"size": 3}})
    db.food.updateOne({_id: 2}, {"$push": {"fruit": "strawberry"}, "$inc": {"size": 1}})
    // 查询长度大于3的数组
    db.food.find({"size": {"$gt": 3}})
    ```

- `$slice`：返回指定的元素
    ```mongodb
    // 插入测试文档
    db.blog.posts.insertOne({
        "_id": 1,
        "connect": "hello",
        "comments": [
            {"comment": "good post", "author": "john", "votes": 0},
            {"comment": "i thought it was too short", "author": "claire", "votes": 3},
            {"comment": "free watch", "author": "alice", "votes": -5},
            {"comment": "vacaton getaways", "author": "lynn", "votes": -7},
        ]
    })

    // 查看前3条评论
    db.blog.posts.findOne({"_id": 1}, {"comments": {"$slice": 3}})

    // 查看倒数3条评论
    db.blog.posts.findOne({"_id": 1}, {"comments": {"$slice": -3}})

    // 查看从包含第1条开始的前3条评论
    db.blog.posts.findOne({"_id": 1}, {"comments": {"$slice": [0, 3]}})

    // 查看从包含第3条开始的前2条评论
    db.blog.posts.findOne({"_id": 1}, {"comments": {"$slice": [2, 2]}})

    // 使用$定位符
    db.blog.posts.findOne({"comments.author": "alice"}, {"comments.$": 1})
    ```

- 范围查询

- `$elemMatch`：强制将子句与每个数组元素比较。不会匹配非数组元素

- `min()`和`max()`：只有在字段有索引时才能使用。

    ```mongodb
    // 插入测试文档
    db.test.insertMany([
        {"x": 5},
        {"x": 15},
        {"x": 25},
        {"x": [5, 25]},
    ])

    // 查询大于10和小于20。第二条数组由于5小于20因此会被返回，这样就失去范围查询的意义了
    db.test.find({"x": {"$gt": 10, "$lt": 20}})
    [
      { _id: ObjectId("65585b557750de4edeba88e0"), x: 15 },
      { _id: ObjectId("65585b557750de4edeba88e2"), x: [ 5, 25 ] }
    ]

    // $elemMatch强制将2个条件子句与每个数组元素比较。但不会匹配非数组元素所以{"x": 15}不匹配
    db.test.find({"x": { "$elemMatch": {"$gt": 10, "$lt": 20}}})
    //没有结果

    // 使用min()和max()，上面例子的索引版。会遍历10到20的索引，不会与值5、25两个条目进行比较
    db.test.find({"x": {"$gt": 10, "$lt": 20}}).min({"x": 10}).max({"x": 20})
    ```

##### 查询内嵌文档

```mongodb
// 插入测试文档
db.people.insertOne({
    "name":{
        "first": "joe",
        "last": "schmoe",
    },
    "age": 45,
})

// 通过内嵌文档键进行查询
db.people.find({"name.first": "joe"})
```

- `$elemMatch`：无须指定每个键

```mongodb
// 插入测试文档
db.blog.posts.insertOne({
    "_id": 1,
    "connect": "hello",
    "comments": [
        {"comment": "good post", "author": "john", "votes": 0},
        {"comment": "i thought it was too short", "author": "claire", "votes": 3},
        {"comment": "free watch", "author": "alice", "votes": -5},
        {"comment": "vacaton getaways", "author": "lynn", "votes": -7},
    ]
})

// 查询内嵌文档author字段为claire，并且votes大于0的文档
db.blog.posts.find({"comments": {"$elemMatch" : {"author": "claire", "votes": {"$gte": 0}}}})
```

##### 游标

- 服务端：游标会占用内存和资源。一旦遍历完后，应尽快释放资源。

    - 超时机制：如果10分钟后，游标没有使用会自动销毁。就算客户端出错，也可以释放。

    - 一些驱动程序事项一个`immortal()`或类似的机制，使超时机制关闭。需要主动销毁游标，否则会一直占用资源，直到服务器重启

- 客户端：调用`find()`：不会立即查询数据库，而是等到开始请求结果时，才会发送查询。

- 可以在执行之前给查询附加额外选项

    ```mongodb
    // 以下都是一样的
    var cursor = db.foo.find().sort({"x": 1}).limit(1).skip(10);
    var cursor = db.foo.find().limit(1).sort({"x": 1}).skip(10);
    var cursor = db.foo.find().skip(10).limit(1).sort({"x": 1});
    ```

- `next()`：下一个结果
- `hasNext()`：检查是否还有剩下的结果。执行后，查询会被发往服务器端，shell会立刻获取前100个结果或前4MB的数据（两者之中的小者）。下次调用`next()`或`hasNext()`就不用再次连接服务器获取结果了。知道客户端遍历完第一组后，shell才会再次连接数据库，使用`getmore`可以获取更多结果

    ```mongodb
    for(i=0; i<100; i++) {
        db.collection.insertOne({x: i})
    }

    var cursor = db.collection.find();

    // next()和hasNext()
    while (cursor.hasNext()) {
        obj = cursor.next();
        // 执行任务
    }
    ```

- `forEach()`：迭代器接口
    ```mongodb
    // 插入测试文档
    db.people.insertMany([
        {"name": "joe", "age": 10},
        {"name": "jack", "age": 20},
        {"name": "jim", "age": 30},
        {"name": "alice", "age": 40},
    ])

    // forEach()迭代器
    var cursor = db.people.find();
    cursor.forEach(function(x) {
        print(x.name);
    });
    ```

## 索引（index）

- 集合扫描：不使用索引的查询。

    - 数据库索引类似于图书的目录，有了目录就不需要浏览整本书，才能查询到结果

- 创建索引：只需要几秒的时间，除非集合特别大。

    - 如果几秒后没有返回，则可以运行`db.currentOp()`（在另一个shell）或检查mongod的日志查看索引创建进度

    - 创建的索引要被RAM所容纳

- 索引的缺点：

    - 修改索引字段的写操作（插入、更新、删除），会花费更大时间。因为除了更新文档，还要更新索引

        - 因此在现有文档上创建索引，比先创建索引再插入文档更快。

    - 创建新索引费时、费资源：
        - mongodb4.2之前：会阻塞所有读写操作，直到索引完成
        - mongodb4.2之后：新增排他锁，会交错让步给读写操作

- 什么时候不使用索引？

    - 结果集在原集合所占百分比越大，索引就会越低效

        - 全表扫描需要1次查找：查找文档
        - 索引扫描需要2次查找：1次查找索引项，一次根据索引的指针查找所指向的文档
            - 最快情况下：返回集合内的索引文档，索引查找的次数是全表扫描的2倍，比全表扫描慢

        | 索引适用的情况 | 全表扫描适用的情况 |
        |----------------|--------------------|
        | 比较大的集合   | 比较小的集合       |
        | 比较大的文档   | 比较小的文档       |
        | 选择性查询     | 非选择性查询       |

    - 根据经验，返回集合中30%或更少，索引可以加快速度。然而这个数字会在2%-60%变动

    - 假设有一个收集统计信息的分析系统。根据1小时之前开始的数据生成一个图表
        ```mongodb
        // 在created_at创建索引
        db.entries.find("created_at": {"$lt": hourAgo})
        ```

        - 最初运行时：结果集很小，可以立即返回
        - 1个月后：数据多起来，查询慢
            - 这可能是个错误查询。你真的需要返回数据集的大部分内容吗？大部分应用不需要。

### 基本命令

```mongodb
// 创建"name"字段的单键索引
db.users.createIndex({"name": 1})
// 创建"name"和age字段的复合索引
db.users.createIndex({"name": 1, "age": 1})

// explain()查看查询计划
db.users.insert({"name": "joe"})
db.users.find({"name": "joe"}).explain()

// 查看集合所创建的索引
db.users.getIndexes()

// 更详细查看集合所创建的索引。mongodb4.2之前使用system.indexes。4.2之后改为以下命令
db.runCommand({listIndexes: "users"})

//删除索引
db.users.dropIndex({"name": 1})
```

### explain()输出

- `stage: 'COLLSCAN'`：没有使用索引的集合扫描
- `stage: 'IXSCAN'`：使用索引

- `needYield: 0`：暂停的次数。如果有写操作，查询会定期释放锁让步给写操作
- `indexBound: {}`：索引如何被使用，并给出索引的遍历范围
    - 精确查询：如`{age: 42}`，只需要查找42这个值
    - 范围查询：假设有索引`{"age": 1, "name": 1}`
        ```mongodb
        db.users.find({"age": {"$gt": 10}, "name": "user2134"}).explain()

        // explain输出
        "indexBounds":{
            "age":[
                "(10.0, inf.0]"
            ],
            "username":[
                "[\ "user2134\",\"user2134\"]"
            ]
        }
        ```

| executionStats字段下的重要的参数 | 说明                                                           |
|----------------------------------|----------------------------------------------------------------|
| nReturned                        | 返回的文档数量                                                 |
| executionTimeMillis              | 查询时间（单位：毫秒）（越少越好）                             |
| totalKeysExamined                | 使用索引：查找过索引项的数量；没有使用索引：检查过文档的数量   |
| totalDocsExamined                | 按照索引指针，在磁盘上查找实际文档的数量；如果查询条件不是索引一部分：查找每个索引指向 的文档（越少越好） |

### 复合索引（compound index）

- 复合索引：多个键上创建索引
    - 复合索引会将字段按顺序保存。所以查询时的条件是否满足前缀顺序非常重要

- `{"age": 1, "name": 1}`的索引会是下面这个样子

    - 每个索引项包含age和name的升序（从小到大）

    ```
    [0,"user100020" ] -> 8623513776
    [0,"user1002"   ] -> 8599246768
    [0,"user100388" ] -> 8623560880
    [0,"user100414" ] -> 8623564208
    ...
    [1,"user100113" ] -> 8623525680
    [1,"user100280" ] -> 8623547056
    [1,"user100551" ] -> 8623581744
    [1,"user100626" ] -> 8623591344
    ...
    [2,"user100191" ] -> 8623535664
    [2, "user100195"] -> 8623536176
    [2,"user100197" ] -> 8623536432
    ```

- 多种索引查询

    - 创建{"age": 1, "name": 1}的复合索引

        ```mongodb
        db.users.createIndex({"age": 1, "name": 1})
        ```

    - 1.等值查询：效率高
        ```mongodb
        // 会先匹配{"age": 21}的最后一项，在依次反向遍历索引（反向的排序方向，依然满足索引）。不需要在内存进行sort排序
        db.users.find({"age": 21}).sort({"name": -1})
        ```

    - 2.多值查询：效率较低

        ```mongodb
        // 索引不会按照顺序返回name，而查询要求对name结果进行排序，因此需要在内存进行sort排序
        db.users.find({"age": {"$gte": 21, "$lte": 30}}).sort({"name": 1})
        ```

        - 如果要排序的结果超过32MB，mongodb会报错
            - 解决方法：
                - 创建一个支持此排序的索引
                - `limit`和`sort`的结合使用，使结果小于32MB

        - 如果索引是`{"name": 1, "age": 1}`：效率高
            - 会遍历所有索引项，然后使用索引项age的部分匹配文档。
            - 不需要在内存对大量数据进行排序

### 如何设计索引？

- 如何选择索引？

    - 1.假设一个查询进入，5个索引中有3个被标识为候选索引。

    - 2.mongodb便会为3个索引，创建查询计划，并在3个并行线程运行。看哪一个最快返回结果。（类似于竞赛）

    - 3.以后会选择最快的那个返回，作为索引，用于相同形状的其他查询

        - 服务端会维护查询计划缓存。随着集合和索引的变化，旧的查询计划可能会被缓存淘汰。

            - mongod进程重启会丢失查询计划缓存

- 如何设计索引的排序方向？

    - 相反的方向是等价的（乘以-1）：因为可以从相反的方向读取索引

        - `{"age": 1, "name": 1}` 等价于 `{"age": -1, "name": -1}`
        - `{"age": -1, "name": 1}` 等价于 `{"age": 1, "name": -1}`

    - 结论：不要建立两个等价的索引

- 隐式索引：

    - 一个索引`{"a": 1, "b": 1, "c": 1}`：

        - 等同于有了：
            - {"a": 1}
            - {"a": 1, "b": 1}
            - {"a": 1, "b": 1, "c": 1}
        - 但并不等同于有了：
            - {"b": 1}
            - {"a": 1, "c": 1}

- 基数索引
    - 基数（cardinality）：集合中某个字段有多少个不同的值
        - "name"、"email"这些字段：几乎每个文档都有不同的值，基数就高
        - "gender"、"newsletter opt-out"这些字段：可能只有2个值，基数就低

    - 对比：
        - 基数高的字段：索引就越有用。因为索引能够迅速将搜索方位搜小到一个比较小的结果集
        - 基数低的字段：索引可能无法排除大量可能的匹配项
        - 例子：查找Susan的女性。
            - 在`"gender"`上的创建索引：只能将搜索空间缩小大约50%，然后在查询"name"字段
            - 在`"name"`上的创建索引：可以立即缩小到name为Susan的一小部分用户，在查询性别

    - 结论：
        - 应该在基数比较高的键上，创建索引
        - 应该把基数比较高的键上，放在复合索引的前面
#### 如何设计复合索引？

- 为了找到正确的索引，有必要在一些实际的工作负责下对索引进行测试，并从中调整

- 思路：对于给定的查询模式，索引将在多大程度上减少扫描的记录数。

- 不同字段顺序的复合索引的性能对比：

    - 结论：顺序为：等值字段->排序字段->多值字段

    - 假设有一个1000000条记录的学生数据集。文档像下面这样

        ```json
        db.students.insertOne({
            "student_id": 0,
            "scores":[
              {
                "type":"exam",
                "score":38.05000060199827,
              },
              {
                "type":"quiz",
                "score":79.45079445008987,
              },
              {
                "type":"homework",
                "score":74.50150548699534,
              },
              {
                "type":"homework",
                "score": 74.68381684615845,
              }
            ],
            "class_id":127,
        })
        ```

    - 例子1：等值字段与多值字段的不同顺序对比

        - 查询

            ```mongodb
            db.students.find({"student_id": {"$gt": 50000}, "class_id": 54}).sort({"student_id: 1"}).explain("executionStats")
            ```

        - 从两个索引开始，看看mongodb会选择哪个？
            ```mongodb
            db.students.createIndex({"class_id": 1})
            db.students.createIndex({"student_id": 1, "class_id": 1})
            ```

        - 一个阶段可以有一个或多个输入阶段

        - `winningPlan`为获胜的查询计划：这个例子的获胜索引是`student_id_1_class_id_1`

            ```mongodb
            // 有一个输入阶段，即索引扫描。然后"FETCH"阶段会获取文档，并分批返回给客户端
            "winningPlan":{
                "stage":"FETCH",
                "inputStage":{
                    "stage":"IXSCAN",
                    "keyPattern": {
                    "student_id": 1,
                    "class_id": 1
            ```

        - `rejectedPlans`为失败的查询计划：这个例子的失败索引是`class_id_1`。因为使用索引后，还要进行内存排序。

            ```mongodb
            // 可以看到查询计划中有"SORT"阶段
            "rejectedPlans"：[
                {
                    "stage":"SORT",
                    "sortPattern":{
                        "student_id":1
                        },

            ```

        - 分析：
            - 这个查询包含多值部分、等值部分。
            - 等值部分要求`class_id`等于54。这个大约只有500个班级，虽然班级中有大量学生。因此`class_id`才此查询更具有选择性。
                - 可以将结果限制在10000条以下，而不是多值部分的850000条

            - 结论：基于`class_id`索引会更好

        - `hint()`：强制使用指定索引
            ```mongodb
            // 强制使用class_id索引
            db.students.find({"student_id": {"$gt": 50000}, "class_id": 54}).sort({"student_id: 1"}).hint({"class_id"}).explain("executionStats")
            ```

        - 为了更有效地执行此查询，我们希望不使用`hint()`。因此需要设置一个更好的索引

            ```mongodb
            // 以等值的字段class_id为前缀。这样只需从class_id:54的第一对键开始遍历
            db.students.createIndex({"class_id": 1, "studnet_id": 1})
            ```

    - 例子2：在等值字段与多值字段的基础上，加入排序字段的顺序对比

        - 查询

            ```mongodb
            // 改为按最终成绩排序
            db.students.find({"student_id": {"$gt": 50000}, "class_id": 54}).sort({"final_grade": 1}).explain("executionStats")
            ```

        - 分析：explain输出，会发现有`"SORT"`阶段使用了内存排序

        - 设计更好的索引，避免内存排序。需要在复合索引键中包含排序的字段
            ```mongodb
            // 顺序为：等值->排序->多值
            db.students.createIndex({"class_id": 1, "final_grade": 1, "student_id": 1})
            // 最后explain的输出，避免了内存排序
            ```

### $运算符如何使用索引

- 1.取反的效率是比较低的

    - 1.`$ne`：可以使用索引，但效率低。因为必须查看所有索引项，不只是`$ne`指定的索引项，因此基本必须扫描整个索引
        ```mongodb
        // 这个查询必须查找所有小于3和大于3的索引项。除非值为3的项非常多，不然就必须扫描大部分索引项
        db.example.find({"i": "$ne": 3}).explain()
        ```

    - 2.`$not`：有时能使用索引，单它并不知道如何使用。
        - 可以对范围查询（如{"key": {"$gt": 7}}, {"key": {"$lt": 7}}）和正则表达式进行反转
        - 大多数会退化为全表扫描

     3.`$nin`：总是全表扫描

- 2.范围查询

    - 优先顺序应该是：第一个索引键为精确匹配，第二个索引键为范围匹配
        - 例子：`{"x": 1, "y": {"$gt": 5, "$lt": 10}}`

    - 同样的查询，在不同索引顺序对比：

        ```mongodb
        db.example.find({"age": 47, "name": {"$gt": "user5", "$lt": "user8"}}).explain("executionStats")
        ```

        - 假设索引为`{"age": 1, "name": 1}`

            - 查询会先定位到"age": 47，再搜索name在user5到user8之间

        - 假设索引为`{"name": 1, "age": 1}`

            - 查询会先搜索name在user5到user8之间，再挑出"age": 47
            - 扫描索引项是上一个的100倍。低效很多

- 3.`$or`

    - 1次查询，只能使用1次索引。
        - 例子：有一个`{"x": 1}`索引和有一个`{"y": 1}`索引。查询条件为`{"x": 123, "y": 321}`只能使用其中的一个。但`$or`除外

    - `$or`：每个子句都可以使用一个索引。实际上是执行2次查询，然后将结果合并，移除重复的文档
        ```mongodb
        // explain会输出两个"IXSCAN"阶段
        db.example.find({"$or": [{"x": 123}, {"y": 321}]}).explain()
        ```

    - 结论：执行2次查询再合并结果的效率，不如1次高。因此尽可能使用`$in`，而不是`$or`
        - 除非使用排序：因为`$in`无法控制返回文档的顺序
            - 例子：两者返回的顺序是一样的`{"x": {"$in": [1, 2, 3]}}`，`{"x": {"$in": [3, 2, 1]}}`

### 索引内嵌文档

- 包含内嵌文档的文档

    ```mongodb
    // 内嵌文档
    db.users.insertOne({
        "username": "joe",
        "loc": {
            "ip": "192.168.1.1",
            "city": "Springfield",
            "state": "NY"
        }
    })
    ```

- 对整个子文档创建索引。

    ```mongodb
    // 对整个子文档loc创建索引
    db.users.createIndex({"loc": 1})

    // 完全匹配。可以使用索引
    db.users.find({
        "loc": {
            "ip": "192.168.1.1",
            "city": "Springfield",
            "state": "NY"
        }
    }).explain()

    // 可以使用索引
    db.users.find({"loc": {"state": "Springfield"}}).explain()

    // 无法使用索引
    db.users.find({"loc.state": "Springfield"}).explain()
    ```

- 创建内嵌文档索引
    ```mongodb
    // 创建内嵌文档索引
    db.users.createIndex({"loc.state": 1})

    // 可以使用索引
    db.users.find({"loc.state": "Springfield"}).explain()
    ```

### 索引数组文档

- 假设有一个博客文章集合，每一个文档是一篇文章。每篇文章有一个`"comments"`字段的数组。
    ```mongodb
    // 如果项查找评论次数最多的博客文章，可以在comments数组的date键上创建索引
    db.blog.createIndex({"comments.date": 1})
    ```

- 对数组创建索引：是对数组的每一个元素，创建索引项。

    - 对于单次的插入、更新、删除，每一个数组项都有可能需要更新（也许有千个索引项）

    - 因此代价比单值索引高

- 数组元素不包含位置信息：因此`comments.4`无法使用索引

    - 需要创建`db.blog.createIndex({"comments.4.votes": 1})`。但只有精确匹配到第5个元素才会其作用（索引从0开始）

- 索引项只能有一个自动是来自数组：避免在多键索引中索引项数量爆增（n*m个索引项）
    - 例子：假设有一个`{"x": 1, "y": 1}`的索引
        ```mongodb
        // 合法。只有x一个数组
        db.multi.insert({"x": [1, 2, 3], "y": 1})

        // 合法。只有y一个数组
        db.multi.insert({"x": 1, "y": [1, 2, 3]})

        // 不合法。x和y都是数组
        db.multi.insert({"x": [1, 2, 3], "y": [3, 2, 1]})
        cannot index parallel arrays [y] [x]
        ```

- 多键索引（`isMultiKey`）

    - 一个文档有被索引数组字段，会被标记为多键索引：`isMultiKey: true,`
        ```mongodb
        db.multi.insert({"x": [1, 2, 3], "y": 1})
        db.multi.createIndex({"x":1, "y":1})

        // explain输出isMultiKey: true
        db.multi.find({"x":[1,2,3]}).explain()
        ```

    - 多键索引无法变成非多键索引，即使该字段中包含数组的所有文档都删除也一样。
        - 唯一的方法是删除并重建索引

    - 多键索引比非多键索引，要慢一些
        - 可能会有许多索引项，指向同一个文档，mongodb返回结果之前需要删除重复数据

### 唯一索引

- 唯一索引：确保索引只会出现1次。

    ```mongodb
        // 创建唯一索引
        db.users.createIndex({"firstname": 1}, {"unique": true})

        // 第1次插入成功
        db.users.insert({"firstname": "bob"})
        // 第2次插入报错
        db.users.insert({"firstname": "bob"})
        Uncaught:
        MongoBulkWriteError: E11000 duplicate key error collection: test.users index: firstname_1 dup key: { firstname: "bob" }
        Result: BulkWriteResult {
          insertedCount: 0,
          matchedCount: 0,
          modifiedCount: 0,
          deletedCount: 0,
          upsertedCount: 0,
          upsertedIds: {},
          insertedIds: { '0': ObjectId("655b820e401a3a90f6352e61") }
        }
        Write Errors: [
          WriteError {
            err: {
              index: 0,
              code: 11000,
              errmsg: 'E11000 duplicate key error collection: test.users index: firstname_1 dup key: { firstname: "bob" }',
              errInfo: undefined,
              op: { firstname: 'bob', _id: ObjectId("655b820e401a3a90f6352e61") }
            }
          }
        ]
        ```


- `_id`：也是唯一索引，只是不能被删除。

- 超过大小限制的值，可能不会被索引：索引桶（index bucket）的大小有限制
    - mongodb4.2之前：索引包含的字段必须小于1024字节
    - mongodb4.2及之后：限制被去掉，不会返回任何错误和警告

        - 意味着超过8KB的键可以不受唯一索引约束。例如插入多个相同8KB的字符串

- 如果集合有重复值，则无法创建唯一索引
    - 可以使用聚合框架，找出重复值

- 复合唯一索引：单个键可以有相同的值

    ```mongodb
    // 创建复合唯一索引
    db.users.createIndex({"name": 1, "age": 1}, {"unique": true})

    // 以下都是合法的
    db.users.insert({"name": "joe"})
    db.users.insert({"name": "joe", "age": 47})
    db.users.insert({"name": "john", "age": 47})

    // 报错
    db.users.insert({"name": "john", "age": 47})
    ```

### 部分索引

- 部分索引不必是唯一索引

- 部分索引只会在数据的一个子集上创建。

    - 与关系型数据库的稀疏索引不同。关系型数据库创建的指向一个数据块索引项会更少，不过所有数据块都有一个关联的稀疏索引项

- 唯一索引的问题：如果一个键不存在，索引会将其作为`null`存储。如果再一次插入缺少索引键的文档，由于已经存在一个`null`了，所以会导致失败

    - 解决方法：创建部分唯一索引，`unique`和`partial`选项一起使用

  ```mongodb
    // 创建部分唯一索引
    db.users.createIndex({"firstname": 1}, {"unique": true, "partialFilterExpression": {"firstname": {$exists: true}}})

    // 第1次插入成功
    db.users.insert({"firstname": "bob"})
    // 第2次插入报错
    db.users.insert({"firstname": "bob"})
    Uncaught:
    MongoBulkWriteError: E11000 duplicate key error collection: test.users index: firstname_1 dup key: { firstname: "bob" }
    Result: BulkWriteResult {
      insertedCount: 0,
      matchedCount: 0,
      modifiedCount: 0,
      deletedCount: 0,
      upsertedCount: 0,
      upsertedIds: {},
      insertedIds: { '0': ObjectId("655b7c45401a3a90f6352e5b") }
    }
    Write Errors: [
      WriteError {
        err: {
          index: 0,
          code: 11000,
          errmsg: 'E11000 duplicate key error collection: test.users index: firstname_1 dup key: { firstname: "bob" }',
          errInfo: undefined,
          op: { firstname: 'bob', _id: ObjectId("655b7c45401a3a90f6352e5b") }
        }
      }
    ]
    ```

### 地理空间索引

- 有2种地理空间索引：

    - 1.`2d`索引：存储二维平面上的点

        - `2d`索引既支持平面几何图形，也支持球面上涉及距离的计算（如使用`$nearSphere`）。但`2dsphere`索引更在球面几何查询饰更高效

    - 2.`2dsphere`索引：基于WGS84基准的地球球面几何模型一起使用。这个基准将地球表面模拟成一个扁圆球体。意味着两极会比较扁。

        - 因此`2dsphere`计算两个城市的距离，会考虑到地球的形状比`2d`索引更准

- `2dsphere`索引运行GeoJSON格式。指定点、线、多边形

    ```mongodb
    // loc只是名字可以自定义。但内嵌文档的字段有GeoJSON指定，不能更改
    // 点
    {
        "name": "New York City",
        "loc": {
            "type": "Point",
            "coordinates": [50, 2]
        }
    }

    // 线
    {
        "name": "Hudson River",
        "loc": {
            "type": "LineString",
            "coordinates": [[0, 1], [0, 2], [1, 2]]
        }
    }

    // 多边形。和线一样，但"type"不同
    {
        "name": "New England",
        "loc": {
            "type": "Polygon",
            "coordinates": [[0, 1], [0, 2], [1, 2], [0, 1]]
        }
    }
    ```

    ```mongodb
    // 创建2dsphere索引。需要传递一个文档，该文档包含几何图形字段。这里为loc。
    db.openStreetMap.createIndex({"loc": "2dsphere"})
    ```

- 3种地理空间查询：交集（intersection）、包含（within）、接近（nearness）

    - `$geometry`：指定GeoJSON对象

    ```mongodb
    // 创建一个地理空间变量eastVillage
    var eastVillage = { "type" : "Polygon", "coordinates" : [ [ [ -73.9732566, 40.7187272 ], [ -73.9724573, 40.7217745 ], [ -73.9717144, 40.7250025 ], [ -73.9714435, 40.7266002 ], [ -73.975735, 40.7284702 ], [ -73.9803565, 40.7304255 ], [ -73.9825505, 40.7313605 ], [ -73.9887732, 40.7339641 ], [ -73.9907554, 40.7348137 ], [ -73.9914581, 40.7317345 ], [ -73.9919248, 40.7311674 ], [ -73.9904979, 40.7305556 ], [ -73.9907017, 40.7298849 ], [ -73.9908171, 40.7297751 ], [ -73.9911416, 40.7286592 ], [ -73.9911943, 40.728492 ], [ -73.9914313, 40.7277405 ], [ -73.9914635, 40.7275759 ], [ -73.9916003, 40.7271124 ], [ -73.9915386, 40.727088 ], [ -73.991788, 40.7263908 ], [ -73.9920616, 40.7256489 ], [ -73.9923298, 40.7248907 ], [ -73.9925954, 40.7241427 ], [ -73.9863029, 40.7222237 ], [ -73.9787659, 40.719947 ], [ -73.9772317, 40.7193229 ], [ -73.9750886, 40.7188838 ], [ -73.9732566, 40.7187272 ] ] ]}

    // $geoIntersects交集。找到纽约与eastVillage有交集的点、线、多边形文档
    db.openStreetMap.find({"loc" : {"$geoIntersects" : {"$geometry" : eastVillage}}})
    // $geoWithin交集。与上条命令不同的是，这次不返回重叠的文档
    db.openStreetMap.find({"loc" : {"$geoWithin" : {"$geometry" : eastVillage}}})
    // $geoNear是一个聚合运算符。不适用于分片。最多只能有一个2dsphere和2d索引。查找附近的位置，按近到远返回。
    db.openStreetMap.find({"loc" : {"$geoNear" : {"$geometry" : eastVillage}}})
    ```

- `2dsphere`索引

    ```mongodb
    // 使用mongoimport导入《MongoDB权威指南》一书给的第6章的2个json数据
    mongoimport --host=127.0.0.1 --port=27017 --db=test --collection=restaurants --file=restaurants.json
    mongoimport --host=127.0.0.1 --port=27017 --db=test --collection=neighborhoods --file=neighborhoods.json
    ```
    ```mongodb
    // 对刚才导入的集合，创建2dsphere索引
    db.neighborhoods.createIndex({location:"2dsphere"})
    db.restaurants.createIndex({location:"2dsphere"})

    // 查询
    db.neighborhoods.find({name: "Clinton"})
    db.restaurants.find({name: "Little Pie Company"})

    // $geoIntersects交集。定位经度-73.93414657, 纬度40.82302903的用户所在的街区
    db.neighborhoods.findOne({geometry: {$geoIntersects: {
        $geometry: {
            type: "Point",
            coordinates: [-73.93414657, 40.82302903]
            }}}})

    // $geoWithin。找到所在街区的所有餐馆。一共127家餐馆
    var neighborhoods = db.neighborhoods.findOne({geometry: {$geoIntersects: {
        $geometry: {
            type: "Point",
            coordinates: [-73.93414657, 40.82302903]
            }}}})

    db.restaurants.find({
        location: {
            $geoWithin: {
                $geometry: neighborhoods.geometry
            }
        }
    })

    // $geoWithin和$centerSphere。找到所在街区的5英里（1英里=1.609344千米）内的所有餐馆。第二个参数为以弧度表示的半径，除以3963.2英里（地球赤道半径）将距离转换为弧度
    db.restaurants.find({
        location: {
            $geoWithin: {
                $centerSphere: [
                    [-73.93414657, 40.82302903], 5/3963.2
                ]
            }
        }
    })

    // $maxDistance返回以米为单位，距离用户5英里内的所有餐馆，并由近到远排序。实际运行报错了??
    var METERS_PER_MILE = 1609.34
    db.restaurants.find({
        location: {
            $nearSphere: {
                $geometry: {
                    type: "Point",
                    coordinates: [-73.93414657, 40.82302903]
                }
            },
            $maxDistance: 5*METERS_PER_MILE
        }
    })
    ```

    - `2dsphere`复合索引：单键索引只能缩小到Hell's Kithchen中的所有内容，在索引添加字段可以将其缩小查询"pizza"
        - 其他普通字段放在`2dsphere`字段之前还是之后，取决于希望先使用普通字段进行过滤，还是先使用位置进行过滤。（应该选择能过滤更多结果的字段放在前面）
        ```mongodb
        // 加入tag字段
        db.openStreetMap.createIndex({"tag": 1, "location": "2dsphere"})
        // 查找Hell's Kithchen中的比萨店
        db.openStreetMap.find({
            "loc": {"$geoWithin": {"$geometry": hellskitchen.geometry}},
            "tags": "pizza"
        })
        ```

- `2d`索引：对于非球面地图（游戏地图、时间序列数据等），可以使用`2d`索引代替`2dsphere`索引

    - 如果向存储GeoJSON，就不要使用`2d`索引。因为`2d`只能对点进行索引，虽然可以存储由点组成的数组，但这不能是一条直线

    ```mongodb
    // 创建2d索引
    db.hyrule.createIndex({"tile": "2d"})
    // 2d索引默认取值为-180到180。min和max可以对其调整
    // 这会对2000 * 2000的正方形创建索引
    db.hyrule.createIndex({"tile": "2d"}, {"min": -1000, "max": 1000})
    ```

    ```mongodb
    db.hyrule.createIndex({"tile": "2d"})

    // $box。在左下角为[10, 10]，右下角为[100, 100]的矩形内的文档进行查询
    db.hyrule.find({
        tile: {
            $geoWithin: {
                $box: [[10, 10], [100, 100]]
            }
        }
    })

    // $center。查询圆心[-17, 20.5]半径为25的圆形内的文档
    db.hyrule.find({
        tile: {
            $geoWithin: {
                $center: [[-17, 20.5], 25]
            }
        }
    })

    // $polygon。查询[0, 0], [3, 6], [6, 0]组成的多边形内的所有文档
    db.hyrule.find({
        tile: {
            $geoWithin: {
                $polygon: [[0, 0], [3, 6], [6, 0]]
            }
        }
    })
    ```

    - `2d`索引的球面查询，更应该使用`2dsphere`

        ```mongodb
        // $centerSphere。查询圆心以弧度作为半径
        db.hyrule.find({
            tile: {
                $geoWithin: {
                    $centerSphere: [[88, 30], 10/3963.2]
                }
            }
        })

        // $near。查询附近的点，并按照点的距离进行排序
        db.hyrule.find({"tile": {"$near": [20, 21]}})
        // 如果没有指定限制，默认为返回100个文档
        db.hyrule.find({"tile": {"$near": [20, 21]}}).limit(10)
        ```

### 文本索引（全文搜索索引）

- mongodb文本索引不同于mongodb Atlas的全文搜索索引（full-text search index）。后者利用`Apache Lucene`提供额外的文本搜索功能

- 文本索引：查询集合中的标题、描述、其他字段的文本。

    - 正则表达式的搜索大块文件会非常慢。文本索引可以快速搜索常见的搜索引擎需求（语言标计化、停止单词、词干查询）

- 缺点：

    - 创建文本索引可能会消耗大量系统资源。

        - 建议后台创建

    - 写操作需要更新所有索引：文本索引比单键、复合等开销要更大

        - 如果正在使用分片，还会减慢数据移动的速度；当迁移一个新分片时，所有文本都必须重新进行索引


- 创建文本索引

    - 与普通索引不同：索引中字段的顺序并不重要。可以为字段指定权重，赋予相对重要性

    ```mongodb
    // 假设有一个维基百科集合需要进行索引。
    db.articles.createIndex({"title": "text", "body": "text"})

    // weights。指定字段权重，赋予相对重要性
    db.articles.createIndex({"title": "text", "body": "text"},
        {"weights": { "title": 3, "body": 2 }}
    )

    // 对于一些集合，可能并不知道文档包含那些字段。可以使用$**在所有字符串字段创建索引
    db.articles.createIndex({"$**": "text"})
    ```

- 文本查询

    - `$text`查询运算符

    - `$meta`运算符：将数据投射出来，否则元数据不会显示到查询结果

    ```mongodb
    // 空格为分隔符，执行OR逻辑的查询。以下查询包含"impact" "crater" "lunar"的所有文章
    db.articles.find({"$text": {"$search": "impact crater lunar"}},
        {title: 1}
    ).limit(10)

    // \"连接短语。impact crater AND lunar
    db.articles.find({"$text": {"$search": "\"impact crater\" lunar"}},
        {title: 1}
    ).limit(10)

    // impact crater AND lunar OR meteor
    db.articles.find({"$text": {"$search": "\"impact crater\" lunar meteor"}},
        {title: 1}
    ).limit(10)

    // 全部使用AND。impact crater AND lunar AND meteor
    db.articles.find({"$text": {"$search": "\"impact crater\" \"lunar\" \"meteor\""}},
        {title: 1}
    ).limit(10)

    // $meta将分数存储到textScore的字段
    db.articles.find({"$text": {"$search": "\"impact crater\" \"lunar\" \"meteor\""}},
        {title: 1, score: {$meta: "textScore"}}
    ).limit(10)

    // 在上一条命令上，进行排序
    db.articles.find({"$text": {"$search": "\"impact crater\" \"lunar\" \"meteor\""}},
        {title: 1, score: {$meta: "textScore"}}
    ).sort({score: {meta: "textScore"}}).limit(10)
    ```

- 优化全文本搜索：分区全文本索引
    - 使某些查询条件将搜索结果的范围变窄。
        ```mongodb
        // 创建一个这些查询条件前缀与全文本字段组成的复合索引
        // 这就是分区全文本索引。因为使用date字段将索引分散成多颗比较小的树。对日期范围内进行全文本会快很多
        db.blog.createIndex({"date": 1, "post": "text"})

        // 后缀实现覆盖查询
        db.blog.createIndex({"post": "text", "author": 1})

        // 前缀和后缀一起使用
        db.blog.createIndex({"date": 1, "post": "text", "author": 1})
        ```

- 其他语言搜索（默认值为：english）

    - 不同语言的词干提取机制不一样。mongodb查找索引字段时，会对每个单词进行词干提取，将其减小为一个基本单元

    ```mongodb
    // 创建法语索引
    db.users.createIndex({"name": "text"}, {"default_language": "french"})
    // 插入时使用language字段描述文档语言
    db.users.insert({"name": "swedishChef", language: "french"})
    ```

### 固定集合

- 固定集合（类似于环形队列）：按插入顺序存储。空间不足时，最旧的文档会被删除，新文档取而代之

    - 需要提前创建好，再插入数据
    - 固定集合一旦创建好，无法改变。只能删除重建

- 固定集合对比普通集合：
    - 固定集合的大小：固定；普通集合的大小：自动增长。
    - 固定集合的访问模式：数据被顺序写入磁盘。因此写入速度非常快；普通集合不是。

- 固定集合不允许某些操作

    - 无法对文档进行删除（除了插入自动淘汰最旧文档机制）
    - 不能被分片

- 固定集合用于记录日志，不够灵活。除了创建集合指定大小，无法控制数据何时过期

    - 使用`TTL`索引：基于日期字段的值和索引的TTL值进行过期删除
        - 在WiredTiger存储引擎中性能更好

- 创建固定集合

    ```mongodb
    // 创建一个名为my_collection,大小为100000字节的固定集合
    db.createCollection("my_collection", {"capped": true, "size": 100000})

    // 固定文档数量。可以保存10条最新的新闻，现在每个用户1000个文档
    db.createCollection("my_collection1", {"capped": true, "size": 100000, "max": 100})
    ```

- 将普通集合转换为固定集合

    ```mongodb
    // 将test集合转换为大小为10000字节的固定集合
    db.runCommand({"convertToCapped": "test", "size": 10000})
    ```

#### 可追加游标（tailable cursor）

- 类似于`tail -f`命令：游标在取光结果集后不会关闭，有新文档插入后，游标可以获取新结果

    - 10分钟后没有新文档插入，`可追加游标`会被关闭

- 由于普通集合不维护插入顺序，`可追加游标`只能在固定集合使用

    - 普通集合可以使用变更流（change stream）代替可追加游标

- `可追加游标`不使用索引，而是按自然顺序返回文档。
    - 因此初始扫描是昂贵的，但获取随后追加的文档是廉价的

- mongoshell 不允许使用`可追加游标`

- python使用`可追加游标`：[PyMongo官方文档的例子](https://pymongo.readthedocs.io/en/stable/examples/tailable.html#)

### TTL索引

- `TTL`索引：为每个文档设置一个超时时间，超时就会被删除

- 一个集合可以有多个`TTL`索引。

- `TTL`索引不能是复合索引。但可以像普通索引那样优化排序和查询

- 创建`TTL`索引

    - `expireAfterSeconds`选项：创建TTL索引
    - mongodb每分钟扫描TTL索引，因此不能依赖秒级粒度。可以使用`collMod`命令：修改`expireAfterSeconds`的值

    ```mongodb
    // 超时时间为24小时
    // 如果lastUpdated为日期类型时，lastUpdated时间晚expireAfterSeconds秒时，就会被删除
    // 为了会话防止被删除，可以周期更新lastUpdated为当前时间
    db.sessions.createIndex({"lastUpdated": 1}, {"expireAfterSeconds": 60 * 60 * 24})

    // collMod命令
    db.sessions.createIndex({"collMod": "someapp.cache", "index": {"keyPattern": {"lastUpdated": 1}, "expireAfterSeconds": 3600})
    ```

## 聚合框架

- 类似于shell中的管道`|`，每个阶段接受特定形式的文档并产生特定的输出

- 顺序很重要：要确保一个阶段传递到下一个阶段的文档数量

- 聚合框架能够使用索引

- 一共5个阶段：

    - `$match`：匹配阶段

        ```mongodb
        // 过滤2004年成立的公司
        db.companies.aggregate([
            {$match: {founded_year: 2004}}
        ])
        // 相当于find()
        db.companies.find({founded_year: 2004})
        ```

    - `$project`：投射阶段

        ```mongodb
        // 排除_id字段，只显示name、founded_year字段
        db.companies.aggregate([
            {$match: {founded_year: 2004}},
            {$project: {
                _id: 0,
                name: 1,
                founded_year: 1
            }}
        ])
        ```

    - `$limit`：限制阶段

      ```mongodb
        // 匹配之后，限制结果集为5，再进行投射
        db.companies.aggregate([
            {$match: {founded_year: 2004}},
            {$limit: 5},
            {$project: {
                _id: 0,
                name: 1,
                founded_year: 1
            }}
        ])
        // 效果等同于上。但低效，在投射阶段传递上百个文档，最后再将结果集限制为5
        db.companies.aggregate([
            {$match: {founded_year: 2004}},
            {$project: {
                _id: 0,
                name: 1,
                founded_year: 1
            }},
            {$limit: 5}
        ])
        ```

    - `$sort`：排序阶段

      ```mongodb
        // 按name升序（从小到大）
        db.companies.aggregate([
            {$match: {founded_year: 2004}},
            {$sort: {name: 1}},
            {$limit: 5},
            {$project: {
                _id: 0,
                name: 1,
                founded_year: 1
            }}
        ])
        ```

    - `$skip`：跳过阶段

      ```mongodb
        // 先排序，再跳过
        db.companies.aggregate([
            {$match: {founded_year: 2004}},
            {$sort: {name: 1}},
            {$skip: 10},
            {$limit: 5},
            {$project: {
                _id: 0,
                name: 1,
                founded_year: 1
            }}
        ])
        ```

- 测试文档

    ```mongodb
    // 插入测试文档
    db.users.insertOne({
        "name": "joe",
        "age": 10,
        "year": 2023,
        "phone": [
            12345678,
            87654321,
        ],
        "email": {
            "qq": "123@qq.com",
            "gmail": "123@gmail.com",
        },
        "investments": [
            {
                "company": "google",
                "ceo": null,
                "amount": 10000,
                "url": {
                    "com": "www.google.com",
                    "game": "www.google.game"
                },
            },
            {
                "company": "facebook",
                "ceo": null,
                "amount": 20000,
                "url": {
                    "com": "www.facebook.com",
                    "game": "www.facebook.game",
                },
            },
        ]
    })
    ```

- 内嵌文档

    - `$project`投射内嵌文档
        ```mongodb
        // $project内嵌文档。com为自定义字段：返回的内嵌文档字段按.定位，最后返回的是数组类型
        db.users.aggregate([
            {$match: {"investments.url.com": "www.facebook.com"}},
            {$project: {
                _id: 0,
                name: 1,
                com: "$investments.url.com",
            }}
        ])
        // 输出
        [ { name: 'joe', com: [ 'www.google.com', 'www.facebook.com' ] } ]
        ```

    - `$unwind`：展开阶段。指定数组字段，每个元素都形成输出文档。如果数组有10个元素就生成10个文档

        ```
        {
            k1: "v1",
            k2: "v2",
            k3: ['elem1', 'elem2', 'elem3'],
        }

                {$unwind: "$k3"}展开阶段后

        {
            k1: "v1",
            k2: "v2",
            k3: "elem1"
        }

        {
            k1: "v1",
            k2: "v2",
            k3: "elem2"
        }

        {
            k1: "v1",
            k2: "v2",
            k3: "elem3"
        }
        ```

        ```mongodb
        // 投射之前包含一个展开阶段
        db.users.aggregate([
            {$match: {"investments.url.com": "www.facebook.com"}},
            {$unwind: "$investments"},
            {$project: {
                _id: 0,
                year: 1,
                amount: "$investments.amount",
            }}
        ])
        // 输出
        [ { year: 2023, amount: 10000 }, { year: 2023, amount: 20000 } ]

        // 先展开，后匹配。这样可以使用索引。有2个匹配阶段
        db.users.aggregate([
            {$match: {"investments.url.com": "www.facebook.com"}},
            {$unwind: "$investments"},
            {$match: {"investments.url.com": "www.facebook.com"}},
            {$project: {
                _id: 0,
                year: 1,
                amount: "$investments.amount",
            }}
        ])
        // 输出
        [ { year: 2023, amount: 20000 } ]
        ```

- 数组表达式
    - `$rounds`：过滤器表达式
    - `$filter`：处理数组字段
        - 第1个字段`input`：指定一个数组
        - 第2个字段：别名
        - 第3个字段：过滤条件

        ```mongodb
        db.users.aggregate([
            {$match: {"investments.url.com": "www.facebook.com"}},
            {$project: {
                _id: 0,
                name: 1,
                alias_name: { $filter: {
                    input: "$investments",
                    as: "inve",
                    cond: {$gte: ["$$inve.amount", 20000]} // 这里$$别名
                }}
            }},
        ])
        // 输出
        [
          {
            name: 'joe',
            alias_name: [
              {
                company: 'facebook',
                ceo: null,
                amount: 20000,
                url: { com: 'www.facebook.com', game: 'www.facebook.game' }
              }
            ]
          }
        ]
        ```

    - `$arrayElemAt`：
        - 第1个元素为：字段路径
        - 第2个元素为：数组的位置（位置从0开始）

        ```mongodb
        // 先输出最后一个元素，再输出第一个元素
        db.users.aggregate([
            {$match: {"investments.url.com": "www.facebook.com"}},
            {$project: {
                _id: 0,
                name: 1,
                last_element: {$arrayElemAt: ["$investments.company", -1]},
                first_element: {$arrayElemAt: ["$investments.company", 0]},
            }},
        ])
        // 输出
        [ { name: 'joe', last_element: 'facebook', first_element: 'google' } ]
        ```

    - `$slice`：从特点元素索引开始，按顺序返回多少个元素

        ```mongodb
        // 从元素0开始，获取1个元素
        db.users.aggregate([
            {$match: {"investments.url.com": "www.facebook.com"}},
            {$project: {
                _id: 0,
                name: 1,
                alias_name: {$slice: ["$investments.company", 0, 1]},
            }},
        ])
        // 输出
        [ { name: 'joe', alias_name: [ 'google' ] } ]
        ```

    - `$size`：统计数组元素个数

        ```mongodb
        // 统计investments数组的个数
        db.users.aggregate([
            {$match: {"investments.url.com": "www.facebook.com"}},
            {$project: {
                _id: 0,
                name: 1,
                total_investments: {$size: "$investments"},
            }},
        ])
        // 输出
        [ { name: 'joe', total_investments: 2 } ]
        ```

- 累加器
    - `$max`：最大值
    - `$min`：最小值

        ```mongodb
        // amount的最大值和最小值
        db.users.aggregate([
            {$match: {"investments.url.com": "www.facebook.com"}},
            {$project: {
                _id: 0,
                name: 1,
                max_investment: {$max: "$investments.amount"},
                min_investment: {$min: "$investments.amount"},
            }},
        ])
        // 输出
        [ { name: 'joe', max_investment: 20000, min_investment: 10000 } ]
        ```

    - `$sum`：总数
    - `$avg`：平均值

        ```mongodb
        // amount的总数和平均值
        db.users.aggregate([
            {$match: {"investments.url.com": "www.facebook.com"}},
            {$project: {
                _id: 0,
                name: 1,
                sum_investments: {$sum: "$investments.amount"},
                avg_investments: {$avg: "$investments.amount"},
            }},
        ])
        // 输出
        [ { name: 'joe', sum_investments: 30000, avg_investments: 15000 } ]
        ```

    - `$first`：第一个元素值
    - `$last`：最后一个元素值

        ```mongodb
        db.users.aggregate([
            {$match: {"investments.url.com": "www.facebook.com"}},
            {$project: {
                _id: 0,
                name: 1,
                first_amount: {$first: "$investments.amount"},
                last_amount: {$last: "$investments.amount"},
            }},
        ])
        ```
    - `$group`：分组。类似于sql中的`GROUP BY`
        ```mongodb
        db.users.aggregate([
            {$match: {"investments.url.com": "www.facebook.com"}},
            {$group: {
                _id: {year: "$year"},
                url_com: {$push: "$investments.url.com"},
            }},
        ])
        // 输出
        [
          {
            _id: { year: 2023 },
            url_com: [ [ 'www.google.com', 'www.facebook.com' ] ]
          }
        ]

        db.users.aggregate([
            {$match: {"investments.url.com": "www.facebook.com"}},
            {$group: {
                _id: {year: "$year"},
                url: {$push: {"com": "$investments.url.com", "game": "$investments.url.game"}},
            }},
        ])
        // 输出
        [
          {
            _id: { year: 2023 },
            url: [
              {
                com: [ 'www.google.com', 'www.facebook.com' ],
                game: [ 'www.google.game', 'www.facebook.game' ]
              }
            ]
          }
        ]
        ```

- `$merge`和`$out`：写入新的集合，必须是最后一个阶段，如果集合存在会覆盖。
    - `$merge`和`$out`不能一起使用。
    - `$merge`是mongodb4.2引入，可以写入任何数据库（包含分片），是写入数据库的首选。`$out`只能写入相同的数据库，不能写入分片。
    - `$merge`：可以对结果进行合并（插入新文档，与现有文档合并）。可以创建物化视图（materialized view）

    ```mongodb
    // 将结果集写入到db.users1数据库
    db.users.aggregate([
        {$match: {"investments.url.com": "www.facebook.com"}},
        {$project: {
            _id: 0,
            name: 1,
            com: "$investments.url.com",
        }},
        {$merge: "users1"}
    ])
    ```

## 事务

- 一篇2019年的SIGMOD会议论文[《Implementation of Cluster-wide Logical Clock and Causal Consistency in MongoDB》](https://dl.acm.org/doi/10.1145/3299869.3314049)。讲述逻辑会话和因果一致性背后的机制提供了深层次的技术解释

- 使用事务必须是mongodb4.2及以上的版本

- 事务支持跨副本集、分片

- mongodb有2种事务api

    - 核心api：`start_transaction`和`commit_transaction`
        - 与关系型数据库类似
        - 不提供错误重试

    - 回调api：推荐的方法
        - 提供一个单独的函数，封装了大量功能
            - 启动与指定会话关联的事务
            - 执行作为回调函数提供的函数（出现错误时终止）
            - 处理错误的重试逻辑

    | 核心api                        | 回调api                                                                         |
    |--------------------------------|---------------------------------------------------------------------------------|
    | 需要显示调用来，启动和提交事务 | 启动事务、执行指定操作，提交（发生错误终止）                                    |
    | 不包含错误处理逻辑             | 自动为TransientTransactionError和UnknownTransactionCommitResult提供错误处理逻辑 |

- 事务的限制：
    - 时间限制：
        - 默认最大运行时间1分钟。
        - 显示设置`maxTimeMS`参数。如果没有设置则使用`transaction-LifetimeLimitSeconds`；如果设置了，但大于`transaction-LifetimeLimitSeconds`，则以后者为准
        - 修改mongod实例级别的`transaction-LifetimeLimitSeconds`
        - 分片集群：必须在所有分片副本集上设置`transaction-LifetimeLimitSeconds`。
            - 超时后，事务视为过期，并由定期运行清理进程终止。
                - 清理进程每60秒或`transaction-LifetimeLimitSeconds`/2运行一次，以较小的值为准

        - 事务锁：获取操作所需锁的默认最大时间为5毫秒。超过后，事务会被终止
            - 可以通过修改`maxTransaction-LockRequestTimeoutMillis`参数

                | 值          | 说明                           |
                |-------------|--------------------------------|
                | 0           | 无法立即获取锁时，事务立即终止 |
                | -1          | 将`maxTimeMS`参数作为超时时间  |
                | 大于0的数字 | 指定超时时间（单位：秒）       |

    - `oplog`条目大小限制：每条`oplog`条目必须小于16MB的BSON

## 应用程序的设计模式

### 不适合使用mongodb的场景

- 关系数据库擅长在许多不同的维度，连接不同类型的数据。mongodb不会在这么做
- 选择关系数据库，往往是工具还不支持mongodb：如SQLAlchemy、WordPress
### 设计模式

- 设计模式时需要考虑的：

    - 与关系数据库不同的是，在为模式建模之前，需要了解查询和数据访问的方式

    - 查询和写入的访问模式
        - 需要量化应用程序和最大系统的工作负载（读写操作）
        - 一旦知道了查询的运行时间和频率，就可以识别最常见的识别。
            - 这些查询需要在模式设计时支持。
            - 一旦确定了这些查询，就应该减少查询的数量，并在设计中确保一起查询的数据存储在同一个文档
            - 这些查询未使用的数据，应该存放在不同的集合中。不经常使用的数据，也应该移动到不同的集合中
            - 需要考虑动态（读/写）数据和静态（主要是读）数据分离开
            - 提高最常见的查询优先级会获得最佳的性能

    - 关系类型

        - 要考虑文档之间的关系，哪些数据是相关的。从而确定是嵌入，还是引入
        - 最好是引用文档，而不是执行其他查询
        - 要考虑关系发生变化时，需要更新多少文档
        - 要考虑数据结构是否易于查询。如使用内嵌数组（数组中的数组）对某些关系进行建模

    - 基数

        - 确定文档与数据的关联方式后，要考虑这些关系的基数。比如一对一、一对多、多对多、一对百万、多对几十亿

        - 考虑相关字段的更新与读取比例

        - 考虑这些问题有助于确定采用内嵌文档还是引用文档，是否应该跨文档对数据进行反范式化处理

- 设计模式：

    - [m320 Data Modeling in MongoDB（mongodb大学提供一个设计模式的4分钟视频）](https://www.youtube.com/embed/hNdMXM5XbQw?rel=0&autoplay=1)

    - 多态模式：
        - 数据结构类似，但不相同
        - 涉及跨文档的公共字段

    - 属性模式：
        - 部分字段会进行排序；或需要排序的字段近存在部分文档中；或者这2个条件都满足
        - 它包含将数据重塑为键-值对数组，并在该数组中的元素上创建索引
        - 此模式有助于查询那些存在许多相似字段的文档，因此需要索引更少，查询也更容易编写。

    - 分桶模式：
        - 时间序列数据
        - mongodb将这些数据分桶存储到一组文档中，例如使用1小时存储桶，将该时间内所有数据都放到文档的一个数组中。文档有开始和结束时间，表示这个桶涵盖的时间段

    - 异常值模式
        - 解决少数文档的查询超出应用程序正常模式的情况。
        - 用一个标志表示文档的异常值，将额外的溢出存储到一个或多个文档中，这些文档通过`_id`引用第一个文档
        - 应用场景：社交网络、图书销售、电影评论

    - 计算模式
        - 频繁计算数据时使用；读取密集型数据访问模式下使用
        - 此模式建议在后台执行计算，并定期更新主文档

    - 子集模式
        - 适用于：
            - 经常使用的数据和不经常使用的数据分割为2个单独的集合
                - 例子：电子商务评论将一个产品10条最近的评论，保存在主（经常访问的）；其他旧的评论，移动到第二个的集合，应用程序只有在需要多于10条评论时才查询
            - 超过机器ram时可以使用这模式

                - 这种情况可能是大文档造成的

    - 扩展引用模式：
        - 每个系统都有自己的集合，并且你希望将这些系统组织在一起实现特定功能
        - 这种模式以数据冗余为代价，减少将信息整合在一起所需要的查询数量
        - 例子：电子商务有订单、客户、库存可能会有单独集合。当将这些单独的集合，收集到单个订单的所有信息时，可能会对性能产生负面影响

    - 近似值模式：
        - 需要昂贵资源（时间、内存、cpu周期）计算，却不需要绝对精确的情况下非常有用
        - 例子：一张图片或一条帖子的点赞计数器、一个页面浏览的计数器，其中知道确切的计数是不必要的（如999535还是100000）
        - 此模式可以极大减少写入次数。
            - 例子每浏览100次或更多次时更新计数器，而不是每次浏览后都进行更新

    - 树形模式：
        - 有很多查询，并且数据主要是层级结构时
        - 结构存储在同一个文档的数组中
        - 例子：电子商务的产品目录中，通常有多个类别的产品，或者这个产品的类别从属于其他某个类别。如硬盘，本身是个类别又属于存储类别，存储又属于计算机部件类别。需要一个字段跟踪整个层次结构，另一个字段保存直接类别（硬盘）。
            - 保存层级结构的字段：提供对这些值使用多键索引的能力。这可以确保很容易地层次结构相关的所有项目。
            - 直接类别字段：允许找到此类别直接相关的所有项目

    - 预分配模式：
        - 创建一个初始的空结构，稍后对进行填充。
            - 主要用于MMAP存储引擎，但仍然有一些可以使用此模式的场景
            - 例子：一个按天管理资源的预定系统，可以跟踪该资源是空闲/预定。资源（x）和天数（y）二维结构可以使得检查可用，以及执行计算变得简单

    - 文档版本控制模式：
        - 添加一个额外的字段（例如`v`或`version`）跟踪文档版本；还需另一个集合保存文档的所有修订版本
        - 例子：某个版本需要`mobile`字段；另一个版本则不需要；还有一个版本的`mobile`字段只是可选字段。

        - 问题：随着数据库的增长，文档结构也会变化。
            - 解决方法1：如果可以应该考虑文档版本控制模式
            - 解方方法2：通过事务确保每一个文档都修改成功

### 范式化和反范式化

- 范式化（normalization）：指将数据分散到多个集合中，在集合之间进行引用
    - 优点：更新数据，只需更新一份文档。写入速度快

- 反范式化（denormalization）：将所有数据嵌入单个文档中。多个文档可能拥有数据副本，而不是所有文档都引用同一份数据
    - 优点：读取速度快
    - 缺点：更新数据，需更新多份文档。但可以通过单词查询获取所有相关数据

- 基数：一个集合对另一个集合的引用数。有一对一、一对多、多对多的关系
    - 例子：博客应用程序。
        - 每篇文章都有一个标题：因此是一对一关系。
        - 每个作者有很多文章：因此是一对多关系。
        - 每篇文章有很多评论：因此是一对多关系。
        - 每篇文章有很多标签，每个标签又可以在多篇文章中使用：因此是多对多关系。

    - “多”可以划分2个子类别：很多和很少
        - “少”：使用内嵌比较好
        - “多”：使用引用比较好
        - 例子：
            - 作者与文章之间的一对少：每个作者只写了几篇文章。
            - 文章与标签之间可能存在多对少：文章数量比标签多

- 选择哪一个非常困难。要根据实际需要权衡：

    - 如果写操作比读操作更重要，但每执行一次写，就要进行1000次读，那还是应该先优化读取速度

    - 选择范式化：
        - 如果定期更新
        - 如果生成的信息越多，就越不应该将这些信息内嵌到其他文档；而应该使用引用。又或者使用子集模式
            - 例子：评论树、活动列表

    - 选择反范式化：
        - 如果数据变化不频繁
            - 例子：可以将用户和用户的地址保存到不同集合。因为地址很少变化，应该嵌入进用户文档

    | 适合引用（范式化）     | 适合内嵌（反范式化）     |
    |------------------------|--------------------------|
    | 较大子文档             | 较小子文档               |
    | 数据经常变更           | 数据不经常变更           |
    | 数据必须强一致性       | 数据最终一致性即可       |
    | 文档数据大幅增加       | 文档数据小幅增加         |
    | 数据通常不包含在结果中 | 数据需要二次查询才能获得 |
    | 快速写入               | 快速读取                 |

    - 判断以下users集合的字段，是否内嵌到用户文档中？
        - 用户首选项：内嵌。用户首选项只与用户文档相关，而且可能与文档中的其他字段被一起查询
        - 最近活动：取决于活动的增长和变化的频繁程度。——如果是固定长度的字段（如最近10次活动）应该使用内嵌或使用子集模式。
        - 好友：不应该内嵌或者不应该完全内嵌
        - 用户生成的内容：引用

- 如果使用内嵌文档并且需要更新时，应该设置一个定时（cron）任务，以确保所做的更新都能成功更新到所有文档。
    - 问题：进行多次更新时，如果服务器崩溃了，就需要一种方法检测，并能继续执行未完成的更新
    - 解决方法：
        - 更新运算符中：`$set`是幂等，`$inc`则不是。
        - 网络故障下
            - 幂等的操作可以重复执行
            - 非幂等操作应该分解为2个幂等操作后，再重复执行。因为每个单独的`updateOne`操作都是幂等
                - 操作1：添加一个待处理令牌
                - 操作2：同时唯一键和一个待处理令牌来实现


- 例子：保存学生和他们上课程的信息

    - 解决方法：范式化
        - 一个students集合（每个学生一个文档）
        - 一个classes集合（每门课程是一个文档）
        - 第三个集合studentClasses存储学生及其所学课程的引用
        ```mongodb
        use school
        db.students.insert({"_id": ObjectId(1), "name": "joe", "age": "26"})
        db.classes.insert([
            {"_id": ObjectId(100), "class": "english", "room": 100},
            {"_id": ObjectId(101), "class": "computer", "room": 101},
        ])

        // 通过_id引用
        db.studentClasses.insert({
            "studnetId": ObjectId(1),
            "classes": [
                ObjectId(100),
                ObjectId(101),
            ]
        })
        ```

        - 问题：假设要找到一个学生上的课：需要查询students集合的学生信息，studentClasses的课程_id，再查找classes集合的课程信息。总共3次查询，这不是理想的mongodb数据设计，除非课程和学生信息会经常变化，并且不需要对数据进行快速读取。

    - 解决方法：可以把studentClasses集合的两次嵌入，减少为1次

        ```mongodb
        // 只嵌入classes的文档，减少1次查询，最后总共需要2次查询
        db.studentClasses.insert({
            "name": "joe",
            "classes": [
                ObjectId(100),
                ObjectId(101),
            ]
        })
        ```

    - 解决方法：完全反范式化，只需1次查询
        - 优点：只需1次查询
        - 缺点：需要占用更多空间，多次更新

        ```mongodb
        // 完全反范式化。
        db.studentClasses.insert({
            "name": "joe",
            "classes": [
                {"class": "english", "room": 100},
                {"class": "computer", "room": 101},
            ]
        })
        ```

    - 解决方法：混合使用内嵌和引用
        ```mongodb
        db.studentClasses.insert({
            "name": "joe",
            "classes": [
                {"_id":ObjectId(100), "class": "english"},
                {"_id":ObjectId(101), "class": "computer"},
            ]
        })
        ```

- 例子：社交应用程序。有好友、粉丝等
    - 关注、好友、收藏可以简化为一个发布-订阅系统
    - 订阅实现的3种方法：
        - 1.生产者内嵌到订阅者文档
            ```mongodb
            {
                "_id": ObjectId(1),
                "name": "joe",
                "following": [
                    ObjectId(100),
                    ObjectId(101),
                ]
            })

            // 对于一个给定的用户文档，查询他们可能感兴趣的所有已发布活动??代码不全面没有看到
            db.activities.find({"user": {"$in": user["following"]}})
            // 如果需要查找对新发布获得感兴趣所有用户，则必须查询所有用户的following
            ```

        - 2.将订阅者内嵌到生产者文档
            - 优点：每当生产者发信息，立即可以给订阅者发通知
            - 缺点：如果要查找一个用户的所有粉丝，需要查询整个users集合（与上一个方法的限制相反）
                - 查询的所有粉丝的操作可能并不频繁
            ```mongodb
            {
                "_id": ObjectId(100),
                "name": "joe",
                "follower": [
                    ObjectId(1),
                    ObjectId(2),
                ]
            })
            ```

        - 以上2种解决方法都有一个缺点：用户文档会变得很大。following和follower字段甚至可以不用返回。
        - 3.对follower进行范式化。将订阅信息保存到单独的集合避免以上缺点
            ```mongodb
            {
                "_id": ObjectId(100), // 生产者（被关注者）的_id
                "follower": [
                    ObjectId(1),
                    ObjectId(2),
                ]
            })
            ```

            - 问题：内嵌的字段文档只适合有限数量的引用。
                - 例子：如果某个用户很有名，导致粉丝列表的文档溢出

            - 解决方法：使用异常值模式。必要时创建一个延续文档，然后从添加tbc（to be continued）数组字段，执行相应的逻辑

                ```mongodb
                {
                    "_id": ObjectId(100), // 生产者（被关注者）的_id
                    "name": "joe",
                    "tbc": [
                        ObjectId(1000),
                        ObjectId(1001),
                    ],
                    "follower": [
                        ObjectId(1),
                        ObjectId(2),
                    ]
                })

                ```

### 如何删除旧数据

- 有些数据短时间内比较重要：几周或几个月后。3种解决方法：

    - 1.固定集合：最简单的方式。
        - 缺点：容易受到流量峰值，从而暂时降低它们所能容纳的时间长度

    - 2.TTL集合：可以精确的控制删除文档的时间
        - 缺点：写入量过大的集合中操作速度不够快，需要遍历TTL索引来删除文档。
            - 如果TTL集合可以承受足够的写入，那这就是最容易实现的方法

    - 3.多个集合：
        - 每个月的文档单独使用一个集合。
        - 月份变更时，就创建本月的空集合
        - 查询时，搜索本月和以前的月份。一旦集合超过特定时间，比如6个月，才删除

        - 优点：可以满足任何流量
        - 缺点：实现复杂。必须使用动态集合或数据库名称，需要查询多个数据库

### 数据库和集合的设计

- 类似模式的文档应该保存在同一个集合

    - 如果文档位于不同集合或数据库中，可以是聚合查询的`$merge`阶段

- 重要性划分：价值最高的集合，可能数据量最小（用户集合没有日志集合数据量多）
    - 用户集合使用在ssd或者RAID10，对日志和活动集合使用RAID0

### 连接问题

- 服务器会为每个连接维护一个队列：客户端的请求会添加到队列的末端，并且始终可以读取到自己的写操作

- 如果打开2个mongosh，连接相同的数据库，就会有2个队列。
    - 问题：一个mongosh执行插入操作，另一个mongosh查询可能不会返回插入的文档
    - 这个问题难以手动复现。但在繁忙的服务器上，可能会出现交错插入和查询的操作。

- ruby、python、java这些驱动程序使用了连接池。

    - 连接池会建立多个与服务端的连接

    - 问题：一个线程插入，另一个线程检查数据是否插入成功时，可能出现好像没有插入成功，然后又突然出现了

## 副本集（replica set）

- 副本集：只能有一个主节点（primary），多个保存主节点数据副本的从节点（secondary）

- 在生产环境中
    - 1.每个节点应该对应一个服务器，实现单个服务器故障，可以隔离
    - 2.应该使用DNS种子列表连接（seedlist connection）格式，指定应用如何连接副本集。
        - 优点：可以轮流更改托管mongodb副本集成员的服务器，无须重新配置客户端（尤其是它们连接的字符串）

- 所有mongodb驱动程序都遵守服务器发现和监控（SDAM）规范。驱动程序会持续监视副本集的拓扑结构，以检测应用程序对成员的访问是否有变化。并且维护哪个成员是主节点的信息

- 读偏好（read preference)：

    - `primary`（默认值）：始终发送给主节点，没有主节点就报错
    - `primaryPreferred`：当主节点停止运行时，副本集会进入一个临时的只读模式
    - `nearest`：在延迟最低的从节点上读取。适合低延迟需求大于一致性需求的场景
        - 基于驱动程序对副本集成员的平均ping，将路由请求到延迟最低的成员
        - 如果应用程序需要低延迟读和低延迟写，由于副本集只允许主节点写，因此需要分片

    - `secondary`：如果可以接受旧数据。总是发送给从节点；如果没有从节点就报错，不会发送给主节点
    - `secondaryPreferred`：如果可以接受旧数据。总是发送给从节点；没有从节点，就发送给主节点

### 启动副本集

- 实验：在单机服务器上，建立一个3节点的副本集

- 1.为每个节点单独创建数据目录
    ```sh
    mkdir -p ~/mongodb/rs{1,2,3}
    ```

- 2.启动mongod
    ```sh
    # 启动3个mongod
    mongod --replSet mdDefGuide --dbpath ~/mongodb/rs1 --port 27017 --oplogSize 200 &
    mongod --replSet mdDefGuide --dbpath ~/mongodb/rs2 --port 27018 --oplogSize 200 &
    mongod --replSet mdDefGuide --dbpath ~/mongodb/rs3 --port 27019 --oplogSize 200 &

    # 默认情况下绑定到localhost(127.0.0.1)。--bind_ip参数可以指定ip，也可以在配置文件使用bind_ip
    # 在192.51.100.1服务器上运行mongod
    # 在绑定到非localhost的ip。应该启用授权控制，并指定身份验证机制
    mongod --bind_ip localhost,192.51.100.1 --replSet mdDefGuide --dbpath ~/mongodb/rs1 --port 27017 --oplogSize 200 &
    ```

- 3.初始化副本集

    - 每个mongod都不知道其他mongod的存在。因此需要创建一个包含每个成员的配置，并发送给其中一个mongod进程，由它负责将配置传递给其他成员。

    ```sh
    # 连接其中一个mongod
    mongosh --port 27017

    // 创建配置文档
    rsconf = {
        _id: "mdDefGuide",
        members: [
            {_id:0, host: "localhost:27017"},
            {_id:1, host: "localhost:27018"},
            {_id:2, host: "localhost:27019"}
        ]
    }

    // 传递rsconf实现初始化。提示符变成mdDefGuide [direct: primary] test>
    // 应该总是使用rs.initiate()初始化，否则mongodb会尝试自动生成一个单成员的副本集配置。
    rs.initiate(rsconf)

    // 查看副本集状态。members数组有3个成员
    rs.status()
    ```

- 4.自动故障转移

    - 关闭27017主节点

        ```mongodb
        db.adminCommand({"shutdown": 1})

        // 查看副本集状态。比rs.status()函数更简洁
        db.isMaster()
        primary: 'localhost:27018',
        me: 'localhost:27018',
        ```

    - 恢复27017

        ```sh
        # 重新启动27017
        mongod --replSet mdDefGuide --dbpath ~/mongodb/rs1 --port 27017 --oplogSize 200 &
        # 连接27017
        mongosh --port 27017

        // 查看副本集状态。27017已经变成从节点了
        db.isMaster()
        secondary: true,
        primary: 'localhost:27018',
        me: 'localhost:27017',
        ```

- 5.开启从节点读取（默认情况下，拒绝从节点读取）：

    - 开启从节点读取的问题：

        - 从节点可能落后于主节点的时间通常在几毫秒之内。但这是无法保证的，由于负载、错误配置、网络等原因，从节点可能延迟几分钟、几小时、甚至几天。

        - 客户端无法知道从节点的数据有多新，因此要读取最新数据，就不该在从节点读取。

        - 客户端发出请求的速度可能快于复制操作的执行速度

        - 除非使用`writeConcern`将写操作复制多个从节点才算成功
            ```mongodb
            // 副本集写操作需要写入majority（大多数成员），如果在100毫秒内没有复制到大多数成员，则返回错误
            db.users.insertOne(
                {"_id": 10, "name": "joe"},
                { writeConcern: {"w": "majority", "wtimeout": 100}}
            );
            ```

        - 结论：从落后的从节点读取数据，就必须牺牲一致性；写操作复制多个成员，就必须牺牲写入速度


    - 在主节点插入测试数据：
        ```monggodb
        use test
        // 插入数据
        for (i=0; i<1000; i++) {db.coll.insertOne({count: i})}
        // 查看文档插入数量
        db.coll.countDocuments()
        ```

    - 2种方法连接从节点：

        - 1.mongosh连接从节点
            ```mongodb
            mongosh --port 27018

            // 读取报错
            db.coll.find()
            MongoServerError: not primary and secondaryOk=false - consider using db.getMongo().setReadPref() or readPreference in the connection string

            // 开启从节点读取。新版setSlaveOk()已经被抛弃，使用setReadPref()代替
            db.getMongo().setReadPref('secondary')

            // 成功读取
            db.coll.find()

            // 关闭从节点读取
            db.getMongo().setReadPref()

            // 写入报错
            db.coll.insertOne({"count": 1001})
            MongoServerError: not primary
            ```

        - 2.在连接了主节点的mongosh上，连接从节点
            ```mongodb
            // 使用构造函数实例化connection对象
            secondaryConn = new Mongo("localhost:27018")
            secondaryDB = secondaryConn.getDB("test")

            // 读取报错
            secondaryDB.coll.find()
            MongoServerError: not primary and secondaryOk=false - consider using db.getMongo().setReadPref() or readPreference in the connection string

            // 开启从节点读取。新版setSlaveOk()已经被抛弃，使用setReadPref()代替
            secondaryConn.setReadPref('secondary')

            // 成功读取
            secondaryDB.coll.find()

            // 关闭从节点读取
            secondaryConn.setReadPref()

            // 写入报错
            secondaryDB.coll.insertOne({"count": 1001})
            MongoServerError: not primary
            ```

### 更改副本集配置：优先级、隐藏成员、索引复制、仲裁者

- `rs`辅助函数，大部分是数据库命令的封装。
    - 最好同时熟悉这两个，因为使用命令形式代替辅助函数可能会更简单
    ```mongodb
    // 两者等效
    rs.initiate(config)
    db.adminCommand({"replSetInitiate": config})
    ```

- 基本命令
    ```mongodb
    // 查看副本集配置。每次修改时version字段会增加
    rs.config()
    // 等同于上。配置实际上保存在local数据库的db.system.replset中
    use local
    db.system.replset.find()

    // 添加成员。第一次添加的成员，对于的目录应该是空的
    rs.add("localhost:27020")
    // 删除成员
    rs.remove("localhost:27017")

    // 把主节点变为从节点（除了修改priority优先级外）可以使用rs.stepDown()
    // 使主节点降级从节点，并维持60秒。如果这段时间内没有其他主节点被选举出来。该节点可以尝试重新选举
    rs.stepDown(60) // 60秒

    // 阻止选举。如果需要对主节点维护，但不想在此期间，有其他成员选举为主节点。可以对每个成员执行rs.freeze()，强制保持从节点
    rs.freeze(60) // 60秒
    // 如果完成主节点维护，释放其他成员。对每个成员执行
    rs.freeze(0)
    ```

- 复杂的配置更改，如一次性添加/删除多个成员。可以使用`rs.reconfig()`重新加载配置
    ```mongodb
    // 修改配置
    var config = rs.config()
    config.members[0].host = "localhost:27017"
    config.members[1].host = "localhost:27018"
    config.members[2].host = "localhost:27019"

    // 重新加载配置
    rs.reconfig(config)
    ```

- 优先级：范围0-100，默认为1

    - 0值：永远不能成为主节点。被称为被动（passive）成员
    - 更高优先级成员总是会被选举为主节点

    ```mongodb
    // 设置优先级为2
    var config = rs.config()
    config.members[0].priority = 2;
    rs.reconfig(config)

    // 查看优先级
    rs.config()

    // 查看27018是否变为主节点
    rs.status()
    ```

- 隐藏成员
    - 客户端不会向隐藏成员发送请求。
    - 隐藏成员不会优先作为副本集的数据源
        - 当其他复制源不可用时，隐藏成员也会被使用
    - 隐藏成员适合性能较弱的服务器、备份服务器

    ```mongodb
    // 当前主节点不能设置为hidden
    cfg = rs.conf()
    cfg.members[1].priority = 0
    cfg.members[1].hidden = true
    rs.reconfig(cfg)
    ```

- 索引复制：从节点默认复制主节点相同的索引。`buildIndexes`为`true`

    ```mongodb
    // 关闭从节点复制主节点的索引
    rs.remove("localhost:27018")
    rs.add({"host": "localhost:27018", "buildIndexes": false, "priority": 0})
    ```

- 选举仲裁者

    - 最好使用没有仲裁者的部署

    - 如果成员数量是奇数，就不需要配置仲裁者

        - 假设有3个成员的副本集，需要2个成员才能选举。这时添加一个仲裁者，副本集就有4个成员，需要3个成员才能选举。反而降低的稳定性：现在需要75%可用，而之前只需67%

        - 如果添加仲裁者后的数量为偶数，反而导致平票，而不是避免平票

    - 仲裁者（arbiter）：只是满足“大多数”的条件。不为客户端提供服务，不保存数据
        - 部署应该将仲裁者与其他成员分开
        - 适合场景：许多小型部署不希望保存3份数据副本集，觉得2份就够了
            - 可以运行在性能较差的服务器

        - 成员一旦配置为仲裁者，便无法重新变为非冲裁者

        - 缺点：

            - 假设：副本集有2个数据成员+1个仲裁者。如果其中一个数据成员停止运行并且不恢复，就需要一个新的从节点。

                - 主节点仅剩1份完好数据，不仅要处理应用程序请求，还要复制数据到新的从节点
                    - 通常几个GB的数据复制很简单；但如果是100GB以上就不太现实了，导致很大的服务器压力，从而降低应用程序的速度。


            - 如果是3个数据成员，1台服务器彻底停止运行，副本集还有喘息的空间

        ```mongodb
        // mongodb4.0以后需要执行此命令
        db.adminCommand({
           "setDefaultRWConcern" : 1,
           "defaultWriteConcern" : {
             "w" : 1
           }
         })

        // 将27019加入副本集，并设置为仲裁者
        rs.addArb("localhost:27019")
        // 或者
        rs.add({"host": "localhost:27018", "arbiterOnly": true})
        ```

- 不能直接修改，而是需要`rs.remove()`后，再`rs.add()`的才能修改的配置
    - 成员的`"_id"`字段
    - 仲裁者不能变为非仲裁者，反之亦然
    - 不能将主节点的`priority`优先级设置为0（就算`rs.remove()`在`rs.add()`也不行）
    - 不能修改`buildIndexes`索引复制设置

        - 直接修改索引复制为false的报错例子
            ```mongodb
            cfg = rs.conf()
            cfg.members[2].priority = 0
            cfg.members[2].buildIndexes = false
            rs.reconfig(cfg)
            MongoServerError: New and old configurations differ in the setting of the buildIndexes field for member localhost:27018; to make this change, remove then re-add the member
            ```

### 管理

- 副本集最多只能有50个成员，其中只有7个成员拥有投票权
    - 这是为了减少每个成员的心跳产生的网络流量
    - 超过7个成员的副本集，额外成员必须赋予0投票权
        ```mongodb
        rs.add({"_id": 7, "hosts": "server-7:27017", "votes": 0})
        ```

- 单机模式启动进行维护：维护任务不能在从节点上执行（涉及写操作），也不应该在主节点上执行，因为会对性能造成影响。

    ```mongodb
    // 查看要维护成员的启动命令
    db.serverCmdLineOpts()
    {
      argv: [
        'mongod',
        '--replSet',
        'mdDefGuide',
        '--dbpath',
        '/home/tz/mongodb/rs1',
        '--port',
        '27017',
        '--oplogSize',
        '200'
      ],

    // 关闭主节点服务器。副本集的其他成员，发现连接主节点27017失败后便会选举主节点
    db.shutdownServer()

    # 以单机模式运行。从另一个端口启动该服务器
    mongod --port 30000 --dbpath ~/mongodb &

    // 完成维护后。以命令的原始选项重启，会自动连接副本集成为从节点，并从新的主节点复制维护期间的操作，如果该节点的priority优先级最高，会重新选举为主节点
    mongod --replSet mdDefGuide --dbpath ~/mongodb/rs1 --port 27017 --oplogSize 200 &
    ```

- 强制重新配置命令：`rs.reconfig(config, {"force": true})`

    - 强制重新配置会使`version`字段数字会显著增加，甚至是数万、数十万。这些都是正常的

    - 适合场景：无法发送给主节点的情况下，在从节点强制重新配置副本集。当从节点受到重新配置时，会更新自身，并传递给其他成员

        - 如果一些成员已经改变了主机名，那应该在还保持着旧主机名的成员上进行强制重新配置。

        - 如果所有成员都已经改变了主机名，则应该关闭副本集中的所有成员，然后在单机模式下启动，手动修改`local`数据库的`db.system.replset`文档（也就是`rs.config()`保存的内容），然后重新启动成员

- 从节点上运行`rs.status().syncSourceHost`：可以查看复制源

    - 复制源链：server0是server1的复制源，server1是server2的复制源，server2是server4的复制源

    - mongodb会根据ping的时间决定复制源。维护心跳ping的滑动平均值，查找离它最近，数据比它新的成员作为复制源，因此不会出现循环复制（复制源只能是主节点和比它新的从节点）

    - 问题：每加入一个成员，复制源链可能会变长，导致复制到所有服务器需要更长时间。

        - 解放方法1：手动修改复制源。注意这可能会导致出现循环复制

            ```mongodb
            rs.syncFrom("localhost:27017")
            ```

        - 解放方法2：禁用复制源链，强制每个成员从主节点同步
            ```mongodb
            var config = rs.config()
            // 如果设置子对象不存在，则进行创建
            config.settings = config.settings || {}
            config.settings.chainingAllowed = false
            rs.reconfig(config)
            ```

- 如果所有从节点同时创建索引时：
    - 副本集的大部分成员将处于离线状态，直到索引创建完成
    - 在创建`unique`索引时，必须停止所有写操作，不然副本集成员数据可能会不一致

    - 解决方法：只在一个成员上创建索引，从而最小化影响
        - 1.关闭1个从节点
        - 2.单机模式重新启动
        - 3.在单机服务器上创建索引
        - 4.索引创建完后，以副本集成员的身份重新启动。
            - 如果命令航选项或配置文件有`disableLogicalSessionCacheRefresh`参数，则需要移除

        - 5.对副本集的每个从节点重复步骤1到4

        - 完成后，除了主节点外的成员都成功创建索引。接下来有2个选择，根据场景选择对生产环境影响最小的
            - 1.在主节点创建索引。
                - 如果系统有一段流量较少的空闲期，则是创建索引的好时机。
                - 可能需要修改读偏好，从而在创建索引过程中，负载到从节点
            - 2.将主节点退位从节点，重复2到4的步骤。
                - 这会发生故障转移，在旧主节点创建索引时，有一个正常运行的主节点。

        - 注意：创建唯一索引，要确保主节点没有插入重复数据，或者首先在主节点创建索引。否则会导致从节点复制错误，如果发生这种情况，从节点会自动关闭。必须以单机模式重新启动，删除唯一索引后，在重新启动

- 如果预算有限，不能购买多台高性能服务器

    - 从节点的只用于灾难恢复。这样就不需要更好的ram和cpu和磁盘io。

        | 设置以下选项 | 值    | 说明                                                                                                                            |
        |--------------|-------|---------------------------------------------------------------------------------------------------------------------------------|
        | priority     | 0     | 永远不会成为主节点                                                                                                              |
        | hidden       | true  | 客户端不会向从节点发送读请求                                                                                                    |
        | buildIndexes | false | 可选选项。如果需要在该节点进行恢复，则需要重新创建索引                                                                          |
        | votes        | 0     | 如果只有2台机器：votes:0可以在从节点停止运行后，主节点仍能保持主节点。如果有3台机器：应该在该机器运行仲裁者，而不是设置votes:0 |

    - 主节点始终用高性能服务器

### 如何设计副本集

- 不同的需求，有不同的配置，应该考虑如何在不利条件下满足大多数（majority）

- 大多数（majority）：副本集一半以上成员

    | 副本集成员总数 | 副本集成员大多数 |
    |----------------|------------------|
    | 1              | 1                |
    | 2              | 2                |
    | 3              | 2                |
    | 4              | 3                |
    | 5              | 3                |
    | 6              | 4                |
    | 7              | 4                |

- 选取主节点需要大多数决定

    - 问题：假设有一个5个成员的副本集，3个成员不可用。剩下2个成员不满足大多数，因此无法选举出一个主节点。如果剩下的2个成员其中一个是主节点，几秒后会变成从节点。最后变成2个从节点3个无法访问的副本集
        - 为什么不能让剩下2个成员选举主节点？问题在于：其他3个成员可能没有崩溃，只是网络故障不可达，它们3个满足大多数，会选举出1个主节点。在网络分区情况下，mongodb不希望各自出现1个主节点，因为2个主节点都可以写入数据会造成混乱

- 2种推荐配置：

    - 1.大多数成员放在同一个数据中心：适合有一个主数据中心
        - 优点：主数据中心只要正常运作，就会有一个主节点
        - 缺点：如果主数据中心不可用，备份数据中心的成员，无法选举主节点

    - 2.两个数据中心各自放数量相等的成员，在第三个地方放一个打破僵局的成员：适合两个数据中心一样重要
        - 优点：两个数据中心的任意一个，都可以达到大多数
        - 缺点：需要将服务器分散到3个地方

    - 如果一个副本集允许多个主节点，上面问题就迎刃而解了。但需要处理写入冲突（有人在主节点1上更新一个文档，另一个人在主节点2删除这个文档）
        - 在支持多线程写入的系统中：有2种处理方法
            - 1.手动解决
            - 2.让系统选择一个胜利者
            - 但这2种方法都不容易实现，因为无法保证写入的数据不会被其他节点修改。因此mongodb只支持一个主节点

### 如何选举

- 主节点会一直处于（PRIMARY状态），直到不能满足大多数的要求：停止运行、降级、副本集被重新配置

- 选举过程中主节点会短暂不可用

    - 选举过程大概几毫秒；网络问题或服务器过载响应慢，可能需要更多时间，甚至几分钟。
    - 必要情况下，可以配置驱动程序将读请求路由到从节点

- 副本集成员每个2秒发送1次心跳（ping)。如果10秒内没有反馈，则会被标记为无法访问。
    ```mongodb
    cfg = rs.conf();
    // 设置ping为3秒
    cfg.settings.heartbeatIntervalMillis = 3000;
    // 设置timeout为15秒
    cfg.settings.heartbeatTimeoutSecs = 15;

    rs.reconfig(cfg);
    ```

- 心跳间隔时间内（默认2秒）有成员发现主节点不可用，就会立即开始选举：选举流程

    - 当一个从节点与主节点无法连接时：会通知并请求其他成员，将自己选举为主节点。

    - 其他成员会做几项健全性检查：

        - 1.它们能否连接到主节点，这个主节点是发起选举的节点无法连接的？

        - 2.发起选举的从节点是否有最新数据？
            - 被选举的成员必须拥有最高优先级

        - 3.有没有更高优先级的成员，可以被选举为主节点？
            - 优先级高的会比低的更快发起选举，继而成为主节点；就算低优先级短暂成为主节点，副本集成员会继续发起选举，直到最高优先级的成员为主节点

        - 被选举成员从副本集获得大多数选票后，选举成功成为主节点（PRIMARY状态）
            - 如果没有获得大多数选票，继续处于从节点（SECONDARY状态），以后可能会试图再次成为主节点

- mongodb3.2版本引入第1版复制协议：

    - 基于RAFT共识协议，开发的类RAFT协议

    - 包含一些特定于monogdb副本集的概念：

        - 仲裁节点、优先级、非选举成员、写入关注点（write concern）等
        - 使用term ID防止重复投票

- 问题：
    - 驱动程序操作失败时，不知道主节点在是否在停止运行之前处理该操作？
    - 如果出现网络分区，选举出一个新主节点，是否在新的主节点重新尝试该操作？

    - 假设该操作为递增计数器

        | 错误类型                         | 不重试             | 重试一定次数策略                 |
        |----------------------------------|--------------------|----------------------------------|
        | 短暂的网络错误                   | 可能会发生计数过少 | 计数过多（如果操作是幂等则不会） |
        | 持续的中断（网络或服务器）       | 正确策略           | 浪费资源                         |
        | 服务器拒绝错误命令（比如未授权） | 正确策略           | 浪费资源                         |

    - 结论：利用幂等操作，最多重试一次是最有可能正确处理3种类型的错误
        - mongodb3.6之后，`可重试写`选项：就是最多重试一次策略。
            - 命令错误会返回应用程序，让客户端进行处理。
            - 服务器会为每个写操作维护唯一标识符：从而确定驱动程序什么时候重试一个已经成功的命令。它会简单返回一条消息表示写入成功，从而客服短暂的网络故障，而不会再次进行写入

### oplog日志同步

- 启动mongod时，可以指定oplog大小
    ```sh
    mongod --config ~/mongodb/mongodb.conf --oplogSize 200 &
    ```

- oplog（日志）：包含主节点的每一次写操作。存在于主节点local数据库中的一个固定集合（类似于环形队列）。

    - 从节点通过查询此集合获取需要复制的操作
    - oplog的每个操作都是幂等的：无论是应用1次，还是多次结果都一样
        - 例子：set a 10是幂等的，add a 1则不是幂等

- 每个从节点都维护着自己的oplog（日志），记录主节点复制的每个操作

    - 使得每个成员都可以被用作其他成员的同步源
    - 流程：
        - 1.从节点从同步源获取操作
        - 2.应用到自己的数据集上
        - 3.再写入oplog

    - 从节点重启，会从oplog的最后一个操作开始同步。由于oplog的每个操作是幂等的，所以不存在一致性问题

- oplog使用空间的速度与写入的速度差不多
    - 主节点每分钟写入1KB数据，那么oplog就会以每分钟1KB的速度填满
    - 特殊情况：如果一个操作影响多份文档（删除/更新多个文档），那么会被分解为多条oplog条目。
        - 如果执行大量批量操作，oplog很快被填满
        - 例子：`db.coll.remove()`从集合删除1000个文档，oplog就会有1000条操作日志

- 查看oplog
    ```mongodb
    rs.printReplicationInfo()
    actual oplog size
    '200 MB'
    ---
    configured oplog size
    '200 MB'
    ---
    log length start to end
    '89240 secs (24.79 hrs)'
    ---
    oplog first event time
    'Wed Nov 29 2023 23:35:39 GMT+0800 (China Standard Time)'
    ---
    oplog last event time
    'Fri Dec 01 2023 00:22:59 GMT+0800 (China Standard Time)'
    ---
    now
    'Fri Dec 01 2023 00:23:00 GMT+0800 (China Standard Time)'
    ```

    - 大小200MB，可以包含24.79个小时的操作

        - 大小应该和进行一次完整的重新同步所花费的时间一样长

    ```mongodb
    // 获取每个成员的syncTo值，以及最后一条oplog被写入从节点的时间
    rs.printSecondaryReplicationInfo()
    source: localhost:27018
    {
      syncedTo: 'Fri Dec 01 2023 00:28:19 GMT+0800 (China Standard Time)',
      replLag: '0 secs (0 hrs) behind the primary '
    }
    ---
    source: localhost:27019
    {
      syncedTo: 'Fri Dec 01 2023 00:28:19 GMT+0800 (China Standard Time)',
      replLag: '0 secs (0 hrs) behind the primary '
    }
    ```

    - 在写入频率低的系统中，可能会造成延迟很大的幻觉。假设每小时执行1次写入，在没有完成复制时，从节点看上去比主节点落后1小时。但它能几毫秒追上这“1小时”的操作

- 大多数情况下，默认的oplog大小就足够了。

     - 小于默认oplog的场景：应用程序多读，少写。

     - 大于默认oplog的场景：

        - 1.一次更新多个文档：为了保持幂等性，需要将一个多文档更新，转换为多个单独操作
            - 可能会占用大量oplog空间，但相应的数据大小和数据磁盘使用量不会增加

        - 2.删除的数据量与插入的数据量相同
            - oplog的大小可能会非常大，但数据库磁盘使用量不会显著增加

        - 3.大量的就地（in-place）更新：不增加文档更新的大小
            - oplog的大小可能会非常大，但数据库磁盘使用量不会显著增加

    - 修改oplog大小：
        - 不幸的是，oplog被写满之前，没有简单的方法计算长度。
        - WiredTiger存储引擎允许在线调整oplog大小
            - 应该先在从节点上调整，在对主节点调整

        ```mongodb
        // 查看大小
        // 如果启动的身份验证，要确保使用的用户具有修改local数据库的权限
        use local
        db.oplog.rs.stats(1024*1024).maxSize

        // oplog必须大于990MB，不然会报错。除非mongod启动时设置
        db.adminCommand({replSetResizeOplog: 1, size: 300})
        MongoServerError: BSON field 'size' value must be >= 990, actual value '300'

        // 修改大小为16000MB（16G）
        db.adminCommand({replSetResizeOplog: 1, size: 16000})

        // 如果减少了oplog的大小，可以使用compact命令回收被分配的磁盘空间。但不要对主节点使用该命令。一般来说不应该减少oplog的大小，即使有几个月那么长，因为oplog不会占用ram和cpu资源，但要有足够的磁盘空间容纳它
        ```

- 初始化同步

    - 副本集成员启动时，会检查自身的有效状态，以缺点是否可以开始从其他成员同步数据

    - 状态有效：会从另一个成员中复制数据的完整副本。几个步骤：

        - 1.克隆除`local`数据库以外的所有数据库
            - 克隆前会删除目标成员的所有数据

        - 2.mongodb3.4版本后：每个集合复制文档时，会创建集合中的所有索引
            - 此过程还会在数据复制期间，添加新的oplog记录。因此确保目标成员在`local`数据库中有足够的磁盘空间

        - 3.克隆完成后，更新同步源的oplog（插入、更新、删除）
            - 必须重新克隆某些被克隆程序移动导致丢失的文档

            - 这个过程后：初始化完成，成为从节点，数据与主节点的数据集完全相同

    - 然而，更推荐从备份中恢复（`mongodump`和`mongorestore`）。因为更快
    - 克隆可能会破坏同步源的工作集：某些被经常访问的数据子集，存在于内存中。
        - 执行初始化同步会强制此成员的所有数据分页加载到内存中，驱逐那些经常访问的数据。导致原先可以在内存进行处理，被迫变为磁盘，速度大幅下降

    - 最常见的问题是时间过长：新成员可能从同步源的oplog末尾脱离。——落后于同步源，并且无法再跟上
        - 除了不要在太忙的时候，执行初始化同步或从备份进行恢复。没有其他方法解决这个问题。

- 第二种同步：复制

    - 初始化同步后，从同步源复制oplog。在一个异步进程完成这些操作
    - 从节点会自动更改同步源，以应对ping时间，以及其他成员复制状态的变化。
        - 有一些规则可以设置指定同步源：
            - 1.有投票权的成员，不能从没有投票权的成员同步
            - 2.从节点不能从延迟成员和隐藏成员同步数据

- 过时从节点：

    - 如果从节点远远落后于同步源的操作，就是过时。如果继续同步，从节点就需要跳过一些操作

    - 会发生的场景：从节点服务器停止运行、写操作超过自身处理能力、忙于过多的读操作

    - 从节点过期时：会尝试从副本集中的每个成员进行复制，看看是否有成员有更长的oplog以继续进行同步。如果没有一个成员有足够长的oplog，那么复制就会停止。需要重新进行完全同步或从最近备份中恢复
        - 为避免出现不同步的从节点：可以让主节点拥有一个比较大的oplog，保存足够多的操作日志。
            - oplog应该可以覆盖2到3天的正常操作（复制窗口）

- 成员通过心跳传达自己的副本集状态：

    - `PRIMARY`：主节点
    - `SECONDARY`：从节点
    - `ARBITER`：仲裁者节点

    - `STARTUP`：成员第一次启动的状态。尝试加载副本集配置，加载完成后进入`STARTUP2`
    - `STARTUP2`：初始化同步，处于这个状态，通常只需几秒。成员会创造出几个线程来处理复制和选举，然后进入下一个状态`RECOVERING`
    - `RECOVERING`：成员运行正常，但不能处理读请求。可能因为以下情况
        - 1.在启动时，成员需要做一些自我检查，确保自己是有效状态
        - 2.处理一些耗时命令（压缩、`replSetMaintenance`命令）
        - 3.远远落后其他成员，无法跟上。
            - 这需要重新进行完全同步或从最近备份中恢复

    - 有问题的状态
        - `DOWN`：成员被正常启动，但后来变为不可访问
            - 有可能只是网络问题，成员依然在运行
        - `UNKNOWN`：如果一个成员未能访问另一个成员
            - 成员要么已经停止运行，要么是网络问题

        - `REMOVED`：成员已经从副本集移除。
            - 如果该成员重新添加到副本集，会转换为“正常”状态

        - `ROLLBACK`：成员正在回滚数据

### 回滚

- 因网络分区出现多主节点的回滚例子：

    - 假设有一个5成员的副本集，oplog日志的操作到了125号

    - 此时出现网络分区：

        | 数据中心1 | 数据中心 |
        |-----------|----------|
        | 1主+1从   | 2：3从   |

    - 数据中心1：继续处理自己的写操作。假设oplog到了126号
    - 数据中心2成员满足大多数：因此其中一个从节点会选举成为主节点。这个新的主节点会开始处理写操作。假设oplog到了128号

    - 网络恢复后：数据中心1会寻找oplog126号开始同步，但找不到这个操作。就会开始回滚（rollback）过程
        - 发现125号为最后一个同步操作。在数据中心2期间的126号到128号写操作会回滚。将这些操作的每个文档写入.bson文件，保存砸rollback目录。

    - 回滚完成后会转换为`RECOVERING`状态，并进行正常同步

- 手动使用`mongorestore`命令把回滚的操作应用到当前主节点
    ```sh
    mongorestore --db stage --collection stuff /data/db/rollback/import.stuff.2018-12-19T18-27-14.0.bson
    ```

    - 如果有人在被回滚的成员上创建一个普通索引，而在当前主节点创建了一个唯一索引，就要确保回滚数据没有重复文档

    - 如果希望保留staging集合中的某个版本，可以将它加载到主集合中
        ```mongodb
        staging.stuff.find().forEach(function(doc) {
            prod.stuff.insert(doc);
        })
        ```

    - 对于那些之运行插入操作的集合，可以直接回滚。然而，如果集合中执行更新操作，则需要小心对回滚数据进行合并处理

- mongodb4.0以前回滚内容太多，可能会失败：
    - 回滚数量超过300MB
    - 回滚时间超过30分钟

    - mongodb4.0以后，取消这些限制

#### 写操作确保大多数成员写入；自定义更复杂的规则

- 单主节点崩溃恢复后的回滚例子：

    - 应用程序发送一个写操作到主节点，主节点写入后，还没来得及同步到从节点就崩溃了

        - 应用程序认为能够访问这个写操作

    - 其中一个从节点选举出新主节点，开始接受新的写入

    - 主节点恢复后：发现一些新主节点不存在的写操作

        - 为了纠正，会把这些写入操作，写入到回滚文件。需要手动恢复（`mongorestore`命令），不能自动操作因为可能与崩溃后的写操作冲突。

- 解决方法：设置写操作必须写入指定数量成员，操作才算成功

    ```mongodb
    // writeConcern参数，w的值包含主节点（n个从节点，就是n+1）。
    // 直接使用数字的缺点是，如果副本集配置发生改变，也需要改变
    db.users.insertOne(
        {"_id": 10, "name": "joe"},
        { writeConcern: {"w": "2", "wtimeout": 100}}
    );

    // majority为大多数成员
    try {
        db.users.insertOne(
            {"_id": 10, "name": "joe"},
            { writeConcern: {"w": "majority", "wtimeout": 100}}
        );
    } catch (e) {
        print(e);
    }
    ```

- 自定义规则：可以确保写操作，复制到指定服务器

    - 最好保证复制每个数据中心的至少1台服务器。如果数据中心掉线了，其他数据中心至少都有一个数据副本

        ```mongodb
        var config = rs.config()
        // 通过tags字段，实现按数据中心分类。
        config.members[0].tags = {"dc": "us-east"}
        config.members[1].tags = {"dc": "us-east"}

        config.members[2].tags = {"dc": "us-west"}
        config.members[3].tags = {"dc": "us-west"}

        // 也可以加入多个标签
        config.members[0].tags = {"dc": "us-east", "quality": "high"}
        ```

        - 通过`getLastErrorModes`参数自定义规则

            ```mongodb
            config.settings = {}
            config.settings.getLastErrorModes = {
              "eachDC": {
                "dc": 2
              }
            };
            rs.reconfig(config)

            // 现在可以对写操作应用这条规则
            db.users.insertOne(
                {"_id": 10, "name": "joe"},
                { writeConcern: {"w": "eachDC", "wtimeout": 100}}
            );
            ```

    - 保证写操作被复制到大多数非隐藏节点

        - 隐藏节点是二等公民。发生故障时不会转移到隐藏节点，也无法执行任何读操作

        ```mongodb
        // 假设有5个成员host0-host4，host4是隐藏成员。
        // 写操作同步大多数非隐藏成员至少host0、host1、host2、host3中的3个；没有为hosts4添加tags
        var config = rs.config()
        config.members[0].tags = {"normal": "A"}
        config.members[1].tags = {"normal": "B"}
        config.members[2].tags = {"normal": "C"}
        config.members[3].tags = {"normal": "D"}

        // 设置规则
        config.settings.getLastErrorModes = {"visibleMajority": {"normal": 3}}
        rs.reconfig(config)

        // 现在可以对写操作应用这条规则
        db.users.insertOne(
            {"_id": 11, "name": "joe"},
            { writeConcern: {"w": "visibleMajority", "wtimeout": 100}}
        );
        ```

#### 防止回滚

- 对于一些场景少量回滚写操作，不是大问题
    - 在博客场景中：回滚某位读者的一两条评论，不会有什么问题

- 不要更改成员的投票数量
    - 改变投票数量，会导致大量回滚

### 负载问题

- 许多用户会将读请求，发送到从节点分配负载

    - 如果服务器每秒只能处理10000次查询，而你需要的查询有30000次。选择设置多个从节点承担负载：创建4个成员的副本集（因为是偶数，所以其中一个没有投票权，以防止平票）

    - 问题：其中一个从节点崩溃了。剩下每个成员就都100%负载，而当成员恢复时，还要从其他成员复制数据，进一步加剧负载。过载可能会导致主节点的复制速度变慢，使得从节点都落后于主节点，恶性循环。

    - 解决方法：使用5台服务器，而不是4台。就算1台崩溃，也不会出现过载。前提是你很清楚1台服务器的负载能力。
        - 但即使如此，依然可能会出现超出预期的服务器崩溃，导致过载

    - 最佳解决方法：分片

## 分片（shard)

- 分片类似于集群和RAID10
    - 可以使用性能较弱的机器实现负载
    - 可以基于地理位置拆分文档，让靠近它们的客户端更快的访问

- config配置服务器：将元数据持久化。
    - 如果元数据丢失，分片将无法使用
        - 因此在生产环境中应该配置3台单独的物理机器，最好是跨地理位置分布
        - 机器最好是有充分的cpu和网络资源，存储只需少量资源

    - `--configsvr`选项：设置为config配置服务器。

    - 除了`config`和`admin`外，不会向其他数据库写入数据
        - `config`：保存分片集群的元数据，当数据块迁移、拆分，就会写入`config`数据库
        - `admin`：身份验证和授权相关

    - config配置服务器写入和读取时
        - 写入：mongodb会使用`majority`的`writeConcern`级别
        - 读取：mongodb会使用`majority`的`readConcern`级别
        - 这确保在分片元数据一致性。
            - 元数据在不发生回滚时，才会被提交到config配置服务器的副本集
            - 只会读取不受config配置服务器故障影响的元数据

- mongos：路由进程，负责将客户端的操作路由到具体的分片上。因此它需要从`config配置服务器`获取元数据（分片的情况）

    - 默认端口为27017

    - 应该启动一定数量的mongos进程，并尽量放在靠近所有分片的位置
        - 可以提高访问多个分片的查询性能
        - 确保高可用：应该创建2个mongos进程
        - 如果运行数十上百个mongos进程，会争夺config配置服务器资源。应该使用一个小型路由节点池

- 分片：
    - 添加分片要确保副本集的名字不同
    - 添加分片还要确保副本集相互之间没有同名数据库
        - 如果有同名mongos会拒绝添加到分片中

- 块与分片

    - 会将集合才分成多个块块，对于大型集合来说可能需要几个小时
        ```mongodb
        sh.shardCollection("crm.users", {"name": 1})
        ```

    - 一个文档总是仅属于一个块。因此不能使用数组字段作为片键——因为数组会创建多个索引项

    - mongodb会用一个较小的表来维护块与分片的映射，保存在`config`数据库的`chunks`集合中

        - 如果假设片键为{"age": 1}
            - 某个块就可能是在age字段3和17之间的文档组成
            - 假设mognos查询{"age": 5}，就会将查询路由到该块的分片上

    - 写操作会改变一个块中的文档数量和大小
        - 删除会使块包含更少的文档
        - 插入会使块包含更多的文档
        - 拆分：
            - 块增长到一定大小，会拆分成2个更小的块

                - 例子：有一个`3 <= "age" < 17`的块被拆分时，会分成`3 <= "age" < 12`和`12 <= "age" < 17`。12被成为拆分点（split point）

                - 步骤：

                    - 1.分片的主节点mongod会向config配置服务器请求`全局块大小配置值`
                    - 2.mongod收到`全局块大小配置值`向均衡器发送拆分请求；均衡器会进行数据迁移
                    - 3.mongod将拆分后的块的元数据，更新到config配置服务器

                - 如果在拆分时，一个配置服务器停止运行，那么mongod将无法更新元数据，也就无法拆分
                    - 拆分风暴：mongod不断收到对一个块的写操作，则会不断尝试拆分，并失败（配置服务器没有正常运行）。这些拆分请求会拖慢mongod


            - 然而拆分方法有限，可能会出现一个块很大了，但无法找到拆分点。因此片键值很重要
                ```mongodb
                {"age": 12, "name": "joe"}
                {"age": 12, "name": "joe1"}
                {"age": 12, "name": "joe2"}
                {"age": 12, "name": "joe3"}
                ...
                ```

    - 复合片键：假设有一个复合片键`{"name": 1, "age": 1}`
        - 如果查询是name或name和age的文档，很容易找到对应的块
        - 如果说age，就需要检查大部分甚至所有的块。因此应使用`{"age": 1, "name": 1}`作为复合片键


- 均衡器：负责数据迁移

    - 是config配置服务器的主节点的后台进程：监视每个分片的块数量，只要块达到阈值大小，才会被激活

    - 定期检查分片之间是否存在不均衡，如果存在就迁移

        - mongodb3.4之后，可以并发执行迁移，并发的最大数量是分片总数的一半

    - 达到阈值时，会开始对块进行迁移：从负载较大的分片中选一个块，并询问分片是否在迁移之前进行拆分，拆分完成后，就会将块迁移到较少块的机器上
        - 这对客户端不可见
            - 1.mongos会将所有读写请求路由到旧的块上
            - 2.mongos会收到一个错误（日志中可能会有unable to setShardVersion），然后从config配置服务器查找数据的新位置，并更新块分布表
                - 如果config配置服务器不可用，无法获取新块的位置，就会向客户端返回一个错误。
            - 3.mongos重新发送请求，成功检索数据后返回客户端

    - 如果迁移过程影响性能，可以在`config.settings`集合中指定一个时间窗口：只允许在下午1点到4点执行均衡

        ```mongodb
        // 开启均衡器
        sh.setBalancerState(true)

        // 设置activeWindow字段
        use config
        db.settings.update(
            {_id: "balancer"},
            {$set: { activeWindow: { start: "13:00", stop: "16:00" }}},
            {upsert: true}
        )
        ```

- 变更流（change stream）：允许应用追踪数据库中数据的实时变更
    - mongodb3.6之后：只能通过追踪`oplog`实现，是一个复杂且容易出错的操作
    - 变更流可以为一个集合、一组集合、一个数据库、整个集群的所有数据的变更提供订阅机制
        - 使用了聚合框架：允许用户自定义过滤
    - 所有变更流操作，都必须针对mongos发出
    - 如果开启变更流的分片，并运行带有`mulit:true`的集合的更新操作，会出现向孤儿文档发送通知
    - 如果一个分片被删除，那么打开的变更流游标被关闭，并且无法恢复

### 启动分片

- `ShardingTest()`的创建分片的方式，已经被抛弃

- 实验：通过配置文件启动分片：

- 所有配置文件在`mongodb/shard`目录下的`start.conf`

- 启动顺序：config配置服务器->所有分片->mongos
    - 重启分片的顺序也一样，只是不需要初始化
    - 如果不按照顺序启动，可能会出现内部通信问题

- 1.启动config配置服务器：37017、37018、37019
    ```sh
    # 启动config配置服务器
    mongod --config ~/mongodb/shard/config-primary/start.conf &
    mongod --config ~/mongodb/shard/config-secondary1/start.conf &
    mongod --config ~/mongodb/shard/config-secondary2/start.conf &

    # 连接
    mongosh --port 37017
    ```

    ```mongosh
    // 初始化副本集
    // 创建配置文档。_id名字要与配置文件的replSetName名字一样
    rsconf = {
        _id: "rsconfig",
        members: [
            {_id:0, host: "localhost:37017"},
            {_id:1, host: "localhost:37018"},
            {_id:2, host: "localhost:37019"}
        ]
    }

    // 传递rsconf实现初始化。提示符变成rsconfig [direct: primary] test>
    // 应该总是使用rs.initiate()初始化，否则mongodb会尝试自动生成一个单成员的副本集配置。
    rs.initiate(rsconf)

    // 查看副本集状态。members数组有3个成员
    rs.status()
    ```

- 2.启动分片1：27017、27018、27019

    ```sh
    # 启动分片1
    mongod --config ~/mongodb/shard/shard1-primary/start.conf &
    mongod --config ~/mongodb/shard/shard1-secondary1/start.conf &
    mongod --config ~/mongodb/shard/shard1-secondary2/start.conf &

    # 连接
    mongosh --port 27017
    ```

    ```mongosh
    // 初始化副本集
    // 创建配置文档。_id名字要与配置文件的replSetName名字一样
    rsconf = {
        _id: "rs0",
        members: [
            {_id:0, host: "localhost:27017"},
            {_id:1, host: "localhost:27018"},
            {_id:2, host: "localhost:27019"}
        ]
    }

    // 传递rsconf实现初始化。提示符变成rs0 [direct: primary] test>
    // 应该总是使用rs.initiate()初始化，否则mongodb会尝试自动生成一个单成员的副本集配置。
    rs.initiate(rsconf)

    // 查看副本集状态。members数组有3个成员
    rs.status()
    ```

- 3.启动分片2：27020、27021、27022

    ```sh
    # 启动分片2
    mongod --config ~/mongodb/shard/shard2-primary/start.conf &
    mongod --config ~/mongodb/shard/shard2-secondary1/start.conf &
    mongod --config ~/mongodb/shard/shard2-secondary2/start.conf &

    # 连接
    mongosh --port 27020
    ```

    ```mongosh
    // 初始化副本集
    // 创建配置文档。_id名字要与配置文件的replSetName名字一样
    rsconf = {
        _id: "rs1",
        members: [
            {_id:0, host: "localhost:27020"},
            {_id:1, host: "localhost:27021"},
            {_id:2, host: "localhost:27022"}
        ]
    }

    // 传递rsconf实现初始化。提示符变成rs1 [direct: primary] test>
    // 应该总是使用rs.initiate()初始化，否则mongodb会尝试自动生成一个单成员的副本集配置。
    rs.initiate(rsconf)

    // 查看副本集状态。members数组有3个成员
    rs.status()
    ```

- 4.启动mongos路由进程：不需要指定数据目录
    ```sh
    # 启动mongos路由进程。记得是mongos命令，而不是mongod，不然会报错Unrecognized option: sharding.configDB
    mongos --config ~/mongodb/shard/mongos/start.conf &

    # 连接mongos
    mongosh --port 47017
    ```

    ```mongodb
    // 初始化mongos
    // 将副本集加入到分片
    sh.addShard("rs0/localhost:27017")
    sh.addShard("rs1/localhost:27020")

    // 查看分片信息
    sh.status()
    //输出
    shardingVersion
    { _id: 1, clusterId: ObjectId("656c82ba589edf4797d528fc") }
    ---
    shards //能看到有两个成员。此时开未开启分片
    [
      {
        _id: 'rs0',
        host: 'rs0/localhost:27017,localhost:27018,localhost:27019',
        state: 1,
        topologyTime: Timestamp({ t: 1701611067, i: 2 })
      },
      {
        _id: 'rs1',
        host: 'rs1/localhost:27020,localhost:27021,localhost:27022',
        state: 1,
        topologyTime: Timestamp({ t: 1701611073, i: 2 })
      }
    ]
    ---
    active mongoses
    [ { '7.0.4': 1 } ]
    ---
    autosplit
    { 'Currently enabled': 'yes' }
    ---
    balancer // 默认开启均衡器
    {
      'Currently enabled': 'yes',
      'Currently running': 'no',
      'Failed balancer rounds in last 5 attempts': 0,
      'Migration Results for the last 24 hours': 'No recent migrations'
    }
    ---
    databases
    [
      {
        database: { _id: 'config', primary: 'config', partitioned: true },
        collections: {}
      }
    ]
    ```

- 5.测试
    ```mongodb
    // 创建crm数据库
    use crm
    // 创建users集合
    db.users.insertOne({"_id": 0, "name": "joe"})
    // 查看分片。
    sh.status()
      {
        database: {
          _id: 'crm',
          primary: 'rs1', // 表示crm数据库所有未分片的集合保存在rs1副本集上
          partitioned: false, // 此时还没有开启分片功能
          version: {
            uuid: new UUID("6ed56c4e-c051-4e72-bdb7-86f077e92814"),
            timestamp: Timestamp({ t: 1701611557, i: 1 }),
            lastMod: 1
          }
        },
        collections: {}
      }

    # 进入rs1
    mongosh --port 27020

    // 选择crm数据库
    use crm

    // 读取会报错。报错信息和在副本集的从节点读取一样
    db.users.find()
    MongoServerError: not primary and secondaryOk=false - consider using db.getMongo().setReadPref() or readPreference in the connection string

    // 开启从节点读取
    db.getMongo().setReadPref('secondary')

    // 再次读取
    db.users.find()
    [ { _id: 0, name: 'joe' } ]

    // 由于没有开启分片功能的crm数据库保存在rs1；如果进入rs0，开启从节点读取，执行db.users.find()，什么也读取不到
    ```

- 6.开启分片功能
    ```mongodb
    // 回到mongos
    // 插入更多数据
    for (var i=1; i<10000; i++) {
        db.users.insertOne({'_id': i, "name": "joe"+i});
    }

    // 对crm数据库开启分片功能
    sh.enableSharding("crm")

    // 分片需要选择一个片键，需要创建索引
    db.users.ensureIndex({"name": 1})
    // 按片键分片存储
    sh.shardCollection("crm.users", {"name": 1})
    // partitioned依然没有true??分片之前是单独的块，分片之后会被分为多个块
    sh.status()
      {
        database: {
          _id: 'crm',
          primary: 'rs1',
          partitioned: false,
          version: {
            uuid: new UUID("6ed56c4e-c051-4e72-bdb7-86f077e92814"),
            timestamp: Timestamp({ t: 1701611557, i: 1 }),
            lastMod: 1
          }
        },
        collections: {
          'crm.users': {
            shardKey: { name: 1 },
            unique: false,
            balancing: true,
            chunkMetadata: [ { shard: 'rs1', nChunks: 1 } ],
            chunks: [
              { min: { name: MinKey() }, max: { name: MaxKey() }, 'on shard': 'rs1', 'last modified': Timestamp({ t: 1, i: 0 }) }
            ],
            tags: []
          }
        }
      },

    // 查询name字段作为条件的文档。只有一个shardName
    db.users.find({"name": "joe10"}).explain()
    // 查询所有文档。有两个shardName
    db.users.find().explain()
    ```

- 7.关闭分片
    ```mongodb
    // 关闭分片没有捷径，要连接所有节点执行以下命令。要先关闭secondary节点，在关闭primary
    use admin
    db.shutdownServer()
    ```

### 副本集转换为分片

- 实验：有一个名为mdDefGuide，地址为localhost:27017、localhost:27018、localhost:27019的副本集

- 需要主节点和从节点都需要使用`--shardsvr`选项全部重新启动

```sh
# 先关闭从节点。我这里是27018和27019
mongosh --port 27018
db.shutdownServer()

mongosh --port 27019
db.shutdownServer()

# 加入--shardsvr选项后，重新启动从节点
mongod --replSet mdDefGuide --dbpath ~/mongodb/rs2 --port 27018 --oplogSize 200 --shardsvr &
mongod --replSet mdDefGuide --dbpath ~/mongodb/rs3 --port 27019 --oplogSize 200 --shardsvr &

# 再关闭主节点。我这里是27017
mongosh --port 27017
rs.stepDown()
db.shutdownServer()

# 加入--shardsvr选项后，重新启动主节点
mongod --replSet mdDefGuide --dbpath ~/mongodb/rs1 --port 27017 --oplogSize 200 --shardsvr &
```

- 启动config配置服务器（我这里使用上一个实验的配置文件。如果像上一个实验那样启动过，则需要删除data目录里的数据）

    - 所有配置文件在`mongodb/shard`目录下的`start.conf`

```sh
# 启动config配置服务器
mongod --config ~/mongodb/shard/config-primary/start.conf &
mongod --config ~/mongodb/shard/config-secondary1/start.conf &
mongod --config ~/mongodb/shard/config-secondary2/start.conf &

// 初始化副本集
mongosh --port 37017
rsconf = {
    _id: "rsconfig",
    members: [
        {_id:0, host: "localhost:37017"},
        {_id:1, host: "localhost:37018"},
        {_id:2, host: "localhost:37019"}
    ]
}
rs.initiate(rsconf)
rs.status()
```

- 启动mongos路由进程
    - 添加分片后，客户端的请求需要发送到mongos而不是副本集
```sh
# 启动mongos路由进程。记得是mongos命令，而不是mongod，不然会报错Unrecognized option: sharding.configDB
mongos --config ~/mongodb/shard/mongos/start.conf &

# 连接mongos
mongosh --port 47017

// 初始化mongos
// 将mdDefGuide副本集加入到分片
sh.addShard("mdDefGuide/localhost:27017")

// 查看分片信息
sh.status()
```

### 选择片键

- 片键：对集合进行分片时，需要对一两个字段进行数据拆分，这个键（这些键）就是片键

- 对于分片的每个集合，首先要回答以下问题

    - 多少个分片？
        - 3个分片比1000个分片的有更大灵活性
        - 集群的分片不断增长，不应该使用会触发所有分片的查询

    - 分片是为了减少读写延迟吗？一个写操作是20毫秒，但你希望是10毫秒
    - 分片是为了提高吞吐量吗？20毫秒完成1000次写操作，但你希望是20毫秒完成5000次写操作
    - 分片是为了增加系统资源吗？增加更多的ram

- 片键和索引概念是相似的：你的片键可能就是你最常使用的索引（或者索引的一些变体）

- 片键的限制：

    - 不能是数组。如果是`sh.shardCollection()`会失败。
    - 特殊类型不能作为片键：地理空间索引
    - 插入文档后，片键的值可能会被修改，除非是不可变的如`_id`字段。在mongodb4.2之前不能修改文档的片键值

- 片键的基数：和索引一样，基数越高，分片性能越好。
    - 如果logLevel只有DEBUG、WARN、ERROR三个值，则mongodb无法分出超过三个以上的块
        - 解决方法：可以使用该键和另一个拥有多样值的键组成复合片键。——比如loglevel和timestamp。总之键的组合要有很高的基数

- 单独的mongod服务器，执行升序写操作时效率最高。分片则与之相反，写操作分发在集群中时，分片效率最高

- 升序片键：类似于`data`或`objectid类型的_id`——随着时间稳步增长的字段。

    - 每次新插入的文档，都会出现在最大块（包含$maxKey键）
    - 所有写操作都会路由到保存最大块的分片上。随着数据的增长，块会被拆分

    - mongodb很难保持块的均衡：所有块都是由一个分片创建的，需要不断将块移动到其他分片上
        - mongodb4.2之后，自动拆分功能被移动到分片的主节点。均衡器会决定在哪个分片中放置顶部块。有助于避免一个分片创建所有新块

- 随机分发的片键：可以是用户名、电子邮件、UUID、MD5哈希值等（没有可识别模式的键）
    - 由于写操作是随即分发：分片应该以大致相同的速度增长，从而减少进行迁移操作的数量
    - 哈希片键：如果不打算执行范围查询，哈希片键就是一个很好的选择
        - 不能使用`unique`选项；不能使用数组字段；浮点型会在哈希前取整（1和1.9会被哈希为同样的值）
        - 对于有一个不存在的集合创建哈希片键，`sh.shardCollection()`会立即创建一些空的块分发到分片集群中。
        ```mongodb
        // 创建哈希索引
        db.users.createIndex({"name": "hashed"})

        // 对集合进行分片
        sh.shardCollection("app.users", {"name": "hashed"})
        ```

- 基于范围的片键：ip、经纬度、地址。在mongodb4.0.3之后，可以定义区域

    | 函数                     | 说明                                 |
    |--------------------------|--------------------------------------|
    | sh.addShardToZone()      | 通过对分片添加标签，从而定义分区范围 |
    | sh.removeShardFromZone() | 取消标签                             |
    | sh.updateZoneKeyRange()  | 将集合分发到标签所在的分区           |
    | sh.removeRangeFromZone() | 移除某个集合的范围                     |

    - 均衡器移动块时，会尝试将这些访问的块移动到指定分片上。但不是立即完成。未被划分区域的块仍会正常移动

        - `sh.updateZoneKeyRange()`不会立即生效，而是给均衡器一条命令。运行时，可以将集合移动到这些目标分片。

    - 例子：基于ip范围的分片

        ```mongodb
        // 对于USPS美国邮政局的ip出现在shard0000分片上
        sh.addShardToZone("shard0000", "USPS")
        // 对于苹果公司的ip出现在shard0000分片和shard0002上
        sh.addShardToZone("shard0000", "Apple")
        sh.addShardToZone("shard0002", "Apple")


        // 56.*.*.*为USPS美国邮政局ip段
        sh.updateZoneKeyRange("test.ips", {"ip": "056.000.000.000"}, {"ip": "057.000.000.000", "USPS"})

        // 17.*.*.*为苹果公司ip段
        sh.updateZoneKeyRange("test.ips", {"ip": "017.000.000.000"}, {"ip": "018.000.000.000", "Apple"})
        ```

    - 消防水管策略：一些服务器的性能比其他服务器更强大

        ```mongodb
        // shard0000性能10倍于其他机器。创建分区
        sh.addShardToZone("shard0000", "10x")

        // 升序键的当前值到无穷大的块，始终固定到"10x"的分片上
        sh.updateZoneKeyRange("test.users", {"_id": ObjectId()}, {"_id": MaxKey}, "10x")
        ```

        - 当前值到无穷大会固定到指定分片上。解决方法：可以设置一个定时任务，每天更新一次键值范围

            ```mongodb
            use config
            var zone = db.tags.findOne({"ns": "<dbName.collName>", "max": {"<shardKey>", MaxKey}})
            zone.min.<shardKey> = ObjectId()
            db.tags.save(zone)
            ```

        - 该策略的缺点是：需要一些变更，才能进行扩展。如果最强大的服务器无法再处理写入，则没有简单的方法可以在这台服务器和另一台服务器之间分配负载

    - 希望是数据价值高（实时集合），而不是数据价值低（日志集合）用于高性能服务器上

        - 例子1：划分高性能和低性能分区

            ```mongodb
            sh.addShardToZone("shard0000", "high")
            // shard0001 - no zone
            // shard0002 - no zone
            // shard0003 - no zone
            sh.addShardToZone("shard0004", "low")
            sh.addShardToZone("shard0005", "low")

            // 将不同数据库集合分配个不同的分片
            sh.updateZoneKeyRange("super.import", {"<shardKey>": MinKey}, {"<shardKey>": MaxKey}, "high")
            sh.updateZoneKeyRange("some.logs", {"<shardKey>": MinKey}, {"<shardKey>": MaxKey}, "low")
            ```

        - 例子2：对非高性能分片分区

            ```mongodb
            // 只希望不放在高性能分区上，而不在乎放在哪个分区上
            sh.addShardToZone("shard0001", "whatever")
            sh.addShardToZone("shard0002", "whatever")
            sh.addShardToZone("shard0003", "whatever")
            sh.addShardToZone("shard0004", "whatever")
            sh.addShardToZone("shard0005", "whatever")

            // 随机分发到非高性能的5个分片上
            sh.updateZoneKeyRange("normal.coll", {"<shardKey>": Minkey}, {"<shardKey": MaxKey}, "whatever")

            // 移除shard0005的标签
            sh.removeShardFromZone("shard0005", "whatever")

            // 参数必须与sh.updateZoneKeyRange()一样
            sh.removeRangeFromZone("normal.coll", {"<shardKey>": Minkey}, {"<shardKey": MaxKey}, "whatever")
            ```

- 热点块和复合片键

    - 最好每个分片都有几个热点，写操作可以在分片集群中均匀分发，并且同一个分片的写操作是递增。实现这一点需要：复合片键

    - 复合片键：

        - 第一个值：随机值，基数较少。可以将每个值想象为1个块
        - 第二个值：升序键。在块的内部，值总是在增加

        - 可以想象为每个块都是1个升序文档的栈，每个栈都是递增的，直到块被拆分。一旦某个块被拆分，就只有一个新的块是热点块，其他块实际上已经死亡，不在增长。
            - 如果栈均匀的分发到各个分片上，写操作也将均匀分发

        - 我们希望每个分片有几个热点块，但不要太多。如果有1个分片有1000个热点块的话，就等同于随机写了

        - 添加新的块不会有任何写操作，因为没有热点块在这个分片上面

### 管理

#### 查看基本分片信息

- 查看分片信息

    ```mongodb
    // sh.status()从config数据库收集。如果块的数量比较多，会统计块总数的信息，而不是打印每个块。
    sh.status()

    // 打印所有块
    sh.status(true)
    ```

- 查看配置信息

    - 不要直接连接config配置服务器，避免以外更改或删除数据

    - 应该通过mongos连接到config数据库。就算config数据库被意外删除，也可以与config配置服务保持同步

    - 通常来说不应该更改config数据库的任何数据；如果修改了，则需要重启所有mongos才能看到效果

    - 默认情况下，数据库的新集合都会在数据库对应的主分片上创建

    ```mongodb
    // 先进入config数据库
    use config

    // 查看所有分片（config.shards）
    db.shards.find()

    // 查看所有数据库（config.databases）。包括分片数据库和非分片数据库
    db.databases.find()
    ```

- 集合中每个块的记录

    - `sh.status()`会通过`config.chunks`收集它大部分信息

    ```mongodb
    db.chunks.find()

    // 只输出1行
    db.chunks.find().skip(1).limit(1).pretty()
    ```

    | db.chunks.find()中有用的字段 | 说明                                                 |
    |------------------------------|------------------------------------------------------|
    | lastmod                      | 数据库的版本                                         |
    | Timestamp                    | 第一部分：块迁移到新分片的次数；第二部分：拆分的次数 |
    | lastmodEpoch                 | 集合创建的时间                                       |

- 查看已经发生的拆分和迁移

    - 拆分：

        ```mongodb
        // 查看拆分的记录
        db.changelog.find({what: "split"})
        ```

        - `details`字段：提供了原始文档和拆分后的内容信息

    - 迁移：

        - from分片：

            ```mongodb
            // from
            db.changelog.find({what: "moveChunk.from"})
              {
                _id: 'tz-pc:27021-2023-12-08T16:50:00.186+08:00-6572d8b8e2e37f6f638e9361',
                server: 'tz-pc:27021',
                shard: 'rs1',
                clientAddr: '',
                time: ISODate("2023-12-08T08:50:00.186Z"),
                what: 'moveChunk.from',
                ns: 'crm.users',
                details: {
                  'step 1 of 6': 0,
                  'step 2 of 6': 2,
                  'step 3 of 6': 61,
                  'step 4 of 6': 139,
                  'step 5 of 6': 35,
                  'step 6 of 6': 36,
                  min: { name: MinKey() },
                  max: { name: MaxKey() },
                  to: 'rs0',
                  from: 'rs1',
                  note: 'success'
                }
              },
            ```

            - 当"from"分片收到mongos的`moveChunk`命令时的步骤
                - 1.检查命令参数
                - 2.向config配置服务器申请一把分布式锁，以进入迁移过程
                - 3.尝试连接到"to"分片
                - 4.复制数据
                - 5.与"to"分片和config配置服务器协调，确认迁移是否成功

            - `details`字段的每一步都是计时：`stepN of N`表示每一步所花的时间（单位：毫秒）

                - "to"分片和from分片必须从`step4 of 6`开始通信：每个分片会直接连接到另一个分片以及config配置服务器通信，执行迁移

                - 如果"from"分片在最后几步网络连接不稳定，那么会处于一种无法撤销迁移、也无法完成迁移的状态。在这种状态下，mongod会关闭

        - to分片：

            ```mongodb
            // to。
            db.changelog.find({what: "moveChunk.to"})
              {
                _id: 'tz-pc:27019-2023-12-08T16:50:00.176+08:00-6572d8b88b9cdd671843e061',
                server: 'tz-pc:27019',
                shard: 'rs0',
                clientAddr: '',
                time: ISODate("2023-12-08T08:50:00.176Z"),
                what: 'moveChunk.to',
                ns: 'crm.users',
                details: {
                  'step 1 of 8': 2,
                  'step 2 of 8': 15,
                  'step 3 of 8': 14,
                  'step 4 of 8': 105,
                  'step 5 of 8': 0,
                  'step 6 of 8': 10,
                  'step 7 of 8': 0,
                  'step 8 of 8': 51,
                  min: { name: MinKey() },
                  max: { name: MaxKey() },
                  to: 'rs0',
                  from: 'rs1',
                  note: 'success'
                }

            // 比from之多了这2行
                  to: 'rs0',
                  from: 'rs1',
            ```

            - `details`字段的每一步都是计时：`stepN of N`表示每一步所花的时间（单位：毫秒）
                - 与from一样

            - 当"to"分片收到"from"分片发来的命令时的步骤

                - 1.迁移索引
                    - 如果这个分片以前从未保存过迁移集合的块：需要知道都索引了那些字段
                    - 如果这个分片以前保存过迁移集合的块：忽略此步骤

                - 2.删除块范围内的任何现有数据。
                    - 可能会有从失败的迁移或恢复过程遗留下来的数据，不希望这些数据干扰当前数据

                - 3.复制过程：将数据块中的所有文档复制到"to"分片

                - 4.执行在复制过程，出现的对这些文档的操作

                - 5.等待"to"分片将新迁移的数据复制到大多数服务器上
                - 6.更新元数据，表明位于"to"分片上

- 查看均衡器设置
    ```mongodb
    db.settings.find()
    [
      { _id: 'balancer', mode: 'off', stopped: true },
      { _id: 'automerge', enabled: false }
    ]
    ```

#### 网络信息

```mongodb
// 获取连接统计
// connPoolStats没有使用锁，计数不是实时的
db.adminCommand({"connPoolStats": 1})
```

|字段|说明|
|----------------------|---------------------------------------------------------------------------------------------------------------|
| totalAvailable       | mongos和monod实例向分片集群或副本集其他成员的**可用传出连接总数**                                             |
| totalCreated         | mongos和monod实例向分片集群或副本集其他成员的**创建的传出连接总数**                                           |
| totalInUse           | mongos和monod实例向**正在使用的**分片集群或副本集其他成员的**传出连接总数**                                   |
| totalRefreshing      | mongos和monod实例向**正在刷新的**分片集群或副本集其他成员的**传出连接总数**                                   |
| numClientConnections | mongos和monod实例向分片集群或副本集其他成员的**活动并保存的传出同步连接数量**                                 |
| numAScopedConnection | mongos和monod实例向分片集群或副本集其他成员的**活动并保存的传出作用域同步数量**                               |
| polls                | 按连接池分组的连接统计信息（正在使用/可用/已创建/刷新）。基于DBClient的连接池和基于NetworkInterfaceTL的连接池 |
| hosts                | 按主机分株的连接统计信息（正在使用/可用/已创建/刷新）mongod和monos实例与分片或副本集每个成员的之间的连接      |


- 限制连接数量

    - 默认情况下mongos和mongod一样接受65536个连接
    - 因此如果有5个mongos进程，每个与10000个客户端连接，那么mongos会试图创建50000个连接到分片

    - 设置连接最大数的命令行：`mongos --maxConns`
        - maxConns只会阻止mongos创建超过这个数量的连接。达到数量后会阻塞请求，等待连接被释放

    - 一个分片可用处理的单个mongos最大连接数公式：`maxConns = maxConnsPrimary - (numMembersPerReplicaSet * 3) - (other * 3) / numMongosProcesses`
        - `maxConnsPrimary`：主节点最大连接数。通常设置20000
        - `(numMembersPerReplicaSet * 3)`：主节点与每个从节点创建的一个连接，而每个从节点会主节点创建2个连接，总共3个连接
        - `(other * 3)`：连接mongods各种进程数量，比如监视或备份的代理、shell的直接连接（用于管理），或者为了迁移而连接到其他分片的连接
        - `numMongosProcesses`：分片集群中的mongos总数

        - 读者著：只有一个mongos和一个mongosh的计算：20000 - (3 * 3) - (1 * 3) / 1 = 19988

    - 当一个mongodb实例完全退出时，会关闭所有连接。
    - 如果实例非正常下线（断电、崩溃、网络等）它可能不会关闭所有套接字。
        - 分片集群中其他服务器，可能会认为连接是正常的，会得到一个错误并刷新连接。
            - 连接数少时，刷新过程会很快。如果有数千个连接必须1个接着1个刷新时，可能会出现大量错误
            - 解决方法：重新启动陷入重连风暴的进程

#### 服务器管理

- 添加服务器
    ```mongodb
    // 将副本集加入到分片
    sh.addShard("rs0/localhost:27017")
    ```

- 修改分片上的成员，需要连接给分片的主节点（而不是通过mongos），并重新配置副本集。
    - 集群配置会监测到变更并自动更新config.shards。不要手动修改config.shards

- 删除服务器

    - 不应该从集群中删除分片。如果添加了过多的分片，最好让系统增长到这些分片的体量，而不是先删除分片，然后等需要时再添加

    - 不过，必要情况下，可以对分片进行删除
        - 确保均衡器是打开的：均衡器的任务是把要删除分片上的所有数据移动到其他分片上（排空drainning）

    ```mongodb
    // removeShard命令会将该分片上的所有块，移动到其他分片上
    // 如果有很多块或较大的块，排空需要很长时间
    db.adminCommand({"removeShard": "rs0"})

    // 再一次运行可以查看移动进度
    db.adminCommand({"removeShard": "rs0"})
    {
      msg: 'draining ongoing',
      state: 'ongoing', // 正在进行移动
      remaining: { chunks: Long("3"), dbs: Long("3"), jumboChunks: Long("0") },
      note: 'you need to drop or movePrimary these databases',
      dbsToMove: [ 'test', 'apple', 'app' ],
      ok: 1,
      '$clusterTime': {
        clusterTime: Timestamp({ t: 1702038842, i: 1 }),
        signature: {
          hash: Binary.createFromBase64("AAAAAAAAAAAAAAAAAAAAAAAAAAA=", 0),
          keyId: Long("0")
        }
      },
      operationTime: Timestamp({ t: 1702038842, i: 1 })
    }
    ```

    - 如果所有块移动后，removeShard有dbsToMove字段列出的数据库。完成分片删除，就需要删除这些数据库或者将数据库移动到新的分片

        ```mongodb
        // movePrimary命令移动dbsToMove字段的数据库到rs1
        db.adminCommand({"movePrimary": "crm", "to": "rs1"})
        db.adminCommand({"movePrimary": "apple", "to": "rs1"})
        db.adminCommand({"movePrimary": "app", "to": "rs1"})

        // 再一次运行removeShard。记得开启均衡器，不然无法完成
        db.adminCommand({"removeShard": "rs0"})
        {
          msg: 'removeshard completed successfully',
          state: 'completed', // 已经完成。
          shard: 'rs0',
          ok: 1,
          '$clusterTime': {
            clusterTime: Timestamp({ t: 1702039713, i: 4 }),
            signature: {
              hash: Binary.createFromBase64("AAAAAAAAAAAAAAAAAAAAAAAAAAA=", 0),
              keyId: Long("0")
            }
          },
          operationTime: Timestamp({ t: 1702039713, i: 4 })
        }
        ```

- 刷新配置：有时候mongos过旧，或找不到应有数据
    ```mongodb
    // 刷新配置。然后需要重启mongos或mongod进程才能清除所有缓存数据
    db.adminCommand({"flushRouterConfig": 1})
    ```

## GridFS

- [官方文档](https://www.mongodb.com/docs/manual/core/gridfs/)

- mongodb所有文档必须小于16MB。GridFS提供存储大于16MB的BSON文档

- GridFS不支持多文档事务

- GridFS缺点：
    - 性能比较低：从mongodb访问文件，不如直接从文件系统访问速度快
    - 修改GridFS的文档，只能先删除原有文档，在重新保存
        - 由于文件会被分割成块（chunk），所以无法对同一个文件的所有块加锁

    - 结论：GridFS只适用于不常修改，但需要经常访问的大文件

- GridFS会将文件分割成多个块（chunk），默认为255KB。最后一个块会存储元数据

    - `fs.chunks`集合：存储块（chunk）

        ```mongodb
        // 查看fs.chunks内的chunk
        db.fs.chunks.find()
        {
         _id: ObjectId("6559a3991fcfb0e85fa79902"),
         files_id: ObjectId("6559a3991fcfb0e85fa79901"),
         n: 0,
         data: Binary.createFromBase64("aGVsbG8sIHdvcmxkCg==", 0)
       },
        ```

        | 字段     | 说明                         |
        |----------|------------------------------|
        | _id      | 唯一id                       |
        | files_id | 元数据文档的_id              |
        | n        | 块在文件中的相对位置         |
        | data     | 文件内容的base64的二进制数据 |

    - `fs.files`集合：存储元数据。每个文档表示1个文件
        ```mongodb
        db.fs.files.find()
        {
          _id: ObjectId("6559a3991fcfb0e85fa79901"),
          length: Long("13"),
          chunkSize: 261120,
          uploadDate: ISODate("2023-11-19T05:56:41.871Z"),
          filename: "/tmp/test',
          metadata: {}
        },
        ```

        | 字段       | 说明                         |
        |------------|------------------------------|
        | _id        | 唯一id                       |
        | length     | 文件内容的总字节数           |
        | chunkSize  | chunk的大小（默认255KB）     |
        | uploadDate | 文件存储进GridFS时间戳       |
        | md5        | 文件内容的校验和，服务端生成 |

        - 除了这些必须的字段。还可以自定义，如下载次数、MIME类型、用户评分

        ```mongodb
        // 获取唯一文件名列表
        db.fs.files.distinct("filename")
        ```

- `mongofiles`命令：archlinux需要安装`mongodb-tools-bin`aur包

    | mongodb-tools包的命令 |
    |-----------------------|
    | bsondump              |
    | mongodump             |
    | mongoexport           |
    | mongofiles            |
    | mongoimport           |
    | mongorestore          |
    | mongostat             |
    | mongotop              |

    ```sh
    echo 'hello, world' > /tmp/test.file

    // put将文件上传到GridFS
    mongofiles put /tmp/test.file

    // 查看所有文件
    mongofiles list

    // 将GridFS的文件下载到本地
    mongofiles get test.file

    // 搜索GridFS上的文件
    mongofiles search test.file

    // 删除GridFS上的文件
    mongofiles delete test.file
    ```

### GridFS索引

- `fs.chunks`集合的`files_id`和`n`的复合唯一索引
    - 虽然`files_id`的值相同，但`n`的值不同。所以符合复合唯一索引

    ```mongodb
    // 创建索引
    db.fs.chunks.createIndex( { files_id: 1, n: 1 }, { unique: true } );

    // 这样就可以使用索引查询
    db.fs.chunks.find( { files_id: myFileID } ).sort( { n: 1 } )
    ```

- `fs.files`集合的`filename`和`uploadDate`的复合索引

    ```mongodb
    // 创建索引
    db.fs.files.createIndex( { filename: 1, uploadDate: 1 } );

    // 这样就可以使用索引查询
    db.fs.files.find( { filename: myFileName } ).sort( { uploadDate: 1 } )
    ```

### GridFS分片

- GridFS将文件拆分成块（GridFS块）；分片将集合拆分成块（分片块）

- `fs.files`集合比`fs.chunks`集合小的多，可能不需要分片

- `fs.chunks`集合的字段`{"_id": 1}`和`{"files_id": 1, "n": 1}`都是升序键，不适合作为片键

- 在对`fs.chunks`集合的`files_id`创建哈希索引：那么每个文件都会在分片集群中随机分发，并且同一个文件始终被包含在单个分片块中。
    - 两全其美：写操作会均匀分发到所有分片；读操作只需要访问1个分片
    ```mongodb
    db.fs.chunks.ensureIndex({"files_id": "hashed"})
    sh.shardCollection("test.fs.chunks", {"files_id": "hashed"})
    ```

## 管理
### 数据块管理

- 手动分片：自己控制分发到哪里。需要关闭均衡器

    - 除非遇到特殊情况，否则应该使用自动分片而不是手动分片。

    - 不要在均衡器开启的情况下，进行手动分片

        - 如果同时使用存在的问题：
            - 有shardA和shardB两个分片，每个分片都有500个块。
            - shardA接受了大量的写操作，你决定关掉均衡器，并将30个最活跃的块移动到shardB。
            - 重新开启均衡器，它可能会将30个块（可能不是刚刚的30个）从shardB移动到shardA来平衡块
        - 两种解决方法：
            - 1.在开启均衡器之前，将30个不活跃的块，从shardB移动到shardA，这样分片之间就不会出现不均衡
            - 2.对shardA的块执行30次拆分

    ```mongodb
    // 关闭均衡器。如果均衡器正在迁移，则完成之前不会生效
    sh.stopBalancer()
    // 或者
    sh.setBalancerState(false)

    // 在输入上一条命令后，确认均衡器是否正在迁移。
    use config
    while(sh.isBalancerRunning()) {
        print("waiting...");
        sleep(1000);
    }
    ```

    ```mongodb
    // 关闭均衡器后，就可以手动迁移了。先查看数据块与分片的映射
    use crm
    db.chunks.find()

    // 迁移crm数据库的users集合的name: MaxKey()数据块到rs0
    sh.moveChunk("crm.users", {name: NumberLong("8345072417171006784")}, "rs0")

    // 如果这个块超过块的最大值，mongos会拒绝移动。需要使用splitAt命令手动拆分
    sh.splitAt("crm.users", {"name": NumberLong("7000000000000000000")})
    sh.moveChunk("crm.users", {name: NumberLong("8345072417171006784")}, "rs0")
    ```

- 修改块大小

    - 默认为128MB。允许的范围大小1到1024MB之间

    - 修改后，不会立即改变
        - 如果增加了块的大小：已经存在的块，通过插入或更新来增长，直到达到新大小
        - 如果减少了块的大小：则需要花费一些时间才能将所有块拆分为新的大小
            - 拆分操作是无法恢复的。

    - 如果迁移过于频繁或者使用的文档太大，则可能需要增加块的大小

    ```mongodb
    // 设置为64MB
    use config
    db.settings.updateOne(
       { _id: "chunksize" },
       { $set: { _id: "chunksize", value: 64 } },
       { upsert: true }
    )
    ```

- 超大块（jumbo chunk）：无法拆分和无法移动的块

    - 如果选择了`date`作为片键。则mongos每天最多只能创建1个块。
        - 无法拆分：假设有一天的数据量比其他任何一天都要多，但这个块不能拆分，因为片键值是相同的
        - 无法移动：而且如果这个块大于`config.settings`中最大块的大小时，均衡器将无法移动

        ```mongodb
        // 超大块会被标记为jumbo标志
        sh.status()
        ```

    - 假设有3个分片shard1、shard2、shard3。写操作都分发到shard1（热点分片），均衡器只能移动非超大块，所以它只会将较小的块从热点分片移走

        - shard1上会有越来越多的超大块，即使3个分片之间的块数量完全均衡，但shard1的填充速度会比其他2个分片要快

    - 使用`dataSize`命令查看块大小。`dataSize`必须扫描整个块的数据确定它的大小

        ```mongodb
        // 查找块的范围
        use config
        var chunks = db.chunks.find({"ns": "crm.users",}).toArray()

        use crm
        db.runCommand({"dataSize", "users",
            "keyPattern": {"data": 1}, // 片键
            "min": chunks[0].min,
            "max": chunks[0].max}
            })
        ```

    - 手动移动超大块
        ```mongodb
        // 关闭均衡器
        sh.setBalancerState(false)

        // mongodb不允许移动超过最大块大小的块。调大块的大小，这里为10000MB
        db.settings.updateOne(
           { _id: "chunksize" },
           { $set: { _id: "chunksize", value: 10000 } },
           { upsert: true }
        )

        // 假设crm.users的NumberLong("8345072417171006784")为超大块，移动到rs0
        sh.moveChunk("crm.users", {name: NumberLong("8345072417171006784")}, "rs0")

        // 在crm数据库的分片rs1上执行splitChunk，直到块数量与rs0大致相同

        // 设置为原来的大小。mongodb7.0默认为128MB
        db.settings.updateOne(
           { _id: "chunksize" },
           { $set: { _id: "chunksize", value: 128 } },
           { upsert: true }
        )

        // 开启均衡器
        sh.setBalancerState(true)
        ```
### 文档、集合、数据库

- 查看文档的存储在mongodb的大小

    ```mongodb
    bsonsize({_id:ObjectId()})
    bsonsize({_id:""+ObjectId()})

    // 查看文档大小
    bsonsize(db.users.findOne())
    ```

- 查看集合信息
    ```mongodb
    db.users.stats()
    ```

- 查看数据库信息

    - `fsUsedSize`：mongodb实例存储数据，所占用文件系统的磁盘总量
    - `dataSize`：数据库未压缩数据的大小。因为WiredTiger通常会被压缩。这个值不等于`storageSize`
    - `indexSize`：索引所占的空间

    ```mongodb
    db.stats()
    ```

### 操作查询

- 查看数据库正在执行的操作列表

    | db.currentOp()重要的字段      | 说明                                                                                                                                                                         |
    |-------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
    | opid                          | 该操作的唯一标识                                                                                                                                                             |
    | active                        | 操作是否正在运行。false表示操作等待其他操作的让出锁                                                                                                                          |
    | op                            | 操作类型通常为query、insert、update、remove                                                                                                                                  |
    | desc                          | 客户端的标识符。与日志的消息相连。与连接相关的每个日志消息都已`conn3`作为前缀，可以用它来筛选日志                                                                            |
    | locks                         | 锁的类型                                                                                                                                                                     |
    | waitingForLock                | 当前是否处于阻塞，等待获取锁                                                                                                                                                 |
    | numYields                     | 释放锁允许其他操作进行的次数。搜索文档（查询、更新和删除）可能会让出锁。一个操作在有其他操作进入队列并等待锁时，才会让出。如果没有处于waitingForLock状态，当前操作不会让出锁 |
    | lockStats.timeAcquiringMicros | 获取锁花费的时间                                                                                                                                                             |

    ```mongodb
    // 查看数据库正在执行的操作列表
    db.currentOp()

    // 慢操作。返回在db1数据库执行，并且超过3秒的操作
    db.currentOp(
       {
         "active" : true,
         "secs_running" : { "$gt" : 3 },
         "ns" : /^db1\./
       }
    )

    // 返回在等待锁的写入操作
    db.currentOp(
       {
         "waitingForLock" : true,
         $or: [
            { "op" : { "$in" : [ "insert", "update", "remove" ] } },
            { "command.findandmodify": { $exists: true } }
        ]
       }
    )

    // 返回active为true，并且没有让出锁的操作
    db.currentOp(
       {
         "active" : true,
         "numYields" : 0,
         "waitingForLock" : false
       }
    )

    // 正在创建索引的操作
    db.adminCommand(
        {
          currentOp: true,
          $or: [
            { op: "command", "command.createIndexes": { $exists: true }  },
            { op: "none", "msg" : /^Index Build/ }
          ]
        }
    )
    ```


    - 停止指定操作
        - 并不是所有操作都能停止：
            - 1.只有操作让出时，才能停止（更新、查找、删除）
            - 2.等待锁的操作不能被停止

        - 在查询耗时过长的操作时，可能会看到一些长时间运行的内部操作。
            - 这其中最常见的是复制线程（同步源获取更多操作）和分片的回写监听器。这些操作被停止了，mongodb会重新启动它们。
                - 停止复制线程：复制操作会短暂的停止
                - 停止回写监听器：可能会导致mongos遗漏正常的写入错误

        - 防止幻象写入操作：如果写操作比mongodb的处理速度要快，写操作就会堆积在操作系统的套接字缓冲区。
            - 问题：用户停止mongodb正在进行的写操作时，还会处理剩下的缓冲区的写操作。即使客户端已经没有发送写操作。
            - 解决方法：执行写入确认机制：让每次写入操作都等待，直到前一个写操作完成；而不是仅仅等到前一个写操作处于缓冲区就开始写一次写入。


        ```mongodb
        // 停止指定操作。db.currentOp()的查询操作字段opid作为参数
        db.killOp(18708)
        ```

- 系统分析器（默认关闭）：分析慢操作，代价是影响性能

    - 开启分析器后：每一条读写操作都会记录system数据库的profile集合
        - 每次写入都要花费额外的写入时间
        - 每次读都要等待写锁（因为必须在system.profile写入一条记录）

    ```mongodb
    // 查看当前分析器的设置
    db.getProfilingStatus()

    // 关闭分析器
    db.setProfilingLevel(0)

    // 开启分析器。指定级别为1，默认记录耗时超过100毫秒的信息
    db.setProfilingLevel(1)
    // 只记录超过500毫秒的所有操作
    db.setProfilingLevel(1, 500)
    // 只记录超过2000毫秒的查询操作
    db.setProfilingLevel( 1, { filter: { op: "query", millis: { $gt: 2000 } } } )
    // 清除filter字段的设置
    db.setProfilingLevel( 1, { filter: "unset" } )

    // 开启分析器。指定级别为2，也就是记录所有信息。
    db.setProfilingLevel(2)

    // 执行一些操作
    db.foo.insert({x:1})
    db.foo.update({}, {$set: {x:2}})
    db.foo.remove({})

    // 查看分析器
    db.system.profile.find()
    ```

### 日志和持久性

- 日志级别
    ```sh
    # --logpath将日志发送到文件，而不是输出到前台
    mongod --logpath
    // 或者
    db.adminCommand({"logRotate": 1})
    ```

    ```mongodb
    // 设置日志的值，默认为0。范围0-5
    db.adminCommand({"setParameter": 1 "logLevel": 3})
    // 查看日志的值
    db.adminCommand({getParameter: 1, logLevel: 1})

    // 这里设置默认日志设置为1，查询组件的日志级别为2
    db.adminCommand({"setParameter": 1, logComponentVerbosity: { verboseity:1, query: { verbosity: 2 }}})
    ```

- mongodb同时维护日志和数据库数据文件的内存视图。默认情况下

    - 日志条目：每50毫秒刷新到磁盘

        ```mongodb
        // --journalCommitInterval设置日志刷新间隔。范围1-500毫秒
        mongod --journalCommitInterval 25 --config ~/mongodb/mongodb.conf &
        ```
    - 数据库文件：每60毫秒刷新到磁盘。这个60秒间隔叫检查点（checkpoint）
    - 如果服务器突然停止，重新启动后，可以使用日志重放在关闭前没有刷新到磁盘的所有写操作

- 日志文件：mongodb在`dbPath`目录创建名为journal的子目录。WiredTiger的日志文件的名称格式为`WiredTigerLog.0000000020`大小为100MB。超过后会创建新的日志文件。

    - 由于日志文件只需在上次检查点之后恢复数据，因此在新的检查点写入完成时，mongodb会自动删除“旧的”日志文件
        - 如果服务器崩溃（或kill -9）。mongod重启时会重放日志文件。可能会丢失的写操作的最大范围是：最近100毫秒+日志刷新到磁盘的时间内发生的写操作

    ```sh
    # mongodb7.0。初始启动mongodb时便会创建3个100MB的日志文件
    ll journal
    .rw------- 1 100Mi tz tz  9 Dec 13:29 -I WiredTigerLog.0000000020
    .rw------- 1 100Mi tz tz  9 Dec 13:21 -I WiredTigerPreplog.0000000001
    .rw------- 1 100Mi tz tz  9 Dec 13:21 -I WiredTigerPreplog.0000000002
    ```


- 问题：从节点数据可能会落后主节点，导致读取到的数据是几秒、几分钟、几小时之前的

    - `writeConcern`写关注：

        ```mongodb
        // 副本集写操作需要写入majority（大多数成员），如果在100毫秒内没有复制到大多数成员，则返回错误
        try {
            db.users.insertOne(
                {"_id": 10, "name": "joe"},
                { writeConcern: {"w": "majority", "wtimeout": 100}}
            );
        } catch (e) {
            print(e)
        }

        // j 表示日志也要写入
        try {
            db.users.insertOne(
                {"_id": 10, "name": "joe"},
                { writeConcern: {"w": "majority", "wtimeout": 100, "j": true}}
            );
        } catch (e) {
            print(e)
        }
        ```

    - `readConcern`读关注：可以设置在写操作被持久化之前就看到写入的结果。

        - 不要将`readConcern`读关注和读偏好（read preference)混淆，后者处理从何处读取数据的问题。
        - 和写`writeConcern`写关注一样，需要权衡性能的影响

        | 值            | 说明                             |
        |---------------|----------------------------------|
        | local（默认） | 返回的数据，不确保写入大多数成员 |
        | linearizable  | 返回的数据，确保写入大多数成员   |
        | majority      | 可以避免读取过时数据             |
        | available     |                                  |
        | snapshot      |                                  |

- mongodb不能保证什么？
    - 硬盘和文件系统错误
    - 一些较便宜和旧的硬盘，在写操作排队等待时（而不是在实际写入后）就会报告写入成功。mongodb无法防止这个级别的数据丢失

- 检查数据损坏
    ```mongodb
    // 检查users集合是否有损坏。valid如果true，则没有数据损坏
    db.users.validate({full: true})
    ```

## WiredTiger存储引擎

- 默认会对集合和索引启用压缩。算法是google的snappy。还可以选择facebook的zstd和zlib。或者选择不压缩

- 文档级别：允许并发多个客户端的更新操作，对集合中的不同文档同时进行更新
    - WiredTiger使用多版本并发控制（MVCC）来隔离读写操作

```mongodb
// 查看集合详细信息
db.users.stats()
//省略
uri: 'statistics:table:collection-2--5575423204468368826',
//省略

# 集合对应的文件
ll | grep '5575423204468368826'
.rw-------  1  36Ki tz tz 10 Dec 11:07 -I collection-2--5575423204468368826.wt
.rw-------  1  36Ki tz tz 10 Dec 11:07 -I index-3--5575423204468368826.wt
```

## 安全事项

- `$where`：可以在查询中执行javascript代码
    - 为了安全起见，应该严格限制，禁止终端用户随意使用`$where`

## 监控的指标

### 副本集

- `rs.status()`：查看状态

    | 最有用的字段  | 说明                                                                                            |
    |---------------|-------------------------------------------------------------------------------------------------|
    | self          | 属于那个副本集成员                                                                              |
    | stateStr      | 副本集状态（PRIMARY、SECONDRAY等）                                                              |
    | uptime        | 启动时间（单位：秒）                                                                            |
    | optimeDate    | 每个成员的oplog中最后一个操作发生的时间（由于有心跳机制可能会慢几秒）                           |
    | lastHeartbeat | 最后一次受到来自"self"这个成员的心跳时间。如果出现网络故障或服务器过载，这个时间可能是两秒之前 |
    | pingMs        | 心跳达到此服务器的平均时间                                                                      |
    | errmsg        | 不是错误信息。是成员在心跳请求中选择返回的状态信息                                              |

- 从节点上运行`rs.status().syncSourceHost`：可以查看复制源

```mongodb
// oplog大小和可以包含的多少时间的操作
rs.printReplicationInfo()

// 获取每个成员的syncTo值，以及最后一条oplog被写入从节点的时间
rs.printSecondaryReplicationInfo()
```

## 命令行工具

### 监控

#### mongodb自带的

```mongodb
// 显示具体数据库的统计信息
use test
db.stats()

// 显示实例的统计信息。可以是mongod和mongos
db.serverStatus()

// 实例的连接数
db.serverStatus().connections

// 实例的内存
db.serverStatus().mem

// 实例的WiredTiger存储引擎的cache信息
db.serverStatus().wiredTiger.cache

// 实例的锁
db.serverStatus().globalLock

// 实例的锁详细信息
db.serverStatus().locks
```

#### mongodb-compass（官方的gui工具）

- 和`mongostat`、`mongotop`工具返回的指标信息是一致的
![avatar](./Pictures/mongodb/mongodb-compass_Databases.avif)
![avatar](./Pictures/mongodb/mongodb-compass_Collections.avif)
![avatar](./Pictures/mongodb/mongodb-compass_Performance.avif)

#### mongotop

```sh
mongotop
                    ns    total    read    write    2023-11-22T00:27:05+08:00
        admin.atlascli      0ms     0ms      0ms
  admin.system.version      0ms     0ms      0ms
config.system.sessions      0ms     0ms      0ms
   config.transactions      0ms     0ms      0ms
  local.system.replset      0ms     0ms      0ms
          test.account      0ms     0ms      0ms
         test.account1      0ms     0ms      0ms
        test.analytics      0ms     0ms      0ms
       test.blog.posts      0ms     0ms      0ms
                test.c      0ms     0ms      0ms

# 获取每个数据库锁的信息
mongotop --locks
```

#### mongostat：每秒打印统计信息

| 重要的字段     | 说明                                                                             |
|----------------|----------------------------------------------------------------------------------|
| flushes        | mongod将数据刷新到磁盘的次数                                                     |
| vsize          | mongod虚拟内存数量。大约是数据目录大小的两倍（1倍用于映射文件，1被用于记录日志） |
| res            | mongod正在使用的内存数量。                                                       |
| used           | WiredTiger cache 的占比                                                          |
| qr和qw         | 读操作和写操作的队列大小（有多少个读和写操作正处于阻塞中，等待被处理             |
| ar和qw         | 有多少个正在执行读操作和写操作的客户端                                           |
| netIn和 netOut | 传入和传出的网络字节数                                                           |
| conn           | 连接数（包括传入和传出）                                                         |
| time           | 进行这些统计所花费的时间                                                         |

```sh
mongostat
insert query update delete getmore command dirty used flushes vsize  res qrw arw net_in net_out conn                time
    *0    *0     *0     *0       0     0|0  0.0% 0.4%       0 2.64G 243M 0|0 0|0   111b   69.5k   11 Nov 22 00:26:35.626
    *0    *0     *0     *0       0     1|0  0.0% 0.4%       0 2.64G 243M 0|0 0|0   112b   69.5k   11 Nov 22 00:26:36.626

# 把副本集和分片中的每个mongod进行输出
# 连接单个副本集
mongostat --discover --port 27017
# 连接mongos，对所有副本集分片
mongostat --discover --port 47017

# -O 添加更多的字段host,version，并把network.numRequests自定义名字为network requests
mongostat -O='host,version,network.numRequests=network requests'

# -o 自定义所有字段
mongostat -o='host,opcounters.insert.rate()=Insert Rate,\
    opcounters.query.rate()=Query Rate,\
    opcounters.command.rate()=Command Rate,\
    wiredTiger.cache.pages requested from the cache=Pages Req,\
    metrics.document.inserted=inserted rate'
```

### mongoimport和mongoexport导入和导出

- 导出工具`mongoexport`：可以将集合中的每一条BSON文档，导出JSON和CSV文件

    ```mongosh
    // 插入测试文档
    db.users.insertMany([
        {"_id": 0 , "name": "joe", "age": 10},
        {"_id": 1 , "name": "john", "age": 20},
    ])
    ```

    ```sh
    # 导出json文件
    mongoexport --host=127.0.0.1 --port=27017 --db=test --collection=users --out=users.json

    cat users.json
    {"_id":0,"name":"joe","age":10}
    {"_id":1,"name":"john","age":20}

    # 导出csv文件。并指定导出的字段只有name和age
    mongoexport --host=127.0.0.1 --port=27017 --db=test --collection=users --type=csv --fields=name,age --out=users.csv

    cat users.csv
    name,age
    joe,10
    john,20

    # 导出csv文件。noHeaderLine不导出字段
    mongoexport --host=127.0.0.1 --port=27017 --db=test --collection=users --type=csv --fields=name,age --noHeaderLine --out=users-noHeaderLine.csv

    cat users-noHeaderLine.csv
    joe,10
    john,20

    # 导出json文件。--query匹配age大于等于20的文档
    mongoexport --host=127.0.0.1 --port=27017 --db=test --collection=users --query='{"age":{"$gte": 20}}' --out=users-query.json

    cat users-query.json
    {"_id":1,"name":"john","age":20}

    # 导出csv文件。--query匹配age大于等于20的文档
    mongoexport --host=127.0.0.1 --port=27017 --db=test --collection=users --type=csv --fields=name,age  --query='{"age":{"$gte": 20}}' --out=users-query.csv

    cat users-query.csv
    name,age
    john,20
    ```

    - 以上命令都是在主节点（Primary）上导出，`readPreference`参数指定从节点（Secondray）导出

        ```sh
        // 从节点（Secondray）导出
        mongoexport --host=127.0.0.1 --port=27017 --db=test --collection=users --readPreference=secondary --out=users.json
        ```

- 导入工具5999999mongoimport`：支持JSON、CSV、TSV（Tab键分隔字段的文本文件，一般用于关系型数据库和mongodb之间的中间格式）

    ```mongodb
    // 导入json
    mongoimport --host=127.0.0.1 --port=27017 --db=test --collection=users --file=users.json

    // 导入csv。headerline为添加第一行的集合字段
    mongoimport --host=127.0.0.1 --port=27017 --db=test --collection=users --type=csv --headerline --file=users.csv

    // 导入tsv
    mongoimport --host=127.0.0.1 --port=27017 --db=test --collection=users --type=csv --headerline --file=users.tsv

    - `--mode=upsert`替换有重复值的的文档。
    ```mongodb
    # 插入测试文档
    db.account.insertOne({"_id": 1, "name": "joe", "balance": 1})
    db.account1.insertOne({"name": "Liu", "balance": 1})

    # 生成2个测试的json文件
    cat > /tmp/account.json << EOF
    { "_id": 1, "name": "Deng", "balance": 19999999}
    { "_id": 10, "name": "Peng", "balance": 5999999}
    EOF

    cat > /tmp/account1.json << EOF
    { "name": "Liu", "balance": 19999999}
    { "name": "Bruce", "balance": 5999999}
    EOF
    ```

    ```mongodb
    // 导入刚才生成的json。由于有重复的{"_id": 1}因此{"_id": 1, "name": "joe", "balance": 1}会被替换
    mongoimport --host=127.0.0.1 --port=27017 --db=test --collection=account --mode=upsert --file=/tmp/account.json
    // 导入刚才生成的json。指定替换的字段为name
    mongoimport --host=127.0.0.1 --port=27017 --db=test --collection=account1 --mode=upsert --upsertFields=name --file=/tmp/account1.json
    ```

### mongodump和mongorestore备份和恢复

- `mongoimport`和`mongoexport`针对的是文本文件；而`mongodump`和`mongorestore`针对的是二进制文件

- 除了主从备份，还可以利用`mongodump`和`mongorestore`开发一些自动备份的脚本

- 备份工具`mongodump`：每个集合会导出1个bson文件和1个json文件

    ```sh
    # 备份test数据库
    mongodump --host=127.0.0.1 --port=27017 --db=test --out=dump

    # 查看备份目录下的文件
    ls dump/test
    account.bson
    account.metadata.json
    account1.bson
    account1.metadata.json
    analytics.bson
    analytics.metadata.json

    # 以archive文件备份。只会生成单个文件
    mongodump --archive=test.20231122.archive --db=test

    # 以archive文件备份。只会生成单个文件，并使用gz压缩
    mongodump --archive=test.20231122.gz --gzip --db=test
    ```

- 恢复工具`mongorestore`

    ```mongodb
    // 删除当前整个数据库
    db.dropDatabase()
    ```

    ```sh
    # 恢复整个数据库。对每一个集合先读取元数据文件，再恢复文件，最后重建该集合的索引
    mongorestore --host=127.0.0.1 --port=27017 ./dump/

    # --drop只恢复不存在的（被删除的）集合
    mongorestore --host=127.0.0.1 --port=27017 --drop ./dump/

    # 只恢复指定集合。--nsInclude=数据库名.集合名
    mongorestore --host=127.0.0.1 --port=27017 --nsInclude=test.account ./dump/

    # --archive恢复archive文件
    mongorestore --host=127.0.0.1 --port=27017 --archive=test.20231122.archive

    # --gzip恢复archive的gz文件
    mongorestore --host=127.0.0.1 --port=27017 --gzip --archive=test.20231122.gz

    # 以archive文件复制一个新数据库newtest
    mongorestore --host=127.0.0.1 --port=27017 --archive=test.20231122.archive --nsFrom='test.*' --nsTo='newtest.*'
    # 打开mongosh，切换数据库
    use newtest
    ```
### mtool

```sh
# 安装mtools
pip3 install mtools pymongo
```

# reference

- [官方文档的gptai](https://www.mongodb.com/docs/)
- [官方文档](https://www.mongodb.com/docs/manual/)

# 第三方 mongodb 软件

- [awesome-mongodb](https://github.com/ramnes/awesome-mongodb)

- [FerretDB](https://github.com/FerretDB/FerretDB)
    - 底层采用 PostgreSQL 作为存储引擎，用 Go 语言实现了 MongoDB 协议

- server（服务端）
    - [MongoShake：集群复制](https://github.com/alibaba/MongoShake)

- client(客户端)

    - [MongoDB Compass：官方gui](https://github.com/mongodb-js/compass)

        ![avatar](./Pictures/mongodb/mongodb-compass.avif)

    - [mongoku: web client](https://github.com/huggingface/Mongoku)

