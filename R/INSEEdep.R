#' Départements français.
#'
#' @description Liste des départemets français existants au 1er janvier 2017.
#' Cette table permet la correspondance avec les régions.
#'
#' @format Data frame contenant 101 lignes et 5 variables.
#' 
#' @param REGION = Code région
#' @param DEP = Code département
#' @param CHEFLIEU = Chef-lieu d'arrondissement, de département, de région ou bureau centralisateur de canton
#' @param TNCC = Type de nom en clair
#' @param NCC = Nom en clair (majuscules)
#' @param NCCENR = Nom en clair (typographie riche)
#' 
#' @examples
#' data(INSEEdep)
#'  
#' @source \url{https://www.insee.fr/fr/information/2666684#titre-bloc-26}
"INSEEdep"