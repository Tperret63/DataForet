#' Fichier placettes de l'IFN.
#'
#' Base Placettes de l'IFN contenant près d'un million de lignes et 14 variables
#'
#' @format Fichier contenant près de 87535 lignes et 8 variables
#' 
#' \describe{
#'   \item{idp}{identifiant du point d’inventaire}
#'   \item{xl93, yl93}{coordonnées (latitude, longitude) en Lambert 93}
#'   \item{ser}{sylvoécorégion}
#'   \item{csa}{couverture du sol}
#'   \item{dc}{type de coupe}
#'   \item{dist}{distance de débardage}
#'   \item{Annee}{année de mesure}
#' }
#' 
#' @examples
#' data(IFNplacettes)
#' 
#' @source \url{https://inventaire-forestier.ign.fr}
"IFNplacettes"