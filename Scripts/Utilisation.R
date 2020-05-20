# -------- INSEE --------
## Mise à jour coefficient de transformation euros constants
library(rvest)
library(dplyr)

MAJ_INSEEpa <- function(){
  data(INSEEpa)
  h <- read_html("https://www.insee.fr/fr/statistiques/serie/ajax/010605954") # lit la page web de l'INSEE avec les données 
  PA <- html_node(h,"table") %>%  html_table() # récupère les coefficients sous forme de tableau directement de la page web
  
  new <- PA %>% 
    mutate(Valeur = str_replace(Valeur, ",", ".")) %>% 
    filter(Année == max(Année)) %>% 
    mutate(Monnaie = 1) %>% 
    rename(Infla = Valeur)
  INSEEpa <- rbind(INSEEpa, new) %>% 
    mutate(Infla =as.numeric(Infla))
  
  usethis::use_data(INSEEpa, overwrite = T)
}

# ------ Prix variables ------
# Mise à jour mercuriale de prix variables
# df : data.frame des nouveaux prix de la forêt privée tels qu'écrits dans la revue (noms colonnes : Année, Essence, Dim, PUmin, PUmax)
MAJ_PUvar <- function(df){
  data(PUvar)
  data(ParamFP)
  data(PUafi)
  
  Nouveau = df %>% 
    left_join(ParamFP$Dim, by="Dim") %>% 
    select(Année, Essence, Classe, Pumin, Pumax) %>% 
    right_join(ParamFP$Qual,by = "Essence")
  
  # Calcul PU par essence  
  Chene = Nouveau %>% 
    filter(Ess == "Chêne") %>% 
    mutate(PU = ifelse(Qual %in% c("A","B","C"),(Pumin + Pumax)/2, ((Pumin + Pumax)/2)/2))  %>% 
    dplyr::select(Année, Ess, Classe, Qual, PU)
  
  # Frene et Hetre
  Frehe = Nouveau %>% 
    filter(Ess == "Frêne" | Ess == "Hêtre")  %>% 
    mutate(PU = ifelse(Qual == "A", Pumax, 
                       ifelse(Qual == "B", Pumin,
                              ifelse(Qual == "C",(Pumin + Pumax)/2,((Pumin + Pumax)/2)/2))))  %>% 
    select(Année, Ess, Classe, Qual, PU)
  
  # Pin sylvestre
  PSyl = Nouveau %>% 
    filter(Ess == "Pin S") %>% 
    mutate(PU = ifelse(Qual == "A", Pumax, ifelse(Qual == "B", Pumin, ifelse(Qual == "C", Pumax, ifelse(Qual == "D", Pumin, NA))))) %>% 
    select(Année, Ess, Classe, Qual, PU)  
  
  # Résineux autres que épicéa, sapin et pin sylvestre
  Résineux = Nouveau %>% 
    filter(Ess %in% c("Pin M", "Pin N", "Douglas", "Mélèze", "Pin L","Aulne","Bouleau")) %>% 
    mutate(PU = ifelse(Qual %in% c("A","B"), Pumax, ifelse(Qual == "C", Pumin,Pumin/2))) %>% 
    select(Année, Ess, Classe, Qual, PU)
  
  # Autres feuillus 
  Feuil = Nouveau %>% 
    filter(Ess %in% c("Charme","Erable C","Châtaignier","Merisier","Tilleul","Orme","Platane","Tremble","Erable S","Erable P")) %>% 
    mutate(PU = ifelse(Qual == "A", Pumax, ifelse(Qual == "B", Pumin,
                                                  ifelse(Qual == "C", Pumin/2,(Pumin/2)/2)))) %>% 
    select(Année, Ess, Classe, Qual, PU)
  
  # Peuplier
  Peu = Nouveau %>% 
    filter(Ess == "Peuplier") %>% 
    mutate(PU = ifelse(Qual %in% c("A","B"), Pumax, ifelse(Qual == "C", Pumin, ifelse(Qual == "D",(Pumin + Pumax)/2, NA)))) %>% 
    select(Année, Ess, Classe, Qual, PU)  
  
  # Epicea, sapin 
  Epc = Nouveau %>% 
    filter(Ess == "Epicéa C") %>% 
    mutate(PU = ifelse(Qual %in% c("A","B"), Pumax, ifelse(Qual == "C",Pumin,Pumin*(1-0.6)))) %>% 
    select(Année, Ess, Classe, Qual, PU)
  Sap = Nouveau %>% 
    filter(Ess == "Sapin P") %>% 
    mutate(PU = ifelse(Qual %in% c("A","B"), (1-0.1)*Pumax, ifelse(Qual == "C", (1-0.1)*Pumin,((1-0.1)*Pumin)*(1-0.6)))) %>% 
    select(Année, Ess, Classe, Qual, PU)
  
  Nouveau = Chene %>% 
    full_join(Frehe, by = c("Année", "Classe", "Ess", "Qual", "PU")) %>% 
    full_join(PSyl, by = c("Année", "Classe", "Ess", "Qual", "PU")) %>% 
    full_join(Résineux, by = c("Année", "Classe", "Ess", "Qual", "PU")) %>% 
    full_join(Feuil, by = c("Année", "Classe", "Ess", "Qual", "PU")) %>% 
    full_join(Peu, by = c("Année", "Classe", "Ess", "Qual", "PU")) %>% 
    full_join(Epc, by = c("Année", "Classe", "Ess", "Qual", "PU")) %>% 
    full_join(Sap, by = c("Année", "Classe", "Ess", "Qual", "PU"))
  
  rm(Chene, Frehe, PSyl, Résineux, Feuil, Peu, Epc, Sap)
  
  # Ajout PU des essences manquantes
  AlisierT = filter(Nouveau, Ess == "Tilleul") %>% 
    mutate(Ess = "Alisier T",
           PU = PU*1.2)
  Nouveau = full_join(Nouveau, AlisierT, by = c("Année", "Classe", "Ess", "Qual", "PU"))
  
  AlisierB = filter(Nouveau, Ess == "Aulne") %>% 
    mutate(Ess = "Alisier B")
  Nouveau = full_join(Nouveau, AlisierB, by = c("Année", "Classe", "Ess", "Qual", "PU")) 
  
  EpiceaS = filter(Nouveau, Ess == "Epicéa C") %>% 
    mutate(Ess = "Epicéa S",
           PU = PU*(1-0.2))
  Nouveau = full_join(Nouveau, EpiceaS, by = c("Année", "Classe", "Ess", "Qual", "PU"))
  
  Chpub = filter(Nouveau, Ess == "Chêne") %>% 
    mutate(Ess = "Chêne Pub.",
           PU = PU*(1-0.3))
  Chrou = filter(Nouveau, Ess == "Chêne") %>% 
    mutate(Ess = "Chêne R",
           PU = PU*(1-0.3))
  Nouveau = Nouveau %>% 
    full_join(Chpub,by = c("Année", "Classe", "Ess", "Qual", "PU")) %>%
    full_join(Chrou,by = c("Année", "Classe", "Ess", "Qual", "PU")) 
  
  MelezeJ = filter(Nouveau, Ess ==  "Mélèze") %>% 
    mutate(Ess = "Mélèze J")
  Nouveau = full_join(Nouveau, MelezeJ,by = c("Année", "Classe", "Ess", "Qual", "PU")) 
  
  PinW = filter(Nouveau, Ess == "Pin S") %>% 
    mutate(Ess = "Pin W",
           PU = PU*(1-0.2))
  Nouveau = full_join(Nouveau, PinW,by = c("Année", "Classe", "Ess", "Qual", "PU"))
  
  Robinier = filter(Nouveau, Ess == "Erable S") %>% 
    mutate(Ess = "Robinier")
  Nouveau = full_join(Nouveau, Robinier,by = c("Année", "Classe", "Ess", "Qual", "PU")) 
  
  SapG = filter(Nouveau, Ess == "Sapin P") %>% 
    mutate(Ess = "Sapin G",
           PU = PU*(1-0.3))
  Nouveau = full_join(Nouveau, SapG,by = c("Année", "Classe", "Ess", "Qual", "PU")) 
  
  Cormier = filter(Nouveau, Ess == "Tilleul") %>% 
    mutate(Ess = "Cormier")
  Nouveau = full_join(Nouveau, Cormier ,by = c("Année", "Classe", "Ess", "Qual", "PU"))
  
  rm(AlisierB, AlisierT, EpiceaS, Chpub, Chrou, MelezeJ, PinW, Robinier, SapG, Cormier)
  
  Nouveau = Nouveau %>% 
    rename(Essence = Ess) 
   
  # Ajout des classes manquantes PB et GB : prix AFI
  Vecteur = unique(df$Année)
  ClassesNA = PUafi %>% 
    filter(Classe %in% c(10,15,20, 85, 90, 95, 100, 105, 110, 115, 120)) # sélection classes perches et gros bois
  ClassesNA = ClassesNA[rep(1:nrow(ClassesNA), each=length(Vecteur)),] %>% 
    mutate(Année = rep(Vecteur, nrow(ClassesNA)))
  
  # Si possibilité, prix des classes >80 = prix forêt privée des 80 
  GrosBois = Nouveau %>% 
    filter(Classe == 80)
  PUGBafi = ClassesNA %>% 
    filter(Classe >= 85) %>% 
    left_join(GrosBois, by = c("Essence","Année","Qual")) %>% 
    rename(PU = PU.y,
           Classe = Classe.x) %>% 
    dplyr::select(Essence, Classe, Qual, Année, PU)
  
  # Prix unitaires perches et petit bois assimilés à bois de chauffage - qualité D
  Nouveau = Nouveau %>% 
    rbind(subset(ClassesNA, Classe < 85)) %>% # Perches et PB: prix de l'AFI
    rbind(PUGBafi)
  
  # Calcul des prix manquants pour les années manquantes
  PUvar <- PUvar %>% 
    rbind(Nouveau)
  PUvar <- PUvar %>% 
    group_by(Essence, Classe, Qual) %>% 
    mutate(PU = ifelse(is.na(PU), lag(PU, order_by = Année), PU)) %>%  # si prix manquant sur l'année <- assimilés à prix années précédentes (ex. PU sapin, épicéa 2019 = PU sapin, épicéa 2018)
    left_join(PUafi, by = c("Essence","Qual","Classe")) # Combler les prix manquant restant avec prix AFI
    # Platane n'existe pas dans base AFI mais même prix que tilleul dans base foret privée
  PUvar = PUvar %>% 
    mutate(PU = ifelse(is.na(PU.x), PU.y, PU.x)) %>%
    dplyr::select(Année, Essence, Classe, Qual, PU)
  Platane = PUvar %>% 
    group_by(Année, Classe, Qual) %>% 
    mutate(PU = ifelse(is.na(PU) & Essence == "Platane", PU[Essence == "Tilleul"], PU))
  PUvar = PUvar %>% 
    left_join(Platane, by = c("Année","Essence","Classe","Qual")) %>% 
    mutate(PU = ifelse(is.na(PU.x), PU.y, PU.x)) %>% 
    dplyr::select(Année, Essence, Classe, Qual, PU)
  
  usethis::use_data(PUvar, overwrite = T)
}


