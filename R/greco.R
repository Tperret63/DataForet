#' Grandes Régions Ecologiques (GRECO).
#'
#' @description Carte des Grandes Régions Ecologiques
#'
#' @format Fichier géoréférencé au format sf contenant les 11 grandes régions écologiques
#' 
#' @param greco = identifiant de la GRECO
#' @param geometry = géométrie
#' 
#' @examples
#' data(ser)
#' plot(st_geometry(greco), border='blue', lwd=2)
#' plot(st_geometry(ser), add=T, border='red')
#'  
#' @source \url{https://inventaire-forestier.ign.fr/spip.php?article729}
"greco"