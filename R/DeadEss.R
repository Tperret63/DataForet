#' Volume de bois mort par essence
#'
#' @description La fonction DeadEss fournit l'importance en volume d'une ou plusieurs essences par
#' sylvoécorégion sur laquelle est superposée l'importance en volume des arbres morts selon la codification
#' IFN (veget = "5" ou veget = "C"). Elle utilise la base de données IFNarbres_morts en ne retenant que les placettes
#' mesurées il y a moins de 5 ans. Seuls les arbres jugés morts depuis moins de 5 ans sont retenus (datemort == "1")
#' Le code data("CodesEssIFN") rappelle la codification de l'IFN pour les paramètres veget et datamort.
#'
#' @format Renvoie une carte au format ggplot
#' 
#' @param ess = code essence de l'IFN. Le code data("CodesEssIFN") rappelle la codification de l'IFN.
#' 
#' @import tidyverse
#' @import sf
#' 
#' @examples
#' DeadEss("02")$map
#' DeadEss("03")$map
#' DeadEss("05")$map
#' DeadEss("09")$map
#' DeadEss("10")$map
#' DeadEss("52")$map
#' DeadEss("61")$map
#' DeadEss("62")$map
#' DeadEss(c("09","61"))$map
#' 
#' @author Bruciamacchie Max
#' 
#' @export

DeadEss <- function(ess){
  
  dfEss <- CodesEssIFN %>% 
    filter(code %in% ess) %>% 
    rename(espar = code) %>% 
    mutate(libelle = str_to_title(libelle))

  last = max(IFNarbres$Annee)
  
  Nb <- IFNplacettes %>% 
    filter(Annee == last-5) %>%
    group_by(ser) %>% 
    summarise(Nb = n())
  
  t1 <- IFNarbres %>% 
    filter(espar %in% ess) %>%
    filter(Annee == last-5) %>%
    left_join(IFNplacettes[, c("idp", "ser")], by = "idp") %>% 
    group_by(Annee, ser, espar) %>% 
    summarise(Vol = sum(v*w, na.rm=T)) %>% 
    left_join(Nb, by = "ser") %>% 
    mutate(Vol = Vol/Nb) %>% 
    left_join(dfEss, by = "espar")
  
  t2 <- IFNarbres_morts %>% 
    filter(espar %in% ess) %>%
    filter(Annee <= last-5) %>%
    filter(datemort == "1") %>% 
    filter(veget %in% c("5","C")) %>% 
    group_by(idp, espar) %>% 
    summarise(Vol = sum(v*w, na.rm=T)/5) %>% 
    left_join(dfEss, by = "espar") %>% 
    left_join(IFNplacettes[, c("idp","xl93","yl93")], by = "idp") %>% 
    st_as_sf(coords=c("xl93","yl93"), crs=2154)
  
  shp <- ser %>%
    rename(ser = codeser) %>% 
    left_join(t1, by = "ser") %>% 
    filter(!is.na(Vol))
  
  g <- ggplot(ser) + 
    geom_sf(fill="grey60", color='grey90', lwd=0.5) +
    geom_sf(data=shp, aes(fill=Vol), color='grey90', lwd=0.5) +
    scale_fill_gradient(low = "white", high = "green4", na.value = "grey60") +
    facet_wrap(~ libelle) +
    geom_sf(data=t2, aes(size=Vol), color="blue", alpha=0.8) +
    scale_size_continuous(range = c(0.25, 4)) +
    coord_sf(datum = sf::st_crs(2154)) +
    theme_void() + 
    labs(fill="Vol vivant \n (m3/ha)", size="Vol mort \n (m3/ha)")

  
  out <- list(g)
  names(out) <- c("map")
  
  return(out)
}


