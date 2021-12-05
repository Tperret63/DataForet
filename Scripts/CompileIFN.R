library(data.table)
library(tidyverse)
library(sf)
# library(rgdal)
library(readxl)
library(DataForet)
######################################################################################
#                       Construction de la base IFN
######################################################################################
# ----------------------- Lecture
IFNarbres        <- data.table()
IFNplacettes     <- data.table()
IFNPlacettesPrel <- data.table()
debut = 2005
fin   = 2018

rep <- "~/Documents/IFN/"

for (i in debut:fin){
  tabArbres     <- read_csv2(paste0(rep,i,"/arbres_foret_",i,".csv"))
  tabArbres$Annee <- i
  IFNarbres     <- rbindlist(list(IFNarbres, tabArbres), use.names=TRUE, fill=TRUE)
  tabPlacettes  <- read_csv2(paste0(rep,i,"/placettes_foret_",i,".csv"))
  tabPlacettes$Annee <- i
  IFNplacettes <- rbindlist(list(IFNplacettes, tabPlacettes), use.names=TRUE, fill=TRUE)
}

IFNplacettes <- IFNplacettes %>%
  dplyr::select(idp:yl93,ser,csa,dc,dist,Annee) %>%
  st_as_sf(coords=c("xl93","yl93"), crs=2154, remove=F) %>%
  st_join(TypoClimat) %>%
  st_drop_geometry()
# save(IFNplacettes, file="IFNplacettes.Rdata")

# ----------------------- Selection
IFNarbres <- IFNarbres%>%
  select(idp,a,espar,veget,mortb,acci,ori,c13,ir5,htot,hdec,v,w,Annee) %>% 
  mutate(ir5  = as.numeric(ir5),
         htot = as.numeric(htot),
         hdec = as.numeric(hdec),
         v    = as.numeric(v))
# save(IFNarbres, file="IFNarbres.Rdata")

for (i in debut:(fin-5)) {
  tabPlacettesPrel  <- read_csv2(paste0("DataIFN/",i,"/placettes_foret_5_",i,".csv"))
  IFNPlacettesPrel <- rbindlist(list(IFNPlacettesPrel, tabPlacettesPrel), use.names=TRUE, fill=TRUE)
}
rm(tabArbres,tabPlacettes,tabPlacettesPrel)
# ----------------------- Selection
IFNarbres <- IFNarbres%>%
  select(-c(a,ori,forme,q2,q3,r,lfsd, sfgui:sfcoeur,simplif))
IFNplacettes <- IFNplacettes %>%
  filter(csa !=2 & (uta ==0 | uta1 <=5) & tm2 >1) %>%
  select(idp:ser,dc,esspre,Annee,gest:incid)
coordinates(IFNplacettes) <- ~ xl93 + yl93
IFNplacettes@proj4string <- CRS("+init=epsg:2154")
# ----------------------- Corrections
IFNarbres$ir5 <- as.numeric(IFNarbres$ir5)
IFNarbres$v <- as.numeric(IFNarbres$v)
######################################################################################
#                       Tables complementaires
######################################################################################
rep <- "/Users/bruciamacchiemax/Documents/GeoData/Administratif"
ser <- readOGR(dsn=rep, "ser100union")
Ecorces <- read_excel("Data/Ecorces.xlsx")
CodesEssIFN  <- read_csv2("Data/CodesEssIFN.csv")
CodesEssIFN$code <- ifelse(nchar(CodesEssIFN$code)<2, paste0("0",CodesEssIFN$code),CodesEssIFN$code)

# ----------------------- Enregistrement sur disque
save(IFNarbres, file="Tables/IFNarbres.RData")
save(IFNplacettes, file="Tables/IFNplacettes.RData")

setwd("~/Desktop/Packages/PPtools/PPtools")
devtools::use_data(IFNarbres, overwrite = T)
devtools::use_data(IFNplacettes, overwrite = T)
devtools::use_data(Ecorces, overwrite = T)
devtools::use_data(CodesEssIFN, overwrite = T)














