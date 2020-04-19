#' Fichier arbres de l'IFN.
#'
#' @description Base Arbres de l'IFN contenant près d'un million de lignes et 14 variables.
#'  Les modalités des variables espar, veget, mortb, acci et ori se trouvent 
#'  dans la table CodesIFNmod. Les modalités de la variable espar se trouvent dans la table
#'  CodesEssIFN.
#'
#' @format Data frame contenant près de 1 million de lignes et 14 variables
#' 
#' @param idp = identifiant du point d’inventaire
#' @param a = identifiant de l’arbre
#' @param espar = espèce arborée
#' @param veget = origine de l’arbre
#' @param mortb = mortalité de branches dans le houppier
#' @param acci = accident de l'arbre
#' @param ori = origine de l’arbre
#' @param c13 = circonférence à 1,30 m (cm)
#' @param ir5 = accroissement radial sous écorce sur 5 ans (mm)
#' @param htot = hauteur totale (m)
#' @param hdec = hauteur à la découpe (m)
#' @param v = volume de l'arbre (donnée calculée)
#' @param w = coefficient de pondération de l’arbre (donnée calculée)
#' @param Annee = année de mesure
#' 
#' @examples
#' data(IFNarbres)
#' 
#' @source \url{https://inventaire-forestier.ign.fr}
"IFNarbres"

