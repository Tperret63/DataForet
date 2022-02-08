#' Mise à jour coefficient de transformation euros constants.
#'
#' @description Mise à jour de la base de données des coefficients de pouvoir d'achat INSEEpa. 
#'
#' @import tidyverse
#' @import rvest
#' @import lubridate
#' 
#' @examples
#' MAJ_INSEEpa
#'  
#' @source \url{https://www.insee.fr/fr/statistiques/serie/010605954#Tableau}


MAJ_INSEEpa <- function(){
  data(INSEEpa)
  # INSEEpa <- INSEEpa %>% slice(1:70)
  an = year(Sys.Date())
  last = max(INSEEpa$Année)
  
  if(last - an > 1) {
    h <- read_html("https://www.insee.fr/fr/statistiques/serie/ajax/010605954") # lit la page web de l'INSEE avec les données 
    PA <- html_node(h,"table") %>%  html_table() # récupère les coefficients sous forme de tableau directement de la page web
    
    new <- PA %>% 
      mutate(Valeur = str_replace(Valeur, ",", ".")) %>% 
      filter(Année > last) %>% 
      mutate(Monnaie = 1) %>% 
      rename(Infla = Valeur) %>% 
      arrange(Année) %>% 
      mutate(Infla =as.numeric(Infla))
    
    INSEEpa <- rbind(INSEEpa, new)
  }

  usethis::use_data(INSEEpa, overwrite = T)
}
