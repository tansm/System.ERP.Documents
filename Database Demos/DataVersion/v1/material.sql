CREATE TABLE [dbo].[Materiel]
(
	[Id] INT NOT NULL PRIMARY KEY, 
	[Materiel_Main_Id] INT NOT NULL,
	[Version] SMALLINT NOT NULL Default 0,
    [Price] DECIMAL(18, 6) NULL, 
    [State] TINYINT NULL
)