# ------- Utilisation -----
res <- IFNdata(FALSE)
IFNarbres <- res$IFNArbres
IFNplacettes <- res$IFNplacettes

CodesIFNmod <- read_excel("/Users/maxbruciamacchie/Desktop/CodeIFN.xlsx", sheet=2)

rnIFN <- st_read("~/pCloud Drive/Bureau/GeoData/Limites/Milieux/rn250_l93_shp-2/rnifn250_l93.shp") %>% 
  select(REGN:geometry) %>% 
  ms_simplify(keep=0.1, keep_shapes = T, drop_null_geometries = F)
st_write(rnIFN, "rnIFN.shp")

ser <- st_read("~/pCloud Drive/Bureau/GeoData/Limites/Milieux/ser_l93/ser_l93.shp") %>% 
  mutate(codeser = as.character(codeser),
         NomSER = as.character(NomSER)) %>% 
  mutate(greco = str_sub(codeser,1,1)) %>% 
  select(codeser,NomSER,greco,geometry) %>% 
  ms_simplify(keep=0.1, keep_shapes = T, drop_null_geometries = F)

greco <- ser %>% 
  group_by(greco) %>% 
  summarise() %>% 
  filter(greco!="-")
plot(st_geometry(greco))


INSEEcom <- read.delim("~/pCloud Sync/Packages/DataForet/temp/INSEEcom.txt", encoding="latin1")
INSEEdep <- read.delim("~/pCloud Sync/Packages/DataForet/temp/INSEEdep.txt", encoding="latin1") %>% 
  select(-TNCC)
