#' Pouvoir d'achat.
#'
#' @description Pouvoir d'achat d'une somme en euros ou en francs d’une année donnée en une somme 
#' équivalente en euros ou en francs d’une autre année, corrigée de l’inflation observée
#'  entre les deux années. 
#'
#' @format Data frame contenant 70 lignes et 3 variables.
#' 
#' @param Année	= année. La base démarre à l'année 1950
#' @param Infla = inflation. L'inflation annuelle se calcule comme le ratio de 2 années
#' @param Monnaie	= variable prennant en compte le passage des anciens francs aux nouveaux francs en 1960 
#' et le passage des francs aux euros en 2002 (1 € = 6,55957 FF).
#' 
#' @examples
#' data(INSEEpa)
#'  
#' @source \url{https://www.insee.fr/fr/information/2417794}
"INSEEpa"