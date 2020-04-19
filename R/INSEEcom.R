#' Communes françaises.
#'
#' @description Liste des communes françaises existantes au 1er janvier 2017.
#' Cette table permet la correspondance avec les régions, départements, cantons et arrondissements.
#'
#' @format Data frame contenant 35416 lignes et 12 variables.
#' 
#' @param CDC	= Découpage de la commune en cantons
#' @param CHEFLIEU = Chef-lieu d'arrondissement, de département, de région ou bureau centralisateur de canton
#' @param REG	= Code région
#' @param DEP	= Code département
#' @param COM	= Code commune
#' @param AR = Code arrondissement
#' @param CT = Code canton
#' @param TNCC = Type de nom en clair
#' @param ARTMAJ = Article (majuscules)
#' @param NCC = Nom en clair (majuscules)
#' @param ARTMIN = Article (typographie riche)
#' @param NCCENR = Nom en clair (typographie riche)
#' 
#' @examples
#' data(INSEEcom)
#'  
#' @source \url{https://www.insee.fr/fr/information/2666684#titre-bloc-26}
"INSEEcom"