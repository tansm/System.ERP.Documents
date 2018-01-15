CREATE TABLE [dbo].[Material_Org]
(
	[Id] INT NOT NULL PRIMARY KEY,
	[Org_Id] INT NOT NULL,
	[Material_Id] INT NOT NULL,
	[Version] smallint NOT NULL DEFAULT 0
)
