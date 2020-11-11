#' Base de données statuts de protection
#'
#' @description La fonction crée un objet qui rassemble tous les statuts de protections disponibles sur
#' le serveur du Muséum d'Histoire naturelle.
#'
#' @return La fonction crée un objet géoréférencé au format sf.
#'
#' @import sf
#' @import tidyverse
#' @import tools
#' @import readxl
#'
#' @author Bruciamacchie Max
#' 
#' @source https://inpn.mnhn.fr/docs/Shape
#'
#' @examples
#' library(tidyverse)
#' library(readxl)
#' library(tools)
#' library(sf)
#' 
#' Protect <- ProtectDataCreate()
#'
#' @export

ProtectDataCreate <- function(){
  # --------- Import liens
  file <- system.file("Liens.xlsx", package = "DataForet")
  liens <- read_excel(file, sheet="R") %>%
    filter(Catégorie == "Protection") %>%
    dplyr::select(Thème,Lien)

  StatutProtect <- st_sf(st_sfc(), crs=2154)
  for (i in 1:dim(liens)[1]){
    # for (i in 7:12){
    theme <- as.character(liens[i,1])
    lien  <- as.character(liens[i,2])
    tempRep <- tempdir()
    temp    <- tempfile()
    repTour <- lien
    download.file(repTour, temp)
    liste <- unzip(temp, exdir=tempRep)
    fich <- list.files(tempRep, pattern="\\.shp$", recursive=T)

    for (j in 1:length(fich)) {
      enTour = fich[j]
      dir <- dirname(enTour)
      if (length(dir) >0){
        rep <- paste(tempRep,dir,sep="/")
      } else{
        rep <- tempRep
      }
      enTour <- file_path_sans_ext(basename(enTour))

      sf1 <- st_read(dsn=rep, layer=enTour, quiet=T) %>%
        st_transform(2154) %>%
        mutate(Nom = names(.)[1]) %>%
        mutate(Iden = .[[1]]) %>%
        mutate(Theme = theme) %>%
        dplyr::select(Nom,Iden,Theme)
      print(paste("Simplification du thème :","........",enTour))
      sf1 <- sf1 %>%
        st_make_valid() %>%
        group_by() %>%
        summarise() %>%
        ms_simplify()

      StatutProtect <- rbind(StatutProtect, sf1)
    }

    files <- list.files(tempRep, full.names = T, pattern = "\\.shp$", recursive=T)
    file.remove(files)
    unlink(temp); unlink(tempRep)
  }
  cat("Fin de la boucle, ........... vérification de la géométrie")
  StatutProtect <- StatutProtect %>%
    st_make_valid()

  return(StatutProtect)
}

