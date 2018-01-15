select Material.Id as Material_Id,Materiel.Price as Price,
       Materiel.State as State,Materiel_Main.Caption as Caption
from Material_Org inner join Materiel on Material_Org.Material_Id = Materiel.Id
     inner join Materiel_Main on Materiel.Material_Main_Id = Materiel_Main.Id
where Org_Id = 1 and Version = 0