#' Sylvoécorégions.
#'
#' Carte des sylvoécorégions
#'
#' @format Fichier géoréférencé contenant 86 sylvoécorégions.
#' 
#' \describe{
#'   \item{codeser}{code de la sylvoécorégion}
#'   \item{NomSER}{Nom de la sylvoécorégion}
#'   \item{greco}{Nom de la grande région écologique}
#'   \item{geometry}{géométrie}
#' }
#' 
#' @examples
#' data(ser)
#' plot(st_geometry(ser))
#' 
#' @source \url{https://inventaire-forestier.ign.fr/spip.php?article729}
"ser"
