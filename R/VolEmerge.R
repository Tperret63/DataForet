#' Coefficients par essence pour le tarif de cubage issu du projet EMERGE (volume total)
#'
#' @description Coefficients du tarif de cubage issu du projet EMERGE nécessaires pour calculer le volume total 
#' d'un arbre (volume total aérien, jusqu'à extrêmité des rameaux), par essence.
#'
#' @format data frame
#' 
#' @param CodeIFN = code de l'essence dans la base de données de l'IFN
#' @param Essence = essence pour lesquelles le modèle a été testé et validé statistiquement
#' @param A = sans unité, spécifique à l'essence
#' @param B = robustesse, commune pour tous les feuillus ou tous les résineux
#' @param C = défilement, sans unité, spécifique à l'essence 
#' 
#' @examples
#' data(VolEmerge)
#' Fonction associée Tarif_EMERGE() pour le calcul
#' 
#' @source C. Deleuze, F. Morneau, J.P. Renaud, Y. Vivien, M. Rivoire, et al.. 
#' Estimer le volume total d’un arbre, quelles que soient l’essence, la taille, la sylviculture, 
#' la station. Rendez-vous Techniques ONF, 2014, pp.22-32. hal-01143797
#' 
#' @author Marie-Laure Martin

"VolEmerge"