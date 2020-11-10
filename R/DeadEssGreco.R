#' Mortalité par essence et GRECO
#'
#' @description La fonction DeadEssGreco fournit par grande région écologique (GRECO) le taux de mortalité par essence.
#' Il est définit comme le ratio en volume des arbres morts sur pied par rapport aux arbres vivants. 
#'
#' @return La fonction renvoie le taux de mortalité sous forme de tableaux ou de cartes.
#' 
#' @param ess = code essence de l'IFN. Le code data("CodesEssIFN") rappelle la codification de l'IFN.
#' 
#' @import tidyverse
#' 
#' @examples
#' ess = "05"
#' res = DeadEssGreco(ess)
#' # Part de l'essence dans la mortalité
#' res$gpart
#' # Taux de mortalité
#' res$gmort
#' # Maximum de mortalité
#' res$tab %>% 
#'  group_by(greco) %>% 
#'  arrange(desc(PourcM)) %>% 
#'  slice(1)
#'  # carte de la part de l'essence dans la mortalité
#'  res$mappart
#'  # carte du taux de mortalité de l'essence
#'  res$mapmort
#' 
#' @author Max Bruciamacchie
#' 
#' @source IFN
#' 
#' @export

DeadEssGreco <- function(ess){
  plac <- IFNplacettes %>% 
    mutate(greco = substring(ser, 1, 1))
  
  Nb <- plac %>% 
    group_by(Annee, greco) %>% 
    summarise(Nb = n())
  
  nomEss <- CodesEssIFN$libelle[which(CodesEssIFN$code == ess)]
  
  t1 <- IFNarbres %>% 
    left_join(plac[, c("idp", "greco")], by = "idp") %>% 
    mutate(Ess = ifelse(espar == ess, nomEss, "Autres")) %>%
    group_by(Annee, greco, Ess) %>% 
    summarise(Vol = sum(v*w)) %>% 
    left_join(Nb, by = c("Annee", "greco")) %>% 
    mutate(VolT = Vol/Nb) %>% 
    group_by(Annee, greco) %>%
    mutate(Pourc = VolT / sum(VolT)) %>% 
    dplyr::select(Annee:Ess,VolT,Pourc)
  
  t2 <- IFNarbres_morts %>% 
    left_join(plac[, c("idp", "greco")], by = "idp") %>% 
    mutate(Ess = ifelse(espar == ess, nomEss, "Autres")) %>%
    group_by(Annee, greco, Ess) %>% 
    summarise(Vol = sum(v*w)) %>% 
    left_join(Nb, by = c("Annee", "greco")) %>% 
    mutate(VolM = Vol/Nb) %>% 
    group_by(Annee, greco) %>%
    mutate(PourcM = VolM / sum(VolM)) %>% 
    dplyr::select(Annee:Ess,VolM,PourcM)
  
  tab <- t1 %>% 
    left_join(t2, by = c("Annee", "greco", "Ess")) %>% 
    filter(Annee > 2008) %>% 
    filter(VolT >= 1) %>% 
    filter(Ess == nomEss) %>% 
    mutate(Part = VolM/VolT)
  
  g <- ggplot(tab, aes(x=greco, y=PourcM, color=Annee, size=VolT)) + 
    geom_jitter(width = 0.2, alpha=0.9) + scale_size(range = c(0, 5))+
    theme_bw() + guides(size=FALSE) +
    labs(y=paste("Part de l'essence",nomEss)) +
    scale_y_continuous(labels=scales::percent)
  
  g1 <- ggplot(tab, aes(x=greco, y=Part, color=Annee, size=VolT)) + 
    geom_jitter(width = 0.2, alpha=0.9) + scale_size(range = c(0, 5))+
    theme_bw() + guides(size=FALSE) +
    labs(y=paste("Taux de l'essence",nomEss)) +
    scale_y_continuous(labels=scales::percent)
  
  last = max(tab$Annee)
  t2 <- greco %>%
    left_join(tab, by = "greco") %>% 
    filter(Annee == last) %>% 
    st_drop_geometry()
  
  t2 <- greco %>%
    left_join(t2, by = "greco")
  
  map <- ggplot(t2, aes(fill=PourcM)) + 
    geom_sf() +
    scale_fill_gradient(low = "white", high = "darkred", 
                        na.value = "grey70") +
    coord_sf(datum = sf::st_crs(2154)) +
    theme_void() + 
    labs(title =paste("Part de l'essence",nomEss," en",last))
  
  map1 <- ggplot(t2, aes(fill=Part)) + 
    geom_sf() +
    scale_fill_gradient(low = "white", high = "darkred", 
                        na.value = "grey70") +
    coord_sf(datum = sf::st_crs(2154)) +
    theme_void() + 
    labs(title =paste("Taux de l'essence",nomEss,"en",last))

  out <- list(tab, g, map, g1, map1)
  names(out) <- c("tab", "gpart", "mappart","gmort", "mapmort")
  
  return(out)
}



