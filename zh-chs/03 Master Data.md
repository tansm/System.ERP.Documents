# 基础资料：版本控制
## 基础
以物料为实例，这是最简单的版本。

| Table： materiel                             | 数据类型 |
|----------------------------------------------|----------|
| 唯一主键 | int  |
| 名称 | nvarchar(64) |
| 参考售价 | decimal |
| 状态，例如已审核是0=草稿， 1=已审核，2 = 关闭， | int |
|


## 引入版本 时间维度
现在遇到一个现实问题：正在使用的一个物料（已经审核），如果需要修改怎么办？如果我反审核去修改价格，那么意味着这个物料就不能使用了，而新价格审批下来还需要一段时间。

走工作流表单，需要独立出一个结构完全相同的表，现在加入版本，表结构如下：
| Table： materiel                             | 数据类型 |
|----------------------------------------------|----------|
| 唯一主键 | int  |
| 名称 | nvarchar(64) |
| 最新版本号对应的主键，指向materiel_version | int |
|

我们将具体的属性存放到版本的表，用于区分不同时期或新增尚未审核的数据。

| Table： materiel_version                     | 数据类型 |
|----------------------------------------------|----------|
| 唯一主键 | int  |
| 物料的主键，指向materiel | int |
| 版本号，从1,2,3这样顺序编写。 | short |
| 参考售价 | decimal |
| 状态，例如已审核是0=草稿， 1=已审核，2 = 关闭， | int |
|

## 基础资料是依附在某个主体的观点 主体维度
刚才我们认识到，不同时期，对于同一个物料的属性是变化的，现在，我们放大到一个大型连锁超市，那么对于同一个物料，其不同组织对价格的值是不同的。也就是变化的维度不仅在时间上，还是主体上。

事实上，之前简单的模型中，认为某个某个物料的价格是多少，是你（唯一的组织）所表达的观点，在大型集团下，我们可以理解成，基础资料的属性其实是某个主体的观点。

原来的主表删掉最新版本号的功能，因为那个是组织上的数据。
| Table： materiel                             | 数据类型 |
|----------------------------------------------|----------|
| 唯一主键 | int  |
| 名称 | nvarchar(64) |
|

版本表没有任何编号，这里就不重复了。我们新增了组织与物料的分配表
| Table： materiel_org                         | 数据类型 |
|----------------------------------------------|----------|
| 唯一主键 | int  |
| 组织的编号，指向org | int |
| 最新版本号对应的主键，指向materiel_version | int |
|

在集团的情况下，某个上级组织可以建立一个隶属于自己组织的物料，即创建了一个版本，然后发布到多个组织下，我们仅仅复制materiel_org的记录，指向同一个版本。

当某个组织需要修改这些信息时，即创建他自己的版本，我们就复制这个版本，然后指向这个新版本，在这个新版本上修改。

