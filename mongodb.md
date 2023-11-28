# mongodb

# 基本概念

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

## mongosh

- mongosh是一个功能齐全的javascript解释器，并且包含了一些扩展语法（语法糖）

### 基本命令

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
db.dropDatabase()
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

## 安全事项

- `$where`：可以在查询中执行javascript代码
    - 为了安全起见，应该严格限制，禁止终端用户随意使用`$where`

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

### mongodb-compass（官方的gui工具）

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
```

#### mongostat

```sh
mongostat
insert query update delete getmore command dirty used flushes vsize  res qrw arw net_in net_out conn                time
    *0    *0     *0     *0       0     0|0  0.0% 0.4%       0 2.64G 243M 0|0 0|0   111b   69.5k   11 Nov 22 00:26:35.626
    *0    *0     *0     *0       0     1|0  0.0% 0.4%       0 2.64G 243M 0|0 0|0   112b   69.5k   11 Nov 22 00:26:36.626
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

# reference

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

