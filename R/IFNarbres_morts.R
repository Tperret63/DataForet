#' Fichier arbres de l'IFN.
#'
#' @description Base arbres morts de l'IFN inventoriés sur les placettes forestières contenant pas moins de 50 000 lignes et 10 variables.
#'  Les modalités des variables espar, veget, datemort et ori se trouvent 
#'  dans la table CodesIFNmod. Les modalités de la variable espar se trouvent dans la table
#'  CodesEssIFN.
#'
#' @format Data frame contenant pas moins de 50 000 lignes et 10 variables
#' 
#' @param idp = identifiant du point d’inventaire
#' @param a = identifiant de l’arbre
#' @param espar = espèce arborée
#' @param veget = origine de l’arbre
#' @param datemort = date présumée de la mort
#' @param ori = origine de l’arbre
#' @param c13 = circonférence à 1,30 m (cm)
#' @param v = volume de l'arbre (donnée calculée)
#' @param w = coefficient de pondération de l’arbre (donnée calculée)
#' @param Annee = année de mesure
#' 
#' @examples
#' data(IFNarbres_morts)
#' 
#' @source \url{https://inventaire-forestier.ign.fr}
"IFNarbres_morts"
