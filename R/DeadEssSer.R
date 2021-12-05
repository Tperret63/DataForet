#' Mortalité par essence et sylvoécorégions
#'
#' @description La fonction DeadEssSer fournit par sylvoécorégions le taux de mortalité par essence. 
#' Il est défini comme le le ratio en volume des arbres morts sur pied par rapport aux arbres vivants, 
#' sur les deux dernières périodes de 5 ans. 
#'
#' @format La fonction renvoie le taux de mortalité sous forme de tableau ou de cartes.
#' 
#' @param ess = code essence de l'IFN. Le code data("CodesEssIFN") rappelle la codification de l'IFN.
#' 
#' @import tidyverse
#' 
#' @examples
#' ess = "05"
#' res = DeadEssSer(ess)
#' # sous forme tableau
#' head(res$tab)
#' # cartes du taux de mortablité sur les 2 dernières années
#' res$mappart
#' 
#' @author Max Bruciamacchie
#' 
#' @source IFN
#' 
#' @export

DeadEssSer <- function(ess){
  
  Nb <- IFNplacettes %>% 
    group_by(Annee, ser) %>% 
    summarise(Nb = n())
  
  nomEss <- CodesEssIFN$libelle[which(CodesEssIFN$code == ess)]
  
  t1 <- IFNarbres %>% 
    left_join(IFNplacettes[, c("idp", "ser")], by = "idp") %>% 
    mutate(Ess = ifelse(espar == ess, nomEss, "Autres")) %>%
    group_by(Annee, ser, Ess) %>% 
    summarise(Vol = sum(v*w, na.rm=T)) %>% 
    left_join(Nb, by = c("Annee", "ser")) %>% 
    mutate(VolT = Vol/Nb) %>% 
    group_by(Annee, ser) %>%
    mutate(Pourc = VolT / sum(VolT)) %>% 
    dplyr::select(Annee:Ess,VolT,Pourc) %>% 
    filter(Ess == nomEss)
  
  t2 <- IFNarbres_morts %>% 
    filter(veget %in% c("5","C")) %>% 
    left_join(IFNplacettes[, c("idp", "ser")], by = "idp") %>% 
    mutate(Ess = ifelse(espar == ess, nomEss, "Autres")) %>%
    group_by(Annee, ser, Ess) %>% 
    summarise(Vol = sum(v*w, na.rm=T)) %>% 
    left_join(Nb, by = c("Annee", "ser")) %>% 
    mutate(VolM = Vol/Nb) %>% 
    group_by(Annee, ser) %>%
    mutate(PourcM = VolM / sum(VolM)) %>% 
    dplyr::select(Annee:Ess,VolM,PourcM) %>% 
    filter(Ess == nomEss)
  
  last = max(t1$Annee)
  
  tab <- t1 %>% 
    left_join(t2, by = c("Annee", "ser", "Ess")) %>%
    filter(Annee > last-10) %>% 
    filter(Annee <= last-5) %>%
    group_by(ser) %>% 
    summarise(VolT = sum(VolT, na.rm=T)/5,
              VolM = sum(VolM, na.rm=T)/5,
              Part = VolM/VolT) %>% 
    filter(VolT > 1)
  
  tab1 <- ser %>%
    rename(ser = codeser) %>% 
    left_join(tab, by = "ser") %>% 
    mutate(Période=paste(last-9, last-5, sep="-"))
  
  laps=5
  tab <- t1 %>% 
    left_join(t2, by = c("Annee", "ser", "Ess")) %>%
    filter(Annee > last-laps) %>% 
    group_by(ser) %>% 
    summarise(VolT = sum(VolT, na.rm=T)/laps,
              VolM = sum(VolM, na.rm=T)/laps,
              Part = VolM/VolT) %>% 
    filter(VolT > 1)
  
  tab2 <- ser %>%
    rename(ser = codeser) %>% 
    left_join(tab, by = "ser") %>% 
    mutate(Période=paste(last-4, last, sep="-"))
  
  tab <- rbind(tab1, tab2)
  
  map <- ggplot(tab, aes(fill=Part)) + 
    geom_sf() +
    facet_wrap(~ Période, ncol=2) +
    scale_fill_gradient(low = "white", high = "darkred", 
                        na.value = "grey90") +
    coord_sf(datum = sf::st_crs(2154)) +
    theme_void()
  
  out <- list(tab, map)
  names(out) <- c("tab", "mappart")
  
  return(out)
}


