CREATE TABLE [dbo].[Materiel]
(
	[Id] INT NOT NULL PRIMARY KEY, 
	[Material_Main_Id] INT NOT NULL,
	[Owner_Org_Id] INT NOT NULL,
    [Price] DECIMAL(18, 6) NULL, 
    [State] TINYINT NULL
)
