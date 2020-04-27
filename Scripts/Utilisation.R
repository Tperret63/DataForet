# -------- INSEE --------
## Mise à jour coefficient de transformation euros constants
library(rvest)
library(dplyr)

MAJ_INSEEpa <- function(){
load("data/INSEEpa.rda")

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


