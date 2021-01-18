#' Tableau des coefficients d'inflation
#'
#' @description Fonction permettant de créer un tableau des coefficients d'inflation. 
#'
#' @format Data frame contenant 70 lignes et 3 variables.
#' 
#' @import tidyverse
#' @import WriteXLS
#' 
#' @examples
#' CoeffInflation()
#'  
#' @source \url{https://www.insee.fr/fr/statistiques/serie/010605954#Tableau}
#' 
#' @export

CoeffInflation <- function(){
  data("INSEEpa")
  euro=6.55957
  tab <- INSEEpa
  valmax = tab$Infla[dim(tab)[1]]
  tab <- tab %>%
    dplyr::mutate(Coefft=1,
           Coefft = ifelse(Année < 2002, 1/euro, Coefft),
           Coefft = ifelse(Année < 1960, 1/euro/100, Coefft),
           Infla = valmax/Infla,
           Coefft = Coefft * Infla) %>%
    dplyr::select(Année, Coefft)
  
  WriteXLS(tab, "Coefft.xlsx")
}


