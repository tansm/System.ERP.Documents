## 版本控制
数据是变化的，这里我谈谈版本的控制。

### 基础
以物料为实例，这是最简单的版本。

| Table： materiel                             | 数据类型 |
|----------------------------------------------|----------|
| 唯一主键 | int  |
| 名称 | nvarchar(50) |
| 参考售价 | decimal |
| 状态，例如已审核是0=草稿， 1=已审核，2 = 关闭， | int |

```sql
CREATE TABLE [dbo].[Materiel]
(
    [Id] INT NOT NULL PRIMARY KEY, 
    [Caption] NVARCHAR(50) NOT NULL, 
    [Price] DECIMAL(18, 6) NULL, 
    [State] TINYINT NULL
)
```

### 引入版本 时间维度
现在遇到一个现实问题：正在使用的一个物料（已经审核），如果需要修改怎么办？如果我反审核去修改价格，那么意味着这个物料就不能使用了，而新价格审批下来还需要一段时间。

走工作流表单，需要独立出一个结构完全相同的表，现在加入版本，将原有的数据提取出一个总表，表结构如下：

| Table： materiel_main                        | 数据类型 |
|----------------------------------------------|----------|
| 唯一主键 | int  |
| 名称 | nvarchar(50) |

```sql
CREATE TABLE [dbo].[Materiel_Main]
(
    [Id] INT NOT NULL PRIMARY KEY, 
    [Caption] NVARCHAR(50) NOT NULL, 
)
```

原始的表增加了版本号，用于区分不同时期或新增尚未审核的数据,版本为0是特殊的版本号，表示最新的版本。所以同一个物料会存在多笔记录。

| Table： materiel                             | 数据类型 |
|----------------------------------------------|----------|
| 唯一主键 | int  |
| 物料的主键，指向materiel_main | int |
| 版本号，从0,1,2,3这样顺序编写。 | smallint |
| 参考售价 | decimal |
| 状态，例如已审核是0=草稿， 1=已审核，2 = 关闭， | int |

```sql
CREATE TABLE [dbo].[Materiel]
(
    [Id] INT NOT NULL PRIMARY KEY, 
    [Materiel_Main_Id] INT NOT NULL,
    [Version] SMALLINT NOT NULL Default 0,
    [Price] DECIMAL(18, 6) NULL, 
    [State] TINYINT NULL
)
```

### 基础资料属性是依附在某个主体的观点 视角维度
刚才我们认识到，不同时期，对于同一个物料的属性是变化的，现在，我们放大到一个大型连锁超市，那么对于同一个物料，其不同组织对价格的值是不同的。也就是变化的维度不仅在时间上，还是主体视角上。

事实上，之前简单的模型中，认为某个某个物料的价格是多少，是你（唯一的组织）所表达的观点，在大型集团下，我们可以理解成，基础资料的属性其实是某个主体的观点。

materiel_main表没有任何变化，这里就不重复了。我们新增了组织与物料的分配表

| Table： materiel_org                         | 数据类型 |
|----------------------------------------------|----------|
| 唯一主键 | int  |
| 组织的编号，指向org | int |
| 物料编号，指向material | int |
| 版本号,0是最新版本，之后的版本顺序累加 | smallint |

```sql
CREATE TABLE [dbo].[Material_Org]
(
	[Id] INT NOT NULL PRIMARY KEY,
	[Org_Id] INT NOT NULL,
	[Material_Id] INT NOT NULL,
	[Version] smallint NOT NULL DEFAULT 0
)
```

原有的物料表，我们砍掉了版本，移动到materiel_org表中，但增加了所有者组织。
```sql
CREATE TABLE [dbo].[Materiel]
(
    [Id] INT NOT NULL PRIMARY KEY, 
    [Material_Main_Id] INT NOT NULL,
    [Owner_Org_Id] INT NOT NULL,
    [Price] DECIMAL(18, 6) NULL, 
    [State] TINYINT NULL
)
```

### 主数据分配
在集团的情况下，某个上级组织可以建立一个隶属于自己组织的物料，即创建了一个版本，然后发布到多个组织下，我们仅仅复制materiel_org的记录，指向同一个版本的记录。

当某个组织需要修改这些信息时，即创建他自己的版本，我们就复制这个版本，然后指向这个新版本，在这个新版本上修改。

要查询某个组织的所有最新版本的物料，其sql是：
```sql
select Material.Id as Material_Id,Materiel.Price as Price,
       Materiel.State as State,Materiel_Main.Caption as Caption
from Material_Org inner join Materiel on Material_Org.Material_Id = Materiel.Id
     inner join Materiel_Main on Materiel.Material_Main_Id = Materiel_Main.Id
where Org_Id = 1 and Version = 0
```

### 使用
在业务单据需要使用物料时，其指向的是特定的版本，即Materiel表，意思是业务的发生针对的是特定版本的物料属性。

todo:那么如果采购订单 预定了某个特定版本的 物料，那么采购入库单 入库时，其最新的物料版本已经变化了，怎么办？

todo:如果处理仓库的统计统计，仓库存储时是存储不同的版本吗？
