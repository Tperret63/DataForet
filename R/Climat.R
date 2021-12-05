#' Climat des communes de la France métropolitaine.
#'
#' @description Données climatiques par communes. Proposition d'une typologie. 
#' Coordonnées sur les 3 premiers axes d'une AFC. Extrait de Les types de climats en France, une construction spatiale
#' Auteurs : Daniel Joly, Thierry Brossard, Hervé Cardot, Jean Cavailhes, Mohamed Hilal et Pierre Wavresky
#'
#' @format Data frame contenant 36211 lignes et 19 variables.
#' 
#' @param INSEE = code Insee
#' @param TMO = Moyenne annuelle de température
#' @param TMN = Nombre de jours avec une température inférieure à -5°C
#' @param TMX = Nombre de jours avec une température supérieure à 30°C.
#' @param TAM = Amplitude thermique annuelle, différence entre la température 
#' moyenne de juillet et celle de janvier. 
#' @param TEH = Variabilité interannuelle de la température en janvier. Ecart-type 
#' des 30 valeurs de température mensuelles au cours de la normale de référence
#' @param TEE = Variabilité interannuelle de la température en juillet
#' @param PTO = Cumuls annuels de précipitation
#' @param PDH = Ecart des cumuls de janvier par rapport à la moyenne annuelle des cumuls mensuels
#' @param PDE = Ecart des cumuls de juillet par rapport à la moyenne annuelle des cumuls mensuels. 
#' @param PJH = Nombre de jours de précipitation en janvier
#' @param PJE = Nombre de jours de précipitation en juillet
#' @param PEH = Variabilité interannuelle des précipitations en janvier
#' @param PEE = Variabilité interannuelle des précipitations en juillet
#' @param PRA = Rapport entre les abats d’automne (septembre + octobre) et ceux de juillet
#' @param Type = typologie des climats. 1:Montagne, 2:Semi-continental, 3:Océanique dégradé
#' 4:Océanique altéré, 5:Océanique, 6:Méditerranéen altéré, 7:Bassin du Sud-Ouest, 8:Méditerranéen))
#' @param axe1, axe2, axe3 = coordonnées factorielles
#' 
#
#' @examples
#' library(sf)
#' library(tidyverse)
#' 
#' data(greco)
#' data(Climat)
#' data(Communes)
#' 
#' Communes <- Communes %>% 
#'   left_join(Climat, by = "INSEE") %>% 
#'   filter(Type %in% 1:8) %>%  
#'   mutate(Type = as.character(Type)) %>% 
#'   group_by(Type) %>% 
#'   summarise() %>% 
#'   st_sf()
#' 
#' cols <- c("8"="firebrick3","7"="darkorange","6"="darkolivegreen2","5"="chartreuse4",
#'           "4"="aquamarine3","3"="darkslategray1","2"="deepskyblue","1"="blue4")
#' 
#' ggplot(Communes) + 
#'   geom_sf(aes(color=Type, fill=Type)) +
#'   scale_fill_manual(values = cols) +
#'   scale_color_manual(values = cols) +
#'   geom_sf(data=greco, fill=NA, color="white", size=0.5) +
#'   theme_bw()
#'  
#' @source \url{http://cybergeo.revues.org/26894?file=1
#' https://doi.org/10.4000/cybergeo.23155}

"Climat"