INSEEreg <- read.delim("~/pCloud Sync/Packages/DataForet/temp/INSEEreg.txt", encoding="latin1") %>% 
  select(-TNCC)

# ------------- Sauvegarde
usethis::use_data(IFNarbres, overwrite = T)
usethis::use_data(IFNplacettes, overwrite = T)
usethis::use_data(ser, overwrite = T)
usethis::use_data(FD, overwrite = T)
usethis::use_data(ParFor, overwrite = T)
usethis::use_data(bioreg, overwrite = T)
usethis::use_data(greco, overwrite = T)
usethis::use_data(rnIFN, overwrite = T)
usethis::use_data(INSEEcom, overwrite = T)
usethis::use_data(INSEEdep, overwrite = T)
usethis::use_data(INSEEreg, overwrite = T)
usethis::use_data(CodesIFNmod, overwrite = T)
usethis::use_data(INSEEpa, overwrite = T)
usethis::use_data(Climat, overwrite = T)
usethis::use_data(Communes, overwrite = T)
usethis::use_data(TypoClimat, overwrite = T)

# Attention placettes doubles !!!
IFNplacettes <- IFNplacettes %>% distinct()

# Climat
TypoClimat <- Communes %>% 
  left_join(Climat, by = "INSEE") %>%
  filter(Type %in% 1:8) %>%
  mutate(Type = as.character(Type)) %>%
  group_by(Type) %>%
  summarise() %>%
  st_sf() %>% 
  ms_simplify()
