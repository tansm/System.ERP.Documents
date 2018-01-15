CREATE TABLE [dbo].[Materiel]
(
	[Id] INT NOT NULL PRIMARY KEY, 
    [Caption] NVARCHAR(50) NOT NULL, 
    [Price] DECIMAL(18, 6) NULL, 
    [State] TINYINT NULL
)
