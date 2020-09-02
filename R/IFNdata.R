#' Rechargement des donnees IFN
#'
#' @encoding UTF-8
#'
#' @description Cette fonction permet de télécharger les données brutes de l'IFN à partir du site
#' https://inventaire-forestier.ign.fr/IMG/zip/. Elle charge les données de 2005 aux dernières campagnes de mesures.
#'
#' @return Cette fonction enregistre dans le dossier data les deux tables IFNarbres.rda et IFNplacettes.rda.
#'
#' @param enrg = si TRUE les 2 tables Arbres et Placettes sont enregistrées sous forme d'archives rda.
#' Sinon la fonction renvoie les deux tables.
#'
#' @import tidyverse
#' @import data.table
#' @import rvest
#'
#' @examples
#' IFNdata()
#' # ou bien
#' res <- IFNdata(FALSE)
#' IFNarbres <- res$IFNarbres
#' IFNplacettes <- res$IFNplacettes
#'
#'@author BRUCIAMACCHIE Max

#' @export IFNdata

IFNdata <- function (enrg = TRUE) {

  IFNarbres <- data.table()
  IFNplacettes <- data.table()
  IFNarbres_morts <- data.table()

  # --------- Boucle Import par annee
  page <- read_html("https://inventaire-forestier.ign.fr/spip.php?article707&ID_TELECHARGEMENT=18429&TOKEN=6e5cf5998c9b2f6842d050c1c61d43ec") # lit le lien IGN pour télécharger les données
  # DataZip <- html_nodes(h, "a[type]") %>% html_attr("href")
  DataZip <- html_nodes(page, "a[type]") %>% html_attr("href")
  DataZip <- DataZip[grepl("zip",DataZip)] # fichiers zip à télécharger

  dates <- str_sub(DataZip,9,12) # récupère les dates des campagnes (dans intitulé fichiers zip)
  dates <- dates[-1] # Premier zip à télécharger = données explicatives
  dates <- unique(dates)
  
  rep <- "https://inventaire-forestier.ign.fr/IMG/zip/"
  
  for (i in 1:length(dates)){
    an = as.integer(substr(dates[i], 1, 4))
    # --------- Telecharger et decompacter
    tempRep <- tempdir()
    temp <- tempfile()
    repTour <- paste0(rep,dates[i],"-fr.zip")
    download.file(repTour, temp)
    liste <- unzip(temp, exdir=tempRep)
    if(sum(grepl("/trees_forest", liste))>0) {
      tabArbres <- read.csv2(liste[grepl(paste("/trees_forest",an,sep="_"), liste)])
      tabArbres$Annee <- an
      tabPlacettes <- read.csv2(liste[grepl(paste("plots_forest_",an,sep=""), liste)])
      tabPlacettes$Annee <- an
      OK = TRUE
    }
    if(sum(grepl("/arbres_foret", liste))>0) {
      tabArbres <- read.csv2(liste[grepl("arbres_foret", liste)])
      tabArbres$Annee <- an
      tabPlacettes <- read.csv2(liste[grepl(paste("placettes_foret_",an,sep=""), liste)])
      tabPlacettes$Annee <- an
      tabMorts <- read.csv2(liste[grepl(paste("arbres_morts_foret_",an,sep=""), liste)])
      tabMorts$Annee <- an
      OK = TRUE
    }

    # --------- Agregation
    if(OK) {
      IFNarbres <- rbindlist(list(IFNarbres, tabArbres), use.names=T, fill=T)
      IFNplacettes <- rbindlist(list(IFNplacettes, tabPlacettes), use.names=T, fill=T)
      IFNarbres_morts <- rbindlist(list(IFNarbres_morts, tabMorts), use.names=T, fill=T)
      # --------- supression fichier et dossier temporaires
      unlink(temp); unlink(tempRep)
    }

  }
  # --------- Nettoyage
  IFNarbres$ir5 <- as.numeric(as.character(IFNarbres$ir5))
  IFNarbres$v   <- as.numeric(as.character(IFNarbres$v))
  IFNarbres$w   <- as.numeric(as.character(IFNarbres$w))
  IFNarbres$htot <- as.numeric(as.character(IFNarbres$htot))
  IFNarbres_morts$v   <- as.numeric(as.character(IFNarbres_morts$v))
  IFNarbres_morts$w   <- as.numeric(as.character(IFNarbres_morts$w))
  # --------- Selection colonnes
  IFNarbres <- IFNarbres %>%
    dplyr::select(idp,a,espar,veget,mortb,acci,ori,mortb,c13,ir5,htot,hdec,v,w,Annee) %>% 
  
  tab <- IFNarbres %>% # correction code essence 2014
    filter(Annee == 2014) %>% 
    mutate(espar2 = ifelse(espar %in% c("2","3","4","5","6","7","9"), paste("0",espar,sep=""),NA),
           espar3 = ifelse(is.na(espar2), as.character(espar), espar2),
           espar4 = as.factor(espar3)) %>% 
    dplyr::select(-c(espar,espar2,espar3)) %>% 
    dplyr::rename(espar = espar4) %>% 
    dplyr::select(idp,a,espar,veget,mortb,acci,ori,c13,ir5,htot,hdec,v,w,Annee)
  IFNarbres <- IFNarbres %>% 
    filter(Annee != 2014) %>% 
    rbind(tab)
  
  IFNplacettes <- IFNplacettes %>%
    dplyr::select(idp,xl93,yl93,ser,csa,dc,dist,Annee)
  IFNarbres_morts <- IFNarbres_morts %>%
    dplyr::select(idp,a,veget,datemort,espar,ori,c13,v,w,Annee)
  # --------- Creation archive ou return
  if(enrg) {
    usethis::use_data(IFNarbres, overwrite = T)
    usethis::use_data(IFNplacettes, overwrite = T)
    usethis::use_data(IFNarbres_morts, overwrite = T)
  } else {
    out = list(IFNarbres, IFNplacettes, IFNarbres_morts)
    names(out) <- c("IFNarbres", "IFNplacettes","IFNarbres_morts")
    return(out)
  }
}


